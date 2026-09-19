[CmdletBinding()]
param([string]$Path)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$allowedResults = @('pass', 'fail', 'partial', 'not-run')
$allowedBundleStatuses = @('draft', 'complete', 'accepted', 'rejected')

function Get-MarkdownSection {
    param([string]$Text, [string]$Heading)
    $match = [regex]::Match($Text, "(?ms)^##\s+$([regex]::Escape($Heading))\s*\r?\n(?<body>.*?)(?=^##\s+|\z)")
    if ($match.Success) { return $match.Groups['body'].Value }
    return $null
}

function Get-BulletField {
    param([AllowNull()][string]$Text, [string]$Label)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    $match = [regex]::Match($Text, "(?im)^\s*-\s*$([regex]::Escape($Label))\s*:\s*(?<value>.+?)\s*$")
    if ($match.Success) { return $match.Groups['value'].Value.Trim().Trim('`') }
    return $null
}

function Get-BulletFieldAny {
    param([AllowNull()][string]$Text, [string[]]$Labels)
    foreach ($label in $Labels) {
        $value = Get-BulletField -Text $Text -Label $label
        if ($value) { return $value }
    }
    return $null
}

function Convert-TableRow {
    param([string]$Line)
    return @(($Line.Trim().Trim('|') -split '\|') | ForEach-Object { $_.Trim().Trim('`') })
}

