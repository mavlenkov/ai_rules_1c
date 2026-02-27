# extensions

Operations with 1C:Enterprise extensions (load, dump, binary packaging).

## Prerequisites

**Requires 1CFilesConverter** configured in infobasesettings.md. Read:
1) Path to 1CFilesConverter
2) Platform version, conversion tool
3) Username, password
4) Extension name

Verify `<converter_path>/scripts/ext2ib.sh` and `ext2xml.sh` exist.

---

# Load extension to infobase

Use when you need to load an extension from XML or CFE into an infobase.

## Parameter mapping

- Infobase connection → strip quotes, format as `/F...` or `/S...`
- Platform version → `V8_VERSION`
- Conversion tool → `V8_CONVERT_TOOL`
- Extension name → `V8_EXT_NAME`
- Username → `V8_IB_USER`
- Password → `V8_IB_PWD`

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

**Example:**
```bash
V8_VERSION=8.3.27.1859 \
V8_EXT_NAME=ExtensionName \
V8_IB_USER=Administrator \
V8_IB_PWD="" \
  ~/Проекты/1CFilesConverter/scripts/ext2ib.sh ./extensions/ExtensionName /F/tmp/test_ib
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
