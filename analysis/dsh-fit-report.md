# Пригодность правил ai_rules_1c для DSH

> Анализ сопоставления артефактов `ai_rules_1c` (форк `mavlenkov`, `comol/ai_rules_1c`)
> с DeepSeek Harness (DSH) `@deepseek-ai/dsh@0.1.0-rc.7`.
> Источник фактов о DSH — README пакетов в
> `/home/l7777/.local/share/deepseek-harness/runtime/node_modules/@deepseek-ai/`
> и фактические настройки `$DSH_HOME` (профиль `web`).

## Вывод коротко

Правила **применимы в основном как контент, а не как нативная интеграция**:

| Артефакт | Формат в ai_rules_1c | Как это видит DSH | Пригодность |
|---|---|---|---|
| Always-on правила (`AGENTS.md`) | Markdown в корне | Загружает `AGENTS.md`/`CLAUDE.md` из корня нативно | ⚠️ Частично — **не влезает в бюджет** |
| On-demand правила (`content/rules/*.md`) | Markdown + YAML-frontmatter | Агент читает файл через `read` по команде из AGENTS.md | ✅ Хорошо (ленивая загрузка совпадает с моделью DSH) |
| Скиллы (`content/skills/*/SKILL.md`) | Anthropic SKILL.md | `.agents/skills/` / `.dsh/skills/` авто-обнаружение | ✅ Почти нативно |
| Субагенты (`content/agents/*.md`) | Markdown-роли с `tools`/`modelTier` | Только prompt-вызов `subagent`, не файлы | ⚠️ Частично (переиспользуемы как промпты/персоны) |
| Команды (`content/commands/*.md`) | Markdown-процедуры | Слэш-команды = JS-плагины, не markdown | ⚠️ Частично (как процедурные доки — да, как `/cmd` — нужен плагин) |
| MCP-каталог (`mcp-servers.json`) | 8 HTTP-серверов | MCP = плагины `cordis.yml`, `streamable-http` | ⚠️ Частично (ручная настройка + префиксация имён) |
| Модели/`.dev.env` | env-параметры, профили моделей | Свой конфиг (`settings.yaml`, `agent-default-model`) | ❌ Не применимо напрямую |
| Установщики/адаптеры (`install.*`, `adapters/*.yaml`) | PowerShell/Python/YAML | Нет аналога (профили Cordis) | ❌ Нужен отдельный DSH-адаптер |

**Общая оценка: правила «о 1С-разработке» переносятся хорошо (это просто Markdown); «инфраструктура» набора (адаптеры, установщики, MCP-автоконфиг, model-tier роутинг) в DSH не применима и требует собственного слоя интеграции.**

---

## 1. Что DSH умеет (проверено по исходникам)

### 1.1 Инструкции (always-on контекст)

Пакет `dsh-agent-instructions`:
- Загружает из `$DSH_HOME/AGENTS.md`, затем из каждой директории от корня проекта (маркер `.git`) до cwd файлы-кандидаты **`AGENTS.md`, `CLAUDE.md`** и локальные оверлеи **`AGENTS.local.md`, `CLAUDE.local.md`**.
- **Бюджет `maxBytes: 65536`** задан по умолчанию в `dsh-base/cordis.patch.yml` (строка 235). Рендер «обрезает широкие файлы раньше, чем самый специфичный».
- **Не интерпретирует** `.cursor/rules/`, `.claude/rules/`, `@path`-импорты, lowercase-имена. Только `AGENTS.md`/`CLAUDE.md`.

**Следствие для этого репозитория (подтверждено фактически в текущей сессии):**
`AGENTS.md` = 59 466 байт, `CLAUDE.md` = 9 494 байт. Сумма ≈ 68.9 КБ > 65 536 → **`AGENTS.md` отбрасывается, остаётся только `CLAUDE.md`** (в сессии это и произошло: «Workspace instruction budget 65536 bytes: omitted AGENTS.md»). Т.е. главный always-on документ набора в DSH по умолчанию **не загружается**.

