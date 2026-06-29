# subagent-model-routing Specification

## Purpose
TBD - created by archiving change multi-client-routing. Update Purpose after archive.
## Requirements
### Requirement: Per-client разрешение модели субагента

Установщик SHALL разрешать конкретную модель для абстрактного `modelTier` субагента **с учётом целевого AI-клиента**, по каскаду: значение `SUBAGENT_MODEL_<TIER>__<TOOL>` (override для клиента), иначе общее `SUBAGENT_MODEL_<TIER>` (дефолт), иначе пусто. Каскад SHALL быть идентичным в `install.ps1` и `scripts/install.sh`.

Суффикс `<TOOL>` SHALL получаться из id адаптера переводом в верхний регистр и заменой `-` на `_` (`claude-code → CLAUDE_CODE`, `opencode → OPENCODE`, `cursor → CURSOR`, `kilocode → KILOCODE`).

#### Scenario: Override для клиента переопределяет общий дефолт

- **WHEN** в `.dev.env` заданы `SUBAGENT_MODEL_CODING=sonnet` и `SUBAGENT_MODEL_CODING__OPENCODE=zai-coding-plan/glm-5.2`, и размещается coding-агент под `opencode`
- **THEN** в файл агента подставляется `zai-coding-plan/glm-5.2`

#### Scenario: Без override используется общий дефолт

- **WHEN** задан только `SUBAGENT_MODEL_CODING=sonnet`, и размещается coding-агент под `claude-code`
- **THEN** в файл агента подставляется `sonnet`

#### Scenario: Пустое значение опускает поле модели

- **WHEN** для яруса нет ни override, ни общего значения
- **THEN** поле модели в файле агента не эмитится и AI-клиент использует свою модель по умолчанию

### Requirement: Проверка формата имени модели для provider/model-клиентов

Для клиентов, требующих формат `provider/model` (`opencode`, `kilocode`), установщик SHALL проверять итоговое имя модели: если оно не содержит `/`, поле модели НЕ подставляется и SHALL печататься предупреждение с подсказкой задать `SUBAGENT_MODEL_<TIER>__<TOOL>`. Для клиентов с короткими алиасами (`claude-code`, `cursor`) проверка НЕ применяется.

#### Scenario: Алиас без префикса провайдера для OpenCode гасится с предупреждением

- **WHEN** для `opencode` итоговое имя модели — `sonnet` (нет `/`)
- **THEN** поле модели не подставляется И печатается WARNING с именем параметра и подсказкой задать `SUBAGENT_MODEL_<TIER>__OPENCODE`

#### Scenario: Корректный provider/model для OpenCode подставляется без предупреждения

- **WHEN** для `opencode` итоговое имя модели — `deepseek/deepseek-v4-pro`
- **THEN** поле модели подставляется без предупреждения

#### Scenario: Короткий алиас для Claude Code остаётся валидным

- **WHEN** для `claude-code` итоговое имя модели — `opus`
- **THEN** поле модели подставляется без проверки на `/`

### Requirement: Обратная совместимость общего параметра яруса

Общий `SUBAGENT_MODEL_<TIER>` без суффикса SHALL продолжать работать как дефолт для всех клиентов; отсутствие per-client суффиксов НЕ должно ломать установку.

#### Scenario: Одноклиентный проект без суффиксов

- **WHEN** в `.dev.env` заданы только `SUBAGENT_MODEL_REASONING/CODING/LIGHT` без суффиксов и активен один клиент
- **THEN** установка проходит и модели подставляются как раньше

