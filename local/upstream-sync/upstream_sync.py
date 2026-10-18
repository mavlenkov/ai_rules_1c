#!/usr/bin/env python3
"""Read-only upstream discovery; only explicit accept advances the baseline."""

import argparse
from collections import defaultdict
import fcntl
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile


class SyncError(Exception):
    pass


class Parser(argparse.ArgumentParser):
    def error(self, message):
        raise SyncError(message)


class Repository:
    def __init__(self, path):
        self.path = Path(path).resolve()
        self.env = os.environ.copy()
        for key in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_COMMON_DIR",
                    "GIT_OBJECT_DIRECTORY", "GIT_ALTERNATE_OBJECT_DIRECTORIES",
                    "GIT_NAMESPACE", "GIT_SHALLOW_FILE"):
            self.env.pop(key, None)
        self.env.update(GIT_OPTIONAL_LOCKS="0", GIT_TERMINAL_PROMPT="0",
                        GIT_NO_REPLACE_OBJECTS="1", LC_ALL="C")
        if self.git("rev-parse", "--is-inside-work-tree").strip() != "true":
            raise SyncError("Нужен исходный Git-репозиторий с рабочим деревом.")
        common = Path(self.git("rev-parse", "--git-common-dir").strip())
        self.common = (self.path / common).resolve()

    def git(self, *args, allowed=(0,)):
        result = subprocess.run(
            ["git", "-c", "core.hooksPath=/dev/null", "-c", "core.fsmonitor=false",
             "-c", "gc.auto=0", "-c", "maintenance.auto=false", "-C", str(self.path), *args],
            env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            encoding="utf-8", errors="replace", timeout=180,
        )
        if result.returncode not in allowed:
            raise SyncError(f"Git {args[0]}: {result.stderr.strip() or result.stdout.strip()}")
        return result.stdout if allowed == (0,) else result.returncode

    def sha(self, revision):
        if not re.fullmatch(r"[0-9a-fA-F]{7,64}", revision):
            raise SyncError("Ожидается точная SHA коммита (не имя ветки).")
        return self.git("rev-parse", "--verify", revision + "^{commit}").strip()

    def ancestor(self, base, tip):
        return self.git("merge-base", "--is-ancestor", base, tip, allowed=(0, 1)) == 0


def load_json(path):
    with path.open(encoding="utf-8") as stream:
        value = json.load(stream)
    if not isinstance(value, dict):
        raise SyncError(f"Ожидается JSON-объект: {path}")
    return value


