#!/usr/bin/env python3
"""Collect structured data about the ai_rules_1c repository for later analysis.

Outputs:
  analysis/project-data.json   — full machine-readable dataset
  analysis/project-data-report.md — human-readable summary report

Run from the repository root: python3 analysis/collect_project_data.py
"""
import datetime
import json
import pathlib
import re
import subprocess

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"
OUT = ROOT / "analysis"


def git(*args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(ROOT), *args],
        capture_output=True, text=True, check=True,
    ).stdout.strip()


def read_text(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8", errors="replace")


def frontmatter(p: pathlib.Path):
    """Return (frontmatter_dict, body_text, parse_error|None)."""
    lines = read_text(p).splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, "\n".join(lines), None
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return {}, "\n".join(lines), None
    fm_text = "\n".join(lines[1:end])
    try:
        data = yaml.safe_load(fm_text)
    except Exception as e:  # noqa: BLE001
        return {}, "\n".join(lines[end + 1:]), str(e)
    if data is None:
        data = {}
    if not isinstance(data, dict):
        data = {"__non_dict__": str(data)}
    return data, "\n".join(lines[end + 1:]), None


def file_info(p: pathlib.Path):
    text = read_text(p)
    lines = text.splitlines()
    fm, body, err = frontmatter(p)
    info = {
        "path": str(p.relative_to(ROOT)),
        "bytes": p.stat().st_size,
        "lines": len(lines),
        "body_lines": len(body.splitlines()),
        "frontmatter": fm,
        "frontmatter_parse_error": err,
    }
    return info


def collect_dir(subdir: str) -> list:
    d = CONTENT / subdir
    if not d.exists():
        return []
    items = []
    if subdir == "skills":
        for skill_dir in sorted(d.iterdir()):
            if not skill_dir.is_dir():
                continue
            sk = skill_dir / "SKILL.md"
            if sk.exists():
                items.append(file_info(sk))
            else:
                items.append({
                    "path": str(skill_dir.relative_to(ROOT)),
                    "bytes": 0, "lines": 0, "body_lines": 0,
                    "frontmatter": {}, "frontmatter_parse_error": "no SKILL.md",
                })
        return items
    for f in sorted(d.glob("*.md")):
        items.append(file_info(f))
    return items


def collect_adapters() -> list:
    out = []
    for f in sorted((ROOT / "adapters").glob("*.yaml")):
        try:
            data = yaml.safe_load(read_text(f)) or {}
        except Exception as e:  # noqa: BLE001
            out.append({"tool": f.stem, "parse_error": str(e)})
            continue
        sections = {}
        for sec in ("rules", "agents", "commands", "skills", "mcp"):
            if sec in data:
                sections[sec] = data[sec]
        out.append({
            "file": f.name,
            "tool": data.get("tool"),
            "schemaVersion": data.get("schemaVersion"),
            "detection": data.get("detection"),
            "sections": sections,
        })
    return out


def collect_mcp_servers():
    f = CONTENT / "mcp-servers.json"
    if not f.exists():
        return None
    try:
        return json.loads(read_text(f))
    except Exception as e:  # noqa: BLE001
        return {"parse_error": str(e)}


def headings(p: pathlib.Path, level: int) -> list:
    return [ln for ln in read_text(p).splitlines() if ln.startswith("#" * level + " ")]


def parse_additional_rules(p: pathlib.Path) -> list:
    """Parse the '# Additional rules (load on demand)' index from AGENTS.md."""
    text = read_text(p)
    m = re.search(r"^# Additional rules \(load on demand\)\s*$", text, re.M)
    if not m:
        return []
    block = text[m.end():]
    rules = []
    for line in block.splitlines():
        m2 = re.match(r"- \*\*`?([\w-]+)`?\*\*", line)
        if m2:
            rules.append({"name": m2.group(1), "cue_line": line[:160]})
    return rules


def skill_docs_inventory(subdir: str) -> dict:
    """Per-skill file inventory for content/skills."""
    d = CONTENT / subdir
    out = {}
    if not d.exists():
        return out
    for skill_dir in sorted(d.iterdir()):
        if not skill_dir.is_dir():
            continue
        files = sorted(str(f.relative_to(ROOT)) for f in skill_dir.rglob("*") if f.is_file())
        out[skill_dir.name] = {
            "files": files,
            "count": len(files),
            "total_bytes": sum(f.stat().st_size for f in skill_dir.rglob("*") if f.is_file()),
        }
    return out


def main() -> None:
    data = {
        "_meta": {
            "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "script": "analysis/collect_project_data.py",
        },
        "repo": {
            "root": str(ROOT),
            "name": ROOT.name,
            "branch": git("branch", "--show-current"),
            "head": git("rev-parse", "HEAD"),
            "head_short": git("rev-parse", "--short", "HEAD"),
            "total_commits": int(git("rev-list", "--count", "HEAD")),
            "first_commit_date": git("log", "--format=%ai", "--reverse").splitlines()[0],
            "last_commit_date": git("log", "-1", "--format=%ai"),
            "working_tree_clean": bool(git("status", "--porcelain") == ""),
            "status_porcelain": git("status", "--porcelain"),
            "remotes": git("remote", "-v"),
            "tracked_files": int(git("ls-files").count("\n") + 1),
        },
        "git": {
            "authors": git("shortlog", "-sne", "HEAD"),
            "branches": git("branch", "-a"),
            "last_commits": git("log", "--format=%h|%ai|%an|%s", "-25"),
        },
        "content": {},
        "adapters": collect_adapters(),
        "mcp_servers": collect_mcp_servers(),
        "openspec": {
            "project_md": read_text(ROOT / "openspec" / "project.md"),
            "specs": [str(p.relative_to(ROOT)) for p in (ROOT / "openspec" / "specs").rglob("*.md")],
            "changes_archive": [str(p.relative_to(ROOT)) for p in (ROOT / "openspec" / "changes" / "archive").rglob("*.md")],
        },
        "fork_todo": {
            "headings": headings(ROOT / "FORK-TODO.md", 2),
            "subheadings": headings(ROOT / "FORK-TODO.md", 3),
        },
        "agents_md": {
            "sections": headings(ROOT / "AGENTS.md", 2),
            "subsections": headings(ROOT / "AGENTS.md", 3),
            "rule_references": sorted(set(
                re.findall(r"content/rules/([\w-]+)\.md", read_text(ROOT / "AGENTS.md"))
            )),
            "additional_rules": parse_additional_rules(ROOT / "AGENTS.md"),
        },
        "dev_env": {
            "sections": [
                ln.strip("# ").strip()
                for ln in read_text(ROOT / ".dev.env.example").splitlines()
                if ln.startswith("# Раздел") or ln.startswith("# Section")
            ],
            "lines": (ROOT / ".dev.env.example").stat().st_size,
        },
        "workflow": read_text(ROOT / ".github" / "workflows" / "validate-rules.yml")[:4000],
        "scripts": {
            "install_sh_lines": len(read_text(ROOT / "scripts" / "install.sh").splitlines()),
            "tools": [
                {
                    "file": p.name,
                    "lines": len(read_text(p).splitlines()),
                    "bytes": p.stat().st_size,
                }
                for p in sorted((ROOT / "tools").glob("*.ps1"))
            ],
        },
        "bundle": {
            "tools": sorted(p.name for p in (CONTENT / "openspec-bundle").iterdir() if p.is_dir()),
            "version": read_text(CONTENT / "openspec-bundle" / "version.txt").strip(),
            "files_per_tool": {
                p.name: len(list(p.rglob("*")))
                for p in sorted((CONTENT / "openspec-bundle").iterdir()) if p.is_dir()
            },
        },
    }

    for subdir in ("rules", "agents", "commands", "skills"):
        items = collect_dir(subdir)
        data["content"][subdir] = items
        data["content"][subdir + "_stats"] = {
            "count": len(items),
            "total_lines": sum(i["lines"] for i in items),
            "total_bytes": sum(i["bytes"] for i in items),
        }

    data["content"]["skills_inventory"] = skill_docs_inventory("skills")
    data["content"]["total_stats"] = {
        "count": sum(data["content"][s + "_stats"]["count"] for s in ("rules", "agents", "commands", "skills")),
        "total_lines": sum(data["content"][s + "_stats"]["total_lines"] for s in ("rules", "agents", "commands", "skills")),
        "total_bytes": sum(data["content"][s + "_stats"]["total_bytes"] for s in ("rules", "agents", "commands", "skills")),
    }
    # data-quality findings: frontmatter parse errors / missing required fields
    findings = []
    for sub in ("rules", "agents", "commands", "skills"):
        for i in data["content"][sub]:
            if i["frontmatter_parse_error"]:
                findings.append({"type": "frontmatter-parse-error", "file": i["path"],
                                 "detail": i["frontmatter_parse_error"]})
            if sub == "rules" and not i["frontmatter"].get("description"):
                findings.append({"type": "rule-without-description", "file": i["path"]})
            if sub == "commands" and not i["frontmatter"].get("description"):
                findings.append({"type": "command-without-description", "file": i["path"]})
    data["data_quality_findings"] = findings

    # Root file inventory
    root_files = [
        file_info(p) for p in sorted(ROOT.iterdir())
        if p.is_file() and not p.name.startswith(".")
    ]
    data["root_files"] = root_files

    OUT.mkdir(exist_ok=True)
    (OUT / "project-data.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print("Wrote", OUT / "project-data.json")

    # ---- human-readable report ----
    r = data["repo"]
    lines_r = []
    lines_r.append("# ai_rules_1c — проект-датасет (снимок данных)")
    lines_r.append("")
    lines_r.append(f"- Сгенерировано: {data['_meta']['generated_at']}")
    lines_r.append(f"- Ветка: `{r['branch']}` @ `{r['head_short']}` ({r['head']})")
    lines_r.append(f"- Коммитов: {r['total_commits']}; период: {r['first_commit_date'][:10]} → {r['last_commit_date'][:10]}")
    lines_r.append(f"- Рабочее дерево: {'чистое' if r['working_tree_clean'] else 'ЕСТЬ ИЗМЕНЕНИЯ'}; отслеживаемых файлов: {r['tracked_files']}")
    lines_r.append("")
    lines_r.append("## Удалённые репозитории")
    for line in r["remotes"].splitlines():
        lines_r.append(f"- `{line}`")
    lines_r.append("")
    lines_r.append("## Git-ветки")
    for b in data["git"]["branches"].splitlines():
        lines_r.append(f"- {b}")
    lines_r.append("")
    lines_r.append("## Авторы (shortlog)")
    lines_r.append("```")
    lines_r.append(data["git"]["authors"])
    lines_r.append("```")
    lines_r.append("")
    lines_r.append("## Последние 25 коммитов")
    lines_r.append("```")
    lines_r.append(data["git"]["last_commits"])
    lines_r.append("```")
    lines_r.append("")
    lines_r.append("## content/ — объёмы")
    lines_r.append("")
    lines_r.append("| Каталог | Файлов | Строк | Байт |")
    lines_r.append("|---|---|---|---|")
    for sub in ("rules", "agents", "commands", "skills"):
        s = data["content"][sub + "_stats"]
        lines_r.append(f"| {sub} | {s['count']} | {s['total_lines']} | {s['total_bytes']} |")
    lines_r.append("")
    for sub in ("rules", "agents", "commands", "skills"):
        lines_r.append(f"## content/{sub}")
        lines_r.append("")
        lines_r.append("| Файл | Строк | name | description |")
        lines_r.append("|---|---|---|---|")
        for i in data["content"][sub]:
            fm = i["frontmatter"]
            name = str(fm.get("name", ""))
            desc = str(fm.get("description", ""))[:80].replace("|", "/").replace("\n", " ")
            lines_r.append(f"| `{i['path'].replace('content/', '')}` | {i['lines']} | {name} | {desc} |")
        lines_r.append("")
    lines_r.append("## Адаптеры (12)")
    lines_r.append("")
    for a in data["adapters"]:
        det = "; ".join(str(d) for d in a.get("detection") or []) if a.get("detection") else "(пусто — other)"
        lines_r.append(f"- **{a['tool']}** (schemaVersion {a.get('schemaVersion')}): detection = {det}")
        for sec, cfg in (a.get("sections") or {}).items():
            lines_r.append(f"  - `{sec}`: {json.dumps(cfg, ensure_ascii=False)}")
    lines_r.append("")
    lines_r.append("## MCP-серверы")
    lines_r.append("")
    mcp = data["mcp_servers"]
    if mcp and "servers" in mcp:
        for s in mcp["servers"]:
            lines_r.append(f"- `{s['id']}` ({s['transport']} {s['url']}) — {s['description'][:90]}")
    else:
        lines_r.append(str(mcp))
    lines_r.append("")
    lines_r.append("## OpenSpec")
    lines_r.append("")
    lines_r.append(f"- specs: {data['openspec']['specs']}")
    lines_r.append(f"- archived changes: {data['openspec']['changes_archive']}")
    lines_r.append("")
    lines_r.append("## FORK-TODO.md — пункты")
    lines_r.append("")
    for h in data["fork_todo"]["headings"]:
        lines_r.append(f"- {h}")
    lines_r.append("")
    lines_r.append("## AGENTS.md — секции")
    lines_r.append("")
    for h in data["agents_md"]["sections"]:
        lines_r.append(f"- {h}")
    lines_r.append("")
    lines_r.append(f"- Упоминаний правил `content/rules/*.md` в AGENTS.md: {len(data['agents_md']['rule_references'])}")
    lines_r.append("")
    lines_r.append("### Индекс '# Additional rules (load on demand)'")
    lines_r.append("")
    for r_ in data["agents_md"]["additional_rules"]:
        lines_r.append(f"- `{r_['name']}`")
    lines_r.append("")
    lines_r.append("## .dev.env.example — разделы")
    lines_r.append("")
    for s in data["dev_env"]["sections"]:
        lines_r.append(f"- {s}")
    lines_r.append("")
    lines_r.append("## Находки по качеству данных")
    lines_r.append("")
    if data["data_quality_findings"]:
        for f_ in data["data_quality_findings"]:
            lines_r.append(f"- **{f_['type']}**: `{f_['file']}` — {f_.get('detail', '')}")
    else:
        lines_r.append("- нет")
    lines_r.append("")
    lines_r.append("## OpenSpec bundle")
    lines_r.append("")
    lines_r.append(f"- tools: {', '.join(data['bundle']['tools'])}")
    lines_r.append(f"- версия: {data['bundle']['version']}")
    lines_r.append("")
    (OUT / "project-data-report.md").write_text("\n".join(lines_r), encoding="utf-8")
    print("Wrote", OUT / "project-data-report.md")
    print("Total rule refs in AGENTS.md:", len(data["agents_md"]["rule_references"]))


if __name__ == "__main__":
    main()
