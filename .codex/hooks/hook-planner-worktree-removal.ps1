<#
.SYNOPSIS
    Pure decision logic of the planner allow branch of the worktree-removal gates (issue #1161).

.DESCRIPTION
    Dot-sourced by .claude/hooks/enforce-worktree-removal-gate-planner.ps1 and by
    .codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1. Holds only function
    definitions: tolerant parsing of the planner_worktrees records of an epic-planner
    checkpoint, the eligibility rule, parsing of git worktree list --porcelain text, path
    comparison, the ordered removal decision over already-collected facts, and the
    refusal sentence. Nothing here reads a file, starts a process, or changes session
    state, so every rule is testable with in-memory values.

    The branch is a policy-level control, not a security control: any writer in the same
    session can author a record, and the git checks bound what a record can authorize.

.NOTES
    PowerShell 7+. Byte-identical in .claude/hooks/ and .codex/hooks/, pinned by
    tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1.
#>

function ConvertTo-PlannerWorktreeNormalizedPath {
    <#
    .SYNOPSIS
        Return a path with forward slashes and no trailing slash, or '' for a blank value.
    .PARAMETER Path
        The path to normalize.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][AllowEmptyString()][string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    return ($Path.Trim() -replace '\\', '/').TrimEnd('/')
}

function Test-PlannerWorktreePathEqual {
    <#
    .SYNOPSIS
        Compare two paths for equality.
    .DESCRIPTION
        Insensitive to separator style and trailing slashes; ordinal for POSIX roots and
        ordinal-ignore-case for drive-letter and UNC roots. A blank side never matches.
    .PARAMETER Left
        One path.
    .PARAMETER Right
        The other path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Left, [AllowNull()][AllowEmptyString()][string] $Right)

    $a = ConvertTo-PlannerWorktreeNormalizedPath -Path $Left
    $b = ConvertTo-PlannerWorktreeNormalizedPath -Path $Right
    if ($a -eq '' -or $b -eq '') { return $false }
    $comparison = if (($a -match '^([A-Za-z]:|//)') -or ($b -match '^([A-Za-z]:|//)')) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
    return [string]::Equals($a, $b, $comparison)
}

function Test-PlannerWorktreePathEncloses {
    <#
    .SYNOPSIS
        Report whether Outer equals Inner or is an ancestor directory of it.
    .PARAMETER Outer
        The candidate enclosing path (the removal target).
    .PARAMETER Inner
        The candidate enclosed path (the session root).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Outer, [AllowNull()][AllowEmptyString()][string] $Inner)

    if (Test-PlannerWorktreePathEqual -Left $Outer -Right $Inner) { return $true }
    $a = ConvertTo-PlannerWorktreeNormalizedPath -Path $Outer
    $b = ConvertTo-PlannerWorktreeNormalizedPath -Path $Inner
    if ($a -eq '' -or $b.Length -le $a.Length -or $b[$a.Length] -ne '/') { return $false }
    return (Test-PlannerWorktreePathEqual -Left $b.Substring(0, $a.Length) -Right $a)
}

function Test-PlannerWorktreeRelativePathSafe {
    <#
    .SYNOPSIS
        Report whether a recorded path is a safe path relative to the main checkout.
    .DESCRIPTION
        The validator rule: a non-empty string with no drive prefix, no leading slash, no
        backslash, no colon, and no empty, '.', or '..' segment.
    .PARAMETER Path
        The recorded planner_worktrees[].path value.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Path)

    if ($Path -isnot [string] -or $Path.Length -eq 0 -or $Path.StartsWith('/') -or $Path.Contains('\') -or $Path.Contains(':')) { return $false }
    foreach ($segment in $Path.Split('/')) {
        if ($segment -eq '' -or $segment -eq '.' -or $segment -eq '..') { return $false }
    }
    return $true
}

function Test-PlannerWorktreeRecordPathMatch {
    <#
    .SYNOPSIS
        Report whether a record's optional path is consistent with the target.
    .DESCRIPTION
        A record without a path property matches. A record with one matches only when the
        path is safe and its join to the main checkout root equals the target.
    .PARAMETER Record
        One planner_worktrees entry.
    .PARAMETER TargetPath
        The removal target.
    .PARAMETER MainRoot
        The main checkout root from the worktree listing.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Record, [AllowNull()][AllowEmptyString()][string] $TargetPath, [AllowNull()][AllowEmptyString()][string] $MainRoot)

    if ($null -eq $Record) { return $false }
    if (@($Record.PSObject.Properties.Name) -cnotcontains 'path') { return $true }
    if (-not (Test-PlannerWorktreeRelativePathSafe -Path $Record.path)) { return $false }
    $base = ConvertTo-PlannerWorktreeNormalizedPath -Path $MainRoot
    if ($base -eq '') { return $false }
    return (Test-PlannerWorktreePathEqual -Left ($base + '/' + $Record.path) -Right $TargetPath)
}

