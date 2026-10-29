<#
.SYNOPSIS
    Green-CI standalone merge branch of the merge gate (issue #997).

.DESCRIPTION
    Dot-sourced by enforce-epic-merge-gate.ps1. Invoke-EpicMergeGateDecision calls
    Get-EpicMergeGateGreenCiDecision after the parallel allow-branch declines and before the
    standalone authorization branch, so branches 1 to 3 keep their order and behavior. The
    branch allows a standalone run (neither an epic child nor a parallel item) to merge its own
    pull request once its per-feature checkpoint records a green S9 gate for that exact pull
    request and the live pull-request head still equals the head that CI passed on.

    Stages run cheapest first, and only stage D starts a process:
      A. The item target resolved to one worktree and its per-feature checkpoint records a green
         standalone S9 gate bound to the explicit PR number (Test-ChildCheckpointGreenCiRecorded).
      B. No epic or parallel run checkpoint records the PR number (both run targets NoTarget),
         and no parallel run checkpoint records the item worktree as a parallel item.
      C. The command is one structural gh pr merge with no chain, wrapper, inline environment
         prefix, -R or --repo, /pull/ URL selector, or --auto (Get-DocsOnlyMergeShapeViolation).
      D. gh pr view <PR> --json headRefOid returns a well-formed head (one bounded call).
      E. The live head equals ci_gate.head_sha, and --match-head-commit, when present, equals it.
    Stages A to C decline silently, so every existing deny text is unchanged for a non-green
    case. A stage D or E decline returns a suffix that the gate appends to its deny reason:
    GREEN_CI_LIVE_HEAD_UNRESOLVED, GREEN_CI_HEAD_STALE, or GREEN_CI_MATCH_HEAD_MISMATCH.

    Residual parallel-exclusion window: the Parallel mode: true marker lives in the Agent
    delegation prompt and is not in a Bash PreToolUse payload, so this hook cannot see it. The
    exclusion is layered and best-effort: a run target recording the PR number (layer 1a), a
    parallel item recording the worktree path (layer 1b), and child-recorded parallel_mode or
    parallel_slug keys (layer 2), with skill prose as layer 3. A parallel child whose parent has
    recorded neither the PR number nor the worktree path, and which omits the layer 2 keys, is
    not excluded mechanically. Like the standalone authorization record, this is a policy-level
    control, not a cryptographic one. A push after the stage D lookup can also change the head
    unless the command passes --match-head-commit; the hook does not require the flag.

.NOTES
    Compatible with PowerShell 7+. This file dot-sources nothing and imports no module. It
    calls, at run time only, Invoke-DocsOnlyGhExe and Get-DocsOnlyMergeShapeViolation
    (hook-docs-only-diff.ps1), Test-CommandLineFlag and Get-CommandLineFlagValue (the shared
    command parser), and Resolve-WorktreeRunTargetByRecord (WorktreeRunResolution.psm1), all of
    which the gate loads before it calls this file's functions.
#>

function Test-EpicMergeGateGreenCiObjectId {
    <#
    .SYNOPSIS
        True when a value is a full lowercase hexadecimal object id of 40 or 64 characters.
    .PARAMETER Value
        The candidate value; any non-string value returns $false.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [string]) -and ($Value -cmatch '^[0-9a-f]{40}([0-9a-f]{24})?$')
}

function Test-EpicMergeGateGreenCiNotParallel {
    <#
    .SYNOPSIS
        True when a parsed per-feature checkpoint carries no epic or parallel marker (pure).
    .DESCRIPTION
        epic_mode must be absent, JSON null, or JSON false; epic_mode true belongs to branch 1,
        and any other value (for example the string "false") fails closed. parallel_mode must
        be absent, JSON null, or JSON false, and parallel_slug must be absent or blank.
    .PARAMETER Checkpoint
        The parsed checkpoint object.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] $Checkpoint)

    $props = @($Checkpoint.PSObject.Properties.Name)
    # Each marker key passes only when it is absent, JSON null, or the JSON boolean false.
    foreach ($marker in @('epic_mode', 'parallel_mode')) {
        if ($props -ccontains $marker -and $null -ne $Checkpoint.$marker -and
            -not (($Checkpoint.$marker -is [bool]) -and -not $Checkpoint.$marker)) {
            return $false
        }
    }
    return -not ($props -ccontains 'parallel_slug' -and -not [string]::IsNullOrWhiteSpace([string]$Checkpoint.parallel_slug))
}

