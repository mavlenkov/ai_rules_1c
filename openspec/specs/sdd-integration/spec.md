# SDD Integration Specification

## Purpose
Обеспечить поддержку spec-driven development через интеграцию с OpenSpec, Memory Bank, Spec Kit и TaskMaster.

## Requirements

### Requirement: Автоматическая детекция SDD-фреймворков
Агенты должны определять наличие SDD-фреймворков в проекте.

#### Scenario: Детекция OpenSpec
- GIVEN в проекте есть папка `openspec/specs/`
- WHEN агент начинает работу
- THEN он читает `rules/sdd-integrations.mdc` и следует OpenSpec workflow

#### Scenario: Детекция Memory Bank
- GIVEN в проекте есть папка `memory-bank/`
- WHEN агент начинает работу
- THEN он читает контекст из `tasks.md`, `activeContext.md`, `progress.md`

### Requirement: OpenSpec workflow
Агенты должны следовать процессу работы с OpenSpec.

#### Scenario: Чтение существующих спецификаций
- GIVEN реализуется функциональность
- WHEN агент проверяет `openspec/specs/`
- THEN находит релевантные требования и сценарии

#### Scenario: Создание change proposal
- GIVEN новая фича
- WHEN агент создаёт proposal в `openspec/changes/<change-id>/`
- THEN создаются файлы: proposal.md, design.md, tasks.md, specs/

#### Scenario: Обновление спецификаций
- GIVEN реализация завершена
- WHEN агент обновляет затронутые specs
- THEN дельты переносятся из changes в baseline specs

### Requirement: Memory Bank workflow
Агенты должны использовать Memory Bank для управления контекстом.

#### Scenario: Чтение контекста перед работой
- GIVEN Memory Bank присутствует
- WHEN агент начинает задачу
- THEN читает `memory-bank/tasks.md` и `activeContext.md`

#### Scenario: Обновление прогресса
- GIVEN задача выполнена
- WHEN агент завершает шаг
- THEN обновляет `memory-bank/progress.md`

### Requirement: Spec Kit constraints
Агенты должны следовать архитектурным ограничениям из Spec Kit.

#### Scenario: Проверка boundaries
- GIVEN изменение затрагивает архитектуру
- WHEN агент проверяет `boundaries.md`
- THEN убеждается, что изменение в рамках scope системы

#### Scenario: Использование glossary
- GIVEN пишется документация или код
- WHEN агент обращается к `glossary.md`
- THEN использует согласованную терминологию

### Requirement: TaskMaster integration
Агенты должны работать с TaskMaster MCP для управления задачами.

#### Scenario: Получение следующей задачи
- GIVEN TaskMaster доступен
- WHEN агент вызывает `next_task`
- THEN получает приоритетную задачу для работы

#### Scenario: Обновление статуса задачи
- GIVEN задача выполнена
- WHEN агент вызывает `set_task_status` с `done`
- THEN статус обновляется в `.taskmaster/tasks/tasks.json`

## SDD Frameworks

| Фреймворк | Тип | Детекция | Назначение |
|-----------|-----|----------|------------|
| **OpenSpec** | Файловый | `openspec/specs/` | Спецификации и change proposals |
| **Memory Bank** | Файловый | `memory-bank/` | Управление контекстом через файлы |
| **Spec Kit** | Файловый | `spec.md`, `constitution.md`, `boundaries.md`, `glossary.md` | Архитектурные ограничения |
| **TaskMaster** | MCP | MCP-сервер `user-task-master-ai` | AI-управление задачами |

## Priority Order

Когда несколько фреймворков присутствуют:
1. TaskMaster — для трекинга задач
2. OpenSpec — для управления спецификациями
3. Spec Kit — для архитектурных ограничений
4. Memory Bank — для workflow и контекста

## Agent-Specific Usage

| Агент | OpenSpec | Memory Bank | Spec Kit | TaskMaster |
|-------|----------|-------------|----------|------------|
| analytic | Создаёт/обновляет specs | Пишет PRD | Обновляет spec.md | — |
| planner | Читает specs, создаёт tasks.md | Использует `/plan`, обновляет tasks.md | — | `expand_task` |
| architect | Пишет design.md | Использует `/creative` | Следует constitution.md | — |
| developer | Читает specs, реализует | Обновляет progress.md | Использует glossary.md | `set_task_status` |
| metadata-manager | Создаёт spec deltas | Обновляет progress.md | — | `set_task_status` |
| code-reviewer | Проверяет против specs | Документирует в progress.md | Проверяет constitution.md | `update_subtask` |
