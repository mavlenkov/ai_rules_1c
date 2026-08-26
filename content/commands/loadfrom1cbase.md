---
description: Dump the configuration from the infobase defined in .dev.env into the current repository files (Linux + Windows)
argumentHint: "[all]"
---

# /loadfrom1cbase — dump from infobase to repository

Full configuration dump (`/DumpConfigToFiles`) from the infobase defined in `.dev.env` into the current repository directory. With the `all` argument (or an explicit "with extensions" request) the command dumps the **full snapshot** — main configuration plus every extension from `EXTENSION_NAMES` — see "Full-snapshot mode" at the end.

For a partial object-by-object export, use `/getconfigfiles` (via `repoobjects.txt`).

This command is **cross-platform** (Linux-first in this fork). Platform paths, the `ibcmd` check and the command syntax differ between Linux and Windows — both are given below.

**EDT gate:** the dump this command writes is in **Designer XML format**. In a project developed in 1C:EDT (`.dev.env` `USE_EDT=true`) whose working tree is an EDT (`src/**/*.mdo`) workspace, dumping into that tree is wrong — pick a separate target directory and state that the result is a dump, not the workspace; bringing changes back into EDT is a separate, confirmed step (`content/rules/edt-workflow.md`).

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
| `EXTENSION_NAMES` | Full-snapshot extension list for the `all` mode — comma-separated, order preserved (empty = single-target mode) |
| `EXPORT_PATH` | Dump directory; empty means repository root |
| `EXTENSIONS_PATH` | Root of extension dump directories for the `all` mode: `{EXTENSIONS_PATH}\<Name>\` (empty = `cfe` at the repository root) |
| `LOG_PATH` | Designer log file; empty resolves to `$env:TEMP\1cv8.log` (Windows) / `$TMPDIR/1cv8.log` (POSIX). Do not ask up front — re-ask only if the resolved path turns out to be non-writable |
| `IBCMD_CONFIG` | Path to standalone server `config.yml` for `ibcmd`; empty = Designer fallback |
| `CONVERTER_PATH` | 1CFilesConverter path (fork Section 5); set = converter path available |

Only `INFOBASE_PATH` and `PLATFORM_PATH` are blocking — if either is empty, ask the user and write the value to `.dev.env`. **Do not** ask about `IB_USER` / `IB_PASSWORD` / `LOG_PATH` when they are empty; apply the documented defaults silently.

When substituting `.dev.env` values into the templates below: if `LOG_PATH` is empty, replace `{LOG_PATH}` with `"$env:TEMP\1cv8.log"` (PowerShell expands the env var when the string is double-quoted).

Build `<IB_CONNECTION>` from `INFOBASE_KIND` + `INFOBASE_PATH`: `file` → `/F<path>`, `server` → `/S<path>` (no space after the flag, no quotes).

## Step 1. Detect OS and choose the tool

1. **OS**: run `uname -s` (Linux/Darwin) or detect Windows by `%PROGRAMFILES%`.
2. **Tool priority**:
   - `CONVERTER_PATH` set and contains `scripts/conf2xml.sh` → **1CFilesConverter (Step 2c)** — recommended in this fork for a full dump.
   - else if `ibcmd` exists **and** `IBCMD_CONFIG` is filled → **ibcmd (Step 2a)**.
   - else → **Designer (Step 2b)**.

| OS | Platform executable | `ibcmd` binary | `ibcmd` existence check |
|----|---------------------|----------------|-------------------------|
| Linux | `{PLATFORM_PATH}/1cv8` | `{PLATFORM_PATH}/ibcmd` | `[ -x "{PLATFORM_PATH}/ibcmd" ]` |
| Windows | `{PLATFORM_PATH}\bin\1cv8.exe` | `{PLATFORM_PATH}\bin\ibcmd.exe` | `Test-Path '{PLATFORM_PATH}\bin\ibcmd.exe'` |

`ibcmd infobase config` does not apply to 1C cluster infobases; for server cluster infobases use Designer or 1CFilesConverter (designer tool).

## Step 2a. Export through `ibcmd` (preferred when configured)

**Linux:**
```bash
"{PLATFORM_PATH}/ibcmd" infobase config export \
    --config='{IBCMD_CONFIG}' \
    --user='{IB_USER}' \
    --password='{IB_PASSWORD}' \
    --extension={EXTENSION_NAME} \
    '{EXPORT_PATH}' 2>&1 | tee '{LOG_PATH}'
