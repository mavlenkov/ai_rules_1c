## Why

При тестировании развёртывания на реальном проекте (ЕвротестРасширение, серверная ИБ rigel:1541\Евротест) обнаружены критические проблемы: Claude Code не подключает MCP-серверы без `"type":"http"`, формат строки подключения `/S` с пробелом приводит к молчаливой ошибке, а команды deploy не поддерживают загрузку расширений конфигурации (`-Extension`). Подробности: `REPORT-2026-03-02-findings.md`.

## What Changes

- **MCP-конфиги**: добавить `"type": "http"` во все записи `.mcp.json` — в генераторе (`deploy/mcp-servers.json`, `scripts/init-project.sh`) и в статичном `.mcp.json` корня проекта
- **Формат подключения**: исправить документацию и примеры — `/Sserver\base` и `/F/path` без пробела после флага; добавить валидацию в инструкции (проверка лога на «Неопределена информационная база»)
- **Поддержка расширений**: добавить автодетекцию расширения (по `Configuration.xml`), поле `Extension name` в `infobasesettings.md`, использование `ext2ib.sh` / `-Extension` в командах deploy
- **Диагностика**: предупреждение о том, что логи конвертера удаляются; рекомендация по `bash -x` для отладки
- **Формат `/S` в Mode 2**: привести примеры к рабочему формату (`/IBConnectionString` для серверных ИБ)

## Capabilities

### New Capabilities
- `extension-support`: Автодетекция расширений конфигурации и корректная загрузка через `-Extension` / `ext2ib.sh`

### Modified Capabilities
- `commands`: Исправление формата `/S`/`/F`, валидация логов, диагностика удалённых логов
- `mcp-integration`: Добавление `"type":"http"` в генерацию MCP-конфигов для Claude Code
- `multi-tool-support`: Обновление генератора `init-project.sh` и deploy-манифестов

## Impact

- `deploy/mcp-servers.json` — добавление поля transport
- `scripts/init-project.sh` — генерация `"type":"http"` в `.mcp.json`
- `.mcp.json` (корень) — добавление type ко всем серверам
- `.cursor/commands/deploy_and_test.md` — формат /S, поддержка расширений, диагностика
- `.cursor/commands/getconfigfiles.md` — формат /S
- `.cursor/rules/getconfigfiles.mdc` — формат /S
- `.cursor/agents/tester.md` — формат /S
- `infobasesettings.md` (шаблон в init-project.sh) — поле Extension
- `deploy/claude.json` — шаблон с type:http
