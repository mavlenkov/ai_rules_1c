---
description: Update the 1c-rules ruleset from GitHub (fork mavlenkov/ai_rules_1c)
---

# /updaterules — update 1c-rules

Source (this fork): `https://github.com/mavlenkov/ai_rules_1c` — the Linux + 1CFilesConverter edition. Update from the fork's own `origin`, **not** from upstream `comol/ai_rules_1c`, otherwise fork-specific changes (bash installer, Linux command adaptations) are lost. Pull upstream changes into the fork through a separate `git merge` of the upstream remote, not through `/updaterules`.

Action: update managed files in the current installation to the latest fork version (on-demand rules, subagent descriptions, slash commands, SKILL packages, MCP config, OpenSpec bundle, rendered `AGENTS.md`). Preserve:

- `USER-RULES.md`, `memory.md`, and `LLM-RULES.md` — one-time templates, never overwritten (a missing `LLM-RULES.md` on an older install is placed by this update);
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

Kilo Code is not covered by the bash installer — for it use the PowerShell channel under `pwsh`.

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

The PowerShell channel applies every adapter frontmatter transform (including OpenCode `toolsToPermission` and Claude Code / Kimi / Qwen `toolsToDenylist`) and runs both agent frontmatter gates before reporting success. Prefer it over the agent channel whenever `git` / PowerShell are available.

3. Check installer output:
   - `Update complete.` / `Манифест .ai-rules.json: N файлов записано` — success;
   - `User-modified files detected: N` (PowerShell) — files with local edits; marked `userModified` and preserved; use `-Force` / `-ForcePaths` only when the user wants the shipped version;
   - `Verification OK` / `Verification found N mismatch(es)` — state of freshly placed files;
   - `OpenCode agent frontmatter OK` — OpenCode gate passed (or skipped when `.opencode/agent/` is absent);
   - `OpenCode agent frontmatter INVALID` / exit code 1 — **update failed the hard gate** (see Step 5). Do not treat the run as successful.
   - `Agent tool vocabulary OK` — the Claude Code / Kimi / Qwen gate passed (or skipped when none of those agent directories exists);
   - `Agent tool vocabulary INVALID` / exit code 1 — **update failed the hard gate** (see Step 5). Do not treat the run as successful.

4. If neither channel is available (no `git`/`pwsh`/`bash`), execute *Update / add / remove* from `AGENT-INSTALL.md` through the agent channel: re-place managed files from the updated clone, re-render `AGENTS.md`, and update `version` and `updatedAt` in `.ai-rules.json`. Do not touch `USER-RULES.md`, `memory.md`, `.dev.env`, or `LLM-RULES.md` (place the latter from the template only if absent).

   **OpenCode hard obligation on the agent channel.** When `opencode` is an active tool (or `.opencode/agent/` exists), every placed agent file **must** go through `adapters/opencode.yaml → agents.frontmatter.toolsToPermission` before write-back: convert the source `tools` array into a `permission` object, then apply `keep` / `drop` / `rename` / `addIf` so that `tools`, `modelTier`, `isSubagent`, and `allowParallel` are **not** left in the file. Copying `content/agents/*.md` into `.opencode/agent/` verbatim is a defect — OpenCode rejects a `tools` array and will not start. Canon — `AGENT-INSTALL.md → OpenCode agents: tools array → permission object`.

   **Claude Code / Kimi / Qwen hard obligation on the agent channel.** For those tools every placed agent file **must** go through `adapters/<tool>.yaml → agents.frontmatter.toolsToDenylist` before write-back: turn the source `tools` array into that host's `disallowedTools` string and emit no `tools` key. Copying `content/agents/*.md` verbatim is a defect — the abstract `Shell` / `MCP` match nothing there, and the subagent silently loses shell and every MCP server. Canon — `AGENT-INSTALL.md → Claude Code / Kimi / Qwen agents: tools array → disallowedTools`.

   **Cursor hard obligation on the agent channel.** Placed Cursor agent files **must** go through `adapters/cursor.yaml → agents.frontmatter.toolsToFlag`: emit no `tools` key (Cursor does not document the field) and set `readonly: true` on the agents whose source list grants none of `Write` / `Edit` / `Shell`. Canon — `AGENT-INSTALL.md → Cursor agents: tools array → readonly`.

