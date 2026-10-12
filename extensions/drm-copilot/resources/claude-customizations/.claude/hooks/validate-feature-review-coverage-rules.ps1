<#
.SYNOPSIS
    Artifact-path rules, changed-language set, and coverage-row rule for the feature-review coverage hook.

.DESCRIPTION
    Dot-sourced by validate-feature-review-coverage.ps1. Defines the advertised-path reader
    (Get-ReviewArtifactPathFromOutput), the active-feature location rule (Get-ReviewArtifactInfo),
    the changed-language reader for the PR context summary (Get-ChangedLanguageSet), and the
    per-language coverage-row rule (Test-LanguageCoverageRow).

    The file has no param() block, writes nothing to the output stream, and runs no top-level
    statement other than function definitions.

.NOTES
    Requires PowerShell 7+.
#>

function Get-ReviewArtifactPathFromOutput {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $AgentOutput,

        [Parameter(Mandatory = $true)]
        [string] $Token
    )

    $escapedToken = [regex]::Escape($Token)
    $pattern = "$escapedToken\s*[:=]\s*[""']?([^\s""'\)`]+)|\[$escapedToken\]\(([^)]+)\)"
    $match = [regex]::Match(
        $AgentOutput,
        $pattern,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if (-not $match.Success) {
        return $null
    }

    $value = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
    $value = $value.Trim()
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }

    return $value
}

function Get-ReviewArtifactInfo {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Stem
    )

    $normalized = $Path -replace '\\', '/'
    $pattern = "^docs/features/active/(?<Folder>.+)/$Stem\.(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}-\d{2})\.md$"
    $match = [regex]::Match($normalized, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) {
        return $null
    }

    return @{
        Folder    = $match.Groups['Folder'].Value
        Timestamp = $match.Groups['Timestamp'].Value
        Path      = $normalized
    }
}

function Get-ChangedLanguageSet {
    [OutputType([System.Collections.Hashtable])]
    param([string[]]$Lines)

    $langs = [ordered]@{}
    foreach ($line in $Lines) {
        if ($line -notmatch '^\s*-\s+(\S+)\s+\(\+\d+/-\d+\)\s*$') { continue }
        $path = $matches[1]
        $ext = [IO.Path]::GetExtension($path).ToLowerInvariant()
        switch -Regex ($ext) {
            '^\.(ts|tsx)$' { $langs['TypeScript'] = $true }
            '^\.py$' { $langs['Python'] = $true }
            '^\.(ps1|psm1)$' { $langs['PowerShell'] = $true }
            '^\.cs$' { $langs['CSharp'] = $true }
        }
    }
    return $langs
}

function Test-LanguageCoverageRow {
    [OutputType([System.Collections.Hashtable])]
    param(
        [string]$AuditText,
        [string]$Language,
        [Nullable[double]]$RepoWidePct,
        [Nullable[double]]$BranchPct,
        [double]$LineFloor = 85.0,
        [double]$BranchFloor = 75.0,
        [string] $LineSource = 'default',
        [string] $BranchSource = 'default'
    )

    $lineSourceLabel = if ($LineSource -eq 'claude-md') { '(root CLAUDE.md)' } else { '(default)' }
    $branchSourceLabel = if ($BranchSource -eq 'claude-md') { '(root CLAUDE.md)' } else { '(default)' }

    $languageLabelMap = @{
        'TypeScript' = @('TypeScript', 'typescript')
        'Python'     = @('Python', 'python', 'pytest')
        'PowerShell' = @('PowerShell', 'powershell', 'pester')
        'CSharp'     = @('C#', 'CSharp', 'csharp', '.NET', 'dotnet')
    }

    $labels = $languageLabelMap[$Language]
    $labelPattern = '(?i)(' + (($labels | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')'

    $lines = $AuditText -split "`r?`n"
    $languageLines = $lines | Where-Object { $_ -match $labelPattern }

    if (-not $languageLines -or $languageLines.Count -eq 0) {
        return @{
            Ok     = $false
            Reason = "$Language has changed files on the branch but the policy-audit does not mention $Language."
        }
    }

    $coverageLines = $languageLines | Where-Object { $_ -match '(?i)(coverage|lcov|line[s]?\s+hit|pester)' }
    if (-not $coverageLines -or $coverageLines.Count -eq 0) {
        return @{
            Ok     = $false
            Reason = "$Language has changed files on the branch but no coverage-scoped row in the policy-audit mentions $Language."
        }
    }

    $narrowingPattern = '(?i)(informational only|context only|out of plan scope|out of scope|not applicable|\bN/A\b|\bUNVERIFIED\b)'
    $narrowing = $coverageLines | Where-Object { $_ -match $narrowingPattern }
    if ($narrowing -and $narrowing.Count -gt 0) {
        $first = ($narrowing | Select-Object -First 1).ToString().Trim()
        return @{
            Ok     = $false
            Reason = "$Language has changed files on the branch but a coverage-scoped row narrows scope: '$first'. Scope narrowing is not permitted for languages with changed files."
        }
    }

    $verdictLines = $coverageLines | Where-Object { $_ -match '\b(PASS|FAIL)\b' }
    if (-not $verdictLines -or $verdictLines.Count -eq 0) {
        return @{
            Ok     = $false
            Reason = "$Language coverage rows contain neither a PASS nor a FAIL verdict."
        }
    }

    if ($null -ne $RepoWidePct -and $RepoWidePct -lt $LineFloor) {
        $failLines = $coverageLines | Where-Object { $_ -match '\bFAIL\b' }
        if (-not $failLines -or $failLines.Count -eq 0) {
            return @{
                Ok     = $false
                Reason = ("{0} repo-wide coverage is {1}% (below the {2}% line coverage floor {3}) but the policy-audit contains no FAIL verdict on a coverage row for {0}." -f $Language, $RepoWidePct, $LineFloor, $lineSourceLabel)
            }
        }
    }

    if ($null -ne $BranchPct -and $BranchPct -lt $BranchFloor) {
        return @{
            Ok     = $false
            Reason = ("{0} branch coverage is {1}% (below the {2}% branch coverage floor {3}); policy-audit must record FAIL on the corresponding coverage row." -f $Language, $BranchPct, $BranchFloor, $branchSourceLabel)
        }
    }

    return @{ Ok = $true; Reason = $null }
}
