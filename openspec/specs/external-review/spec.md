# external-review Specification

## Purpose
TBD - created by archiving change multi-client-routing. Update Purpose after archive.
## Requirements
### Requirement: Автоматический внешний критик в quality gate

Набор правил SHALL предписывать автоматический прогон внешнего критика на этапе verification gate для **нетривиального** кода (граница full-cycle vs quick-fix из Triage). Quick-fix и docs-fix критика НЕ требуют. Внешний критик — слой ② поверх обязательных hard-валидаторов (`syntaxcheck` → `check_1c_code` → `review_1c_code`), которые остаются обязательными.

#### Scenario: Нетривиальное изменение запускает внешнего критика

- **WHEN** агент завершает нетривиальное изменение кода и доходит до verification gate
- **THEN** автоматически выполняется проход внешнего критика без запроса к пользователю

#### Scenario: Quick-fix не запускает внешнего критика

- **WHEN** изменение классифицировано как quick-fix
- **THEN** проход внешнего критика пропускается

#### Scenario: Обязательные валидаторы не заменяются критиком

- **WHEN** выполняется проход внешнего критика
- **THEN** hard-валидаторы `syntaxcheck` / `check_1c_code` / `review_1c_code` всё равно выполняются как обязательный слой

### Requirement: Предпочтение Codex с graceful fallback

Внешним критиком SHALL предпочтительно выступать Codex; при его недоступности правило SHALL деградировать на субагента `1c-code-reviewer` на модели текущего клиента (из per-client разрешения). Недоступность Codex НЕ должна блокировать завершение задачи. Способ детекции доступности Codex SHALL описываться per-client (Claude Code — codex-плагин/`codex` CLI; OpenCode — `codex exec` через shell).

#### Scenario: Codex доступен

- **WHEN** способ вызова Codex для текущего клиента доступен
- **THEN** ревью выполняет Codex

#### Scenario: Codex недоступен — fallback на субагента

- **WHEN** Codex недоступен (бинарь не найден, ошибка запуска или таймаут)
- **THEN** ревью выполняет субагент `1c-code-reviewer` на модели текущего клиента, и завершение задачи не блокируется

### Requirement: Передача контекста правил внешнему критику

При вызове Codex родитель SHALL прикладывать контекст правил ревью, потому что Codex нативно читает только корневой `AGENTS.md` и не загружает on-demand правила. Минимальный контекст: `anti-patterns.md` (рубрика код-ревью), индекс `coding-standards.md`, diff/изменённые файлы.

#### Scenario: Вызов Codex включает рубрику ревью

- **WHEN** формируется промпт для Codex-критика
- **THEN** в него включаются `anti-patterns.md`, индекс `coding-standards.md` и diff изменённых файлов

