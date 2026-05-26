---
description: Операции с расширениями 1С: загрузка, выгрузка, сборка CFE (Linux + 1CFilesConverter)
---

# extensions

Operations with 1C:Enterprise extensions (load, dump, binary packaging).

Fork command (`mavlenkov/ai_rules_1c`, Linux + 1CFilesConverter). Reads all parameters from **`.dev.env`** (the single source of truth — see `.dev.env.example`). If the project still has a legacy `infobasesettings.md`, migrate its values into `.dev.env` and delete the legacy file after a successful migration.

## Prerequisites

**Requires 1CFilesConverter** (`CONVERTER_PATH` in `.dev.env`, fork Section 3). Read from `.dev.env`:
1) `CONVERTER_PATH` — path to 1CFilesConverter
2) `PLATFORM_PATH` (`V8_VERSION` = `basename(PLATFORM_PATH)`), `CONVERT_TOOL`
3) `IB_USER`, `IB_PASSWORD`
4) `EXTENSION_NAME`

Verify `{CONVERTER_PATH}/scripts/ext2ib.sh` and `ext2xml.sh` exist.

---

# Load extension to infobase

Use when you need to load an extension from XML or CFE into an infobase.

## Parameter mapping (`.dev.env` → converter env vars)

- `INFOBASE_KIND` + `INFOBASE_PATH` → `<ib_connection>` (`file` → `/F...`, `server` → `/S...`, no space after flag, no quotes)
- `basename(PLATFORM_PATH)` → `V8_VERSION`
- `CONVERT_TOOL` → `V8_CONVERT_TOOL`
- `IBCMD_TOOL` (if set) → `IBCMD_TOOL`
- `EXTENSION_NAME` → `V8_EXT_NAME`
- `IB_USER` → `V8_IB_USER`
- `IB_PASSWORD` → `V8_IB_PWD`
- `DB_SRV_ADDR` → `V8_DB_SRV_ADDR` (named MSSQL instances)
- `DB_SRV_DBMS` → `V8_DB_SRV_DBMS` (ibcmd + server infobase)
- `DB_SRV_USR` → `V8_DB_SRV_USR` (ibcmd + server infobase)
- `DB_SRV_PWD` → `V8_DB_SRV_PWD` (ibcmd + server infobase)
- `REMOTE_HOST` → `V8_REMOTE_HOST` (for MSSQL on Linux)
- `REMOTE_IBCMD` → `V8_REMOTE_IBCMD` (remote ibcmd.exe path)
- `REMOTE_TEMP` → `V8_REMOTE_TEMP` (remote temp dir)

Omit `V8_DB_SRV_*` and `V8_REMOTE_*` when the corresponding `.dev.env` keys are empty.
See `deploy-and-test.md` → "Tool selection (ibcmd)" for when remote ibcmd is needed.

## Command

```bash
V8_VERSION=<version> \
V8_CONVERT_TOOL=<tool> \
V8_EXT_NAME=<extension_name> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
  <converter_path>/scripts/ext2ib.sh <extension_source> <ib_connection>
```

**Parameters:**
- `<extension_source>` — path to XML folder or CFE file
- `<ib_connection>` — `/F<path>` or `/Sserver\basename`

**Example (file infobase):**
```bash
V8_VERSION=8.3.27.1859 \
V8_EXT_NAME=ExtensionName \
V8_IB_USER=Administrator \
V8_IB_PWD="" \
  ~/Проекты/1CFilesConverter/scripts/ext2ib.sh ./extensions/ExtensionName /F/tmp/test_ib
```

**Example (server infobase, MSSQL on Linux via remote SSH):**
```bash
V8_VERSION=8.3.27.1859 \
V8_CONVERT_TOOL=ibcmd \
V8_EXT_NAME=МоёРасширение \
V8_REMOTE_HOST=rigel \
V8_DB_SRV_DBMS=MSSQLServer \
V8_DB_SRV_ADDR='RIGEL\SQL2019' \
V8_DB_SRV_USR=sa \
V8_DB_SRV_PWD=secretpwd \
  ~/Проекты/1CFilesConverter/scripts/ext2ib.sh . /Srigel/TEST_CONV МоёРасширение
```

## Fallback (without 1CFilesConverter)

If 1CFilesConverter is not configured, manual loading via Designer:

1. Open Designer (`/F` or `/S` connection)
2. Menu: Configuration → Extensions → Add extension from file
3. Select CFE file or load from XML manually

**Note:** Designer does not support batch extension loading from command line.

---

# Dump extension from infobase

Export extension from infobase to XML format.

## Command

```bash
V8_VERSION=<version> \
V8_EXT_NAME=<extension_name> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
  <converter_path>/scripts/ext2xml.sh <ib_connection> <dest_path>
```

**Example:**
```bash
V8_VERSION=8.3.27.1859 \
V8_EXT_NAME=ExtensionName \
V8_IB_USER=Administrator \
V8_IB_PWD="" \
  ~/Проекты/1CFilesConverter/scripts/ext2xml.sh /F/tmp/test_ib ./extensions/ExtensionName
```

## Fallback (without 1CFilesConverter)

Use Designer `DumpConfigToFiles` with `-Extension`:

```bash
<V8_PATH> DESIGNER <IB_CONNECTION> /DisableStartupMessages /N <user> /P <pwd> \
  /DumpConfigToFiles <dest_path> -Extension <extension_name> /Out <LOG_PATH>
```

---

# Build CFE binary

Package extension XML to CFE binary format (for distribution or installation).

## Command

```bash
<converter_path>/scripts/ext2cfe.sh <extension_xml_path> <output_cfe>
```

**Example:**
```bash
~/Проекты/1CFilesConverter/scripts/ext2cfe.sh ./extensions/ExtensionName ./dist/ExtensionName.cfe
```

**Note:** No fallback — requires 1CFilesConverter.

---

# Convert extension to EDT

Convert extension to 1C:EDT project format.

Mapping: `.dev.env` `EDT_VERSION` → `V8_EDT_VERSION`.

## Command

```bash
V8_EDT_VERSION=<edt_version> \
  <converter_path>/scripts/ext2edt.sh <extension_source> <edt_project_path>
```

**Parameters:**
- `<extension_source>` — XML folder, CFE file, or infobase with extension
- `<edt_project_path>` — destination folder for EDT project

**Note:** No fallback — requires 1CFilesConverter and 1C:EDT tools (ring or edtcli).

---

# Best practices

1. **Always specify extension name** via `V8_EXT_NAME` — required for all operations
2. **Validate extension name** with `search_metadata` before operations
3. **For base + extension workflow:**
   - Set `V8_BASE_IB` to point to infobase with base configuration
   - Or set `V8_BASE_CONFIG` to CF file path
4. **Check converter logs** at `<converter_path>/tmp/v8_designer_output.log`
5. **Version control:** Store extensions as XML, build CFE for distribution
