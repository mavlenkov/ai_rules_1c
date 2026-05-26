---
description: Load current repository files into the infobase defined in .dev.env and update the DB structure (Linux + Windows)
---

# /update1cbase — load repository into an infobase

Load the configuration (`/LoadConfigFromFiles`) from the current repository directory into the infobase defined in `.dev.env`, then update the database structure (`/UpdateDBCfg`).

This command does not run tests and does not publish the infobase. Use `/deploy-and-test` to run tests after loading.

This command is **cross-platform** (Linux-first in this fork). Platform paths, the `ibcmd` check and the command syntax differ between Linux and Windows — both are given below.

## Step 0. Check `.dev.env` parameters

`.dev.env` is the single source of truth for connection parameters (created by the 1c-rules installer at the project root). If it is missing, ask the user to run `install.ps1 init` (Windows) / `scripts/install.sh` (Linux) or copy `.dev.env.example` to `.dev.env`.

If the project still has legacy `infobasesettings.md`, migrate values to `.dev.env` (`KEY=value` format), preserving already-filled `.dev.env` keys, and delete the legacy file after successful migration. The ruleset has no other connection-settings location.

Used `.dev.env` keys:

| Key | Purpose |
|---|---|
| `PLATFORM_PATH` | Platform install dir. Executable: `{PLATFORM_PATH}/1cv8` (Linux) or `{PLATFORM_PATH}\bin\1cv8.exe` (Windows) |
| `INFOBASE_KIND` | `file` or `server` |
| `INFOBASE_PATH` | File path or server connection string |
| `IB_USER` | Infobase user; empty means no authentication |
| `IB_PASSWORD` | Password; empty means no password |
| `EXTENSION_NAME` | Extension name; empty means main configuration |
| `EXPORT_PATH` | Source directory; empty means repository root |
| `LOG_PATH` | Designer log file |
| `IBCMD_CONFIG` | Path to standalone server `config.yml` for `ibcmd`, optional |
| `CONVERTER_PATH` | 1CFilesConverter path (fork Section 3); set = converter path available |

If critical fields are empty (`INFOBASE_PATH`, `PLATFORM_PATH`), ask the user and write the values to `.dev.env`; do not guess.

Before running, make sure `{EXPORT_PATH}` contains dumped configuration sources (for example, `Configuration.xml` at the root or in the extension subdirectory). If no sources exist, stop and tell the user.

Build `<IB_CONNECTION>` from `INFOBASE_KIND` + `INFOBASE_PATH`: `file` → `/F<path>`, `server` → `/S<path>` (no space after the flag, no quotes).

## Step 1. Detect OS and choose the tool

1. **OS**: run `uname -s` (Linux/Darwin) or detect Windows by `%PROGRAMFILES%`.
2. **Tool priority**:
   - `CONVERTER_PATH` set and contains `scripts/conf2ib.sh` → **1CFilesConverter (Step 2c)** — recommended in this fork; covers extensions and DB update in one call (`V8_UPDATE_DB=1` on Linux).
   - else if `ibcmd` exists **and** `IBCMD_CONFIG` is filled → **ibcmd (Steps 2a + 3a)**.
   - else → **Designer (Steps 2b + 3b)**.

| OS | Platform executable | `ibcmd` binary | `ibcmd` existence check |
|----|---------------------|----------------|-------------------------|
| Linux | `{PLATFORM_PATH}/1cv8` | `{PLATFORM_PATH}/ibcmd` | `[ -x "{PLATFORM_PATH}/ibcmd" ]` |
| Windows | `{PLATFORM_PATH}\bin\1cv8.exe` | `{PLATFORM_PATH}\bin\ibcmd.exe` | `Test-Path '{PLATFORM_PATH}\bin\ibcmd.exe'` |

`ibcmd infobase config` does not apply to 1C cluster infobases; for server cluster infobases use Designer or 1CFilesConverter (designer tool).

## Step 2a / 3a. Load + apply through `ibcmd` (preferred when configured)

