#!/usr/bin/env pwsh
#
# koda-mcp-setup.ps1 — Generate Koda MCP setup instructions from mcp-servers.json.
#
# Usage:
#   .\koda-mcp-setup.ps1 -Source <path-to-mcp-servers.json> -Target <path-to-.koda/mcp-setup.md>
#
# Reads content/mcp-servers.json and generates a markdown file with ready-to-copy
# /mcp add-http commands for each HTTP-based MCP server.

param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Target
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Read mcp-servers.json
$serversJson = Get-Content -Path $Source -Raw -Encoding UTF8 | ConvertFrom-Json
$servers = $serversJson.servers

# Generate markdown
$lines = @()
$lines += "# Koda MCP Setup"
$lines += ""
$lines += "Koda does not use a static MCP config file. Add servers using the `/mcp add-http` command."
$lines += ""
$lines += "Copy and run the commands below in Koda's TUI or headless mode:"
$lines += ""

foreach ($server in $servers) {
    $id = $server.id
    $desc = $server.description
    $transport = $server.transport
    $url = $server.url
    
    # Skip servers that are not HTTP transport
    if ($transport -ne "http") {
        continue
    }
    
    # Skip servers with placeholder URLs (they need .dev.env resolution)
    if ($url -match '^\{') {
        continue
    }
    
    $lines += '```'
    $lines += ('/mcp add-http {0} {1}' -f $server.id, $server.url)
    $lines += '```'
    $lines += ""
    $lines += "> $desc"
    $lines += ""
}

# Add data-mcp special note
$lines += "---"
$lines += ''
$lines += '## Special: 1c-data-mcp'
$lines += ''
$lines += "This server's URL is derived from `INFOBASE_PUBLISH_URL` in `.dev.env`."
$lines += 'After setting `INFOBASE_PUBLISH_URL`, run:'
$lines += ''
$lines += '```'
$lines += ('/mcp add-http 1c-data-mcp {0}/hs/mcp' -f '{INFOBASE_PUBLISH_URL}')
$lines += '```'
$lines += ''
$lines += 'See `USER-RULES.md` for details on configuring anonymous access.'
$lines += ''

# Write file
$output = $lines -join "`n"
Set-Content -Path $Target -Value $output -Encoding UTF8 -NoNewline

Write-Host "Generated MCP setup: $Target" -ForegroundColor Green
Write-Host "  Servers: $($servers | Where-Object { $_.transport -eq 'http' -and $_.url -notmatch '^\{' } | Measure-Object).Count" -ForegroundColor Gray
