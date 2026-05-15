<#
.SYNOPSIS
Start IDA Pro MCP HTTP server (background, non-blocking)

.DESCRIPTION
1. Kill old process
2. Start idalib-mcp HTTP server in hidden window mode
3. Wait for service ready (max 15 seconds)
4. Output result

Usage: run without parameters
#>

param(
    [string]$IdaDir,
    [int]$Port = 13337,
    [string]$ServerPath
)

if ([string]::IsNullOrWhiteSpace($IdaDir)) {
    $IdaDir = if (-not [string]::IsNullOrWhiteSpace($env:IDADIR)) { $env:IDADIR } else { 'D:\APP\IDA' }
}
$env:IDADIR = $IdaDir

if ([string]::IsNullOrWhiteSpace($ServerPath)) {
    $resolved = Get-Command idalib-mcp -ErrorAction SilentlyContinue
    if ($resolved) {
        $ServerPath = $resolved.Source
    }
    else {
        $roamingPython = Join-Path $env:APPDATA 'Python'
        if (Test-Path -LiteralPath $roamingPython) {
            $candidate = Get-ChildItem -LiteralPath $roamingPython -Directory -ErrorAction SilentlyContinue |
                ForEach-Object { Join-Path $_.FullName 'Scripts\idalib-mcp.exe' } |
                Where-Object { Test-Path -LiteralPath $_ } |
                Select-Object -First 1
            if ($candidate) {
                $ServerPath = $candidate
            }
        }
    }
}

# Auto-bootstrap idalib-mcp if still not found
if ([string]::IsNullOrWhiteSpace($ServerPath)) {
    $bootstrapScript = Join-Path $PSScriptRoot '..\..\scripts\bootstrap-reverse.ps1'
    if (Test-Path -LiteralPath $bootstrapScript) {
        Write-Output "INFO: idalib-mcp not found, attempting auto-bootstrap (pip install idalib-mcp)..."
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrapScript -Capability @('idalib-mcp') -SkipRefresh
        $resolved = Get-Command idalib-mcp -ErrorAction SilentlyContinue
        if ($resolved) {
            $ServerPath = $resolved.Source
        }
        else {
            $roamingPython = Join-Path $env:APPDATA 'Python'
            if (Test-Path -LiteralPath $roamingPython) {
                $candidate = Get-ChildItem -LiteralPath $roamingPython -Directory -ErrorAction SilentlyContinue |
                    ForEach-Object { Join-Path $_.FullName 'Scripts\idalib-mcp.exe' } |
                    Where-Object { Test-Path -LiteralPath $_ } |
                    Select-Object -First 1
                if ($candidate) {
                    $ServerPath = $candidate
                }
            }
        }
    }
}

if ([string]::IsNullOrWhiteSpace($ServerPath)) {
    throw 'Missing required CLI tool: idalib-mcp — auto-bootstrap failed. Install manually: pip install idalib-mcp'
}

# 清理旧进程（杀进程树，包括 worker 子进程）
$old = Get-Process -Name "idalib-mcp" -ErrorAction SilentlyContinue
if ($old) { taskkill /F /T /PID $old.Id 2>$null | Out-Null; Start-Sleep 2 }

# 后台启动
Start-Process -WindowStyle Hidden -FilePath $ServerPath -ArgumentList "--host 127.0.0.1 --port $Port"

# 等待就绪
$ready = $false
for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Seconds 1
    try {
        $r = Invoke-RestMethod "http://127.0.0.1:$Port/mcp" -Method Post `
            -Body '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' `
            -ContentType "application/json" -ErrorAction Stop
        if ($r.result.tools.Count -gt 0) {
            Write-Output "OK:$($r.result.tools.Count)"
            $ready = $true
            break
        }
    } catch {}
}
if (-not $ready) {
    Write-Output "ERR:timeout"
}