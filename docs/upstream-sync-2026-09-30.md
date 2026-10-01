# Синхронизация upstream от 30 сентября 2026

Подготовлена в ветке `chore/sync-upstream-20260930`: upstream `45bacdd`, общий предок `4aef5ca`, исходный форк `5a83a3d`. Ревью завершено 1 октября; merge-коммит сохраняет оба родителя слияния. OpenSpec change архивирован в `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/`, требования синхронизированы. Публикация и пилотная установка — отдельные этапы.

## Что изменено

- Общая структура правил и пакет OpenSpec приняты из upstream. `AGENTS.md` совпадает с upstream: 11 214 байт.
- Сохранены Linux/1CFilesConverter, Koda и per-client model overrides. Конвертер имеет один канон `content/rules/linux-converter.md`; команды наследуют upstream-проверки, порядок загрузки/проверки/применения и политику UI. Возможности установленного конвертера проверяются перед реальной операцией.
- `scripts/install.sh` сокращён с 816 до 49 строк: запуск общего установщика, требуется PowerShell 7. Флаги `--tools`, `--host`, `--publish-url` сохранены; автоматически выбирается init/update.
- JSON MCP-конфиги объединяются по серверам с сохранением существующих URL, авторизации и настроек. Невалидный JSON не перезаписывается. Существующий Codex TOML сохраняется целиком, новые подключения добавляются отдельно через `/setupmcp`.
- Политика валидаторов принята из upstream. Дополнительный внешний критик теперь только по явному запросу; выбор модели reviewer обязателен.
- Kimi-пакет заново сгенерирован официальным OpenSpec 1.13.1 в временной директории, использует `.kimi-code/` и включён в refresh-утилиту. Содержимое остальных пакетов совпадает с upstream.
- Отдельный генератор `tools/koda-mcp-setup.ps1` удалён: его функцию выполняет общий установщик.

## Проверки

- Структурный валидатор: PASS, бюджеты контекста не повышались. Тела standards-корпуса недоступны локально, проверка их содержимого пропущена самим валидатором.
- PowerShell AST установщика: PASS, дубли функций отсутствуют; Bash syntax: PASS.
- `agent-adapters.ps1`: 9/9 PASS; проверка обновления адаптирована к сохранению настроенного managed URL.
- `fork-install-regression.py`: PASS на восьми клиентах; пути с пробелами, выбор моделей, readonly-права, OpenSpec, авторизация, сторонние настройки и серверы, обновление/ForcePaths, невалидный JSON, отсутствие pwsh. Изолированы HOME и XDG-каталоги.
- `installer-paths-regression.ps1`: переносимые сценарии PASS; сценарии Windows short paths и интерактивной первичной выгрузки явно пропускаются на Linux. Первичная выгрузка в самом установщике по-прежнему ограничена Windows.
- `python-ports-regression.py`: 60/60 PASS в отдельном временном Git-снимке итогового исходника и 60/60 на чистом upstream, с PowerShell для parity-проверок.
- `metadata-tools-regression.ps1`: 53/59 PASS на Linux. Те же шесть падений воспроизводятся на чистом upstream, код инструментов метаданных совпадает с upstream. Windows-запуск этого набора не подтверждён.
- OpenSpec change `sync-upstream-minimal-fork`: strict validation PASS.

### Унаследованные падения Windows-набора на Linux

1. remove-form: a failed publish whose restore also fails keeps the quarantine.
2. remove-form: an object directory reached through a junction is refused.
3. dump-validate: healthy CF and CFE, nested subsystems and internal dump-info records.
4. dump-validate: object versions, malformed XML and mismatched descriptor names.
5. dump-validate: ConfigDumpInfo version and missing objects without duplicate child reports.
6. dump-validate: optional dump-info and root file input, text and JSON output.

## Границы и ревью

