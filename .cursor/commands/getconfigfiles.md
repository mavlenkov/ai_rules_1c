# get files from infobase

## mode selection

**Check if 1CFilesConverter is configured** in infobasesettings.md (section "1CFilesConverter").

- If **configured and path exists** → use **Mode 1: 1CFilesConverter** (recommended for full export)
- If **not configured, path invalid, or selective export needed** → use **Mode 2: Designer fallback**

**Note:** 1CFilesConverter does not support selective export (`-listFile`). For selective dumps, always use Mode 2.

---

# Mode 1: 1CFilesConverter (full export)

Use for complete configuration export when 1CFilesConverter is configured.

## Prerequisites

1) Read path to 1CFilesConverter from infobasesettings.md
2) Verify `<converter_path>/scripts/conf2xml.sh` exists
3) Extract: platform version, conversion tool, username, password

## Parameter mapping

From infobasesettings.md to environment variables:

- Infobase connection `/F '...'` or `/S '...'` → strip quotes, format as `/F...` or `/S...` (no space after flag)
- Platform version → `V8_VERSION`
- Conversion tool → `V8_CONVERT_TOOL`
- Path to ibcmd (if specified) → `IBCMD_TOOL`
- Username → `V8_IB_USER`
- Password → `V8_IB_PWD` (empty string if not set)

## Commands

**Export configuration:**

```bash
cd <project_root>
V8_VERSION=<version> \
V8_CONVERT_TOOL=<tool> \
V8_IB_USER=<user> \
V8_IB_PWD=<pwd> \
  <converter_path>/scripts/conf2xml.sh <ib_connection> <project_root>
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
  <converter_path>/scripts/ext2xml.sh <ib_connection> <project_root>
```

Read converter log to confirm success.

---

# Mode 2: Designer fallback (selective or full export)

Use for selective export or when 1CFilesConverter is unavailable.

## environment detection
**IMPORTANT** Before running commands, detect the environment automatically:

1) **OS**: run `uname -s` (or check if Windows by the presence of `%PROGRAMFILES%`).
2) **Platform path**: find the latest installed version of 1C:Enterprise.

| OS | How to detect version | Platform executable | Log path |
|----|----------------------|---------------------|----------|
| Linux | `ls /opt/1cv8/x86_64/` | `/opt/1cv8/x86_64/<version>/1cv8` | `/tmp/1c/update.log` |
| Windows | `dir "%PROGRAMFILES%\1cv8"` | `C:\Program Files\1cv8\<version>\bin\1cv8.exe` | `%TEMP%\1c\update.log` |

Use the highest available version. Store the result as `<V8_PATH>` and `<LOG_PATH>`.

## to get files from infobase to modify its code or metadata please use following commands:

Replace `<IB_CONNECTION>` with value from infobasesettings.md (`/F...` or `/S...` — no space after flag, no quotes).
If username/password are specified, add `/N 'UserName' /P 'Password'` after `/DisableStartupMessages`. Omit `/P` if password is empty — otherwise Designer will consume the next parameter as password value.

commands:

**Step 1 - Dump config to files:**

File infobase:
```
<V8_PATH> DESIGNER /F/path/to/InfoBase /DisableStartupMessages /DumpConfigToFiles /path/to/project -listFile repoobjects.txt /Out <LOG_PATH>
```

Server infobase:
```
<V8_PATH> DESIGNER /Sservername:port\basename /DisableStartupMessages /N UserName /DumpConfigToFiles /path/to/project -listFile repoobjects.txt /Out <LOG_PATH>
```

For extension dump add `-Extension <ExtensionName>`:

```
<V8_PATH> DESIGNER <IB_CONNECTION> /DisableStartupMessages /N 'UserName' /P 'Password' /DumpConfigToFiles /path/to/project -listFile repoobjects.txt -Extension ExtensionName /Out <LOG_PATH>
```

Выгружай объекты полностью. Строго в текущий каталог - не создавая нового подкаталога.

Предварительно внеси объекты к выгрузке в файл repoobjects.txt

# Использование инструментов
**search_metadata** нужно использовать для получения списков объектов метаданных необходимых для загрузки в репозиторий
