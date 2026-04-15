param(
    [string]$SourceDir = "_exercises-render",
    [string]$DestinationDir = "_book/exercises"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceDir)) {
    Write-Host "Exercises render directory not found: $SourceDir"
    exit 0
}

New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null

$pdfFiles = Get-ChildItem -Path $SourceDir -Recurse -Filter *.pdf -File

foreach ($pdfFile in $pdfFiles) {
    Copy-Item -LiteralPath $pdfFile.FullName -Destination (Join-Path $DestinationDir $pdfFile.Name) -Force
}

Write-Host "Copied $($pdfFiles.Count) exercise PDF(s) to $DestinationDir"
