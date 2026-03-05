param(
  [string]$ConfigPath = "google-slides-images.yml"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-SafeFileName {
  param([string]$Name)
  $safe = $Name -replace '[^A-Za-z0-9._-]', '_'
  if ([string]::IsNullOrWhiteSpace($safe)) {
    throw "Resolved file name is empty."
  }
  return $safe
}

function Convert-YamlScalar {
  param([string]$Value)
  if ($null -eq $Value) { return "" }
  $v = $Value.Trim()
  if (($v.StartsWith('"') -and $v.EndsWith('"')) -or ($v.StartsWith("'") -and $v.EndsWith("'"))) {
    if ($v.Length -ge 2) {
      return $v.Substring(1, $v.Length - 2)
    }
  }
  return $v
}

function Parse-GoogleSlidesEditUrl {
  param([string]$Url)

  if ([string]::IsNullOrWhiteSpace($Url)) {
    throw "Google Slides URL is empty."
  }

  $docId = $null
  if ($Url -match 'docs\.google\.com/presentation/d/(?<doc>[^/?#]+)') {
    $docId = $matches['doc']
  } else {
    throw "Could not extract document_id from URL: $Url"
  }

  $slideToken = $null
  if ($Url -match '(?:[?#&]slide=id\.(?<sid>[^&#]+))') {
    $slideToken = $matches['sid']
  } elseif ($Url -match '(?:[?&]pageid=(?<pid>[^&#]+))') {
    $slideToken = $matches['pid']
  }

  $pageId = $null
  if (-not [string]::IsNullOrWhiteSpace($slideToken)) {
    $pageId = $slideToken
    if ($pageId.StartsWith('id.')) {
      $pageId = $pageId.Substring(3)
    }
  }

  return @{
    document_id = $docId
    pageid = $pageId
  }
}

function Read-SlidesConfigYaml {
  param([string]$Path)

  $lines = Get-Content -Path $Path
  $outputDir = "images"
  $presentations = @()
  $currentPresentation = $null
  $currentSlide = $null

  foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    if ($line -match '^\s*#') { continue }

    if ($line -match '^\s*output_dir:\s*(?<value>.+?)\s*$') {
      $outputDir = Convert-YamlScalar -Value $matches['value']
      continue
    }

    if ($line -match '^\s*-\s*document_id:\s*(?<value>.+?)\s*$') {
      $docId = Convert-YamlScalar -Value $matches['value']
      $currentPresentation = [ordered]@{
        document_id = $docId
        slides = @()
      }
      $presentations += ,$currentPresentation
      $currentSlide = $null
      continue
    }

    if ($line -match '^\s*-\s*(?<key>pageid|edit_url|slide_edit_url):\s*(?<value>.+?)\s*$') {
      if ($null -eq $currentPresentation) {
        throw "Found slide entry before document_id in config: $Path"
      }
      $k = [string]$matches['key']
      $v = Convert-YamlScalar -Value $matches['value']
      $currentSlide = [ordered]@{}
      $currentSlide[$k] = $v
      $currentPresentation.slides += ,$currentSlide
      continue
    }

    if ($line -match '^\s*(?<key>pageid|slide_pageid|filename|edit_url|slide_edit_url):\s*(?<value>.+?)\s*$') {
      if ($null -eq $currentSlide) {
        throw "Found $($matches['key']) before slide entry start in config: $Path"
      }
      $currentSlide[$matches['key']] = Convert-YamlScalar -Value $matches['value']
      continue
    }
  }

  return @{
    output_dir = $outputDir
    presentations = $presentations
  }
}

function Resolve-OutputFileName {
  param(
    [string]$PageId,
    [string]$ExplicitName
  )

  if (-not [string]::IsNullOrWhiteSpace($ExplicitName)) {
    return (Get-SafeFileName -Name $ExplicitName)
  }

  return (Get-SafeFileName -Name $PageId)
}

