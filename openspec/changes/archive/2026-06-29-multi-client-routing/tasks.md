## 1. Фаза A — per-client модели: scripts/install.sh

- [x] 1.1 Добавить маппинг `tool → suffix` (UPPER + `-`→`_`) и список provider/model-клиентов (`opencode`, `kilocode`)
- [x] 1.2 `resolve_model_tiers`: читать из `.dev.env` и общие `SUBAGENT_MODEL_<TIER>`, и per-client `SUBAGENT_MODEL_<TIER>__<TOOL>`
- [x] 1.3 `resolve_agent_model_tier`: принять `tool`, реализовать каскад `override ?? default ?? пусто`
- [x] 1.4 Добавить проверку формата: для provider/model-клиентов имя без `/` → не подставлять + WARNING с подсказкой
- [x] 1.5 `place_section`: прокинуть `tool` (из главного цикла `for tool, adapter`) в `resolve_agent_model_tier` для `section == 'agents'`
- [x] 1.6 `bash -n` + прогон на временной директории (claude-code=alias, opencode=provider/model, WARNING на алиасе для opencode, пусто→нет поля)

## 2. Фаза A — per-client модели: install.ps1

- [x] 2.1 `Resolve-ModelTiers`: расширить чтение per-client ключей `SUBAGENT_MODEL_<TIER>__<TOOL>`
- [x] 2.2 `Resolve-AgentModelTier`: сделать tool-aware (param `$Tool`), каскад + проверка формата (зеркало install.sh)
- [x] 2.3 `Invoke-PlacePhase`: передать текущий `$tool` в `Resolve-AgentModelTier`
- [x] 2.4 Проверка паритета вывода с install.sh на тех же входных `.dev.env`

## 3. Фаза A — конфиг и документация

- [x] 3.1 `.dev.env.example`: добавить примеры `SUBAGENT_MODEL_<TIER>__OPENCODE` (`zai-coding-plan/glm-5.2`, `deepseek/deepseek-v4-pro`, `glm-5-turbo` для light); free-tier только в комментарии
- [x] 3.2 `content/rules/dev-standards-core.md` и `content/rules/subagents.md`: описать per-client суффиксы и биллинг-семантику ярусов (per-token vs flat)
- [x] 3.3 `AGENT-INSTALL.md`: описать резолюцию `__<TOOL>` и проверку формата в Lean placement
- [x] 3.4 `README.md`: упомянуть per-client модели субагентов
- [x] 3.5 `AGENTS.md → Defaulted`: упомянуть per-client суффиксы `SUBAGENT_MODEL_*__<TOOL>`

## 4. Фаза B — автоматический внешний критик

- [x] 4.1 Создать `content/rules/external-review.md`: триггер (verification, нетривиальный код), предпочтение Codex, fallback на `1c-code-reviewer`@модель-клиента, per-client секции детекции/вызова
- [x] 4.2 Прописать передачу контекста правил Codex (`anti-patterns.md` + индекс `coding-standards.md` + diff)
- [x] 4.3 `content/rules/verification-checklist.md`: добавить soft-gate ссылку на `external-review.md`
- [x] 4.4 `AGENTS.md → Quality`: добавить запись о правиле `external-review`
- [x] 4.5 `content/rules/coding-standards.md`: внести `external-review.md` в индекс (если индекс перечисляет detail-файлы)

## 5. Раскатка и фиксация

- [x] 5.1 Развёрнутые проекты: добавить `SUBAGENT_MODEL_<TIER>__OPENCODE` в `.dev.env` (7 шт.)
- [x] 5.2 Перекатать развёрнутые проекты новым install.sh, проверить `opencode models`-валидность и отсутствие битого `model: sonnet`
- [x] 5.3 `FORK-TODO.md`: зафиксировать per-client routing + внешний критик как форк-расхождение (при merge upstream сохранять)
- [x] 5.4 Финальный прогон обоих установщиков на временной директории (regression)
