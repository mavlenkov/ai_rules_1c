# Правила и конфигурации Cursor для разработки на 1С

Набор правил, агентов, навыков и команд для эффективной разработки на платформе 1С:Предприятие 8.3 с использованием Cursor IDE и MCP-серверов.

> Полная спецификация проекта: [`openspec/specs/`](openspec/specs/)

## Быстрый старт

1. Скопируйте содержимое репозитория в папку `.cursor` вашего проекта 1С
2. Настройте MCP-серверы: [vibecoding1c.ru](https://vibecoding1c.ru/)
3. Создайте `infobasesettings.md` с подключением к ИБ и URL тестирования
4. Начните работу с агентами: `@1c-developer`, `@1c-architect` и др.

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
├── agents/          # 12 AI-агентов
├── rules/           # 11 правил (2 always-applied, 9 context-dependent)
├── skills/          # Навыки (1c-metadata-manage + утилиты)
└── commands/        # 2 команды (deploy + dump)

openspec/
├── specs/           # Спецификации capabilities (source of truth)
└── changes/         # Change proposals
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
- **MCP-серверы**: [vibecoding1c.ru](https://vibecoding1c.ru/)

## Участие

Делитесь своими правилами, агентами и навыками — присылайте pull request!

---

*Проект развивается. Актуальные спецификации: [`openspec/specs/`](openspec/specs/)*