if (-not (Test-Path $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$config = Read-SlidesConfigYaml -Path $ConfigPath

if (-not $config.presentations -or $config.presentations.Count -eq 0) {
  throw "No presentations found in config: $ConfigPath"
}

$projectRoot = (Get-Location).Path
$outputDir = if ($config.output_dir) { [string]$config.output_dir } else { "images" }
$outputPath = Join-Path $projectRoot $outputDir
$bookOutputPath = Join-Path $outputPath "google_slides"
$slidesOutputPath = Join-Path (Join-Path $outputPath "slides") "google_slides"
New-Item -ItemType Directory -Force -Path $bookOutputPath | Out-Null
New-Item -ItemType Directory -Force -Path $slidesOutputPath | Out-Null

$downloaded = 0
foreach ($presentation in $config.presentations) {
  $docId = [string]$presentation.document_id
  if (-not $presentation.slides -or $presentation.slides.Count -eq 0) {
    throw "Presentation $docId has no slides configured."
  }

  foreach ($slide in $presentation.slides) {
    $pageId = $null
    if ($slide.Contains("pageid")) {
      $pageId = [string]$slide.pageid
    }

    if ($slide.Contains("edit_url")) {
      $parsed = Parse-GoogleSlidesEditUrl -Url ([string]$slide.edit_url)
      if ([string]::IsNullOrWhiteSpace($docId)) {
        $docId = [string]$parsed.document_id
      } elseif ($docId -ne [string]$parsed.document_id) {
        throw "document_id mismatch between presentation ($docId) and edit_url ($($parsed.document_id))."
      }
      if ([string]::IsNullOrWhiteSpace($pageId)) {
        $pageId = [string]$parsed.pageid
      }
    }

    if ([string]::IsNullOrWhiteSpace($docId)) {
      throw "Missing document_id. Set presentation.document_id or use edit_url."
    }
    if ([string]::IsNullOrWhiteSpace($pageId)) {
      throw "A slide entry in presentation $docId is missing pageid. Set pageid or edit_url with slide=id..."
    }

    $explicitName = $null
    if ($slide.Contains("filename")) {
      $explicitName = [string]$slide.filename
    }

    $nameBase = Resolve-OutputFileName -PageId $pageId -ExplicitName $explicitName
    $bookFilePath = Join-Path $bookOutputPath ($nameBase + ".svg")

    $bookUrl = "https://docs.google.com/presentation/d/$docId/export/svg?pageid=$pageId"
    Write-Host "Downloading $bookUrl"

    $bookResponse = Invoke-WebRequest -Uri $bookUrl -UseBasicParsing
    $bookSvg = [string]$bookResponse.Content
    if ([string]::IsNullOrWhiteSpace($bookSvg)) {
      throw "Empty SVG response for $docId / $pageId"
    }

    Set-Content -Path $bookFilePath -Value $bookSvg -Encoding UTF8
    Write-Host ("Saved: {0}" -f $bookFilePath)
    $downloaded++

    $slidePageId = $null
    if ($slide.Contains("slide_pageid")) {
      $slidePageId = [string]$slide.slide_pageid
    }
    if ([string]::IsNullOrWhiteSpace($slidePageId) -and $slide.Contains("slide_edit_url")) {
      $parsedSlide = Parse-GoogleSlidesEditUrl -Url ([string]$slide.slide_edit_url)
      if ($docId -ne [string]$parsedSlide.document_id) {
        throw "document_id mismatch between presentation ($docId) and slide_edit_url ($($parsedSlide.document_id))."
      }
      $slidePageId = [string]$parsedSlide.pageid
    }

    if (-not [string]::IsNullOrWhiteSpace($slidePageId)) {
      $slideUrl = "https://docs.google.com/presentation/d/$docId/export/svg?pageid=$slidePageId"
      Write-Host "Downloading $slideUrl"

      $slideResponse = Invoke-WebRequest -Uri $slideUrl -UseBasicParsing
      $slideSvg = [string]$slideResponse.Content
      if ([string]::IsNullOrWhiteSpace($slideSvg)) {
        throw "Empty SVG response for $docId / $slidePageId"
      }

      $slideFilePath = Join-Path $slidesOutputPath ($nameBase + ".svg")
      Set-Content -Path $slideFilePath -Value $slideSvg -Encoding UTF8
      Write-Host ("Saved: {0}" -f $slideFilePath)
      $downloaded++
    }
  }
}

Write-Host ("Done. Downloaded {0} SVG file(s) to {1} (and optionally {2})" -f $downloaded, $bookOutputPath, $slidesOutputPath)
