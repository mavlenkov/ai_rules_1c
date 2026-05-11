---
description: Развёртывание конфигурации в ИБ и веб-тестирование (Linux, 1CFilesConverter Mode 1 / Designer Mode 2)
---

# installation
**IMPORTANT** if file infobasesettings.md does not exist - create it with following info:
1) Ask infobase connection type and path:
   - File infobase: `/F/path/to/InfoBase` (no space after `/F`, no quotes)
   - Server infobase: `/Sservername\basename` (or `/Sservername:port\basename`) — no space after `/S`, no quotes
   - **WARNING**: A space after `/S` or `/F` will produce an invalid connection string. Designer will exit with code 0 but fail silently.
2) Ask infobase publish URL. Example: `http://localhost/MyBase/ru/`
3) If server or authenticated infobase - ask username and password
4) Optionally ask about 1CFilesConverter installation (path, platform version, conversion tool)
5) If server infobase with MSSQL on Linux — ask about remote ibcmd host and DB server address

# extension detection

**Before loading**, check if this project is a configuration extension:

1. Look for `Configuration.xml` in project root
2. If it contains `ConfigurationExtensionPurpose` → this is an **extension** (NOTE: `ConfigurationExtensionCompatibilityMode` is NOT a reliable marker — it exists in all configurations)
3. Extract extension name from `<Name>` element in `Configuration.xml`, or from `infobasesettings.md` section "Расширение"
4. **Notify the user**: "This project is a configuration extension. Extension name: `<ExtName>`. Loading will use ext2ib.sh / -Extension. Please confirm."
5. **Wait for confirmation** before proceeding. After confirmation, use extension mode automatically.

If user declines auto-detection, ask for manual choice (configuration / extension + name).

# mode selection

**Check if 1CFilesConverter is configured** in infobasesettings.md (section "1CFilesConverter").

- If **configured and path exists** → use **Mode 1: 1CFilesConverter** (recommended)
- If **not configured or path invalid** → use **Mode 2: Designer fallback**

---

# Mode 1: 1CFilesConverter (recommended)

Use this mode when 1CFilesConverter is configured in infobasesettings.md.

## Prerequisites

1) Read path to 1CFilesConverter from infobasesettings.md
2) Verify `<converter_path>/scripts/conf2ib.sh` exists
3) Extract: platform version, conversion tool (designer/ibcmd), username, password
4) Detect OS (for `V8_UPDATE_DB` handling on Windows)

## Parameter mapping

From infobasesettings.md to environment variables:

- Infobase connection `/F '...'` or `/S '...'` → strip quotes, format as `/F...` or `/S...` (no space after flag)
- Platform version → `V8_VERSION`
- Conversion tool → `V8_CONVERT_TOOL`
- Path to ibcmd (if specified) → `IBCMD_TOOL` (overrides default `/opt/1cv8/x86_64/<version>/ibcmd`)
- Username → `V8_IB_USER`
- Password → `V8_IB_PWD` (empty string if not set)
- DB server address (if specified) → `V8_DB_SRV_ADDR` (for named MSSQL instances like `RIGEL\SQL2019`)
- DB server DBMS type → `V8_DB_SRV_DBMS` (`MSSQLServer` or `PostgreSQL`, for ibcmd + server infobase)
- DB server user → `V8_DB_SRV_USR` (for ibcmd + server infobase)
- DB server password → `V8_DB_SRV_PWD` (for ibcmd + server infobase)
- Remote ibcmd host (if specified) → `V8_REMOTE_HOST` (SSH host with ibcmd, for MSSQL on Linux)
- Remote ibcmd path (if specified) → `V8_REMOTE_IBCMD` (default: `C:\Program Files\1cv8\<version>\bin\ibcmd.exe`)
- Remote temp dir (if specified) → `V8_REMOTE_TEMP` (default: `C:\Temp\1c_conv`)

## Tool selection (ibcmd)

When `V8_CONVERT_TOOL=ibcmd` and server infobase:

```
OS = Windows → ibcmd locally (any DBMS)
OS = Linux + DBMS = PostgreSQL → ibcmd locally
OS = Linux + DBMS = MSSQLServer:
  V8_REMOTE_HOST set → ibcmd via SSH (remote)
  V8_REMOTE_HOST not set → ERROR (ibcmd on Linux does not support MSSQL)
File infobase → ibcmd locally (any OS)
V8_CONVERT_TOOL=designer → works via cluster, DBMS irrelevant, always local
```

