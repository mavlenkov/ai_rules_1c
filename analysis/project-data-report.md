# ai_rules_1c — проект-датасет (снимок данных)

- Сгенерировано: 2026-08-19T10:45:11.872190+00:00
- Ветка: `main` @ `97cd3c2` (97cd3c29de349955c0ae4a36613bf5782b18331f)
- Коммитов: 109; период: 2025-08-31 → 2026-08-12
- Рабочее дерево: ЕСТЬ ИЗМЕНЕНИЯ; отслеживаемых файлов: 289

## Удалённые репозитории
- `mavlenkov	git@github.com:mavlenkov/ai_rules_1c.git (fetch)`
- `mavlenkov	git@github.com:mavlenkov/ai_rules_1c.git (push)`
- `origin	https://github.com/comol/ai_rules_1c.git (fetch)`
- `origin	https://github.com/comol/ai_rules_1c.git (push)`

## Git-ветки
- backup/pre-v4-merge-20260525
-   codex/merge-upstream-20260812
-   feat/multi-client-routing
-   fix/opencode-tools-frontmatter
- * main
-   migration/v2-ai-rules
-   remotes/mavlenkov/HEAD -> mavlenkov/main
-   remotes/mavlenkov/codex/merge-upstream-20260812
-   remotes/mavlenkov/cursor/development-environment-setup-8572
-   remotes/mavlenkov/feat/multi-client-routing
-   remotes/mavlenkov/fix/opencode-tools-frontmatter
-   remotes/mavlenkov/main
-   remotes/origin/HEAD -> origin/main
-   remotes/origin/main

## Авторы (shortlog)
```
37	Oleg Philippov <comol@mail.ru>
    33	mavlenkov <23328420+mavlenkov@users.noreply.github.com>
    24	filippov.o <comol@mail.ru>
    10	comol <56004685+comol@users.noreply.github.com>
     2	Andrey Lebedev <36698670+permblackshark@users.noreply.github.com>
     1	Roman Starchenko <roman_starch@mail.ru>
     1	Vladimir <33487200+Eraserhp@users.noreply.github.com>
     1	permblackshark <36698670+permblackshark@users.noreply.github.com>
```

