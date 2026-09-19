[CmdletBinding()]
param(
    [string]$Path
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

if ($Path) {
    $resolved = Resolve-Path -LiteralPath $Path
    if ((Get-Item -LiteralPath $resolved).PSIsContainer) {
        $evidenceFiles = @(Get-ChildItem -LiteralPath $resolved -Filter 'evidence.md' -File -Recurse)
    } else {
        $evidenceFiles = @(Get-Item -LiteralPath $resolved)
    }
} else {
    $evidenceFiles = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'workspaces') -Filter 'evidence.md' -File -Recurse)
}

if ($evidenceFiles.Count -eq 0) {
    Write-Host 'No evidence.md files found.'
    exit 0
}

foreach ($evidenceFile in $evidenceFiles) {
    Write-Host "Validating $($evidenceFile.FullName)"
    $text = Get-Content -Raw -LiteralPath $evidenceFile.FullName
    $packPath = Join-Path $evidenceFile.DirectoryName 'pack.json'
    if (-not (Test-Path -LiteralPath $packPath)) {
        $failures.Add("pack.json is missing next to evidence: $($evidenceFile.FullName)")
        continue
    }

    $pack = Get-Content -Raw -LiteralPath $packPath | ConvertFrom-Json -Depth 50
    foreach ($requirementId in @($pack.acceptance_criteria.id) + @($pack.nfrs.id)) {
        if ($text -notmatch [regex]::Escape([string]$requirementId)) {
            $failures.Add("Evidence does not mention requirement '$requirementId': $($evidenceFile.FullName)")
        }
    }

    foreach ($requiredToken in @('Evidence ID', 'Result', 'Limitations', 'Coverage gaps')) {
        if ($text -notmatch [regex]::Escape($requiredToken)) {
            $failures.Add("Evidence is missing section or field '$requiredToken': $($evidenceFile.FullName)")
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Validated $($evidenceFiles.Count) Evidence Bundle(s)."