5. **Mandatory post-update gates (both channels).** After the update, if `.opencode/agent/` or `.opencode/agents/` exists, verify that **no** agent markdown still has a `tools` **array** in its YAML frontmatter:

```powershell
Get-ChildItem .opencode\agent, .opencode\agents -Filter *.md -File -ErrorAction SilentlyContinue |
  ForEach-Object {
    $raw = Get-Content $_.FullName -Raw
    if ($raw -match '(?ms)\A---\r?\n.*?^tools:\s*\[') {
      "FAIL: $($_.FullName)"
    }
  }
```

   Linux equivalent (bash):

```bash
for f in .opencode/agent/*.md .opencode/agents/*.md; do
  [ -f "$f" ] || continue
  awk '/^---$/{c++} c==1 && /^tools:[[:space:]]*\[/{print "FAIL: " FILENAME}' "$f"
done
```

   - Any match → **update is incomplete / failed**. Report FAIL, list the files, and repair by re-running the PowerShell channel with `-ForcePaths .opencode/agent/*` (or re-applying `toolsToPermission` correctly on the agent channel). Do not tell the user the update succeeded.
   - Optional live check when `opencode` is on PATH: `opencode agent list` must not print `Configuration is invalid` / `Expected object | undefined, got [...] tools`.
   - If neither OpenCode agent directory exists → skip this gate.

   Then, if `.claude/agents/`, `.kimi-code/agents/`, `.qwen/agents/` or `.cursor/agents/` exists, verify that no agent markdown there still names an abstract tool:

```powershell
Get-ChildItem .claude\agents, .kimi-code\agents, .qwen\agents, .cursor\agents -Filter *.md -File -ErrorAction SilentlyContinue |
  ForEach-Object {
    if ((Get-Content $_.FullName -Raw) -match '(?m)^(tools|disallowedTools):.*\b(Shell|MCP)\b') {
      "FAIL: $($_.FullName)"
    }
  }
```

   - Any match → **update is incomplete / failed**. Report FAIL, list the files, and repair by re-running the PowerShell channel with `-ForcePaths` on the affected agents directory (or re-applying `toolsToDenylist` / `toolsToFlag` correctly on the agent channel). Do not tell the user the update succeeded, and do not "repair" it by deleting the `tools` line — that leaves the read-only agents unrestricted.
   - If none of those agent directories exists → skip this gate.

6. Recommend restarting the AI client (OpenCode in particular) so it re-reads agent definitions and MCP config.

7. **MCP-effectiveness reminder when the bundle is absent.** After a successful update, if 1C MCP tools are not exposed in the current session **and** `.dev.env` `SUPPORT_KEY` is empty **and** `.ai-rules.json` does not have `integrations.mcp.mode = "external"` — print the same reminder as after `init` (`AGENT-INSTALL.md`, section *Remind about MCP servers when the bundle is absent*; https://vibecoding1c.ru/mcp_server). Skip it when any of those signals is present. Do not open the `/installtools` menu solely for this reminder.

8. Compare the installed `install*.md` command names from the pre-update manifest with the updated ruleset. If one or more tool installers were added, show their names and execute `installtools.md` as the next procedure in the same interactive agent task. A PowerShell-only run cannot start a new AI command, so its report must tell the user to restart and run `/installtools`. The general command owns the MCP bundle question and all optional-tool choices; do not invoke `/installmcp` separately from this post-update flow. If no installer was added, do not interrupt the user with the tool menu.

## Parameters (PowerShell channel)

- `-AssumeYes` — answers "yes" to confirmations and keeps user edits (`keep`) on conflicting files. For a fully automated run (CI), add `-NonInteractive`.
- `-Force` / `-ForcePaths .opencode/agent/*` — overwrite drifted / broken OpenCode agent files with the correctly transformed shipped versions.
- `-Tools cursor,claude-code` — not needed: active tools are read from `.ai-rules.json`.
