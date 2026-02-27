#!/bin/bash
#
# Инициализация проекта 1С для работы с Cursor, Claude Code и OpenCode.
# Копирует конфигурации AI-инструментов и генерирует MCP-конфиги из единого шаблона.
#
# Использование:
#   ./init-project.sh /path/to/1c-project [--tools cursor,claude,opencode] [--host HOST] [--ports FILE]
#   ./init-project.sh --list [--tools cursor,claude,opencode]
#
# По умолчанию устанавливаются все три инструмента.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DIR="$REPO_DIR/deploy"
MCP_TEMPLATE="$DEPLOY_DIR/mcp-servers.json"

TOOLS="cursor,claude,opencode"
TARGET_DIR=""
LIST_MODE=false
CUSTOM_HOST=""
CUSTOM_PORTS=""

usage() {
    echo "Инициализация проекта 1С для AI-инструментов"
    echo ""
    echo "Использование:"
    echo "  $0 <путь-к-проекту> [опции]"
    echo "  $0 --list [--tools ...]"
    echo ""
    echo "Параметры:"
    echo "  <путь-к-проекту>    Путь к целевому проекту 1С"
    echo "  --tools <список>    Инструменты для настройки (по умолчанию: все)"
    echo "                      cursor   — .cursor/ (правила, агенты, навыки, команды, MCP)"
    echo "                      claude   — CLAUDE.md, .mcp.json, .claude/settings.json"
    echo "                      opencode — AGENTS.md, opencode.json"
    echo "  --host <host>       Хост MCP-серверов (по умолчанию: localhost)"
    echo "  --ports <файл>      JSON-файл с переопределением портов серверов"
    echo "                      Формат: {\"code-metadata\": 9000, \"docs\": 9003, ...}"
    echo "  --list              Показать маппинг файлов без копирования"
    echo "  --help, -h          Эта справка"
    echo ""
    echo "Примеры:"
    echo "  $0 ~/Проекты/МойПроект1С"
    echo "  $0 ~/Проекты/МойПроект1С --host 192.168.1.100"
    echo "  $0 ~/Проекты/МойПроект1С --host mcp.example.com --ports custom-ports.json"
    echo "  $0 --list --tools opencode"
    echo ""
    echo "Подробнее: deploy/README.md"
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --tools)
            shift
            TOOLS="${1:-}"
            [ -z "$TOOLS" ] && { echo "Ошибка: --tools требует список инструментов"; usage; }
            ;;
        --host)
            shift
            CUSTOM_HOST="${1:-}"
            [ -z "$CUSTOM_HOST" ] && { echo "Ошибка: --host требует значение"; usage; }
            ;;
        --ports)
            shift
            CUSTOM_PORTS="${1:-}"
            [ -z "$CUSTOM_PORTS" ] && { echo "Ошибка: --ports требует путь к файлу"; usage; }
            [ ! -f "$CUSTOM_PORTS" ] && { echo "Ошибка: файл '$CUSTOM_PORTS' не найден"; exit 1; }
            ;;
        --list)
            LIST_MODE=true
            ;;
        --help|-h)
            usage
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            else
                echo "Неизвестный параметр: $1"
                usage
            fi
            ;;
    esac
    shift
done

# --- Python helper для работы с MCP ---

