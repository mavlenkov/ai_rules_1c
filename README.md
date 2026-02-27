# AI-правила для разработки на 1С

Набор правил, агентов, навыков и команд для разработки на платформе 1С:Предприятие 8.3 с использованием AI-инструментов и MCP-серверов.

Поддерживаемые инструменты: **Cursor IDE**, **Claude Code**, **OpenCode**.

> Полная спецификация проекта: [`openspec/specs/`](openspec/specs/)

## Быстрый старт

### Вариант 1 — Автоматическая инициализация (Linux / macOS / WSL)

```bash
git clone https://github.com/mavlenkov/cursor_rules_1c.git
cd cursor_rules_1c
./scripts/init-project.sh /path/to/1c-project
```

С выбором инструментов:
```bash
./scripts/init-project.sh /path/to/1c-project --tools cursor,claude
./scripts/init-project.sh /path/to/1c-project --tools opencode
```

Нестандартный хост или порты MCP-серверов:
```bash
./scripts/init-project.sh /path/to/1c-project --host 192.168.1.100
./scripts/init-project.sh /path/to/1c-project --host mcp.example.com --ports custom-ports.json
```

### Вариант 2 — Ручная установка (все ОС, включая Windows)

```
git clone https://github.com/mavlenkov/cursor_rules_1c.git
```

Скопируйте файлы из клонированного репозитория в целевой проект согласно таблице:

| Что копировать | Куда (относительно корня проекта) | Для какого инструмента |
|---------------|----------------------------------|----------------------|
| `.cursor/agents/` | `.cursor/agents/` | Cursor |
| `.cursor/rules/` | `.cursor/rules/` | Cursor |
| `.cursor/skills/` | `.cursor/skills/` | Cursor |
| `.cursor/commands/` | `.cursor/commands/` | Cursor |
| `.cursor/mcp.json` | `.cursor/mcp.json` | Cursor |
| `CLAUDE.md` | `CLAUDE.md` | Claude Code |
| `.mcp.json` | `.mcp.json` | Claude Code |
| `.claude/settings.json` | `.claude/settings.json` | Claude Code |
| `AGENTS.md` | `AGENTS.md` | OpenCode |
| `opencode.json` | `opencode.json` | OpenCode |

> При нестандартных портах MCP-серверов отредактируйте `.cursor/mcp.json`, `.mcp.json` и `opencode.json` — измените номера портов в URL.

