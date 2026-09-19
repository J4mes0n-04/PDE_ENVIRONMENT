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

    $documentBlocks = [regex]::Matches($catalogText, '(?ms)^  - id:\s*(?<id>\S+)\s*\r?\n(?<body>.*?)(?=^  - id:|\z)')
    foreach ($block in $documentBlocks) {
        $catalogId = $block.Groups['id'].Value.Trim()
        $body = $block.Groups['body'].Value
        $catalogFields = @{}
        foreach ($field in @('path', 'type', 'owner_role', 'approver_role', 'status', 'version', 'review_cycle_days')) {
            $fieldMatch = [regex]::Match($body, "(?m)^    $([regex]::Escape($field)):\s*(?<value>.+?)\s*$")
            if ($fieldMatch.Success) { $catalogFields[$field] = $fieldMatch.Groups['value'].Value.Trim() }
        }
        if (-not $catalogFields.ContainsKey('path')) { continue }

        $documentPath = Join-Path $repoRoot $catalogFields['path']
        if (-not (Test-Path -LiteralPath $documentPath)) { continue }
        $documentText = Get-Content -Raw -LiteralPath $documentPath
        $requiredMetadata = @('Document ID', 'Type', 'Status', 'Version', 'Owner', 'Approver', 'Scope', 'Effective date', 'Review cycle', 'Changelog')
        $metadata = @{}
        foreach ($field in $requiredMetadata) {
            $matches = [regex]::Matches($documentText, "(?im)^$([regex]::Escape($field)):\s*(?<value>.+?)\s*$")
            if ($matches.Count -ne 1) {
                $failures.Add("Governance metadata '$field' must occur exactly once in $($catalogFields['path']); found $($matches.Count)")
            } else {
                $metadata[$field] = $matches[0].Groups['value'].Value.Trim()
            }
        }

        $expectedMetadata = @{
            'Document ID' = $catalogId
            'Type' = $catalogFields['type']
            'Status' = $catalogFields['status']
            'Version' = $catalogFields['version']
            'Owner' = $catalogFields['owner_role']
            'Approver' = $catalogFields['approver_role']
            'Review cycle' = "$($catalogFields['review_cycle_days']) days"
        }
        foreach ($entry in $expectedMetadata.GetEnumerator()) {
            if ($metadata.ContainsKey($entry.Key) -and $metadata[$entry.Key] -ine $entry.Value) {
                $failures.Add("Governance metadata '$($entry.Key)' in $($catalogFields['path']) is '$($metadata[$entry.Key])', expected '$($entry.Value)'")
            }
        }
        if ($metadata.ContainsKey('Scope') -and $metadata['Scope'].Length -lt 20) {
            $failures.Add("Governance metadata 'Scope' is not descriptive enough in $($catalogFields['path'])")
        }
        if ($metadata.ContainsKey('Effective date') -and $catalogFields['status'] -ieq 'active' -and $metadata['Effective date'] -match '(?i)not set|не назнач') {
            $failures.Add("Active governance document must have an effective date: $($catalogFields['path'])")
        }
        if ($metadata.ContainsKey('Changelog') -and $metadata['Changelog'] -notmatch [regex]::Escape($catalogFields['version'])) {
            $failures.Add("Governance Changelog must mention current version $($catalogFields['version']): $($catalogFields['path'])")
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

$featuresPath = Join-Path $repoRoot 'config/features.yaml'
$codexConfig = Join-Path $repoRoot '.codex/config.toml'
if ((Test-Path -LiteralPath $featuresPath) -and (Test-Path -LiteralPath $codexConfig)) {
    $featureText = Get-Content -Raw -LiteralPath $featuresPath
    $configText = Get-Content -Raw -LiteralPath $codexConfig

    $featureSectionMatch = [regex]::Match($featureText, '(?ms)^  openspace_local:\s*\r?\n(?<body>(?:    .*\r?\n?)*)')
    $serverSectionMatch = [regex]::Match($configText, '(?ms)^\[mcp_servers\.openspace\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
    if (-not $featureSectionMatch.Success) {
        $failures.Add('Feature openspace_local is missing from config/features.yaml')
    }
    if (-not $serverSectionMatch.Success) {
        $failures.Add('MCP server mcp_servers.openspace is missing from .codex/config.toml')
    }

    if ($featureSectionMatch.Success -and $serverSectionMatch.Success) {
        $featureEnabledMatch = [regex]::Match($featureSectionMatch.Groups['body'].Value, '(?m)^    enabled:\s*(true|false)\s*$')
        $serverEnabledMatch = [regex]::Match($serverSectionMatch.Groups['body'].Value, '(?m)^enabled\s*=\s*(true|false)\s*$')
        if (-not $featureEnabledMatch.Success) {
            $failures.Add('features.openspace_local.enabled must be explicitly true or false')
        }
        if (-not $serverEnabledMatch.Success) {
            $failures.Add('mcp_servers.openspace.enabled must be explicitly true or false')
        }
        if ($featureEnabledMatch.Success -and $serverEnabledMatch.Success) {
            $featureEnabled = $featureEnabledMatch.Groups[1].Value
            $serverEnabled = $serverEnabledMatch.Groups[1].Value
            if ($featureEnabled -ne $serverEnabled) {
                $failures.Add("OpenSpace activation mismatch: config/features.yaml is '$featureEnabled', .codex/config.toml is '$serverEnabled'")
            }
        }
    }

    if ($featureText -notmatch '(?m)^    cloud_mode:\s*off\s*$' -or
        $featureText -notmatch '(?m)^  allow_openspace_cloud:\s*false\s*$') {
        $failures.Add('OpenSpace cloud mode must remain off in config/features.yaml')
    }
    if ($configText -notmatch '(?m)^OPENSPACE_CLOUD_MODE\s*=\s*"off"\s*$' -or
        $configText -notmatch '(?m)^OPENSPACE_CLOUD_TELEMETRY_MODE\s*=\s*"off"\s*$') {
        $failures.Add('OpenSpace cloud mode and cloud telemetry must remain off in .codex/config.toml')
    }
    if ($configText -notmatch '(?m)^OPENSPACE_EVOLUTION_TRIGGERS_ENABLED\s*=\s*"false"\s*$') {
        $failures.Add('OpenSpace automatic evolution triggers must remain disabled')
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
