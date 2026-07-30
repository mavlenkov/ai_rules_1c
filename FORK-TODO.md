# FORK-TODO — технический долг форка `mavlenkov/ai_rules_1c`

Линукс + 1CFilesConverter edition поверх upstream `comol/ai_rules_1c`.
Этот файл фиксирует расхождения форка с upstream, требующие отдельной работы.
Не относится к upstream — при PR в upstream не включать.

## После мержа upstream (2026-07-27, upstream `5ae333e`)

Слит upstream `7266528..5ae333e` (3 коммита): hard gate против `tools`-массива
во frontmatter агентов OpenCode (`5ae333e`), перенос on-demand правил Claude Code
в `.claude/rules-1c/` (`1b6e2ed`), усиление правил — hard gate metadata-manage,
platform-first, MCP-first search (`f33d240`). Конфликтов было 4 (все в
`content/commands/`), разрешены по политике форка:

- `deploy-and-test.md` — сохранена форк-версия (Linux + 1CFilesConverter,
  пример PostgreSQL); upstream-секция «Failure handling — retry loop» перенесена
  перед `# Diagnostics` с поправкой на форк-нумерацию шагов.
- `update1cbase.md` — upstream-секция «Update retry loop» влилась чисто;
  в финальном отчёте объединены форк-список инструментов (1CFilesConverter /
  ibcmd / Designer) и upstream-учёт попыток retry loop.
- `doctor.md` — объединён список починки (форк-пункт про `scripts/install.sh` +
  upstream-пункт про OpenCode-гейт); к PowerShell quick-check добавлен
  bash-эквивалент.
- `updaterules.md` — сохранена форк-структура (OS-detect, bash-канал, источник
  `mavlenkov/ai_rules_1c`); приняты upstream-шаги 5–6 (post-update гейт) и
  hard obligation для agent-канала; к гейту добавлен bash-эквивалент.
- `memory.md` — восстановлена секция `## Captured during work (no remember
  available)`: upstream удалил её в `1b6e2ed`, но собственный `AGENTS.md`
  ссылается на неё в трёх местах.

**Проверено после мержа:** `scripts/install.sh` читает `copyTo` из адаптера
динамически — переезд claude-code на `.claude/rules-1c/` bash-канал подхватывает
без правок. `install.ps1` слился без дублей функций (`Test-OpenCodeAgentFrontmatter`
и миграция legacy `.claude/rules/` на месте); синтаксис не прогнан — на машине
нет `pwsh`. Форк-хуки целы: external-review (soft gate E), per-client каскад
`__<TOOL>`, форк-секции `AGENTS.md`. `transcribe` не вернулся (п.8 не требуется).

### 11. Отложено после мержа `5ae333e`

- Bash-канал (`scripts/install.sh`) не выполняет post-update OpenCode-гейт
  автоматически и не имеет repair-флага уровня `-ForcePaths` (гейт покрыт
  ручным шагом 5 в `/updaterules`, bash-сниппет добавлен). Legacy-очистки
  `.claude/rules/` в install.sh тоже нет — старые managed-файлы оттуда bash
  не удаляет.
- Новые адаптеры (Kimi/Qwen/Command Code/Cline/Pi) по-прежнему только через
  `install.ps1` (см. п.10).

### 12. ✅ РЕШЕНО (2026-07-27): `scripts/install.sh` поддерживает codex

Bash-канал научился устанавливать codex-адаптер (раньше — только
cursor/claude-code/opencode; FORK-TODO п.10). Реализовано:

- `parse_yaml` — блочные скаляры `|` / `>` (шаблон `template: |` адаптера
  codex раньше терялся).
- `place_section` — режим `rebuild-toml` (агенты → `.codex/agents/*.toml`
  через `codex_agent_template`, зеркало `Invoke-CodexAgentTemplate`: строка
  шаблона с пустым плейсхолдером выбрасывается — `model = …` без модели,
  `model_reasoning_effort` всегда) и user-scope цели `~/` (команды →
  `~/.codex/prompts/`, WARNING раз за прогон, в манифест — абсолютный путь,
  как в install.ps1).
