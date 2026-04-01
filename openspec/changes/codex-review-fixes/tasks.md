## 1. init-project.sh — критические исправления

- [ ] 1.1 Валидация `--tools`: перед началом установки проверить наличие `deploy/<tool>.json` для каждого tool, exit 1 при ошибке
- [ ] 1.2 OpenCode без Cursor: при `opencode` в tools — авто-копировать `.cursor/rules/anti-patterns.mdc` и `.cursor/rules/mcp-tools.mdc`
- [ ] 1.3 Обработка ошибок python3: отделить «python3 не найден» от ошибок выполнения, показывать реальный stderr
- [ ] 1.4 Сохранение пользовательских файлов: заменить `rmtree+copytree` на `copytree(dirs_exist_ok=True)`
- [ ] 1.5 Проверить python3 один раз в начале скрипта, exit 1 если отсутствует

## 2. VCS — убрать сгенерированные и локальные файлы

- [ ] 2.1 Добавить в `.gitignore`: `.cursor/mcp.json`, `.mcp.json`, `opencode.json`, `.claude/settings.local.json`
- [ ] 2.2 `git rm --cached` для `.cursor/mcp.json`, `.mcp.json`, `opencode.json`, `.claude/settings.local.json`
- [ ] 2.3 Обновить `deploy/README.md` — указать что MCP-конфиги генерируются, не хранятся в VCS

## 3. settings.json — безопасные дефолты

- [ ] 3.1 В `.claude/settings.json` (шаблон): заменить `bypassPermissions` на `default`
- [ ] 3.2 Убрать `git add`, `git commit` из дефолтных разрешений — оставить только Read-правила

## 4. Команды — URL тестирования

- [ ] 4.1 В `deploy_and_test.md` секция testing: заменить `http://localhost/MyBase/ru/` на `<URL from infobasesettings.md>`
- [ ] 4.2 Добавить пояснение: если URL не задан — пропустить тестирование

## 5. Specs — убрать несуществующие элементы

- [ ] 5.1 В `openspec/specs/multi-tool-support/spec.md`: убрать `.cursor/settings.json`, `.claude/agents/`, `.opencode/commands/` из File Mapping

## 6. Документация — синхронизация с реальностью

- [ ] 6.1 README: упомянуть OpenSpec-команды (opsx-apply, opsx-propose и т.д.) в секции Команды
- [ ] 6.2 README: уточнить что навыки `1c-form-*`, `1c-mxl-*` и др. — подкоманды `1c-metadata-manage`, а не отдельные skills

## 7. Валидация

- [ ] 7.1 Проверить `init-project.sh --tools opencode` на чистом проекте — rules скопированы
- [ ] 7.2 Проверить `init-project.sh --tools typo` — exit 1 до начала копирования
- [ ] 7.3 Проверить повторный запуск — пользовательские файлы сохранены
- [ ] 7.4 Проверить что `.cursor/mcp.json` и `.mcp.json` не в git tracking
