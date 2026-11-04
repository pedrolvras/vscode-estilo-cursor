# Aplica cursor-chat.css no chat do Claude Code (so visual).
# Rode de novo depois de cada atualizacao da extensao, ou depois de mudar o cursor-chat.css.
# Uso:  powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.vscode\aplicar-chat-css.ps1"
# Para desfazer: o mesmo comando com -Remover

param([switch]$Remover)

$ini = '/* >>> cursor-chat-css */'
$fim = '/* <<< cursor-chat-css */'
$cssProprio = Join-Path $env:USERPROFILE '.vscode\cursor-chat.css'
$ext = Join-Path $env:USERPROFILE '.vscode\extensions'

$pasta = Get-ChildItem $ext -Directory -Filter 'anthropic.claude-code-*' |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($null -eq $pasta) { Write-Host 'Extensao do Claude Code nao encontrada.'; exit 1 }

$alvo = Join-Path $pasta.FullName 'webview\index.css'
if (-not (Test-Path $alvo)) { Write-Host "Nao achei $alvo"; exit 1 }

$utf8 = New-Object System.Text.UTF8Encoding($false)
$texto = [IO.File]::ReadAllText($alvo, $utf8)

# Tira o bloco antigo, se houver (assim rodar de novo nao duplica)
$i = $texto.IndexOf($ini)
if ($i -ge 0) {
    $j = $texto.IndexOf($fim, $i)
    if ($j -ge 0) { $texto = $texto.Substring(0, $i) + $texto.Substring($j + $fim.Length) }
    $texto = $texto.TrimEnd()
}

if (-not $Remover) {
    $novo = [IO.File]::ReadAllText($cssProprio, $utf8)
    $texto = $texto + "`n" + $ini + "`n" + $novo + "`n" + $fim + "`n"
}

[IO.File]::WriteAllText($alvo, $texto, $utf8)
if ($Remover) { Write-Host "Removido de $($pasta.Name)." }
else { Write-Host "Aplicado em $($pasta.Name). Recarregue a janela: Ctrl+Shift+P > Reload Window." }
