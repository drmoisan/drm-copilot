<#
.SYNOPSIS
    Epic-child CI verification for the epic merge gates (issue #1130).

.DESCRIPTION
    Dot-sourced by .claude/hooks/enforce-epic-merge-gate.ps1 and .codex/hooks/enforce-epic-merge-gate.ps1;
    the two copies are byte-identical. The child branch of each gate allows an epic-child merge only when
    its existing checkpoint predicates hold and Get-EpicMergeGateChildCiDecision returns Verified. The
    decision evaluates six stages in order, cheapest first, and the first failure denies:

      1. PR number: the command's explicit number, else the JSON-integer pr_gate.pr_number; when both
         are present they must match; when neither is present, deny.
      2. ci_gate.conclusion equals "success" and ci_gate.head_sha is a lowercase 40- or 64-character
         object id.
      3. One bounded gh pr view <PR> --json headRefOid; the live head must equal ci_gate.head_sha.
      4. One bounded gh run list --commit <head> --limit 100; the runs are filtered to workflowName "CI"
         and headSha equal to the head, and the newest by createdAt is selected. No match denies.
      5. The selected run's event is pull_request or workflow_dispatch, its status is completed, and its
         conclusion is success. A push-event run is not accepted.
      6. For workflow_dispatch, the run's databaseId equals ci_gate.dispatch_run_id.

    Every failure returns Verified = $false with a Reason that begins
    "EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: ". A failed, timed-out, or unparseable gh
    result denies. The file dot-sources nothing: the bounded gh wrapper comes from hook-docs-only-diff.ps1,
    which both gates load, and it is called only inside the two seams below. The helper never throws
    and invokes no Python. The required workflow name CI is a stated assumption. A push after the
    live-head lookup can change the head; like the rest of the gate this is a policy-level control.
#>

$script:EpicMergeGateChildCiReasonPrefix = 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: '

function Test-EpicMergeGateChildCiObjectId {
    <#
    .SYNOPSIS
        Report whether a value is a lowercase 40- or 64-character hexadecimal object id.
    .PARAMETER Value
        The candidate value, of any type.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [string] -and $Value -cmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$')
}

function Test-EpicMergeGateChildCiPositiveInteger {
    <#
    .SYNOPSIS
        Report whether a parsed JSON value is an integer greater than zero; a digit string fails.
    .PARAMETER Value
        The candidate value, of any type.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return (($Value -is [int] -or $Value -is [long]) -and $Value -gt 0)
}

function Get-EpicMergeGateChildCiProperty {
    <#
    .SYNOPSIS
        Read a named property off a parsed JSON object, or $null when the value is not an object or lacks it.
    .PARAMETER InputObject
        The parsed value.
    .PARAMETER Name
        The property name.
    .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()] $InputObject, [Parameter(Mandatory)][string] $Name)

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return , $property.Value
}

function Get-EpicMergeGateChildCiPrNumber {
    <#
    .SYNOPSIS
        Resolve the pull-request number for stage 1, or a failure detail.
    .DESCRIPTION
        A present pr_gate.pr_number must be a positive JSON integer. The command's explicit number wins
        when present and must equal a recorded number; otherwise the recorded number is used.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .PARAMETER CommandPrNumber
        The explicit PR number of the command, or $null for a bare command.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with PrNumber and Detail.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] $Checkpoint, [AllowNull()][Nullable[int]] $CommandPrNumber)

    $prGate = Get-EpicMergeGateChildCiProperty -InputObject $Checkpoint -Name 'pr_gate'
    $recorded = $null
    if ($null -ne $prGate) {
        $recordedValue = Get-EpicMergeGateChildCiProperty -InputObject $prGate -Name 'pr_number'
        if ($null -ne $recordedValue) {
            if (-not (Test-EpicMergeGateChildCiPositiveInteger -Value $recordedValue)) {
                return [ordered]@{ PrNumber = $null; Detail = 'pr_gate.pr_number is not a positive JSON integer.' }
            }
            $recorded = [int]$recordedValue
        }
    }
    if ($null -ne $CommandPrNumber) {
        if ($null -ne $recorded -and $recorded -ne $CommandPrNumber) {
            return [ordered]@{ PrNumber = $null; Detail = "the command names pull request $CommandPrNumber but pr_gate.pr_number records $recorded." }
        }
        return [ordered]@{ PrNumber = [int]$CommandPrNumber; Detail = $null }
    }
    if ($null -eq $recorded) {
        return [ordered]@{ PrNumber = $null; Detail = 'the command names no pull request and the checkpoint records no pr_gate.pr_number.' }
    }
    return [ordered]@{ PrNumber = $recorded; Detail = $null }
}

