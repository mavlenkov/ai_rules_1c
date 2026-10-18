"""Offline behavioural tests. All writes occur in disposable Git fixtures."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("upstream_sync.py")


class SyncTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.remote = self.root / "vendor"
        self.source = self.root / "source"
        self.remote.mkdir()
        self.git(self.remote, "init", "-b", "main")
        self.base = self.commit(self.remote, "content/rules/base.md", "base\n")
        self.git(self.root, "clone", str(self.remote), str(self.source))
        self.config = self.root / "config.json"
        self.config.write_text(json.dumps({"remote": "origin", "url": str(self.remote), "branch": "main"}))
        self.state = self.source / ".git/upstream-sync/state.json"
        self.call("accept", "--initialize", self.base, expected=0)

    def git(self, repo, *args, input=None):
        env = dict(os.environ, GIT_AUTHOR_NAME="Fixture", GIT_AUTHOR_EMAIL="fixture@example.invalid",
                   GIT_COMMITTER_NAME="Fixture", GIT_COMMITTER_EMAIL="fixture@example.invalid")
        return subprocess.run(["git", "-c", "core.hooksPath=/dev/null", "-C", str(repo), *args],
                              input=input, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              env=env, check=True).stdout.strip()

    def commit(self, repo, path, text):
        target = repo / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)
        self.git(repo, "add", "--", path)
        self.git(repo, "commit", "-m", "Change " + path)
        return self.git(repo, "rev-parse", "HEAD")

    def call(self, *args, expected):
        result = subprocess.run([sys.executable, "-B", str(SCRIPT), "--repo", str(self.source),
                                 "--config", str(self.config), *args],
                                text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result.stdout + result.stderr

    def advance(self):
        return self.commit(self.remote, "content/skills/new/SKILL.md", "new skill\n")

    def snapshot(self):
        # Byte inventory includes dirty, staged and untracked files; index compared raw.
        files = {str(p.relative_to(self.source)): p.read_bytes()
                 for p in self.source.rglob("*") if p.is_file() and ".git" not in p.relative_to(self.source).parts}
        return (files, (self.source / ".git/index").read_bytes(),
                (self.source / ".git/HEAD").read_bytes(), self.git(self.source, "rev-parse", "HEAD"),
                self.git(self.source, "show-ref"))

    def test_update_summary_and_stable_repeat(self):
        tip = self.advance()
        output = self.call("check", expected=1)
        self.assertIn("Есть кандидат", output)
        self.assertIn("content/skills", output)
        self.assertIn("1 file changed", output)
        self.assertIn("Полный diff:", output)
        state = json.loads(self.state.read_text())
        self.assertEqual(state["accepted"], self.base)
        self.assertEqual(state["seen"], tip)
        before = (self.state.read_bytes(), self.state.stat().st_mtime_ns)
        self.assertEqual(self.call("check", expected=1), output)
        self.assertEqual((self.state.read_bytes(), self.state.stat().st_mtime_ns), before)
        self.assertEqual(list(self.state.parent.glob("state*.json")), [self.state])

    def test_no_updates_and_repeat(self):
        self.assertIn("Обновлений нет", self.call("check", expected=0))
        before = (self.state.read_bytes(), self.state.stat().st_mtime_ns)
        self.call("check", expected=0)
        self.assertEqual((self.state.read_bytes(), self.state.stat().st_mtime_ns), before)

    def test_dirty_tree_index_branch_and_user_files_preserved(self):
        self.advance()
        tracked = self.source / "content/rules/base.md"
        tracked.write_text("staged\n")
        self.git(self.source, "add", "content/rules/base.md")
        tracked.write_text("unstaged after staging\n")
        (self.source / "user.txt").write_bytes(b"untracked\x00\xff")
        before = self.snapshot()
        self.call("check", expected=1)
        self.assertEqual(self.snapshot(), before)

    def test_rewritten_history_preserves_state(self):
        self.advance()
        self.call("check", expected=1)
        tree = self.git(self.remote, "rev-parse", "HEAD^{tree}")
        unrelated = self.git(self.remote, "commit-tree", tree, input="rewritten root\n")
        self.git(self.remote, "update-ref", "refs/heads/main", unrelated)
        before = self.state.read_bytes()
        output = self.call("check", expected=2)
        self.assertIn("Переписанная история", output)
        self.assertEqual(self.state.read_bytes(), before)

    def test_unavailable_remote_preserves_state(self):
        self.advance()
        self.call("check", expected=1)
        before = self.state.read_bytes()
        # Keep identity unchanged, make the local remote inaccessible as a Git repo.
        self.git(self.remote, "config", "core.repositoryformatversion", "999")
        output = self.call("check", expected=2)
        self.assertIn("Git fetch", output)
        self.assertEqual(self.state.read_bytes(), before)

    def test_remote_identity_drift(self):
        before = self.state.read_bytes()
        self.git(self.source, "remote", "set-url", "origin", str(self.root / "other"))
        self.assertIn("identity", self.call("check", expected=2))
        self.assertEqual(self.state.read_bytes(), before)

    def test_accept_and_check(self):
        tip = self.advance()
        # Simulate an already integrated source, without running vendor code.
        self.git(self.source, "fetch", "origin", "main")
        tree = self.git(self.source, "rev-parse", "HEAD^{tree}")
        merge = self.git(self.source, "commit-tree", tree, "-p", self.base, "-p", tip,
                         input="Fixture source integration\n")
        self.git(self.source, "update-ref", "HEAD", merge)
        self.call("check", expected=1)
        self.call("accept", tip, expected=0)
        state = json.loads(self.state.read_text())
        self.assertEqual(state["accepted"], tip)
        self.assertEqual(state["source"], merge)
        self.assertIsNone(state["candidate"])
        self.call("check", expected=0)

    def test_accept_refuses_unintegrated_candidate(self):
        tip = self.advance()
        self.call("check", expected=1)
        before = self.state.read_bytes()
        self.assertIn("не входит", self.call("accept", tip, expected=2))
        self.assertEqual(self.state.read_bytes(), before)

    def test_accept_refuses_source_drift_and_wrong_sha(self):
        tip = self.advance()
        self.call("check", expected=1)
        before = self.state.read_bytes()
        self.call("accept", self.base, expected=2)
        self.commit(self.source, "local.txt", "source drift\n")
        self.assertIn("source изменилась", self.call("accept", tip, expected=2))
        self.assertEqual(self.state.read_bytes(), before)

    def test_initialize_cannot_reset_existing_baseline(self):
        before = self.state.read_bytes()
        self.call("accept", "--initialize", self.base, expected=2)
        self.assertEqual(self.state.read_bytes(), before)

    def test_no_repository_returns_two(self):
        self.source = self.root
        self.call("check", expected=2)

    def test_missing_baseline_returns_two(self):
        # A second fresh clone has no state; check must not choose upstream HEAD.
        self.source = self.root / "fresh"
        self.git(self.root, "clone", str(self.remote), str(self.source))
        self.assertIn("Нет принятой базы", self.call("check", expected=2))
        self.assertFalse((self.source / ".git/upstream-sync/state.json").exists())

    def test_vendor_hooks_and_diff_helpers_not_executed(self):
        self.advance()
        marker = self.root / "executed"
        hook = self.source / ".git/hooks/reference-transaction"
        hook.write_text(f"#!/bin/sh\ntouch '{marker}'\n")
        hook.chmod(0o755)
        self.git(self.source, "config", "diff.external", f"touch {marker}")
        self.call("check", expected=1)
        self.assertFalse(marker.exists())

    def test_malformed_state_returns_two_unchanged(self):
        self.state.write_text("[]")
        self.call("check", expected=2)
        self.assertEqual(self.state.read_text(), "[]")


if __name__ == "__main__":
    unittest.main()
