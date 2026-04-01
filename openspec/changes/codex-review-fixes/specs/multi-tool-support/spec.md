# Multi-Tool Support Specification — Delta

## MODIFIED Requirements

### Requirement: Оперативная инициализация
Скрипт должен позволять быстро развернуть конфигурацию в новый проект 1С. Генератор `init-project.sh` ДОЛЖЕН валидировать входные данные, корректно обрабатывать ошибки и не уничтожать пользовательские файлы.

#### Scenario: Полная инициализация
- **WHEN** выполнен `scripts/init-project.sh /path/to/project`
- **THEN** в проекте создаётся `.cursor/` с правилами и агентами, `CLAUDE.md`, `.mcp.json` (с `"type": "http"`), `AGENTS.md`, `opencode.json`, шаблон `infobasesettings.md`

#### Scenario: Частичная инициализация только OpenCode
- **WHEN** выполнен `scripts/init-project.sh /path/to/project --tools opencode`
- **THEN** копируются `AGENTS.md`, `opencode.json`, и дополнительно `.cursor/rules/anti-patterns.mdc`, `.cursor/rules/mcp-tools.mdc` (зависимости opencode.json)

#### Scenario: Повторная инициализация с сохранением пользовательских файлов
- **WHEN** выполнен скрипт повторно в проекте с пользовательскими навыками/агентами
- **THEN** файлы из репозитория обновляются, пользовательские дополнения НЕ удаляются
- **AND** `infobasesettings.md` не перезаписывается

#### Scenario: Невалидное имя инструмента
- **WHEN** передан `--tools` с несуществующим именем (напр. `--tools opencode,typo`)
- **THEN** скрипт завершается с exit code 1 и сообщением об ошибке ДО начала копирования

#### Scenario: Ошибка генерации MCP-конфигов
- **WHEN** python3 доступен, но произошла ошибка при генерации (битый JSON, ошибка записи)
- **THEN** скрипт выводит реальное сообщение об ошибке (не «python3 недоступен»)
- **AND** скрипт завершается с exit code 1

## ADDED Requirements

### Requirement: Сгенерированные MCP-конфиги не хранятся в VCS
Файлы `.cursor/mcp.json`, `.mcp.json`, `opencode.json` ДОЛЖНЫ генерироваться при установке и НЕ ДОЛЖНЫ храниться в репозитории.

#### Scenario: Файлы MCP в .gitignore
- **WHEN** разработчик клонирует репозиторий
- **THEN** `.cursor/mcp.json`, `.mcp.json`, `opencode.json` отсутствуют
- **AND** `.gitignore` содержит эти файлы

#### Scenario: Генерация при init-project.sh
- **WHEN** выполнен `scripts/init-project.sh`
- **THEN** MCP-конфиги генерируются из `deploy/mcp-servers.json` с правильным хостом

### Requirement: Безопасные дефолтные настройки Claude Code
Шаблон `.claude/settings.json` ДОЛЖЕН использовать безопасные дефолтные разрешения.

#### Scenario: Дефолтный режим разрешений
- **WHEN** скрипт копирует `.claude/settings.json` в целевой проект
- **THEN** `defaultMode` установлен в `"default"` (не `"bypassPermissions"`)

#### Scenario: Персональные настройки не в VCS
- **WHEN** разработчик создаёт `.claude/settings.local.json` с персональными разрешениями
- **THEN** файл исключён из VCS через `.gitignore`
