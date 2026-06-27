# FORK-TODO — технический долг форка `mavlenkov/ai_rules_1c`

Линукс + 1CFilesConverter edition поверх upstream `comol/ai_rules_1c`.
Этот файл фиксирует расхождения форка с upstream, требующие отдельной работы.
Не относится к upstream — при PR в upstream не включать.

## После мержа upstream (2026-06-27, upstream `a421cf4`)

Слит upstream `5b246bc..a421cf4` (11 коммитов) в ветке `merge/upstream-20260627`.
Конфликтов было 9, разрешены: форк-специфика (Linux-пути, fork Section 3,
команды `extensions`/`dataprocessors`) сохранена, upstream-улучшения приняты
(семантика «пустые `IB_USER`/`IB_PASSWORD`/`LOG_PATH` — валидные дефолты, не
спрашивать»; модели субагентов по ярусам; новый `permission`-механизм OpenCode;
секция про мультипроектную MCP-установку). Новые техдолги:

### 5. `scripts/install.sh` — не реализует `toolsToPermission` (OpenCode `permission`)

Upstream доработал `adapters/opencode.yaml`: вместо «дропнуть массив `tools`»
он теперь ТРАНСФОРМИРУЕТ список инструментов в объект `permission`
(`toolsToPermission`: Read→read, Write/Edit→edit, Grep→grep, Glob→glob,
Shell→bash; не выданное = `deny`), чтобы read-only субагенты (`explorer`,
`code-reviewer`, `arch-reviewer`) не могли писать/звать shell. Наш
`apply_frontmatter_ops()` в `scripts/install.sh` знает только
`keep`/`drop`/`rename`/`addIf` — директиву `toolsToPermission` он игнорирует.
Проверено эмпирически: opencode-агенты, разложенные через install.sh, выходят
БЕЗ `permission` и без `tools` (дефолтный toolset). **Конфиг не ломается**
(массив не пишется), но read-only ограничения не применяются. Установка через
`install.ps1` корректна. Фикс: реализовать `toolsToPermission` в install.sh.

### 6. `scripts/install.sh` — не подставляет модель по `modelTier`

Upstream убрал `modelHint` из `content/agents/*.md` и ввёл `modelTier`
(`coding` / `light`) + параметры `.dev.env` `SUBAGENT_MODEL_CODING` /
`SUBAGENT_MODEL_LIGHT`; установщик подставляет модель в файл субагента по ярусу.
`install.ps1` это умеет, наш `install.sh` — нет (`modelTier` не в `keep` →
дропается, поле модели не появляется). Агенты выходят на дефолтной модели
AI-клиента. Не ломает установку, но `.dev.env`-параметры моделей через bash-канал
не действуют. Фикс: читать `SUBAGENT_MODEL_*` из `.dev.env` и маппить `modelTier`.

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
