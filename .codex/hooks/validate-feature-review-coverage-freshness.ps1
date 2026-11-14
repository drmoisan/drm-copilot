<#
.SYNOPSIS
    Codex twin of the feature-review coverage freshness functions (issue #1114).

.DESCRIPTION
    Source: .claude/hooks/validate-feature-review-coverage-freshness.ps1 (issue #1105). This file
    carries the four functions of that file with byte-identical function text, because Codex hooks
    cannot dot-source .claude paths: a consumer repository receives the .codex runtime without the
    Claude hooks. tests/scripts/codex-hooks/validate-feature-review-coverage-freshness.Tests.ps1
    holds the function names and each function's text equal to the Claude file and runs the
    freshness rows against this file.

    Functions-only: the file has no entry point and no statement outside the function definitions.
    It is dot-sourced by .codex/hooks/validate-feature-review-coverage.ps1, which passes the
    Invoke-CodexReviewCoverageGitLog wrapper of feature-review-coverage-target.ps1 as -GitInvoker,
    so the default GitInvoker below does not run in the hook. Edit the Claude file first, then copy
    the changed function text here.

.NOTES
    Compatible with PowerShell 7+. Holds no script-scope state and invokes no Python. Mirrored
    byte-identically under extensions/drm-copilot/resources/codex-and-agents-customizations/.
#>

function Get-FeatureReviewCoverageReportPath {
    # Returns the repository-relative coverage report path for a language, or $null.
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Language)

    switch ($Language) {
        'TypeScript' { return 'coverage/lcov.info' }
        'Python' { return 'artifacts/python/lcov.info' }
        'PowerShell' { return 'artifacts/pester/powershell-coverage.xml' }
        'CSharp' { return 'artifacts/csharp/coverage.xml' }
    }
    return $null
}

function Get-FeatureReviewCoveragePathspec {
    # Returns the git pathspecs whose newest commit is the freshness reference for a language.
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string] $Language)

    switch ($Language) {
        'TypeScript' { return [string[]]@('*.ts', '*.tsx') }
        'Python' { return [string[]]@('*.py') }
        'PowerShell' { return [string[]]@('*.ps1', '*.psm1', '*.psd1') }
        'CSharp' { return [string[]]@('*.cs') }
    }
    return [string[]]@()
}

function Get-FeatureReviewReportLastWriteUtc {
    <#
    .SYNOPSIS
        Returns the UTC last-write time of a file, or $null when it is absent. Tests mock this seam.
    .PARAMETER Path
        The absolute path beneath the resolved item worktree.
    #>
    [CmdletBinding()]
    [OutputType([Nullable[datetime]])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return (Get-Item -LiteralPath $Path -ErrorAction Stop).LastWriteTimeUtc
}

function Get-FeatureReviewCoverageFreshnessDecision {
    <#
    .SYNOPSIS
        Decides whether the item worktree's coverage inputs are present and fresh.
    .DESCRIPTION
        Returns $null when no finding applies: the source is SessionRoot, the root is blank, or the
        root equals the session root (no probe runs), or every input is present and fresh.
        Otherwise returns a hashtable with Reasons (one string per finding), HasRepairable, and
        HasNonRepairable. An absent PR context summary, an absent report, and a stale report are
        repairable; a git failure (a non-zero exit, empty output, or non-integer output) is a
        fail-closed finding the subagent cannot repair.
    .PARAMETER WorktreeRoot
        The resolved item worktree root.
    .PARAMETER SessionRoot
        The hook's session root.
    .PARAMETER Source
        The resolver source of the root.
    .PARAMETER ChangedLanguage
        The changed-language set read from the item's PR context summary (keys are language names).
    .PARAMETER GitInvoker
        { param($Root, $Pathspec) [pscustomobject]@{ ExitCode; Output } }; the default runs
        git log -1 --format=%ct HEAD -- <pathspecs> in the root.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $WorktreeRoot,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [AllowNull()] [AllowEmptyString()] [string] $Source,
        [AllowNull()] [System.Collections.IDictionary] $ChangedLanguage,
        [scriptblock] $GitInvoker = { param([string] $Root, [string[]] $Pathspec) $output = & git -C $Root log -1 '--format=%ct' HEAD -- @Pathspec 2>$null; [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = (@($output) -join "`n") } }
    )

    $root = ($WorktreeRoot -replace '\\', '/').TrimEnd('/')
    $session = ($SessionRoot -replace '\\', '/').TrimEnd('/')
    if ($Source -eq 'SessionRoot' -or [string]::IsNullOrWhiteSpace($root) -or [string]::Equals($root, $session, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    $reasons = [System.Collections.Generic.List[string]]::new()
    $hasNonRepairable = $false
    $summaryPath = 'artifacts/pr_context.summary.txt'
    if ($null -eq (Get-FeatureReviewReportLastWriteUtc -Path "$root/$summaryPath")) {
        $reasons.Add("the PR context summary '$summaryPath' is absent beneath the item worktree '$root'; generate it in the item worktree so the changed languages can be read.")
    }

    $languages = if ($null -eq $ChangedLanguage) { @() } else { @($ChangedLanguage.Keys) }
    foreach ($language in $languages) {
        $reportPath = Get-FeatureReviewCoverageReportPath -Language $language
        if ($null -eq $reportPath) { continue }
        $reportTime = Get-FeatureReviewReportLastWriteUtc -Path "$root/$reportPath"
        if ($null -eq $reportTime) {
            $reasons.Add("$language has changed files but its coverage report '$reportPath' is absent beneath the item worktree '$root'; run the $language coverage gate in the item worktree.")
            continue
        }
        $gitResult = $null
        try { $gitResult = & $GitInvoker $root (Get-FeatureReviewCoveragePathspec -Language $language) } catch { $gitResult = $null }
        $outputText = if ($null -eq $gitResult) { '' } else { ([string]$gitResult.Output).Trim() }
        $seconds = 0L
        if ($null -eq $gitResult -or $gitResult.ExitCode -ne 0 -or [string]::IsNullOrEmpty($outputText) -or -not [long]::TryParse($outputText, [ref]$seconds)) {
            $exitText = if ($null -eq $gitResult) { 'none' } else { [string]$gitResult.ExitCode }
            $reasons.Add("$language coverage freshness cannot be decided: the git query for the newest commit touching $language files in '$root' failed (exit code $exitText, output '$outputText'); the gate fails closed.")
            $hasNonRepairable = $true
            continue
        }
        $referenceTime = [DateTimeOffset]::FromUnixTimeSeconds($seconds).UtcDateTime
        if ($reportTime -lt $referenceTime) {
            $format = 'yyyy-MM-ddTHH:mm:ssZ'
            $culture = [System.Globalization.CultureInfo]::InvariantCulture
            $reasons.Add("$language coverage report '$reportPath' in '$root' is stale: it was written at $($reportTime.ToString($format, $culture)), before the newest commit touching $language files at $($referenceTime.ToString($format, $culture)); re-run the $language coverage gate in the item worktree.")
        }
    }

    if ($reasons.Count -eq 0) { return $null }
    $repairableCount = $reasons.Count - @($reasons | Where-Object { $_.Contains('the gate fails closed') }).Count
    return @{ Reasons = [string[]]$reasons.ToArray(); HasRepairable = ($repairableCount -gt 0); HasNonRepairable = $hasNonRepairable }
}
