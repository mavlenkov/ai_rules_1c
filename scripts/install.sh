#!/usr/bin/env bash
#
# Минимальный Linux-installer для ai_rules_1c (Linux + 1CFilesConverter edition).
# Реализует протокол AGENT-INSTALL.md в форме CLI — альтернатива install.ps1
# для Linux/CI-сценариев. По возможностям эквивалентен upstream-protocol'у
# в пределах поддерживаемых tools (cursor, claude-code, opencode).
#
# Использование:
#   ./install.sh <target-dir> [--tools cursor,claude-code,opencode] [--host HOST]
#
# По умолчанию: auto-detect активных tools, host=localhost.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET=""
TOOLS=""
HOST="localhost"

usage() {
    cat <<EOF
ai_rules_1c installer (Linux edition)

Usage:
  $0 <target-dir> [options]

Options:
  --tools <list>   Comma-separated tool ids: cursor, claude-code, opencode.
                   Default: auto-detect by adapter detection rules.
  --host <host>    MCP server host (substitutes 'localhost' in content/mcp-servers.json).
                   Default: localhost.
  --help, -h       This help.

Examples:
  $0 ~/Проекты/MyProject1C
  $0 ~/Проекты/MyProject1C --host alcor
  $0 ~/Проекты/MyProject1C --tools claude-code --host alcor
EOF
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --tools) shift; TOOLS="${1:-}" ;;
        --host)  shift; HOST="${1:-}"  ;;
        --help|-h) usage ;;
        *)
            if [ -z "$TARGET" ]; then TARGET="$1"
            else echo "Unexpected arg: $1"; usage; fi
            ;;
    esac
    shift
done

