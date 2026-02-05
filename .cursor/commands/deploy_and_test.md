# installation
**IMPORTANT** if file infobasesettings.md does not exists - create it with following info:
1) Ask connection for infobase. Example: `/home/user/1c/infobases/MyBase` (Linux) or `C:\Users\user\InfoBase` (Windows)
2) Ask infobase publish URL. In this file it http://localhost/TestForms/ru/


# setings usage
1) In commands below replace infobase connection with read from infobasesettings.md. Don't forget to use /S for server infobase and /F for file
2) replace 'http://localhost/TestForms/ru/' url to url read from infobasesettings.md. If URL not set - just skip testing
3) /tmp/1c_update.log - just put update log whereever it comfortable
4) Replace project path with current project root directory


# testing and deployment
## to update infobase before testing use following commands:
**Step 1 - Load config to base:**

```bash
/opt/1cv8/x86_64/8.3.27.1859/1cv8 DESIGNER /F '<INFOBASE_PATH>' /DisableStartupMessages /LoadConfigFromFiles <PROJECT_ROOT> /Out /tmp/1c_update.log
```

Read `/tmp/1c_update.log` to confirm success.

Wait 5-10 seconds

**Step 2 - Update database structure:**

```bash
/opt/1cv8/x86_64/8.3.27.1859/1cv8 DESIGNER /F '<INFOBASE_PATH>' /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out /tmp/1c_update.log
```

Read `/tmp/1c_update.log` to confirm success.

## to test infobase use following URL and rules:

http://localhost/TestForms/ru/
**IMPORTANT** ALWAYS USE **human-like typing** simulation with **DELAY** to fill values during testing
you can use TAB to select form field