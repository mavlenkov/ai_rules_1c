# Поддержка Claude Code и OpenCode

## Проблема

Проект cursor_rules_1c ориентирован исключительно на Cursor IDE:
- Правила в формате `.mdc` (Cursor-специфичный)
- MCP-серверы сконфигурированы только в `.cursor/mcp.json`
- Агенты только в `.cursor/agents/`
- Нет конфигурации для Claude Code и OpenCode

При этом Claude Code и OpenCode поддерживают аналогичные возможности:
- Claude Code: `CLAUDE.md`, `.mcp.json`, `.claude/agents/`, `.claude/settings.json`
- OpenCode: `AGENTS.md`, `opencode.json`, `.opencode/agents/`, `instructions`

## Цель

Адаптировать проект для работы с тремя AI-инструментами:
1. **Cursor IDE** — существующая конфигурация (`.cursor/`)
2. **Claude Code** — добавить `.mcp.json`, обновить `CLAUDE.md`, добавить `.claude/settings.json`
3. **OpenCode** — добавить `opencode.json` и `AGENTS.md`

Обеспечить оперативную инициализацию: при развёртывании в проект 1С MCP-серверы подключаются автоматически для всех инструментов.

## Подход

- MCP-серверы описаны в трёх форматах: `.cursor/mcp.json`, `.mcp.json` (Claude Code), `opencode.json` (OpenCode)
- Правила проекта: `.cursor/rules/*.mdc` (Cursor), `CLAUDE.md` (Claude Code), `AGENTS.md` (OpenCode)
- OpenCode дополнительно использует `instructions` для загрузки `.cursor/rules/*.md` файлов
- Скрипт `scripts/init-project.sh` для быстрой инициализации нового проекта
