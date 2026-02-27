# OpenSpec в проекте

Эта директория содержит артефакты Spec-Driven Development (SDD):

- `specs/` — актуальные спецификации возможностей (source of truth).
- `changes/` — предложения изменений (change proposals).

## Быстрый старт

1. Для новой возможности создайте `openspec/specs/<capability>/spec.md`.
2. Для изменения существующей логики создайте `openspec/changes/<change-id>/`:
   - `proposal.md`
   - `design.md` (если есть архитектурные решения)
   - `tasks.md`
   - `specs/<capability>/spec.md` (дельта к спецификации)
3. После реализации перенесите финальные требования в `openspec/specs/`.

## Базовый формат спецификации

```markdown
# <capability> Specification

## Purpose
<Зачем нужна возможность>

## Requirements

### Requirement: <Название требования>
<Описание требования>

#### Scenario: <Название сценария>
- GIVEN <предусловие>
- WHEN <действие>
- THEN <ожидаемый результат>
```
