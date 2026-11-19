# Membuat shortcut "Chat" di Desktop dengan ikon chat.ico:
#   1. Chat.lnk          -> membuka aplikasi Claude desktop
#   2. Chat (Web).lnk    -> membuka claude.ai di Edge mode aplikasi (tanpa address bar & tab)
#   3. Chat helper.lnk   -> menjalankan mask.ahk otomatis saat Windows menyala (folder Startup)
#
# Cara pakai: klik kanan file ini > "Run with PowerShell".

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$icon = Join-Path $here 'chat.ico'
$desktop = [Environment]::GetFolderPath('Desktop')
$startup = [Environment]::GetFolderPath('Startup')
$shell = New-Object -ComObject WScript.Shell

if (-not (Test-Path $icon)) { throw "chat.ico tidak ditemukan di $here" }

function New-Shortcut($path, $target, $arguments, $workdir) {
    $lnk = $shell.CreateShortcut($path)
    $lnk.TargetPath = $target
    if ($arguments) { $lnk.Arguments = $arguments }
    if ($workdir) { $lnk.WorkingDirectory = $workdir }
    $lnk.IconLocation = "$icon,0"
    $lnk.Save()
    Write-Host "Dibuat: $path"
}

# 1. Aplikasi Claude desktop
$candidates = @(
    "$env:LOCALAPPDATA\AnthropicClaude\claude.exe",
    "$env:LOCALAPPDATA\Programs\Claude\Claude.exe",
    "$env:ProgramFiles\Claude\Claude.exe"
)
$claude = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($claude) {
    New-Shortcut (Join-Path $desktop 'Chat.lnk') $claude $null (Split-Path $claude)
} else {
    Write-Warning "claude.exe tidak ditemukan otomatis. Lewati shortcut aplikasi desktop."
}

# 2. claude.ai lewat Edge mode aplikasi
$edge = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($edge) {
    New-Shortcut (Join-Path $desktop 'Chat (Web).lnk') $edge '--app=https://claude.ai' $null
}

# 3. Jalankan mask.ahk saat Windows menyala
$ahk = Join-Path $here 'mask.ahk'
if (Test-Path $ahk) {
    New-Shortcut (Join-Path $startup 'Chat helper.lnk') $ahk $null $here
}

Write-Host ""
Write-Host "Selesai. Unpin ikon Claude lama dari taskbar, lalu pin shortcut 'Chat' yang baru."
