<#
.SYNOPSIS
    Review guard of the merge gate under review_mode concurrent (issue #1097).

.DESCRIPTION
    Dot-sourced by enforce-epic-merge-gate.ps1 in both runtimes; this file is byte-identical in the
    Claude and Codex hook folders. Each gate calls Get-EpicMergeGateReviewDecision with the
    per-feature checkpoint it read, before any allow branch, so a checkpoint that carries the key
    cannot reach an allow branch without a passing review at a current head.

    The key is the top-level checkpoint key review_mode. Only the exact string concurrent activates
    the guard, compared ordinally; an absent key, null, sequential, a case variant, a number, and
    every other non-string value mean sequential, and the guard then starts no process and denies
    nothing. Test-EpicMergeGateReviewModeConcurrent holds that predicate.

    Evaluation order; the first match ends it:
      1. The checkpoint is absent or the key is not exactly concurrent: inert, no process.
      2. The command names no pull request number: REVIEW_GATE_HEAD_UNRESOLVED, before any process.
      3. The last remediation_loop.review_outcomes entry is missing, is not an object, or its
         verdict is not exactly PASS: REVIEW_GATE_NOT_PASSED, before any process.
      4. Its head_sha is absent or malformed: REVIEW_GATE_NOT_PASSED, before any process.
      5. The one bounded gh pr view <PR> --json headRefOid fails or is malformed:
         REVIEW_GATE_HEAD_UNRESOLVED.
      6. head_sha equals the live head: pass.
      7. git merge-base --is-ancestor <reviewed> <live> exits 1: REVIEW_GATE_HEAD_STALE.
      8. That command exits anything other than 0 or 1: REVIEW_GATE_HEAD_UNRESOLVED.
      9. feature-folder is not a clean path below docs/features/: REVIEW_GATE_HEAD_UNRESOLVED.
     10. git diff --name-only -z of the reviewed and live heads fails, or its non-empty output does
         not end with NUL: REVIEW_GATE_HEAD_UNRESOLVED.
     11. A listed path does not start with <feature-folder>/ (ordinal): REVIEW_GATE_HEAD_STALE,
         naming the path.
     12. Otherwise, including an empty listing: pass.

    A code change after the review is therefore stale, including a merge of origin/main, because
    that diff lists code paths. The hook never fetches: a head that is not present locally fails
    step 7 or 8 and denies. The guard applies to whichever checkpoint its gate hands it, with no
    binding exemption, so an explicit PR number that the checkpoint does not bind fails at the head
    comparison; an exemption for an unbound number would open a bypass on Codex, whose child branch
    requires no PR binding.

    Limits (issue #1097 decision D10): this guard is a policy-level control, not a security control.
    A writer in the same session can edit the checkpoint. A merge outside the Bash hook surface is
    not gated. A merge whose item target does not resolve (NoTarget or Ambiguous), or whose child
    checkpoint does not parse, sees no key, and the parallel skill step is then the only backstop. A
    push after the lookup can change the head unless the command passes --match-head-commit. The
    CI full run requirement of the join is skill-level, because a docs-only head passes CI Required
    Gate. The authorization path reads no CI result, so the required CI Required Gate context is the
    control there.

.NOTES
    Compatible with PowerShell 7+. This file dot-sources nothing and imports no module. It calls, at
    run time only, Invoke-DocsOnlyGhExe and Invoke-DocsOnlyGitExe (hook-docs-only-diff.ps1), which
    the gate loads before it calls this file's functions and which bound each call and never throw.
    The Claude gate runs gh in the session worktree and git in the item worktree; the Codex gate
    runs both in the repository root.
#>

function Test-EpicMergeGateReviewModeConcurrent {
    <#
    .SYNOPSIS
        True when a parsed checkpoint carries review_mode exactly equal to concurrent (pure).
    .DESCRIPTION
        The value is tested with -is [string] first, because -ceq on an array filters rather than
        compares. The guard and the readiness relaxation share this meaning.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint, or $null when absent or unreadable.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Checkpoint)

    if ($Checkpoint -isnot [System.Management.Automation.PSCustomObject]) { return $false }
    if (@($Checkpoint.PSObject.Properties.Name) -cnotcontains 'review_mode') { return $false }
    $mode = $Checkpoint.review_mode
    return ($mode -is [string]) -and ($mode -ceq 'concurrent')
}

function Test-EpicMergeGateReviewObjectId {
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

    return ($Value -is [string]) -and ($Value -cmatch '\A[0-9a-f]{40}([0-9a-f]{24})?\z')
}

function Get-EpicMergeGateLastReviewOutcome {
    <#
    .SYNOPSIS
        Return the last remediation_loop.review_outcomes entry when it is an object, else $null.
    .DESCRIPTION
        Last-entry semantics: only the final list element counts, so an earlier PASS never
        satisfies the guard. A missing loop, a value that is not a list, an empty list, and a final
        element that is not an object all return $null.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint.
    .OUTPUTS
        System.Management.Automation.PSCustomObject or $null
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()] $Checkpoint)

    $loop = $Checkpoint.remediation_loop
    if ($loop -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $outcomes = $loop.review_outcomes
    if ($outcomes -isnot [System.Array] -or $outcomes.Count -eq 0) { return $null }
    $last = $outcomes[$outcomes.Count - 1]
    if ($last -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    return $last
}

function Test-EpicMergeGateReviewFeatureFolder {
    <#
    .SYNOPSIS
        True when a value is a clean relative path below docs/features/ (pure).
    .DESCRIPTION
        A blank value, a value outside docs/features/ (which includes every absolute path), a
        backslash, an empty segment (which includes a trailing slash), and a dot segment all return
        $false, so a value such as . cannot widen the feature-folder rule.
    .PARAMETER Value
        The candidate feature-folder value; any non-string value returns $false.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) { return $false }
    if (-not $Value.StartsWith('docs/features/', [System.StringComparison]::Ordinal)) { return $false }
    if ($Value.IndexOf([char]92) -ge 0) { return $false }
    foreach ($segment in $Value.Split('/')) {
        if ($segment.Length -eq 0 -or $segment -ceq '.' -or $segment -ceq '..') { return $false }
    }
    return $true
}

