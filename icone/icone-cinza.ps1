# Ícone do VS Code em cinza (combina com o tema escuro sem cor).
# Gera %USERPROFILE%\.vscode\code-cinza.ico a partir do ícone do VS Code instalado e o põe nos
# atalhos do menu Iniciar, da área de trabalho e da barra de tarefas.
#   powershell -ExecutionPolicy Bypass -File .\icone\icone-cinza.ps1            # aplica
#   powershell -ExecutionPolicy Bypass -File .\icone\icone-cinza.ps1 -Remover   # volta ao azul
param([switch]$Remover)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$base = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code'
$exe  = Join-Path $base 'Code.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw "VS Code não encontrado em $base" }
$ico  = Get-ChildItem -LiteralPath $base -Recurse -Filter 'code.ico' | Where-Object { $_.FullName -like '*resources\win32\code.ico' } | Select-Object -First 1
$saida = Join-Path $env:USERPROFILE '.vscode\code-cinza.ico'

$atalhos = @(
  (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk'),
  (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Visual Studio Code.lnk'),
  (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Visual Studio Code.lnk')
) | Where-Object { Test-Path -LiteralPath $_ }

if (-not $Remover) {
  if (-not $ico) { throw 'code.ico do VS Code não encontrado' }
  New-Item -ItemType Directory -Force -Path (Split-Path $saida) | Out-Null
  $tamanhos = 16, 24, 32, 48, 64, 128, 256
  $pngs = @()
  foreach ($t in $tamanhos) {
    $orig = New-Object System.Drawing.Icon($ico.FullName, $t, $t)
    $src  = $orig.ToBitmap()
    $bmp  = New-Object System.Drawing.Bitmap($t, $t, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.DrawImage($src, 0, 0, $t, $t); $g.Dispose()
    for ($y = 0; $y -lt $t; $y++) { for ($x = 0; $x -lt $t; $x++) {
      $c = $bmp.GetPixel($x, $y)
      if ($c.A -eq 0) { continue }
      # luminância, clareada para o azul do logo virar um cinza médio-claro
      $l = [int][Math]::Min(255, (0.299 * $c.R + 0.587 * $c.G + 0.114 * $c.B) * 1.55 + 20)
      $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $l, $l, $l))
    } }
    $ms = New-Object System.IO.MemoryStream
    if ($t -ge 256) {
      $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    } else {
      # bitmap clássico (BITMAPINFOHEADER, 32 bits, de baixo para cima, mais a máscara AND)
      $bw = New-Object System.IO.BinaryWriter($ms)
      $bw.Write([UInt32]40); $bw.Write([Int32]$t); $bw.Write([Int32]($t * 2))
      $bw.Write([UInt16]1); $bw.Write([UInt16]32); $bw.Write([UInt32]0)
      $mascara = [int]([Math]::Ceiling($t / 32.0) * 4)
      $bw.Write([UInt32]($t * $t * 4 + $mascara * $t))
      $bw.Write([Int32]0); $bw.Write([Int32]0); $bw.Write([UInt32]0); $bw.Write([UInt32]0)
      for ($y = $t - 1; $y -ge 0; $y--) { for ($x = 0; $x -lt $t; $x++) {
        $c = $bmp.GetPixel($x, $y)
        $bw.Write([Byte]$c.B); $bw.Write([Byte]$c.G); $bw.Write([Byte]$c.R); $bw.Write([Byte]$c.A)
      } }
      $bw.Write((New-Object Byte[] ($mascara * $t)))
      $bw.Flush()
    }
    $pngs += ,@($t, $ms.ToArray())
    $bmp.Dispose(); $src.Dispose(); $orig.Dispose()
  }
  # ICO: bitmaps até 128 e PNG no 256
  $fs = [System.IO.File]::Create($saida); $w = New-Object System.IO.BinaryWriter($fs)
  $w.Write([UInt16]0); $w.Write([UInt16]1); $w.Write([UInt16]$pngs.Count)
  $offset = 6 + 16 * $pngs.Count
  foreach ($p in $pngs) {
    $d = if ($p[0] -ge 256) { 0 } else { $p[0] }
    $w.Write([Byte]$d); $w.Write([Byte]$d); $w.Write([Byte]0); $w.Write([Byte]0)
    $w.Write([UInt16]1); $w.Write([UInt16]32); $w.Write([UInt32]$p[1].Length); $w.Write([UInt32]$offset)
    $offset += $p[1].Length
  }
  foreach ($p in $pngs) { $w.Write($p[1]) }
  $w.Close()
  Write-Host "Ícone gerado: $saida"
}

$sh = New-Object -ComObject WScript.Shell
foreach ($a in $atalhos) {
  $lnk = $sh.CreateShortcut($a)
  $lnk.IconLocation = if ($Remover) { "$exe,0" } else { "$saida,0" }
  $lnk.Save()
  Write-Host "Atalho: $a"
}
# avisa o Explorer para redesenhar os ícones
& ie4uinit.exe -show 2>$null
Write-Host 'Pronto. Se a barra de tarefas não mudar, desafixe e fixe o VS Code de novo, ou reinicie o Explorer.'
