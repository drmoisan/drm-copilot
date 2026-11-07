<#
.SYNOPSIS
    Step derivation functions for Get-EpicProgressReport.ps1: item, remediation-cycle, and epic-level steps.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. A step record holds Issue, Type, Cycle
    (0 for the initial run), Ordinal, Status (done, in_progress, remaining, or blocked), Key,
    and StartedUnixSeconds (the start of an in-progress step when recorded). The rules follow
    the step model of the epic-progress-report skill. Get-EpicProgressReport.Logic.ps1
    dot-sources this file, so a consumer dot-sources the Logic hub, not this file.
#>

function Get-EpicProgressPlanTask {
    <#
    .SYNOPSIS
        Return one record (Id, Done) per '- [ ] [P#-T#]' or '- [x] [P#-T#]' checkbox of a plan text, in file order.
    .PARAMETER PlanText
        The plan, remediation-plan, or light remediation-inputs text.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $PlanText)

    if ([string]::IsNullOrEmpty($PlanText)) { return }
    foreach ($taskMatch in [regex]::Matches($PlanText, '(?m)^\s*- \[( |x)\] \[(P\d+-T\d+)\]')) {
        [pscustomobject]@{ Id = $taskMatch.Groups[2].Value; Done = ($taskMatch.Groups[1].Value -eq 'x') }
    }
}

function Get-EpicProgressStepRecord {
    <#
    .SYNOPSIS
        Return one step record built from the given values.
    .PARAMETER Issue
        The issue number of the item (or of the epic for an epic-level step).
    .PARAMETER Type
        The step type.
    .PARAMETER Cycle
        0 for the initial run, n for remediation cycle n.
    .PARAMETER Ordinal
        The 1-based position of the step among steps of the same type and cycle.
    .PARAMETER Status
        done, in_progress, remaining, or blocked.
    .PARAMETER Key
        The step key; blank for the default '<issue>|<type>|c<cycle>|<ordinal>'.
    .PARAMETER StartedUnixSeconds
        The recorded start of an in-progress step; null when not recorded.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [string] $Type,
        [int] $Cycle = 0,
        [int] $Ordinal = 1,
        [string] $Status = 'remaining',
        [string] $Key = '',
        [AllowNull()] [object] $StartedUnixSeconds = $null
    )

    if (-not $Key) { $Key = "$Issue|$Type|c$Cycle|$Ordinal" }
    return [pscustomobject]@{ Issue = $Issue; Type = $Type; Cycle = $Cycle; Ordinal = $Ordinal; Status = $Status; Key = $Key; StartedUnixSeconds = $StartedUnixSeconds }
}

function Test-EpicProgressCompletedStep {
    <#
    .SYNOPSIS
        Return whether a checkpoint's completed_steps holds an entry that starts with the given canonical prefix.
    .PARAMETER Checkpoint
        The parsed item checkpoint; null returns $false.
    .PARAMETER Prefix
        The canonical step prefix, for example S2_research.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Checkpoint,
        [Parameter(Mandatory = $true)] [string] $Prefix
    )

    if ($null -eq $Checkpoint) { return $false }
    return [bool] @(@($Checkpoint.completed_steps) | Where-Object { "$_" -like "$Prefix*" }).Count
}

