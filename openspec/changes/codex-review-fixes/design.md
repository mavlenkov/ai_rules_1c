# Design: codex-review-fixes

## D1: --tools opencode без cursor — авто-копирование rules

**Проблема:** `opencode.json` ссылается на `.cursor/rules/anti-patterns.mdc` и `.cursor/rules/mcp-tools.mdc`, но при `--tools opencode` эти файлы не копируются.

**Решение:** В `init-project.sh` при наличии `opencode` в списке tools — автоматически копировать `.cursor/rules/anti-patterns.mdc` и `.cursor/rules/mcp-tools.mdc` (создать `.cursor/rules/` если нет). Не копировать весь каталог rules — только те файлы, на которые ссылается `opencode.json`.

**Альтернатива:** Запретить `--tools opencode` без `cursor`. Отклонено — ограничивает пользователя без необходимости.

## D2: Сгенерированные MCP-конфиги — убрать из VCS

**Проблема:** `.cursor/mcp.json`, `.mcp.json`, `opencode.json` закоммичены с локальным хостом `alcor`. При ручном копировании пользователь получает чужую инфраструктуру.

**Решение:**
1. Добавить в `.gitignore`: `.cursor/mcp.json`, `.mcp.json`, `opencode.json`
2. Удалить из git tracking (git rm --cached)
3. В `deploy/README.md` явно указать: эти файлы генерируются скриптом, в VCS не хранятся
4. Для ручной установки — описать шаги генерации или дать пример с localhost

## D3: Улучшение обработки ошибок в init-project.sh

**Проблема:** Ошибки python3 (битый JSON, синтаксические ошибки) маскируются как «python3 недоступен». Скрипт оставляет проект полуинициализированным.

**Решение:**
1. Разделить проверку наличия python3 и ошибки выполнения
2. Сначала `python3 --version` — если нет, сообщить и выйти
3. При ошибке python-кода — показать реальную ошибку (stderr)
4. При ошибке — не продолжать (exit 1)

## D4: Валидация --tools

**Проблема:** Опечатка в `--tools` (например `typo`) молча проходит с exit 0.

**Решение:** Перед началом установки проверить каждый tool из списка на наличие манифеста `deploy/<tool>.json`. Если хотя бы один не найден — вывести ошибку и exit 1.

## D5: Сохранение пользовательских файлов при повторной инициализации

**Проблема:** `shutil.rmtree` удаляет весь каталог `.cursor/skills/`, `.cursor/agents/` и т.д., включая пользовательские дополнения.

**Решение:** Вместо rmtree+copytree — копировать поверх (overwrite existing, keep extra). Использовать `shutil.copytree` с `dirs_exist_ok=True` (Python 3.8+). Пользовательские файлы, которых нет в репозитории, останутся.

## D6: URL тестирования — убрать hardcode

**Проблема:** В секции testing жёстко прописан `http://localhost/MyBase/ru/`.

**Решение:** Заменить на `<TEST_URL from infobasesettings.md>` с пояснением.

## D7: settings.json — смягчить дефолт

**Проблема:** `bypassPermissions` + `git add/commit` в шаблоне — агрессивно для публичного toolkit.

**Решение:** В шаблоне (deploy/claude.json → .claude/settings.json) убрать `bypassPermissions`, оставить `"defaultMode": "default"`. Разрешения git оставить как Read-only. Текущий settings.json в репозитории (наш рабочий) — это наш личный конфиг, его тоже стоит исключить из VCS или сделать шаблонным.

## D8: settings.local.json — убрать из VCS

**Решение:** Добавить `.claude/settings.local.json` в `.gitignore`, удалить из tracking.

## D9: Документация — синхронизация

**Проблема:** README описывает skills как отдельные, а они подкоманды `1c-metadata-manage`. Не упомянуты OpenSpec-команды. CLAUDE.md на английском.

**Решение:**
1. README: skills описать как подкоманды `1c-metadata-manage`, а не отдельные навыки (это upstream — не трогаем их описание, но наш мультитул-блок должен быть точным)
2. README: добавить упоминание OpenSpec-команд в `.cursor/commands/`
3. CLAUDE.md: перевести на русский (или оставить — это специфика Claude Code, который работает с английским контекстом). Решение: оставить на английском с комментарием.