function Test-ChildCheckpointGreenCiRecorded {
    <#
    .SYNOPSIS
        True when a per-feature checkpoint records a green standalone S9 gate for the PR (pure).
    .DESCRIPTION
        Every condition must hold: the command names a PR number above zero; the checkpoint
        carries no epic or parallel marker (Test-EpicMergeGateGreenCiNotParallel);
        step9_status is exactly "passed"; ci_gate is an object whose conclusion is exactly
        "success"; pr_gate.pr_number is a JSON integer equal to the command number, with no
        fallback to a standalone_merge_authorizations record; ci_gate.head_sha is a lowercase
        40 or 64 character object id; and pr_gate.head_sha, when present and not null, equals
        ci_gate.head_sha. Comparisons are ordinal, so a case variant fails closed.
    .PARAMETER Checkpoint
        Parsed per-feature checkpoint, or $null when absent or unreadable.
    .PARAMETER CommandPrNumber
        The explicit PR number the command names, or $null for a bare command.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber
    )

    if ($null -eq $CommandPrNumber -or $CommandPrNumber -le 0) { return $false }
    if ($Checkpoint -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    if (-not (Test-EpicMergeGateGreenCiNotParallel -Checkpoint $Checkpoint)) { return $false }
    if (-not (($Checkpoint.step9_status -is [string]) -and ($Checkpoint.step9_status -ceq 'passed'))) { return $false }

    $ciGate = $Checkpoint.ci_gate
    if ($ciGate -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    if (-not (($ciGate.conclusion -is [string]) -and ($ciGate.conclusion -ceq 'success'))) { return $false }
    if (-not (Test-EpicMergeGateGreenCiObjectId -Value $ciGate.head_sha)) { return $false }

    # The PR binding comes from pr_gate alone; an authorization record must not stand in for a CI result.
    $prGate = $Checkpoint.pr_gate
    if ($prGate -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    $recordedNumber = $prGate.pr_number
    if (-not (($recordedNumber -is [int]) -or ($recordedNumber -is [long])) -or [long]$recordedNumber -ne $CommandPrNumber) { return $false }

    # A recorded PR head must agree with the head CI passed on; null or absent means not recorded.
    if (@($prGate.PSObject.Properties.Name) -ccontains 'head_sha' -and $null -ne $prGate.head_sha) {
        return [string]::Equals([string]$prGate.head_sha, [string]$ciGate.head_sha, [System.StringComparison]::Ordinal)
    }
    return $true
}

function Get-EpicMergeGateLivePrHeadSha {
    <#
    .SYNOPSIS
        Return the live head commit of a pull request, or $null on any failure (the live-head seam).
    .DESCRIPTION
        Runs gh pr view <PR> --json headRefOid through Invoke-DocsOnlyGhExe, which bounds the
        call at 7 seconds and never throws. Returns the head only for exit code 0, output that
        parses to a JSON object, and a well-formed lowercase object id; a non-zero exit
        (including 124 for a timeout and -1 for a missing root), unparseable output, and a
        malformed head all return $null. Tests mock this function by name.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][int] $PrNumber,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefOid')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
    }
    catch {
        # Unreadable gh output is a lookup failure; the gate fails closed on $null.
        return $null
    }
    if ($pr -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    if (-not (Test-EpicMergeGateGreenCiObjectId -Value $pr.headRefOid)) { return $null }
    return [string]$pr.headRefOid
}

function Test-EpicMergeGateGreenCiHeadAgreement {
    <#
    .SYNOPSIS
        True when the live head equals ci_gate.head_sha and any pinned head equals the live head (pure).
    .PARAMETER Checkpoint
        Parsed per-feature checkpoint carrying ci_gate.head_sha.
    .PARAMETER LiveHeadSha
        The live pull-request head, or $null when unresolved.
    .PARAMETER PinnedHeadSha
        The --match-head-commit value, or $null when the flag is absent. An empty string means
        the flag is present without a usable value and fails closed.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()] $LiveHeadSha,
        [AllowNull()] $PinnedHeadSha
    )

    if ($null -eq $Checkpoint -or $LiveHeadSha -isnot [string] -or $null -eq $Checkpoint.ci_gate) { return $false }
    if (-not [string]::Equals($LiveHeadSha, [string]$Checkpoint.ci_gate.head_sha, [System.StringComparison]::Ordinal)) { return $false }
    if ($null -ne $PinnedHeadSha -and -not [string]::Equals([string]$PinnedHeadSha, $LiveHeadSha, [System.StringComparison]::Ordinal)) { return $false }
    return $true
}

function Resolve-EpicMergeGateParallelItemByWorktree {
    <#
    .SYNOPSIS
        Resolve the parallel run whose items[] record a worktree path (layer 1b seam).
    .DESCRIPTION
        A one-call seam over Resolve-WorktreeRunTargetByRecord so tests can mock it. Status
        NoTarget means no parallel checkpoint records the worktree as a parallel item.
    .PARAMETER WorktreeRoot
        The item worktree whose per-feature checkpoint was read.
    .OUTPUTS
        System.Management.Automation.PSCustomObject (the worktree-resolution target result).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    return Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value $WorktreeRoot -SessionRoot (Get-Location).Path
}