function Test-EpicMergeGateReviewPathInFolder {
    <#
    .SYNOPSIS
        True when a repository-relative path lies inside the feature folder (pure, ordinal).
    .DESCRIPTION
        The prefix carries the separator, so a sibling folder whose name extends the feature folder
        does not match.
    .PARAMETER Path
        The repository-relative path a diff listed.
    .PARAMETER FeatureFolder
        The validated feature folder.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $FeatureFolder
    )

    return $Path.StartsWith($FeatureFolder + '/', [System.StringComparison]::Ordinal)
}

function Get-EpicMergeGateReviewLiveHeadSha {
    <#
    .SYNOPSIS
        Return the live head commit of a pull request, or $null on any failure (the live-head seam).
    .DESCRIPTION
        Runs gh pr view <PR> --json headRefOid through Invoke-DocsOnlyGhExe, which bounds the call
        and never throws. This is the guard's own seam, because the green-CI sibling that holds a
        similar function exists only on the Claude runtime. A non-zero exit, output that does not
        parse to a JSON object, and a malformed head all return $null. Tests mock this by name.
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
        # Unreadable gh output is a lookup failure; the guard fails closed on $null.
        return $null
    }
    if ($pr -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    if (-not (Test-EpicMergeGateReviewObjectId -Value $pr.headRefOid)) { return $null }
    return [string]$pr.headRefOid
}

