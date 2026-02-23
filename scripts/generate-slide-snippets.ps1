Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Get-Location).Path
$slidesConfigPath = Join-Path $projectRoot "_quarto-slides.yml"

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
        $targets.Add($p)
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

function Build-SlideGenerationJobs {
  param([string[]]$Targets)

  $jobs = New-Object System.Collections.Generic.List[object]
  foreach ($targetRel in $Targets) {
    $targetNorm = ($targetRel -replace '\\', '/')
    if ($targetNorm -notlike "*/_generated/*.qmd") {
      continue
    }

    $sourceRel = $targetNorm -replace '/_generated/', '/'
    $sourceAbs = Join-Path $projectRoot $sourceRel
    $targetAbs = Join-Path $projectRoot $targetNorm

    $jobs.Add([pscustomobject]@{
      SourceRelative = $sourceRel
      SourceAbsolute = $sourceAbs
      TargetRelative = $targetNorm
      TargetAbsolute = $targetAbs
    })
  }
  return $jobs
}

function Get-FrontMatter {
  param([string]$Text)
  $m = [regex]::Match($Text, '(?s)\A\s*---\r?\n(.*?)\r?\n---\r?\n')
  if ($m.Success) { return $m.Groups[1].Value }
  return $null
}

function Get-FrontMatterValue {
  param(
    [string]$FrontMatter,
    [string[]]$Keys
  )
  if (-not $FrontMatter) { return $null }
  $lines = $FrontMatter -split "`r?`n"
  foreach ($line in $lines) {
    foreach ($key in $Keys) {
      $m = [regex]::Match($line, "^\s*$([regex]::Escape($key))\s*:\s*(.*?)\s*$")
      if ($m.Success) {
        $v = $m.Groups[1].Value.Trim()
        $v = $v -replace '\s+#.*$', ''
        $v = $v.Trim('"').Trim("'").Trim()
        if ($v -ne "") { return $v }
      }
    }
  }
  return $null
}

function Resolve-PathFromSlide {
  param(
    [string]$RawPath,
    [string]$SlidePath
  )
  if ([string]::IsNullOrWhiteSpace($RawPath)) { return $null }
  $normalized = $RawPath -replace '\\', '/'

  $candidates = @(
    $normalized,
    (Join-Path (Split-Path $SlidePath -Parent) $normalized),
    (Join-Path $projectRoot $normalized)
  )

  foreach ($cand in $candidates) {
    if (Test-Path $cand) {
      return (Resolve-Path $cand).Path
    }
  }
  return $null
}

function Extract-ReuseById {
  param(
    [string]$Text,
    [string]$Id
  )
  if ([string]::IsNullOrWhiteSpace($Id)) { return $null }
  $idEsc = [regex]::Escape($Id)
  $pattern = "(?ms)^:::\s*\{[^}]*\.reuse[^}]*#$idEsc[^}]*\}\s*\r?\n(.*?)\r?\n:::\s*$"
  $m = [regex]::Match($Text, $pattern)
  if ($m.Success) { return $m.Groups[1].Value }
  return $null
}

function Extract-ChunkByLabel {
  param(
    [string]$Text,
    [string]$Label
  )
  if ([string]::IsNullOrWhiteSpace($Label)) { return $null }
  $lines = $Text -split "`r?`n"

  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^```+\s*\{.*\}\s*$') {
      $j = $i + 1
      $found = $null
      while ($j -lt $lines.Count -and $lines[$j] -match '^\s*#\|') {
        if ($lines[$j] -match '^\s*#\|\s*label\s*:\s*(.+?)\s*$') {
          $found = $matches[1].Trim()
        }
        $j++
      }

      if ($found -eq $Label) {
        $k = $j
        while ($k -lt $lines.Count -and $lines[$k] -notmatch '^```+\s*$') {
          $k++
        }
        if ($k -ge $lines.Count) {
          throw "snippet: unterminated code fence for label='$Label'"
        }

        $out = New-Object System.Collections.Generic.List[string]
        for ($t = $i; $t -le $k; $t++) {
          $line = $lines[$t]
          # Strip Quarto code annotation markers like "# <1>" from slide code.
          $line = [regex]::Replace($line, '\s+#\s*<\d+>\s*$', '')
          $out.Add($line)
        }

        return ($out -join "`n")
      }
    }
  }
  return $null
}

