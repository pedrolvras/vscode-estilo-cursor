# Monta o .vsix desta pasta e instala com "code --install-extension".
# Rodar: powershell -ExecutionPolicy Bypass -File .vscode\scriptcase-php\instalar.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$dir  = $PSScriptRoot
$pkg  = Get-Content (Join-Path $dir 'package.json') -Raw | ConvertFrom-Json
$vsix = Join-Path $env:TEMP 'scriptcase-php.vsix'
if (Test-Path -LiteralPath $vsix) { Remove-Item -LiteralPath $vsix }

$manifest = @"
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="$($pkg.name)" Version="$($pkg.version)" Publisher="$($pkg.publisher)"/>
    <DisplayName>$($pkg.displayName)</DisplayName>
    <Description xml:space="preserve">PHP Scriptcase</Description>
    <Categories>Programming Languages</Categories>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="$($pkg.engines.vscode)"/>
    </Properties>
  </Metadata>
  <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
  <Dependencies/>
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/>
  </Assets>
</PackageManifest>
"@
$types = @"
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension=".json" ContentType="application/json"/>
  <Default Extension=".md" ContentType="text/markdown"/>
  <Default Extension=".vsixmanifest" ContentType="text/xml"/>
</Types>
"@

$zip = [System.IO.Compression.ZipFile]::Open($vsix, 'Create')
try {
  foreach ($e in @(@('[Content_Types].xml', $types), @('extension.vsixmanifest', $manifest))) {
    $w = New-Object System.IO.StreamWriter(($zip.CreateEntry($e[0])).Open())
    $w.Write($e[1]); $w.Close()
  }
  foreach ($f in 'package.json', 'language-configuration.json', 'README.md', 'syntaxes/php-scriptcase.tmLanguage.json') {
    [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, (Join-Path $dir $f), "extension/$f")
  }
} finally { $zip.Dispose() }

& code --install-extension $vsix --force