### 1.2 Скиллы

Пакеты `dsh-skill` + `dsh-skill-filesystem`:
- Корни проекта: **`<projectRoot>/.dsh/skills`** (rank 100) и **`<projectRoot>/.agents/skills`** (rank 200); плюс пользовательские `$DSH_HOME/skills`, `~/.agents/skills`.
- Формат: каталог `<name>/SKILL.md` или плоский `<name>.md`. Обнаружение **одноуровневое** (вложенные `**/SKILL.md` игнорируются).
- Frontmatter: обязательные `name` (kebab-case) и `description`; опциональные `whenToUse`, `metadata`, `disable-model-invocation`, `user-invocable`. Лишние поля — «открытый YAML-объект», игнорируются без ошибки.

**Следствие:** все 10 скиллов `content/skills/*/SKILL.md` (`1c-metadata-manage`, `mcp-1c-tools`, `caveman`, `handoff`, …) имеют kebab-case `name` + `description` и переносятся почти без изменений — достаточно скопировать их в `.agents/skills/` (или `.dsh/skills/`) целевого проекта. Вложенные `docs/*.md` и `tools/*.ps1` не мешают: SKILL.md верхнего уровня обнаруживается, ресурсы читаются по относительным путям через `read`.

### 1.3 MCP

Пакет `dsh-mcp-client`:
- MCP-сервер = **один плагин в `cordis.yml`** (не `.mcp.json`, не `mcp-servers.json`, не `.cursor/mcp.json`).
- Транспорты: `stdio` и **`streamable-http`**.
- Инструменты видны модели как **`mcp__<serverName>__<rawName>`**.

**Следствия:**
- 8 HTTP-серверов `content/mcp-servers.json` технически подключаемы (это streamable-http), но только **вручную через `cordis.yml`** — установщики ai_rules_1c этого не генерируют.
- **Несовпадение имён инструментов.** Правила и скилл `mcp-1c-tools` пишут `syntaxcheck`, `check_1c_code`, `templatesearch`, `docsearch`, `ssl_search`, `recall`, `get_module_structure`, `search_code`… В DSH те же инструменты называются `mcp__1c-syntax-checker-mcp__syntaxcheck` и т.д. Текст правил рассчитан на «короткие» имена — потребуется либо переименование в правилах, либо договорённость для агента о маппинге.
- В текущей сессии DSH MCP-инструменты **не подключены** (в списке доступных инструментов нет ни одного `mcp__*`), т.е. сейчас вся «MCP-first» цепочка верификации фактически невыполнима.

### 1.4 Субагенты

Пакеты `dsh-subagent` / `dsh-tool-subagent`:
- Субагент создаётся **вызовом инструмента `subagent`(prompt)** (и `subagent_fork`), а не файлом-ролью.
- Нет авто-обнаружения каталога агентов (аналога `.cursor/agents/`, `.claude/agents/`).
- Запрос может задавать модель, structured output, лимит глубины, фильтр инструментов, **persona** на ребёнка.
- DSH-нативные оркестрационные примитивы: `workflow` (fan-out по JS-сценарию), `ralph` (цикл свежих агентов), `goal` (долгоживущая цель), `subagent` model override.

**Следствие:** 13 агентов `content/agents/*.md` **не подхватываются** как нативные субагенты. Их можно использовать двумя способами:
1. Как **промпты**: родитель читает `content/agents/<name>.md` и передаёт текст в `subagent(prompt=…)` (именно так AGENTS.md набора уже предписывает — «full subagent prompts live in content/agents/»).
2. Как **персоны** (`dsh-persona` — `text`-прокладка в preset) — но это уже конфигурация Cordis, не markdown.

Поля frontmatter агентов (`tools`, `modelTier`, `isSubagent`, `allowParallel`, `modelHint`) в DSH либо игнорируются (файл просто читается как текст), либо требуют ручного переноса в параметры вызова `subagent` (модель, toolFilter).