function Get-EpicMergeGateReviewHeadState {
    <#
    .SYNOPSIS
        Classify a reviewed head against the live head as Current, Stale, or Unresolved.
    .DESCRIPTION
        Evaluates steps 6 to 12 of the file header in order. A later head is Current only when the
        reviewed head is its ancestor and every path changed since then lies inside the feature
        folder, so review artifacts and evidence do not force a new review.
    .PARAMETER ReviewedHead
        The head_sha of the last review outcome.
    .PARAMETER LiveHead
        The live pull-request head.
    .PARAMETER FeatureFolder
        The checkpoint's feature-folder value, not yet validated.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with State and Detail.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $ReviewedHead,
        [Parameter(Mandatory)][string] $LiveHead,
        [AllowNull()] $FeatureFolder,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    if ([string]::Equals($ReviewedHead, $LiveHead, [System.StringComparison]::Ordinal)) {
        return [ordered]@{ State = 'Current'; Detail = 'the reviewed head is the live head.' }
    }

    $ancestry = Invoke-DocsOnlyGitExe -WorktreeRoot $GitRoot -GitArgs @('merge-base', '--is-ancestor', $ReviewedHead, $LiveHead)
    $ancestryExit = if ($null -eq $ancestry) { -1 } else { [int]$ancestry.ExitCode }
    if ($ancestryExit -eq 1) {
        return [ordered]@{ State = 'Stale'; Detail = "the reviewed head $ReviewedHead is not an ancestor of the live head $LiveHead." }
    }
    if ($ancestryExit -ne 0) {
        return [ordered]@{ State = 'Unresolved'; Detail = "git merge-base could not compare the reviewed head $ReviewedHead with the live head $LiveHead; fetch the pull request head, then retry. This hook does not fetch." }
    }

    if (-not (Test-EpicMergeGateReviewFeatureFolder -Value $FeatureFolder)) {
        return [ordered]@{ State = 'Unresolved'; Detail = 'the checkpoint feature-folder value is not a clean path below docs/features/.' }
    }

    $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $GitRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', $ReviewedHead, $LiveHead)
    if ($null -eq $diff -or $diff.ExitCode -ne 0) {
        return [ordered]@{ State = 'Unresolved'; Detail = "git diff of the reviewed head $ReviewedHead and the live head $LiveHead could not be computed." }
    }
    $listing = [string]$diff.Output
    if ($listing.Length -gt 0 -and -not $listing.EndsWith([char]0)) {
        return [ordered]@{ State = 'Unresolved'; Detail = 'git diff did not return NUL-terminated output.' }
    }

    foreach ($path in @(ConvertFrom-DocsOnlyNameList -Text $listing)) {
        if (-not (Test-EpicMergeGateReviewPathInFolder -Path $path -FeatureFolder $FeatureFolder)) {
            return [ordered]@{ State = 'Stale'; Detail = "the path $path changed after the reviewed head $ReviewedHead and lies outside $FeatureFolder." }
        }
    }
    return [ordered]@{ State = 'Current'; Detail = 'only feature-folder paths changed after the reviewed head.' }
}

function Get-EpicMergeGateReviewDecision {
    <#
    .SYNOPSIS
        Evaluate the review guard for one merge command and return Denied and Reason.
    .DESCRIPTION
        Applies steps 1 to 5 of the file header and delegates steps 6 to 12 to
        Get-EpicMergeGateReviewHeadState. Every deny reason reads
        EPIC_MERGE_GATE_BLOCKED: <code>: <message>. Without the key it returns immediately and
        starts no process.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint, or $null.
    .PARAMETER CommandPrNumber
        The explicit PR number the command names, or $null for a bare command.
    .PARAMETER GhRoot
        The directory gh runs in.
    .PARAMETER GitRoot
        The directory git runs in.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Denied and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot,
        [AllowNull()][AllowEmptyString()][string] $GitRoot
    )

    $pass = [ordered]@{ Denied = $false; Reason = $null }
    if (-not (Test-EpicMergeGateReviewModeConcurrent -Checkpoint $Checkpoint)) { return $pass }

    if ($null -eq $CommandPrNumber) {
        return [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: review_mode concurrent requires a merge command that names the pull request number.' }
    }

    $outcome = Get-EpicMergeGateLastReviewOutcome -Checkpoint $Checkpoint
    if ($null -eq $outcome -or $outcome.verdict -isnot [string] -or $outcome.verdict -cne 'PASS') {
        return [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: review_mode concurrent requires a last review_outcomes entry with verdict PASS.' }
    }
    if (-not (Test-EpicMergeGateReviewObjectId -Value $outcome.head_sha)) {
        return [ordered]@{ Denied = $true; Reason = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: review_mode concurrent requires a full lowercase head_sha on the last review_outcomes entry.' }
    }

    $liveHead = Get-EpicMergeGateReviewLiveHeadSha -PrNumber $CommandPrNumber -WorktreeRoot $GhRoot
    if ($null -eq $liveHead) {
        return [ordered]@{ Denied = $true; Reason = "EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: the live head of pull request $CommandPrNumber could not be read." }
    }

    $headState = Get-EpicMergeGateReviewHeadState -ReviewedHead ([string]$outcome.head_sha) -LiveHead $liveHead -FeatureFolder $Checkpoint.'feature-folder' -GitRoot $GitRoot
    if ($headState.State -ceq 'Current') { return $pass }
    $code = if ($headState.State -ceq 'Stale') { 'REVIEW_GATE_HEAD_STALE' } else { 'REVIEW_GATE_HEAD_UNRESOLVED' }
    return [ordered]@{ Denied = $true; Reason = "EPIC_MERGE_GATE_BLOCKED: ${code}: $($headState.Detail)" }
}
