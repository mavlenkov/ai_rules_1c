---
description: Развёртывание конфигурации/расширения в ИБ и веб-тестирование (Linux, 1CFilesConverter Mode 1 / Designer Mode 2)
---

# /deploy-and-test — deploy to infobase + UI tests

Deploy the current configuration (or extension) into the infobase defined in `.dev.env`, then run UI tests in the web client at `INFOBASE_PUBLISH_URL`.

This is a fork command (`mavlenkov/ai_rules_1c`, Linux + 1CFilesConverter). It reads all parameters from **`.dev.env`** (the single source of truth — see `.dev.env.example`).

## Step 0. Settings (`.dev.env`)

`.dev.env` lives at the project root and is created by the 1c-rules installer. If it is missing, ask the user to run `install.ps1 init` / `scripts/install.sh` or to copy `.dev.env.example` to `.dev.env`.

If the project still has a legacy `infobasesettings.md`, migrate its values into `.dev.env` (Section 2 + the fork Section 3), preserving already-filled `.dev.env` keys, and delete the legacy file after a successful migration. There is no other location for connection settings.

Read from `.dev.env`:

| Key | Purpose |
|---|---|
| `PLATFORM_PATH` | Platform install dir. `V8_VERSION` = `basename(PLATFORM_PATH)`; the executable is `{PLATFORM_PATH}/1cv8` (Linux) or `{PLATFORM_PATH}\bin\1cv8.exe` (Windows) |
| `INFOBASE_KIND` | `file` or `server` (empty = `file`) |
| `INFOBASE_PATH` | File path or server connection string (see "Connection string" below) |
| `IB_USER` / `IB_PASSWORD` | Credentials, optional |
| `EXTENSION_NAME` | Extension name; empty = main configuration |
| `LOG_PATH` | Designer / converter log file |
| `INFOBASE_PUBLISH_URL` | Web-publish URL for UI tests; empty = skip UI tests |
| **fork Section 3** | `CONVERTER_PATH`, `CONVERT_TOOL`, `IBCMD_TOOL`, `DB_SRV_*`, `REMOTE_*` — see `.dev.env.example` |

Critical deploy fields: `INFOBASE_PATH`, `PLATFORM_PATH`, `LOG_PATH`. If empty, ask the user and write the values back to `.dev.env`. If the project requires 1CFilesConverter (Mode 1), `CONVERTER_PATH` is also critical.

## Connection string (`<IB_CONNECTION>`)

Build it from `INFOBASE_KIND` + `INFOBASE_PATH`:

- `file` → `/F<INFOBASE_PATH>` (no space after `/F`, no quotes)
- `server` → `/S<INFOBASE_PATH>` (e.g. `/Sserver:port\basename` — no space after `/S`, no quotes)

**WARNING:** A space after `/F` or `/S` produces an invalid connection string. Designer exits with code 0 but fails silently.

## Extension detection

**Before loading**, check whether this project is a configuration extension:

1. Look for `Configuration.xml` in the project root.
2. If it contains `<ConfigurationExtensionPurpose>` → this is an **extension** (NOTE: `<ConfigurationExtensionCompatibilityMode>` is NOT a reliable marker — it exists in all configurations).
3. Take the extension name from the `<Name>` element of `Configuration.xml`, or from `.dev.env` `EXTENSION_NAME`.
4. **Notify the user**: "This project is a configuration extension. Extension name: `<ExtName>`. Loading will use `ext2ib.sh` / `-Extension`. Please confirm."
5. **Wait for confirmation** before proceeding. After confirmation, use extension mode automatically.

If the user declines auto-detection, ask for a manual choice (configuration / extension + name).

## Mode selection

- `CONVERTER_PATH` is set **and** the path contains `scripts/conf2ib.sh` → use **Mode 1: 1CFilesConverter** (recommended).
- Otherwise → use **Mode 2: Designer fallback**.

---

# Mode 1: 1CFilesConverter (recommended)

Use when `CONVERTER_PATH` is configured in `.dev.env`.

## Prerequisites

1) `CONVERTER_PATH` set; verify `{CONVERTER_PATH}/scripts/conf2ib.sh` exists.
2) Derive `V8_VERSION` = `basename(PLATFORM_PATH)`.
3) Read `CONVERT_TOOL` (designer/ibcmd), `IB_USER`, `IB_PASSWORD` from `.dev.env`.
4) Detect OS (for `V8_UPDATE_DB` handling on Windows).

## Parameter mapping (`.dev.env` → converter env vars)

