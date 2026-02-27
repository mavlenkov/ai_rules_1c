# План тестирования: мультитул-поддержка

## Подготовка

### Предусловия
- [ ] Python 3 установлен
- [ ] MCP-серверы vibecoding1c.ru запущены (хотя бы один, например docs на порту 8003)
- [ ] Установлен Claude Code (`claude --version`)
- [ ] Установлен OpenCode (`opencode --version`)
- [ ] Cursor IDE доступен

### Тестовая директория
```bash
mkdir -p /tmp/test-1c-project
```

---

## 1. Скрипт инициализации

### 1.1 Полная инициализация (все инструменты)
```bash
./scripts/init-project.sh /tmp/test-1c-project
```
- [ ] Выполняется без ошибок
- [ ] Создан `.cursor/agents/` (12 файлов)
- [ ] Создан `.cursor/rules/` (11 файлов)
- [ ] Создан `.cursor/skills/`
- [ ] Создан `.cursor/commands/` (2 файла)
- [ ] Создан `.cursor/mcp.json` (8 серверов, localhost)
- [ ] Создан `CLAUDE.md`
- [ ] Создан `.mcp.json` (8 серверов, localhost)
- [ ] Создан `.claude/settings.json`
- [ ] Создан `AGENTS.md`
- [ ] Создан `opencode.json` (8 серверов + instructions)
- [ ] Создан `infobasesettings.md` (шаблон)

### 1.2 Частичная инициализация
```bash
rm -rf /tmp/test-partial && mkdir /tmp/test-partial
./scripts/init-project.sh /tmp/test-partial --tools claude
```
- [ ] Создан `CLAUDE.md`, `.mcp.json`, `.claude/settings.json`
- [ ] **НЕ** создан `.cursor/`, `AGENTS.md`, `opencode.json`

```bash
rm -rf /tmp/test-partial && mkdir /tmp/test-partial
./scripts/init-project.sh /tmp/test-partial --tools opencode
```
- [ ] Создан `AGENTS.md`, `opencode.json`
- [ ] **НЕ** создан `.cursor/`, `CLAUDE.md`, `.mcp.json`

### 1.3 Кастомный хост
```bash
rm -rf /tmp/test-host && mkdir /tmp/test-host
./scripts/init-project.sh /tmp/test-host --host 192.168.1.100
```
- [ ] `.cursor/mcp.json` содержит `192.168.1.100` (не localhost)
- [ ] `.mcp.json` содержит `192.168.1.100`
- [ ] `opencode.json` → mcp содержит `192.168.1.100`

### 1.4 Кастомные порты
```bash
echo '{"docs": 9003, "ssl": 9008}' > /tmp/ports.json
rm -rf /tmp/test-ports && mkdir /tmp/test-ports
./scripts/init-project.sh /tmp/test-ports --ports /tmp/ports.json
```
- [ ] docs-сервер на порту 9003 во всех трёх конфигах
- [ ] ssl-сервер на порту 9008 во всех трёх конфигах
- [ ] Остальные серверы на стандартных портах

### 1.5 Комбинация хост + порты
```bash
rm -rf /tmp/test-combo && mkdir /tmp/test-combo
./scripts/init-project.sh /tmp/test-combo --host mcp.server.local --ports /tmp/ports.json --tools cursor,claude
```
- [ ] Хост `mcp.server.local` + порты 9003/9008 для docs/ssl
- [ ] Только Cursor и Claude Code файлы

### 1.6 Режим --list
```bash
./scripts/init-project.sh --list
```
- [ ] Выводит маппинг для всех инструментов
- [ ] Выводит таблицу MCP-серверов с портами
- [ ] Ничего не копирует

```bash
./scripts/init-project.sh --list --tools claude
```
- [ ] Выводит только Claude Code маппинг

### 1.7 Повторная инициализация
```bash
./scripts/init-project.sh /tmp/test-1c-project
```
- [ ] Файлы обновлены
- [ ] `infobasesettings.md` **НЕ** перезаписан (сообщение «уже существует»)

### 1.8 Ошибки
```bash
./scripts/init-project.sh /tmp/nonexistent
```
- [ ] Ошибка: «директория не существует»

```bash
./scripts/init-project.sh
```
- [ ] Выводит справку