Работающий MCP-контур, URL, порты, базы и клиентские конфигурации не менялись. Исходный незакоммиченный `content/rules/system-safety.md` не редактировался и не входит в результат. Конвертер не запускался на реальной базе; инструкции сохраняют требование проверить возможности установленной версии. Windows-регрессии требуют отдельного запуска на Windows; это не новый дефект переноса.

Внешний critic больше не стартует автоматически. Upstream-политика выбора валидаторов отличается от прежней форк-политики; соответствующие решения отражены в OpenSpec change. Beta-миграция MCP выполняется отдельно от обновления набора правил.

Приоритет пользователя от 2026-10-01: Koda — эксперимент, дополнительные улучшения и PR в последнюю очередь. Локальная память и корневой `.agents/` не включаются в коммит. `AGENTS.md` и вложенные пакеты OpenSpec являются исходниками продукта, обновление которых входит в согласованный перенос upstream.

## Дополнение от 1 октября

После основного merge-коммита `72b3877` upstream продвинулся на 12 коммитов до `c1fb8e6`. Дополнительное слияние принимает исправления OpenCode, обновления пакета OpenSpec, определения БСП, исключения Python bytecode, инструментов метаданных и QA. Единственный конфликт — список адаптеров; сохранены общий upstream-код и прежняя регистрация Koda.

OpenCode JSON/JSONC, в том числе legacy-файлы, теперь сохраняются побайтно и не принадлежат установщику. Семь новых upstream-сценариев сохранения проходят. Повторные проверки общего установщика: PASS на восьми клиентах; Python-регрессии: 60/60; структурный валидатор: PASS. Переносимые сценарии installer-paths также прошли с shim `powershell.exe` → `pwsh`; Windows-only сценарии пропущены. Итоговые логи: `/tmp/ai-rules-latest-opencode.log`, `/tmp/ai-rules-latest-fork-install.log`, `/tmp/ai-rules-latest-python.log`, `/tmp/ai-rules-latest-validate-fixed.log`, `/tmp/ai-rules-latest-paths.log`. После уточнения имени query-валидатора набор full-cycle превысил лимит на шесть байт; удалена необязательная форк-ссылка из `verification-delivery.md`, сам файл снова совпадает с upstream. Лимиты не повышались, внешний критик остаётся явно запрашиваемым on-demand правилом.

## Полный перечень затронутых файлов

В таблице перечислены файлы относительно исходного форка; исторические форк-файлы, не затронутые этим обновлением, не включены.

