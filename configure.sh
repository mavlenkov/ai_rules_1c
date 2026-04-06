#!/bin/bash
# Настройка MCP-серверов: замена localhost на указанный хост
# Использование: ./configure.sh <хост>
# Пример:  ./configure.sh myserver
#          ./configure.sh 192.168.1.80

set -euo pipefail

HOST="${1:-}"

if [ -z "$HOST" ]; then
    echo "Использование: $0 <хост>"
    echo "Пример: $0 myserver"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FILES=(
    "$SCRIPT_DIR/.mcp.json"
    "$SCRIPT_DIR/.cursor/mcp.json"
    "$SCRIPT_DIR/opencode.json"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        sed -i "s|http://localhost|http://$HOST|g" "$file"
        echo "✓ $(realpath --relative-to="$SCRIPT_DIR" "$file"): localhost → $HOST"
    else
        echo "✗ $(realpath --relative-to="$SCRIPT_DIR" "$file"): файл не найден"
    fi
done

# Скрываем локальные изменения от git
cd "$SCRIPT_DIR"
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        rel=$(realpath --relative-to="$SCRIPT_DIR" "$file")
        git update-index --skip-worktree "$rel" 2>/dev/null && \
            echo "✓ $rel: skip-worktree установлен" || \
            echo "✗ $rel: не удалось установить skip-worktree"
    fi
done

echo ""
echo "Готово. Для отката: git update-index --no-skip-worktree <файл> && git checkout -- <файл>"
