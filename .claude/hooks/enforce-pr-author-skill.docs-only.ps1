<#
.SYNOPSIS
    Docs-only exemption from the checkpoint preflight of enforce-pr-author-skill.ps1 (issue #901).

.DESCRIPTION
    Dot-sourced by enforce-pr-author-skill-helpers.ps1. Get-PrAuthorBypassReason calls
    Get-PrAuthorDocsOnlyExemption only in its non-epic branch and only after
    Invoke-OrchestratorStatePreflight reports errors. The exemption lets a gh pr create call
    continue to the receipt checks when the branch changes nothing outside docs/. It fails
    closed: every condition below must hold, and the first that does not names the sub-code
    the caller appends to its ORCHESTRATOR_STATE_PREFLIGHT_FAILED denial.

      E1 DOCS_ONLY_EXEMPTION_NOT_CREATE         - the command is a structural gh pr create.
      E2 DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT - no checkpoint file exists at the resolved path.
      E3 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - exactly one explicit --base, no -B token, and a
                                                  conservative branch spelling without '..'.
      E4 DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED    - refs/remotes/origin/<base> resolves to a commit.
      E5 DOCS_ONLY_EXEMPTION_DIFF_FAILED        - git diff <commit>...HEAD exits 0 without throwing.
      E6 DOCS_ONLY_EXEMPTION_EMPTY_DIFF         - the diff lists at least one path.
      E7 DOCS_ONLY_EXEMPTION_NON_DOCS_PATH      - every path starts with docs/ (ordinal).

    The diff runs with --no-renames so a rename from outside docs/ reports its old path, with -z
    so no path is quoted, and with --no-relative, --no-color, and --no-ext-diff so repository
    configuration cannot change the listing.

.NOTES
    PowerShell 7+. Depends, at call time, on Test-CommandLineInvocation,
    Get-CommandLineStructuralMatch, and Get-CommandLineFlagValue from the command parsers the
    helpers file loads. It reads no file content. The git executable runs only through
    Invoke-PrAuthorDocsOnlyGitExe, the single executable seam, which never throws. Mirrored
    byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>
[CmdletBinding()]
param()

function Invoke-PrAuthorDocsOnlyGitExe {
    <#
    .SYNOPSIS
        Run git -C <root> with the given arguments. The single executable seam; tests mock it.
    .DESCRIPTION
        Never throws: an uncaught error ends the hook with exit 1, which PreToolUse treats as
        non-blocking, so a throw here would allow the call. A root that is not an existing
        directory, or a git that cannot start, returns ExitCode -1. Standard error is discarded
        so that it is never read as path data.
    .PARAMETER WorktreeRoot
        The resolved worktree root git runs in.
    .PARAMETER GitArgs
        The git arguments that follow -C <root>.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ExitCode and Output.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [Parameter(Mandatory)][string[]] $GitArgs
    )

    $failure = [pscustomobject]@{ ExitCode = -1; Output = '' }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot) -or -not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)) {
        return $failure
    }
    try {
        $lines = @(& git -C $WorktreeRoot @GitArgs 2>$null)
        $code = $LASTEXITCODE
    }
    catch {
        return $failure
    }
    return [pscustomobject]@{ ExitCode = [int]$code; Output = ($lines -join "`n") }
}

function Test-PrAuthorDocsOnlyCheckpointPresence {
    <#
    .SYNOPSIS
        Return $true when a checkpoint file exists at the path, and also for a blank path.
    .DESCRIPTION
        A blank path cannot prove that no checkpoint exists, so it reports presence (fail closed).
    .PARAMETER CheckpointPath
        The absolute checkpoint path identity resolution composed.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    if ([string]::IsNullOrWhiteSpace($CheckpointPath)) {
        return $true
    }
    return (Test-Path -LiteralPath $CheckpointPath -PathType Leaf)
}

