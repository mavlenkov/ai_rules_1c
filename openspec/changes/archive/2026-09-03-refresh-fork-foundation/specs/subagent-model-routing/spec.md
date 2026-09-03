## ADDED Requirements

### Requirement: Routine work uses one appropriate model route
Routine execution SHALL use one model appropriate to the selected tier. Joint evaluation by multiple senior models SHALL be reserved for material decision forks, explicit comparative evaluation, or a direct user request; it SHALL NOT be an automatic routine step.

#### Scenario: Routine bounded task is delegated
- **WHEN** a bounded task has no material architecture, data-integrity, security, or public-contract decision
- **THEN** the parent selects one suitable tier/model and does not launch a multi-model panel

#### Scenario: Material decision needs independent opinions
- **WHEN** a consequential and hard-to-reverse decision would benefit from independent model perspectives
- **THEN** the parent may request multiple opinions while retaining responsibility for the final integrated decision

## MODIFIED Requirements

### Requirement: Обратная совместимость общего параметра яруса
Общий `SUBAGENT_MODEL_<TIER>` без суффикса SHALL продолжать работать как дефолт для всех клиентов; отсутствие per-client суффиксов НЕ должно ломать установку. Поддерживаемые ярусы — `CODING`, `ANALYSIS` и `LIGHT`; удалённый исторический `REASONING` не является действующим параметром.

#### Scenario: Одноклиентный проект без суффиксов
- **WHEN** в `.dev.env` заданы только `SUBAGENT_MODEL_CODING`, `SUBAGENT_MODEL_ANALYSIS` и `SUBAGENT_MODEL_LIGHT` без суффиксов и активен один клиент
- **THEN** установка проходит и модели подставляются из общих параметров ярусов

#### Scenario: Устаревший REASONING отсутствует
- **WHEN** документация или пример описывает действующие параметры model-tier routing
- **THEN** он перечисляет `CODING`, `ANALYSIS` и `LIGHT` и не представляет `SUBAGENT_MODEL_REASONING` как поддерживаемый ключ