## Последние 25 коммитов
```
97cd3c2|2026-08-12 14:52:50 +0300|mavlenkov|feat(kimi): добавить OpenSpec skills bundle
091a139|2026-08-12 14:34:20 +0300|mavlenkov|Merge upstream comol/ai_rules_1c through 410951e
636b566|2026-08-08 07:32:57 +0300|mavlenkov|fix(mcp): сохранять проектный хост серверов при обновлении
eee8a4e|2026-08-07 19:35:32 +0300|mavlenkov|fix(koda): привести адаптер к фактическому контракту Koda CLI
4561f00|2026-08-07 19:17:02 +0300|mavlenkov|feat(koda): полная поддержка Koda CLI — адаптер, конвертация агентов, MCP setup
410951e|2026-08-01 03:43:07 +0300|Oleg Philippov|fix(rules): ПродолжитьВызов только для &Вместо, не для &ИзменениеИКонтроль
5f3d3f0|2026-07-31 15:36:05 +0300|Oleg Philippov|Правила и metadata-manage: профили моделей, UI-тесты, support/XDTO/UUID, CI
10cb524|2026-07-30 13:57:20 +0300|mavlenkov|fix(metadata-manage): platform note про pwsh на Linux (fork) + FORK-TODO п.14 (OpenSpec schema, pwsh 7.6.4)
4268831|2026-07-30 13:35:45 +0300|mavlenkov|docs(FORK-TODO): раскатка kimi-канала в 9 проектов
b343605|2026-07-30 13:30:51 +0300|mavlenkov|feat(install.sh): поддержка kimi — детект, rulesDir-приоритет, help; generic-пути без изменений
25108bd|2026-07-29 18:41:46 +0300|mavlenkov|feat(install.sh): поддержка codex — rebuild-toml агенты, TOML MCP, user-scope команды, детект по .codex/
ed54032|2026-07-27 14:27:34 +0300|mavlenkov|docs: форк-секция .dev.env 3 → 5 в AGENTS.md и deploy-командах (после ре-нумерации upstream)
9ecdb3c|2026-07-27 14:02:09 +0300|mavlenkov|Merge upstream comol/ai_rules_1c (7266528..5ae333e) в форк
5ae333e|2026-07-25 21:50:32 +0300|Oleg Philippov|fix(opencode): hard gate against tools array in agent frontmatter
1b6e2ed|2026-07-24 15:46:46 +0300|Oleg Philippov|fix(claude-code): on-demand rules в .claude/rules-1c вместо автозагружаемой .claude/rules/
f33d240|2026-07-23 03:39:42 +0300|Oleg Philippov|Усиление правил: hard gate metadata-manage, platform-first, MCP-first search
369d51a|2026-07-21 11:58:27 +0300|mavlenkov|feat(install.sh): OpenCode MCP — нормализация ключей, строгая схема, merge, legacy-очистка
4f59dad|2026-07-20 22:15:12 +0300|mavlenkov|Merge upstream comol/ai_rules_1c (a421cf4..7266528) в форк
7266528|2026-07-19 23:44:08 +0300|Oleg Philippov|Add adapters for Qwen, Command Code, Cline, and Pi.
525be79|2026-07-19 20:28:01 +0300|Oleg Philippov|Add Kimi Code adapter
b4d9875|2026-07-16 04:09:44 +0300|Oleg Philippov|fix(install): kilocode ставит одну папку .kilo вместо .kilo + .kilocode
01d39ed|2026-07-16 00:18:39 +0300|Oleg Philippov|Скилл caveman: переключение через .dev.env (CAVEMAN) и команда /caveman
dc8cca4|2026-07-15 23:54:03 +0300|Oleg Philippov|Реструктуризация правил: разделение dev-standards и verification, новые команды
6f2c35d|2026-06-29 22:29:04 +0300|mavlenkov|fix(rules): correct transaction method НачалоТранзакции -> НачатьТранзакцию
07ce6d1|2026-06-29 22:29:04 +0300|mavlenkov|docs(rules): require delegating full-cycle /opsx:apply implementation to a coding-tier subagent
```

## content/ — объёмы

| Каталог | Файлов | Строк | Байт |
|---|---|---|---|
| rules | 44 | 5930 | 450112 |
| agents | 13 | 2414 | 116626 |
| commands | 19 | 3076 | 204593 |
| skills | 10 | 1172 | 68487 |

## content/rules