function Get-PrAuthorDocsOnlyBaseName {
    <#
    .SYNOPSIS
        Return the single explicit --base value of a gh pr create command, or $null.
    .DESCRIPTION
        Returns $null when the command is not a structural gh pr create, when any token begins
        with -B (the short form the shared parser does not read), when --base appears other
        than exactly once, when its value is missing or dash-leading, when the value is not a
        conservative branch spelling, or when it contains '..'.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText
    )

    $subcommandPath = @('pr', 'create')
    $match = Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath
    if ($null -eq $match) {
        return $null
    }
    $baseTokenCount = 0
    foreach ($token in @($match.Segment.Tokens)) {
        $text = [string]$token
        if ($text.StartsWith('-B', [System.StringComparison]::Ordinal)) {
            return $null
        }
        if ($text -eq '--base' -or $text.StartsWith('--base=', [System.StringComparison]::OrdinalIgnoreCase)) {
            $baseTokenCount++
        }
    }
    if ($baseTokenCount -ne 1) {
        return $null
    }
    $base = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--base'
    if ($null -eq $base -or $base -cnotmatch '^[A-Za-z0-9][A-Za-z0-9._/-]*$' -or $base.Contains('..')) {
        return $null
    }
    return $base
}

function ConvertFrom-PrAuthorDocsOnlyNameList {
    <#
    .SYNOPSIS
        Split NUL-separated git output into paths, discarding empty elements.
    .DESCRIPTION
        Callers wrap the result in @() so that an empty listing is an empty array. A path that
        contains a line feed stays one element, because only NUL separates entries.
    .PARAMETER Text
        The captured git output.
    .OUTPUTS
        System.String, one per path
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Text
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return
    }
    foreach ($entry in $Text.Split([char]0)) {
        if ($entry.Length -gt 0) {
            $entry
        }
    }
}

function Get-PrAuthorDocsOnlyPathViolation {
    <#
    .SYNOPSIS
        Return $null when every path is under docs/, else the denial sub-code text.
    .DESCRIPTION
        An empty set returns DOCS_ONLY_EXEMPTION_EMPTY_DIFF. Otherwise the first path that does
        not start with docs/ under ordinal comparison, or that is not longer than docs/ itself,
        returns DOCS_ONLY_EXEMPTION_NON_DOCS_PATH naming that path.
    .PARAMETER Path
        The changed paths, repository-relative, as git reports them.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][AllowEmptyCollection()][string[]] $Path
    )

    $paths = @($Path | Where-Object { $null -ne $_ })
    if ($paths.Count -eq 0) {
        return 'DOCS_ONLY_EXEMPTION_EMPTY_DIFF: the branch diff lists no path.'
    }
    foreach ($entry in $paths) {
        if ($entry.Length -le 5 -or -not $entry.StartsWith('docs/', [System.StringComparison]::Ordinal)) {
            return "DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: '$entry' is outside docs/."
        }
    }
    return $null
}

function Get-PrAuthorDocsOnlyExemption {
    <#
    .SYNOPSIS
        Decide whether a failed preflight is exempt because the branch changes only docs/.
    .DESCRIPTION
        Evaluates E1 to E7 of the file header in order and returns at the first failure.
        Each git call is wrapped so that a throwing seam denies rather than escapes.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER WorktreeRoot
        The resolved worktree root the diff is computed in.
    .PARAMETER CheckpointPath
        The resolved checkpoint path whose absence E2 requires.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Exempt and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $CommandText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    if (-not (Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create'))) {
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_NOT_CREATE: only gh pr create is eligible.' }
    }
    if (Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath $CheckpointPath) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT: a checkpoint file exists at '$CheckpointPath', so its preflight governs." }
    }
    $base = Get-PrAuthorDocsOnlyBaseName -CommandText $CommandText
    if ($null -eq $base) {
        return [ordered]@{ Exempt = $false; Reason = 'DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: pass exactly one explicit --base <branch>; the -B short form is not read.' }
    }

    $baseRef = 'refs/remotes/origin/' + $base + '^{commit}'
    try {
        $revParse = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', $baseRef)
    }
    catch {
        $revParse = $null
    }
    $commit = ''
    if ($null -ne $revParse) {
        $commit = ([string]$revParse.Output).Trim()
    }
    if ($null -eq $revParse -or $revParse.ExitCode -ne 0 -or $commit -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED: refs/remotes/origin/$base does not resolve to a commit in the target worktree." }
    }

    try {
        $diff = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($commit + '...HEAD'))
    }
    catch {
        $diff = $null
    }
    if ($null -eq $diff -or $diff.ExitCode -ne 0) {
        return [ordered]@{ Exempt = $false; Reason = "DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/$base could not be computed." }
    }

    $violation = Get-PrAuthorDocsOnlyPathViolation -Path @(ConvertFrom-PrAuthorDocsOnlyNameList -Text ([string]$diff.Output))
    if ($violation) {
        return [ordered]@{ Exempt = $false; Reason = $violation }
    }
    return [ordered]@{ Exempt = $true; Reason = $null }
}
