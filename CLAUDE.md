# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agentic software engineering toolkit for 1C Enterprise platform. Rules, agents, skills, and commands for **Cursor IDE**, **Claude Code**, and **OpenCode**.

**Primary Language:** Russian (code and documentation)
**Platform:** 1C:Enterprise 8.3.27
**MCP Servers:** https://docs.onerpa.ru/mcp-servery-1c

## Multi-Tool Support

| Tool | Config | MCP Servers | Rules/Instructions |
|------|--------|-------------|-------------------|
| **Cursor IDE** | `.cursor/mcp.json` | URL-based | `.cursor/rules/*.mdc`, `.cursor/agents/*.md` |
| **Claude Code** | `.mcp.json` | URL-based | `CLAUDE.md`, `.claude/settings.json` |
| **OpenCode** | `opencode.json` | Remote type | `AGENTS.md`, `instructions` in config |

## Repository Structure

```
.cursor/
├── agents/           # 12 specialized AI assistants
├── rules/            # 14 coding standards (.mdc format)
├── skills/           # Deep knowledge (metadata, forms, queries)
├── commands/         # Cross-platform deploy/dump commands
└── mcp.json          # MCP server config (Cursor)

.claude/
└── settings.json     # Claude Code project settings

openspec/
├── specs/            # Capability specifications (source of truth)
└── changes/          # Change proposals
```

Root files:
- `CLAUDE.md` — instructions for Claude Code (this file)
- `AGENTS.md` — instructions for OpenCode
- `.mcp.json` — MCP servers for Claude Code
- `opencode.json` — OpenCode config + MCP servers

## MCP Tools

All [MCP servers](https://docs.onerpa.ru/mcp-servery-1c) are configured for all three tools.

| Tool | Purpose |
|------|---------|
| `docsearch` | 1C platform documentation (search by description, hybrid: vector + BM25) |
| `docinfo` | 1C platform documentation (lookup by exact object/method name) |
| `templatesearch` | Code templates and examples |
| `list_templates` | List all templates (id, description) without code |
| `get_template` | Get full template code by ID |
| `add_template` | Save new template (description + code, min 10 chars) |
| `codesearch` | Search in current configuration |
| `search_metadata` / `metadatasearch` | Metadata structure validation |
| `business_search` | Semantic search by description |
| `syntaxcheck` | BSL syntax check (max 3 times per cycle) |
| `check_1c_code` | Technical check: syntax, logic, performance |
| `review_1c_code` | Code review: style, ITS standards, naming |
| `rewrite_1c_code` | AI rewrites code with improvements |
| `modify_1c_code` | Modify/generate code by instruction |
| `ask_1c_ai` | Free-form question to 1С:Напарник |
| `ssl_search` | БСП (SSL) functions |
| `helpsearch` | Metadata object information |
| `search_1c_documentation` | Platform docs for specific version |
| `onec_help` | Platform docs (latest version) |
| `its_help` | ITS knowledge base (returns IDs for `fetch_its`) |
| `fetch_its` | Read full ITS document by ID |
| `diff_1c_documentation_versions` | Compare docs between platform versions |
| `config_help` | Docs for specific configs (ERP, БП, ЗУП, УТ) |
| `vcexecutequery` | Execute 1C query in live database |
| `vcvalidatequery` | Validate 1C query without execution |
| `vcexecutecode` | Execute BSL code in live database |
| `vcloggetlasterror` | Last error from event log |
| `remember` | Save a note to long-term memory (decisions, fixes, facts) |
| `recall` | Semantic search over saved notes |

**Workflow:**
1. `templatesearch` → find examples before writing
2. `search_metadata` → validate metadata
3. `docinfo` → verify built-in functions by exact name; `docsearch` → search by description
4. `codesearch` → find existing patterns
5. `ssl_search` → find БСП functions
6. Write code
7. `syntaxcheck` → check syntax (max 3 iterations)
8. `check_1c_code` → analyze logic/performance
9. `review_1c_code` → verify style and standards

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
| **metadata-manager** | Metadata objects creation/editing |

## Critical Anti-Patterns

| Anti-Pattern | Severity | Solution |
|--------------|----------|----------|
| Query in loop | CRITICAL | Use `В (&СписокСсылок)` |
| Dot notation (`Контрагент.ИНН`) | CRITICAL | Use `ОбщегоНазначения.ЗначенияРеквизитовОбъекта` |
| Subquery in SELECT | CRITICAL | Use JOIN with aggregation |
| Virtual table filter in WHERE | HIGH | Use virtual table parameters |
| Multiple server calls | HIGH | Combine into single `&НаСервереБезКонтекста` |
| `&НаСервере` without context need | HIGH | Use `&НаСервереБезКонтекста` |

## Coding Guidelines

**Restrictions:**
- No `Попытка...Исключение` for DB operations without justification
- No `ЗаписьЖурналаРегистрации()` unless explicitly asked
- Use `ОбщегоНазначения.СообщитьПользователю` instead of `Сообщить()`
- No ternary operators `?(Условие, Да, Нет)`
- No Hungarian notation (`МассивКонтрагентов` → `Контрагенты`)
- No global context names for variables (`Документы`, `Справочники`, `Метаданные`)
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

1. **Clarify Scope** — plan before coding
2. **Locate Exact Point** — identify files/lines
3. **Minimal Changes** — no scope creep
4. **Double Check** — verify correctness
5. **Deliver Clearly** — summarize with paths

## Deployment Commands

Cross-platform (Linux/Windows), auto-detect OS and platform version.
Support both file (`/F`) and server (`/S`) infobases.

```bash
# Load config to infobase (Linux example)
<V8_PATH> DESIGNER <IB_CONNECTION> /DisableStartupMessages /LoadConfigFromFiles <repo> /Out <log>

# Update database structure
<V8_PATH> DESIGNER <IB_CONNECTION> /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out <log>
```

## Specifications

Full project specifications: `openspec/specs/`
