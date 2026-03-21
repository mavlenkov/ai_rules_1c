# Отчёт: находки при тестировании на проекте ЕвротестРасширение

**Дата:** 2026-03-02
**Тестовый проект:** ЕвротестРасширение (расширение конфигурации ЛИС 1С)
**Стенд:** rigel:1541\Евротест

---

## 1. MCP-серверы: `.mcp.json` — отсутствует `"type": "http"`

### Проблема

Claude Code не подключает MCP-серверы, если в `.mcp.json` указан только `"url"` без `"type"`.

**Не работает:**
```json
{
  "mcpServers": {
    "1c-docs-mcp": {
      "url": "http://localhost:8003/mcp"
    }
  }
}
```

**Работает:**
```json
{
  "mcpServers": {
    "1c-docs-mcp": {
      "type": "http",
      "url": "http://localhost:8003/mcp"
    }
  }
}
```

### Что исправить

- **`deploy/claude.json`** — добавить `"type": "http"` в шаблон генерации `.mcp.json`
- **`.mcp.json`** (корень проекта) — добавить `"type": "http"` ко всем серверам
- **`deploy/mcp-servers.json`** — добавить поле `"transport": "http"` в описание серверов, чтобы скрипт генерации учитывал его
- **`deploy/README.md`** и **`README.md`** — упомянуть, что `"type": "http"` обязателен для Claude Code

### Примечание по SSE

