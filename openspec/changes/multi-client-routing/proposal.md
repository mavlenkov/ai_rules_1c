## Why

В форке введены абстрактные ярусы моделей субагентов (`reasoning`/`coding`/`light`), но параметры `SUBAGENT_MODEL_*` глобальны на проект, тогда как имя модели **диалектно по AI-клиенту**: Claude Code принимает алиас (`sonnet`), а OpenCode требует `provider/model` (`zai-coding-plan/glm-5.2`) — голый `sonnet` там не резолвится и молча откатывается на дефолт. При последней перекатке мы уже внесли этот баг: `model: sonnet` проставлен в opencode-агентов как битое имя. Параллельно у пользователя есть осознанная схема ревью — внешний критик (Codex) должен срабатывать **автоматически по правилам**, а при недоступности Codex — деградировать на имеющиеся модели; сейчас про Codex в правилах нет ничего.

## What Changes

- **Per-client разрешение модели субагента.** Вводится override через суффикс клиента: `SUBAGENT_MODEL_<TIER>__<TOOL>` (например `SUBAGENT_MODEL_CODING__OPENCODE`). Каскад: `__<TOOL>` → общий `SUBAGENT_MODEL_<TIER>` → пусто. Резолверы в обоих установщиках становятся tool-aware.
- **Проверка формата имени модели по клиенту.** Для `opencode`/`kilocode`, если итоговое имя не похоже на `provider/model` (нет `/`), модель **не подставляется** и печатается WARNING — вместо тихого битого алиаса.
- **Починка уже битых конфигов.** Перекатка развёрнутых проектов после фикса убирает битый `model: sonnet` из opencode-агентов.
- **Автоматический внешний критик (Codex) с fallback.** Новое on-demand правило описывает: на этапе verification gate (нетривиальный код) автоматически прогонять внешнего критика; предпочтительно Codex (с приложенным контекстом правил), при его недоступности — fallback на субагента `1c-code-reviewer` на per-client модели. Слой `review_1c_code` (1С:Напарник) остаётся обязательным, не fallback.
- **Контекст правил для Codex.** При вызове Codex прикладывать `anti-patterns.md` (рубрику код-ревью) + индекс `coding-standards.md` + diff — потому что on-demand правила Codex сам не загружает (нативно читает только корневой `AGENTS.md`).
- **Документация семантики ярусов.** Зафиксировать, что ярус означает разное по биллингу клиента: per-token (Claude Code) → стоимость×способность; flat-подписка (OpenCode/Z.AI Coding Plan) → способность×латентность (поэтому `reasoning` и `coding` в OpenCode могут совпадать).
- Расхождение с upstream фиксируется в `FORK-TODO.md`.

## Capabilities

### New Capabilities

- `subagent-model-routing`: как установщик резолвит конкретную модель субагента из абстрактного `modelTier` per-client (каскад override → дефолт → пусто, проверка формата `provider/model`, маппинг tool→суффикс).
- `external-review`: автоматический внешний критик в quality gate — триггер, per-client детекция доступности Codex, передача контекста правил, fallback-цепочка на per-client модель.

### Modified Capabilities

<!-- Нет ранее зафиксированных specs (openspec/specs пуст) — изменяемых возможностей нет. -->

## Impact

- **Установщики**: `install.ps1` (`Resolve-ModelTiers`, `Resolve-AgentModelTier` → tool-aware; `Invoke-PlacePhase` уже знает `$tool`), `scripts/install.sh` (`MODEL_TIER_KEYS`, `resolve_model_tiers`, `resolve_agent_model_tier`, `place_section` — прокинуть `tool`).
- **Конфиг проекта**: `.dev.env.example` (примеры `__OPENCODE` с `zai-coding-plan/glm-5.2`, `deepseek/deepseek-v4-pro`).
- **Правила/доки**: новое `content/rules/external-review.md`; правки `content/rules/verification-checklist.md` (soft-gate хук), `content/rules/subagents.md` и `content/rules/dev-standards-core.md` (per-client модели, биллинг-семантика ярусов), `AGENTS.md` (Quality + Defaulted), `AGENT-INSTALL.md`, `README.md`, `FORK-TODO.md`.
- **Развёрнутые проекты**: перекатка 7 шт. с per-client `__OPENCODE`-моделями.
- **Совместимость**: общий `SUBAGENT_MODEL_<TIER>` без суффикса продолжает работать как дефолт (обратная совместимость для одноклиентных проектов). Codex — не установочный таргет, в развязке моделей не участвует.