function Get-EpicMergeGateChildCiLiveHeadSha {
    <#
    .SYNOPSIS
        Return the live head commit of a pull request, or $null on any failure (the live-head seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh pr view <PR> --json headRefOid. A non-zero exit,
        output that does not parse to a JSON object, and a malformed head all return $null.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][int] $PrNumber, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr', 'view', [string]$PrNumber, '--json', 'headRefOid')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $pr = ConvertFrom-Json -InputObject ([string]$lookup.Output) -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the decision fails closed on $null.
        return $null
    }
    $head = Get-EpicMergeGateChildCiProperty -InputObject $pr -Name 'headRefOid'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $head)) { return $null }
    return [string]$head
}

function Get-EpicMergeGateChildCiRunList {
    <#
    .SYNOPSIS
        Return the workflow runs recorded for a commit as an array, or $null on any failure (the run-list seam).
    .DESCRIPTION
        Makes exactly one Invoke-DocsOnlyGhExe call, gh run list --commit <head> --limit 100 with the JSON
        fields databaseId, event, status, conclusion, headSha, workflowName, and createdAt. A non-zero
        exit, unparseable output, and output that is not a JSON array return $null.
    .PARAMETER HeadSha
        The commit whose runs are listed.
    .PARAMETER WorktreeRoot
        The directory gh runs in.
    .OUTPUTS
        System.Object[] or $null
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)][string] $HeadSha, [AllowNull()][AllowEmptyString()][string] $WorktreeRoot)

    $lookup = Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('run', 'list', '--commit', $HeadSha, '--limit', '100', '--json', 'databaseId,event,status,conclusion,headSha,workflowName,createdAt')
    if ($null -eq $lookup -or $lookup.ExitCode -ne 0) { return $null }
    try {
        $runs = ConvertFrom-Json -InputObject ([string]$lookup.Output) -NoEnumerate -ErrorAction Stop
    } catch {
        # Unreadable gh output is a lookup failure; the decision fails closed on $null.
        return $null
    }
    if ($runs -isnot [System.Array]) { return $null }
    return , $runs
}

function Select-EpicMergeGateChildCiRun {
    <#
    .SYNOPSIS
        Select the newest run of the workflow named CI on the given head, or $null when none qualifies.
    .DESCRIPTION
        Considers only object entries whose workflowName is exactly CI and whose headSha equals the head.
        The newest is chosen by createdAt, then by databaseId. A matching entry whose createdAt cannot be
        read makes the selection fail, because its order relative to the others is unknown.
    .PARAMETER Runs
        The parsed run list.
    .PARAMETER HeadSha
        The verified head commit.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param([AllowNull()][AllowEmptyCollection()][object[]] $Runs, [Parameter(Mandatory)][string] $HeadSha)

    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($run in @($Runs)) {
        if ([string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'workflowName') -cne 'CI') { continue }
        if ([string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'headSha') -cne $HeadSha) { continue }
        $created = Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'createdAt'
        $stamp = [DateTimeOffset]::MinValue
        if ($created -is [DateTime]) {
            $stamp = [DateTimeOffset]::new($created.ToUniversalTime())
        } elseif (-not ($created -is [string] -and [DateTimeOffset]::TryParse($created, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal, [ref] $stamp))) {
            return $null
        }
        $id = Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'databaseId'
        $candidates.Add([pscustomobject]@{ Stamp = $stamp; Id = $(if (Test-EpicMergeGateChildCiPositiveInteger -Value $id) { [long]$id } else { [long]0 }); Run = $run })
    }
    if ($candidates.Count -eq 0) { return $null }
    $newest = $candidates | Sort-Object -Property @{ Expression = 'Stamp'; Descending = $true }, @{ Expression = 'Id'; Descending = $true } | Select-Object -First 1
    return $newest.Run
}

