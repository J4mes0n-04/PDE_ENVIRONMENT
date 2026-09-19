[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

$requiredPaths = @(
    'README.md', 'AGENTS.md', 'CONTRIBUTING.md', 'SECURITY.md',
    'governance/document-control.yaml', 'governance/01-pde-charter.md',
    'governance/19-ase-qsre-interface-contract.md',
    'config/features.yaml', 'schemas/pack.schema.json',
    'workspaces/README.md', 'workspaces/projects/README.md',
    'integrations/openspace/README.md', '.codex/config.toml'
)

foreach ($relativePath in $requiredPaths) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath))) {
        $failures.Add("Required path is missing: $relativePath")
    }
}

$catalogPath = Join-Path $repoRoot 'governance/document-control.yaml'
if (Test-Path -LiteralPath $catalogPath) {
    $catalogText = Get-Content -Raw -LiteralPath $catalogPath
    $catalogMatches = [regex]::Matches($catalogText, '(?m)^\s+path:\s+(.+)$')
    foreach ($match in $catalogMatches) {
        $relativePath = $match.Groups[1].Value.Trim()
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath))) {
            $failures.Add("Document catalog points to missing file: $relativePath")
        }
    }
}

$skillFiles = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot '.agents/skills') -Filter 'SKILL.md' -File -Recurse)
if ($skillFiles.Count -lt 5) {
    $failures.Add("Expected at least 5 skills, found $($skillFiles.Count)")
}
foreach ($skillFile in $skillFiles) {
    $text = Get-Content -Raw -LiteralPath $skillFile.FullName
    if ($text -notmatch '(?s)^---\s*.*?name:\s*[a-z0-9-]+\s+description:\s*.+?\s*---') {
        $failures.Add("Invalid SKILL.md frontmatter: $($skillFile.FullName)")
    }
}

$codexConfig = Join-Path $repoRoot '.codex/config.toml'
if (Test-Path -LiteralPath $codexConfig) {
    $configText = Get-Content -Raw -LiteralPath $codexConfig
    if ($configText -notmatch 'OPENSPACE_CLOUD_MODE\s*=\s*"off"') {
        $failures.Add('OpenSpace cloud mode is not explicitly off in .codex/config.toml')
    }
    if ($configText -notmatch '(?m)^enabled\s*=\s*false$') {
        $failures.Add('OpenSpace must be disabled in the base .codex/config.toml')
    }
}

try {
    Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'schemas/pack.schema.json') | ConvertFrom-Json -Depth 100 | Out-Null
} catch {
    $failures.Add("Invalid JSON schema: $($_.Exception.Message)")
}

$catalogFile = Join-Path $repoRoot 'docs/file-catalog.md'
if (Test-Path -LiteralPath $catalogFile) {
    $fileCatalog = Get-Content -Raw -LiteralPath $catalogFile
    $repositoryFiles = @(Get-ChildItem -LiteralPath $repoRoot -File -Recurse -Force)
    foreach ($repositoryFile in $repositoryFiles) {
        $relativePath = [IO.Path]::GetRelativePath($repoRoot, $repositoryFile.FullName).Replace('\', '/')
        if ($relativePath -match '^(\.git|\.openspace|artifacts|reports)/') {
            continue
        }
        $catalogToken = ([char]96) + $relativePath + ([char]96)
        if ($fileCatalog -notmatch [regex]::Escape($catalogToken)) {
            $failures.Add("File is not described in docs/file-catalog.md: $relativePath")
        }
    }
} else {
    $failures.Add('docs/file-catalog.md is missing')
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Repository structure is valid. Skills found: $($skillFiles.Count)."

& (Join-Path $PSScriptRoot 'check-links.ps1')
exit $LASTEXITCODE
