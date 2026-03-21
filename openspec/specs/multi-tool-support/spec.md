# Multi-Tool Support Specification

## Purpose
Обеспечить работу проекта с Cursor IDE, Claude Code и OpenCode без дублирования правил и с единым набором MCP-серверов.

## Requirements

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

### Requirement: Единые правила разработки
Правила кодирования должны быть доступны всем инструментам без дублирования.

#### Scenario: Cursor IDE загружает правила
- GIVEN `.cursor/rules/*.mdc` содержит правила
- WHEN агент Cursor начинает работу
- THEN загружаются always-applied и context-dependent правила

#### Scenario: Claude Code загружает правила
- GIVEN `CLAUDE.md` содержит ключевые правила и антипаттерны
- WHEN Claude Code начинает работу
- THEN правила из `CLAUDE.md` применяются автоматически

#### Scenario: OpenCode загружает правила
- GIVEN `AGENTS.md` содержит правила, `opencode.json` ссылается на дополнительные файлы
- WHEN OpenCode начинает работу
- THEN загружаются `AGENTS.md` + файлы из `instructions` (`anti-patterns.mdc`, `mcp-tools.mdc`)

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

### Requirement: Настраиваемые хост и порты MCP-серверов
MCP-конфиги должны генерироваться из единого шаблона `deploy/mcp-servers.json` с возможностью переопределения.

#### Scenario: MCP-серверы на удалённой машине
- GIVEN MCP-серверы запущены на хосте 192.168.1.100
- WHEN выполнен `scripts/init-project.sh /path --host 192.168.1.100`
- THEN все три MCP-конфига содержат URL с хостом 192.168.1.100

#### Scenario: Нестандартные порты
- GIVEN сервер docs слушает на порту 9003 вместо 8003
- WHEN передан `--ports custom.json` с содержимым `{"docs": 9003}`
- THEN docs-сервер получает порт 9003, остальные — порты по умолчанию

#### Scenario: Просмотр конфигурации MCP
- GIVEN пользователь хочет увидеть текущий маппинг серверов
- WHEN выполнен `scripts/init-project.sh --list`
- THEN выводится таблица серверов с портами и именами для каждого инструмента

### Requirement: Совместимость OpenCode с Claude Code
OpenCode поддерживает файлы Claude Code как fallback.

#### Scenario: OpenCode без AGENTS.md
- GIVEN проект содержит `CLAUDE.md`, но не `AGENTS.md`
- WHEN OpenCode запускается
- THEN он читает `CLAUDE.md` как инструкции (fallback)

#### Scenario: OpenCode с AGENTS.md
- GIVEN проект содержит и `CLAUDE.md`, и `AGENTS.md`
- WHEN OpenCode запускается
- THEN он использует `AGENTS.md` (приоритет), `CLAUDE.md` игнорируется

## MCP Server Mapping

Единый источник: `deploy/mcp-servers.json`. Порты по умолчанию:

| Сервер | Порт | `.cursor/mcp.json` | `.mcp.json` | `opencode.json` |
|--------|------|--------------------|--------------|--------------------|
| code-metadata | 8000 | `1c-code-metadata-mcp` | `1c-code-metadata-mcp` | `1c-code-metadata` |
| syntax-checker | 8002 | `1c-syntax-checker-mcp` | `1c-syntax-checker-mcp` | `1c-syntax-checker` |
| docs | 8003 | `1C-docs-mcp` | `1c-docs-mcp` | `1c-docs` |
| templates | 8004 | `1c-templates-mcp` | `1c-templates-mcp` | `1c-templates` |
| graph-metadata | 8006 | `1c-graph-metadata-mcp` | `1c-graph-metadata-mcp` | `1c-graph-metadata` |
| code-check | 8007 | `1c-code-check-mcp` | `1c-code-check-mcp` | `1c-code-check` |
| ssl | 8008 | `1c-ssl-mcp` | `1c-ssl-mcp` | `1c-ssl` |
| forms | 8011 | `1c-forms-mcp` | `1c-forms-mcp` | `1c-forms` |

Хост и порты настраиваются через `--host` и `--ports` при инициализации.

## File Mapping

| Назначение | Cursor IDE | Claude Code | OpenCode |
|-----------|------------|-------------|----------|
| MCP-серверы | `.cursor/mcp.json` | `.mcp.json` | `opencode.json` → `mcp` |
| Правила | `.cursor/rules/*.mdc` | `CLAUDE.md` | `AGENTS.md` + `instructions` |
| Агенты | `.cursor/agents/*.md` | `.claude/agents/` (при необходимости) | `.opencode/agents/` (при необходимости) |
| Навыки | `.cursor/skills/` | — | — |
| Команды | `.cursor/commands/` | — | `.opencode/commands/` (при необходимости) |
| Настройки | `.cursor/settings.json` | `.claude/settings.json` | `opencode.json` |