function Get-EpicProgressCycleStep {
    <#
    .SYNOPSIS
        Return the steps added by each opened remediation_loop.cycles entry of an item checkpoint.
    .DESCRIPTION
        Each cycle adds a plan and a preflight step unless its remediation_path is 'light' (a
        missing key is full), one execution step per task in the file named by its plan_path,
        one review step (the re-audit), and one ci step when the cycle opened after a PR
        existed: a recorded pr stage started at or before the cycle entry_timestamp, or, with
        no such times, step9_status 'failed_remediation_required'. Cycles not yet opened are not
        predicted. A step of an earlier cycle is done once a later cycle exists; otherwise plan
        is done when its text is present, preflight when final_status is recorded or a task is
        checked, review when review_outcomes holds an entry for the cycle, and ci when
        step9_status is 'passed'.
    .PARAMETER Issue
        The item issue number.
    .PARAMETER Checkpoint
        The parsed item checkpoint; null gives no steps.
    .PARAMETER CycleText
        The cycle plan texts keyed by plan_path.
    .PARAMETER StageRecord
        The records from ConvertFrom-EpicProgressStageTiming.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Checkpoint,
        [hashtable] $CycleText = @{},
        [AllowEmptyCollection()] [object[]] $StageRecord = @()
    )

    if ($null -eq $Checkpoint -or $null -eq $Checkpoint.remediation_loop) { return }
    $cycles = @(@($Checkpoint.remediation_loop.cycles) | Where-Object { $null -ne $_ })
    $outcomeCount = @(@($Checkpoint.remediation_loop.review_outcomes) | Where-Object { $null -ne $_ }).Count
    $prRecord = @($StageRecord | Where-Object { $_.Type -eq 'pr' } | Sort-Object -Property StartedUnixSeconds) | Select-Object -First 1
    $ciPassed = [string] $Checkpoint.step9_status -eq 'passed'
    for ($index = 0; $index -lt $cycles.Count; $index++) {
        $cycle = $cycles[$index]
        $number = $index + 1
        $later = $number -lt $cycles.Count
        $planPath = [string] $cycle.plan_path
        $text = ''
        if ($planPath -and $CycleText.ContainsKey($planPath)) { $text = [string] $CycleText[$planPath] }
        $tasks = @(Get-EpicProgressPlanTask -PlanText $text)
        $anyChecked = @($tasks | Where-Object { $_.Done }).Count -gt 0
        if ([string] $cycle.remediation_path -ne 'light') {
            $planDone = $later -or -not [string]::IsNullOrWhiteSpace($text)
            $preflightDone = $later -or $anyChecked -or -not [string]::IsNullOrWhiteSpace([string] $cycle.preflight.final_status)
            Get-EpicProgressStepRecord -Issue $Issue -Type 'plan' -Cycle $number -Status $(if ($planDone) { 'done' } else { 'remaining' })
            Get-EpicProgressStepRecord -Issue $Issue -Type 'preflight' -Cycle $number -Status $(if ($preflightDone) { 'done' } else { 'remaining' })
        }
        $planFile = ($planPath -split '[\\/]')[-1]
        $ordinal = 0
        foreach ($task in $tasks) {
            $ordinal++
            Get-EpicProgressStepRecord -Issue $Issue -Type 'execution' -Cycle $number -Ordinal $ordinal -Status $(if ($task.Done) { 'done' } else { 'remaining' }) -Key "$Issue|exec|$planFile|$($task.Id)"
        }
        $reviewDone = $later -or $outcomeCount -ge ($number + 1)
        Get-EpicProgressStepRecord -Issue $Issue -Type 'review' -Cycle $number -Status $(if ($reviewDone) { 'done' } else { 'remaining' })
        $entry = ConvertTo-EpicProgressUnixSecond -Value $cycle.entry_timestamp
        $afterPr = [string] $Checkpoint.step9_status -eq 'failed_remediation_required'
        if ($null -ne $prRecord -and $null -ne $entry) { $afterPr = $prRecord.StartedUnixSeconds -le $entry }
        if ($afterPr) {
            Get-EpicProgressStepRecord -Issue $Issue -Type 'ci' -Cycle $number -Status $(if ($later -or $ciPassed) { 'done' } else { 'remaining' })
        }
    }
}

