#!/usr/bin/env pwsh
# koda-agent-convert.ps1 — Convert 1c-rules agent markdown files to Koda CLI JSON format.
#
# Usage:
#   .\koda-agent-convert.ps1 -Source <path-to-content/agents> -Target <path-to-.koda/agents> [-DevEnv <path-to-.dev.env>]
#
# Delegates YAML parsing to Python (reliable) and JSON output to PowerShell.

param(
    [Parameter(Mandatory=$true)] [string]$Source,
    [Parameter(Mandatory=$true)] [string]$Target,
    [string]$DevEnv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Ensure target directory exists
if (-not (Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
}

$agentFiles = Get-ChildItem -Path $Source -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }
if ($agentFiles.Count -eq 0) {
    Write-Host "No agent files found in $Source" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n=== Koda Agent Converter ===" -ForegroundColor Cyan
Write-Host "Source: $Source" -ForegroundColor Gray
Write-Host "Target: $Target" -ForegroundColor Gray
if ($DevEnv) { Write-Host "DevEnv: $DevEnv" -ForegroundColor Gray }
Write-Host "`nConverting $($agentFiles.Count) agent(s)..." -ForegroundColor Cyan

# Delegate YAML parsing + JSON generation to Python for reliability
$pythonScript = @'
import json, sys, re, os
from pathlib import Path

source = sys.argv[1]
target = sys.argv[2]
devenv = sys.argv[3] if len(sys.argv) > 3 else ""

def parse_yaml_fm(text):
    """Minimal YAML frontmatter parser supporting scalars and inline arrays."""
    m = re.match(r'^---\r?\n([\s\S]*?)\r?\n---', text)
    if not m:
        return {}, text.strip()
    fm = {}
    for line in m.group(1).splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        km = re.match(r'^(\w+):\s*(.*)', line)
        if not km:
            continue
        key, value = km.group(1), km.group(2).strip()
        # Inline array: ["Read", "Write", ...]
        am = re.match(r'^\[(.+)\]$', value)
        if am:
            inner = am.group(1)
            items = [x.strip().strip('"').strip("'") for x in inner.split(',') if x.strip()]
            fm[key] = items
            continue
        # Quoted string
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]
        elif value.startswith("'") and value.endswith("'"):
            value = value[1:-1]
        # Boolean
        if value == 'true': value = True
        elif value == 'false': value = False
        fm[key] = value
    body = text[m.end():].strip()
    return fm, body

def resolve_model(devenv_path, tier, tool_name):
    """Resolve model from .dev.env using cascade."""
    if not devenv_path or not os.path.exists(devenv_path):
        return None
    tool_upper = tool_name.replace('-', '_').upper()
    keys = [
        f"SUBAGENT_MODEL_{tier}__{tool_upper}",
        f"SUBAGENT_MODEL_{tier}"
    ]
    try:
        with open(devenv_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                for key in keys:
                    if line.startswith(key + '='):
                        val = line[len(key)+1:].strip()
                        if val:
                            return val
    except:
        pass
    return None

TOOL_MAP = {
    "Read": "Read", "Write": "Write", "Edit": "Edit",
    "Grep": "Grep", "Glob": "Glob", "Shell": "Bash", "MCP": "MCP"
}
ALL_TOOLS = ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "MCP"]

for f in sorted(Path(source).glob("*.md")):
    if f.name == "README.md":
        continue
    content = f.read_text(encoding='utf-8')
    fm, body = parse_yaml_fm(content)
    
    name = fm.get("name", f.stem.replace("1c-", ""))
    tier = fm.get("modelTier", "")
    is_subagent = fm.get("isSubagent", False)
    if isinstance(is_subagent, str):
        is_subagent = is_subagent.lower() == "true"
    
    # Resolve model
    model = resolve_model(devenv, tier, "koda")
    
    # Convert tools
    raw_tools = fm.get("tools", [])
    if isinstance(raw_tools, str):
        # Fallback: parse inline array from string
        am = re.match(r'^\[(.+)\]$', raw_tools)
        if am:
            raw_tools = [x.strip().strip('"').strip("'") for x in am.group(1).split(',') if x.strip()]
        else:
            raw_tools = []
    
    allowed = []
    for t in raw_tools:
        t_str = str(t).strip()
        if t_str in TOOL_MAP:
            allowed.append(TOOL_MAP[t_str])
    
    disallowed = [t for t in ALL_TOOLS if t not in allowed]
    max_iter = 30 if is_subagent else 200
    skip_mem = not (any(t in allowed for t in ("Write", "Edit", "Bash")))
    
    agent = {
        "name": name,
        "system_prompt": body,
        "trust": "safe",
        "allowed_tools": allowed,
        "disallowed_tools": disallowed,
        "max_iterations": max_iter,
        "skip_memory": skip_mem
    }
    if model:
        agent["model"] = model
    
    out_path = Path(target) / f"{name}.json"
    out_path.write_text(json.dumps(agent, indent=2, ensure_ascii=False) + "\n", encoding='utf-8')
    print(f"  OK {name} -> {out_path}")

'@

$pythonCode = $pythonScript -replace "`r`n", "`n"
$pythonCode | Set-Content -Path "/tmp/koda-convert.py" -Encoding UTF8 -NoNewline

$pythonArgs = @($Source, $Target)
if ($DevEnv) { $pythonArgs += $DevEnv }

try {
    $argList = @("/tmp/koda-convert.py", $Source, $Target)
    if ($DevEnv) { $argList += $DevEnv }
    $proc = Start-Process -FilePath "python3" -ArgumentList $argList `
        -NoNewWindow -Wait -PassThru -RedirectStandardError "/tmp/koda-convert-err.txt"
    if ($proc.ExitCode -ne 0) {
        $err = Get-Content "/tmp/koda-convert-err.txt" -Raw
        Write-Host "Python error: $err" -ForegroundColor Red
        exit 1
    }
} finally {
    if (Test-Path "/tmp/koda-convert.py") { Remove-Item "/tmp/koda-convert.py" -Force -ErrorAction SilentlyContinue }
    if (Test-Path "/tmp/koda-convert-err.txt") { Remove-Item "/tmp/koda-convert-err.txt" -Force -ErrorAction SilentlyContinue }
}

Write-Host "`nDone. Agents written to: $Target" -ForegroundColor Green