function Parse-SnippetAttributes {
  param([string]$AttrText)
  $dict = @{}
  if ([string]::IsNullOrWhiteSpace($AttrText)) { return $dict }
  $rx = [regex] '([a-zA-Z_][a-zA-Z0-9_-]*)\s*=\s*"([^"]*)"'
  $matches = $rx.Matches($AttrText)
  foreach ($m in $matches) {
    $dict[$m.Groups[1].Value] = $m.Groups[2].Value
  }
  return $dict
}

$targets = @(Get-ConfiguredSlideTargets -ConfigPath $slidesConfigPath)
$jobs = @(Build-SlideGenerationJobs -Targets $targets)

if ($jobs.Count -eq 0) {
  throw "No '/_generated/*.qmd' targets configured under project.render in _quarto-slides.yml"
}

foreach ($job in $jobs) {
  if (-not (Test-Path $job.SourceAbsolute)) {
    throw "Configured source slide not found: $($job.SourceRelative)"
  }

  $outDir = Split-Path -Parent $job.TargetAbsolute
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null

  $text = Get-Content -Raw -Path $job.SourceAbsolute
  $fm = Get-FrontMatter -Text $text
  $defaultSnippetFile = Get-FrontMatterValue -FrontMatter $fm -Keys @("snippet_file", "snippet-file")

  $rxSnippet = [regex] '\{\{<\s*snippet\b(.*?)>\}\}'
  $output = $rxSnippet.Replace($text, {
    param($m)
    $attrs = Parse-SnippetAttributes -AttrText $m.Groups[1].Value

    $fileRaw = $null
    if ($attrs.ContainsKey("file")) {
      $fileRaw = $attrs["file"]
    } else {
      $fileRaw = $defaultSnippetFile
    }
    if ([string]::IsNullOrWhiteSpace($fileRaw)) {
      throw "snippet: requires file='...' or YAML snippet_file in $($job.SourceAbsolute)"
    }

    $sourceFile = Resolve-PathFromSlide -RawPath $fileRaw -SlidePath $job.SourceAbsolute
    if (-not $sourceFile) {
      throw "snippet: cannot open file '$fileRaw' referenced from $($job.SourceAbsolute)"
    }

    $sourceText = Get-Content -Raw -Path $sourceFile
    $id = if ($attrs.ContainsKey("id")) { $attrs["id"] } else { $null }
    $label = if ($attrs.ContainsKey("label")) { $attrs["label"] } else { $null }

    if (-not [string]::IsNullOrWhiteSpace($id)) {
      $frag = Extract-ReuseById -Text $sourceText -Id $id
      if (-not $frag) {
        throw "snippet: no ::: {.reuse #$id} found in $sourceFile (referenced from $($job.SourceAbsolute))"
      }
      return $frag
    }

    if (-not [string]::IsNullOrWhiteSpace($label)) {
      $frag = Extract-ChunkByLabel -Text $sourceText -Label $label
      if (-not $frag) {
        throw "snippet: no code chunk with '#| label: $label' found in $sourceFile (referenced from $($job.SourceAbsolute))"
      }
      return $frag
    }

    throw "snippet: requires id='...' OR label='...' in $($job.SourceAbsolute)"
  })

  Set-Content -Path $job.TargetAbsolute -Value $output -NoNewline
}

Write-Host ("Generated slides with snippets for targets: {0}" -f ($jobs.TargetRelative -join ", "))