function Get-EpicProgressItemStep {
    <#
    .SYNOPSIS
        Return the step records of one item from its checkpoint, plan text, cycles, and epic state.
    .DESCRIPTION
        The initial run has one step of each item type and one execution step per plan task.
        A type with recorded stage_timing attempts counts one step per attempt (decision D4),
        less the steps of that type that the remediation cycles add; a closed attempt is done
        and the open attempt is in progress. A type without attempts falls back to the
        checkpoint: research on S2_research, spec on S3_promotion with spec.md present, plan on
        S4_atomic_planning, preflight on a checked task or a step5_status past pending, review
        on S7_feature_review or a review outcome, pr on S8_create_pr, pr_gate.pr_number, or a
        pull request, and ci on step9_status 'passed'. Merge is done when the item is merged.
        Without an open stage the next_step value marks the in-progress step. An item without
        a checkpoint whose plan is already prepared counts research, spec, and plan as done
        (decision D6); a merged item has every step done; a blocked item turns every step that
        is not done to blocked.
    .PARAMETER Item
        The item record: Issue, Checkpoint, PlanText, PlanFile, CycleText, SpecExists,
        MergeStatus, PrState, PreparedPlan, and Blockage (Blocked, Reason).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Item)

    $issue = [string] $Item.Issue
    $checkpoint = $Item.Checkpoint
    $records = @()
    if ($null -ne $checkpoint) { $records = @(ConvertFrom-EpicProgressStageTiming -StageTiming @($checkpoint.stage_timing)) }
    $tasks = @(Get-EpicProgressPlanTask -PlanText ([string] $Item.PlanText))
    $taskDone = @($tasks | Where-Object { $_.Done }).Count
    $cycleSteps = @(Get-EpicProgressCycleStep -Issue $issue -Checkpoint $checkpoint -CycleText $(if ($Item.CycleText) { $Item.CycleText } else { @{} }) -StageRecord $records)
    $merged = ([string] $Item.MergeStatus -in @('merged', 'worktree_removed')) -or ([string] $Item.PrState -match 'MERGED')
    $prepared = ($null -eq $checkpoint) -and [bool] $Item.PreparedPlan
    $step5 = [string] $checkpoint.step5_status
    $fallback = @{
        research  = $prepared -or (Test-EpicProgressCompletedStep -Checkpoint $checkpoint -Prefix 'S2_research')
        spec      = $prepared -or ((Test-EpicProgressCompletedStep -Checkpoint $checkpoint -Prefix 'S3_promotion') -and [bool] $Item.SpecExists)
        plan      = $prepared -or (Test-EpicProgressCompletedStep -Checkpoint $checkpoint -Prefix 'S4_atomic_planning')
        preflight = ($taskDone -gt 0) -or ($step5 -in @('delegated', 'verified', 'in_progress', 'completed'))
        review    = (Test-EpicProgressCompletedStep -Checkpoint $checkpoint -Prefix 'S7_feature_review') -or (@(@($checkpoint.remediation_loop.review_outcomes) | Where-Object { $null -ne $_ }).Count -gt 0)
        pr        = (Test-EpicProgressCompletedStep -Checkpoint $checkpoint -Prefix 'S8_create_pr') -or ($null -ne $checkpoint.pr_gate.pr_number) -or -not [string]::IsNullOrWhiteSpace([string] $Item.PrState)
        ci        = [string] $checkpoint.step9_status -eq 'passed'
    }

    $steps = [System.Collections.Generic.List[object]]::new()
    $addTimed = {
        param([string] $Type)
        $typed = @($records | Where-Object { $_.Type -eq $Type } | Sort-Object -Property Attempt)
        $count = [math]::Max(1, $typed.Count - @($cycleSteps | Where-Object { $_.Type -eq $Type }).Count)
        for ($ordinal = 1; $ordinal -le $count; $ordinal++) {
            $status = 'remaining'
            $started = $null
            if ($typed.Count -gt 0) {
                $record = $typed[$ordinal - 1]
                if ($null -ne $record.EndedUnixSeconds) { $status = 'done' } else { $status = 'in_progress'; $started = $record.StartedUnixSeconds }
            } elseif ($fallback[$Type]) {
                $status = 'done'
            }
            $steps.Add((Get-EpicProgressStepRecord -Issue $issue -Type $Type -Ordinal $ordinal -Status $status -StartedUnixSeconds $started))
        }
    }
    foreach ($type in @('research', 'spec', 'plan', 'preflight')) { & $addTimed $type }
    $openExecution = @($records | Where-Object { $_.Type -eq 'execution' -and $null -eq $_.EndedUnixSeconds }) | Select-Object -First 1
    $ordinal = 0
    foreach ($task in $tasks) {
        $ordinal++
        $status = 'remaining'
        $started = $null
        if ($task.Done) { $status = 'done' }
        $steps.Add((Get-EpicProgressStepRecord -Issue $issue -Type 'execution' -Ordinal $ordinal -Status $status -Key "$issue|exec|$($Item.PlanFile)|$($task.Id)" -StartedUnixSeconds $started))
    }
    if ($null -ne $openExecution) {
        $firstOpen = @($steps | Where-Object { $_.Type -eq 'execution' -and $_.Status -eq 'remaining' }) | Select-Object -First 1
        if ($null -ne $firstOpen) { $firstOpen.Status = 'in_progress'; $firstOpen.StartedUnixSeconds = $openExecution.StartedUnixSeconds }
    }
    foreach ($type in @('review', 'pr', 'ci')) { & $addTimed $type }
    $steps.Add((Get-EpicProgressStepRecord -Issue $issue -Type 'merge' -Status $(if ($merged) { 'done' } else { 'remaining' })))
    foreach ($cycleStep in $cycleSteps) { $steps.Add($cycleStep) }

    $hasOpen = @($steps | Where-Object { $_.Status -eq 'in_progress' }).Count -gt 0
    $nextStep = [string] $checkpoint.next_step
    if (-not $hasOpen -and $nextStep) {
        $nextType = ''
        $nextCycle = -1
        $remediation = [regex]::Match($nextStep, '^remediation\.cycle_(\d+)\.(plan|preflight|execute|reaudit)')
        if ($remediation.Success) {
            $nextCycle = [int] $remediation.Groups[1].Value
            $nextType = @{ plan = 'plan'; preflight = 'preflight'; execute = 'execution'; reaudit = 'review' }[$remediation.Groups[2].Value]
        } else {
            $prefixType = [ordered]@{ S2_research = 'research'; S3_promotion = 'spec'; S4_atomic_planning = 'plan'; S5_atomic_execution = 'execution'; S7_feature_review = 'review'; S8_create_pr = 'pr'; S9 = 'ci' }
            foreach ($prefix in $prefixType.Keys) { if ($nextStep -like "$prefix*") { $nextType = $prefixType[$prefix]; break } }
        }
        $target = @($steps | Where-Object { $_.Type -eq $nextType -and $_.Status -eq 'remaining' -and ($nextCycle -lt 0 -or $_.Cycle -eq $nextCycle) }) | Select-Object -First 1
        if ($null -ne $target) { $target.Status = 'in_progress' }
    }

    foreach ($step in $steps) {
        if ($merged) {
            $step.Status = 'done'
            $step.StartedUnixSeconds = $null
        } elseif ($Item.Blockage -and $Item.Blockage.Blocked -and $step.Status -ne 'done') {
            $step.Status = 'blocked'
        }
    }
    return $steps.ToArray()
}