[ -z "$TARGET" ] && { echo "Ошибка: не указан target-dir"; usage; }
[ ! -d "$TARGET" ] && { echo "Ошибка: $TARGET не существует"; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

command -v python3 >/dev/null || { echo "Ошибка: python3 нужен для парсинга YAML"; exit 1; }

echo "ai_rules_1c installer"
echo "  Source: $REPO_DIR"
echo "  Target: $TARGET"
echo "  Host:   $HOST"
echo "  Tools:  ${TOOLS:-<auto-detect>}"
echo ""

python3 - "$REPO_DIR" "$TARGET" "$HOST" "$TOOLS" <<'PYEOF'
import json, os, re, shutil, sys
from pathlib import Path

REPO, TARGET, HOST, TOOLS_ARG = sys.argv[1:5]
REPO, TARGET = Path(REPO), Path(TARGET)

# --- Минимальный YAML-парсер для адаптеров ---------------------------------
# Поддерживает только нужные нам конструкции: scalars, lists, nested maps,
# inline-объекты в значениях (`{ mode: subagent }`). Без потоков, тегов и т.п.

def parse_yaml(text):
    lines = []
    for ln in text.splitlines():
        s = ln.split('#', 1)[0] if '#' in ln and not _in_quotes(ln, ln.find('#')) else ln
        if s.strip():
            lines.append(s)
    return _parse_block(lines, 0, 0)[0]

def _in_quotes(s, i):
    return s[:i].count('"') % 2 == 1 or s[:i].count("'") % 2 == 1

def _indent(line):
    return len(line) - len(line.lstrip(' '))

def _parse_inline_value(v):
    v = v.strip()
    if not v: return None
    if v.startswith('"') and v.endswith('"'): return v[1:-1]
    if v.startswith("'") and v.endswith("'"): return v[1:-1]
    if v.startswith('[') and v.endswith(']'):
        inner = v[1:-1].strip()
        if not inner: return []
        return [_parse_inline_value(x) for x in _split_flow(inner)]
    if v.startswith('{') and v.endswith('}'):
        inner = v[1:-1].strip()
        if not inner: return {}
        out = {}
        for pair in _split_flow(inner):
            k, _, vv = pair.partition(':')
            out[k.strip()] = _parse_inline_value(vv.strip())
        return out
    if v in ('true', 'True'): return True
    if v in ('false', 'False'): return False
    if v == 'null': return None
    try: return int(v)
    except: pass
    try: return float(v)
    except: pass
    return v

def _split_flow(s):
    depth = 0; out = []; cur = ''
    for ch in s:
        if ch in '[{': depth += 1; cur += ch
        elif ch in ']}': depth -= 1; cur += ch
        elif ch == ',' and depth == 0: out.append(cur.strip()); cur = ''
        else: cur += ch
    if cur.strip(): out.append(cur.strip())
    return out

def _parse_block(lines, idx, base_indent):
    if idx >= len(lines): return None, idx
    first = lines[idx]
    if first.lstrip().startswith('- '):
        items = []
        while idx < len(lines):
            ln = lines[idx]
            if _indent(ln) < base_indent or not ln.lstrip().startswith('- '): break
            rest = ln.lstrip()[2:]
            if ':' in rest and not rest.startswith('{'):
                items.append({})
                k, _, v = rest.partition(':')
                v = v.strip()
                if v: items[-1][k.strip()] = _parse_inline_value(v)
                else:
                    sub, idx2 = _parse_block(lines, idx+1, base_indent+2)
                    if sub: items[-1].update(sub if isinstance(sub, dict) else {})
                    idx = idx2 - 1
            else:
                items.append(_parse_inline_value(rest))
            idx += 1
        return items, idx
    out = {}
    while idx < len(lines):
        ln = lines[idx]
        ind = _indent(ln)
        if ind < base_indent: break
        if ind > base_indent: idx += 1; continue
        k, _, v = ln.lstrip().partition(':')
        v = v.strip()
        k = k.strip()
        if v:
            out[k] = _parse_inline_value(v)
            idx += 1
        else:
            sub, idx = _parse_block(lines, idx+1, base_indent+2)
            out[k] = sub
    return out, idx

# --- Frontmatter ops ------------------------------------------------------

FM_RE = re.compile(r'\A---\s*\n(.*?)\n---\s*\n', re.DOTALL)

def split_frontmatter(text):
    m = FM_RE.match(text)
    if not m: return {}, text
    fm_text = m.group(1)
    body = text[m.end():]
    fm = {}
    for ln in fm_text.splitlines():
        if not ln.strip() or ln.startswith('#'): continue
        k, _, v = ln.partition(':')
        fm[k.strip()] = _parse_inline_value(v.strip())
    return fm, body

def fm_to_text(fm):
    if not fm: return ''
    lines = ['---']
    for k, v in fm.items():
        if isinstance(v, bool):
            lines.append(f"{k}: {'true' if v else 'false'}")
        elif isinstance(v, list):
            lines.append(f"{k}: [{', '.join(str(x) for x in v)}]")
        elif v is None:
            lines.append(f"{k}:")
        elif isinstance(v, str) and (':' in v or v.startswith(' ') or v.endswith(' ')):
            lines.append(f'{k}: "{v}"')
        else:
            lines.append(f"{k}: {v}")
    lines.append('---\n')
    return '\n'.join(lines)

def apply_frontmatter_ops(fm, ops):
    if not ops: return fm
    out = {}
    keep = set(ops.get('keep') or [])
    drop = set(ops.get('drop') or [])
    rename = ops.get('rename') or {}
    add_if = ops.get('addIf') or {}
    for k, v in fm.items():
        if k in drop: continue
        if keep and k not in keep and k not in rename: continue
        nk = rename.get(k, k)
        out[nk] = v
    for cond, payload in add_if.items():
        negate = cond.startswith('!')
        key = cond[1:] if negate else cond
        truthy = bool(fm.get(key))
        if (truthy and not negate) or (not truthy and negate):
            if isinstance(payload, dict):
                for pk, pv in payload.items():
                    out[pk] = pv
    return out

# --- Per-tool placement ---------------------------------------------------

def place_section(adapter, section, src_dir):
    """Walk src_dir, copy files to adapter[section].copyTo with frontmatter ops."""
    cfg = adapter.get(section)
    if not cfg: return []
    placed = []
    copy_to = cfg['copyTo']
    mode = cfg.get('mode', '')
    ops = cfg.get('frontmatter')
    src_path = REPO / src_dir
    if not src_path.exists(): return []

    if copy_to.endswith('/'):  # directory mode (skills)
        for entry in sorted(src_path.iterdir()):
            if not entry.is_dir(): continue
            dst = TARGET / copy_to.format(name=entry.name)
            if dst.exists(): shutil.rmtree(dst)
            shutil.copytree(entry, dst)
            placed.append(str(dst.relative_to(TARGET)))
    else:
        for entry in sorted(src_path.iterdir()):
            if not entry.is_file() or entry.suffix != '.md': continue
            name = entry.stem
            dst_rel = copy_to.format(name=name)
            dst = TARGET / dst_rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            text = entry.read_text(encoding='utf-8')
            if mode == 'verbatim' or not ops:
                dst.write_text(text, encoding='utf-8')
            else:
                fm, body = split_frontmatter(text)
                new_fm = apply_frontmatter_ops(fm, ops)
                dst.write_text(fm_to_text(new_fm) + body, encoding='utf-8')
            placed.append(dst_rel)
    return placed

# --- MCP rendering --------------------------------------------------------

def render_mcp(adapter, host):
    src = json.loads((REPO / 'content/mcp-servers.json').read_text(encoding='utf-8'))
    servers = src['servers']
    if host != 'localhost':
        for s in servers:
            if 'url' in s:
                s['url'] = s['url'].replace('localhost', host)

    schema = adapter['mcp']['schema']
    if schema == 'mcpServers':
        out = {'mcpServers': {}}
        for s in servers:
            e = {}
            for src_k, dst_k in [('url','url'), ('connectionId','connection_id'),
                                  ('description','description')]:
                if src_k in s: e[dst_k] = s[src_k]
            # для cursor/claude добавим type: http если есть url с http
            if 'url' in s and s.get('transport') == 'http':
                e['type'] = 'http'
            out['mcpServers'][s['id']] = e
    elif 'mcp[id]' in schema:
        out = {'mcp': {}}
        for s in servers:
            e = {}
            if 'url' in s:
                e['type'] = 'remote'
                e['url'] = s['url']
            elif 'command' in s:
                e['type'] = 'local'
                e['command'] = [s['command']] + list(s.get('args', []))
            if 'description' in s: e['description'] = s['description']
            out['mcp'][s['id']] = e
    else:
        raise ValueError(f"Unknown MCP schema: {schema}")

    return json.dumps(out, indent=2, ensure_ascii=False)

# --- Detection ------------------------------------------------------------

def detect_tools():
    """Return list of active tool ids based on adapter detection rules."""
    active = []
    for ad_path in sorted((REPO / 'adapters').glob('*.yaml')):
        ad = parse_yaml(ad_path.read_text(encoding='utf-8'))
        tool = ad['tool']
        if tool not in ('cursor', 'claude-code', 'opencode'): continue
        det = ad.get('detection', [])
        for rule in det:
            if 'exists' in rule and (TARGET / rule['exists']).exists():
                active.append(tool); break
    return active

# --- Main install ---------------------------------------------------------

if TOOLS_ARG:
    tools = [t.strip() for t in TOOLS_ARG.split(',') if t.strip()]
else:
    tools = detect_tools()
    if not tools:
        print("Активных tools не обнаружено по detection rules. Укажи --tools.", file=sys.stderr)
        sys.exit(1)
    print(f"Auto-detected tools: {', '.join(tools)}\n")

adapters = {}
for tool in tools:
    ad_path = REPO / 'adapters' / f'{tool}.yaml'
    if not ad_path.exists():
        print(f"Адаптер {tool} не найден: {ad_path}", file=sys.stderr); sys.exit(1)
    adapters[tool] = parse_yaml(ad_path.read_text(encoding='utf-8'))

manifest_files = []

for tool, adapter in adapters.items():
    print(f"=== {tool} ===")
    for section, src in [('rules','content/rules'), ('agents','content/agents'),
                          ('commands','content/commands'), ('skills','content/skills')]:
        placed = place_section(adapter, section, src)
        if placed:
            print(f"  {section}: {len(placed)} файлов")
            for p in placed: manifest_files.append({'path': p, 'tool': tool, 'section': section})
    mcp_cfg = adapter.get('mcp')
    if mcp_cfg:
        dst = TARGET / mcp_cfg['target']
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(render_mcp(adapter, HOST), encoding='utf-8')
        print(f"  mcp: {mcp_cfg['target']} (host={HOST})")
        manifest_files.append({'path': mcp_cfg['target'], 'tool': tool, 'section': 'mcp'})
    entry = adapter.get('entry')
    if entry:
        dst = TARGET / entry['target']
        dst.write_text(entry['template'].encode('utf-8').decode('unicode_escape'), encoding='utf-8')
        print(f"  entry: {entry['target']}")
        manifest_files.append({'path': entry['target'], 'tool': tool, 'section': 'entry'})
    print()

# --- OpenSpec bundle per tool (skip-if-exists) ---------------------------

print("=== openspec-bundle ===")
for tool in tools:
    bundle_root = REPO / 'content' / 'openspec-bundle' / tool
    if not bundle_root.exists(): continue
    for src in bundle_root.rglob('*'):
        if not src.is_file(): continue
        rel = src.relative_to(bundle_root)
        dst = TARGET / rel
        if dst.exists(): continue  # skip-if-exists
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        manifest_files.append({'path': str(rel), 'tool': tool, 'section': 'openspec-bundle'})
    print(f"  {tool}: bundle размещён (skip-if-exists)")
print()

# --- AGENTS.md с подстановкой rulesDir/rulesExt --------------------------

priority = ['cursor', 'claude-code', 'kilocode', 'opencode', 'codex']
canonical = next((t for t in priority if t in tools), tools[0])
copy_to = adapters[canonical]['rules']['copyTo']
m = re.match(r'(.+)/\{name\}\.(\w+)$', copy_to)
rules_dir, rules_ext = m.group(1), m.group(2)

agents_src = (REPO / 'AGENTS.md').read_text(encoding='utf-8')
agents_out = agents_src.replace('{{ rulesDir }}', rules_dir).replace('{{ rulesExt }}', rules_ext)
(TARGET / 'AGENTS.md').write_text(agents_out, encoding='utf-8')
print(f"AGENTS.md размещён (rulesDir={rules_dir}, rulesExt={rules_ext})")
manifest_files.append({'path': 'AGENTS.md', 'tool': 'always-on', 'section': 'always-on'})

# --- USER-RULES.md и memory.md (skip-if-exists) --------------------------

for fname in ('USER-RULES.md', 'memory.md'):
    src = REPO / fname
    dst = TARGET / fname
    if dst.exists():
        print(f"  – {fname} уже существует, сохраняем")
        continue
    if src.exists():
        shutil.copy2(src, dst)
        print(f"  ✓ {fname} (первая установка)")
        manifest_files.append({'path': fname, 'tool': 'always-on', 'section': 'always-on'})

# --- Манифест .ai-rules.json --------------------------------------------

import subprocess
try:
    ver = subprocess.check_output(['git', '-C', str(REPO), 'describe', '--tags', '--always'],
                                   stderr=subprocess.DEVNULL).decode().strip()
except Exception:
    ver = 'unknown'

manifest = {
    'protocolVersion': '1.0',
    'sourceVersion': ver,
    'source': str(REPO),
    'tools': tools,
    'rulesDir': rules_dir,
    'rulesExt': rules_ext,
    'host': HOST,
    'files': manifest_files,
}
(TARGET / '.ai-rules.json').write_text(
    json.dumps(manifest, indent=2, ensure_ascii=False) + '\n', encoding='utf-8'
)
print(f"\nМанифест .ai-rules.json: {len(manifest_files)} файлов записано")
print(f"\n=== Готово ===")
PYEOF

echo ""
echo "Следующие шаги:"
echo "  1. Проверь infobasesettings.md (если новый — заполни подключение к ИБ)"
echo "  2. Запусти MCP-серверы (host=$HOST)"
echo "  3. Открой проект в нужном AI-инструменте"