- `INFOBASE_KIND` + `INFOBASE_PATH` → `<ib_connection>` (`/F...` or `/S...`, see above)
- `basename(PLATFORM_PATH)` → `V8_VERSION`
- `CONVERT_TOOL` → `V8_CONVERT_TOOL`
- `IBCMD_TOOL` → `IBCMD_TOOL` (overrides default `/opt/1cv8/x86_64/<version>/ibcmd`)
- `IB_USER` → `V8_IB_USER`
- `IB_PASSWORD` → `V8_IB_PWD` (empty string if not set)
- `EXTENSION_NAME` → `V8_EXT_NAME` (when deploying an extension)
- `DB_SRV_ADDR` → `V8_DB_SRV_ADDR` (named MSSQL instances like `RIGEL\SQL2019`)
- `DB_SRV_DBMS` → `V8_DB_SRV_DBMS` (`MSSQLServer` or `PostgreSQL`, for ibcmd + server infobase)
- `DB_SRV_USR` → `V8_DB_SRV_USR`
- `DB_SRV_PWD` → `V8_DB_SRV_PWD`
- `REMOTE_HOST` → `V8_REMOTE_HOST` (SSH host with ibcmd, for MSSQL on Linux)
- `REMOTE_IBCMD` → `V8_REMOTE_IBCMD` (default `C:\Program Files\1cv8\<version>\bin\ibcmd.exe`)
- `REMOTE_TEMP` → `V8_REMOTE_TEMP` (default `C:\Temp\1c_conv`)

## Tool selection (ibcmd)

When `CONVERT_TOOL=ibcmd` and server infobase:

```
OS = Windows → ibcmd locally (any DBMS)
OS = Linux + DBMS = PostgreSQL → ibcmd locally
OS = Linux + DBMS = MSSQLServer:
  REMOTE_HOST set → ibcmd via SSH (remote)
  REMOTE_HOST not set → ERROR (ibcmd on Linux does not support MSSQL)
File infobase → ibcmd locally (any OS)
CONVERT_TOOL=designer → works via cluster, DBMS irrelevant, always local
```

Omit `IBCMD_TOOL` if empty (defaults to `/opt/1cv8/x86_64/<version>/ibcmd`).
Omit `V8_DB_SRV_*` and `V8_REMOTE_*` variables when the corresponding `.dev.env` keys are empty.

## Commands

**If the project is an extension** (detected above), use `ext2ib.sh` instead of `conf2ib.sh`:

```bash
cd <project_root>
V8_VERSION=<version> \
V8_CONVERT_TOOL=<tool> \
IBCMD_TOOL=<ibcmd_path> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
V8_EXT_NAME=<extension_name> \
  <converter_path>/scripts/ext2ib.sh <project_root> <ib_connection> <extension_name>
```

**Otherwise (main configuration):**

**Linux (with automatic DB update):**

```bash
cd <project_root>
V8_VERSION=<version> \
V8_CONVERT_TOOL=<tool> \
IBCMD_TOOL=<ibcmd_path> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
V8_UPDATE_DB=1 \
  <converter_path>/scripts/conf2ib.sh <project_root> <ib_connection>
```

Example (file infobase — `INFOBASE_KIND=file`, `INFOBASE_PATH=/tmp/test_ib`):
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=designer \
V8_IB_USER=Administrator \
V8_IB_PWD="" \
V8_UPDATE_DB=1 \
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . /F/tmp/test_ib
```

Example (server infobase, designer — `INFOBASE_KIND=server`, `INFOBASE_PATH=rigel:1541\Евротест`):
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=designer \
V8_IB_USER=Администратор \
V8_IB_PWD="" \
V8_UPDATE_DB=1 \
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . '/Srigel:1541\Евротест'
```

Example (server infobase, ibcmd, MSSQL on Linux via remote SSH):
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=ibcmd \
V8_REMOTE_HOST=rigel \
V8_DB_SRV_DBMS=MSSQLServer \
V8_DB_SRV_ADDR='RIGEL\SQL2019' \
V8_DB_SRV_USR=sa \
V8_DB_SRV_PWD=secretpwd \
V8_UPDATE_DB=1 \
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . '/Srigel/TEST_CONV'
```

Example (server infobase, ibcmd, PostgreSQL on Linux — local):
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=ibcmd \
IBCMD_TOOL=~/.local/bin/ibcmd \
V8_DB_SRV_DBMS=PostgreSQL \
V8_IB_USER=Администратор \
V8_IB_PWD="" \
V8_UPDATE_DB=1 \
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . '/Srigel:1541\Евротест'
```

**Windows (separate DB update):**

```bash
# Step 1: Load configuration
V8_VERSION=<version> \
V8_CONVERT_TOOL=<tool> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
  <converter_path>/scripts/conf2ib.sh <project_root> <ib_connection>

# Step 2: Update DB (use Designer directly)
<V8_PATH> DESIGNER <ib_connection> /DisableStartupMessages /N <user> /P <pwd> /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <LOG_PATH>
```

Read the converter log at `<converter_path>/tmp/v8_designer_output.log` (or the `$V8_TEMP` location) to confirm success.

**Wait 5-10 seconds** between configuration load and testing.

---

# Mode 2: Designer fallback

Use when `CONVERTER_PATH` is empty or invalid.

## Environment detection
**IMPORTANT** Before running commands, detect the environment automatically:

1) **OS**: run `uname -s` (or check for Windows by the presence of `%PROGRAMFILES%`).
2) **Platform path**: take it from `.dev.env` `PLATFORM_PATH`; if empty, find the latest installed 1C:Enterprise version.

