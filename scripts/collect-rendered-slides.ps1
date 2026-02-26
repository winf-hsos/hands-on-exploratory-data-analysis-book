Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Get-Location).Path
$slidesConfigPath = Join-Path $projectRoot "_quarto-slides.yml"
$slidesOutRoot = Join-Path $projectRoot "_book/slides"

function Get-ConfiguredSlideTargets {
  param([string]$ConfigPath)
  if (-not (Test-Path $ConfigPath)) {
    throw "Slides config not found: $ConfigPath"
  }

  $lines = Get-Content -Path $ConfigPath
  $targets = New-Object System.Collections.Generic.List[string]
  $inRender = $false
  $renderIndent = 0

  foreach ($line in $lines) {
    if ($line -match '^(?<indent>\s*)render:\s*$') {
      $inRender = $true
      $renderIndent = $matches['indent'].Length
      continue
    }

    if (-not $inRender) { continue }

    if ($line -match '^(?<indent>\s*)-\s*(?<path>.+?)\s*$') {
      $indentLen = $matches['indent'].Length
      if ($indentLen -le $renderIndent) {
        $inRender = $false
        continue
      }
      $p = $matches['path'].Trim().Trim('"').Trim("'")
      $normalized = $p -replace '\\', '/'
      if ($normalized -like "*.qmd") {
        if ($normalized -notmatch '^slides/[^/]+\.qmd$') {
          throw "Slide source path must match slides/*.qmd (no subfolders): $normalized"
        }
        $targets.Add($normalized)
      }
      continue
    }

    if ($line.Trim() -eq "") { continue }

    if ($line -match '^(?<indent>\s*)\S') {
      $indentLen = $matches['indent'].Length
      if ($indentLen -le $renderIndent) {
        $inRender = $false
      }
    }
  }

  return $targets
}

function Get-DestinationRelativeHtml {
  param([string]$RenderedHtmlRelative)
  $r = $RenderedHtmlRelative -replace '\\', '/'
  if ($r -match '^slides/[^/]+\.html$') {
    # Flat source path:
    # slides/foo.html -> foo.html
    return [IO.Path]::GetFileName($r)
  }

  throw "Rendered file path does not match expected slide pattern slides/*.html : $RenderedHtmlRelative"
}

New-Item -ItemType Directory -Force -Path $slidesOutRoot | Out-Null

$targets = Get-ConfiguredSlideTargets -ConfigPath $slidesConfigPath
$filter = $env:QUARTO_SLIDES_FILTER
if (-not [string]::IsNullOrWhiteSpace($filter)) {
  $requested = @(
    $filter.Split(';') |
      ForEach-Object { ($_ -replace '\\', '/').Trim() } |
      Where-Object { $_ -ne "" }
  )
  if ($requested.Count -gt 0) {
    $targets = $targets | Where-Object { $requested -contains $_ }
  }
}
$htmlTargets = $targets | ForEach-Object { ($_ -replace '\.qmd$', '.html') }

foreach ($htmlRel in $htmlTargets) {
  $srcHtml = Join-Path $projectRoot $htmlRel
  if (-not (Test-Path $srcHtml)) {
    throw "Rendered slide HTML not found: $htmlRel"
  }

  $dstRel = Get-DestinationRelativeHtml -RenderedHtmlRelative $htmlRel
  $dstHtml = Join-Path $slidesOutRoot $dstRel

  Copy-Item -Path $srcHtml -Destination $dstHtml -Force

  # Keep only one HTML file per slide deck in _book/slides (no copied *_files folders).
  $baseName = [IO.Path]::GetFileNameWithoutExtension($dstHtml)
  $dstAssets = Join-Path $slidesOutRoot ($baseName + "_files")
  if (Test-Path $dstAssets) {
    Remove-Item -Path $dstAssets -Recurse -Force
  }
}

Write-Host ("Collected slide outputs into: {0}" -f $slidesOutRoot)
