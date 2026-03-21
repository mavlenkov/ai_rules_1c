# MCP Integration Specification — Delta

## ADDED Requirements

### Requirement: Обязательный транспорт для Claude Code
Конфигурация MCP-серверов для Claude Code ДОЛЖНА содержать явное указание типа транспорта.

#### Scenario: Claude Code подключает MCP-серверы с type:http
- **WHEN** `.mcp.json` содержит запись MCP-сервера
- **THEN** запись ДОЛЖНА включать `"type": "http"` помимо `"url"`
- **AND** без `"type"` Claude Code не подключает сервер

#### Scenario: Cursor IDE не требует type
- **WHEN** `.cursor/mcp.json` содержит запись MCP-сервера
- **THEN** поле `"type"` не требуется — Cursor определяет транспорт по URL автоматически

#### Scenario: OpenCode не требует type
- **WHEN** `opencode.json` содержит запись MCP-сервера с `"type": "remote"`
- **THEN** поле `"type": "remote"` уже присутствует в формате OpenCode (это другое поле, не HTTP transport)
