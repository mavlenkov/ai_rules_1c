#!/usr/bin/env pwsh
# Generate project-scoped Koda MCP registration commands from mcp-servers.json.
# Usage:
#   ./koda-mcp-setup.ps1 -Source content/mcp-servers.json -Target .kodacli/mcp-setup.md

param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Target
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$serversJson = Get-Content -Path $Source -Raw -Encoding UTF8 | ConvertFrom-Json
$lines = @(
    '# Koda MCP Setup',
    '',
    'Run these commands in a shell from the project root:',
    ''
)
$count = 0
$hasUnresolvedUrl = $false

foreach ($server in $serversJson.servers) {
    if ($server.transport -ne 'http' -or -not $server.url) { continue }
    if ($server.url -match '\{[^}]+\}') {
        $hasUnresolvedUrl = $true
        continue
    }

    $lines += '```bash'
    $lines += "koda mcp add $($server.id) `"$($server.url)`" --transport http --scope project"
    $lines += '```'
    if ($server.description) { $lines += "`n> $($server.description)" }
    $lines += ''
    $count++
}

if ($count -eq 0) { $lines += 'No HTTP MCP servers configured.' }
if ($hasUnresolvedUrl) {
    $lines += 'Regenerate this file after setting INFOBASE_PUBLISH_URL to include 1c-data-mcp.'
}

$parent = Split-Path -Parent $Target
if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
Set-Content -Path $Target -Value ($lines -join "`n") -Encoding utf8NoBOM -NoNewline

Write-Host "Generated MCP setup: $Target" -ForegroundColor Green
Write-Host "  Servers: $count" -ForegroundColor Gray
