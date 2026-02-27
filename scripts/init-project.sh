#!/bin/bash
#
# Инициализация проекта 1С для работы с Cursor, Claude Code и OpenCode.
# Копирует конфигурации AI-инструментов и MCP-серверов в целевой проект.
#
# Использование:
#   ./init-project.sh /path/to/1c-project [--tools cursor,claude,opencode]
#
# По умолчанию устанавливаются все три инструмента.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Использование: $0 <путь-к-проекту> [--tools cursor,claude,opencode]"
    echo ""
    echo "Параметры:"
    echo "  <путь-к-проекту>    Путь к целевому проекту 1С"
    echo "  --tools <список>    Какие инструменты настроить (по умолчанию: все)"
    echo "                      cursor   — .cursor/ (правила, агенты, навыки, команды, MCP)"
    echo "                      claude   — CLAUDE.md, .mcp.json, .claude/settings.json"
    echo "                      opencode — AGENTS.md, opencode.json"
    echo ""
    echo "Примеры:"
    echo "  $0 ~/Проекты/МойПроект1С"
    echo "  $0 ~/Проекты/МойПроект1С --tools cursor,claude"
    echo "  $0 ~/Проекты/МойПроект1С --tools opencode"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

TARGET_DIR="$1"
shift

TOOLS="cursor,claude,opencode"

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
        --help|-h)
            usage
            ;;
        *)
            echo "Неизвестный параметр: $1"
            usage
            ;;
    esac
    shift
done

if [ ! -d "$TARGET_DIR" ]; then
    echo "Ошибка: директория '$TARGET_DIR' не существует"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo "Целевой проект: $TARGET_DIR"
echo "Инструменты: $TOOLS"
echo ""

install_cursor() {
    echo "=== Cursor IDE ==="

    if [ -d "$TARGET_DIR/.cursor" ]; then
        echo "  .cursor/ уже существует, обновляю..."
    fi

    mkdir -p "$TARGET_DIR/.cursor"

    for dir in agents rules skills commands; do
        if [ -d "$REPO_DIR/.cursor/$dir" ]; then
            cp -r "$REPO_DIR/.cursor/$dir" "$TARGET_DIR/.cursor/"
            echo "  ✓ .cursor/$dir/"
        fi
    done

    if [ -f "$REPO_DIR/.cursor/mcp.json" ]; then
        cp "$REPO_DIR/.cursor/mcp.json" "$TARGET_DIR/.cursor/mcp.json"
        echo "  ✓ .cursor/mcp.json"
    fi

    echo ""
}

install_claude() {
    echo "=== Claude Code ==="

    cp "$REPO_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    echo "  ✓ CLAUDE.md"

    cp "$REPO_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"
    echo "  ✓ .mcp.json"

    mkdir -p "$TARGET_DIR/.claude"
    cp "$REPO_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    echo "  ✓ .claude/settings.json"

    echo ""
}

install_opencode() {
    echo "=== OpenCode ==="

    cp "$REPO_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
    echo "  ✓ AGENTS.md"

    cp "$REPO_DIR/opencode.json" "$TARGET_DIR/opencode.json"
    echo "  ✓ opencode.json"

    echo ""
}

create_infobase_settings() {
    local SETTINGS_FILE="$TARGET_DIR/infobasesettings.md"
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
}

IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
for tool in "${TOOL_LIST[@]}"; do
    tool="$(echo "$tool" | xargs)"
    case "$tool" in
        cursor)   install_cursor ;;
        claude)   install_claude ;;
        opencode) install_opencode ;;
        *)        echo "Неизвестный инструмент: $tool" ;;
    esac
done

create_infobase_settings

echo "=== Готово ==="
echo ""
echo "Следующие шаги:"
echo "  1. Отредактируйте infobasesettings.md с параметрами вашей ИБ"
echo "  2. Убедитесь, что MCP-серверы запущены (https://vibecoding1c.ru/)"

if [[ "$TOOLS" == *"claude"* ]]; then
    echo "  3. Claude Code: выполните 'claude' в папке проекта"
fi
if [[ "$TOOLS" == *"opencode"* ]]; then
    echo "  3. OpenCode: выполните 'opencode' в папке проекта"
fi
