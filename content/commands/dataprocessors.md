---
description: Операции с внешними обработками и отчётами EPF/ERF (Linux + 1CFilesConverter)
---

# dataprocessors

Operations with external data processors and reports (EPF/ERF files).

Fork command (`mavlenkov/ai_rules_1c`, Linux + 1CFilesConverter). Reads all parameters from **`.dev.env`** (the single source of truth — see `.dev.env.example`). If the project still has a legacy `infobasesettings.md`, migrate its values into `.dev.env` and delete the legacy file after a successful migration.

## Prerequisites

**Requires 1CFilesConverter** (`CONVERTER_PATH` in `.dev.env`, fork Section 3). Read from `.dev.env`:
1) `CONVERTER_PATH` — path to 1CFilesConverter
2) `PLATFORM_PATH` (`V8_VERSION` = `basename(PLATFORM_PATH)`)
3) `BASE_IB` or `BASE_CONFIG` — base infobase or base configuration path

Verify `{CONVERTER_PATH}/scripts/dp2epf.sh` and `dp2xml.sh` exist.

**Important:** External data processors/reports require a base configuration context for correct compilation.

---

# Build EPF/ERF binary

Compile external data processor or report from XML to binary format (EPF/ERF).

## Prerequisites

You must specify **either**:
- `V8_BASE_IB` — path to infobase with base configuration (e.g., `/F/tmp/base_ib`)
- `V8_BASE_CONFIG` — path to CF file with base configuration (e.g., `/path/to/base.cf`)

## Parameter mapping (`.dev.env` → converter env vars)

- `basename(PLATFORM_PATH)` → `V8_VERSION`
- `BASE_IB` → `V8_BASE_IB`
- `BASE_CONFIG` → `V8_BASE_CONFIG`

## Command

```bash
V8_VERSION=<version> \
V8_BASE_IB=<base_ib_path> \
  <converter_path>/scripts/dp2epf.sh <dp_xml_path> <output_folder>
```

Or with base configuration:

```bash
V8_VERSION=<version> \
V8_BASE_CONFIG=<base_cf_path> \
  <converter_path>/scripts/dp2epf.sh <dp_xml_path> <output_folder>
```

**Parameters:**
- `<dp_xml_path>` — folder with external data processor XML (must contain `ExternalDataProcessor.xml` or `ExternalReport.xml`)
- `<output_folder>` — destination for compiled EPF/ERF file

**Example:**
```bash
V8_VERSION=8.3.27.1859 \
V8_BASE_IB=/F/tmp/base_ib \
  ~/Проекты/1CFilesConverter/scripts/dp2epf.sh ./dataprocessors/MyProcessor ./dist
```

Output: `./dist/MyProcessor.epf`

---

# Dump data processor to XML

Extract external data processor or report from binary (EPF/ERF) to XML format.

## Command

```bash
V8_VERSION=<version> \
V8_BASE_IB=<base_ib_path> \
  <converter_path>/scripts/dp2xml.sh <epf_file> <output_xml_folder>
```

**Example:**
```bash
V8_VERSION=8.3.27.1859 \
V8_BASE_IB=/F/tmp/base_ib \
  ~/Проекты/1CFilesConverter/scripts/dp2xml.sh ./dist/MyProcessor.epf ./dataprocessors/MyProcessor
```

---

# Convert to EDT

Convert external data processor/report to 1C:EDT project format.

Mapping: `.dev.env` `EDT_VERSION` → `V8_EDT_VERSION` (in addition to `V8_VERSION` = `basename(PLATFORM_PATH)` and `BASE_IB`/`BASE_CONFIG`).

## Command

```bash
V8_VERSION=<version> \
V8_EDT_VERSION=<edt_version> \
V8_BASE_IB=<base_ib_path> \
  <converter_path>/scripts/dp2edt.sh <dp_source> <edt_project_path>
```

**Parameters:**
- `<dp_source>` — EPF/ERF file or XML folder
- `<edt_project_path>` — destination for EDT project

**Note:** Requires 1C:EDT tools (ring or edtcli).

---

# Base configuration setup

For data processors/reports compilation, you need a base configuration. Two options:

### Option 1: Use existing infobase

```bash
V8_BASE_IB="/F/tmp/my_config_ib"
```

### Option 2: Use CF file

```bash
V8_BASE_CONFIG="/path/to/1cv8.cf"
```

The converter will automatically create a temporary infobase from CF if needed.

---

# Workflow example

**Scenario:** Develop external data processor, build EPF for distribution.

1. Extract existing EPF to XML:
   ```bash
   V8_VERSION=8.3.27.1859 \
   V8_BASE_IB=/F/tmp/base_ib \
     ~/Проекты/1CFilesConverter/scripts/dp2xml.sh ./current/Processor.epf ./src/dataprocessors/Processor
   ```

2. Modify XML files in `./src/dataprocessors/Processor/`

3. Build updated EPF:
   ```bash
   V8_VERSION=8.3.27.1859 \
   V8_BASE_IB=/F/tmp/base_ib \
     ~/Проекты/1CFilesConverter/scripts/dp2epf.sh ./src/dataprocessors/Processor ./dist
   ```

4. Distribute `./dist/Processor.epf`

---

# No fallback

Operations with external data processors/reports have **no Designer fallback** — they require 1CFilesConverter.

For manual operations:
1. Open Designer
2. File → Open → Select EPF/ERF
3. Edit and save manually
4. File → Save as → Select format

---

# Best practices

1. **Always use base configuration** (`V8_BASE_IB` or `V8_BASE_CONFIG`) — required for correct compilation
2. **Version control XML** — store data processors as XML, build EPF for distribution
3. **Check converter logs** at `<converter_path>/tmp/v8_designer_output.log`
4. **Use `search_metadata`** to find available subsystems for external processors
5. **Test EPF files** after build — load in target infobase and verify functionality
