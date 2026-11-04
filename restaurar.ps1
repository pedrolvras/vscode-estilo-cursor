# Restaura as configuracoes deste repositorio nos lugares certos.
# Uso:  powershell -ExecutionPolicy Bypass -File .\restaurar.ps1
# Antes de sobrescrever, guarda uma copia do que existe com a extensao .bak
# Com -Todas, instala tambem as outras extensoes que eu uso (extensoes-todas.txt)

param([switch]$Todas)

$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path

# Extensoes
$lista = if ($Todas) { 'extensoes-todas.txt' } else { 'extensoes-necessarias.txt' }
Get-Content (Join-Path $aqui $lista) | Where-Object { $_.Trim() -ne '' } | ForEach-Object {
    Write-Host "Instalando $_"
    code --install-extension $_ --force | Out-Null
}

$copias = @(
    @{ de = 'vscode\settings.json';        para = "$env:APPDATA\Code\User\settings.json" },
    @{ de = 'vscode\keybindings.json';     para = "$env:APPDATA\Code\User\keybindings.json" },
    @{ de = 'vscode\cursor-like.css';      para = "$env:USERPROFILE\.vscode\cursor-like.css" },
    @{ de = 'vscode\cursor-chat.css';      para = "$env:USERPROFILE\.vscode\cursor-chat.css" },
    @{ de = 'vscode\aplicar-chat-css.ps1'; para = "$env:USERPROFILE\.vscode\aplicar-chat-css.ps1" },
    @{ de = 'claude\settings.json';        para = "$env:USERPROFILE\.claude\settings.json" }
)

foreach ($c in $copias) {
    $origem = Join-Path $aqui $c.de
    $pasta = Split-Path -Parent $c.para
    if (-not (Test-Path $pasta)) { New-Item -ItemType Directory -Force $pasta | Out-Null }
    if (Test-Path $c.para) { Copy-Item $c.para "$($c.para).bak" -Force }
    Copy-Item $origem $c.para -Force
    Write-Host "OK  $($c.para)"
}

# Reaplica o visual do chat do Claude Code, se a extensao estiver instalada
& "$env:USERPROFILE\.vscode\aplicar-chat-css.ps1"

Write-Host ''
Write-Host 'Falta no VS Code: Ctrl+Shift+P > Enable Custom CSS and JS, e reiniciar.'
