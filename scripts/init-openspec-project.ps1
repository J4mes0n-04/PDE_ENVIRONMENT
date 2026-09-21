[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $repoRoot "workspaces/projects/$ProjectId"
$templatePath = Join-Path $repoRoot 'templates/openspec'
$targetPath = Join-Path $projectPath 'openspec'

if (-not (Test-Path -LiteralPath $projectPath)) {
    Write-Error "Project folder is missing: $projectPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $templatePath)) {
    Write-Error "OpenSpec template is missing: $templatePath"
    exit 1
}

function Copy-OpenSpecTemplate {
    param([string]$Source, [string]$Destination)
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    foreach ($item in Get-ChildItem -LiteralPath $Source -Force) {
        $destinationItem = Join-Path $Destination $item.Name
        if ($item.PSIsContainer) {
            Copy-OpenSpecTemplate -Source $item.FullName -Destination $destinationItem
        } elseif ($item.Name -eq 'config.yaml' -or -not (Test-Path -LiteralPath $destinationItem)) {
            Copy-Item -LiteralPath $item.FullName -Destination $destinationItem -Force
        }
    }
}

$openspecCommand = Get-Command openspec -ErrorAction SilentlyContinue
$env:OPENSPEC_TELEMETRY = '0'
$env:DO_NOT_TRACK = '1'
$env:OPENSPEC_NO_ANIMATION = '1'

if ($openspecCommand -and -not (Test-Path -LiteralPath (Join-Path $targetPath 'config.yaml'))) {
    Write-Host "Initializing OpenSpec CLI structure in $projectPath"
    & openspec init $projectPath --tools none --language ru --no-animation
    if ($LASTEXITCODE -ne 0) {
        Write-Error "openspec init failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

Copy-OpenSpecTemplate -Source $templatePath -Destination $targetPath

Write-Host "OpenSpec intake is ready: $targetPath"
Write-Host "Create a change under openspec/changes/<change-id>/ before any Outcome Pack."
