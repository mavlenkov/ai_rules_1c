# Multi-Tool Support Specification — Delta

## MODIFIED Requirements

### Requirement: Конфигурация MCP-серверов для каждого инструмента
Каждый AI-инструмент должен иметь свой файл конфигурации MCP-серверов с одинаковым набором серверов. Генератор ДОЛЖЕН добавлять `"type": "http"` только в `.mcp.json` (Claude Code).

#### Scenario: Cursor IDE подключает MCP-серверы
- **WHEN** проект содержит `.cursor/mcp.json`
- **THEN** все 8 MCP-серверов доступны через URL-based соединение
- **AND** поле `"type"` отсутствует (Cursor определяет транспорт автоматически)

#### Scenario: Claude Code подключает MCP-серверы
- **WHEN** проект содержит `.mcp.json` в корне
- **THEN** все 8 MCP-серверов доступны через streamable HTTP
- **AND** каждая запись содержит `"type": "http"` и `"url"`
- **AND** `.claude/settings.json` содержит `enableAllProjectMcpServers: true`

#### Scenario: OpenCode подключает MCP-серверы
- **WHEN** проект содержит `opencode.json` с секцией `mcp`
- **THEN** все 8 MCP-серверов доступны как remote MCP с type "remote"

### Requirement: Оперативная инициализация
Скрипт должен позволять быстро развернуть конфигурацию в новый проект 1С. Генератор `init-project.sh` ДОЛЖЕН учитывать поле `transport` из `deploy/mcp-servers.json` при генерации `.mcp.json`.

#### Scenario: Полная инициализация
- **WHEN** выполнен `scripts/init-project.sh /path/to/project`
- **THEN** в проекте создаётся `.cursor/` с правилами и агентами, `CLAUDE.md`, `.mcp.json` (с `"type": "http"`), `AGENTS.md`, `opencode.json`, шаблон `infobasesettings.md`

#### Scenario: Частичная инициализация
- **WHEN** выполнен `scripts/init-project.sh /path/to/project --tools claude`
- **THEN** копируются `CLAUDE.md`, `.mcp.json` (с `"type": "http"`), `.claude/settings.json`

#### Scenario: Повторная инициализация
- **WHEN** выполнен скрипт повторно
- **THEN** файлы обновляются, `infobasesettings.md` не перезаписывается

#### Scenario: Генерация с transport из mcp-servers.json
- **WHEN** `deploy/mcp-servers.json` содержит `"transport": "http"` для сервера
- **THEN** генератор добавляет `"type": "http"` в `.mcp.json` (Claude Code)
- **AND** генератор НЕ добавляет `"type"` в `.cursor/mcp.json` и `opencode.json`
