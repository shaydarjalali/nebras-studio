$ErrorActionPreference = 'Stop'
$project = $PSScriptRoot
$root = Split-Path (Split-Path $project -Parent) -Parent
$outputs = Join-Path $root 'outputs'
New-Item -ItemType Directory -Force -Path $outputs | Out-Null

$html = Get-Content -Raw -Encoding UTF8 (Join-Path $project 'index.html')
$css = Get-Content -Raw -Encoding UTF8 (Join-Path $project 'styles.css')
$js = Get-Content -Raw -Encoding UTF8 (Join-Path $project 'app.js')

function DataUri([string]$path, [string]$mime) {
  $bytes = [IO.File]::ReadAllBytes($path)
  return "data:$mime;base64,$([Convert]::ToBase64String($bytes))"
}

$html = $html.Replace('<link rel="stylesheet" href="styles.css">', "<style>$css</style>")
$html = $html.Replace('<script src="app.js"></script>', "<script>$js</script>")
$html = $html.Replace('assets/orbit-sprite.webp', (DataUri (Join-Path $project 'assets\orbit-sprite.webp') 'image/webp'))
$html = $html.Replace('assets/logo.webp', (DataUri (Join-Path $project 'assets\logo.webp') 'image/webp'))
$html = $html.Replace('assets/cloud-cinematic-v1.webp', (DataUri (Join-Path $project 'assets\cloud-cinematic-v1.webp') 'image/webp'))

$single = Join-Path $outputs 'Nebras-final-clean-single.html'
[IO.File]::WriteAllText($single, $html, [Text.UTF8Encoding]::new($false))

$zip = Join-Path $outputs 'Nebras-final-clean-host.zip'
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $project '*') -DestinationPath $zip -CompressionLevel Optimal

Get-Item $single, $zip | Select-Object FullName, Length