**Linux:**
```bash
# 2a: import configuration
"{PLATFORM_PATH}/ibcmd" infobase config import \
    --config='{IBCMD_CONFIG}' --user='{IB_USER}' --password='{IB_PASSWORD}' \
    --extension={EXTENSION_NAME} '{EXPORT_PATH}' 2>&1 | tee '{LOG_PATH}'
# 3a: apply to DB structure
"{PLATFORM_PATH}/ibcmd" infobase config apply \
    --config='{IBCMD_CONFIG}' --user='{IB_USER}' --password='{IB_PASSWORD}' \
    --force --dynamic=auto --session-terminate=force \
    --extension={EXTENSION_NAME} 2>&1 | tee -a '{LOG_PATH}'
```

**Windows:** same commands with `& '{PLATFORM_PATH}\bin\ibcmd.exe' …`, backtick line continuation, and `*>&1 | Tee-Object -FilePath '{LOG_PATH}'`.

Remove empty optional keys. `--session-terminate=force` forcibly terminates active sessions — use it only on a dev/test infobase. On production, use `--session-terminate=prompt` (or remove the key) and agree on an update window with the user. On a 2a error, **do not** run 3a. Continue to **Step 4**.

## Step 2b / 3b. Load + update through Designer (fallback)

Map `.dev.env` keys to Designer flags: `INFOBASE_KIND=file` → `/F<path>`, `server` → `/S<path>`; `IB_USER` → `/N 'user'`; `IB_PASSWORD` → `/P 'pwd'`; `EXTENSION_NAME` → `-Extension <name>`.

**Linux:**
```bash
# 2b: load config from files
"{PLATFORM_PATH}/1cv8" DESIGNER /F'{INFOBASE_PATH}' /N'{IB_USER}' /P'{IB_PASSWORD}' \
    /DisableStartupMessages /LoadConfigFromFiles '{EXPORT_PATH}' -Extension {EXTENSION_NAME} /Out '{LOG_PATH}'
# wait 5-10 s for the platform to release the configuration lock, then:
# 3b: update DB structure
"{PLATFORM_PATH}/1cv8" DESIGNER /F'{INFOBASE_PATH}' /N'{IB_USER}' /P'{IB_PASSWORD}' \
    /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force -Extension {EXTENSION_NAME} /Out '{LOG_PATH}'
```

**Windows:** same flags with `& '{PLATFORM_PATH}\bin\1cv8.exe' DESIGNER …` and backtick continuation.

Remove empty optional keys (`/N`, `/P`, `-Extension`). For the main configuration remove `-Extension` entirely. For a server infobase replace `/F` with `/S`. `-SessionTerminate force` — dev/test only; on production remove it and agree on a window. On a 2b error, **do not** run 3b. Designer load success: `Конфигурация успешно загружена`; DB update success: `Обновление информационной базы выполнено` / `Database configuration update completed`.

## Step 2c. Load + update through 1CFilesConverter (fork)

When `CONVERTER_PATH` is set. `V8_VERSION` = `basename(PLATFORM_PATH)`. See `deploy-and-test.md` → "Mode 1" for the full parameter mapping (including `V8_DB_SRV_*` / `V8_REMOTE_*` for ibcmd + server infobase).

**Shell quoting:** "no quotes" refers to the value passed *to 1C* (no space after `/F`/`/S`); in the shell the argument MUST be quoted, otherwise bash eats the backslash in a server string like `/Srigel:1541\Евротест`. Build it in a variable and quote every expansion (including the script path).

```bash
# main configuration (Linux, DB update in the same call)
IB_CONNECTION="/S${INFOBASE_PATH}"            # or "/F${INFOBASE_PATH}" for a file infobase
V8_VERSION=<version> V8_CONVERT_TOOL=<tool> \
V8_IB_USER='{IB_USER}' V8_IB_PWD='{IB_PASSWORD}' V8_UPDATE_DB=1 \
  "{CONVERTER_PATH}/scripts/conf2ib.sh" "{EXPORT_PATH}" "$IB_CONNECTION"
```

For an extension use `ext2ib.sh` with `V8_EXT_NAME={EXTENSION_NAME}`. Continue to **Step 4**.

## Step 4. Final report

Briefly report which infobase was updated, which directory was loaded, which tool was used (1CFilesConverter / `ibcmd` / Designer), and whether dynamic update was applied or restructuring was required (visible in the log). List errors separately.
