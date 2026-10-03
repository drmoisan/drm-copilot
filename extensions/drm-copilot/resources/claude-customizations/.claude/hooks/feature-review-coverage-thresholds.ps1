<#
.SYNOPSIS
    Resolve the coverage thresholds that govern the feature-review coverage validation.
.DESCRIPTION
    Implements the threshold precedence of the pushed quality-tiers rule for the
    feature-review SubagentStop hook (issue #824, follow-up FU-823-1). When the
    repository's root CLAUDE.md states a line or branch coverage threshold, that threshold
    governs; otherwise the default governs (85 percent line, 75 percent branch). Each
    metric is resolved on its own, so a root CLAUDE.md that states only a line threshold
    leaves the branch default in force.

    Pure string logic only: the caller supplies the CLAUDE.md text. No disk, process,
    network, clock, or environment access. It is dot-sourced by
    validate-feature-review-coverage.ps1 as:
    . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1')
#>

function Get-FeatureReviewCoverageThreshold {
    <#
    .SYNOPSIS
        Return the governing line and branch coverage thresholds for a root CLAUDE.md text.
    .DESCRIPTION
        For each metric M in 'line' and 'branch', the text is searched with
        '(?im)\bM\s+coverage\b[^\r\n%]*?(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%'. The first
        match whose value parses (invariant culture) to a number from 0 to 100 sets that
        metric and its source to 'claude-md'. Otherwise the metric keeps its default (line
        85, branch 75) and its source is 'default'.
    .PARAMETER ClaudeMdText
        The text of the repository's root CLAUDE.md; $null or empty when it is absent.
    .OUTPUTS
        System.Management.Automation.PSCustomObject - Line, Branch, LineSource, BranchSource.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowNull()][AllowEmptyString()][string] $ClaudeMdText
    )

    $defaults = [ordered]@{ line = 85.0; branch = 75.0 }
    $resolved = @{}
    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $style = [System.Globalization.NumberStyles]::Float

    foreach ($metric in $defaults.Keys) {
        $value = [double]$defaults[$metric]
        $source = 'default'
        if (-not [string]::IsNullOrEmpty($ClaudeMdText)) {
            $pattern = '(?im)\b' + $metric + '\s+coverage\b[^\r\n%]*?(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%'
            foreach ($match in [regex]::Matches($ClaudeMdText, $pattern)) {
                $parsed = 0.0
                $isNumber = [double]::TryParse($match.Groups['pct'].Value, $style, $culture, [ref]$parsed)
                if ($isNumber -and $parsed -ge 0 -and $parsed -le 100) {
                    $value = $parsed
                    $source = 'claude-md'
                    break
                }
            }
        }
        $resolved[$metric] = [pscustomobject]@{ Value = $value; Source = $source }
    }

    return [pscustomobject]@{
        Line         = $resolved['line'].Value
        Branch       = $resolved['branch'].Value
        LineSource   = $resolved['line'].Source
        BranchSource = $resolved['branch'].Source
    }
}