- `render_mcp` — TOML-схема `[mcp_servers."<id>"]` → `.codex/config.toml`
  (зеркало `New-McpConfig-Codex`); контракт изменён на `(fmt, text)`, для
  TOML merge НЕ делается (файл перезаписывается целиком — отличие от
  потенциальной merge-семантики ps1, зафиксировано как допустимое расхождение).
- `detect_tools` — codex авто-детектится только по директории `.codex/`
  (правило `exists: "AGENTS.md"` из адаптера проигнорировано: OR-семантика
  добавляла бы codex в каждый проект; зеркало detection-map install.ps1).
  Пустой 0-байтовый ФАЙЛ `.codex` детект не срабатывает.
- Модели ярусов: codex принимает свои slug'и без провайдера
  (`gpt-5.6-sol/terra/luna`), в `PROVIDER_MODEL_TOOLS` НЕ добавлен.
  Примеры `__CODEX` добавлены в `.dev.env.example` Раздел 4.
- Бонус: финальное сообщение install.sh говорило «fork Раздел 3» → «Раздел 5».

Проверено: temp-проект (TOML валиден tomllib, модели из `__CODEX` override,
13 агентов, 35 правил, 10 скиллов, 15 команд в fake-HOME), регрессия
claude-code (rules-1c, JSON-путь MCP), детект по файлу/директории. Боевая
установка в LocalProject1 (2026-07-27): `--tools claude-code,codex --host mcp-host`,
мусор (0-байтовый `.codex`, папка `codex/` со старой копией бандла) удалён,
ключи `SUBAGENT_MODEL_*__CODEX` добавлены в `.dev.env` проекта.

**При будущем merge upstream:** если upstream допишет codex в свой bash-канал
или изменит `adapters/codex.yaml` (merge-флаг MCP, новые поля шаблона) —
сверять с этой реализацией.

### 13. ✅ РЕШЕНО (2026-07-29): `scripts/install.sh` поддерживает kimi

Kimi-адаптер (`adapters/kimi.yaml`) простой — rules → `.kimi-code/rules-1c/`,
agents → `.kimi-code/agents/*.md` (generic frontmatter ops, `modelHint`→`model`),
без секции commands (у Kimi нет проектного каталога команд — by design
адаптера), skills verbatim, MCP — схема `mcpServers` (уже поддерживалась
JSON-веткой `render_mcp`). Поэтому доработка свелась к: добавлению `kimi` в
список детектируемых tools, в priority rulesDir для рендера `AGENTS.md`
(между kilocode и opencode — порядок `RulesDirPriority` из install.ps1) и в
help-тексты. Детект по адаптеру: `.kimi-code/` или `.kimi/` — оба легитимные
маркеры, спец-обработки (как у codex) не нужно. `PROVIDER_MODEL_TOOLS` не
трогали: алиасы Kimi (`kimi-code/k3`) содержат `/` и проходят формат-гард.
Проверено на temp-проекте: 35 правил, 13 агентов (`model: kimi-code/k3` из
`__KIMI` override), 10 скиллов, 8 MCP-серверов, манифест
`['kimi']` / `.kimi-code/rules-1c`. Раскатано (2026-07-29) во все 9 проектов
с установленными правилами (LocalProject3, SyncUtil, LocalProject2, TestBaseExt,
CustomCfgExt, LocalProject1, HistologyDemo, LocalProject4, Тестирование):
`--tools <манифестные tools>+kimi --host <из манифеста>`, ключи
`SUBAGENT_MODEL_*__KIMI` (coding/analysis=`kimi-code/k3`,
light=`kimi-code/kimi-for-coding-highspeed`) дописаны в `.dev.env` проектов
(в LocalProject3 `.dev.env` нет — модель не эмитится, дефолт клиента). OpenSpec-бандла для kimi в
`content/openspec-bundle/` нет (upstream не поставляет) — цикл бандла его
пропускает; `.kimi/skills/openspec-*` в проектах ставит собственный
инсталлятор OpenSpec, не 1c-rules.