function Test-PlannerWorktreeRecordedPathMatch {
    <#
    .SYNOPSIS
        Report whether a recorded worktree_path names the target.
    .DESCRIPTION
        A rooted record (drive letter or leading slash) is compared directly. A relative
        record matches when it is safe and its join to one of the base roots equals the target.
    .PARAMETER RecordedPath
        The recorded worktree_path.
    .PARAMETER TargetPath
        The removal target.
    .PARAMETER BaseRoot
        The roots a relative record is joined to.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $RecordedPath, [AllowNull()][AllowEmptyString()][string] $TargetPath, [AllowNull()][AllowEmptyCollection()][string[]] $BaseRoot = @())

    $recorded = ConvertTo-PlannerWorktreeNormalizedPath -Path $RecordedPath
    if ($recorded -match '^([A-Za-z]:(/|$)|/)') { return (Test-PlannerWorktreePathEqual -Left $recorded -Right $TargetPath) }
    if (-not (Test-PlannerWorktreeRelativePathSafe -Path $recorded)) { return $false }
    # Try the join to each base root; any equal join names the target.
    foreach ($root in @($BaseRoot)) {
        $base = ConvertTo-PlannerWorktreeNormalizedPath -Path $root
        if ($base -ne '' -and (Test-PlannerWorktreePathEqual -Left ($base + '/' + $recorded) -Right $TargetPath)) { return $true }
    }
    return $false
}

function Test-PlannerWorktreeTargetCheckpointInUse {
    <#
    .SYNOPSIS
        U4: report whether a target's orchestrator checkpoint is unparseable or not at S5_atomic_execution.
    .PARAMETER Text
        The checkpoint text, or $null when the file is absent; an absent file does not satisfy U4.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    if ($null -eq $Text) { return $false }
    try { $state = ConvertFrom-Json -InputObject $Text -NoEnumerate -ErrorAction Stop } catch { return $true }
    if ($state -isnot [pscustomobject] -or @($state.PSObject.Properties.Name) -cnotcontains 'next_step') { return $true }
    return -not ($state.next_step -is [string] -and $state.next_step -ceq 'S5_atomic_execution')
}

function Get-PlannerWorktreeEpicRecordFact {
    <#
    .SYNOPSIS
        U5: read what an epic-orchestrator checkpoint records about a branch and its worktrees.
    .DESCRIPTION
        Only a checkpoint whose route_id is exactly epic counts. Returns BranchNamed (a
        features[].branch_name equals the branch, ordinally) and WorktreePath (every
        string features[].worktree_path), which the adapter compares with the target.
    .PARAMETER Text
        The epic checkpoint text, or $null.
    .PARAMETER Branch
        The matched record's branch.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $Text, [AllowNull()][AllowEmptyString()][string] $Branch)

    $fact = [pscustomobject]@{ BranchNamed = $false; WorktreePath = [string[]] @() }
    if ([string]::IsNullOrWhiteSpace($Text)) { return $fact }
    try { $state = ConvertFrom-Json -InputObject $Text -NoEnumerate -ErrorAction Stop } catch { return $fact }
    if ($state -isnot [pscustomobject]) { return $fact }
    $names = @($state.PSObject.Properties.Name)
    if ($names -cnotcontains 'route_id' -or $state.route_id -isnot [string] -or $state.route_id -cne 'epic' -or $names -cnotcontains 'features') { return $fact }
    $paths = [System.Collections.Generic.List[string]]::new()
    # Collect each feature's branch_name match and worktree_path.
    foreach ($feature in @($state.features)) {
        if ($feature -isnot [pscustomobject]) { continue }
        $featureNames = @($feature.PSObject.Properties.Name)
        if ($featureNames -ccontains 'branch_name' -and $feature.branch_name -is [string] -and $feature.branch_name -ceq $Branch) { $fact.BranchNamed = $true }
        if ($featureNames -ccontains 'worktree_path' -and $feature.worktree_path -is [string]) { $paths.Add($feature.worktree_path) }
    }
    $fact.WorktreePath = $paths.ToArray()
    return $fact
}

