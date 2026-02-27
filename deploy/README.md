# Развёртывание в проект 1С

Этот репозиторий содержит конфигурации для трёх AI-инструментов. Каждый инструмент ожидает свои файлы в определённых местах целевого проекта.

## Схема развёртывания

```
cursor_rules_1c/                         Целевой проект 1С/
(этот репозиторий)                       (куда копируем)

.cursor/agents/*.md          ──────►     .cursor/agents/*.md
.cursor/rules/*.mdc          ──────►     .cursor/rules/*.mdc
.cursor/skills/              ──────►     .cursor/skills/
.cursor/commands/            ──────►     .cursor/commands/
.cursor/mcp.json             ──────►     .cursor/mcp.json

CLAUDE.md                    ──────►     CLAUDE.md
.mcp.json                    ──────►     .mcp.json
.claude/settings.json        ──────►     .claude/settings.json

AGENTS.md                    ──────►     AGENTS.md
opencode.json                ──────►     opencode.json

(скрипт создаёт)             ──────►     infobasesettings.md
```

## Что куда и зачем

### Cursor IDE

Cursor ищет конфигурацию в `.cursor/` целевого проекта.

| Источник (репозиторий) | Назначение (целевой проект) | Что содержит |
|------------------------|----------------------------|-------------|
| `.cursor/agents/` | `.cursor/agents/` | 12 AI-агентов |
| `.cursor/rules/` | `.cursor/rules/` | 11 правил кодирования |
| `.cursor/skills/` | `.cursor/skills/` | Навыки для метаданных, форм, макетов |
| `.cursor/commands/` | `.cursor/commands/` | Команды deploy и dump |
| `.cursor/mcp.json` | `.cursor/mcp.json` | 8 MCP-серверов (URL-based) |

### Claude Code

Claude Code ищет конфигурацию в **корне** проекта.

| Источник (репозиторий) | Назначение (целевой проект) | Что содержит |
|------------------------|----------------------------|-------------|
| `CLAUDE.md` | `CLAUDE.md` | Правила кодирования, антипаттерны, MCP workflow |
| `.mcp.json` | `.mcp.json` | 8 MCP-серверов (streamable HTTP) |
| `.claude/settings.json` | `.claude/settings.json` | Язык, разрешения, автоодобрение MCP |

### OpenCode

OpenCode ищет конфигурацию в **корне** проекта.

| Источник (репозиторий) | Назначение (целевой проект) | Что содержит |
|------------------------|----------------------------|-------------|
| `AGENTS.md` | `AGENTS.md` | Правила кодирования (аналог CLAUDE.md) |
| `opencode.json` | `opencode.json` | MCP-серверы (remote) + ссылки на `.cursor/rules/` |

> **Примечание:** OpenCode через `instructions` в `opencode.json` ссылается на файлы из `.cursor/rules/`. Поэтому для полноценной работы OpenCode рекомендуется также установить Cursor-компоненты (`--tools cursor,opencode`).

### Общие файлы

| Источник (репозиторий) | Назначение (целевой проект) | Что содержит |
|------------------------|----------------------------|-------------|
| _(создаётся скриптом)_ | `infobasesettings.md` | Шаблон подключения к ИБ |

## MCP-серверы

Все три инструмента подключают одинаковый набор из 8 MCP-серверов:

| Сервер | Порт | Инструмент (имя в конфиге) |
|--------|------|---------------------------|
| Метаданные + код | 8000 | `1c-code-metadata-mcp` / `1c-code-metadata` |
| Синтаксис | 8002 | `1c-syntax-checker-mcp` / `1c-syntax-checker` |
| Документация | 8003 | `1c-docs-mcp` / `1c-docs` |
| Шаблоны | 8004 | `1c-templates-mcp` / `1c-templates` |
| Граф метаданных | 8006 | `1c-graph-metadata-mcp` / `1c-graph-metadata` |
| Проверка кода | 8007 | `1c-code-check-mcp` / `1c-code-check` |
| БСП | 8008 | `1c-ssl-mcp` / `1c-ssl` |
| Формы | 8011 | `1c-forms-mcp` / `1c-forms` |

Серверы запускаются через [vibecoding1c.ru](https://vibecoding1c.ru/) и слушают на `localhost`.

## Быстрый старт

### Все инструменты

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С
```

### Только Cursor + Claude Code

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С --tools cursor,claude
```

### Только OpenCode (+ Cursor для правил)

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С --tools cursor,opencode
```

### Только Claude Code (минимальная установка)

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С --tools claude
```

### Просмотр маппинга без копирования

```bash
./scripts/init-project.sh --list
```

## После установки

1. Отредактируйте `infobasesettings.md` — укажите подключение к ИБ
2. Запустите MCP-серверы через [vibecoding1c.ru](https://vibecoding1c.ru/)
3. Откройте проект в выбранном инструменте:
   - **Cursor:** откройте папку проекта в Cursor IDE
   - **Claude Code:** `cd ~/Проекты/МойПроект1С && claude`
   - **OpenCode:** `cd ~/Проекты/МойПроект1С && opencode`

## Обновление

При выходе новой версии правил повторно запустите скрипт — он перезапишет файлы конфигурации. Файл `infobasesettings.md` не перезаписывается.
