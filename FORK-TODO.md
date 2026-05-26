# FORK-TODO — технический долг форка `mavlenkov/ai_rules_1c`

Линукс + 1CFilesConverter edition поверх upstream `comol/ai_rules_1c`.
Этот файл фиксирует расхождения форка с upstream, требующие отдельной работы.
Не относится к upstream — при PR в upstream не включать.

## После мержа upstream «версия 4» (2026-05-25, upstream `5b246bc`)

### 1. Рассинхрон источника параметров ИБ: `.dev.env` (upstream) vs `infobasesettings.md` (форк) — КРУПНЫЙ

Upstream мигрировал весь проект на `.dev.env` как единый источник параметров
(подключение к ИБ, публикация, платформа). Команды upstream
(`loadfrom1cbase`, `update1cbase`, `getconfigfiles`, `deploy-and-test`)
читают `.dev.env`.

Форк-команды (`deploy-and-test`, `extensions`, `dataprocessors`, `getconfigfiles`)
по-прежнему читают `infobasesettings.md`. При мерже намеренно сохранены
форк-версии этих команд (Linux + 1CFilesConverter, Mode 1 / Mode 2).

`AGENTS.md → Project info` описывает `.dev.env`, а форк-подсекция
`### Infobase deployment (Linux + 1CFilesConverter — fork)` — `infobasesettings.md`.

**Решить:** либо мигрировать форк-команды и Linux/1CFilesConverter-логику на
`.dev.env` (предпочтительно — единый источник), либо явно зафиксировать
`infobasesettings.md` как форк-слой и описать маршрутизацию. Сейчас — рассинхрон.

### 2. Новые команды upstream — Windows/PowerShell-ориентированы

Приняты как есть, но требуют Linux-адаптации под форк (PowerShell-синтаксис,
`*.exe`, `Test-Path`, `C:\Program Files`, `.dev.env`):

- `content/commands/installmcp.md`
- `content/commands/updatemcp.md`
- `content/commands/checkmcp.md`
- `content/commands/doctor.md`
- `content/commands/loadfrom1cbase.md`
- `content/commands/update1cbase.md`
- `content/commands/updaterules.md`
- `content/rules/getconfigfiles.md` (обновлён upstream; наша команда
  `getconfigfiles` на него больше не опирается — самодостаточна)

### 3. `scripts/install.sh` vs новый MCP-сервер `1c-data-mcp`

`content/mcp-servers.json` получил сервер `1c-data-mcp` с URL-плейсхолдером
`{INFOBASE_PUBLISH_URL}/hs/mcp` (не `localhost`). Наш `install.sh --host`
подставляет хост только в `localhost`-URL'ы — этот плейсхолдер останется
неподставленным. **Решить:** обработать `{INFOBASE_PUBLISH_URL}` в `install.sh`
или задокументировать, что сервер настраивается вручную при bash-установке.

### 4. `scripts/install.sh` — покрытие новых tools/файлов

`install.sh` поддерживает только `cursor` / `claude-code` / `opencode`.
Upstream добавил адаптер `adapters/other.yaml` (универсальный fallback) и
много нового контента (агент `explorer`, скиллы `mcp-1c-tools`, `caveman`,
`handoff`, `md-to-docx`, `prompt-enhancer`, `transcribe`). Адаптеры
cursor/claude-code/opencode изменились только в комментариях — структура
операций прежняя, install.sh не сломан. Но стоит свериться, что новый контент
раскладывается корректно (особенно скиллы со скриптами и `presets/`).