Omit `IBCMD_TOOL` if not specified in infobasesettings.md (defaults to `/opt/1cv8/x86_64/<version>/ibcmd`).
Omit `V8_DB_SRV_*` and `V8_REMOTE_*` variables if not specified in infobasesettings.md.

## Commands

**If project is an extension** (detected in extension detection step), use `ext2ib.sh` instead of `conf2ib.sh`:

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

Example (file infobase):
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=designer \
V8_IB_USER=Administrator \
V8_IB_PWD="" \
V8_UPDATE_DB=1 \
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . /F/tmp/test_ib
```

Example (server infobase, designer):
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=designer \
V8_IB_USER=Администратор \
V8_IB_PWD="" \
V8_UPDATE_DB=1 \
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . /Srigel:1541\Евротест
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
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . /Srigel/TEST_CONV
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
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . /Srigel:1541\Евротест
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

Read converter log at `<converter_path>/tmp/v8_designer_output.log` (or `$V8_TEMP` location) to confirm success.

**Wait 5-10 seconds** between configuration load and testing.

---

# Mode 2: Designer fallback

Use when 1CFilesConverter is not configured or unavailable.

## environment detection
**IMPORTANT** Before running commands, detect the environment automatically:

1) **OS**: run `uname -s` (or check if Windows by the presence of `%PROGRAMFILES%`).
2) **Platform path**: find the latest installed version of 1C:Enterprise.

| OS | How to detect version | Platform executable | Log path |
|----|----------------------|---------------------|----------|
| Linux | `ls /opt/1cv8/x86_64/` | `/opt/1cv8/x86_64/<version>/1cv8` | `/tmp/1c/update.log` |
| Windows | `dir "%PROGRAMFILES%\1cv8"` | `C:\Program Files\1cv8\<version>\bin\1cv8.exe` | `%TEMP%\1c\update.log` |

Use the highest available version. Store the result as `<V8_PATH>` and `<LOG_PATH>`.

## settings usage
1) In commands below replace `<V8_PATH>` with detected platform executable
2) Replace `<LOG_PATH>` with log path for detected OS
3) Replace `<IB_CONNECTION>` with infobase connection from infobasesettings.md (`/F...` or `/S...` — no space after flag, no quotes)
4) If username/password are specified in infobasesettings.md, add `/N 'UserName' /P 'Password'` after `/DisableStartupMessages`. Omit `/P` if password is empty — otherwise Designer will consume the next parameter as password value
5) Replace test URL with URL read from infobasesettings.md. If URL not set - just skip testing
6) Replace source path with current project root directory


## testing and deployment

**If project is an extension**, add `-Extension <ExtName>` to `LoadConfigFromFiles` and `UpdateDBCfg` commands below.

### to update infobase before testing use following commands:
**Step 1 - Load config to base:**

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

Wait 5-10 seconds

**Step 2 - Update database structure:**

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

# diagnostics

## Common issues after deployment

| Log message | Meaning | Action |
|-------------|---------|--------|
| `Неопределена информационная база` | **Connection error** — invalid `/S` or `/F` format (likely a space after flag or wrong server name) | Fix connection string in infobasesettings.md. No space after `/S` or `/F`. |
| `Загрузка не должна менять принадлежность` | **Normal warning** for extensions — not an error | Ignore. This is expected when loading extension XML. |
| `Database configuration updated successfully` but no actual changes | Designer exited with code 0 but did nothing | Check log for `Неопределена информационная база` — this is a silent failure. |

## Important notes

- **Exit code 0 does not guarantee success.** Designer may exit cleanly even when the operation failed. Always read the log file.
- **1CFilesConverter logs are deleted** after script execution (temp directory cleaned up). For debugging, run with `bash -x` to see the full command trace and log contents.
- **For extensions:** if you loaded XML without `-Extension <name>`, the code went into the main configuration, not the extension. The extension in the infobase remains unchanged.

---

# testing

## to test infobase use following URL and rules:

http://localhost/MyBase/ru/
**IMPORTANT** ALWAYS USE **human-like typing** simulation with **DELAY** to fill values during testing
you can use TAB to select form field