### 1.5 Слэш-команды

Пакет `dsh-commands`:
- Команды регистрируются **через JS/TS-плагин** (`ctx.commands.register(...)`).
- Авто-обнаружения каталога markdown-команд (аналога `.cursor/commands/`) нет.

**Следствие:** 19 команд `content/commands/*.md` не появятся как `/deploy-and-test` и т.д. сами. Как **процедурные документы** (агент читает и выполняет шаги) — работают. Как нативные `/cmd` — нужен плагин-адаптер.

### 1.6 Модели и `.dev.env`

DSH конфигурируется через `settings.yaml` (`agent-default-model`, `llm-pi-ai.providers.*.models`) и Cordis-пресеты. **`.dev.env` DSH не читает**, переменные `$DSH_*` — его собственные.

**Следствие:** всё, что в ai_rules_1c завязано на `.dev.env` и модельные профили, в DSH не работает:
- `AGENT_MODEL` / `SUBAGENT_MODEL_*` / per-client `__<TOOL>`-override — нет.
- Правила `model-opus5/sonnet5/fable5/gpt56` — про чужие модели (Claude/GPT), к DeepSeek/GLM не применимы.
- Форк-секция «Linux + 1CFilesConverter» (`CONVERTER_PATH`, `DB_SRV_*`, `REMOTE_*`) — параметры читаются форк-командами из `.dev.env`; без него команды деплоя потеряют источник параметров (придётся переносить в env/settings DSH).

---

## 2. Детальный маппинг

### 2.1 Правила (`content/rules/`, 44 файла)

| Аспект | Оценка | Комментарий |
|---|---|---|
| Язык/формат | ✅ | Чистый Markdown, читается любым агентом через `read`. |
| Модель загрузки | ✅ | «on-demand» (агент читает файл по триггеру) совпадает с DSH: DSH не автозагружает каталоги правил, а полагается на явное чтение. |
| Индекс (routing cues) | ⚠️ | Триггеры к загрузке живут в `AGENTS.md → Additional rules`, который в DSH по умолчанию **отбрасывается по бюджету**. |
| Ссылки на инструменты | ❌ | Правила называют `Grep/Glob/Read/Shell` и короткие MCP-имена (`syntaxcheck`, `templatesearch`…); в DSH — `grep/glob/read/bash` и `mcp__<srv>__<tool>`. |
| MCP-first цепочка | ❌ | Без ручной настройки MCP в `cordis.yml` вся верификация (`syntaxcheck→check_1c_code→review_1c_code`, `templatesearch`, `recall`) невыполнима. |
| Триаж/гейты | ✅ | Содержательно универсальны (quick-fix/docs/spec/full-cycle, gates) — не зависят от харнесса. |
| Модельные профили | ❌ | `model-*.md` и `model-adaptation.md` про Claude/GPT — не DeepSeek. |

### 2.2 Скиллы (`content/skills/`, 10 шт.)

| Скилл | Перенос в DSH | Комментарий |
|---|---|---|
| `1c-metadata-manage` | ✅ (контент) / ❌ (инструменты) | SKILL.md совместим; но его `tools/*.ps1` и вызовы MCP-инструментов требуют MCP + PowerShell (на Linux — pwsh). |
| `mcp-1c-tools` | ✅ | Каталог серверов; имена инструментов надо адаптировать под `mcp__<srv>__<tool>`. |
| `caveman`, `handoff`, `md-to-docx`, `mermaid-diagrams`, `prompt-enhancer`, `img-grid-analysis`, `powershell-windows`, `v8unpack-cf` | ✅ | Формат/фронтматтер совместимы; переносятся копированием в `.agents/skills/`. |

### 2.3 Субагенты (`content/agents/`, 13 шт.)