`"type": "sse"` — deprecated. Серверы comol/* с `USESSE=false` работают через streamable HTTP. Claude Code поддерживает `"type": "http"` для этого транспорта.

---

## 2. deploy_and_test: пробел в строке подключения `/S`

### Проблема

В `infobasesettings.md` формат подключения документируется как:
```
/S 'servername\basename'
```

Скрипт `1CFilesConverter/scripts/conf2ib.sh` парсит этот параметр и строит `IBConnectionString`:
```
Srvr=" servername:1541";Ref="basename";
```

**Пробел перед именем сервера** приводит к тому, что Designer не находит базу. При этом Designer завершается с **exit code 0** и выдаёт только предупреждение:
```
Неопределена информационная база
```

Скрипт конвертера воспринимает это как успех и пишет `Database configuration updated successfully`.

### Правильный формат

```
/Sservername\basename
```

Без пробела после `/S`, без кавычек.

### Что исправить

- **`.cursor/commands/deploy_and_test.md`** — секция `installation`:
  - Изменить документированный формат с `/S 'servername\basename'` на `/Sservername\basename`
  - То же для `/F` — `/F/path/to/InfoBase` (без пробела)
  - Добавить предупреждение: "Пробел после /S или /F приведёт к невалидной строке подключения"

- **`.cursor/commands/deploy_and_test.md`** — секция Mode 1 Parameter mapping:
  - Уже написано `strip quotes, format as /F... or /S... (no space after flag)` — но пример в секции installation противоречит этому. Привести в соответствие.

- **`.cursor/commands/deploy_and_test.md`** — секция Mode 2:
  - Примеры тоже используют `/S 'servername\basename'` с пробелом — исправить

- **Примеры в секции Mode 1 Commands** — уже правильные (`/F/tmp/test_ib`), но добавить серверный пример:
  ```bash
  ~/Проекты/1CFilesConverter/scripts/conf2ib.sh . /Srigel:1541\Евротест
  ```

### Дополнительно: валидация в deploy_and_test

Рассмотреть добавление проверки в инструкцию:
- После запуска проверять лог Designer на наличие "Неопределена информационная база" — если есть, это ошибка подключения
- "Загрузка не должна менять принадлежность" — штатное предупреждение для расширений, не ошибка

---

## 3. deploy_and_test: логи конвертера удаляются

### Проблема

Скрипт `conf2ib.sh` удаляет временную директорию (`/tmp/1c/conf2ib/`) по завершении, включая `v8_designer_output.log`. Это делает невозможной диагностику проблем.

### Что исправить

В инструкции `deploy_and_test.md` упомянуть:
- Лог Designer **удаляется** после работы скрипта
- Для диагностики: запускать через `bash -x` чтобы видеть трейс команд и содержимое лога
- Наличие в выводе скрипта строки `[WARN] Неопределена информационная база` — это **ошибка подключения**, не успех

---

## 4. deploy_and_test: выход Mode 2 с `/S` на серверной ИБ

### Проблема

В Mode 2 (Designer fallback) примеры команд используют:
```
<V8_PATH> DESIGNER /S 'servername\basename' /DisableStartupMessages ...
```

Для Linux Designer ожидает формат без кавычек:
```
/opt/1cv8/.../1cv8 DESIGNER /Sservername\basename /DisableStartupMessages ...
```

Или через `/IBConnectionString`:
```
/opt/1cv8/.../1cv8 DESIGNER /IBConnectionString 'Srvr="servername";Ref="basename";' /DisableStartupMessages ...
```

### Что исправить

Привести примеры Mode 2 в соответствие с рабочим форматом. Рекомендую использовать `/IBConnectionString` для серверных ИБ — это явно и однозначно.

---

## 5. deploy_and_test: не поддерживает расширения (`-Extension`)

### Проблема

Инструкция `deploy_and_test.md` не учитывает, что проект может быть **расширением** конфигурации. Команда `LoadConfigFromFiles` без флага `-Extension <ИмяРасширения>` загружает XML в **основную конфигурацию**, а не в расширение.

Это приводит к тому, что:
- Для расширений `conf2ib.sh` молча загружает код в основную конфигурацию (Designer не ошибается)
- Расширение в ИБ остаётся неизменным
- Ошибка обнаруживается только при ручной проверке

### Рабочий вариант (прямой вызов Designer)

```bash
# Загрузка расширения
/opt/1cv8/x86_64/8.3.27.1859/1cv8 DESIGNER \
  /IBConnectionString 'Srvr="rigel:1541";Ref="Евротест";' \
  /NАдминистратор /DisableStartupDialogs /DisableStartupMessages \
  /LoadConfigFromFiles . -Extension Евротест /Out /tmp/1c/ext_load.log

# Обновление структуры БД расширения
/opt/1cv8/x86_64/8.3.27.1859/1cv8 DESIGNER \
  /IBConnectionString 'Srvr="rigel:1541";Ref="Евротест";' \
  /NАдминистратор /DisableStartupDialogs /DisableStartupMessages \
  /UpdateDBCfg -Extension Евротест /Out /tmp/1c/ext_updatedb.log
```

### Альтернатива: ext2ib.sh

В 1CFilesConverter уже есть `scripts/ext2ib.sh` для расширений:
```bash
~/Проекты/1CFilesConverter/scripts/ext2ib.sh <SRC_PATH> <IB_PATH> <EXT_NAME>
```

### Что исправить

- **`.cursor/commands/deploy_and_test.md`** — добавить:
  - Параметр `V8_EXT_NAME` (или `Extension name`) в `infobasesettings.md`
  - Условие: если указано имя расширения → использовать `ext2ib.sh` вместо `conf2ib.sh`
  - Для Mode 2 (прямой Designer): добавить `-Extension <имя>` к `LoadConfigFromFiles` и `UpdateDBCfg`
  - Автодетекция: если в корне проекта есть `Configuration.xml` с `ConfigurationExtensionCompatibilityMode` — это расширение

- **`infobasesettings.md`** (шаблон) — добавить опциональное поле:
  ```markdown
  ## Расширение (если применимо)
  Имя расширения в ИБ:
  Евротест
  ```

---

## 6. MCP docker-compose: `RESET_DATABASE` для docs

### Контекст (не для cursor_rules_1c, но связано)

В `mcp-deployment/docker-compose.yml` у сервиса `1c-docs` отсутствовала переменная `RESET_DATABASE`. Дефолт внутри контейнера — `True`. Это приводило к переиндексации всей документации 1С (~15 мин, 300 МБ) при каждом перезапуске контейнера.

Если в cursor_rules_1c есть шаблоны docker-compose или инструкции по развёртыванию MCP — добавить напоминание: **всем сервисам с ChromaDB необходимо явно передавать `RESET_DATABASE=false`**.

---

## Резюме приоритетов

| # | Что | Приоритет | Файлы |
|---|-----|-----------|-------|
| 1 | `"type": "http"` в MCP-конфигах | **Высокий** | `.mcp.json`, `deploy/claude.json`, `deploy/mcp-servers.json` |
| 2 | Пробел в `/S` подключении | **Высокий** | `.cursor/commands/deploy_and_test.md` |
| 3 | Удаление логов + диагностика | Средний | `.cursor/commands/deploy_and_test.md` |
| 4 | Формат `/S` в Mode 2 | Средний | `.cursor/commands/deploy_and_test.md` |
| 5 | Поддержка расширений (`-Extension`) | **Высокий** | `.cursor/commands/deploy_and_test.md`, `infobasesettings.md` |
| 6 | `RESET_DATABASE` для docs | Низкий | `deploy/README.md` (если есть docker-инструкции) |