## После мержа upstream (2026-06-27, upstream `a421cf4`)

Слит upstream `5b246bc..a421cf4` (11 коммитов) в ветке `merge/upstream-20260627`.
Конфликтов было 9, разрешены: форк-специфика (Linux-пути, fork Section 3,
команды `extensions`/`dataprocessors`) сохранена, upstream-улучшения приняты
(семантика «пустые `IB_USER`/`IB_PASSWORD`/`LOG_PATH` — валидные дефолты, не
спрашивать»; модели субагентов по ярусам; новый `permission`-механизм OpenCode;
секция про мультипроектную MCP-установку). Новые техдолги:

### 7. ✅ ЗАКРЫТО (2026-07-20): ярус `reasoning` упразднён — принята upstream-схема

При merge upstream 7266528 обнаружилось, что upstream ввёл собственный 3-й ярус
`analysis` с другой раскладкой (architect→coding, explorer→light). По решению
пользователя форк перешёл на upstream-схему `coding`/`analysis`/`light`;
ключ `SUBAGENT_MODEL_REASONING` заменён на `SUBAGENT_MODEL_ANALYSIS`
(в развёрнутых проектах ключи переименованы при перекатке).
Ниже — историческое описание упразднённого форк-яруса.

#### (история) Третий ярус моделей `reasoning`

Upstream использует **два** яруса субагентов (`coding` / `light`). Форк ввёл
**третий** — `reasoning` (2026-06-27) под схему «opus проектирует → sonnet
исполняет»: `reasoning` (исследование/спеки/архитектура: `1c-explorer`,
`1c-analytic`, `1c-planner`, `1c-architect`, `1c-arch-reviewer`) → сильная
модель; `coding` (реализация: developer, metadata-manager, refactoring, tester,
code-reviewer, performance-optimizer, doc-writer); `light` (error-fixer).
Параметр `.dev.env` — `SUBAGENT_MODEL_REASONING`. Затронуто: `modelTier:
reasoning` у 5 агентов в `content/agents/`, `ModelTierKeys` в `install.ps1`,
`MODEL_TIER_KEYS` в `scripts/install.sh`, `.dev.env.example` Раздел 4, доки
(`AGENTS.md`, `subagents.md`, `dev-standards-core.md`, `AGENT-INSTALL.md`,
`README.md`). **При будущем merge upstream:** их `modelTier: coding` у
explorer/analytic/planner/architect/arch-reviewer будет конфликтовать с нашим
`reasoning` — сохранять форк-значение. Если upstream введёт свой 3-й ярус с
другим именем — согласовать.

### 8. Удалён скилл `transcribe` (форк)

Скилл `transcribe` (Gemini 2.5 Flash API, расшифровка аудио/видео) удалён из
форка (2026-06-27): ни одна из используемых моделей (Claude) не принимает аудио,
скилл не нужен. Удалена папка `content/skills/transcribe/` + ссылки в `AGENTS.md`,
`README.md`, `AGENT-INSTALL.md`. **При будущем merge upstream** скилл вернётся
(он есть в upstream) — удалять повторно при необходимости.

### 9. Per-client модели субагентов + автоматический внешний критик (форк)

**Обновление 2026-07-20:** после merge upstream ярусы переименованы в
`coding`/`analysis`/`light` (см. п.7) — per-client каскад и формат-гард работают
поверх новых имён без изменений логики; hook внешнего критика перенесён в новую
структуру verification-правил (soft gate E в `verification-delivery.md`,
указатель в роутере `verification-checklist.md`).

Расхождение с upstream, внесено 2026-06-29 (OpenSpec change `multi-client-routing`).

