# OpenSpec bundle — snapshot of `openspec init` output

This folder ships a per-tool snapshot of the artifacts that the official OpenSpec CLI (`@fission-ai/openspec`) generates on `openspec init`: slash commands / workflows and SKILL packages for `/opsx:propose`, `/opsx:apply`, `/opsx:archive`, `/opsx:explore`.

- One subfolder per supported tool (`cursor/`, `claude-code/`, `codex/`, `opencode/`, `kilocode/`, `kimi/`); each mirrors the exact relative paths the CLI writes into a project. The installer copies a tool's subtree during `init` / `add` / `update` — see `AGENT-INSTALL.md → Place / Shared OpenSpec scaffold`. Official layouts that differ from client contracts are remapped: Kilo `.kilocode/workflows|skills` → `.kilo/commands|skills`; Kimi `.kimi/skills` → `.kimi-code/skills`; OpenSpec 1.4 OpenCode `.opencode/commands` → `.opencode/command`.
- `version.txt` — the OpenSpec CLI version the snapshot was generated from; recorded in `.ai-rules.json` under `integrations.openspec.artifactsBundleVersion` on install.
- Codex and Kimi ship SKILLs only (no project slash commands); `qwen`, `command-code`, `cline`, `pi`, and `other` have no bundle — see `README.md → OpenSpec`.

To refresh the snapshot to a newer OpenSpec CLI version, run `tools/refresh-openspec-bundle.ps1` (maintainer machine; requires Node.js + the globally installed OpenSpec CLI) and review the diff — the script re-runs `openspec init` per tool and refreshes `version.txt` itself. Do not hand-edit the generated files — they are overwritten on the next refresh.
