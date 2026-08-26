---
description: Load current repository files into the infobase defined in .dev.env and update the DB structure (Linux + Windows)
argumentHint: "[all]"
---

# /update1cbase — load repository into an infobase

Load the configuration (`/LoadConfigFromFiles`) from the current repository directory into the infobase defined in `.dev.env`, then update the database structure (`/UpdateDBCfg`). With the `all` argument (or an explicit "with extensions" request) the command loads the **full snapshot** — main configuration plus every extension from `EXTENSION_NAMES` — see "Full-snapshot mode" at the end.

This command does not run tests and does not publish the infobase. Use `/deploy-and-test` to run tests after loading.

This command is **cross-platform** (Linux-first in this fork). Platform paths, the `ibcmd` check and the command syntax differ between Linux and Windows — both are given below.

## Step 0. Check `.dev.env` parameters

`.dev.env` is the single source of truth for connection parameters (created by the 1c-rules installer at the project root). If it is missing, ask the user to run `install.ps1 init` (Windows) / `scripts/install.sh` (Linux) or copy `.dev.env.example` to `.dev.env`.

If the project still has legacy `infobasesettings.md`, migrate values to `.dev.env` (`KEY=value` format), preserving already-filled `.dev.env` keys, and delete the legacy file after successful migration. The ruleset has no other connection-settings location.

Used `.dev.env` keys:

| Key | Purpose |
|---|---|
| `PLATFORM_PATH` | Platform install dir. Executable: `{PLATFORM_PATH}/1cv8` (Linux) or `{PLATFORM_PATH}\bin\1cv8.exe` (Windows) |
| `INFOBASE_KIND` | `file` or `server` (empty = `file`) |
| `INFOBASE_PATH` | File infobase path or server connection string |
| `IB_USER` / `IB_PASSWORD` | Credentials; empty = no authentication / no password (`/N` / `/P` / `--user` / `--password` omitted). Do not ask up front; re-ask only when the platform returns an authentication error |
| `EXTENSION_NAME` | Extension name; empty means main configuration |
| `EXTENSION_NAMES` | Full-snapshot extension list for the `all` mode — comma-separated, order = load order (empty = single-target mode) |
| `EXPORT_PATH` | Source directory; empty means repository root |
| `EXTENSIONS_PATH` | Root of extension sources for the `all` mode: `{EXTENSIONS_PATH}\<Name>\` (empty = `cfe` at the repository root) |
| `LOG_PATH` | Designer log file; empty resolves to `$env:TEMP\1cv8.log` (Windows) / `$TMPDIR/1cv8.log` (POSIX). Do not ask up front — re-ask only if the resolved path turns out to be non-writable |
| `IBCMD_CONFIG` | Path to standalone server `config.yml` for `ibcmd`; empty = Designer fallback |
| `CONVERTER_PATH` | 1CFilesConverter path (fork Section 5); set = converter path available |
| `REPOSITORY_PATH` | Configuration repository address (empty = not repository-bound, no extra steps) |

**EDT gate:** when `.dev.env` `USE_EDT=true`, establish the source format before running. This command loads a **Designer XML dump**; it cannot load an EDT (`src/**/*.mdo`) tree. In an EDT-format project either produce a dump first (`export_configuration_to_xml`) or let EDT apply the change (`update_database`) — and keep **one deployment owner per run**, named in the `IB tooling:` line. Canon — `content/rules/edt-workflow.md → DB update, launches, external objects`.

**Repository gate:** when `REPOSITORY_PATH` is non-empty, the target infobase is bound to a configuration repository — the objects being loaded must be **locked in the repository first** (`1c-repository-manage` skill, process — its `docs/repo-sdlc.md`); otherwise the load fails or silently skips read-only objects. A "configuration is read-only / object locked" line in the load/update log routes to that skill, not into the retry loop below. **Never unbind** the configuration from the repository to make the load proceed.

Only `INFOBASE_PATH` and `PLATFORM_PATH` are blocking — if either is empty, ask the user and write the value to `.dev.env`. **Do not** ask about `IB_USER` / `IB_PASSWORD` / `LOG_PATH` when they are empty; apply the documented defaults silently.

When substituting `.dev.env` values into the templates below: if `LOG_PATH` is empty, replace `{LOG_PATH}` with `"$env:TEMP\1cv8.log"` (PowerShell expands the env var when the string is double-quoted).

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

**Shell quoting:** "no quotes" refers to the value passed *to 1C* (no space after `/F`/`/S`); in the shell the argument MUST be quoted, otherwise bash eats the backslash in a server string like `/Sdbsrvhost:1541\TestBase`. Build it in a variable and quote every expansion (including the script path).

```bash
# main configuration (Linux, DB update in the same call)
IB_CONNECTION="/S${INFOBASE_PATH}"            # or "/F${INFOBASE_PATH}" for a file infobase
V8_VERSION=<version> V8_CONVERT_TOOL=<tool> \
V8_IB_USER='{IB_USER}' V8_IB_PWD='{IB_PASSWORD}' V8_UPDATE_DB=1 \
  "{CONVERTER_PATH}/scripts/conf2ib.sh" "{EXPORT_PATH}" "$IB_CONNECTION"