```bash
./scripts/init-project.sh /tmp/test-1c-project --ports /tmp/nonexistent.json
```
- [ ] Ошибка: «файл не найден»

---

## 2. Claude Code

### 2.1 Запуск в инициализированном проекте
```bash
cd /tmp/test-1c-project && claude
```
- [ ] Claude Code запускается без ошибок
- [ ] Видит `CLAUDE.md` (проверить: спросить «Какой язык проекта?» — должен ответить «русский»)

### 2.2 MCP-серверы
- [ ] Claude Code обнаруживает MCP-серверы из `.mcp.json`
- [ ] MCP-серверы отображаются (команда `/mcp` или подобная)
- [ ] При запущенных серверах: `docsearch` возвращает результаты
- [ ] При остановленных серверах: понятная ошибка

### 2.3 Правила
- [ ] Claude Code следует антипаттернам из `CLAUDE.md` при написании 1С кода
- [ ] Использует `ОбщегоНазначения.СообщитьПользователю` вместо `Сообщить()`

---

## 3. OpenCode

### 3.1 Запуск в инициализированном проекте
```bash
cd /tmp/test-1c-project && opencode
```
- [ ] OpenCode запускается без ошибок
- [ ] Видит `AGENTS.md` (проверить: спросить «Какой язык проекта?»)

### 3.2 MCP-серверы
- [ ] OpenCode обнаруживает MCP-серверы из `opencode.json`
- [ ] MCP-серверы отображаются (`opencode mcp list`)
- [ ] При запущенных серверах: `docsearch` возвращает результаты

### 3.3 Instructions
- [ ] OpenCode загружает `AGENTS.md`
- [ ] OpenCode загружает дополнительные файлы из `instructions` в opencode.json:
  - `.cursor/rules/anti-patterns.mdc`
  - `.cursor/rules/mcp-tools.mdc`

### 3.4 Fallback на CLAUDE.md
```bash
rm -rf /tmp/test-fallback && mkdir /tmp/test-fallback
./scripts/init-project.sh /tmp/test-fallback --tools claude
cd /tmp/test-fallback && opencode
```
- [ ] OpenCode запускается (нет `AGENTS.md`, но есть `CLAUDE.md`)
- [ ] Использует `CLAUDE.md` как инструкции (fallback)

---

## 4. Cursor IDE

### 4.1 Открытие проекта
- [ ] Cursor видит `.cursor/rules/` — правила загружены
- [ ] Cursor видит `.cursor/agents/` — агенты доступны
- [ ] Cursor видит `.cursor/mcp.json` — MCP-серверы подключены

### 4.2 MCP-серверы
- [ ] MCP-серверы из `.cursor/mcp.json` отображаются в настройках
- [ ] При запущенных серверах: инструменты работают

---

## 5. Кросс-проверки

### 5.1 Одинаковые MCP-серверы
```bash
python3 -c "
import json
cursor = json.load(open('/tmp/test-1c-project/.cursor/mcp.json'))
claude = json.load(open('/tmp/test-1c-project/.mcp.json'))
oc = json.load(open('/tmp/test-1c-project/opencode.json'))
print(f'Cursor:   {len(cursor[\"mcpServers\"])} серверов')
print(f'Claude:   {len(claude[\"mcpServers\"])} серверов')
print(f'OpenCode: {len(oc[\"mcp\"])} серверов')
"
```
- [ ] Все три: 8 серверов
- [ ] URL-ы совпадают (одинаковый хост и порты)

### 5.2 Содержимое правил
- [ ] `CLAUDE.md` и `AGENTS.md` содержат одинаковые ключевые правила (антипаттерны, MCP workflow)
- [ ] Формат адаптирован под каждый инструмент

---

## 6. Документация

- [ ] `deploy/README.md` — схема развёртывания актуальна
- [ ] `deploy/README.md` — секции --host и --ports присутствуют
- [ ] `README.md` — быстрый старт с примерами --host/--ports
- [ ] `openspec/specs/multi-tool-support/spec.md` — requirement «Настраиваемые хост и порты»
- [ ] `scripts/init-project.sh --help` — справка корректна

---

## Очистка после тестирования
```bash
rm -rf /tmp/test-1c-project /tmp/test-partial /tmp/test-host /tmp/test-ports /tmp/test-combo /tmp/test-fallback /tmp/ports.json
```