function Get-PlannerWorktreeCandidateRecord {
    <#
    .SYNOPSIS
        Parse epic-planner checkpoint text tolerantly and return its candidate records.
    .DESCRIPTION
        A candidate is an object entry of planner_worktrees whose branch is a non-empty
        string. Unparseable text, a non-object root, an absent or non-list
        planner_worktrees, and every other entry contribute nothing.
    .PARAMETER Text
        The checkpoint text, or $null when no checkpoint was read.
    .OUTPUTS
        PSCustomObject with Branch, Record, and IntegrationBranch ('' when absent or not a string).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return }
    try { $state = ConvertFrom-Json -InputObject $Text -NoEnumerate -ErrorAction Stop } catch { return }
    if ($state -isnot [pscustomobject] -or @($state.PSObject.Properties.Name) -cnotcontains 'planner_worktrees') { return }
    $records = $state.planner_worktrees
    if ($records -isnot [array]) { return }
    $integration = ''
    if (@($state.PSObject.Properties.Name) -ccontains 'integration_branch' -and $state.integration_branch -is [string]) { $integration = $state.integration_branch }
    # Keep each object entry that carries a non-empty string branch; every other entry is inert.
    foreach ($record in $records) {
        if ($record -isnot [pscustomobject] -or @($record.PSObject.Properties.Name) -cnotcontains 'branch') { continue }
        if ($record.branch -isnot [string] -or $record.branch.Length -eq 0) { continue }
        [pscustomobject]@{ Branch = $record.branch; Record = $record; IntegrationBranch = $integration }
    }
}

function Test-PlannerWorktreeRecordEligible {
    <#
    .SYNOPSIS
        Report whether a record is gate-eligible.
    .DESCRIPTION
        purpose is exactly preparation and preparation_status is exactly prepared or
        fanned_in; both comparisons are ordinal and case-sensitive.
    .PARAMETER Record
        One planner_worktrees entry.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Record)

    if ($null -eq $Record) { return $false }
    $names = @($Record.PSObject.Properties.Name)
    if ($names -cnotcontains 'purpose' -or $names -cnotcontains 'preparation_status') { return $false }
    $purpose = $Record.purpose
    $status = $Record.preparation_status
    return ($purpose -is [string] -and $purpose -ceq 'preparation' -and $status -is [string] -and ($status -ceq 'prepared' -or $status -ceq 'fanned_in'))
}

function ConvertFrom-PlannerWorktreePorcelain {
    <#
    .SYNOPSIS
        Parse git worktree list --porcelain output into one record per non-bare stanza.
    .DESCRIPTION
        Each record carries Root, Branch (refs/heads/ stripped, $null when detached),
        Locked (the stanza carries a locked line, with or without a reason), and IsMain
        (the stanza is the first one, which git always lists for the main checkout).
    .PARAMETER Text
        The porcelain output, as one string or as lines.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyCollection()][string[]] $Text)

    $stanzas = [System.Collections.Generic.List[hashtable]]::new()
    $current = $null
    # Group the lines into stanzas; a worktree line opens one and a blank line closes it.
    foreach ($line in (($Text -join "`n") -split "`r?`n")) {
        if ($line.StartsWith('worktree ')) {
            $current = @{ Root = $line.Substring(9); Branch = $null; Locked = $false; Bare = $false }
            $stanzas.Add($current)
        } elseif ($null -eq $current) {
            continue
        } elseif ($line.StartsWith('branch ')) {
            $ref = $line.Substring(7)
            $current.Branch = if ($ref.StartsWith('refs/heads/')) { $ref.Substring(11) } else { $ref }
        } elseif ($line -ceq 'locked' -or $line.StartsWith('locked ')) {
            $current.Locked = $true
        } elseif ($line -ceq 'bare') {
            $current.Bare = $true
        } elseif ($line -eq '') {
            $current = $null
        }
    }
    # Emit the non-bare stanzas; only the first stanza is the main checkout.
    for ($index = 0; $index -lt $stanzas.Count; $index++) {
        $stanza = $stanzas[$index]
        if ($stanza.Bare) { continue }
        [pscustomobject]@{ Root = $stanza.Root; Branch = $stanza.Branch; Locked = $stanza.Locked; IsMain = ($index -eq 0) }
    }
}

