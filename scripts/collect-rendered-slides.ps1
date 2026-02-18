Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Get-Location).Path
$slidesConfigPath = Join-Path $projectRoot "_quarto-slides.yml"
$slidesOutRoot = Join-Path $projectRoot "slides"

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
      if ($p -like "*.qmd") {
        $targets.Add(($p -replace '\\', '/'))
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
  if ($r -notlike "*/slides/_generated/*.html") {
    throw "Rendered file path does not match expected pattern */slides/_generated/*.html : $RenderedHtmlRelative"
  }

  # project-1-survey/slides/_generated/foo.html -> project-1-survey/foo.html
  return ($r -replace '/slides/_generated/', '/')
}

New-Item -ItemType Directory -Force -Path $slidesOutRoot | Out-Null

$targets = Get-ConfiguredSlideTargets -ConfigPath $slidesConfigPath
$htmlTargets = $targets | ForEach-Object { ($_ -replace '\.qmd$', '.html') }

foreach ($htmlRel in $htmlTargets) {
  $srcHtml = Join-Path $projectRoot $htmlRel
  if (-not (Test-Path $srcHtml)) {
    throw "Rendered slide HTML not found: $htmlRel"
  }

  $dstRel = Get-DestinationRelativeHtml -RenderedHtmlRelative $htmlRel
  $dstHtml = Join-Path $slidesOutRoot $dstRel
  $dstDir = Split-Path -Parent $dstHtml
  New-Item -ItemType Directory -Force -Path $dstDir | Out-Null

  Copy-Item -Path $srcHtml -Destination $dstHtml -Force

  # Keep only one HTML file per slide deck in slides/ (no copied *_files folders).
  $baseName = [IO.Path]::GetFileNameWithoutExtension($dstHtml)
  $dstAssets = Join-Path $dstDir ($baseName + "_files")
  if (Test-Path $dstAssets) {
    Remove-Item -Path $dstAssets -Recurse -Force
  }
}

Write-Host ("Collected slide outputs into: {0}" -f $slidesOutRoot)
