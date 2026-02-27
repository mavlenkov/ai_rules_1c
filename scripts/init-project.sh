#!/bin/bash
#
# Инициализация проекта 1С для работы с Cursor, Claude Code и OpenCode.
# Копирует конфигурации AI-инструментов и MCP-серверов в целевой проект.
#
# Использование:
#   ./init-project.sh /path/to/1c-project [--tools cursor,claude,opencode]
#   ./init-project.sh --list [--tools cursor,claude,opencode]
#
# По умолчанию устанавливаются все три инструмента.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_DIR="$REPO_DIR/deploy"

TOOLS="cursor,claude,opencode"
TARGET_DIR=""
LIST_MODE=false

usage() {
    echo "Инициализация проекта 1С для AI-инструментов"
    echo ""
    echo "Использование:"
    echo "  $0 <путь-к-проекту> [--tools cursor,claude,opencode]"
    echo "  $0 --list [--tools cursor,claude,opencode]"
    echo ""
    echo "Параметры:"
    echo "  <путь-к-проекту>    Путь к целевому проекту 1С"
    echo "  --tools <список>    Инструменты для настройки (по умолчанию: все)"
    echo "                      cursor   — .cursor/ (правила, агенты, навыки, команды, MCP)"
    echo "                      claude   — CLAUDE.md, .mcp.json, .claude/settings.json"
    echo "                      opencode — AGENTS.md, opencode.json"
    echo "  --list              Показать маппинг файлов без копирования"
    echo "  --help, -h          Эта справка"
    echo ""
    echo "Примеры:"
    echo "  $0 ~/Проекты/МойПроект1С"
    echo "  $0 ~/Проекты/МойПроект1С --tools cursor,claude"
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
            if [ -z "$TOOLS" ]; then
                echo "Ошибка: --tools требует список инструментов"
                usage
            fi
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

show_mapping() {
    local tool_name="$1"
    local manifest="$DEPLOY_DIR/${tool_name}.json"

    if [ ! -f "$manifest" ]; then
        echo "  Манифест $manifest не найден"
        return
    fi

    local tool_label
    tool_label=$(python3 -c "import json; print(json.load(open('$manifest'))['tool'])" 2>/dev/null || echo "$tool_name")

    echo "=== $tool_label ==="

    python3 -c "
import json, sys
m = json.load(open('$manifest'))
print(f\"  {m.get('description', '')}\" )
note = m.get('note')
if note:
    print(f'  Примечание: {note}')
print()
for f in m['files']:
    src = f['source']
    tgt = f['target']
    desc = f.get('description', '')
    print(f'  {src:<30s} → {tgt:<30s} ({desc})')
print()
" 2>/dev/null || {
        echo "  (python3 недоступен, показываю из манифеста)"
        echo "  Смотрите: $manifest"
        echo ""
    }
}

install_tool() {
    local tool_name="$1"
    local manifest="$DEPLOY_DIR/${tool_name}.json"

    if [ ! -f "$manifest" ]; then
        echo "  Манифест $manifest не найден, пропускаю"
        return
    fi

    local tool_label
    tool_label=$(python3 -c "import json; print(json.load(open('$manifest'))['tool'])" 2>/dev/null || echo "$tool_name")

    echo "=== $tool_label ==="

    python3 -c "
import json, os, shutil, sys

manifest = json.load(open('$manifest'))
repo = '$REPO_DIR'
target = '$TARGET_DIR'

for f in manifest['files']:
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
        echo "  Ошибка: python3 недоступен для обработки манифеста"
        echo "  Используйте ручную установку: deploy/README.md"
        echo ""
    }
}

if $LIST_MODE; then
    echo "Маппинг файлов при развёртывании"
    echo "Репозиторий: $REPO_DIR"
    echo ""

    IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
    for tool in "${TOOL_LIST[@]}"; do
        tool="$(echo "$tool" | xargs)"
        show_mapping "$tool"
    done

    echo "Общие файлы:"
    echo "  (создаётся скриптом)              → infobasesettings.md       (шаблон подключения к ИБ)"
    echo ""
    echo "Для установки: $0 <путь-к-проекту> --tools $TOOLS"
    exit 0
fi

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
echo ""

IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
for tool in "${TOOL_LIST[@]}"; do
    tool="$(echo "$tool" | xargs)"
    install_tool "$tool"
done

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
    echo "  – infobasesettings.md уже существует, пропускаю"
fi

echo ""
echo "=== Готово ==="
echo ""
echo "Следующие шаги:"
echo "  1. Отредактируйте infobasesettings.md — укажите подключение к ИБ"
echo "  2. Запустите MCP-серверы (https://vibecoding1c.ru/)"

for tool in "${TOOL_LIST[@]}"; do
    tool="$(echo "$tool" | xargs)"
    case "$tool" in
        cursor)   echo "  3. Cursor: откройте папку проекта в Cursor IDE" ;;
        claude)   echo "  3. Claude Code: cd $TARGET_DIR && claude" ;;
        opencode) echo "  3. OpenCode: cd $TARGET_DIR && opencode" ;;
    esac
done

echo ""
echo "Подробнее о развёртывании: deploy/README.md"
