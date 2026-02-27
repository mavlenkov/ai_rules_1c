# get files from infobase

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

Replace `<IB_CONNECTION>` with value from infobasesettings.md (`/F '...'` or `/S '...'`).
If username/password are specified, add `/N 'UserName' /P 'Password'` after `/DisableStartupMessages`. Omit `/P` if password is empty — otherwise Designer will consume the next parameter as password value.

commands:

**Step 1 - Dump config to files:**

File infobase:
```
<V8_PATH> DESIGNER /F '/path/to/InfoBase' /DisableStartupMessages /DumpConfigToFiles /path/to/project -listFile repoobjects.txt /Out <LOG_PATH>
```

Server infobase:
```
<V8_PATH> DESIGNER /S 'servername\basename' /DisableStartupMessages /N 'UserName' /P 'Password' /DumpConfigToFiles /path/to/project -listFile repoobjects.txt /Out <LOG_PATH>
```

For extension dump add `-Extension <ExtensionName>`:

```
<V8_PATH> DESIGNER <IB_CONNECTION> /DisableStartupMessages /N 'UserName' /P 'Password' /DumpConfigToFiles /path/to/project -listFile repoobjects.txt -Extension ExtensionName /Out <LOG_PATH>
```

Выгружай объекты полностью. Строго в текущий каталог - не создавая нового подкаталога.

Предварительно внеси объекты к выгрузке в файл repoobjects.txt

# Использование инструментов
**search_metadata** нужно использовать для получения списков объектов метаданных необходимых для загрузки в репозиторий
