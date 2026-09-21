[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [Parameter(Mandatory = $true)]
    [string]$ChangeName
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not [IO.Path]::IsPathRooted($ProjectPath)) {
    $ProjectPath = Join-Path $repoRoot $ProjectPath
}

$openspecRoot = Join-Path $ProjectPath 'openspec'
$changePath = Join-Path $openspecRoot "changes/$ChangeName"
$configPath = Join-Path $openspecRoot 'config.yaml'

if (-not (Test-Path -LiteralPath $configPath)) {
    $failures.Add("OpenSpec config is missing: $configPath")
}
if (-not (Test-Path -LiteralPath $changePath)) {
    $failures.Add("Change folder is missing: $changePath")
}

$proposalPath = Join-Path $changePath 'proposal.md'
if (-not (Test-Path -LiteralPath $proposalPath)) {
    $failures.Add("proposal.md is missing in $changePath")
} else {
    $proposal = Get-Content -Raw -LiteralPath $proposalPath
    if ($proposal -notmatch '[А-Яа-яЁё]') {
        $failures.Add("proposal.md must contain Russian human-readable text: $proposalPath")
    }
}

$specFiles = @()
$specsRoot = Join-Path $changePath 'specs'
if (Test-Path -LiteralPath $specsRoot) {
    $specFiles = @(Get-ChildItem -LiteralPath $specsRoot -Filter 'spec.md' -File -Recurse)
}
if ($specFiles.Count -eq 0) {
    $failures.Add("Change has no delta spec.md files: $changePath")
}

$requirementIds = [System.Collections.Generic.List[string]]::new()
foreach ($specFile in $specFiles) {
    $text = Get-Content -Raw -LiteralPath $specFile.FullName
    if ($text -notmatch '(?m)^##\s+(ADDED|MODIFIED|REMOVED)\s+Requirements\s*$') {
        $failures.Add("Delta spec must contain ADDED, MODIFIED or REMOVED Requirements: $($specFile.FullName)")
    }
    if ($text -notmatch '[А-Яа-яЁё]') {
        $failures.Add("Delta spec must contain Russian human-readable text: $($specFile.FullName)")
    }
    $idMatches = [regex]::Matches($text, '(?m)^###\s+Requirement:\s*(?<id>(?:AC|NFR)-[0-9]{3,})\s+')
    foreach ($match in $idMatches) {
        $requirementIds.Add($match.Groups['id'].Value)
    }
}

if ($requirementIds.Count -eq 0) {
    $failures.Add("No AC-NNN or NFR-NNN requirements found in $changePath")
}

$duplicates = @($requirementIds) | Group-Object | Where-Object Count -gt 1
foreach ($duplicate in $duplicates) {
    $failures.Add("Duplicate requirement id '$($duplicate.Name)' in $changePath")
}

$forbiddenPack = @(Get-ChildItem -LiteralPath $changePath -Filter 'pack.*' -File -Recurse -ErrorAction SilentlyContinue)
foreach ($packFile in $forbiddenPack) {
    $failures.Add("OpenSpec change must not contain Pack files: $($packFile.FullName)")
}

$openspecCommand = Get-Command openspec -ErrorAction SilentlyContinue
if ($openspecCommand -and (Test-Path -LiteralPath $openspecRoot)) {
    $env:OPENSPEC_TELEMETRY = '0'
    $env:DO_NOT_TRACK = '1'
    Push-Location $ProjectPath
    try {
        & openspec validate $ChangeName
        if ($LASTEXITCODE -ne 0) {
            $failures.Add("openspec validate failed for change '$ChangeName' in $ProjectPath")
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "OpenSpec CLI is not available; structural PDE checks only."
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "OpenSpec change '$ChangeName' is structurally valid."
Write-Host ("Requirement ids: " + (($requirementIds | Select-Object -Unique) -join ', '))