| OS | Platform executable | Default log path |
|----|---------------------|------------------|
| Linux | `{PLATFORM_PATH}/1cv8` (or `/opt/1cv8/x86_64/<version>/1cv8`) | `LOG_PATH` (e.g. `/tmp/1c/update.log`) |
| Windows | `{PLATFORM_PATH}\bin\1cv8.exe` (or `C:\Program Files\1cv8\<version>\bin\1cv8.exe`) | `LOG_PATH` (e.g. `%TEMP%\1c\update.log`) |

Store the result as `<V8_PATH>` and `<LOG_PATH>`.

## Settings usage
1) Replace `<V8_PATH>` with the detected platform executable.
2) Replace `<LOG_PATH>` with `.dev.env` `LOG_PATH`.
3) Replace `<IB_CONNECTION>` with the connection string built from `INFOBASE_KIND` + `INFOBASE_PATH` (`/F...` or `/S...` — no space after the flag, no quotes).
4) If `IB_USER` / `IB_PASSWORD` are set, add `/N 'UserName' /P 'Password'` after `/DisableStartupMessages`. Omit `/P` if the password is empty — otherwise Designer consumes the next parameter as the password value.
5) Replace the test URL with `.dev.env` `INFOBASE_PUBLISH_URL`. If empty — skip testing.
6) Replace the source path with the current project root (or `.dev.env` `EXPORT_PATH` if set).

## Testing and deployment

**If the project is an extension**, add `-Extension <ExtName>` to the `LoadConfigFromFiles` and `UpdateDBCfg` commands below.

### Step 1 — Load config to base:

File infobase:
```
<V8_PATH> DESIGNER /F/path/to/InfoBase /DisableStartupMessages /LoadConfigFromFiles /path/to/project /Out <LOG_PATH>
```

Server infobase (option A — short format):
```
<V8_PATH> DESIGNER /Sservername:port\basename /DisableStartupMessages /N UserName /LoadConfigFromFiles /path/to/project /Out <LOG_PATH>
```

Server infobase (option B — explicit connection string, recommended):
```
<V8_PATH> DESIGNER /IBConnectionString 'Srvr="servername";Ref="basename";' /DisableStartupMessages /N UserName /LoadConfigFromFiles /path/to/project /Out <LOG_PATH>
```

Read `<LOG_PATH>` to confirm success.

### Step 2 — Update DB structure:

File infobase:
```
<V8_PATH> DESIGNER /F/path/to/InfoBase /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <LOG_PATH>
```

Server infobase (option A — short format):
```
<V8_PATH> DESIGNER /Sservername:port\basename /DisableStartupMessages /N UserName /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <LOG_PATH>
```

Server infobase (option B — explicit connection string, recommended):
```
<V8_PATH> DESIGNER /IBConnectionString 'Srvr="servername";Ref="basename";' /DisableStartupMessages /N UserName /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <LOG_PATH>
```

Read `<LOG_PATH>` to confirm success.

---

# Diagnostics

## Common issues after deployment

| Log message | Meaning | Action |
|-------------|---------|--------|
| `Неопределена информационная база` | **Connection error** — invalid `/S` or `/F` format (likely a space after the flag or wrong server name) | Fix the connection string. No space after `/S` or `/F`. Check `INFOBASE_KIND` / `INFOBASE_PATH` in `.dev.env`. |
| `Загрузка не должна менять принадлежность` | **Normal warning** for extensions — not an error | Ignore. Expected when loading extension XML. |
| `Database configuration updated successfully` but no actual changes | Designer exited with code 0 but did nothing | Check the log for `Неопределена информационная база` — this is a silent failure. |

## Important notes

- **Exit code 0 does not guarantee success.** Designer may exit cleanly even when the operation failed. Always read the log file.
- **1CFilesConverter logs are deleted** after script execution (temp directory cleaned up). For debugging, run with `bash -x` to see the full command trace and log contents.
- **For extensions:** if you loaded XML without `-Extension <name>`, the code went into the main configuration, not the extension. The extension in the infobase remains unchanged.
- **On any deploy error, do NOT run UI tests** — fix the deploy first.

---

# Testing

## To test the infobase use the following URL and rules:

Use `.dev.env` `INFOBASE_PUBLISH_URL` (e.g. `http://localhost/MyBase/ru/`). If empty, skip this step and finish with: "UI tests skipped: `INFOBASE_PUBLISH_URL` is not set in `.dev.env`."

Otherwise open the URL through the MCP browser and run the test scenarios. Rules:

- **IMPORTANT** ALWAYS USE **human-like typing** simulation with **DELAY** to fill values during testing.
- Use TAB to move between form fields.
- Wait for elements to load before interacting.
- Take screenshots at key steps for documentation.

## Final report

Briefly report which infobase was updated, which mode/tool was used (1CFilesConverter Mode 1 — designer/ibcmd, or Designer Mode 2), which test scenarios passed/failed, and list errors separately with log fragments and screenshots.