| Файл | Изменение |
|---|---|
| `.claude-plugin/marketplace.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `.cursor-plugin/marketplace.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `.dev.env.example` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `.gitattributes` | Принято обновление upstream; общая структура/инструменты/тесты |
| `.github/workflows/validate-rules.yml` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `.gitignore` | Принято обновление upstream; общая структура/инструменты/тесты |
| `AGENT-INSTALL.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `AGENTS.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `FORK-TODO.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `README.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `WORKFLOWS.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/claude-code.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/cline.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/command-code.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/cursor.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/kimi.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/mimocode.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/other.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/qwen.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `adapters/zcode.yaml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/analytic.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/arch-reviewer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/architect.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/code-reviewer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/developer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/doc-writer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/error-fixer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/explorer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/metadata-manager.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/performance-optimizer.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/planner.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/refactoring.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/agents/tester.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/build-release.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/caveman.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/checkmcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/checkupdates.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/dataprocessors.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/commands/deploy-and-test.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/commands/doctor.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/economymode.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/evolve.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/extensions.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/commands/getconfigfiles.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/commands/initproject.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-agent-browser.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-atlassian-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-cognee.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-edt-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-officecli.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-openviking.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-rtk.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/install-windows-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/installfilesupdatescript.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/installmcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/installtools.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/litemode.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/loadfrom1cbase.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/commands/ponytail-review.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/previewmode.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/restore-testbase.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/resume.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/rulesmodel.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/sdlc.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/setupmcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/support.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/supportstatus.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/test-fix-loop.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/uitests.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/update1cbase.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/commands/updatemcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/commands/updaterules.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/mcp-servers.json` | Согласование существующего форк-файла с upstream |
| `content/openspec-bundle/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/commands/opsx/apply.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/commands/opsx/archive.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/commands/opsx/explore.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/commands/opsx/propose.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/commands/opsx/sync.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/commands/opsx/update.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/skills/openspec-apply-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/skills/openspec-archive-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/skills/openspec-explore/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/skills/openspec-propose/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/skills/openspec-sync-specs/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/claude-code/.claude/skills/openspec-update-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.agents/skills/openspec-apply-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.agents/skills/openspec-archive-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.agents/skills/openspec-explore/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.agents/skills/openspec-propose/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.agents/skills/openspec-sync-specs/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.agents/skills/openspec-update-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.codex/skills/openspec-apply-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.codex/skills/openspec-archive-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.codex/skills/openspec-explore/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/codex/.codex/skills/openspec-propose/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/commands/opsx-apply.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/commands/opsx-archive.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/commands/opsx-explore.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/commands/opsx-propose.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/commands/opsx-sync.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/commands/opsx-update.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/skills/openspec-apply-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/skills/openspec-archive-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/skills/openspec-explore/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/skills/openspec-propose/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/skills/openspec-sync-specs/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/cursor/.cursor/skills/openspec-update-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/skills/openspec-apply-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/skills/openspec-archive-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/skills/openspec-explore/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/skills/openspec-propose/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/skills/openspec-sync-specs/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/skills/openspec-update-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/workflows/opsx-apply.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/workflows/opsx-archive.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/workflows/opsx-explore.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/workflows/opsx-propose.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/workflows/opsx-sync.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kilocode/.kilocode/workflows/opsx-update.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/kimi/.kimi-code/skills/openspec-apply-change/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi-code/skills/openspec-archive-change/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi-code/skills/openspec-explore/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi-code/skills/openspec-propose/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi-code/skills/openspec-sync-specs/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi-code/skills/openspec-update-change/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi/skills/openspec-apply-change/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi/skills/openspec-archive-change/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi/skills/openspec-explore/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/kimi/.kimi/skills/openspec-propose/SKILL.md` | Официальный пакет Kimi 1.13.1 / удаление старого layout |
| `content/openspec-bundle/opencode/.opencode/commands/opsx-apply.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/commands/opsx-archive.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/commands/opsx-explore.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/commands/opsx-propose.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/commands/opsx-sync.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/commands/opsx-update.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/skills/openspec-apply-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/skills/openspec-archive-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/skills/openspec-explore/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/skills/openspec-propose/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/skills/openspec-sync-specs/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/opencode/.opencode/skills/openspec-update-change/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/openspec-bundle/version.txt` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/anti-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/async-methods.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/bsp-access-rights.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/coding-standards.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dcs-advanced-composition.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dcs-design.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/designer-batch-checks.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dev-standards-architecture.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dev-standards-change-markers.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dev-standards-code-style.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dev-standards-core.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/dev-standards-env.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/edt-workflow.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/extension-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/extension-workspace.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/external-review.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/rules/form-module.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/form-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/forms-add.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/forms.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/getconfigfiles.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/help-corpus-retrieval.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/integrations-add.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/linux-converter.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/rules/locks-and-transactions.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/logging-strategy.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/mcp-deployment.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/mcp-first-search.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/mcp-policy.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/memory-setup.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/model-adaptation.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/model-fable5.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/model-gpt56.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/model-gpt6.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/model-opus5.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/model-sonnet5.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/module-structure.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/multi-contour-search.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/orchestrator-economy.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/platform-solutions.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/project-memory.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/qa-testclient.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/query-design.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/registers-design.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/sdd-integrations.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/subagent-core.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/subagent-pipeline.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/subagents.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/rules/support-feedback.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/systematic-debugging.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/tooling-playbooks.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/ui-testing-tools.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/verification-checklist.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/verification-delivery.md` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `content/rules/verification-gates.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/verification-policy.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/rules/web-client-driving.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-business-tests/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-change-package/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-change-package/references/manual-implementation.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-change-package/references/review.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-code-search/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-form-inspect/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-impact/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-live-ib/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-meta-info/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/NOTICE.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/CHANGELOG.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/bsp-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/cf-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/cfe-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/db-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/edit-preview.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/epf-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/form-compile-dsl.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/form-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/form-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/help-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/interface-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/meta-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/mxl-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/query-optimization.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/query-writing.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/role-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/skd-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/ssl-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/subsystem-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/support-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/template-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/web-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/docs/xdto-manage.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-cf-manage/cf-edit-reference.md` | Согласование существующего форк-файла с upstream |
| `content/skills/1c-metadata-manage/tools/1c-cf-manage/scripts/cf-edit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-cf-manage/scripts/dump-validate.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-cfe-manage/scripts/cfe-borrow.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-dump-cf.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-dump-dt.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-dump-xml.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-load-cf.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-load-dt.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-load-git.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-load-xml.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/db-update.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-db-ops/scripts/install-files-update.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-epf-build/scripts/epf-build.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-epf-dump/scripts/epf-dump.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-compile/form-dsl-spec.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-compile/presets/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-compile/presets/erp-standard.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-compile/scripts/form-compile.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-compile/scripts/form-compile.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-edit/scripts/form-edit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-scaffold/scripts/form-add.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-scaffold/scripts/form-add.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-scaffold/scripts/remove-form.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-scaffold/scripts/remove-form.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-form-validate/scripts/form-validate.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-help-manage/scripts/add-help.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-interface-manage/scripts/interface-edit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-meta-edit/child-operations.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-meta-edit/json-dsl.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-meta-edit/scripts/meta-edit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-meta-edit/scripts/meta-edit.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-meta-validate/scripts/meta-validate.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-meta-validate/scripts/meta-validate.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-skd-edit/scripts/skd-edit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-subsystem-manage/scripts/subsystem-compile.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-subsystem-manage/scripts/subsystem-edit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-template-manage/scripts/add-template.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-web-ops/scripts/web-info.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-web-ops/scripts/web-publish.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-web-ops/scripts/web-stop.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-web-ops/scripts/web-unpublish.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/1c-web-ops/scripts/web_common.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/_common/DevEnv.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/_common/Invoke-1CEdit.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/_common/MetadataAddress.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-metadata-manage/tools/_common/dev_env.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-platform-help/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-qa-testing/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-qa-testing/scripts/qa-testclient.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-repository-manage/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-repository-manage/docs/repo-sdlc.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-templates-memory/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-ui-regression/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/1c-validate/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/caveman/NOTES.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/caveman/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/handoff/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1C-docs-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-code-check-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-code-metadata-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-data-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-graph-metadata-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-ssl-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-syntax-checker-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/1c-templates-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/edt-mcp.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/mcp-conversion-data20.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/mcp-test.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/mcp-1c-tools/docs/memory-providers.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/md-to-docx/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/md-to-docx/scripts/md_to_docx.js` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/prompt-enhancer/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/transcribe/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/transcribe/scripts/transcribe.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/skills/v8unpack-cf/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/anti-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/async-methods.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/bsp-access-rights.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/dcs-advanced-composition.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/dcs-design.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/dev-standards-architecture.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/dev-standards-code-style.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/extension-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/form-patterns.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/locks-and-transactions.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/logging-strategy.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/platform-solutions.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/registers-design.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `content/standards/systematic-debugging.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `docs/upstream-sync-2026-09-30.md` | Результат, ограничения проверок и перечень файлов для ревью |
| `install.ps1` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `openspec/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `openspec/changes/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/.openspec.yaml` | План, требования и отметки реализации текущего изменения |
| `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/design.md` | План, требования и отметки реализации текущего изменения |
| `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/proposal.md` | План, требования и отметки реализации текущего изменения |
| `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/specs/external-review/spec.md` | План, требования и отметки реализации текущего изменения |
| `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/specs/minimal-fork-integration/spec.md` | План, требования и отметки реализации текущего изменения |
| `openspec/changes/archive/2026-10-01-sync-upstream-minimal-fork/tasks.md` | План, требования и отметки реализации текущего изменения |
| `openspec/specs/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/.claude-plugin/plugin.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/.codex-plugin/plugin.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/.cursor-plugin/plugin.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/commands/install.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/commands/update.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/hooks/cursor-hooks.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/hooks/hooks.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/package.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/plugin.mjs` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/scripts/invoke-install.cmd` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/scripts/invoke-install.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/scripts/invoke-install.sh` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/skills/install/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `plugins/1c-rules/skills/update/SKILL.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `scripts/install.sh` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `tools/koda-mcp-setup.ps1` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `tools/refresh-openspec-bundle.ps1` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `tools/render-gate-evals.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/rules-rationale.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/agent-adapters.ps1` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `tools/tests/eval-fixtures/S102/CommonModules/РаботаСЗаказами/Ext/Module.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/S147/openspec/changes/import-lines/tasks.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-fixtures/common/CommonModules/ОбменССайтом/Ext/Module.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/common/CommonModules/РаботаСЗаказами/Ext/Module.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/common/CommonModules/РаботаСКонтрагентамиСервер/Ext/Module.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/common/CommonModules/СкладыСервер/Ext/Module.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/common/Documents/РеализацияТоваровУслуг/Ext/ManagerModule.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/common/Documents/РеализацияТоваровУслуг/Ext/ObjectModule.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/common/README.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-fixtures/sets/openspec-import-lines/CommonModules/ИмпортСтрокСервер/Ext/Module.bsl` | Согласование существующего форк-файла с upstream |
| `tools/tests/eval-fixtures/sets/openspec-import-lines/openspec/changes/import-lines/proposal.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-fixtures/sets/openspec-import-lines/openspec/changes/import-lines/specs/import/spec.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-fixtures/sets/openspec-import-lines/openspec/changes/import-lines/tasks.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-code-check-mcp/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-code-check-mcp/_tools.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-code-metadata-mcp/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-code-metadata-mcp/_tools.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-graph-metadata-mcp/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-graph-metadata-mcp/_tools.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-syntax-checker-mcp/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-syntax-checker-mcp/_tools.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-templates-mcp/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/1c-templates-mcp/_tools.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/_world.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/cognee-memory/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/eval-mocks/openviking/_server.md` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/files-update-task.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka.xml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka/Forms/AuxForm.xml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka/Forms/AuxForm/Ext/Form.xml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka/Forms/AuxForm/Ext/Form/Module.bsl` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka/Forms/MainForm.xml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka/Forms/MainForm/Ext/Form.xml` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fixtures/epf-with-form/Obrabotka/Forms/MainForm/Ext/Form/Module.bsl` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/fork-install-regression.py` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `tools/tests/gate-scenarios.json` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/initial-source-dump.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/installer-paths-regression.ps1` | Адаптация сохраняемой возможности форка или её регрессионная проверка |
| `tools/tests/marketplace-bootstrap.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/md-to-docx-regression.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/metadata-tools-regression.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/python-ports-regression.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/tool-policy-settings.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/transcribe-regression.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/tests/web-python-regression.py` | Принято обновление upstream; общая структура/инструменты/тесты |
| `tools/validate-rules.ps1` | Принято обновление upstream; общая структура/инструменты/тесты |


Дополнительные файлы, появившиеся после начального перечня:

- `openspec/specs/minimal-fork-integration/spec.md` — текущие требования после синхронизации.
- `tools/tests/opencode-config-preservation.ps1` — новые регрессии upstream.

Остальные файлы добавочного переноса перечислены выше; содержимое инструментов метаданных совпадает с новым upstream `c1fb8e6`. Локальная память и исходный незакоммиченный `content/rules/system-safety.md` сохранены вне коммитов.