generate_mcp_configs() {
    local target="$1"
    local tools="$2"

    python3 -c "
import json, os, sys

template = json.load(open('$MCP_TEMPLATE'))
host = '${CUSTOM_HOST}' or template.get('host', 'localhost')
ports_file = '${CUSTOM_PORTS}'

port_overrides = {}
if ports_file:
    port_overrides = json.load(open(ports_file))

target = '$target'
tools = '$tools'.split(',')

for s in template['servers']:
    sid = s['id']
    if sid in port_overrides:
        s['port'] = port_overrides[sid]
    s['url'] = f\"http://{host}:{s['port']}{s['path']}\"

# --- Cursor: .cursor/mcp.json ---
if 'cursor' in tools:
    cursor_cfg = {'mcpServers': {}}
    for s in template['servers']:
        cursor_cfg['mcpServers'][s['cursor_name']] = {
            'url': s['url'],
            'connection_id': s['cursor_connection_id']
        }
    dst = os.path.join(target, '.cursor', 'mcp.json')
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, 'w') as f:
        json.dump(cursor_cfg, f, indent=2, ensure_ascii=False)
    print(f\"  ✓ .cursor/mcp.json              (8 серверов, хост: {host})\")

# --- Claude Code: .mcp.json ---
if 'claude' in tools:
    claude_cfg = {'mcpServers': {}}
    for s in template['servers']:
        claude_cfg['mcpServers'][s['claude_name']] = {
            'url': s['url']
        }
    dst = os.path.join(target, '.mcp.json')
    with open(dst, 'w') as f:
        json.dump(claude_cfg, f, indent=2, ensure_ascii=False)
    print(f\"  ✓ .mcp.json                     (8 серверов, хост: {host})\")

# --- OpenCode: opencode.json ---
if 'opencode' in tools:
    oc_path = os.path.join(target, 'opencode.json')
    oc_cfg = {}
    if os.path.exists(oc_path):
        oc_cfg = json.load(open(oc_path))
    else:
        oc_cfg = {
            '\$schema': 'https://opencode.ai/config.json',
            'instructions': ['AGENTS.md', '.cursor/rules/anti-patterns.mdc', '.cursor/rules/mcp-tools.mdc']
        }

    oc_cfg['mcp'] = {}
    for s in template['servers']:
        oc_cfg['mcp'][s['opencode_name']] = {
            'type': 'remote',
            'url': s['url'],
            'enabled': True,
            'timeout': 10000
        }
    with open(oc_path, 'w') as f:
        json.dump(oc_cfg, f, indent=2, ensure_ascii=False)
    print(f\"  ✓ opencode.json → mcp            (8 серверов, хост: {host})\")
" 2>/dev/null || {
        echo "  Ошибка: python3 недоступен для генерации MCP-конфигов"
        echo "  Установите python3 или сконфигурируйте вручную"
        return 1
    }
}

show_mcp_info() {
    python3 -c "
import json
t = json.load(open('$MCP_TEMPLATE'))
host = '${CUSTOM_HOST}' or t.get('host', 'localhost')
print(f'  Хост: {host}')
print()
print(f'  {\"Сервер\":<20s} {\"Порт\":<8s} {\"Описание\"}')
print(f'  {\"─\"*20} {\"─\"*8} {\"─\"*35}')
for s in t['servers']:
    print(f\"  {s['id']:<20s} {s['port']:<8d} {s['description']}\")
print()
" 2>/dev/null || echo "  (python3 недоступен)"
}

# --- Маппинг файлов (без MCP — те генерируются) ---

show_mapping() {
    local tool_name="$1"
    local manifest="$DEPLOY_DIR/${tool_name}.json"

    if [ ! -f "$manifest" ]; then
        echo "  Манифест $manifest не найден"
        return
    fi

    python3 -c "
import json
m = json.load(open('$manifest'))
print(f\"=== {m['tool']} ===\")
print(f\"  {m.get('description', '')}\")
note = m.get('note')
if note:
    print(f'  Примечание: {note}')
print()
for f in m['files']:
    src = f['source']
    tgt = f['target']
    desc = f.get('description', '')
    gen = ' [генерируется]' if f.get('generated') else ''
    print(f'  {src:<30s} → {tgt:<30s} ({desc}){gen}')
print()
" 2>/dev/null || {
        echo "  (python3 недоступен)"
    }
}

install_tool() {
    local tool_name="$1"
    local manifest="$DEPLOY_DIR/${tool_name}.json"

    if [ ! -f "$manifest" ]; then
        echo "  Манифест $manifest не найден"
        return
    fi

    python3 -c "
import json, os, shutil

manifest = json.load(open('$manifest'))
repo = '$REPO_DIR'
target = '$TARGET_DIR'

print(f\"=== {manifest['tool']} ===\")

for f in manifest['files']:
    if f.get('generated'):
        continue

    src = os.path.join(repo, f['source'])
    dst = os.path.join(target, f['target'])

    os.makedirs(os.path.dirname(dst) if f['type'] == 'file' else dst, exist_ok=True)

    if f['type'] == 'directory':
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
    else:
        shutil.copy2(src, dst)

    print(f\"  ✓ {f['target']:<35s} {f.get('description', '')}\")
print()
" 2>/dev/null || {
        echo "  Ошибка: python3 недоступен"
    }
}

# --- LIST ---

if $LIST_MODE; then
    echo "Маппинг файлов при развёртывании"
    echo "Репозиторий: $REPO_DIR"
    echo ""

    IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
    for tool in "${TOOL_LIST[@]}"; do
        tool="$(echo "$tool" | xargs)"
        show_mapping "$tool"
    done

    echo "MCP-серверы (генерируются из deploy/mcp-servers.json):"
    show_mcp_info

    echo "Общие файлы:"
    echo "  (создаётся скриптом)              → infobasesettings.md       (шаблон подключения к ИБ)"
    echo ""
    echo "Для установки: $0 <путь-к-проекту> --tools $TOOLS"
    exit 0
fi

# --- INSTALL ---

if [ -z "$TARGET_DIR" ]; then
    echo "Ошибка: не указан путь к целевому проекту"
    echo ""
    usage
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Ошибка: директория '$TARGET_DIR' не существует"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo "Целевой проект: $TARGET_DIR"
echo "Инструменты:    $TOOLS"
[ -n "$CUSTOM_HOST" ] && echo "Хост MCP:        $CUSTOM_HOST"
[ -n "$CUSTOM_PORTS" ] && echo "Порты:           $CUSTOM_PORTS"
echo ""

IFS=',' read -ra TOOL_LIST <<< "$TOOLS"

for tool in "${TOOL_LIST[@]}"; do
    tool="$(echo "$tool" | xargs)"
    install_tool "$tool"
done

echo "=== MCP-серверы ==="
generate_mcp_configs "$TARGET_DIR" "$TOOLS"
echo ""

SETTINGS_FILE="$TARGET_DIR/infobasesettings.md"
if [ ! -f "$SETTINGS_FILE" ]; then
    cat > "$SETTINGS_FILE" << 'HEREDOC'
# Настройки информационной базы

## Подключение
<!-- Раскомментируйте нужный вариант -->

<!-- Файловая ИБ: -->
<!-- /F '/path/to/InfoBase' -->

<!-- Серверная ИБ: -->
<!-- /S 'server\basename' -->

## Аутентификация
<!-- Имя пользователя: -->
<!-- /N 'Администратор' -->
<!-- Пароль (опустите /P если пустой): -->
<!-- /P '' -->

## URL тестирования
<!-- http://localhost/MyBase/ru/ -->
HEREDOC
    echo "  ✓ infobasesettings.md (шаблон)"
else
    echo "  – infobasesettings.md уже существует"
fi

echo ""
echo "=== Готово ==="
echo ""
echo "Следующие шаги:"
echo "  1. Отредактируйте infobasesettings.md — укажите подключение к ИБ"
echo "  2. Запустите MCP-серверы (https://docs.onerpa.ru/mcp-servery-1c)"

for tool in "${TOOL_LIST[@]}"; do
    tool="$(echo "$tool" | xargs)"
    case "$tool" in
        cursor)   echo "  3. Cursor: откройте папку проекта в Cursor IDE" ;;
        claude)   echo "  3. Claude Code: cd $TARGET_DIR && claude" ;;
        opencode) echo "  3. OpenCode: cd $TARGET_DIR && opencode" ;;
    esac
done

echo ""
echo "Подробнее: deploy/README.md"
