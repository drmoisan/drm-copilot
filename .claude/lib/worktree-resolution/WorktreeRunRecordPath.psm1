<#
.SYNOPSIS
    Shared comparison of a recorded worktree_path with a removal target (issue #995).

.DESCRIPTION
    A run checkpoint records items[].worktree_path or features[].worktree_path either as
    an absolute path or relative to the main checkout. Every site that compares such a
    record to the absolute path a command names calls Test-WorktreeRunRecordedPathMatchesTarget,
    so a relative record is joined to the same base roots everywhere and no site carries
    its own normalise-and-compare.

    A rooted record is compared to the target with Test-WorktreeRunPathEqual. A relative
    record is joined to each non-blank base root and compared the same way. A relative
    record that is blank, is . or .., has a . or .. segment, or contains : matches
    nothing, so it can never name the main checkout or a path outside it.

.NOTES
    PowerShell 7+. The two comparison functions are pure. Get-WorktreeRunMainCheckoutRoot
    reads the filesystem only through its siblings' seams (Get-WorktreeItemLiveRoot and
    Get-WorktreeResolutionGitEntryKind). Mirrored byte-identically.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'WorktreeResolution.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'WorktreeItemResolution.psm1') -ErrorAction Stop

# A drive-rooted, slash-rooted, or // (UNC) path; anything else is relative to some directory.
# The same pattern as $script:AbsolutePathPattern in WorktreeRunResolution.psm1.
$script:AbsolutePathPattern = '^([A-Za-z]:(/|$)|/)'

# The administrative entry that is a directory only in the main checkout; a linked
# worktree carries a .git file instead.
$script:GitEntryName = '.git'

# Private (moved from WorktreeRunResolution.psm1 for issue #995): compare two worktree
# paths, insensitive to separator style and trailing slashes, and case-insensitive for
# drive-letter and UNC (//) paths.
function Test-WorktreeRunPathEqual {
    <#
    .SYNOPSIS
        Compare two worktree paths for equality.
    .DESCRIPTION
        Pure. Insensitive to separator style and trailing slashes; ordinal for single-slash
        POSIX roots and ordinal-ignore-case for drive-letter and UNC (//) roots. A blank
        side never matches.
    .PARAMETER Left
        One path.
    .PARAMETER Right
        The other path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Left,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Right
    )

    if ([string]::IsNullOrWhiteSpace($Left) -or [string]::IsNullOrWhiteSpace($Right)) { return $false }
    $a = ($Left.Trim() -replace '\\', '/').TrimEnd('/')
    $b = ($Right.Trim() -replace '\\', '/').TrimEnd('/')
    $isCaseInsensitivePath = ($a -match '^([A-Za-z]:|//)') -or ($b -match '^([A-Za-z]:|//)')
    $comparison = if ($isCaseInsensitivePath) { [System.StringComparison]::OrdinalIgnoreCase } else { [System.StringComparison]::Ordinal }
    return [string]::Equals($a, $b, $comparison)
}

# Private: whether a relative recorded path (already slash-normalised) is safe to join.
function Test-WorktreeRunRelativeRecordSafe {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or $Path.Contains(':')) { return $false }
    foreach ($segment in $Path.TrimEnd('/').Split('/')) {
        if ($segment -eq '.' -or $segment -eq '..') { return $false }
    }
    return ($Path.TrimEnd('/').Length -gt 0)
}

function Test-WorktreeRunRecordedPathMatchesTarget {
    <#
    .SYNOPSIS
        Report whether a recorded worktree_path names the removal target.
    .DESCRIPTION
        Pure. A rooted record (drive-letter, single-slash, or // after backslash-to-slash
        normalisation) matches when Test-WorktreeRunPathEqual holds against the target. A
        relative record matches when it is safe and Test-WorktreeRunPathEqual holds for
        its join to at least one non-blank base root. A relative record that is blank, is
        . or .., has a . or .. segment, or contains : matches nothing, as does a blank target.
    .PARAMETER RecordedPath
        The worktree_path a checkpoint records, absolute or relative.
    .PARAMETER TargetPath
        The absolute path the command names.
    .PARAMETER BaseRoot
        Optional. The roots a relative record is joined to: the main checkout root and the
        root that holds the checkpoint. With none, a relative record matches nothing.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $RecordedPath,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $TargetPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $BaseRoot = @()
    )

    if ([string]::IsNullOrWhiteSpace($RecordedPath) -or [string]::IsNullOrWhiteSpace($TargetPath)) { return $false }
    $recorded = $RecordedPath.Trim() -replace '\\', '/'
    if ($recorded -match $script:AbsolutePathPattern) {
        return (Test-WorktreeRunPathEqual -Left $recorded -Right $TargetPath)
    }
    if (-not (Test-WorktreeRunRelativeRecordSafe -Path $recorded)) { return $false }
    foreach ($root in @($BaseRoot)) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        $joined = (($root.Trim() -replace '\\', '/').TrimEnd('/')) + '/' + $recorded.TrimEnd('/')
        if (Test-WorktreeRunPathEqual -Left $joined -Right $TargetPath) { return $true }
    }
    return $false
}

function Get-WorktreeRunMainCheckoutRoot {
    <#
    .SYNOPSIS
        Return the main checkout root reachable from a session path, or $null.
    .DESCRIPTION
        The first live root whose .git entry is a directory; a linked worktree's .git entry
        is a file. Reads the filesystem only through Get-WorktreeItemLiveRoot and
        Get-WorktreeResolutionGitEntryKind, the seams a test mocks.
    .PARAMETER SessionRoot
        The calling process's path, used only to find the repository.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SessionRoot
    )

    $liveRoots = Get-WorktreeItemLiveRoot -SessionRoot $SessionRoot
    foreach ($root in $liveRoots) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        $gitEntry = (($root -replace '\\', '/').TrimEnd('/')) + '/' + $script:GitEntryName
        if ((Get-WorktreeResolutionGitEntryKind -Path $gitEntry) -eq 'Directory') { return $root }
    }
    return $null
}

Export-ModuleMember -Function `
    Test-WorktreeRunPathEqual, `
    Test-WorktreeRunRecordedPathMatchesTarget, `
    Get-WorktreeRunMainCheckoutRoot