function Get-PlannerWorktreeOutcome {
    <#
    .SYNOPSIS
        Construct one decision outcome.
    .DESCRIPTION
        Outcome is Allow, Refuse (with Code and Detail), NoRecord, or Pending (with the
        name of the next git fact the adapter must collect).
    .PARAMETER Outcome
        The outcome kind.
    .PARAMETER Code
        The refusal code suffix (for example DIRTY).
    .PARAMETER Detail
        The refusal detail.
    .PARAMETER Pending
        The fact to collect: Status, Head, IntegrationAncestor, or BranchAncestor.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][ValidateSet('Allow', 'Refuse', 'NoRecord', 'Pending')][string] $Outcome,
        [string] $Code,
        [string] $Detail,
        [string] $Pending
    )

    return [pscustomobject]@{ Outcome = $Outcome; Code = $Code; Detail = $Detail; Pending = $Pending }
}

function Get-PlannerWorktreeRemovalDecision {
    <#
    .SYNOPSIS
        Decide the planner branch for one removal target from already-collected facts.
    .DESCRIPTION
        Evaluates in the spec order and returns the first refusal: listing failure,
        no record (NoRecord), ambiguity, eligibility, in use U1 to U5, clean, then
        committed and pushed. A git fact that is still $null yields Pending naming it,
        so the adapter runs git only as far as the decision needs.
    .PARAMETER Facts
        Hashtable or object with ListingExitCode, Branch, MatchCount, BranchRootCount,
        Record, IntegrationBranch, U1 to U5, StatusExitCode, StatusOutput, HeadExitCode,
        Head, IntegrationAncestorExitCode, and BranchAncestorExitCode.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] $Facts)

    $branch = [string] $Facts.Branch
    if ($null -ne $Facts.ListingExitCode -and [int] $Facts.ListingExitCode -ne 0) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code GIT_FAILED -Detail "branch '$branch': git worktree list exited $($Facts.ListingExitCode)"
    }
    if ([int] $Facts.MatchCount -eq 0) { return Get-PlannerWorktreeOutcome -Outcome NoRecord }
    if ([int] $Facts.MatchCount -gt 1 -or [int] $Facts.BranchRootCount -gt 1) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code AMBIGUOUS -Detail "branch '$branch' is ambiguous: $($Facts.MatchCount) matching planner records, $($Facts.BranchRootCount) live roots with it checked out"
    }
    if (-not (Test-PlannerWorktreeRecordEligible -Record $Facts.Record)) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code NOT_ELIGIBLE -Detail "branch '$branch' needs purpose preparation and preparation_status prepared or fanned_in"
    }
    # The in-use conditions are evaluated in their fixed order; the first that holds refuses.
    $inUse = [ordered]@{
        U1 = "U1 the worktree of branch '$branch' is or encloses the session root, or holds the planner checkpoint"
        U2 = "U2 the worktree of branch '$branch' is the main checkout"
        U3 = "U3 the worktree of branch '$branch' is locked"
        U4 = "U4 the worktree of branch '$branch' holds an orchestrator checkpoint that is unparseable or not at S5_atomic_execution"
        U5 = "U5 a live epic checkpoint records the worktree of branch '$branch'"
    }
    foreach ($condition in $inUse.Keys) {
        if ([bool] $Facts.$condition) { return Get-PlannerWorktreeOutcome -Outcome Refuse -Code IN_USE -Detail $inUse[$condition] }
    }
    if ($null -eq $Facts.StatusExitCode) { return Get-PlannerWorktreeOutcome -Outcome Pending -Pending Status }
    if ([int] $Facts.StatusExitCode -ne 0) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code GIT_FAILED -Detail "branch '$branch': git status exited $($Facts.StatusExitCode)"
    }
    if (-not [string]::IsNullOrWhiteSpace([string] $Facts.StatusOutput)) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code DIRTY -Detail "branch '$branch' has uncommitted or untracked changes"
    }
    if ($null -eq $Facts.HeadExitCode) { return Get-PlannerWorktreeOutcome -Outcome Pending -Pending Head }
    if ([int] $Facts.HeadExitCode -ne 0 -or [string]::IsNullOrWhiteSpace([string] $Facts.Head)) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code GIT_FAILED -Detail "branch '$branch': git rev-parse --verify HEAD exited $($Facts.HeadExitCode)"
    }
    # The integration ref is tried first when recorded; exit 1 falls through to the branch ref.
    if (-not [string]::IsNullOrEmpty([string] $Facts.IntegrationBranch)) {
        if ($null -eq $Facts.IntegrationAncestorExitCode) { return Get-PlannerWorktreeOutcome -Outcome Pending -Pending IntegrationAncestor }
        $code = [int] $Facts.IntegrationAncestorExitCode
        if ($code -eq 0) { return Get-PlannerWorktreeOutcome -Outcome Allow }
        if ($code -ne 1) {
            return Get-PlannerWorktreeOutcome -Outcome Refuse -Code GIT_FAILED -Detail "branch '$branch': git merge-base --is-ancestor against the integration ref exited $code"
        }
    }
    if ($null -eq $Facts.BranchAncestorExitCode) { return Get-PlannerWorktreeOutcome -Outcome Pending -Pending BranchAncestor }
    $code = [int] $Facts.BranchAncestorExitCode
    if ($code -eq 0) { return Get-PlannerWorktreeOutcome -Outcome Allow }
    if ($code -eq 1) {
        return Get-PlannerWorktreeOutcome -Outcome Refuse -Code NOT_PUSHED -Detail "branch '$branch' HEAD is on neither the integration nor the branch remote-tracking ref"
    }
    return Get-PlannerWorktreeOutcome -Outcome Refuse -Code GIT_FAILED -Detail "branch '$branch': git merge-base --is-ancestor against the branch ref exited $code"
}