**A. Per-client разрешение модели субагента.** Имя модели диалектно по клиенту:
формат (Claude Code/Cursor — алиас `sonnet`; OpenCode/Kilo — `provider/model`,
напр. `zai-coding-plan/glm-5.2`, `deepseek/deepseek-v4-pro`) и набор провайдеров
(Claude Code — только Anthropic). Введён override на клиента суффиксом `__<TOOL>`
(`SUBAGENT_MODEL_<TIER>__OPENCODE` и т.п.; TOOL = UPPER, `-`→`_`). Каскад
резолюции `__<TOOL>` → общий ярус → пусто; для OpenCode/Kilo имя без `/` не
подставляется и печатается WARNING (защита от молчаливо битого алиаса). Затронуто:
`resolve_tier_model`/`resolve_agent_model_tier` + `MODEL_WARNINGS` в
`scripts/install.sh`; `Get-ToolSuffix`/`Get-DevEnvRawKeys`/`Resolve-AgentModelTier`
(tool-aware) в `install.ps1`; `.dev.env.example` Раздел 4 (примеры `__OPENCODE`);
доки (`subagents.md`, `dev-standards-core.md`, `AGENT-INSTALL.md`, `README.md`,
`AGENTS.md`). Биллинг-семантика яруса: per-token (Claude Code) = стоимость×способность;
flat-подписка (OpenCode/Z.AI) = способность×латентность (reasoning и coding могут
совпадать). Общий `SUBAGENT_MODEL_<TIER>` без суффикса работает как прежде —
одноклиентные проекты не затронуты.

**B. Автоматический внешний критик `external-review.md`.** Новое on-demand правило:
на verification gate для нетривиального кода автоматически (без запроса) запускается
внешний критик — слой ② поверх обязательных hard-валидаторов (`syntaxcheck` →
`check_1c_code` → `review_1c_code`). Предпочтение Codex (с приложением рубрики
`anti-patterns.md` + индекса `coding-standards.md` + diff, т.к. Codex читает только
корневой `AGENTS.md`); при недоступности Codex — graceful fallback на субагента
`1c-code-reviewer` на модели текущего клиента (per-client из пункта A). Codex —
НЕ установочный таргет. Затронуто: `content/rules/external-review.md` (новый),
хук в `verification-checklist.md` (soft gate D), `AGENTS.md → Quality`,
`coding-standards.md` (Code Review), снят запрет авто-вызова `1c-code-reviewer` в
`subagents.md` для этого fallback.

**При будущем merge upstream:** обе части — форк-only, сохранять. Если upstream
введёт свою развязку моделей/критика — согласовать имена параметров и хуки.

### 10. Merge upstream 7266528 (2026-07-20): принятое и отложенное

**Принято:** реструктуризация правил (dev-standards-core и verification-checklist →
роутеры + focused-файлы: dev-standards-env/code-style/change-markers,
verification-policy/gates/delivery); ярусы `coding`/`analysis`/`light` (п.7);
новые команды `/economymode`, `/litemode`, `/caveman`, `/evolve`; параметры
`ORCHESTRATION`, `QUICKFIX_MAX_LINES`, `DEBUG_FAST_PATH`, `VERIFICATION_DEPTH`,
`CAVEMAN`, `UI_TESTING`; корневой `LLM-RULES.md` (install.sh кладёт skip-if-exists);
скилл `v8unpack-cf`; фикс kilocode (.kilo) и профили моделей по бенчу в install.ps1.
**Дослано в install.sh (2026-07-21):** нормализация OpenCode MCP-ключей
`1c…`→`onec…` (Moonshot/Kimi отвергают имена функций с цифры), строгая схема
записей ({type,url,enabled} — без description), merge-логика для корневого
`opencode.json` (заменяется только ключ `mcp`, instructions и прочее
пользовательское сохраняется) и удаление legacyTargets
(`.opencode/opencode.json`).

**Отложено / не поддержано в install.sh:** новые адаптеры Kimi/Qwen/Command
Code/Cline/Pi — только через `install.ps1` (bash-канал по-прежнему
cursor/claude-code/opencode). Форк-команды деплоя (`deploy-and-test`,
`getconfigfiles`, `loadfrom1cbase`, `update1cbase`) оставлены форк-версиями и НЕ
перенесены на новую upstream-структуру «команда-тонкая → правило-канон» — при
следующем merge пересмотреть. `transcribe` удалён повторно (п.8).

### 5. ✅ РЕШЕНО (2026-06-27): `scripts/install.sh` реализует `toolsToPermission`

