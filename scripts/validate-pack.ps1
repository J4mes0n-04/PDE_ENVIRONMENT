[CmdletBinding()]
param(
    [string]$Path
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$schemaPath = Join-Path $repoRoot 'schemas/pack.schema.json'
$failures = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $schemaPath)) {
    Write-Error "Schema not found: $schemaPath"
    exit 1
}

if ($Path) {
    $resolved = Resolve-Path -LiteralPath $Path
    if ((Get-Item -LiteralPath $resolved).PSIsContainer) {
        $packFiles = @(Get-ChildItem -LiteralPath $resolved -Filter 'pack.json' -File -Recurse)
    } else {
        $packFiles = @(Get-Item -LiteralPath $resolved)
    }
} else {
    $workspaces = Join-Path $repoRoot 'workspaces'
    $packFiles = @(Get-ChildItem -LiteralPath $workspaces -Filter 'pack.json' -File -Recurse)
}

if ($packFiles.Count -eq 0) {
    Write-Host 'No operational pack.json files found.'
    exit 0
}

foreach ($packFile in $packFiles) {
    Write-Host "Validating $($packFile.FullName)"
    $jsonText = Get-Content -Raw -LiteralPath $packFile.FullName
    try {
        if (-not ($jsonText | Test-Json -SchemaFile $schemaPath -ErrorAction Stop)) {
            $failures.Add("Schema validation failed: $($packFile.FullName)")
            continue
        }
        $pack = $jsonText | ConvertFrom-Json -Depth 50
    } catch {
        $failures.Add("Invalid pack JSON or schema mismatch: $($packFile.FullName): $($_.Exception.Message)")
        continue
    }

    $markdownPath = Join-Path $packFile.DirectoryName 'pack.md'
    if (-not (Test-Path -LiteralPath $markdownPath)) {
        $failures.Add("Matching pack.md is missing: $($packFile.DirectoryName)")
        continue
    }

    $markdown = Get-Content -Raw -LiteralPath $markdownPath
    foreach ($expectedValue in @($pack.outcome_id, $pack.version, $pack.risk_level)) {
        if ($markdown -notmatch [regex]::Escape([string]$expectedValue)) {
            $failures.Add("pack.md does not contain '$expectedValue': $markdownPath")
        }
    }

    $ids = @($pack.acceptance_criteria.id) + @($pack.nfrs.id)
    $duplicates = $ids | Group-Object | Where-Object Count -gt 1
    foreach ($duplicate in $duplicates) {
        $failures.Add("Duplicate requirement id '$($duplicate.Name)': $($packFile.FullName)")
    }
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Validated $($packFiles.Count) Pack control record(s)."
