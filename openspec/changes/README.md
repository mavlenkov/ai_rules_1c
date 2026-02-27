# Предложения изменений

Структура change proposal:

```text
openspec/changes/<change-id>/
├── proposal.md
├── design.md
├── tasks.md
└── specs/
    └── <capability>/
        └── spec.md
```

Назначение файлов:

- `proposal.md` — зачем изменение и какой ожидаемый эффект.
- `design.md` — ключевые технические решения и ограничения.
- `tasks.md` — пошаговый план реализации и проверки.
- `specs/.../spec.md` — дельта требований относительно baseline-спеки.