function Get-EpicMergeGateChildCiDecision {
    <#
    .SYNOPSIS
        Verify a green CI run on the live head of an epic child's pull request (stages 1 to 6).
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .PARAMETER CommandPrNumber
        The explicit PR number of the command, or $null for a bare command.
    .PARAMETER GhRoot
        The directory gh runs in: the session root on Claude, the repository root on Codex.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Verified and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][Nullable[int]] $CommandPrNumber,
        [AllowNull()][AllowEmptyString()][string] $GhRoot
    )

    try {
        $detail = Get-EpicMergeGateChildCiFailureDetail -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber -GhRoot $GhRoot
    } catch {
        # The helper never throws: an unexpected error denies with its message (fail closed).
        $detail = 'verification failed with an error: ' + $_.Exception.Message
    }
    if ($null -eq $detail) { return [ordered]@{ Verified = $true; Reason = '' } }
    return [ordered]@{ Verified = $false; Reason = $script:EpicMergeGateChildCiReasonPrefix + $detail }
}

function Get-EpicMergeGateChildCiFailureDetail {
    <#
    .SYNOPSIS
        Evaluate stages 1 to 6 in order and return the first failure detail, or $null when all pass.
    .PARAMETER Checkpoint
        The parsed child checkpoint.
    .PARAMETER CommandPrNumber
        The explicit PR number of the command, or $null for a bare command.
    .PARAMETER GhRoot
        The directory gh runs in.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] $Checkpoint, [AllowNull()][Nullable[int]] $CommandPrNumber, [AllowNull()][AllowEmptyString()][string] $GhRoot)

    $pr = Get-EpicMergeGateChildCiPrNumber -Checkpoint $Checkpoint -CommandPrNumber $CommandPrNumber
    if ($null -eq $pr.PrNumber) { return 'stage 1 (PR number): ' + $pr.Detail }

    $ciGate = Get-EpicMergeGateChildCiProperty -InputObject $Checkpoint -Name 'ci_gate'
    if ($null -eq $ciGate -or [string](Get-EpicMergeGateChildCiProperty -InputObject $ciGate -Name 'conclusion') -cne 'success') {
        return 'stage 2 (ci_gate): the checkpoint records no ci_gate with conclusion "success" for the child head.'
    }
    $head = Get-EpicMergeGateChildCiProperty -InputObject $ciGate -Name 'head_sha'
    if (-not (Test-EpicMergeGateChildCiObjectId -Value $head)) {
        return 'stage 2 (ci_gate): ci_gate.head_sha is not a lowercase 40- or 64-character object id.'
    }

    $liveHead = Get-EpicMergeGateChildCiLiveHeadSha -PrNumber $pr.PrNumber -WorktreeRoot $GhRoot
    if ($null -eq $liveHead) { return "stage 3 (live head): the live head of pull request $($pr.PrNumber) could not be resolved." }
    if ($liveHead -cne $head) { return "stage 3 (live head): the live head $liveHead differs from ci_gate.head_sha $head." }

    $runs = Get-EpicMergeGateChildCiRunList -HeadSha $head -WorktreeRoot $GhRoot
    if ($null -eq $runs) { return "stage 4 (run list): the workflow runs for $head could not be listed." }
    $run = Select-EpicMergeGateChildCiRun -Runs $runs -HeadSha $head
    if ($null -eq $run) { return "stage 4 (run list): no run of the workflow named CI exists on $head." }

    $runEvent = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'event')
    if (@('pull_request', 'workflow_dispatch') -cnotcontains $runEvent) {
        return "stage 5 (run result): the newest CI run on $head has event '$runEvent'; only pull_request or workflow_dispatch is accepted."
    }
    $status = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'status')
    $conclusion = [string](Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'conclusion')
    if ($status -cne 'completed' -or $conclusion -cne 'success') {
        return "stage 5 (run result): the newest CI run on $head has status '$status' and conclusion '$conclusion'."
    }

    if ($runEvent -ceq 'workflow_dispatch') {
        $recordedId = Get-EpicMergeGateChildCiProperty -InputObject $ciGate -Name 'dispatch_run_id'
        $runId = Get-EpicMergeGateChildCiProperty -InputObject $run -Name 'databaseId'
        if (-not (Test-EpicMergeGateChildCiPositiveInteger -Value $recordedId) -or
            -not (Test-EpicMergeGateChildCiPositiveInteger -Value $runId) -or
            [long]$recordedId -ne [long]$runId) {
            return "stage 6 (dispatch run): the workflow_dispatch run $runId is not the run recorded in ci_gate.dispatch_run_id."
        }
    }
    return $null
}
