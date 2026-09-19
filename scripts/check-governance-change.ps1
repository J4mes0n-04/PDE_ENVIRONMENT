[CmdletBinding()]
param(
    [string]$BaseRef,
    [string]$PullRequestBody = $env:PR_BODY,
    [string[]]$ChangedPaths
)

$ErrorActionPreference = 'Stop'

if (-not $BaseRef -and -not $ChangedPaths) {
    Write-Host 'No base ref provided; structural governance checks only.'
    & (Join-Path $PSScriptRoot 'validate-repository.ps1')
    exit $LASTEXITCODE
}

if ($ChangedPaths) {
    $changed = @($ChangedPaths)
} else {
    $changed = @(git diff --name-only "$BaseRef...HEAD")
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Unable to read git diff against $BaseRef"
        exit 1
    }
}

$governanceImpactPatterns = @(
    'governance/*',
    'architecture/*',
    'templates/*',
    'schemas/*',
    'scripts/*',
    'integrations/*',
    '.agents/skills/*',
    '.cursor/rules/*',
    '.codex/*',
    '.github/workflows/*',
    'config/features.yaml',
    'AGENTS.md',
    'SECURITY.md'
)

$governanceImpacting = @($changed | Where-Object {
    $path = $_.Replace('\', '/')
    @($governanceImpactPatterns | Where-Object { $path -like $_ }).Count -gt 0
})

if ($governanceImpacting.Count -eq 0) {
    Write-Host 'No governance-impacting platform files changed.'
    exit 0
}

Write-Host 'Governance-impacting changes detected:'
$governanceImpacting | ForEach-Object { Write-Host " - $_" }

function Get-PrField {
    param([string]$Body, [string]$Name)
    if ([string]::IsNullOrWhiteSpace($Body)) { return $null }
    $match = [regex]::Match($Body, "(?im)^\s*$([regex]::Escape($Name))\s*:\s*(?<value>.*?)\s*$")
    if (-not $match.Success) { return $null }
    return ([regex]::Replace($match.Groups['value'].Value, '<!--.*?-->', '')).Trim()
}

function Test-MeaningfulPrField {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Length -lt 20) { return $false }
    return $Value -notmatch '(?i)^\s*(n/?a|not applicable|none|no impact|нет|не применимо|без влияния|tbd|todo|-)(\b|\s|$)' 
}

$reason = Get-PrField -Body $PullRequestBody -Name 'Reason'
$governanceImpact = Get-PrField -Body $PullRequestBody -Name 'Governance impact'
if (-not (Test-MeaningfulPrField -Value $reason) -or
    -not (Test-MeaningfulPrField -Value $governanceImpact)) {
    Write-Error "Governance-impacting PR must contain meaningful 'Reason:' and 'Governance impact:' values (at least 20 characters; N/A, none, no impact, TBD and equivalents are forbidden)."
    exit 1
}

Write-Host 'PR rationale is present and meaningful.'

& (Join-Path $PSScriptRoot 'validate-repository.ps1')
exit $LASTEXITCODE
