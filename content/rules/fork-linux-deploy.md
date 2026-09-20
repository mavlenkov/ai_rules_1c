---
description: Fork-specific Linux deployment via 1CFilesConverter, per-client subagent model routing and Koda CLI MCP setup. Load when deploying to an infobase on Linux, editing SUBAGENT_MODEL_* routing or configuring Koda.
alwaysApply: false
category: tooling
---

# Fork extras — Linux deployment, model routing, Koda

Fork-specific (`mavlenkov/ai_rules_1c`). Upstream (`comol/ai_rules_1c`) is Windows/PowerShell-first; everything here is additive and must not weaken an upstream gate.

## Infobase deployment (Linux + 1CFilesConverter)

Commands `deploy-and-test`, `extensions`, `dataprocessors`, `getconfigfiles`, `loadfrom1cbase` and `update1cbase` read `.dev.env` Section 5 (`CONVERTER_PATH`, `CONVERT_TOOL`, `IBCMD_TOOL`, `DB_SRV_*`, `REMOTE_*`) and prefer 1CFilesConverter (`conf2ib.sh` / `ext2ib.sh`), with direct Designer as fallback. Their command files are the canonical executable procedures; never reconstruct a flow from memory.

- Linux connection strings are `/F<path>` and `/S<server:port\base>` with no space after the flag; the executable is `{PLATFORM_PATH}/1cv8`.
- Detect extensions only by `<ConfigurationExtensionPurpose>` in `Configuration.xml`; `<ConfigurationExtensionCompatibilityMode>` is not a marker.
- For MSSQL server infobases on Linux the converter may proxy `ibcmd` through the configured `REMOTE_*` SSH host.
- Load scope, applicability checks and the three-signal verdict stay owned by `content/commands/update1cbase.md` and `content/rules/designer-batch-checks.md`.

## Per-client subagent model routing

`SUBAGENT_MODEL_<TIER>__<TOOL>` overrides the bare tier for one client (`__OPENCODE`, `__CLAUDE_CODE`, `__CURSOR`, `__KILO`, `__KODA`). Claude Code / Cursor accept aliases; OpenCode / Kilo require `provider/model` and skip invalid bare names with a warning. Tier semantics remain `content/rules/subagents.md → Model-tier routing`.

## Koda CLI — MCP setup

Koda stores project settings under `.kodacli/`. Register servers with `koda mcp add <name> <url> --transport http --scope project`; after installing 1c-rules for Koda, use the generated commands in `.kodacli/mcp-setup.md`. For `1c-data-mcp`, set `INFOBASE_PUBLISH_URL` before generating or running the command.
