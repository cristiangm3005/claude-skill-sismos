# Instala la skill "sismos" para tu usuario de Claude Code en Windows.
$ErrorActionPreference = "Stop"
$origen = Join-Path $PSScriptRoot "sismos"
$base = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
$destino = Join-Path $base "skills\sismos"
New-Item -ItemType Directory -Force -Path (Split-Path $destino) | Out-Null
if (Test-Path $destino) { Remove-Item -Recurse -Force $destino }
Copy-Item -Recurse $origen $destino
Write-Host "Skill instalada en $destino"
Write-Host "Prueba:  python `"$destino\scripts\sismos.py`" prueba"
