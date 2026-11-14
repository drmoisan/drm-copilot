<#
.SYNOPSIS
    Classify the changed-path set of an integration merge for the regenerate path.

.DESCRIPTION
    Pure functions for issue #1156: the changed-path intersection of two
    NUL-separated git listings, declared-pattern matching that delegates to
    Test-GlobMatch in .claude/lib/blast-radius/BlastRadiusGlob.psm1, and the
    first-match decision table that selects the regenerate path or the
    remediation loop.

    Every function is pure: no filesystem, process, network, or clock access.
    The module imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '../blast-radius/BlastRadiusGlob.psm1') -Force -ErrorAction Stop

function ConvertFrom-RegenerationNulListing {
    <#
    .SYNOPSIS
        Split one NUL-separated listing into its non-empty entries.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Listing
    )

    if ([string]::IsNullOrEmpty($Listing)) { return , [string[]] @() }
    return , [string[]] @($Listing.Split([char] 0) | Where-Object { $_.Length -gt 0 })
}

function Get-RegenerationChangedPath {
    <#
    .SYNOPSIS
        Return the ordinal-sorted, de-duplicated intersection of two NUL-separated listings.

    .PARAMETER OursListing
        Output of git diff --name-only -z --no-renames B HEAD.

    .PARAMETER TheirsListing
        Output of git diff --name-only -z --no-renames B MERGE_HEAD.

    .OUTPUTS
        System.String[]. Paths changed on both sides, empty entries removed.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $OursListing,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $TheirsListing
    )

    $theirs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($path in (ConvertFrom-RegenerationNulListing -Listing $TheirsListing)) { [void] $theirs.Add($path) }
    $both = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($path in (ConvertFrom-RegenerationNulListing -Listing $OursListing)) {
        if ($theirs.Contains($path)) { [void] $both.Add($path) }
    }
    return , [string[]] @($both)
}

function Test-RegenerationPathMatch {
    <#
    .SYNOPSIS
        Report whether a repository path matches any declared pattern.

    .DESCRIPTION
        Delegates to Test-GlobMatch (whole-string, ordinal, case-sensitive). A
        pattern that begins with a double-star segment and a slash also matches
        its remainder at the repository root. A candidate holding a backslash
        never matches.

    .PARAMETER Path
        Repository-relative candidate path.

    .PARAMETER Pattern
        Declared path patterns.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]] $Pattern
    )

    if ($Path.Contains('\')) { return $false }
    foreach ($candidatePattern in $Pattern) {
        if (Test-GlobMatch -Pattern $candidatePattern -Candidate $Path) { return $true }
        if ($candidatePattern.StartsWith('**/', [System.StringComparison]::Ordinal)) {
            if (Test-GlobMatch -Pattern $candidatePattern.Substring(3) -Candidate $Path) { return $true }
        }
    }
    return $false
}

function Get-RegenerationPathDecision {
    <#
    .SYNOPSIS
        Apply the first-match classifier rule order to a changed-path set.

    .DESCRIPTION
        Rules: no config gives no_config; config errors give config_invalid; a
        merge-base count other than 1 gives multiple_merge_bases; an empty set
        gives empty_set; a path matching no declared pattern gives unmatched_path
        with UnmatchedPath ordinal-sorted; otherwise regenerate with all_match.
        UnmatchedPath is empty for every reason except unmatched_path.

    .OUTPUTS
        System.Management.Automation.PSCustomObject with Decision, Reason, UnmatchedPath.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]] $ChangedPath,
        [Parameter(Mandatory = $true)]
        [int] $MergeBaseCount,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]] $ConfigError
    )

    $fallback = 'remediation_loop'
    if ($null -eq $Config) { return [pscustomobject]@{ Decision = $fallback; Reason = 'no_config'; UnmatchedPath = [string[]] @() } }
    if ($ConfigError.Count -gt 0) { return [pscustomobject]@{ Decision = $fallback; Reason = 'config_invalid'; UnmatchedPath = [string[]] @() } }
    if ($MergeBaseCount -ne 1) { return [pscustomobject]@{ Decision = $fallback; Reason = 'multiple_merge_bases'; UnmatchedPath = [string[]] @() } }
    if ($ChangedPath.Count -eq 0) { return [pscustomobject]@{ Decision = $fallback; Reason = 'empty_set'; UnmatchedPath = [string[]] @() } }

    $patterns = [string[]] @($Config['paths'])
    $unmatched = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($path in $ChangedPath) {
        if (-not (Test-RegenerationPathMatch -Path $path -Pattern $patterns)) { [void] $unmatched.Add($path) }
    }
    if ($unmatched.Count -gt 0) {
        return [pscustomobject]@{ Decision = $fallback; Reason = 'unmatched_path'; UnmatchedPath = [string[]] @($unmatched) }
    }
    return [pscustomobject]@{ Decision = 'regenerate'; Reason = 'all_match'; UnmatchedPath = [string[]] @() }
}

Export-ModuleMember -Function Get-RegenerationChangedPath, Test-RegenerationPathMatch, Get-RegenerationPathDecision