function Format-PlannerWorktreeRefusalSentence {
    <#
    .SYNOPSIS
        Return the refusal sentence appended to a gate's final deny text.
    .PARAMETER Code
        The refusal code suffix (for example DIRTY).
    .PARAMETER Detail
        The refusal detail, without a closing period.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $Code, [Parameter(Mandatory)][string] $Detail)

    return "Planner worktree: PLANNER_WORKTREE_${Code}: $Detail."
}

function Get-PlannerWorktreeDenySuffix {
    <#
    .SYNOPSIS
        Return ' ' plus the refusal sentence for a Refuse outcome, or '' for any other outcome.
    .DESCRIPTION
        The gates append this to their final deny text, so a target no record names keeps
        byte-identical deny text.
    .PARAMETER Decision
        The planner decision, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] $Decision)

    if ($null -eq $Decision -or $Decision.Outcome -ne 'Refuse') { return '' }
    return ' ' + (Format-PlannerWorktreeRefusalSentence -Code $Decision.Code -Detail $Decision.Detail)
}

function Get-PlannerWorktreeGitFactArgument {
    <#
    .SYNOPSIS
        Return the git arguments that collect one pending fact for the target.
    .PARAMETER Pending
        Status, Head, IntegrationAncestor, or BranchAncestor.
    .PARAMETER WorktreePath
        The removal target, passed to git as -C.
    .PARAMETER Facts
        The facts collected so far (Head, IntegrationBranch, Branch).
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory)][ValidateSet('Status', 'Head', 'IntegrationAncestor', 'BranchAncestor')][string] $Pending, [Parameter(Mandatory)][string] $WorktreePath, [Parameter(Mandatory)][hashtable] $Facts)

    switch ($Pending) {
        'Status' { return , [string[]] @('-C', $WorktreePath, 'status', '--porcelain=v1', '--untracked-files=all') }
        'Head' { return , [string[]] @('-C', $WorktreePath, 'rev-parse', '--verify', 'HEAD') }
        'IntegrationAncestor' { return , [string[]] @('-C', $WorktreePath, 'merge-base', '--is-ancestor', [string] $Facts.Head, "refs/remotes/origin/$($Facts.IntegrationBranch)") }
        default { return , [string[]] @('-C', $WorktreePath, 'merge-base', '--is-ancestor', [string] $Facts.Head, "refs/remotes/origin/$($Facts.Branch)") }
    }
}

function Add-PlannerWorktreeGitFact {
    <#
    .SYNOPSIS
        Record one git result in the facts hashtable under the pending fact's keys.
    .PARAMETER Pending
        Status, Head, IntegrationAncestor, or BranchAncestor.
    .PARAMETER Result
        The git seam result (ExitCode and Output).
    .PARAMETER Facts
        The facts hashtable, updated in place.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param([Parameter(Mandatory)][ValidateSet('Status', 'Head', 'IntegrationAncestor', 'BranchAncestor')][string] $Pending, [Parameter(Mandatory)] $Result, [Parameter(Mandatory)][hashtable] $Facts)

    $text = (@($Result.Output) | ForEach-Object { [string] $_ }) -join "`n"
    switch ($Pending) {
        'Status' { $Facts.StatusExitCode = [int] $Result.ExitCode; $Facts.StatusOutput = $text }
        'Head' { $Facts.HeadExitCode = [int] $Result.ExitCode; $Facts.Head = $text.Trim() }
        'IntegrationAncestor' { $Facts.IntegrationAncestorExitCode = [int] $Result.ExitCode }
        default { $Facts.BranchAncestorExitCode = [int] $Result.ExitCode }
    }
}
