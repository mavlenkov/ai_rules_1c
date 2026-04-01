## Why

Codex (gpt-5.4) провёл полную ревизию проекта и выявил 13 проблем: 1 критическую, 4 высоких, 5 средних, 3 низких. Основная тема — дрейф между source of truth (deploy/mcp-servers.json, specs), сгенерированными файлами и документацией. Также найдены баги в init-project.sh и противоречия в инструкциях команд.

## What Changes

Исправление всех дефектов из ревью Codex, сгруппированных по направлениям:

1. **init-project.sh** — критические баги и edge cases
2. **MCP-конфиги в VCS** — убрать сгенерированные файлы из репозитория
3. **Документация** — привести README, CLAUDE.md, AGENTS.md в соответствие с реальностью
4. **Команды** — исправить противоречия в deploy_and_test.md
5. **Specs** — убрать несуществующие элементы из multi-tool spec
6. **Security** — settings.json, settings.local.json

## Capabilities

### New Capabilities

(нет новых capabilities)

### Modified Capabilities

- `multi-tool-support`: исправить --tools opencode зависимость от cursor rules; валидация --tools; не сносить пользовательские файлы при повторной инициализации; убрать несуществующие элементы из spec; не хранить сгенерированные MCP-конфиги в VCS
- `commands`: исправить hardcoded URL тестирования; унифицировать формат infobasesettings.md

## Impact

- `scripts/init-project.sh` — основные исправления
- `.cursor/mcp.json`, `.mcp.json`, `opencode.json` — удалить из VCS, добавить в .gitignore
- `README.md`, `CLAUDE.md`, `AGENTS.md` — синхронизация с реальностью
- `.cursor/commands/deploy_and_test.md` — URL тестирования
- `.claude/settings.json` — смягчить дефолтные разрешения
- `.claude/settings.local.json` — удалить из VCS, добавить в .gitignore
- `openspec/specs/multi-tool-support/spec.md` — убрать несуществующие пути
- `deploy/README.md` — обновить инструкцию ручной установки