Затем:
1. Настройте MCP-серверы: [документация](https://docs.onerpa.ru/mcp-servery-1c)
2. Создайте `infobasesettings.md` с подключением к ИБ и URL тестирования
3. Начните работу с агентами: `@1c-developer`, `@1c-architect` и др.

## Развёртывание

Каждый инструмент ожидает свои файлы в определённых местах целевого проекта:

```
Репозиторий                              Целевой проект 1С
──────────                               ──────────────────

.cursor/agents/  ────────────────────►   .cursor/agents/
.cursor/rules/   ────────────────────►   .cursor/rules/        ← Cursor IDE
.cursor/skills/  ────────────────────►   .cursor/skills/
.cursor/commands/────────────────────►   .cursor/commands/
.cursor/mcp.json ────────────────────►   .cursor/mcp.json

CLAUDE.md        ────────────────────►   CLAUDE.md
.mcp.json        ────────────────────►   .mcp.json             ← Claude Code
.claude/         ────────────────────►   .claude/

AGENTS.md        ────────────────────►   AGENTS.md             ← OpenCode
opencode.json    ────────────────────►   opencode.json

(скрипт)         ────────────────────►   infobasesettings.md
```

Скрипт `scripts/init-project.sh` автоматически раскладывает файлы по нужным местам. Посмотреть маппинг без копирования:

```bash
./scripts/init-project.sh --list
```

Подробности: [`deploy/README.md`](deploy/README.md) | Спецификация: [`openspec/specs/multi-tool-support/spec.md`](openspec/specs/multi-tool-support/spec.md)

## Компоненты

### [Агенты](openspec/specs/agents/spec.md)
12 специализированных AI-ассистентов для разных этапов разработки:

| Группа | Агенты |
|--------|--------|
| **Разработка** | developer, architect, analytic |
| **Качество** | code-reviewer, arch-reviewer, error-fixer, refactoring, performance-optimizer |
| **Документация** | doc-writer, planner, tester |
| **Метаданные** | metadata-manager |

### [Правила](openspec/specs/rules/spec.md)
11 правил кодирования и поведения агентов:

- **Always-applied:** `project_rules.mdc`, `user_rules.mdc`
- **Context-dependent:** `anti-patterns.mdc`, `mcp-tools.mdc`, `sdd-integrations.mdc`, `form_module_rules.mdc`, `forms_add.mdc`, `forms_events_add.mdc`, `integrations_add.mdc`, `refactor_add.mdc`, `getconfigfiles.mdc`

### [Навыки](openspec/specs/skills/spec.md)
Углублённые знания для специфических задач:

- **1c-metadata-manage** — мета-навык с подкомандами: формы (form-*), макеты (mxl-*), роли (role-*), EPF/ERF (epf-*), операции с платформой
- **powershell-windows** — правила PowerShell на Windows
- **mermaid-diagrams** — создание диаграмм
- **img-grid-analysis** — разметка макетов

### [Команды](openspec/specs/commands/spec.md)
Кросс-платформенные команды для операций с ИБ:

- **deploy_and_test** — загрузка конфигурации + обновление БД + тестирование
- **getconfigfiles** — выборочная выгрузка объектов из ИБ

Поддержка: Linux/Windows, файловые и серверные ИБ, автодетект ОС и версии платформы.

### [MCP-интеграция](openspec/specs/mcp-integration/spec.md)
Работа с MCP-инструментами vibecoding1c.ru:

| Инструмент | Назначение |
|------------|------------|
| `docsearch` | Документация платформы 1С |
| `codesearch` | Поиск в текущей конфигурации |
| `templatesearch` | Шаблоны и примеры кода |
| `search_metadata` | Структура метаданных |
| `ssl_search` | Функции БСП |
| `syntaxcheck` | Синтаксический контроль |
| `check_1c_code` | Анализ логики и производительности |

### [SDD-интеграция](openspec/specs/sdd-integration/spec.md)
Поддержка spec-driven development:

- **OpenSpec** — спецификации и change proposals (`openspec/specs/`, `openspec/changes/`)
- **Memory Bank** — управление контекстом (`memory-bank/`)
- **Spec Kit** — архитектурные ограничения (`spec.md`, `constitution.md`, `boundaries.md`, `glossary.md`)
- **TaskMaster** — AI-управление задачами (MCP-сервер)

## Структура

```
.cursor/
├── agents/          # 12 AI-агентов (Cursor)
├── rules/           # 11 правил (2 always-applied, 9 context-dependent)
├── skills/          # Навыки (1c-metadata-manage + утилиты)
├── commands/        # 2 команды (deploy + dump)
└── mcp.json         # MCP-серверы (Cursor)

.claude/
└── settings.json    # Настройки Claude Code

openspec/
├── specs/           # Спецификации capabilities (source of truth)
└── changes/         # Change proposals

deploy/
├── README.md        # Подробный гайд по развёртыванию
├── cursor.json      # Манифест: что копировать для Cursor
├── claude.json      # Манифест: что копировать для Claude Code
└── opencode.json    # Манифест: что копировать для OpenCode

scripts/
└── init-project.sh  # Инициализация нового проекта (читает манифесты)

CLAUDE.md            # Инструкции для Claude Code
AGENTS.md            # Инструкции для OpenCode
.mcp.json            # MCP-серверы (Claude Code)
opencode.json        # Конфигурация OpenCode + MCP-серверы
```

## Ключевые принципы

1. **MCP-first** — templatesearch → search_metadata → docsearch перед написанием кода
2. **Антипаттерны** — избегать запросов в циклах, точечной нотации, избыточных серверных вызовов
3. **БСП** — использовать `ОбщегоНазначения`, `СтроковыеФункцииКлиентСервер` вместо написания с нуля
4. **Кросс-платформенность** — команды работают на Linux и Windows с автодетектом
5. **Spec-driven** — читать спеки перед реализацией, создавать proposals для новых фич

## Антипаттерны (критичные)

| Антипаттерн | Решение |
|-------------|---------|
| Запрос в цикле | Batch-запрос с `В (&СписокСсылок)` |
| `Контрагент.ИНН` | `ОбщегоНазначения.ЗначениеРеквизитаОбъекта(...)` |
| Подзапрос в SELECT | JOIN с агрегацией |
| Фильтр WHERE на виртуальной таблице | Параметры виртуальной таблицы |

Полный список: [`rules/anti-patterns.mdc`](.cursor/rules/anti-patterns.mdc)

## Сообщество

- **Основные обсуждения**: [t.me/comol_it_does_matter](https://t.me/comol_it_does_matter)
- **Дополнительные материалы**: [t.me/yellow_ai_vibe](https://t.me/yellow_ai_vibe)
- **MCP-серверы**: [docs.onerpa.ru](https://docs.onerpa.ru/mcp-servery-1c)

## Участие

Делитесь своими правилами, агентами и навыками — присылайте pull request!

---

*Проект развивается. Актуальные спецификации: [`openspec/specs/`](openspec/specs/)*
