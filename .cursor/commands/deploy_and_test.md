# installation
**IMPORTANT** if file infobasesettings.md does not exist - create it with following info:
1) Ask infobase connection type and path:
   - File infobase: `/F '/path/to/InfoBase'`
   - Server infobase: `/S 'servername\basename'` (or `/S 'servername:port\basename'`)
2) Ask infobase publish URL. Example: `http://localhost/MyBase/ru/`
3) If server or authenticated infobase - ask username and password

# environment detection
**IMPORTANT** Before running commands, detect the environment automatically:

1) **OS**: run `uname -s` (or check if Windows by the presence of `%PROGRAMFILES%`).
2) **Platform path**: find the latest installed version of 1C:Enterprise.

| OS | How to detect version | Platform executable | Log path |
|----|----------------------|---------------------|----------|
| Linux | `ls /opt/1cv8/x86_64/` | `/opt/1cv8/x86_64/<version>/1cv8` | `/tmp/1c/update.log` |
| Windows | `dir "%PROGRAMFILES%\1cv8"` | `C:\Program Files\1cv8\<version>\bin\1cv8.exe` | `%TEMP%\1c\update.log` |

Use the highest available version. Store the result as `<V8_PATH>` and `<LOG_PATH>`.

# settings usage
1) In commands below replace `<V8_PATH>` with detected platform executable
2) Replace `<LOG_PATH>` with log path for detected OS
3) Replace `<IB_CONNECTION>` with infobase connection from infobasesettings.md (`/F '...'` or `/S '...'`)
4) If username/password are specified in infobasesettings.md, add `/N 'UserName' /P 'Password'` after `/DisableStartupMessages`. Omit `/P` if password is empty — otherwise Designer will consume the next parameter as password value
5) Replace test URL with URL read from infobasesettings.md. If URL not set - just skip testing
6) Replace source path with current project root directory


# testing and deployment
## to update infobase before testing use following commands:
**Step 1 - Load config to base:**

File infobase:
```
<V8_PATH> DESIGNER /F '/path/to/InfoBase' /DisableStartupMessages /LoadConfigFromFiles /path/to/project /Out <LOG_PATH>
```

Server infobase:
```
<V8_PATH> DESIGNER /S 'servername\basename' /DisableStartupMessages /N 'UserName' /P 'Password' /LoadConfigFromFiles /path/to/project /Out <LOG_PATH>
```

Read `<LOG_PATH>` to confirm success.

Wait 5-10 seconds

**Step 2 - Update database structure:**

File infobase:
```
<V8_PATH> DESIGNER /F '/path/to/InfoBase' /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <LOG_PATH>
```

Server infobase:
```
<V8_PATH> DESIGNER /S 'servername\basename' /DisableStartupMessages /N 'UserName' /P 'Password' /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <LOG_PATH>
```

Read `<LOG_PATH>` to confirm success.

## to test infobase use following URL and rules:

http://localhost/MyBase/ru/
**IMPORTANT** ALWAYS USE **human-like typing** simulation with **DELAY** to fill values during testing
you can use TAB to select form field