```

For an extension use `ext2ib.sh` with `V8_EXT_NAME={EXTENSION_NAME}`. Continue to **Step 4**.

## Update retry loop — mandatory failure handling for Steps 2–3

Loading and updating rarely succeed on a dirty state at the first attempt. Handle failures **iteratively**, never by re-running the same command blindly and never by declaring success from the exit code alone.

**1. Log first — after every attempt, success or not.** Read `{LOG_PATH}` in full after each Step 2 / Step 3 run. The platform can write errors to the log while formally exiting 0 (typical: `Неверное свойство объекта метаданных`, `Неизвестное имя типа`, `Ошибка при обновлении конфигурации базы данных`, `Конфигурация не соответствует`). A diagnostic line in the log = failed attempt, regardless of exit code.

**Classify success phrases before error stems** — the platform reports success with the same words (`Ошибок не обнаружено`, `Предупреждений: 0`), so a bare "contains `Ошибка` / `Error`" test flags a clean run as broken and starts a fix loop against working code. Order and full pattern list — `content/rules/designer-batch-checks.md → The success-phrase trap`. Add **`/DumpResult '{RESULT_PATH}'`** next to `/Out` in both command lines above: it writes the batch result as a number (`0` = success) and is the cheapest of the three signals to read (same rule, *The verdict is three signals*). Delete a stale result file before the run.

**2. Terminate the Configurator before the next attempt.** A failed or hung Designer launch can stay alive and hold the configuration lock — every following attempt then dies with `База данных заблокирована` / exclusive-access errors that look like new problems but are not. For retry-aware runs launch Designer with a known process handle and a timeout:

```powershell
$p = Start-Process -FilePath '{PLATFORM_PATH}\bin\1cv8.exe' -ArgumentList $designerArgs -PassThru
if (-not $p.WaitForExit(600000)) { Stop-Process -Id $p.Id -Force }   # 10 min — raise for large configurations
```

Kill **only the PID started by this command**. Never blanket-kill `Get-Process 1cv8 | Stop-Process` — that would take down the user's own open Designer or client sessions. If the lock persists after your process is confirmed dead, the lock is foreign: report it and ask the user instead of killing anything else.

**3. Fix before retry.** Re-running against unchanged sources is forbidden (same no-change-repeat rule as for validators). Read the exact error from the log, fix its cause first — source XML/BSL defects are fixed through the `1c-metadata-manage` skill / normal code editing and re-validated (`verify_xml` / `syntaxcheck`) before the next attempt; parameter/connection errors are fixed in `.dev.env` or the command line. After a failed **load**, restart from Step 2 (load), not from Step 3 — the half-loaded state is not trustworthy; after a clean load with a failed **update**, retrying Step 3 alone is fine.

**4. Bounded budget — 3 full attempts.** If the third attempt still fails, stop: report the last log fragment, what was fixed between attempts, and the remaining error. Do not loop further and do not present a failed update as done.

## Full-snapshot mode (`/update1cbase all`) — optional

Loads the **effective snapshot**: main configuration + every extension from `EXTENSION_NAMES` (`.dev.env`, comma-separated, order = load order). Used by `/restore-testbase`, `/build-release` and whenever the user asks to deploy "with extensions".

- If `EXTENSION_NAMES` is empty, fall back to the regular single-target run above and note that in the report.
- **Pass 1 — main configuration:** Steps 2–3 as written, from `{EXPORT_PATH}`, without `-Extension` / `--extension`.
- **Pass per extension**, in `EXTENSION_NAMES` order: the same Steps 2–3 with `-Extension <Name>` / `--extension=<Name>`, sources from `{EXTENSIONS_PATH}\<Name>\` (`EXTENSIONS_PATH` empty = `cfe` at the repository root).
- **Every extension pass runs the applicability check between load and update** — `/CheckModules … -Extension <Name>` then `/CheckCanApplyConfigurationExtensions -Extension <Name>`, per `content/rules/designer-batch-checks.md → The check ladder` (verification contract: `verification-gates.md → Gate 6`). A failure stops that pass before `/UpdateDBCfg`; an interceptor whose target method the vendor renamed loads cleanly and fails only at apply time, or silently stops intercepting. This is also what `/restore-testbase` and `/build-release` inherit by calling this procedure.
- A listed extension whose sources directory is missing or empty breaks the snapshot contract — stop and ask the user (skip it or abort); never skip silently.
- The **Update retry loop** applies to every pass with its own 3-attempt budget. A pass that exhausts its budget stops the mode; report which passes completed and which failed.

## Step 4. Final report

Briefly report which infobase was updated, which directory was loaded, which tool was used (1CFilesConverter / `ibcmd` / Designer), how many attempts the retry loop took and what was fixed between them, and whether dynamic update was applied or restructuring was required (visible in the log). In full-snapshot mode, list the passes (main + each extension) with their outcomes. List errors separately.