- Переиспользуемы как **промпты** для `subagent`/`subagent_fork` (содержательно — да).
- `modelTier` (coding/analysis/light) маппится на DSH-механизм «модель на ребёнка» в параметрах вызова `subagent`, но не автоматически.
- Роутинг/оркестрация (`subagents.md`, `subagent-pipeline.md`, `orchestrator-economy.md`) частично перекрывается нативными DSH-примитивами (`workflow`, `ralph`, `goal`).

### 2.4 Команды (`content/commands/`, 19 шт.)

- Как **процедуры** (шаги, чек-листы, скрипты) — переносимы.
- Как **`/слэш-команды`** — нет (нужен плагин `dsh-commands`).
- Команды, читающие `.dev.env` (`deploy-and-test`, `getconfigfiles`, `extensions`, `dataprocessors`, `loadfrom1cbase`, `update1cbase`) — в DSH лишаются источника параметров.

---

## 3. Ключевые блокеры (по убыванию важности)

1. **AGENTS.md не влезает в 64КБ-бюджет инструкций DSH.** Главный always-on документ набора (59.5 КБ) отбрасывается. Нужно либо: разбить на «тонкий» AGENTS.md + on-demand; поднять `maxBytes` (правка `cordis.patch.yml` профиля); либо держать в DSH только сжатый entry-point, а всё остальное — скиллы/правила по требованию.
2. **MCP не настроено и имена инструментов не совпадают.** Вся «MCP-first» верификация набора в DSH сейчас мертва; для оживления — `cordis.yml`-плагины на 8 серверов + адаптация имён инструментов в правилах/скилле `mcp-1c-tools`.
3. **Нет DSH-адаптера.** `adapters/*.yaml` знают Cursor/Claude Code/Codex/OpenCode/Kilo/Kimi/Koda/Qwen/Cline/Pi/Command Code, но не DSH. Установщики (`install.sh`, `install.ps1`) не генерируют ни `cordis.yml`, ни профиль, ни раскладку `.agents/skills`.
4. **Субагенты и команды не автозагружаются.** Требуют перевода в DSH-механизмы (prompt-вызов / plugin-регистрация / persona).
5. **`.dev.env` и модельные профили не применимы.** Параметры проекта и выбор моделей в DSH живут в `settings.yaml`/env, а не в `.dev.env`.

---

## 4. Что нужно, чтобы «подружить» (черновик DSH-адаптера)

Минимальный контур интеграции:

1. **Entry-point**: тонкий `AGENTS.md` (< ~10 КБ) или использовать `CLAUDE.md` как указатель на `content/`. Правила `content/rules/*.md` остаются on-demand (агент читает их через `read`).
2. **Скиллы**: копировать `content/skills/*` → `.agents/skills/` целевого проекта (одноуровневое обнаружение DSH). Это единственный артефакт, который «встаёт» почти без изменений.
3. **MCP**: генерировать блоки `dsh-mcp-client` в `cordis.yml` профиля из `content/mcp-servers.json` (транспорт `streamable-http`), с подстановкой хоста (`MCP_HOST`/`--host`). Отдельно — соглашение об именах инструментов (короткие имена в тексте правил ↔ `mcp__<srv>__<tool>` в DSH).
4. **Субагенты**: не переносить как файлы; оставить `content/agents/*.md` как библиотеку промптов, а tier-роутинг реализовать параметром модели в вызове `subagent` (или пресетами-персонами).
5. **Команды**: либо оставить процедурными доками, либо написать тонкий плагин `dsh-commands`, который регистрирует 19 команд и делегирует их markdown-телам.
6. **Параметры**: переносить `.dev.env`-значения в env/settings DSH (или в `$DSH_*`), модельные профили — не переносить.

**Приоритет по ценности/затратам:** скиллы (дёшево, сразу работает) → правила как on-demand (дёшево) → MCP-подключение (средне, разблокирует верификацию) → тонкий AGENTS.md (обязательно, иначе контекст не грузится) → субагенты/команды (дорого, частично дублируется нативными DSH-примитивами).
