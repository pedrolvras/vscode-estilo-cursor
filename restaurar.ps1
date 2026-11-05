# Restaura as configuracoes deste repositorio nos lugares certos.
# Uso:  powershell -ExecutionPolicy Bypass -File .\restaurar.ps1
#       powershell -ExecutionPolicy Bypass -File .\restaurar.ps1 -Todas   (instala todas as extensoes)
# Antes de sobrescrever, guarda uma copia do que existe com a extensao .bak

param([switch]$Todas)

$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Guardar-Bak($caminho) {
    if (Test-Path $caminho) { Copy-Item $caminho "$caminho.bak" -Force }
}

# ---- 1. Extensoes (precisa do comando "code" no PATH) ----
if ($null -eq (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host 'AVISO: comando "code" nao encontrado. Extensoes nao instaladas.'
    Write-Host '       No VS Code: Ctrl+Shift+P > "Shell Command: Install code command in PATH", ou reinstale marcando "Add to PATH".'
} else {
    $lista = if ($Todas) { 'extensoes-todas.txt' } else { 'extensoes-necessarias.txt' }
    Get-Content (Join-Path $aqui $lista) | Where-Object { $_.Trim() -ne '' } | ForEach-Object {
        Write-Host "Instalando $_"
        code --install-extension $_.Trim() --force | Out-Null
    }
}

# ---- 1b. Fonte JetBrains Mono (instala so para o usuario atual, sem precisar de administrador) ----
$pastaFontes = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$regFontes = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
if (Get-ChildItem $pastaFontes -Filter 'JetBrainsMono*.ttf' -ErrorAction SilentlyContinue) {
    Write-Host 'Fonte JetBrains Mono ja instalada.'
} else {
    $versao = '2.304'
    $url = "https://github.com/JetBrains/JetBrainsMono/releases/download/v$versao/JetBrainsMono-$versao.zip"
    $tmp = Join-Path $env:TEMP "jbmono-$([guid]::NewGuid())"
    try {
        New-Item -ItemType Directory -Force $tmp | Out-Null
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "Baixando JetBrains Mono $versao..."
        Invoke-WebRequest -Uri $url -OutFile "$tmp\fonte.zip" -UseBasicParsing
        Expand-Archive "$tmp\fonte.zip" -DestinationPath "$tmp\x" -Force
        if (-not (Test-Path $pastaFontes)) { New-Item -ItemType Directory -Force $pastaFontes | Out-Null }
        if (-not (Test-Path $regFontes)) { New-Item -Force $regFontes | Out-Null }
        Get-ChildItem "$tmp\x\fonts\ttf" -Filter '*.ttf' | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $pastaFontes $_.Name) -Force
            New-ItemProperty -Path $regFontes -Name "$($_.BaseName) (TrueType)" `
                -Value (Join-Path $pastaFontes $_.Name) -PropertyType String -Force | Out-Null
        }
        Write-Host 'OK  Fonte JetBrains Mono instalada (reinicie o VS Code para aparecer).'
    } catch {
        Write-Host "AVISO: nao consegui instalar a fonte ($($_.Exception.Message))."
        Write-Host '       Baixe em https://www.jetbrains.com/lp/mono/ e instale os .ttf de fonts/ttf. Sem ela, o editor usa a Cascadia Code.'
    } finally {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---- 2. Arquivos copiados como estao ----
$copias = @(
    @{ de = 'vscode\keybindings.json';     para = "$env:APPDATA\Code\User\keybindings.json" },
    @{ de = 'vscode\cursor-like.css';      para = "$env:USERPROFILE\.vscode\cursor-like.css" },
    @{ de = 'vscode\fechar-menu.js';       para = "$env:USERPROFILE\.vscode\fechar-menu.js" },
    @{ de = 'vscode\rodape-blame.js';      para = "$env:USERPROFILE\.vscode\rodape-blame.js" },
    @{ de = 'vscode\cursor-chat.css';      para = "$env:USERPROFILE\.vscode\cursor-chat.css" },
    @{ de = 'vscode\aplicar-chat-css.ps1'; para = "$env:USERPROFILE\.vscode\aplicar-chat-css.ps1" }
)
foreach ($c in $copias) {
    $pasta = Split-Path -Parent $c.para
    if (-not (Test-Path $pasta)) { New-Item -ItemType Directory -Force $pasta | Out-Null }
    Guardar-Bak $c.para
    Copy-Item (Join-Path $aqui $c.de) $c.para -Force
    Write-Host "OK  $($c.para)"
}

# ---- 3. settings.json do VS Code, com o caminho do CSS ajustado para o usuario atual ----
$destSettings = "$env:APPDATA\Code\User\settings.json"
if (-not (Test-Path (Split-Path -Parent $destSettings))) { New-Item -ItemType Directory -Force (Split-Path -Parent $destSettings) | Out-Null }
$texto = [IO.File]::ReadAllText((Join-Path $aqui 'vscode\settings.json'), $utf8)
$perfil = ($env:USERPROFILE -replace '\\', '/')
$texto = $texto -replace 'file:///C:/Users/[^/]+/\.vscode/', "file:///$perfil/.vscode/"
Guardar-Bak $destSettings
[IO.File]::WriteAllText($destSettings, $texto, $utf8)
Write-Host "OK  $destSettings (CSS em $perfil/.vscode/)"

# ---- 4. Claude Code: so acrescenta a telemetria desligada, sem trocar o resto do arquivo ----
# (o claude/settings.json do repositorio tem hooks do Orca e plugins desta maquina; nao e copiado inteiro)
$destClaude = "$env:USERPROFILE\.claude\settings.json"
if (-not (Test-Path (Split-Path -Parent $destClaude))) { New-Item -ItemType Directory -Force (Split-Path -Parent $destClaude) | Out-Null }
if (Test-Path $destClaude) {
    $cfg = [IO.File]::ReadAllText($destClaude, $utf8) | ConvertFrom-Json
} else {
    $cfg = New-Object PSObject
}
if ($null -eq $cfg.env) { $cfg | Add-Member -NotePropertyName env -NotePropertyValue (New-Object PSObject) }
foreach ($k in @('DISABLE_TELEMETRY', 'DISABLE_ERROR_REPORTING')) {
    if ($cfg.env.PSObject.Properties.Name -contains $k) { $cfg.env.$k = '1' }
    else { $cfg.env | Add-Member -NotePropertyName $k -NotePropertyValue '1' }
}
Guardar-Bak $destClaude
[IO.File]::WriteAllText($destClaude, ($cfg | ConvertTo-Json -Depth 50), $utf8)
Write-Host "OK  $destClaude (telemetria desligada; o resto foi mantido)"

# ---- 5. Visual do chat do Claude Code ----
if (Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Directory -Filter 'anthropic.claude-code-*' -ErrorAction SilentlyContinue) {
    & "$env:USERPROFILE\.vscode\aplicar-chat-css.ps1"
} else {
    Write-Host 'AVISO: extensao do Claude Code nao encontrada; rode aplicar-chat-css.ps1 depois de instalar.'
}

Write-Host ''
Write-Host 'Falta no VS Code: Ctrl+Shift+P > Enable Custom CSS and JS, e reiniciar.'