def save_state(path, state):
    """No timestamp or rewrite on a repeated observation; replace atomically."""
    data = json.dumps(state, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if path.exists() and path.read_text(encoding="utf-8") == data:
        return
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent,
                                     prefix="state-", delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        except BaseException:
            temporary.unlink(missing_ok=True)
            raise
    try:
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def validate_state(repo, state, identity):
    if state.get("version") != 1 or state.get("upstream") != identity:
        raise SyncError("Состояние принадлежит другому upstream или имеет неизвестную версию.")
    for key in ("accepted", "seen", "source"):
        if not isinstance(state.get(key), str) or repo.sha(state[key]) != state[key]:
            raise SyncError(f"Некорректная SHA состояния: {key}")
    if not repo.ancestor(state["accepted"], state["seen"]):
        raise SyncError("Некорректное состояние: seen не продолжает accepted.")
    expected = None if state["seen"] == state["accepted"] else {
        "base": state["accepted"], "upstream": state["seen"], "source_base": state["source"]
    }
    if state.get("candidate") != expected:
        raise SyncError("Некорректный идентификатор кандидата.")


def changed_paths(repo, base, tip):
    return set(filter(None, repo.git("diff", "--no-ext-diff", "--no-textconv",
                                   "--no-renames", "--name-only", "-z", base, tip, "--").split("\0")))


def area(path):
    parts = path.split("/")
    if parts[0] == "content" and len(parts) > 2:
        return "/".join(parts[:2])
    if parts[0] in ("adapters", ".github", "tools", "scripts", "local"):
        return parts[0]
    if parts[0].startswith(".") and len(parts) > 1:
        return "клиентские экспорты/" + parts[0]
    return "корень/прочее"


def summary(repo, base, seen, source):
    lines = [f"Принятая upstream: {base}", f"Увиденная upstream: {seen}",
             f"Наша source SHA: {source}"]
    if base == seen:
        return "\n".join(["Обновлений нет.", *lines])
    files = changed_paths(repo, base, seen)
    local = changed_paths(repo, base, source)
    overlap = files & local
    groups = defaultdict(list)
    for path in sorted(files):
        groups[area(path)].append(path)
    lines.insert(0, "Есть кандидат обновления (ничего не применяется).")
    lines.append("Новые коммиты:")
    lines.append(repo.git("log", "--format=%h %s", "--no-decorate", f"{base}..{seen}", "--").rstrip())
    lines.append("Файлы по областям (* — пересечение с source относительно принятой базы):")
    for name, paths in sorted(groups.items()):
        lines.append(f"  {name}: {len(paths)}")
        lines.extend(f"    {'*' if path in overlap else ' '} {json.dumps(path, ensure_ascii=False)}" for path in paths)
    lines.append("Размер: " + repo.git("diff", "--no-ext-diff", "--no-textconv", "--no-renames",
                                       "--shortstat", base, seen, "--").strip())
    lines.append(f"Пересечений: {len(overlap)} (не доказательство конфликта; dirty-файлы не анализируются).")
    lines.append("Полный diff: " + shlex.join(["git", "-C", str(repo.path), "diff",
                 "--no-ext-diff", "--no-textconv", base, seen, "--"]))
    lines.append("Scope: только обнаружение. Перед принятием проверь diff, Linux-адаптацию и затронутые форматы; семантика не проверена.")
    return "\n".join(lines)


def run(args):
    repo = Repository(args.repo)
    identity = load_json(Path(args.config))
    if set(identity) != {"remote", "url", "branch"} or not all(isinstance(v, str) and v for v in identity.values()):
        raise SyncError("Конфигурация должна задавать remote, url и branch.")
    if identity["remote"] != "origin" or identity["branch"] != "main":
        raise SyncError("Этот инструмент проверяет только origin main.")
    urls = repo.git("remote", "get-url", "--all", "origin").splitlines()
    if urls != [identity["url"]]:
        raise SyncError("Remote identity изменилась: URL origin не совпадает с конфигурацией.")
    state_path = (repo.common / "upstream-sync" / "state.json")
    state_path.parent.mkdir(parents=True, exist_ok=True)
    # Serialize check/accept, including fetch and the read-modify-write transaction.
    with (state_path.parent / "lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state = load_json(state_path) if state_path.exists() else None
        source = repo.git("rev-parse", "--verify", "HEAD^{commit}").strip()
        if state is not None:
            validate_state(repo, state, identity)
        if args.command == "accept":
            accepted = repo.sha(args.sha)
            if args.initialize:
                if state is not None:
                    raise SyncError("База уже задана; --initialize не может её заменить.")
                if not repo.ancestor(accepted, source):
                    raise SyncError("Начальная принятая база не входит в историю source.")
            else:
                if state is None:
                    raise SyncError("Нет базы: выполни accept --initialize <подтверждённая-SHA>.")
                if accepted != state["seen"] or source != state["source"]:
                    raise SyncError("SHA не совпадает с увиденным кандидатом или source изменилась; повтори check.")
                if not repo.ancestor(accepted, source):
                    raise SyncError("Кандидат ещё не входит в историю source; accept не выполняет интеграцию.")
            new_state = {"version": 1, "upstream": identity, "accepted": accepted,
                         "seen": accepted, "source": source, "candidate": None}
            save_state(state_path, new_state)
            print(f"Принята upstream SHA: {accepted}\nSource SHA: {source}\nСостояние: {state_path}")
            return 0
        if state is None:
            raise SyncError("Нет принятой базы. Сначала accept --initialize <подтверждённая-SHA>; check базу не выбирает.")
        if repo.git("rev-parse", "--is-shallow-repository").strip() == "true":
            raise SyncError("Shallow-репозиторий: ancestry нельзя надёжно проверить; нужна полная история.")
        repo.git("fetch", "--no-tags", "--no-recurse-submodules", "--no-auto-maintenance",
                 "--no-prune", "--refmap=", "origin", "main")
        seen = repo.git("rev-parse", "--verify", "FETCH_HEAD^{commit}").strip()
        if not repo.ancestor(state["accepted"], seen):
            raise SyncError("Переписанная история: origin/main не продолжает принятую upstream SHA. Состояние не изменено.")
        report = summary(repo, state["accepted"], seen, source)
        new_state = dict(state, seen=seen, source=source, candidate=None)
        if seen != state["accepted"]:
            new_state["candidate"] = {"base": state["accepted"], "upstream": seen, "source_base": source}
        save_state(state_path, new_state)
        print(report)
        print(f"Состояние: {state_path}")
        return int(seen != state["accepted"])


def main(argv=None):
    parser = Parser(description="Проверка upstream без применения; коды check: 0/1/2.")
    parser.add_argument("--repo", default=str(Path(__file__).resolve().parents[2]))
    parser.add_argument("--config", default=str(Path(__file__).with_name("config.json")))
    commands = parser.add_subparsers(dest="command", required=True, parser_class=Parser)
    commands.add_parser("check", help="fetch origin main и сводка")
    accept = commands.add_parser("accept", help="явно зафиксировать точную upstream SHA")
    accept.add_argument("sha")
    accept.add_argument("--initialize", action="store_true", help="задать подтверждённую базу впервые")
    try:
        return run(parser.parse_args(argv))
    except (SyncError, OSError, ValueError, subprocess.TimeoutExpired) as error:
        print(f"Ошибка: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
