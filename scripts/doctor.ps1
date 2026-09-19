[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

Write-Host "PDE environment doctor"
Write-Host "Repository: $repoRoot"

$requiredFiles = @(
    'README.md', 'AGENTS.md', 'config/features.yaml',
    'governance/document-control.yaml', 'schemas/pack.schema.json',
    '.github/workflows/validate-repository.yml',
    '.github/workflows/validate-pack.yml',
    '.github/workflows/validate-evidence.yml',
    '.github/workflows/governance-change-control.yml'
)

foreach ($relativePath in $requiredFiles) {
    $absolutePath = Join-Path $repoRoot $relativePath
    if (Test-Path -LiteralPath $absolutePath) {
        Write-Host "[OK] $relativePath"
    } else {
        $failures.Add("Missing required file: $relativePath")
        Write-Host "[FAIL] $relativePath"
    }
}

foreach ($commandName in @('git', 'pwsh')) {
    if (Get-Command $commandName -ErrorAction SilentlyContinue) {
        Write-Host "[OK] command $commandName"
    } else {
        $failures.Add("Command is not available: $commandName")
        Write-Host "[FAIL] command $commandName"
    }
}

$featureText = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'config/features.yaml')
foreach ($feature in @('openspace_local', 'unleash', 'opentelemetry', 'grafana')) {
    if ($featureText -notmatch "(?m)^  ${feature}:") {
        $failures.Add("Feature declaration is missing: $feature")
    }
}

if ($featureText -notmatch '(?m)^  allow_openspace_cloud: false$') {
    $failures.Add('OpenSpace cloud must remain disabled in the base package.')
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Doctor completed successfully. Optional integrations may remain disabled."
