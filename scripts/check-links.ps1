[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$markdownFiles = @(Get-ChildItem -LiteralPath $repoRoot -Filter '*.md' -File -Recurse -Force)

foreach ($markdownFile in $markdownFiles) {
    $text = Get-Content -Raw -LiteralPath $markdownFile.FullName
    $matches = [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')
    foreach ($match in $matches) {
        $target = $match.Groups[1].Value.Trim().Trim('<', '>')
        if ($target -match '^(https?://|mailto:|demo:|#)') {
            continue
        }
        $pathPart = ($target -split '#', 2)[0]
        if (-not $pathPart) {
            continue
        }
        $decoded = [Uri]::UnescapeDataString($pathPart)
        $absoluteTarget = Join-Path $markdownFile.DirectoryName $decoded
        if (-not (Test-Path -LiteralPath $absoluteTarget)) {
            $relativeSource = [IO.Path]::GetRelativePath($repoRoot, $markdownFile.FullName)
            $failures.Add("Broken local link in ${relativeSource}: $target")
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Checked local links in $($markdownFiles.Count) Markdown file(s)."
