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

CLAUDE.md                    ──────►     CLAUDE.md
.claude/settings.json        ──────►     .claude/settings.json

AGENTS.md                    ──────►     AGENTS.md

deploy/mcp-servers.json      ─┬─────►   .cursor/mcp.json      (генерируется)
                              ├─────►   .mcp.json              (генерируется)
                              └─────►   opencode.json          (генерируется)

(скрипт создаёт)             ──────►     infobasesettings.md
```

> MCP-конфиги не копируются, а **генерируются** из единого шаблона `deploy/mcp-servers.json`. Это позволяет менять хост и порты серверов при установке.

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
| `.mcp.json` | `.mcp.json` | 8 MCP-серверов (streamable HTTP, `"type": "http"` обязателен) |
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

> **CloudEmbeddingsServer** (альтернатива CodeMetadataSearchServer) использует тот же порт 8000 и предоставляет облачную индексацию с параллельными эмбеддингами. Используется одно из двух — `code-metadata` в конфигурации покрывает оба варианта.

Серверы запускаются через Docker ([документация](https://docs.onerpa.ru/mcp-servery-1c)) и по умолчанию слушают на `localhost`.

> **Важно для Claude Code:** В `.mcp.json` каждый сервер **обязан** содержать `"type": "http"` помимо `"url"`. Без этого поля Claude Code не подключит сервер. Cursor и OpenCode определяют транспорт автоматически.

### Единый источник конфигурации

Все MCP-конфиги генерируются из одного файла — `deploy/mcp-servers.json`. Он содержит:
- `host` — хост по умолчанию (localhost)
- `servers` — список серверов с портами, путями и именами для каждого инструмента

### Изменение хоста

Если MCP-серверы запущены на другой машине:

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С --host 192.168.1.100
```

### Изменение портов

Создайте JSON-файл с нужными портами (указывайте только те, что отличаются от стандартных):

```json
{
  "docs": 9003,
  "ssl": 9008,
  "forms": 9011
}
```

Доступные идентификаторы серверов: `code-metadata`, `syntax-checker`, `docs`, `templates`, `graph-metadata`, `code-check`, `ssl`, `forms`.

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С --ports my-ports.json
```

Можно комбинировать:

```bash
./scripts/init-project.sh ~/Проекты/МойПроект1С --host mcp.example.com --ports custom-ports.json
```

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
2. Запустите MCP-серверы ([документация](https://docs.onerpa.ru/mcp-servery-1c))
3. Откройте проект в выбранном инструменте:
   - **Cursor:** откройте папку проекта в Cursor IDE
   - **Claude Code:** `cd ~/Проекты/МойПроект1С && claude`
   - **OpenCode:** `cd ~/Проекты/МойПроект1С && opencode`

## Обновление

При выходе новой версии правил повторно запустите скрипт — он перезапишет файлы конфигурации. Файл `infobasesettings.md` не перезаписывается.

## Файлы развёртывания

| Файл | Назначение |
|------|-----------|
| `deploy/README.md` | Этот документ |
| `deploy/mcp-servers.json` | Единый источник конфигурации MCP-серверов (хост, порты, имена) |
| `deploy/cursor.json` | Манифест: что копировать/генерировать для Cursor |
| `deploy/claude.json` | Манифест: что копировать/генерировать для Claude Code |
| `deploy/opencode.json` | Манифест: что копировать/генерировать для OpenCode |
| `scripts/init-project.sh` | Скрипт инициализации (читает манифесты, генерирует MCP-конфиги) |