Upstream доработал `adapters/opencode.yaml`: вместо «дропнуть массив `tools`»
он ТРАНСФОРМИРУЕТ список инструментов в объект `permission`
(`toolsToPermission`: Read→read, Write/Edit→edit, Grep→grep, Glob→glob,
Shell→bash; не выданное = `deny`), чтобы read-only субагенты (`explorer`,
`code-reviewer`, `arch-reviewer`) не могли писать/звать shell. Раньше наш
`apply_frontmatter_ops()` знал только `keep`/`drop`/`rename`/`addIf`.
**Фикс:** в `apply_frontmatter_ops()` добавлена Phase 0 (построение `permission`
из `tools` до keep/drop), повторяющая `Invoke-FrontmatterOps` Phase 0 из
`install.ps1`; `fm_to_text()` научился сериализовать вложенный dict block-style
(как `Format-FrontmatterEntry`). Проверено: `developer` → всё `allow`,
`code-reviewer` (Read+MCP) → `edit`/`grep`/`glob`/`bash: deny`, MCP не маппится.

### 6. ✅ РЕШЕНО (2026-06-27): `scripts/install.sh` подставляет модель по `modelTier`

Upstream убрал `modelHint` из `content/agents/*.md` и ввёл `modelTier`
(`coding` / `light`) + параметры `.dev.env` `SUBAGENT_MODEL_CODING` /
`SUBAGENT_MODEL_LIGHT`; установщик подставляет модель в файл субагента по ярусу.
**Фикс:** добавлены `resolve_model_tiers()` (читает `SUBAGENT_MODEL_*` из
`TARGET/.dev.env`, кэш на прогон) и `resolve_agent_model_tier()` (заменяет
`modelTier` → `modelHint` до frontmatter-ops; нет модели → ключ удаляется),
вызывается в `place_section` для `section == 'agents'`. Зеркалит
`Resolve-ModelTiers` / `Resolve-AgentModelTier` из `install.ps1`. install.sh
неинтерактивен: без `.dev.env`/ключа модель не эмитится (дефолт AI-клиента).
Проверено: с `.dev.env` `coding=opus` → `model: opus`; без `.dev.env` — нет
поля модели, `modelTier` удалён.

## После мержа upstream «версия 4» (2026-05-25, upstream `5b246bc`)

### 0. ✅ РЕШЕНО (2026-05-26): OpenCode adapter — формат `tools`

При раскатке на проекты выяснилось: OpenCode (1.15.10) валидирует frontmatter
агентов/команд и требует `tools` как **object** (`{read: true, …}`), а не массив.
`content/agents/*.md` и `content/commands/*.md` хранят `tools`/`allowedTools`
списком (верно для Cursor / Claude Code), и adapter opencode копировал их как
массив → OpenCode падал с `Configuration is invalid` и **не грузил весь конфиг**
(ни MCP, ни агентов). Фикс в `adapters/opencode.yaml`: `tools` убран из `keep`
агентов (+ в `drop`), у команд убран `allowedTools → tools` rename. Агенты/команды
opencode теперь без явного `tools` (дефолтный набор инструментов). Проверено:
`opencode mcp list` грузится, серверы connected. **Это баг и в upstream.**

Отдельно (эмпирически, OpenCode 1.15.10): OpenCode **мержит** корневой
`opencode.json` И `.opencode/opencode.json` (документация утверждает только
корневой). Поэтому adapter target `.opencode/opencode.json` РАБОТАЕТ. Но старые
корневые `opencode.json` v1-генерации в проектах дают дубли серверов + битый
`1c-data` URL — чистятся в проектах при раскатке, не в форке.

### 1. ✅ РЕШЕНО (2026-05-26): миграция форк-команд на `.dev.env`

