[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [Parameter(Mandatory = $true)]
    [string]$ChangeName,
    [Parameter(Mandatory = $true)]
    [string]$OutcomePath
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

if (-not [IO.Path]::IsPathRooted($ProjectPath)) {
    $ProjectPath = Join-Path $repoRoot $ProjectPath
}
if (-not [IO.Path]::IsPathRooted($OutcomePath)) {
    $OutcomePath = Join-Path $repoRoot $OutcomePath
}

$changePath = Join-Path $ProjectPath "openspec/changes/$ChangeName"
if (-not (Test-Path -LiteralPath $changePath)) {
    Write-Error "Change folder is missing: $changePath"
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutcomePath | Out-Null

$specFiles = @(Get-ChildItem -LiteralPath (Join-Path $changePath 'specs') -Filter 'spec.md' -File -Recurse -ErrorAction SilentlyContinue)
if ($specFiles.Count -eq 0) {
    Write-Error "No delta specs found in $changePath"
    exit 1
}

function Get-OpenSpecRequirements {
    param([string]$Text)
    $requirements = [System.Collections.Generic.List[object]]::new()
    $blocks = [regex]::Matches($Text, '(?ms)^###\s+Requirement:\s*(?<id>(?:AC|NFR)-[0-9]{3,})\s+(?<title>.+?)\r?\n(?<body>.*?)(?=^###\s+Requirement:|\z)')
    foreach ($block in $blocks) {
        $body = $block.Groups['body'].Value.Trim()
        $statementMatch = [regex]::Match($body, '(?m)^The system (?:SHALL|MUST)\s+.+$')
        $statement = if ($statementMatch.Success) { $statementMatch.Value.Trim() } else { ($body -split "`r?`n")[0].Trim() }
        $scenarios = [regex]::Matches($body, '(?ms)^####\s+Scenario:\s*(?<name>.+?)\r?\n(?<scene>.*?)(?=^####\s+Scenario:|\z)')
        $scenarioList = @()
        foreach ($scenario in $scenarios) {
            $scenarioList += [pscustomobject]@{
                name = $scenario.Groups['name'].Value.Trim()
                body = $scenario.Groups['scene'].Value.Trim()
            }
        }
        $requirements.Add([pscustomobject]@{
            id = $block.Groups['id'].Value
            title = $block.Groups['title'].Value.Trim()
            statement = $statement
            scenarios = $scenarioList
        })
    }
    return $requirements
}

$allRequirements = [System.Collections.Generic.List[object]]::new()
foreach ($specFile in $specFiles) {
    $text = Get-Content -Raw -LiteralPath $specFile.FullName
    foreach ($item in (Get-OpenSpecRequirements -Text $text)) {
        $allRequirements.Add($item)
    }
}

if ($allRequirements.Count -eq 0) {
    Write-Error "No AC/NFR requirements could be mapped from $changePath"
    exit 1
}

$relativeChange = [IO.Path]::GetRelativePath($repoRoot, $changePath).Replace('\', '/')
$specLines = @(
    '# Спецификации поведения',
    '',
    'Сценарии перенесены из утверждённого OpenSpec change. Для gates источником истины остаётся pack.json.',
    '',
    "- Идентификатор change: $ChangeName",
    "- Путь change: $relativeChange",
    ''
)

$traceLines = @(
    '# Трассировка OpenSpec → Pack',
    '',
    "- Идентификатор change: $ChangeName",
    "- Путь change: $relativeChange",
    '- Статус change: approved',
    '',
    '## Соответствие требований',
    '',
    '| OpenSpec | Pack | Примечание |',
    '| --- | --- | --- |'
)

$packJsonPath = Join-Path $OutcomePath 'pack.json'
$packIds = @()
if (Test-Path -LiteralPath $packJsonPath) {
    $pack = Get-Content -Raw -LiteralPath $packJsonPath | ConvertFrom-Json -Depth 50
    $packIds = @($pack.acceptance_criteria.id) + @($pack.nfrs.id)
}

foreach ($requirement in $allRequirements) {
    $specLines += "## $($requirement.id) $($requirement.title)"
    $specLines += ''
    $specLines += $requirement.statement
    $specLines += ''
    foreach ($scenario in $requirement.scenarios) {
        $specLines += "### Сценарий: $($scenario.name)"
        $specLines += ''
        $specLines += $scenario.body
        $specLines += ''
    }

    $note = 'Перенесено в спецификации Outcome'
    if ($packIds.Count -gt 0) {
        if ($packIds -contains $requirement.id) {
            $note = 'Идентификатор совпадает с Pack'
        } else {
            $note = 'Идентификатор отсутствует в pack.json'
            $failures.Add("Mapped requirement '$($requirement.id)' is not present in $packJsonPath")
        }
    }
    $traceLines += "| $($requirement.id) | $($requirement.id) | $note |"
}

$specificationsPath = Join-Path $OutcomePath 'specifications.md'
$traceabilityPath = Join-Path $OutcomePath 'openspec-traceability.md'
Set-Content -LiteralPath $specificationsPath -Value ($specLines -join [Environment]::NewLine) -Encoding utf8
Set-Content -LiteralPath $traceabilityPath -Value ($traceLines -join [Environment]::NewLine) -Encoding utf8

if ($failures.Count -gt 0) {
    Write-Error ($failures -join [Environment]::NewLine)
    exit 1
}

Write-Host "Wrote $specificationsPath"
Write-Host "Wrote $traceabilityPath"
Write-Host ("Mapped requirement ids: " + (($allRequirements.id | Select-Object -Unique) -join ', '))
