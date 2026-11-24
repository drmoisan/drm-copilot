<#
.SYNOPSIS
    Pure predicates shared by the release pull-request legs (issue #1231).

.DESCRIPTION
    Dot-sourced, guarded, by enforce-pr-author-skill.release.ps1,
    enforce-model-routing-receipt-release.ps1, and
    enforce-orchestration-preimplementation-gate-release-receipt.ps1. This file reads no file,
    starts no process, and reads no environment state; it dot-sources nothing. The I/O seams are
    passed in by the caller as scriptblocks.

    Get-ReleasePullRequestConfigState reads the destination-owned allowance file
    .claude/release-commit-allowance.json beneath a worktree root R through the injected reader,
    parses it with ConvertFrom-ReleaseAllowanceConfig (issue #1201), and probes every allowed_paths
    entry with the injected container probe. It returns State Absent (blank root or no file),
    Invalid (read failure, parse failure, probe failure, or a directory entry), or Valid.

    Get-ReleasePullRequestPathDecision decides one branch and one diff path list against the
    parsed allowances. Candidates are the allowances whose branch_patterns match the branch
    (Test-ReleaseAllowanceBranchMatch), in file order. The first candidate that lists every path
    wins; paths are never combined across allowances. Path comparison is ordinal and
    case-sensitive. The failure kinds, in evaluation order, are BranchNotMatched, EmptyPath, and
    PathNotAllowed (the first unlisted path of the first candidate).

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. Call-time dependencies loaded by the
    callers: ConvertFrom-ReleaseAllowanceConfig and Test-ReleaseAllowanceBranchMatch
    (hook-release-allowance-context.ps1). Script-scope names use the prefix ReleasePullRequest.
    This hook file starts no interpreter process. A policy-level control, not a security control.
#>

function Get-ReleasePullRequestConfigState {
    <#
    .SYNOPSIS
        Read, parse, and probe the release-commit allowance file beneath a worktree root.
    .PARAMETER WorktreeRoot
        The resolved worktree root R.
    .PARAMETER ConfigReader
        Called with R; returns the file text, $null for an absent file, or throws.
    .PARAMETER ContainerProbe
        Called with R and an allowed_paths entry; returns $true when the entry is a directory.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with State, Allowances, and Detail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [Parameter(Mandatory)][scriptblock] $ConfigReader,
        [Parameter(Mandatory)][scriptblock] $ContainerProbe
    )

    $absent = [pscustomobject]@{ State = 'Absent'; Allowances = @(); Detail = '' }
    if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) { return $absent }
    try {
        $text = & $ConfigReader $WorktreeRoot
    } catch {
        return [pscustomobject]@{ State = 'Invalid'; Allowances = @(); Detail = 'the file could not be read' }
    }
    if ($null -eq $text) { return $absent }
    $config = ConvertFrom-ReleaseAllowanceConfig -Text ([string]$text)
    if (-not $config.Valid) { return [pscustomobject]@{ State = 'Invalid'; Allowances = @(); Detail = [string]$config.Detail } }
    foreach ($allowance in @($config.Allowances)) {
        foreach ($entry in @($allowance.AllowedPaths)) {
            try {
                $isContainer = [bool](& $ContainerProbe $WorktreeRoot $entry)
            } catch {
                return [pscustomobject]@{ State = 'Invalid'; Allowances = @(); Detail = "allowed_paths entry '$entry' could not be checked" }
            }
            if ($isContainer) { return [pscustomobject]@{ State = 'Invalid'; Allowances = @(); Detail = "allowed_paths entry '$entry' is a directory" } }
        }
    }
    return [pscustomobject]@{ State = 'Valid'; Allowances = @($config.Allowances); Detail = '' }
}

function Get-ReleasePullRequestPathDecision {
    <#
    .SYNOPSIS
        Decide a branch and a diff path list against the parsed allowances.
    .PARAMETER Allowances
        The Allowances of a Valid Get-ReleasePullRequestConfigState result.
    .PARAMETER Branch
        The head branch name.
    .PARAMETER Path
        The diff paths.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed, Failure (BranchNotMatched,
        EmptyPath, PathNotAllowed, or ''), Detail, and AllowanceId.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyCollection()][object[]] $Allowances,
        [AllowNull()][AllowEmptyString()][string] $Branch,
        [AllowNull()][AllowEmptyCollection()][string[]] $Path
    )

    $candidates = @(@($Allowances) | Where-Object { $null -ne $_ } | Where-Object {
            $allowance = $_
            @(@($allowance.BranchPatterns) | Where-Object { Test-ReleaseAllowanceBranchMatch -Branch $Branch -Pattern $_ }).Count -gt 0
        })
    if ($candidates.Count -eq 0) { return [pscustomobject]@{ Allowed = $false; Failure = 'BranchNotMatched'; Detail = "branch '$Branch' matches no allowance"; AllowanceId = '' } }
    $paths = [string[]]@(@($Path) | Where-Object { -not [string]::IsNullOrEmpty($_) })
    if ($paths.Count -eq 0) { return [pscustomobject]@{ Allowed = $false; Failure = 'EmptyPath'; Detail = 'the path list is empty'; AllowanceId = '' } }
    $firstFailure = $null
    foreach ($candidate in $candidates) {
        $allowed = [string[]]@($candidate.AllowedPaths)
        $unlisted = @($paths | Where-Object { $allowed -cnotcontains $_ } | Select-Object -First 1)
        if ($unlisted.Count -eq 0) { return [pscustomobject]@{ Allowed = $true; Failure = ''; Detail = ''; AllowanceId = [string]$candidate.Id } }
        if ($null -eq $firstFailure) {
            $firstFailure = [pscustomobject]@{ Allowed = $false; Failure = 'PathNotAllowed'; Detail = "'$($unlisted[0])' is not listed in allowed_paths of allowance '$($candidate.Id)'"; AllowanceId = '' }
        }
    }
    return $firstFailure
}