Форк-команды (`deploy-and-test`, `extensions`, `dataprocessors`, `getconfigfiles`)
переведены с `infobasesettings.md` на `.dev.env`. В `.dev.env.example` добавлен
fork-only **Раздел 3** (Linux + 1CFilesConverter): `CONVERTER_PATH`,
`CONVERT_TOOL`, `IBCMD_TOOL`, `DB_SRV_*`, `REMOTE_*`, `BASE_IB`/`BASE_CONFIG`,
`EDT_VERSION`. `V8_VERSION` выводится как `basename(PLATFORM_PATH)`; строка
подключения `<ib_connection>` строится из `INFOBASE_KIND` + `INFOBASE_PATH`.
Команды мигрируют legacy `infobasesettings.md` → `.dev.env` при первом запуске.
`AGENTS.md`/`README.md` приведены в соответствие. Mode 1/Mode 2 логика сохранена.

Остаточный вопрос: `scripts/install.sh` не создаёт `.dev.env` (это делает только
`install.ps1`). Bash-установка пока не генерирует `.dev.env` с автодетектом —
пользователь копирует `.dev.env.example` вручную. См. пункт 4.

### 2. ✅ РЕШЕНО (2026-05-26): Linux-адаптация команд upstream

Все 7 новых команд upstream адаптированы под Linux:

- `loadfrom1cbase.md`, `update1cbase.md` — переписаны кросс-платформенно
  (Linux-first): OS-detection, Linux/Windows варианты ibcmd и Designer,
  плюс опция 1CFilesConverter (Mode 2c: `conf2xml.sh`/`conf2ib.sh`).
- `updaterules.md` — источник переключён на форк `mavlenkov/ai_rules_1c`
  (не upstream `comol`, иначе теряются форк-правки); добавлен bash-channel
  (`scripts/install.sh`), `.dev.env` в preserve-список.
- `doctor.md` — проверка платформы и рекомендации установщика сделаны
  OS-зависимыми (`{PLATFORM_PATH}/1cv8` vs `bin\1cv8.exe`).
- `installmcp.md`, `updatemcp.md`, `checkmcp.md` — добавлена секция
  "Platform note (Linux)": Docker-движок (без Docker Desktop/winget/WSL),
  POSIX volume-пути, `/opt/1cv8/...`, MCP-конфиг под `~`. В `checkmcp` —
  bash/`curl` HTTP-проверка; в `installmcp` — bash `curl`+`jq` порт
  Tilda-pipeline загрузки дистрибутива.

Остаток для MCP-темы: полный детальный bash-порт всех шагов установки/обновления
MCP-серверов (Docker-команды per-server, config.env merge) не делался — на Linux
команды используют тот же Docker, отличия покрыты Platform note. Развёртывание и
использование MCP-серверов (включая `1c-data-mcp`) — отдельная MCP-тема.

- `content/rules/getconfigfiles.md` (обновлён upstream; наша команда
  `getconfigfiles` на него больше не опирается — самодостаточна; rule оставлен
  как Windows-reference, низкий приоритет)

### 3. ✅ РЕШЕНО (2026-05-26): `install.sh` обрабатывает `1c-data-mcp`

Добавлен флаг `--publish-url <URL>`: подставляет URL веб-публикации ИБ в
плейсхолдер `{INFOBASE_PUBLISH_URL}/hs/mcp` сервера `1c-data-mcp`, обрезая
концевой `/` и сегмент локали (`/ru`, `/en`, …) — та же логика, что в
`install.ps1`. Без флага плейсхолдер сохраняется и печатается предупреждение
(`⚠ MCP warnings`). `--host` (docker-серверы, `localhost`-URL) и `--publish-url`
(публикация ИБ) работают независимо. Протестировано прогоном обоих сценариев.

### 4. `scripts/install.sh` — покрытие новых tools/файлов

`install.sh` поддерживает только `cursor` / `claude-code` / `opencode`.
Upstream добавил адаптер `adapters/other.yaml` (универсальный fallback) и
много нового контента (агент `explorer`, скиллы `mcp-1c-tools`, `caveman`,
`handoff`, `md-to-docx`, `prompt-enhancer`, `transcribe`). Адаптеры
cursor/claude-code/opencode изменились только в комментариях — структура
операций прежняя, install.sh не сломан. Но стоит свериться, что новый контент
раскладывается корректно (особенно скиллы со скриптами и `presets/`).
