---
description: Linux platform paths and 1CFilesConverter workflows; shared parameter mapping and load/check/apply safety for deployment, export and external objects
alwaysApply: false
category: tooling
---

# Linux and 1CFilesConverter — fork integration

`MCP_HOST` supplies a host default for new connections only; existing full URLs and authentication remain authoritative.

Load when `CONVERTER_PATH` is set or a deployment/export command runs on Linux. Settings come only from `.dev.env`; classification and ask policy remain in `dev-standards-env.md`. This rule supplies the OS/converter branch, not a second deployment workflow.

## Common workflow and Linux paths

First follow the calling command's source-selection, partial/full-snapshot, dirty-export, infobase-role, repository and EDT gates. Keep one deployment owner. `/deploy-and-test` retains its UI policy and final report; `/update1cbase` retains its checks, retry budget and per-target outcomes; exports retain the synchronization contract of `getconfigfiles.md`.

On Linux the executable is `{PLATFORM_PATH}/1cv8` and the standalone utility is `{PLATFORM_PATH}/ibcmd`; on Windows retain the calling command's `bin` paths. For a Designer launch pass `/F<path>` or `/S<server\base>` as one argument with no space after the flag. Quote shell expansions, including server backslashes and paths with spaces. Use the common `designer-batch-checks.md` verdict, timeout and PID-scoped cleanup. Never copy a Windows command unchanged into Bash.

Detect an extension from `Configuration.xml`'s `ConfigurationExtensionPurpose`; `ConfigurationExtensionCompatibilityMode` alone is not a marker. Apply this to the selected source directory, separately for every snapshot pass.

## Converter selection and parameter mapping

Verify the required script under `{CONVERTER_PATH}/scripts/` before selecting the converter. Missing installation or unsupported operation → use the calling command's common route. Do not install a converter or change its version as a side effect.

| `.dev.env` | Converter input |
|---|---|
| `INFOBASE_KIND` + `INFOBASE_PATH` | Connection argument: `/F<path>` or `/S<server\base>` |
| `PLATFORM_PATH` | `V8_VERSION` = basename of the platform version directory |
| `CONVERT_TOOL` | `V8_CONVERT_TOOL`; empty = `designer` |
| `IBCMD_TOOL` | `IBCMD_TOOL`; omit when empty |
| `IB_USER` / `IB_PASSWORD` | `V8_IB_USER` / `V8_IB_PWD`; empty credentials remain empty |
| `EXTENSION_NAME` | `V8_EXT_NAME`, extension operations only |
| `DB_SRV_DBMS`, `DB_SRV_ADDR`, `DB_SRV_USR`, `DB_SRV_PWD` | Matching `V8_DB_SRV_*`, when configured |
| `REMOTE_HOST`, `REMOTE_IBCMD`, `REMOTE_TEMP` | Matching `V8_REMOTE_*`, when configured |
| `BASE_IB` / `BASE_CONFIG` | `V8_BASE_IB` / `V8_BASE_CONFIG`, external-object base context |
| `EDT_VERSION` | `V8_EDT_VERSION`, EDT conversion only |

Read the installed converter's script/help to confirm this mapping and defaults before execution; do not infer features from the script name. Preserve existing credential handling and mask secrets in commands/reports; never write actual credentials into generated artifacts. Omit unset optional DB/remote variables.

For the existing converter's `ibcmd` server route on Linux, preserve its documented DBMS routing: PostgreSQL locally, MSSQL through the configured `REMOTE_*` host. Without the required remote route, stop that converter path or use Designer; never substitute the client machine for the configured DB host. The common raw `ibcmd` cluster restriction does not authorize inventing a converter route.

## Load, check, apply — separate phases

Use `conf2ib.sh <source> <connection>` for a main configuration and `ext2ib.sh <source> <connection>` with `V8_EXT_NAME` for an extension. Preserve the calling command's selected file list: if the converter cannot honor a partial load, use the common partial-load route, never a full replacement.

Before execution inspect the installed script to establish whether it can load without updating the DB (including its actual `V8_UPDATE_DB` semantics). **Do not use `V8_UPDATE_DB=1` to combine load and apply when the common workflow requires a check between them.** If separate phases are supported, load only, perform the common applicability/check ladder, then apply with the common command. Otherwise use the common deployment route for the whole pass. A successful converter exit is not a substitute for logs, batch result and the calling command's verification evidence. Preserve pre-existing extension backups and rollback.

Report the actual converter script and load/check/apply owner in `IB tooling:`. The calling command's retry budget applies; an unchanged retry is forbidden.

## Full export

Use `conf2xml.sh <connection> <destination>` or `ext2xml.sh <connection> <destination>` with `V8_EXT_NAME` for an extension. Only explicitly selected **full** exports use the converter; selective exports use `getconfigfiles.md` and its separate `repoobjects.txt` selection. Preserve the dirty-directory guard and verify log/output before editing sources. No empty selection may turn into a full export.

## Extension packaging and EDT conversion

- CFE packaging: `ext2cfe.sh <extension-XML-directory> <output.cfe>`.
- EDT conversion: `ext2edt.sh <extension-source> <EDT-destination>` with `V8_EDT_VERSION`; verify the installed EDT tooling first.
- Extension load/export uses the phases and mappings above; `/extensions` is a router into this rule and the common update/export procedures.

## External data processors and reports

Require an explicitly selected base context (`BASE_IB` or `BASE_CONFIG`) before compilation. If neither exists, ask only for the context needed by the selected operation. With the mapping above:

- Build: `dp2epf.sh <XML-source> <output-directory>`.
- Export: `dp2xml.sh <EPF-or-ERF-file> <XML-destination>`.
- EDT conversion: `dp2edt.sh <source> <EDT-destination>` with `V8_EDT_VERSION` and installed EDT tooling.

Verify the installed script's accepted inputs, then check the actual output exists and is non-empty. When no converter is installed, use a documented matching `1c-metadata-manage` operation if available; otherwise report the missing tooling. Never improvise compilation flags or silently choose another base context.