```

**Windows:**
```powershell
& '{PLATFORM_PATH}\bin\ibcmd.exe' infobase config export `
    --config='{IBCMD_CONFIG}' `
    --user='{IB_USER}' `
    --password='{IB_PASSWORD}' `
    --extension={EXTENSION_NAME} `
    '{EXPORT_PATH}' *>&1 | Tee-Object -FilePath '{LOG_PATH}'
```

Remove empty optional keys (`--user`, `--password`, `--extension`). For repeated exports into the same directory with a valid `ConfigDumpInfo.xml`, add `--sync` to export only changed files. Continue to **Step 3**.

## Step 2b. Export through Designer (fallback)

Map `.dev.env` keys to Designer flags: `INFOBASE_KIND=file` → `/F<path>`, `INFOBASE_KIND=server` → `/S<path>`; `IB_USER` → `/N 'user'`; `IB_PASSWORD` → `/P 'pwd'`; `EXTENSION_NAME` → `-Extension <name>`.

**Linux:**
```bash
"{PLATFORM_PATH}/1cv8" DESIGNER /F'{INFOBASE_PATH}' /N'{IB_USER}' /P'{IB_PASSWORD}' \
    /DisableStartupMessages /DumpConfigToFiles '{EXPORT_PATH}' -Extension {EXTENSION_NAME} /Out '{LOG_PATH}'
```

**Windows:**
```powershell
& '{PLATFORM_PATH}\bin\1cv8.exe' DESIGNER `
    /F '{INFOBASE_PATH}' /N '{IB_USER}' /P '{IB_PASSWORD}' `
    /DisableStartupMessages /DumpConfigToFiles '{EXPORT_PATH}' -Extension {EXTENSION_NAME} /Out '{LOG_PATH}'
```

Remove empty optional keys (`/N`, `/P`, `-Extension`). For the main configuration remove `-Extension` entirely. For a server infobase replace `/F` with `/S`. On Linux use no space after `/F`/`/S` and no surrounding quotes around the connection string itself. The export goes **strictly into the specified directory**; no extra subdirectories are created.

## Step 2c. Export through 1CFilesConverter (fork, full dump)

When `CONVERTER_PATH` is set. `V8_VERSION` = `basename(PLATFORM_PATH)`. See `getconfigfiles.md` → "Mode 1" for the full parameter mapping.

**Shell quoting:** "no quotes" refers to the value passed *to 1C* (no space after `/F`/`/S`); in the shell the argument MUST be quoted, otherwise bash eats the backslash in a server string like `/Sdbsrvhost:1541\TestBase` (→ `/Sdbsrvhost:1541TestBase`). Build it in a variable and quote every expansion. Quote the script path too (it may contain spaces).

```bash
IB_CONNECTION="/S${INFOBASE_PATH}"            # or "/F${INFOBASE_PATH}" for a file infobase
V8_VERSION=<version> V8_CONVERT_TOOL=<tool> \
V8_IB_USER='{IB_USER}' V8_IB_PWD='{IB_PASSWORD}' \
  "{CONVERTER_PATH}/scripts/conf2xml.sh" "$IB_CONNECTION" "{EXPORT_PATH}"
```

For an extension dump use `ext2xml.sh` with `V8_EXT_NAME={EXTENSION_NAME}`. Continue to **Step 3**.

## Step 3. Check result

1. Read `{LOG_PATH}`:
   - For Designer, success means `Конфигурация успешно сохранена` / `Configuration successfully saved`.
   - For `ibcmd` / converter, success means no `error` / `ошибка` lines and a zero exit code.
2. If errors exist, show the relevant log fragment to the user and stop.
3. Briefly list which top-level object directories appeared or changed according to `git status`, without content diffs.

## Full-snapshot mode (`/loadfrom1cbase all`) — optional

Dumps the **effective snapshot**: main configuration + every extension from `EXTENSION_NAMES` (`.dev.env`, comma-separated, order preserved). Used by `/initproject` and whenever the user asks for a dump "with extensions".

- If `EXTENSION_NAMES` is empty, fall back to the regular single-target run above and note that in the report.
- **Pass 1 — main configuration:** Steps 2–3 as written, into `{EXPORT_PATH}`, without `-Extension` / `--extension`.
- **Pass per extension**, in `EXTENSION_NAMES` order: the same Step 2a/2b template with `-Extension <Name>` / `--extension=<Name>`, target directory `{EXTENSIONS_PATH}\<Name>\` (`EXTENSIONS_PATH` empty = `cfe` at the repository root; create missing directories). Run the Step 3 check after **every** pass.
- The Step 0 dirty-working-tree guard covers `{EXTENSIONS_PATH}` as well as `{EXPORT_PATH}`.
- A failed pass stops the mode — do not continue to the next extension over a broken dump; report which passes completed.