function Test-Placeholder {
    param([AllowNull()][string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $true }
    return $Value.Trim() -match '(?i)^(TBD|TODO|N/A|none|-|<[^>]+>|\.\.\.)$'
}

function Test-ImmutableLink {
    param([string]$Link, [bool]$IsExample)
    if (Test-Placeholder -Value $Link) { return $false }
    if ($Link -match '(?i)(/branches?/(main|master)|/tree/(main|master)|/blob/(main|master)|\blatest\b|\bHEAD\b)') { return $false }
    if ($IsExample -and $Link -match '^demo://') { return $true }
    if ($Link -match '^urn:sha256:[0-9a-fA-F]{64}$') { return $true }
    if ($Link -match '^https://.+(commit/[0-9a-fA-F]{7,40}|actions/runs/[0-9]+|artifacts/[0-9]+|[?&](version|sha|digest)=[^&#]+|#[sS][hH][aA]256=[0-9a-fA-F]{64})') { return $true }
    return $false
}

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

    try {
        $pack = Get-Content -Raw -LiteralPath $packPath | ConvertFrom-Json -Depth 50
    } catch {
        $failures.Add("Invalid pack.json next to evidence: ${packPath}: $($_.Exception.Message)")
        continue
    }

    $isExample = $evidenceFile.FullName -match '[\\/]workspaces[\\/]examples[\\/]'
    $outcomeId = Get-BulletFieldAny -Text $text -Labels @('Идентификатор результата', 'Outcome ID')
    $packVersion = Get-BulletFieldAny -Text $text -Labels @('Версия Pack', 'Pack version')
    $packSha = Get-BulletFieldAny -Text $text -Labels @('SHA коммита Pack', 'Pack commit SHA')
    $risk = Get-BulletFieldAny -Text $text -Labels @('Риск', 'Risk')
    $evidenceOwner = Get-BulletFieldAny -Text $text -Labels @('Владелец доказательств', 'Evidence owner')
    $bundleStatusValue = Get-BulletFieldAny -Text $text -Labels @('Статус', 'Status')
    $bundleStatus = if ($bundleStatusValue) { $bundleStatusValue.ToLowerInvariant() } else { '' }

    foreach ($check in @(
        @{ Label = 'Outcome ID'; Actual = $outcomeId; Expected = [string]$pack.outcome_id },
        @{ Label = 'Pack version'; Actual = $packVersion; Expected = [string]$pack.version },
        @{ Label = 'Risk'; Actual = $risk; Expected = [string]$pack.risk_level }
    )) {
        if ($check.Actual -ne $check.Expected) {
            $failures.Add("Evidence field '$($check.Label)' must equal '$($check.Expected)', got '$($check.Actual)': $($evidenceFile.FullName)")
        }
    }
    if (Test-Placeholder -Value $evidenceOwner) {
        $failures.Add("Evidence owner is missing or a placeholder: $($evidenceFile.FullName)")
    }
    if ($bundleStatus -notin $allowedBundleStatuses) {
        $failures.Add("Evidence Status '$bundleStatus' is invalid; allowed: $($allowedBundleStatuses -join ', '): $($evidenceFile.FullName)")
    }
    if ($packSha -notmatch '^[0-9a-fA-F]{40}$') {
        $failures.Add("Pack commit SHA must be a full 40-character Git SHA: $($evidenceFile.FullName)")
    } elseif (-not $isExample) {
        & git -C $repoRoot cat-file -e "$packSha`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            $failures.Add("Pack commit SHA does not resolve in this repository: $packSha ($($evidenceFile.FullName))")
        } else {
            $relativePackPath = [System.IO.Path]::GetRelativePath($repoRoot, $packPath).Replace('\', '/')
            $baselineJson = (& git -C $repoRoot show "${packSha}:$relativePackPath" 2>$null) -join [Environment]::NewLine
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($baselineJson)) {
                $failures.Add("Pack commit SHA does not contain '$relativePackPath': $packSha ($($evidenceFile.FullName))")
            } else {
                try {
                    $baselinePack = $baselineJson | ConvertFrom-Json -Depth 50
                    if ($baselinePack.outcome_id -ne $outcomeId -or $baselinePack.version -ne $packVersion) {
                        $failures.Add("Pack commit SHA resolves to a different Outcome ID or Pack version: $packSha ($($evidenceFile.FullName))")
                    }
                } catch {
                    $failures.Add("Pack commit SHA contains invalid pack.json: $packSha ($($evidenceFile.FullName))")
                }
            }
        }
    }

    $index = Get-MarkdownSection -Text $text -Heading 'Реестр доказательств'
    if ([string]::IsNullOrWhiteSpace($index)) {
        $index = Get-MarkdownSection -Text $text -Heading 'Evidence index'
    }
    $tableLines = @($index -split '\r?\n' | Where-Object { $_.Trim().StartsWith('|') })
    if ($tableLines.Count -lt 3) {
        $failures.Add("Evidence index must contain a header and at least one evidence row: $($evidenceFile.FullName)")
        continue
    }

    $headers = Convert-TableRow -Line $tableLines[0]
    $requiredColumns = @(
        @{ Key = 'Evidence ID'; Labels = @('ID доказательства', 'Evidence ID') },
        @{ Key = 'Requirement'; Labels = @('Требование', 'Requirement') },
        @{ Key = 'Method'; Labels = @('Метод', 'Method') },
        @{ Key = 'Result'; Labels = @('Результат', 'Result') },
        @{ Key = 'Immutable link'; Labels = @('Неизменяемая ссылка', 'Immutable link') },
        @{ Key = 'Environment'; Labels = @('Среда', 'Environment') },
        @{ Key = 'Executed at'; Labels = @('Время выполнения', 'Executed at') },
        @{ Key = 'Producer'; Labels = @('Автор', 'Producer') },
        @{ Key = 'Limitations'; Labels = @('Ограничения', 'Limitations') }
    )
    $columnIndex = @{}
    foreach ($column in $requiredColumns) {
        $indexOf = -1
        foreach ($label in $column.Labels) {
            $candidateIndex = [array]::IndexOf($headers, $label)
            if ($candidateIndex -ge 0) {
                $indexOf = $candidateIndex
                break
            }
        }
        if ($indexOf -lt 0) {
            $failures.Add("В реестре доказательств отсутствует столбец '$($column.Labels[0])': $($evidenceFile.FullName)")
        } else {
            $columnIndex[$column.Key] = $indexOf
        }
    }
    if ($columnIndex.Count -ne $requiredColumns.Count) { continue }

    $requirements = @($pack.acceptance_criteria.id) + @($pack.nfrs.id)
    $knownRequirements = @{}
    foreach ($id in $requirements) { $knownRequirements[[string]$id] = $true }
    $evidenceIds = @{}
    $resultsByRequirement = @{}
    $nonPassRequirements = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($line in $tableLines[2..($tableLines.Count - 1)]) {
        $cells = Convert-TableRow -Line $line
        if ($cells.Count -ne $headers.Count) {
            $failures.Add("Evidence row has $($cells.Count) cells but header has $($headers.Count): $line")
            continue
        }
        $evidenceId = $cells[$columnIndex['Evidence ID']]
        $requirementId = $cells[$columnIndex['Requirement']]
        $method = $cells[$columnIndex['Method']]
        $resultCell = $cells[$columnIndex['Result']]
        $result = (($resultCell -split '[,;:\s]')[0]).ToLowerInvariant()
        $link = $cells[$columnIndex['Immutable link']]
        $environment = $cells[$columnIndex['Environment']]
        $executedAt = $cells[$columnIndex['Executed at']]
        $producer = $cells[$columnIndex['Producer']]
        $limitations = $cells[$columnIndex['Limitations']]

        if ($evidenceId -notmatch '^EVD-[0-9]{3,}$') {
            $failures.Add("Invalid Evidence ID '$evidenceId': $($evidenceFile.FullName)")
        } elseif ($evidenceIds.ContainsKey($evidenceId)) {
            $failures.Add("Duplicate Evidence ID '$evidenceId': $($evidenceFile.FullName)")
        } else { $evidenceIds[$evidenceId] = $true }

        if (-not $knownRequirements.ContainsKey($requirementId)) {
            $failures.Add("Evidence '$evidenceId' references unknown requirement '$requirementId': $($evidenceFile.FullName)")
        }
        if (Test-Placeholder -Value $method) { $failures.Add("Evidence '$evidenceId' has no verification method: $($evidenceFile.FullName)") }
        if ($result -notin $allowedResults) {
            $failures.Add("Evidence '$evidenceId' has invalid result '$resultCell'; allowed: $($allowedResults -join ', '): $($evidenceFile.FullName)")
        }
        if (-not (Test-ImmutableLink -Link $link -IsExample $isExample)) {
            $failures.Add("Evidence '$evidenceId' does not use a verifiably immutable link: '$link': $($evidenceFile.FullName)")
        }
        if (Test-Placeholder -Value $environment) { $failures.Add("Evidence '$evidenceId' has no environment: $($evidenceFile.FullName)") }
        $parsedDate = [DateTimeOffset]::MinValue
        if ($executedAt -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$' -or -not [DateTimeOffset]::TryParse($executedAt, [ref]$parsedDate)) {
            $failures.Add("Evidence '$evidenceId' has invalid execution time '$executedAt'; use ISO 8601: $($evidenceFile.FullName)")
        }
        if (Test-Placeholder -Value $producer) { $failures.Add("Evidence '$evidenceId' has no producer: $($evidenceFile.FullName)") }
        if (Test-Placeholder -Value $limitations) { $failures.Add("Evidence '$evidenceId' has no explicit limitations: $($evidenceFile.FullName)") }

        if (-not $resultsByRequirement.ContainsKey($requirementId)) { $resultsByRequirement[$requirementId] = @() }
        $resultsByRequirement[$requirementId] += $result
        if ($result -ne 'pass') { [void]$nonPassRequirements.Add($requirementId) }
    }

    $coverageGaps = Get-MarkdownSection -Text $text -Heading 'Пробелы покрытия'
    if ([string]::IsNullOrWhiteSpace($coverageGaps)) {
        $coverageGaps = Get-MarkdownSection -Text $text -Heading 'Coverage gaps'
    }
    if (Test-Placeholder -Value $coverageGaps) {
        $failures.Add("Coverage gaps must explicitly state gaps or their absence: $($evidenceFile.FullName)")
    }
    foreach ($requirementId in $requirements) {
        if (-not $resultsByRequirement.ContainsKey([string]$requirementId)) {
            $failures.Add("No evidence row covers requirement '$requirementId': $($evidenceFile.FullName)")
        } elseif ($bundleStatus -in @('complete', 'accepted') -and 'pass' -notin $resultsByRequirement[[string]$requirementId]) {
            $failures.Add("Complete Evidence Bundle has no passing evidence for '$requirementId': $($evidenceFile.FullName)")
        }
    }
    foreach ($requirementId in $nonPassRequirements) {
        if ($coverageGaps -notmatch [regex]::Escape($requirementId)) {
            $failures.Add("Non-pass requirement '$requirementId' is not documented in Coverage gaps: $($evidenceFile.FullName)")
        }
    }

    $review = Get-MarkdownSection -Text $text -Heading 'Независимая проверка'
    if ([string]::IsNullOrWhiteSpace($review)) {
        $review = Get-MarkdownSection -Text $text -Heading 'Independent review'
    }
    if (Test-Placeholder -Value (Get-BulletFieldAny -Text $review -Labels @('Остаточный риск', 'Residual risk'))) {
        $failures.Add("Independent review must state Residual risk: $($evidenceFile.FullName)")
    }
    if ($pack.risk_level -in @('R2', 'R3')) {
        foreach ($field in @(
            @{ Labels = @('Проверяющий', 'Reviewer') },
            @{ Labels = @('Область проверки', 'Scope') },
            @{ Labels = @('Решение', 'Decision') }
        )) {
            if (Test-Placeholder -Value (Get-BulletFieldAny -Text $review -Labels $field.Labels)) {
                $failures.Add("Risk $($pack.risk_level) requires Independent review field '$($field.Labels[0])': $($evidenceFile.FullName)")
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Validated $($evidenceFiles.Count) Evidence Bundle(s): Pack baseline, coverage, result statuses, immutable links, execution context and residual risk are valid."