function Test-EpicMergeGateGreenCiNoRunRecord {
    <#
    .SYNOPSIS
        True when no epic or parallel run checkpoint records the PR or the item worktree (stage B).
    .DESCRIPTION
        Both run targets must have status NoTarget; a resolved or Ambiguous target declines.
        The worktree lookup declines on any status other than NoTarget, on $null, and on a
        thrown error, because an unreadable parallel record cannot prove the item is standalone.
    .PARAMETER EpicTarget
        The epic run target resolved for the PR number.
    .PARAMETER ParallelTarget
        The parallel run target resolved for the PR number.
    .PARAMETER WorktreeRoot
        The item worktree root.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] $EpicTarget,
        [AllowNull()] $ParallelTarget,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    foreach ($target in @($EpicTarget, $ParallelTarget)) {
        if ($null -eq $target -or [string]$target.Status -cne 'NoTarget') { return $false }
    }
    try {
        $byWorktree = Resolve-EpicMergeGateParallelItemByWorktree -WorktreeRoot $WorktreeRoot
    }
    catch {
        # A failed lookup cannot show the worktree is not a parallel item, so the stage declines.
        return $false
    }
    return ($null -ne $byWorktree -and [string]$byWorktree.Status -ceq 'NoTarget')
}

function Get-EpicMergeGateGreenCiDecision {
    <#
    .SYNOPSIS
        Evaluate stages A to E of the green-CI branch and return Allowed and a deny suffix.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER CommandPrNumber
        The explicit PR number, or $null for a bare command.
    .PARAMETER ChildCheckpoint
        The parsed per-feature checkpoint the gate read, or $null.
    .PARAMETER ItemTarget
        The item target, or $null for a bare command.
    .PARAMETER EpicTarget
        The epic run target, or $null for a bare command.
    .PARAMETER ParallelTarget
        The parallel run target, or $null for a bare command.
    .PARAMETER SessionRoot
        The session worktree root, where gh runs.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Allowed and Suffix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CommandText,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()] $ChildCheckpoint,
        [AllowNull()] $ItemTarget,
        [AllowNull()] $EpicTarget,
        [AllowNull()] $ParallelTarget,
        [AllowNull()][AllowEmptyString()][string] $SessionRoot
    )

    $silent = [ordered]@{ Allowed = $false; Suffix = '' }
    # Stage A: one resolved item worktree whose checkpoint records a green S9 gate for this PR.
    if ($null -eq $ItemTarget -or @('SessionRoot', 'OtherWorktree') -cnotcontains [string]$ItemTarget.Status) { return $silent }
    if (-not (Test-ChildCheckpointGreenCiRecorded -Checkpoint $ChildCheckpoint -CommandPrNumber $CommandPrNumber)) { return $silent }
    # Stage B: no epic or parallel run records the PR or the item worktree.
    if (-not (Test-EpicMergeGateGreenCiNoRunRecord -EpicTarget $EpicTarget -ParallelTarget $ParallelTarget -WorktreeRoot ([string]$ItemTarget.WorktreeRoot))) { return $silent }
    # Stage C: a single structural gh pr merge naming the PR, with no repository or auto override.
    if ($null -ne (Get-DocsOnlyMergeShapeViolation -CommandText $CommandText -PrNumber $CommandPrNumber)) { return $silent }

    # Stage D: the only process call, made after every pure stage passed.
    $liveHead = Get-EpicMergeGateLivePrHeadSha -PrNumber $CommandPrNumber -WorktreeRoot $SessionRoot
    if ($null -eq $liveHead) {
        return [ordered]@{ Allowed = $false; Suffix = ' (green-CI merge not applied: GREEN_CI_LIVE_HEAD_UNRESOLVED)' }
    }

    # Stage E: a stale checkpoint head is reported before a mismatched --match-head-commit pin.
    $subcommandPath = @('pr', 'merge')
    $pinned = $null
    if (Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit') {
        $pinned = [string](Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--match-head-commit')
    }
    if (Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint $ChildCheckpoint -LiveHeadSha $liveHead -PinnedHeadSha $pinned) {
        return [ordered]@{ Allowed = $true; Suffix = '' }
    }
    if (-not (Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint $ChildCheckpoint -LiveHeadSha $liveHead -PinnedHeadSha $null)) {
        return [ordered]@{ Allowed = $false; Suffix = ' (green-CI merge not applied: GREEN_CI_HEAD_STALE)' }
    }
    return [ordered]@{ Allowed = $false; Suffix = ' (green-CI merge not applied: GREEN_CI_MATCH_HEAD_MISMATCH)' }
}
