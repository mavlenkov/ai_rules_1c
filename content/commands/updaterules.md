---
description: Update the 1c-rules ruleset from GitHub (fork mavlenkov/ai_rules_1c)
---

# /updaterules — update 1c-rules

Source (this fork): `https://github.com/mavlenkov/ai_rules_1c` — the Linux + 1CFilesConverter edition. Update from the fork's own `origin`, **not** from upstream `comol/ai_rules_1c`, otherwise fork-specific changes (bash installer, Linux command adaptations) are lost. Pull upstream changes into the fork through a separate `git merge` of the upstream remote, not through `/updaterules`.

Action: update managed files in the current installation to the latest fork version (on-demand rules, subagent descriptions, slash commands, SKILL packages, MCP config, OpenSpec bundle, rendered `AGENTS.md`). Preserve:

- `USER-RULES.md` and `memory.md` — one-time templates, never overwritten;
- `.dev.env` — never overwritten (user secrets / connection params);
- contents of `openspec/specs/` and `openspec/changes/` — copied in skip-if-exists mode;
- any managed file marked `userModified: true` in `.ai-rules.json`.

## Steps

1. Make sure `.ai-rules.json` exists at the project root. If it is missing, this is a first install: run `init` per `AGENT-INSTALL.md`, not `/updaterules`.

2. **Detect OS** (`uname -s` / `%PROGRAMFILES%`) and run the matching channel.

### Linux / macOS — bash channel (fork)

> **Caveat — this is a refresh, not a true update.** `scripts/install.sh` is a one-shot re-installer: it **unconditionally overwrites** managed files (rules, agents, commands, skills, `AGENTS.md`, MCP config) and rewrites `.ai-rules.json`. It does **not** honor `userModified: true` — local edits to managed files are lost. It re-detects active tools by directory presence (`.cursor/` / `.claude/` / `.opencode/`), **not** from `.ai-rules.json`. For full update semantics (userModified preservation, manifest-driven tool set), use the PowerShell channel under `pwsh`.
>
> Safe before running: commit or stash any local edits to managed files. Preserved automatically: `USER-RULES.md` and `memory.md` (skip-if-exists), `.dev.env` (never touched), `openspec/specs/` and `openspec/changes/` (skip-if-exists).

```bash
src=/tmp/1c-rules
if [ -d "$src/.git" ]; then
    git -C "$src" fetch --depth 1 origin HEAD && git -C "$src" reset --hard FETCH_HEAD
else
    git clone --depth 1 https://github.com/mavlenkov/ai_rules_1c.git "$src"
fi
# Re-place managed files. Add --tools cursor,claude-code,opencode if auto-detect misses a tool.
"$src/scripts/install.sh" "$(pwd)"
```

Codex and Kilo Code are not covered by the bash installer — for those use the PowerShell channel under `pwsh`.

### Windows — PowerShell channel

`install.ps1` expects a local path in `-Source`, so first clone or update the source into a cache under `$env:TEMP`:

```powershell
$src = Join-Path $env:TEMP '1c-rules'
if (Test-Path (Join-Path $src '.git')) {
    git -C $src fetch --depth 1 origin HEAD
    git -C $src reset --hard FETCH_HEAD
} else {
    git clone --depth 1 https://github.com/mavlenkov/ai_rules_1c.git $src
}
& "$src\install.ps1" update -Source $src -AssumeYes
```

3. Check installer output:
   - `Update complete.` / `Манифест .ai-rules.json: N файлов записано` — success;
   - `User-modified files detected: N` (PowerShell) — files with local edits; marked `userModified` and preserved;
   - `Verification OK` / `Verification found N mismatch(es)` — state of freshly placed files.

4. If neither channel is available (no `git`/`pwsh`/`bash`), execute *Update / add / remove* from `AGENT-INSTALL.md` through the agent channel: re-place managed files from the updated clone, re-render `AGENTS.md`, and update `version` and `updatedAt` in `.ai-rules.json`. Do not touch `USER-RULES.md`, `memory.md`, or `.dev.env`.

## Parameters (PowerShell channel)

- `-AssumeYes` — answers "yes" to confirmations and keeps user edits (`keep`) on conflicting files. For a fully automated run (CI), add `-NonInteractive`.
- `-Tools cursor,claude-code` — not needed: active tools are read from `.ai-rules.json`.
