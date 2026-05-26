# FORK-TODO — технический долг форка `mavlenkov/ai_rules_1c`

Линукс + 1CFilesConverter edition поверх upstream `comol/ai_rules_1c`.
Этот файл фиксирует расхождения форка с upstream, требующие отдельной работы.
Не относится к upstream — при PR в upstream не включать.

## После мержа upstream «версия 4» (2026-05-25, upstream `5b246bc`)

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
