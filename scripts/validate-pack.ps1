[CmdletBinding()]
param([string]$Path)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$schemaPath = Join-Path $repoRoot 'schemas/pack.schema.json'
$failures = [System.Collections.Generic.List[string]]::new()

function Get-MarkdownSection {
    param([string]$Text, [string]$Heading)
    $match = [regex]::Match($Text, "(?ms)^##\s+$([regex]::Escape($Heading))\s*\r?\n(?<body>.*?)(?=^##\s+|\z)")
    if ($match.Success) { return $match.Groups['body'].Value }
    return $null
}

function Get-BulletField {
    param([string]$Text, [string]$Label)
    $match = [regex]::Match($Text, "(?im)^\s*-\s*$([regex]::Escape($Label))\s*:\s*(?<value>.+?)\s*$")
    if ($match.Success) { return $match.Groups['value'].Value.Trim() }
    return $null
}

function Test-ContainsLiteral {
    param([AllowNull()][string]$Text, [string]$Value)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
    return $Text -match "(?i)$([regex]::Escape($Value.Trim()))"
}

function Test-Placeholder {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $true }
    return $Value -match '(?i)(^|\b)(TBD|TODO|OUT-000|RM-000|example\.invalid)(\b|$)|<[^>]+>|\.\.\.'
}

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
    $packFiles = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'workspaces') -Filter 'pack.json' -File -Recurse)
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
    $control = Get-MarkdownSection -Text $markdown -Heading 'Control'
    if ([string]::IsNullOrWhiteSpace($control)) {
        $failures.Add("pack.md is missing the Control section: $markdownPath")
        continue
    }

    $controlChecks = [ordered]@{
        'Outcome ID' = [string]$pack.outcome_id
        'Pack type' = [string]$pack.pack_type
        'Version' = [string]$pack.version
        'Outcome state' = [string]$pack.outcome_state
        'Pack status' = [string]$pack.pack_status
    }
    foreach ($entry in $controlChecks.GetEnumerator()) {
        $actual = Get-BulletField -Text $control -Label $entry.Key
        if (-not (Test-ContainsLiteral -Text $actual -Value $entry.Value)) {
            $failures.Add("pack.md Control field '$($entry.Key)' does not match pack.json value '$($entry.Value)': $markdownPath")
        }
    }

    $riskAutonomy = Get-BulletField -Text $control -Label 'Risk / autonomy'
    if (-not $riskAutonomy) {
        $riskAutonomy = "$(Get-BulletField -Text $control -Label 'Risk') / $(Get-BulletField -Text $control -Label 'Autonomy')"
    }
    foreach ($expected in @([string]$pack.risk_level, [string]$pack.autonomy_level)) {
        if (-not (Test-ContainsLiteral -Text $riskAutonomy -Value $expected)) {
            $failures.Add("pack.md risk/autonomy does not contain '$expected': $markdownPath")
        }
    }

    foreach ($owner in @(
        @{ Label = 'Outcome Owner'; Value = [string]$pack.owners.outcome_owner },
        @{ Label = 'PDE Owner'; Value = [string]$pack.owners.pde_owner },
        @{ Label = 'Risk Owner'; Value = [string]$pack.owners.risk_owner }
    )) {
        $actual = Get-BulletField -Text $control -Label $owner.Label
        if (-not (Test-ContainsLiteral -Text $actual -Value $owner.Value)) {
            $failures.Add("pack.md Control field '$($owner.Label)' does not match pack.json value '$($owner.Value)': $markdownPath")
        }
    }

    $redmine = Get-BulletField -Text $control -Label 'Redmine'
    foreach ($expected in @([string]$pack.redmine.issue_id, [string]$pack.redmine.url)) {
        if (-not (Test-ContainsLiteral -Text $redmine -Value $expected)) {
            $failures.Add("pack.md Redmine field does not contain '$expected': $markdownPath")
        }
    }

    $semanticValues = @(
        [string]$pack.problem.summary
        [string]$pack.outcome.statement
        @($pack.scope.in)
        @($pack.scope.out)
        [string]$pack.measurement.metric
        [string]$pack.measurement.baseline
        [string]$pack.measurement.target
        [string]$pack.measurement.source
        [string]$pack.measurement.validation_window
        [string]$pack.measurement.decision_rule
        @($pack.release.rollout)
        @($pack.release.stop_conditions)
        @($pack.release.rollback)
    )
    foreach ($value in $semanticValues) {
        if (-not [string]::IsNullOrWhiteSpace([string]$value) -and -not (Test-ContainsLiteral -Text $markdown -Value ([string]$value))) {
            $failures.Add("pack.md does not contain the pack.json value '$value': $markdownPath")
        }
    }

    $requirements = @($pack.acceptance_criteria) + @($pack.nfrs)
    $duplicates = @($requirements.id) | Group-Object | Where-Object Count -gt 1
    foreach ($duplicate in $duplicates) {
        $failures.Add("Duplicate requirement id '$($duplicate.Name)': $($packFile.FullName)")
    }
    foreach ($requirement in $requirements) {
        foreach ($expected in @([string]$requirement.id, [string]$requirement.statement)) {
            if (-not (Test-ContainsLiteral -Text $markdown -Value $expected)) {
                $failures.Add("pack.md does not contain requirement value '$expected': $markdownPath")
            }
        }
    }

    if ($pack.risk_level -in @('R2', 'R3') -and $pack.pack_type -ne 'full') {
        $failures.Add("Risk $($pack.risk_level) requires pack_type 'full': $($packFile.FullName)")
    }

    $isExample = $packFile.FullName -match '[\\/]workspaces[\\/]examples[\\/]'
    if (-not $isExample) {
        foreach ($value in @(
            [string]$pack.outcome_id,
            [string]$pack.owners.outcome_owner,
            [string]$pack.owners.pde_owner,
            [string]$pack.owners.risk_owner,
            [string]$pack.redmine.issue_id,
            [string]$pack.redmine.url
        )) {
            if (Test-Placeholder -Value $value) {
                $failures.Add("Operational Pack contains a placeholder value '$value': $($packFile.FullName)")
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Validated $($packFiles.Count) Pack control record(s): schema, metadata, owners, scope, requirements, measurement, Redmine, rollout and rollback are consistent."
