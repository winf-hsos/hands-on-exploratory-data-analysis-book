param(
  [switch]$Force
)

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

function Get-DestinationHtmlPath {
  param([string]$SlideSourceRelative)
  $sourceName = [IO.Path]::GetFileNameWithoutExtension($SlideSourceRelative)
  $targetName = $sourceName + ".html"
  return (Join-Path $slidesOutRoot $targetName)
}

$targets = Get-ConfiguredSlideTargets -ConfigPath $slidesConfigPath
if ($targets.Count -eq 0) {
  Write-Host "No slide sources configured in _quarto-slides.yml under project.render."
  exit 0
}

foreach ($slideRel in $targets) {
  $srcQmd = Join-Path $projectRoot $slideRel
  if (-not (Test-Path $srcQmd)) {
    throw "Configured slide source not found: $slideRel"
  }
}

$toRender = New-Object System.Collections.Generic.List[string]

if ($Force) {
  foreach ($slide in $targets) {
    $toRender.Add($slide)
  }
}

if (-not $Force) {
foreach ($slideRel in $targets) {
  $srcQmd = Join-Path $projectRoot $slideRel

  $dstHtml = Get-DestinationHtmlPath -SlideSourceRelative $slideRel
  if (-not (Test-Path $dstHtml)) {
    $toRender.Add($slideRel)
    continue
  }

  $srcTimeUtc = (Get-Item $srcQmd).LastWriteTimeUtc
  $dstTimeUtc = (Get-Item $dstHtml).LastWriteTimeUtc
  if ($srcTimeUtc -gt $dstTimeUtc) {
    $toRender.Add($slideRel)
  }
}
}

if ($toRender.Count -eq 0) {
  Write-Host "No changed slide sources detected. Nothing to render."
  exit 0
}

Write-Host ("Rendering {0} changed slide(s):" -f $toRender.Count)
foreach ($slide in $toRender) {
  Write-Host (" - {0}" -f $slide)
}

foreach ($slide in $toRender) {
  $env:QUARTO_SLIDES_FILTER = $slide
  & quarto render --profile slides $slide
  if ($LASTEXITCODE -ne 0) {
    Remove-Item Env:\QUARTO_SLIDES_FILTER -ErrorAction SilentlyContinue
    throw "quarto render failed for $slide with exit code $LASTEXITCODE"
  }
}

Remove-Item Env:\QUARTO_SLIDES_FILTER -ErrorAction SilentlyContinue

if ($toRender.Count -gt 1) {
  # Final pass to ensure target folder reflects all configured slides after multi-file incremental runs.
  & powershell -ExecutionPolicy Bypass -File scripts/collect-rendered-slides.ps1
  if ($LASTEXITCODE -ne 0) {
    throw "collect-rendered-slides.ps1 failed with exit code $LASTEXITCODE"
  }
}
