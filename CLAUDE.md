# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains rules, agents, skills, and commands for AI-assisted 1C Enterprise platform development using Cursor IDE. It is designed to be placed in the `.cursor` folder of a 1C project.

**Primary Language:** Russian (code and documentation)
**Platform:** 1C:Enterprise 8.3.27
**MCP Servers:** https://vibecoding1c.ru/

## Repository Structure

```
.cursor/
├── agents/           # Specialized AI assistants (11 agents)
├── rules/            # Standards and guidelines (.mdc format)
├── skills/           # Deep knowledge on specific topics
├── commands/         # Deployment and config extraction
└── mcp.json          # MCP server configurations
```

## Agents

| Agent | Purpose |
|-------|---------|
| **developer** | Main coding agent with MCP tools and self-review |
| **architect** | Solution architecture design |
| **analytic** | Business analysis, PRD, specifications (no code) |
| **code-reviewer** | Code review with confidence scoring |
| **arch-reviewer** | Architecture review |
| **error-fixer** | Error fixing |
| **refactoring** | Refactoring with preserved functionality |
| **performance-optimizer** | Performance optimization |
| **doc-writer** | Technical documentation |
| **planner** | Task planning and decomposition |
| **tester** | Test development |

## Rules

**Always applied:**
- `project_rules.mdc` — 1C coding standards, MCP tool usage, query guidelines
- `user_rules.mdc` — step-by-step approach, minimal changes

**Context-dependent:**
- `anti-patterns.mdc` — catalog of anti-patterns with examples
- `mcp-tools.mdc` — MCP tools reference
- `sdd-integrations.mdc` — SDD framework integrations (Memory Bank, OpenSpec, Spec Kit, TaskMaster)
- `form_module_rules.mdc` — form module directives
- `forms_add.mdc`, `forms_events_add.mdc` — form generation

## Skills

- **1c-query-optimization** — query optimization patterns (temp tables, JOINs, virtual table parameters)
- **1c-ssl-patterns** — БСП patterns (users, files, print forms, background jobs)

## MCP Tools

| Tool | Purpose |
|------|---------|
| `docsearch` | 1C platform documentation |
| `templatesearch` | Code templates and examples |
| `codesearch` | Search in current configuration |
| `search_metadata` | Metadata structure validation |
| `business_search` | Semantic search by description |
| `syntaxcheck` | BSL syntax check (max 3 times per cycle) |
| `check_1c_code` | Logic and performance analysis |
| `ssl_search` | БСП (SSL) functions |
| `helpsearch` | Metadata object information |

## Deployment Commands

Located in `.cursor/commands/deploy_and_test.md`:

```bash
# Load config to infobase (Linux)
/opt/1cv8/x86_64/8.3.27.1859/1cv8 DESIGNER /F '<path>' /DisableStartupMessages /LoadConfigFromFiles <repo> /Out <log>

# Update database structure
/opt/1cv8/x86_64/8.3.27.1859/1cv8 DESIGNER /F '<path>' /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <log>
```

## Critical Anti-Patterns

From `anti-patterns.mdc` — must avoid:

| Anti-Pattern | Severity | Solution |
|--------------|----------|----------|
| Query in loop | CRITICAL | Use `В (&СписокСсылок)` |
| Dot notation (`Контрагент.ИНН`) | CRITICAL | Use `ОбщегоНазначения.ЗначенияРеквизитовОбъекта` |
| Subquery in SELECT | CRITICAL | Use JOIN with aggregation |
| Virtual table filter in WHERE | HIGH | Use virtual table parameters |
| Multiple server calls | HIGH | Combine into single `&НаСервереБезКонтекста` |
| `&НаСервере` without context need | HIGH | Use `&НаСервереБезКонтекста` |

## Coding Guidelines

**Tool workflow:**
1. `templatesearch` → find examples before writing
2. `search_metadata` → validate metadata
3. `docsearch` → verify built-in functions
4. Write code
5. `syntaxcheck` → check syntax (max 3 iterations)
6. `check_1c_code` → analyze logic/performance

**Restrictions:**
- No `Попытка...Исключение` for DB operations
- No `ЗаписьЖурналаРегистрации()` unless asked
- Use `ОбщегоНазначения.СообщитьПользователю` instead of `Сообщить()`
- No ternary operators `?(Условие, Да, Нет)`
- No Hungarian notation (`МассивКонтрагентов` → `Контрагенты`)
- Line limit: 120 characters

**Query formatting:**
```bsl
Запрос = Новый Запрос;
Запрос.Текст =
"ВЫБРАТЬ
|	Контрагенты.Ссылка КАК Ссылка
|ИЗ
|	Справочник.Контрагенты КАК Контрагенты";
РезультатЗапроса = Запрос.Выполнить();
```

## Development Procedure

From `user_rules.mdc`:

1. **Clarify Scope** — plan before coding
2. **Locate Exact Point** — identify files/lines
3. **Minimal Changes** — no scope creep
4. **Double Check** — verify correctness
5. **Deliver Clearly** — summarize with paths
