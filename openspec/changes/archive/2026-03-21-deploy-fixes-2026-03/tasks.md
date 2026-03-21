## 1. MCP-конфиги: добавить type:http

- [x] 1.1 Добавить `"transport": "http"` в `deploy/mcp-servers.json` для всех серверов
- [x] 1.2 Обновить `scripts/init-project.sh` — при генерации `.mcp.json` учитывать поле `transport` и добавлять `"type": "http"`
- [x] 1.3 Добавить `"type": "http"` ко всем серверам в `.mcp.json` (корень проекта)
- [x] 1.4 Обновить шаблон `deploy/claude.json` — добавить `"type": "http"` в каждую запись (реализовано через transport в mcp-servers.json + генератор)
- [x] 1.5 Проверить, что `.cursor/mcp.json` и `opencode.json` НЕ содержат лишнего `"type"`
- [x] 1.6 Упомянуть в `deploy/README.md`, что `"type": "http"` обязателен для Claude Code

## 2. Формат строки подключения /S и /F

- [x] 2.1 Исправить формат `/S` в `.cursor/commands/deploy_and_test.md` — убрать пробел и кавычки во всех секциях (installation, Mode 1, Mode 2)
- [x] 2.2 Исправить формат `/F` в `.cursor/commands/deploy_and_test.md` — убрать пробел после флага
- [x] 2.3 Привести примеры Mode 2 к формату `/IBConnectionString 'Srvr="server";Ref="base";'` для серверных ИБ
- [x] 2.4 Исправить формат `/S` в `.cursor/commands/getconfigfiles.md`
- [x] 2.5 Исправить формат `/S` в `.cursor/rules/getconfigfiles.mdc`
- [x] 2.6 Исправить формат `/S` в `.cursor/agents/tester.md`
- [x] 2.7 Добавить серверный пример в секцию Mode 1 Commands (`conf2ib.sh . /Srigel:1541\Евротест`)

## 3. Поддержка расширений

- [x] 3.1 Добавить в `deploy_and_test.md` шаг автодетекции расширения по `Configuration.xml` → `ConfigurationExtensionCompatibilityMode`
- [x] 3.2 Добавить уведомление пользователя с именем расширения и запрос подтверждения
- [x] 3.3 Добавить условие: если расширение → использовать `ext2ib.sh` вместо `conf2ib.sh` (Mode 1)
- [x] 3.4 Добавить `-Extension <ExtName>` к `LoadConfigFromFiles` и `UpdateDBCfg` (Mode 2)
- [x] 3.5 Добавить опциональную секцию «Расширение» в шаблон `infobasesettings.md` в `init-project.sh`
- [x] 3.6 Добавить автозаполнение секции расширения при наличии `Configuration.xml` в целевом проекте

## 4. Диагностика

- [x] 4.1 Добавить секцию «Диагностика» в `deploy_and_test.md`
- [x] 4.2 Описать: «Неопределена информационная база» = ошибка подключения
- [x] 4.3 Описать: «Загрузка не должна менять принадлежность» = штатное предупреждение для расширений
- [x] 4.4 Описать: логи конвертера удаляются, для отладки использовать `bash -x`
- [x] 4.5 Описать: exit code 0 от Designer не гарантирует успех — проверять лог

## 5. Валидация

- [x] 5.1 Протестировать `init-project.sh` на чистом проекте — проверить генерацию `.mcp.json` с `"type": "http"`
- [x] 5.2 Проверить подключение MCP-серверов в Claude Code, Cursor и OpenCode
- [x] 5.3 Проверить корректность формата `/S` во всех изменённых файлах (grep на `/S '` и `/S ` с пробелом)
