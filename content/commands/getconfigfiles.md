---
description: Выгрузка объектов конфигурации/расширения из ИБ в файлы (Linux + 1CFilesConverter)
---

# /getconfigfiles — extract configuration objects from an infobase

Fork command (`mavlenkov/ai_rules_1c`, Linux + 1CFilesConverter). Reads all parameters from **`.dev.env`** (the single source of truth — see `.dev.env.example`).

## Settings (`.dev.env`)

Read from `.dev.env`. If a value is unknown, ask the user and write it back. If the project still has a legacy `infobasesettings.md`, migrate its values into `.dev.env` and delete the legacy file after a successful migration.

| Key | Purpose |
|---|---|
| `PLATFORM_PATH` | Platform install dir; `V8_VERSION` = `basename(PLATFORM_PATH)`, executable `{PLATFORM_PATH}/1cv8` (Linux) |
| `INFOBASE_KIND` / `INFOBASE_PATH` | Build `<ib_connection>`: `file` → `/F<path>`, `server` → `/S<path>` (no space after flag, no quotes) |
| `IB_USER` / `IB_PASSWORD` | Credentials, optional |
| `EXTENSION_NAME` | Extension name; empty = main configuration |
| `EXPORT_PATH` | Target export directory; empty = current repository root |
| `LOG_PATH` | Designer log file |
| `CONVERTER_PATH` | 1CFilesConverter path (fork Section 3); set = Mode 1, empty = Mode 2 |
| `CONVERT_TOOL` | `designer` / `ibcmd` → `V8_CONVERT_TOOL` |

## Mode selection

- `CONVERTER_PATH` set **and** path contains `scripts/conf2xml.sh` → use **Mode 1: 1CFilesConverter** (recommended for full export).
- Otherwise, or when **selective** export is needed → use **Mode 2: Designer fallback**.

**Note:** 1CFilesConverter does not support selective export (`-listFile`). For selective dumps, always use Mode 2.

---

# Mode 1: 1CFilesConverter (full export)

Use for complete configuration export when `CONVERTER_PATH` is configured.

## Prerequisites

1) `CONVERTER_PATH` set; verify `{CONVERTER_PATH}/scripts/conf2xml.sh` exists.
2) Derive `V8_VERSION` = `basename(PLATFORM_PATH)`.
3) Read `CONVERT_TOOL`, `IB_USER`, `IB_PASSWORD`, `EXTENSION_NAME` from `.dev.env`.

## Parameter mapping (`.dev.env` → converter env vars)

- `INFOBASE_KIND` + `INFOBASE_PATH` → `<ib_connection>` (`/F...` or `/S...`)
- `basename(PLATFORM_PATH)` → `V8_VERSION`
- `CONVERT_TOOL` → `V8_CONVERT_TOOL`
- `IBCMD_TOOL` → `IBCMD_TOOL` (if set)
- `IB_USER` → `V8_IB_USER`
- `IB_PASSWORD` → `V8_IB_PWD` (empty string if not set)
- `EXTENSION_NAME` → `V8_EXT_NAME` (when exporting an extension)
- `EXPORT_PATH` → target directory (empty = current repository root)
- For `CONVERT_TOOL=ibcmd` + server infobase: `DB_SRV_DBMS` → `V8_DB_SRV_DBMS`, `DB_SRV_ADDR` → `V8_DB_SRV_ADDR`, `DB_SRV_USR` → `V8_DB_SRV_USR`, `DB_SRV_PWD` → `V8_DB_SRV_PWD`; for MSSQL on Linux also `REMOTE_HOST` → `V8_REMOTE_HOST`, `REMOTE_IBCMD` → `V8_REMOTE_IBCMD`, `REMOTE_TEMP` → `V8_REMOTE_TEMP`. Omit when the corresponding `.dev.env` key is empty. See `deploy-and-test.md` → "Tool selection (ibcmd)" for when remote ibcmd is required.

## Commands

**Export configuration:**

```bash
cd <export_path>
V8_VERSION=<version> \
V8_CONVERT_TOOL=<tool> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
  <converter_path>/scripts/conf2xml.sh <ib_connection> <export_path>
```

Example:
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=designer \
V8_IB_USER=Administrator \
V8_IB_PWD="" \
  ~/Проекты/1CFilesConverter/scripts/conf2xml.sh /F/tmp/test_ib .
```

**Export extension:**

```bash
V8_VERSION=<version> \
V8_EXT_NAME=<extension_name> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
  <converter_path>/scripts/ext2xml.sh <ib_connection> <export_path>
```

Read the converter log to confirm success.

---

# Mode 2: Designer fallback (selective or full export)

Use for selective export or when 1CFilesConverter is unavailable.

## Environment detection
**IMPORTANT** Before running commands, detect the environment automatically:

1) **OS**: run `uname -s` (or check for Windows by the presence of `%PROGRAMFILES%`).
2) **Platform path**: take it from `.dev.env` `PLATFORM_PATH`; if empty, find the latest installed 1C:Enterprise version.

| OS | Platform executable | Default log path |
|----|---------------------|------------------|
| Linux | `{PLATFORM_PATH}/1cv8` (or `/opt/1cv8/x86_64/<version>/1cv8`) | `LOG_PATH` (e.g. `/tmp/1c/update.log`) |
| Windows | `{PLATFORM_PATH}\bin\1cv8.exe` (or `C:\Program Files\1cv8\<version>\bin\1cv8.exe`) | `LOG_PATH` (e.g. `%TEMP%\1c\update.log`) |

Store the result as `<V8_PATH>` and `<LOG_PATH>`.

## To get files from the infobase to modify its code or metadata, use the following commands:

Replace `<IB_CONNECTION>` with the connection string built from `INFOBASE_KIND` + `INFOBASE_PATH` (`/F...` or `/S...` — no space after the flag, no quotes).
If `IB_USER` / `IB_PASSWORD` are set, add `/N 'UserName' /P 'Password'` after `/DisableStartupMessages`. Omit `/P` if the password is empty — otherwise Designer consumes the next parameter as the password value.

**Step 1 — Dump config to files:**

File infobase:
```
<V8_PATH> DESIGNER /F/path/to/InfoBase /DisableStartupMessages /DumpConfigToFiles <export_path> -listFile repoobjects.txt /Out <LOG_PATH>
```

Server infobase:
```
<V8_PATH> DESIGNER /Sservername:port\basename /DisableStartupMessages /N UserName /DumpConfigToFiles <export_path> -listFile repoobjects.txt /Out <LOG_PATH>
```

For an extension dump add `-Extension <ExtensionName>` (`EXTENSION_NAME` from `.dev.env`):

```
<V8_PATH> DESIGNER <IB_CONNECTION> /DisableStartupMessages /N 'UserName' /P 'Password' /DumpConfigToFiles <export_path> -listFile repoobjects.txt -Extension <EXTENSION_NAME> /Out <LOG_PATH>
```

Export objects fully, strictly into `<export_path>` (`EXPORT_PATH` or the repository root) — do not create a new subdirectory.

Beforehand, put the objects to export into `repoobjects.txt`.

# Tool usage
Use **search_metadata** to obtain the lists of metadata objects required for loading into the repository.