function Get-EpicProgressEpicStep {
    <#
    .SYNOPSIS
        Return the epic-level steps: one main-sync step per sync row and one integration-pr step.
    .DESCRIPTION
        A sync row is an epic checkpoint features row whose issue_num is not in the kickoff
        table (decision D11: syncs are counted only once recorded). It is done when its merge
        status is 'merged' or 'worktree_removed', blocked at 'blocked_conflict_loop_limit', in
        progress at any other status except 'not_started' (started at worktree_created_at), and
        otherwise remaining. The integration-pr step is done when
        epic_merge_pr.merge_commit_sha is present, in progress when epic_merge_pr exists, and
        otherwise remaining.
    .PARAMETER Checkpoint
        The parsed epic checkpoint; null when the epic has none.
    .PARAMETER KickoffIssue
        The issue numbers of the kickoff feature rows.
    .PARAMETER EpicIssue
        The epic issue number.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Checkpoint,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $KickoffIssue,
        [Parameter(Mandatory = $true)] [string] $EpicIssue
    )

    $mergePr = $null
    if ($null -ne $Checkpoint) {
        $mergePr = $Checkpoint.epic_merge_pr
        foreach ($row in @(@($Checkpoint.features) | Where-Object { $null -ne $_ -and $null -ne $_.issue_num })) {
            $rowIssue = [string] $row.issue_num
            if ($KickoffIssue -contains $rowIssue) { continue }
            $mergeStatus = [string] $row.merge_status
            $created = ConvertTo-EpicProgressUnixSecond -Value $row.worktree_created_at
            $status = 'remaining'
            $started = $null
            if ($mergeStatus -in @('merged', 'worktree_removed')) {
                $status = 'done'
            } elseif ($mergeStatus -eq 'blocked_conflict_loop_limit') {
                $status = 'blocked'
                $started = $created
            } elseif ($mergeStatus -and $mergeStatus -ne 'not_started') {
                $status = 'in_progress'
                $started = $created
            }
            Get-EpicProgressStepRecord -Issue $rowIssue -Type 'main-sync' -Status $status -Key "$EpicIssue|main-sync|$rowIssue|$created" -StartedUnixSeconds $started
        }
    }
    $prStatus = 'remaining'
    if ($null -ne $mergePr) {
        $prStatus = 'in_progress'
        if (-not [string]::IsNullOrWhiteSpace([string] $mergePr.merge_commit_sha)) { $prStatus = 'done' }
    }
    Get-EpicProgressStepRecord -Issue $EpicIssue -Type 'integration-pr' -Status $prStatus
}

function Get-EpicProgressStepCount {
    <#
    .SYNOPSIS
        Return Done, Total, and Percent (done steps over all steps; decision D8) of a step list.
    .PARAMETER Step
        The step records.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Step)

    $done = @($Step | Where-Object { $_.Status -eq 'done' }).Count
    return [pscustomobject]@{ Done = $done; Total = $Step.Count; Percent = 100.0 * $done / [math]::Max(1, $Step.Count) }
}
