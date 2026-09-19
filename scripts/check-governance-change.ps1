[CmdletBinding()]
param(
    [string]$BaseRef,
    [string]$PullRequestBody = $env:PR_BODY
)

$ErrorActionPreference = 'Stop'

if (-not $BaseRef) {
    Write-Host 'No base ref provided; structural governance checks only.'
    & (Join-Path $PSScriptRoot 'validate-repository.ps1')
    exit $LASTEXITCODE
}

$changed = @(git diff --name-only "$BaseRef...HEAD")
if ($LASTEXITCODE -ne 0) {
    Write-Error "Unable to read git diff against $BaseRef"
    exit 1
}

$governanceChanged = @($changed | Where-Object { $_ -like 'governance/*' })
if ($governanceChanged.Count -eq 0) {
    Write-Host 'No governance documents changed.'
    exit 0
}

Write-Host 'Governance changes detected:'
$governanceChanged | ForEach-Object { Write-Host " - $_" }

if (-not $PullRequestBody -or
    $PullRequestBody -notmatch '(?im)^Reason:\s*(?!N/A\s*$)\S+' -or
    $PullRequestBody -notmatch '(?im)^Governance impact:\s*(?!none\s*$)\S+') {
    Write-Error "PR body must contain non-empty 'Reason:' and 'Governance impact:' fields."
    exit 1
}

& (Join-Path $PSScriptRoot 'validate-repository.ps1')
exit $LASTEXITCODE