| Файл | Строк | name | description |
|---|---|---|---|
| `rules/anti-patterns.md` | 490 |  | 1C anti-patterns, performance guidelines, and code review scoring |
| `rules/async-methods.md` | 212 |  | 1C asynchronous methods (`Асинх` / `Ждать` / `Обещание`) — patterns and pitfalls |
| `rules/bsp-access-rights.md` | 182 |  | Programmatic work with БСП access-group profiles and rights — `ПрофилиГруппДосту |
| `rules/coding-standards.md` | 75 |  | Coding standards — forbidden constructs, comments, code review, module regions,  |
| `rules/dcs-advanced-composition.md` | 155 |  | Advanced programmatic composition in СКД — two-pass preprocessing of detail reco |
| `rules/dcs-design.md` | 134 |  | 1C Data Composition System (СКД / DCS) design rules — data sets, computed fields |
| `rules/dev-standards-architecture.md` | 228 |  | Development standards — architecture patterns, extensions, platform standards, c |
| `rules/dev-standards-change-markers.md` | 82 |  | Modification markers and metadata naming — typical-code change banners, new-obje |
| `rules/dev-standards-code-style.md` | 174 |  | BSL code style — formatting, quality metrics, forbidden constructs, naming, publ |
| `rules/dev-standards-core.md` | 153 |  | Router for development standards — directs project parameters, BSL style, and mo |
| `rules/dev-standards-env.md` | 174 |  | Project and process parameters from .dev.env — code generation, infobase operati |
| `rules/extension-patterns.md` | 197 |  | 1C configuration extension (CFE) patterns — interceptor types (`&Перед` / `&Посл |
| `rules/external-review.md` | 68 |  | Automatic external critic (Codex) at the verification gate — trigger, per-client |
| `rules/form-module.md` | 93 |  | Form-module code (`Form.Module.bsl` / ФормаМодуль) — client-server interaction,  |
| `rules/form-patterns.md` | 215 |  | Managed-form layout patterns — archetypes (document, data processor, list, catal |
| `rules/forms-add.md` | 64 |  | Generating or significantly altering a managed 1C form (`Form.xml` + `Form.Modul |
| `rules/forms.md` | 28 |  | Entry point for managed-form work — pick the exact companion rules for `Form.xml |
| `rules/getconfigfiles.md` | 64 |  | Exporting configuration objects (metadata) from an infobase to the repository —  |
| `rules/integrations-add.md` | 57 |  | when writing code that integrates 1C with another system (HTTP services, REST, m |
| `rules/locks-and-transactions.md` | 221 |  | Managed locks, transaction boundaries, lock ordering, deadlock prevention, share |
| `rules/logging-strategy.md` | 144 |  | Positive logging strategy for 1C — when to write to the event log, which severit |
| `rules/mcp-first-search.md` | 106 |  | MCP-first search discipline — bounded priority of MCP project-index tools over n |
| `rules/metadata-xml-workarounds.md` | 85 |  | Common XML generation pitfalls for 1C metadata and managed forms (`TabularSectio |
| `rules/model-adaptation.md` | 87 |  | Active-model adaptation — how AGENT_MODEL in .dev.env selects a model profile (o |
| `rules/model-fable5.md` | 89 |  | Model profile for Claude Fable 5 / Mythos 5 (AGENT_MODEL=fable5) — act instead o |
| `rules/model-gpt56.md` | 59 |  | Model profile for GPT-5.6 (AGENT_MODEL=gpt56) — lean context and each instructio |
| `rules/model-opus5.md` | 67 |  | Model profile for Claude Opus 5 (AGENT_MODEL=opus5) — verbosity and report shape |
| `rules/model-sonnet5.md` | 57 |  | Model profile for Claude Sonnet 5 (AGENT_MODEL=sonnet5) — literal instruction fo |
| `rules/module-structure.md` | 85 |  | Canonical region templates for common modules, object / manager modules, and for |
| `rules/orchestrator-economy.md` | 67 |  | Orchestrator economy mode — while ORCHESTRATION=economy in .dev.env (toggled by  |
| `rules/platform-solutions.md` | 352 |  | Case book of common 1C platform pitfalls and proven fix templates |
| `rules/query-design.md` | 48 |  | Entry point for 1C query work — pick the exact companion rules and skill docs fo |
| `rules/registers-design.md` | 98 |  | Designing 1C registers — dimensions, resources, attributes, periodicity, indexes |
| `rules/sdd-integrations.md` | 215 |  | OpenSpec integration. Load when working with the openspec/ workspace (specs and  |
| `rules/subagent-pipeline.md` | 246 |  | Formalized subagent pipeline for delegated full-cycle 1C changes — planner → dev |
| `rules/subagents.md` | 190 |  | Subagent catalog — when to delegate to a specialized subagent vs. execute direct |
| `rules/systematic-debugging.md` | 160 |  | Systematic 4-phase debugging methodology adapted for 1C (reproduce → hypothesize |
| `rules/tooling-playbooks.md` | 171 |  | Per-task MCP tool playbooks (writing code, review, refactoring — including the s |
| `rules/ui-testing-tools.md` | 75 |  | Preferred tooling for 1C UI testing — agent-browser for web (token-efficient), W |
| `rules/verification-checklist.md` | 93 |  | Router for 1C verification — directs triage, hard gates, and delivery checks to  |
| `rules/verification-delivery.md` | 78 |  | Verification delivery gates — reproduction, plan adherence, explicit review, UI  |
| `rules/verification-gates.md` | 115 |  | Verification execution gates for BSL and metadata — evidence reuse, syntax, logi |
| `rules/verification-policy.md` | 64 |  | Verification policy — depth levels, quick-fix eligibility, promotion triggers, a |
| `rules/web-client-driving.md` | 113 |  | Driving the 1C web client during UI tests — what the accessibility snapshot show |

## content/agents

| Файл | Строк | name | description |
|---|---|---|---|
| `agents/analytic.md` | 189 | 1c-analytic | Expert 1C business analyst agent. Analyzes existing code and metadata structure, |
| `agents/arch-reviewer.md` | 233 | 1c-arch-reviewer | Expert 1C architecture reviewer agent. Reviews architectural decisions, evaluate |
| `agents/architect.md` | 180 | 1c-architect | Expert 1C solution architect agent. Designs architecture for complex 1C modifica |
| `agents/code-reviewer.md` | 194 | 1c-code-reviewer | Expert 1C code reviewer agent. Reviews code for bugs, readability, standards com |
| `agents/developer.md` | 121 | 1c-developer | Expert 1C code developer agent. Creates modules, procedures, functions, queries, |
| `agents/doc-writer.md` | 224 | 1c-doc-writer | Expert 1C documentation specialist for end-user and administrator documentation. |
| `agents/error-fixer.md` | 174 | 1c-error-fixer | Expert 1C error resolution specialist. Fixes syntax errors, runtime errors, and  |
| `agents/explorer.md` | 151 | 1c-explorer | Read-only 1C codebase exploration specialist — the project's ONLY exploration su |
| `agents/metadata-manager.md` | 128 | 1c-metadata-manager | 1C metadata management specialist. Creates, edits, validates, and removes config |
| `agents/performance-optimizer.md` | 173 | 1c-performance-optimizer | Expert 1C performance optimization specialist. Analyzes code for performance iss |
| `agents/planner.md` | 232 | 1c-planner | Expert 1C planning specialist. Creates comprehensive, actionable implementation  |
| `agents/refactoring.md` | 203 | 1c-refactoring | Expert 1C code refactoring specialist. Focuses on dead code cleanup, code consol |
| `agents/tester.md` | 212 | 1c-tester | Expert 1C testing agent. Tests code and functions using web browser automation a |

## content/commands

| Файл | Строк | name | description |
|---|---|---|---|
| `commands/caveman.md` | 48 |  | Toggle the caveman communication style — set CAVEMAN (on/auto/off) in .dev.env f |
| `commands/check-uuid.md` | 44 |  | Check a 1C XML configuration dump for duplicate UUIDs, and optionally regenerate |
| `commands/checkmcp.md` | 315 |  | Check availability of 1C MCP servers and install/start the missing ones |
| `commands/dataprocessors.md` | 177 |  | Операции с внешними обработками и отчётами EPF/ERF (Linux + 1CFilesConverter) |
| `commands/deploy-and-test.md` | 334 |  | Развёртывание конфигурации/расширения в ИБ и веб-тестирование (Linux, 1CFilesCon |
| `commands/doctor.md` | 180 |  | Diagnose whether 1c-rules is installed, connected, configured, and usable by the |
| `commands/economymode.md` | 89 |  | Toggle orchestrator economy mode via ORCHESTRATION in .dev.env; on enable, offer |
| `commands/evolve.md` | 92 |  | Aggregate accumulated rule-friction signals into user-approved behavior rules in |
| `commands/extensions.md` | 178 |  |  |
| `commands/getconfigfiles.md` | 137 |  | Выгрузка объектов конфигурации/расширения из ИБ в файлы (Linux + 1CFilesConverte |
| `commands/install-agent-browser.md` | 148 |  | Install agent-browser (token-efficient headless browser CLI + MCP) for 1C web UI |
| `commands/install-windows-mcp.md` | 145 |  | Install Windows-MCP (desktop UI automation MCP) as a last-resort alternative to  |
| `commands/installmcp.md` | 418 |  | Download the 1C MCP server distribution from vibecoding1c.ru and install all ser |
| `commands/litemode.md` | 59 |  | Toggle lightweight QA mode — set VERIFICATION_DEPTH (full/standard/lite) in .dev |
| `commands/loadfrom1cbase.md` | 119 |  | Dump the configuration from the infobase defined in .dev.env into the current re |
| `commands/rulesmodel.md` | 62 |  | Adapt the ruleset to the model that is actually running — normalize a free-form  |
| `commands/update1cbase.md` | 132 |  | Load current repository files into the infobase defined in .dev.env and update t |
| `commands/updatemcp.md` | 299 |  | Re-download the 1C MCP server distribution from vibecoding1c.ru, pull new images |
| `commands/updaterules.md` | 100 |  | Update the 1c-rules ruleset from GitHub (fork mavlenkov/ai_rules_1c) |

## content/skills

| Файл | Строк | name | description |
|---|---|---|---|
| `skills/1c-metadata-manage/SKILL.md` | 94 | 1c-metadata-manage | 1C metadata management — create, edit, validate, and remove configuration object |
| `skills/caveman/SKILL.md` | 139 | caveman | Ultra-compressed communication mode. Cuts output tokens ~65–75% by using a terse |
| `skills/handoff/SKILL.md` | 93 | handoff | Compact the current conversation into a self-contained handoff document so a fre |
| `skills/img-grid-analysis/SKILL.md` | 71 | img-grid-analysis | Overlay a numbered grid on an image to determine column proportions for layout g |
| `skills/mcp-1c-tools/SKILL.md` | 87 | mcp-1c-tools | Catalog of MCP servers for 1C development — search, code navigation, metadata, c |
| `skills/md-to-docx/SKILL.md` | 74 | md-to-docx | Convert a Markdown file to DOCX (Word). Use when the user asks to convert .md to |
| `skills/mermaid-diagrams/SKILL.md` | 228 | mermaid-diagrams | Practical guide for creating human-readable and agent-parseable diagrams using M |
| `skills/powershell-windows/SKILL.md` | 109 | powershell-windows | PowerShell scripting rules for Windows environment. Use when running shell comma |
| `skills/prompt-enhancer/SKILL.md` | 126 | prompt-enhancer | Improve and structure short, unstructured prompts and task statements, turning t |
| `skills/v8unpack-cf/SKILL.md` | 151 | v8unpack-cf | Unpack and repack 1C binary files (CF / CFE / EPF) with the Python `v8unpack` ut |

## Адаптеры (12)

- **claude-code** (schemaVersion 1): detection = {'exists': '.claude/'}; {'exists': 'CLAUDE.md'}
  - `rules`: {"copyTo": ".claude/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".claude/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "tools", "modelHint", "isSubagent", "allowParallel"], "rename": {"modelHint": "model"}, "drop": ["reasoningEffort"]}}
  - `commands`: {"copyTo": ".claude/commands/{name}.md", "frontmatter": {"keep": ["description", "argumentHint", "allowedTools"], "rename": {"argumentHint": "argument-hint", "allowedTools": "allowed-tools"}}}
  - `skills`: {"copyTo": ".claude/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".mcp.json", "schema": "mcpServers", "format": "json"}
- **cline** (schemaVersion 1): detection = {'exists': '.cline/'}; {'exists': '.clinerules/'}
  - `rules`: {"copyTo": ".cline/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".cline/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "modelHint"], "rename": {"modelHint": "model"}, "drop": ["tools", "allowParallel", "reasoningEffort", "isSubagent"]}}
  - `skills`: {"copyTo": ".cline/skills/{name}/", "mode": "verbatim"}
- **codex** (schemaVersion 1): detection = {'exists': '.codex/'}; {'exists': 'AGENTS.md'}
  - `rules`: {"copyTo": ".codex/rules/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".codex/agents/{name}.toml", "mode": "rebuild-toml", "template": "name = \"{name}\"\ndescription = \"{description}\"\nmodel = \"{modelHint}\"\nmodel_reasoning_effort = \"{reasoningEffort}\"\ndeveloper_instructions = \"\"\"\n{body}\n\"\"\"\n"}
  - `commands`: {"copyTo": "~/.codex/prompts/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".codex/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".codex/config.toml", "schema": "[mcp_servers.<id>]", "format": "toml"}
- **command-code** (schemaVersion 1): detection = {'exists': '.commandcode/'}
  - `rules`: {"copyTo": ".commandcode/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".commandcode/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "modelHint"], "rename": {"modelHint": "model"}, "drop": ["tools", "allowParallel", "reasoningEffort", "isSubagent"]}}
  - `commands`: {"copyTo": ".commandcode/commands/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".commandcode/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".mcp.json", "schema": "mcpServers-claude", "format": "json"}
- **cursor** (schemaVersion 1): detection = {'exists': '.cursor/'}
  - `rules`: {"copyTo": ".cursor/rules/{name}.mdc", "frontmatter": {"keep": ["description", "globs", "alwaysApply"], "drop": ["category"]}}
  - `agents`: {"copyTo": ".cursor/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "tools", "modelHint", "allowParallel", "isSubagent"], "rename": {"modelHint": "model"}, "drop": ["reasoningEffort"]}}
  - `commands`: {"copyTo": ".cursor/commands/{name}.md", "frontmatter": {"keep": ["description", "argumentHint"], "drop": ["allowedTools"]}}
  - `skills`: {"copyTo": ".cursor/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".cursor/mcp.json", "schema": "mcpServers", "format": "json"}
- **kilocode** (schemaVersion 1): detection = {'exists': '.kilo/'}; {'exists': '.kilocode/'}
  - `rules`: {"copyTo": ".kilo/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".kilo/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "modelHint"], "rename": {"modelHint": "model"}, "drop": ["tools", "allowParallel", "reasoningEffort"], "addIf": {"isSubagent": {"mode": "subagent"}, "!isSubagent": {"mode": "all"}}}}
  - `commands`: {"copyTo": ".kilo/commands/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".kilo/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".kilo/kilo.json", "schema": "kilo-mcp", "format": "json", "merge": true, "legacyTargets": [".kilocode/mcp.json"]}
- **kimi** (schemaVersion 1): detection = {'exists': '.kimi-code/'}; {'exists': '.kimi/'}
  - `rules`: {"copyTo": ".kimi-code/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".kimi-code/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "tools", "modelHint", "isSubagent"], "rename": {"modelHint": "model"}, "drop": ["allowParallel", "reasoningEffort"]}}
  - `skills`: {"copyTo": ".kimi-code/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".kimi-code/mcp.json", "schema": "mcpServers", "format": "json"}
- **koda** (schemaVersion 1): detection = {'exists': '.kodacli/'}; {'exists': '.koda/'}; {'exists': 'KODA.md'}
  - `rules`: {"copyTo": ".koda/rules/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".koda/agents/{name}.md", "frontmatter": {"keep": ["name", "description"], "drop": ["modelTier", "tools", "isSubagent", "allowParallel", "reasoningEffort"]}}
  - `commands`: {"copyTo": ".koda/commands/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".koda/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"target": ".kodacli/mcp-setup.md", "format": "koda-mcp-commands"}
- **opencode** (schemaVersion 1): detection = {'exists': '.opencode/'}; {'exists': 'opencode.json'}
  - `rules`: {"copyTo": ".opencode/rules/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".opencode/agent/{name}.md", "frontmatter": {"toolsToPermission": {"source": "tools", "grant": "allow", "deny": "deny", "map": {"Read": "read", "Write": "edit", "Edit": "edit", "Grep": "grep", "Glob": "glob", "Shell": "bash"}}, "keep": ["name", "description", "modelHint", "permission"], "rename": {"modelHint": "model"}, "addIf": {"isSubagent": {"mode": "subagent"}, "!isSubagent": {"mode": "primary"}}}}
  - `commands`: {"copyTo": ".opencode/command/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".claude/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": "opencode.json", "schema": "mcp[id]={ type: 'remote', url, enabled: true } | { type: 'local', command: [...], enabled: true }", "format": "json", "merge": true, "legacyTargets": [".opencode/opencode.json"], "keyNormalization": "leading-1c-to-onec"}
- **other** (schemaVersion 1): detection = (пусто — other)
  - `rules`: {"copyTo": ".ai-agent/rules/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".ai-agent/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "tools", "modelHint", "isSubagent"], "rename": {"modelHint": "model"}, "drop": ["allowParallel", "reasoningEffort"]}}
  - `commands`: {"copyTo": ".ai-agent/commands/{name}.md", "frontmatter": {"keep": ["description", "argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".ai-agent/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".ai-agent/mcp.json", "schema": "mcpServers", "format": "json"}
- **pi** (schemaVersion 1): detection = {'exists': '.pi/'}
  - `rules`: {"copyTo": ".pi/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `commands`: {"copyTo": ".pi/prompts/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".pi/skills/{name}/", "mode": "verbatim"}
- **qwen** (schemaVersion 1): detection = {'exists': '.qwen/'}; {'exists': 'QWEN.md'}
  - `rules`: {"copyTo": ".qwen/rules-1c/{name}.md", "frontmatter": {"keep": ["description", "alwaysApply"], "drop": ["globs", "category"]}}
  - `agents`: {"copyTo": ".qwen/agents/{name}.md", "frontmatter": {"keep": ["name", "description", "tools", "modelHint", "isSubagent"], "rename": {"modelHint": "model"}, "drop": ["allowParallel", "reasoningEffort"]}}
  - `commands`: {"copyTo": ".qwen/commands/{name}.md", "frontmatter": {"keep": ["description"], "drop": ["argumentHint", "allowedTools"]}}
  - `skills`: {"copyTo": ".qwen/skills/{name}/", "mode": "verbatim"}
  - `mcp`: {"source": "content/mcp-servers.json", "target": ".qwen/settings.json", "schema": "qwen-mcp", "format": "json", "merge": true, "mergeKey": "mcpServers"}

## MCP-серверы

- `1c-code-metadata-mcp` (http http://localhost:8000/mcp) — 1C metadata search, code navigation, forms inspection, XSD schemas and validation
- `1c-syntax-checker-mcp` (http http://localhost:8002/mcp) — BSL syntax validation via BSL Language Server
- `1C-docs-mcp` (http http://localhost:8003/mcp) — 1C platform documentation search (docsearch, docinfo)
- `1c-templates-mcp` (http http://localhost:8004/mcp) — Code templates library and implementation examples search
- `1c-graph-metadata-mcp` (http http://localhost:8006/mcp) — Graph-based metadata queries and impact analysis (Neo4j / Cypher)
- `1c-code-check-mcp` (http http://localhost:8007/mcp) — 1C code review and quality checking (1С:Напарник) — check_1c_code, review_1c_code, ITS doc
- `1c-ssl-mcp` (http http://localhost:8008/mcp) — Standard Subsystems Library (БСП / SSL) function search
- `1c-data-mcp` (http {INFOBASE_PUBLISH_URL}/hs/mcp) — 1C data management and analysis (HTTP service published on the infobase; URL is derived fr

## OpenSpec

- specs: ['openspec/specs/README.md', 'openspec/specs/external-review/spec.md', 'openspec/specs/subagent-model-routing/spec.md']
- archived changes: ['openspec/changes/archive/2026-06-29-multi-client-routing/design.md', 'openspec/changes/archive/2026-06-29-multi-client-routing/proposal.md', 'openspec/changes/archive/2026-06-29-multi-client-routing/tasks.md', 'openspec/changes/archive/2026-06-29-multi-client-routing/specs/external-review/spec.md', 'openspec/changes/archive/2026-06-29-multi-client-routing/specs/subagent-model-routing/spec.md']

## FORK-TODO.md — пункты

- ## После мержа upstream (2026-07-27, upstream `5ae333e`)
- ## После мержа upstream (2026-06-27, upstream `a421cf4`)
- ## После мержа upstream «версия 4» (2026-05-25, upstream `5b246bc`)

## AGENTS.md — секции

- ## Persona
- ## Core Principles
- ## Active model adaptation
- ## Development Procedure
- ## Project info
- ## MCP Tool Calling
- ## Coding Standards
- ## Skills and Subagents
- ## Project memory
- ## Rules self-improvement (`/evolve` + `LLM-RULES.md`)
- ## Editing discipline
- ## Development standards
- ## Model adaptation
- ## Subagents
- ## Forms
- ## Tooling
- ## Workflow and integrations
- ## Metadata
- ## Quality

- Упоминаний правил `content/rules/*.md` в AGENTS.md: 15

### Индекс '# Additional rules (load on demand)'

- `coding-standards`
- `dev-standards-core`
- `dev-standards-env`
- `dev-standards-code-style`
- `dev-standards-change-markers`
- `dev-standards-architecture`
- `module-structure`
- `extension-patterns`
- `dcs-design`
- `dcs-advanced-composition`
- `bsp-access-rights`
- `registers-design`
- `query-design`
- `logging-strategy`
- `locks-and-transactions`
- `model-adaptation`
- `model-opus5`
- `subagents`
- `subagent-pipeline`
- `orchestrator-economy`
- `forms`
- `forms-add`
- `form-patterns`
- `form-module`
- `async-methods`
- `tooling-playbooks`
- `mcp-first-search`
- `ui-testing-tools`
- `web-client-driving`
- `getconfigfiles`
- `integrations-add`
- `sdd-integrations`
- `metadata-xml-workarounds`
- `anti-patterns`
- `verification-checklist`
- `verification-policy`
- `verification-gates`
- `verification-delivery`
- `external-review`
- `systematic-debugging`
- `platform-solutions`

## .dev.env.example — разделы

- Раздел 1. Параметры генерации кода (всегда обязательны для задач генерации)
- Section 1. Code-generation parameters (mandatory for code-generation tasks)
- Раздел 2. Параметры подключения к информационной базе (для команд и тестов)
- Section 2. Infobase connection parameters (for commands and tests)
- Раздел 3. Модель головного агента, модели субагентов и режим оркестрации
- Section 3. Parent-agent model, subagent models and orchestration mode
- Раздел 4. Параметры процесса разработки (триаж и отладка)
- Section 4. Development-process parameters (triage and debugging)
- Раздел 5. Linux + 1CFilesConverter (ТОЛЬКО форк mavlenkov/ai_rules_1c)
- Section 5. Linux + 1CFilesConverter (FORK-ONLY: mavlenkov/ai_rules_1c)

## Находки по качеству данных

- **frontmatter-parse-error**: `content/commands/extensions.md` — mapping values are not allowed here
  in "<unicode string>", line 1, column 40:
     ... tion: Операции с расширениями 1С: загрузка, выгрузка, сборка CFE ... 
                                         ^
- **command-without-description**: `content/commands/extensions.md` — 

## OpenSpec bundle

- tools: claude-code, codex, cursor, kilocode, kimi, opencode
- версия: 1.4.1
