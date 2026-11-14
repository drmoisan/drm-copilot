<#
.SYNOPSIS
    Critical-path report functions for Get-EpicProgressReport.ps1: critical chain, epic tail, feature remaining time, range, and the report composition.

.DESCRIPTION
    Pure, host-neutral functions (issue #1153, decisions E4 to E9): each takes data in and
    returns data, and none reads a file, starts a process, calls the network, calls an I/O
    seam, or reads the clock, and the file imports nothing. The functions compose the
    dependency graph, parallel cap, and list schedule of Get-EpicProgressReport.Schedule.ps1
    with the velocity functions of Get-EpicProgressReport.Velocity.ps1 into the critical-path
    record. Get-EpicProgressReport.Logic.ps1 dot-sources this file after the Schedule file, so
    a consumer dot-sources the Logic hub, not this file.
#>

function Get-EpicProgressCriticalChain {
    <#
    .SYNOPSIS
        Return the critical chain text '#a -> #b -> tail', walking back from the latest-finishing node through each start's delaying predecessor (decision E6).
    .PARAMETER Schedule
        The result of Invoke-EpicProgressListSchedule.
    .PARAMETER NoTail
        Omit the trailing 'tail' (item mode).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [pscustomobject] $Schedule,
        [switch] $NoTail
    )

    $byIssue = @{}
    foreach ($row in $Schedule.Feature) { $byIssue[[string] $row.Issue] = $row }
    $chain = [System.Collections.Generic.List[string]]::new()
    $current = $Schedule.LastIssue
    while ($null -ne $current -and $byIssue.ContainsKey([string] $current) -and $chain.Count -lt $byIssue.Count) {
        # An external node '<epic>#<issue>' prints as is, without the leading '#' (issue #1162).
        $label = "#$current"
        if ([string] $current -like '*#*') { $label = [string] $current }
        $chain.Insert(0, $label)
        $current = $byIssue[[string] $current].Predecessor
    }
    if (-not $NoTail) { $chain.Add('tail') }
    return ($chain -join ' -> ')
}

function Get-EpicProgressEpicTail {
    <#
    .SYNOPSIS
        Return TailSeconds, PredictedSync, and Step rows (Type, Seconds) of the epic tail after the last feature finishes (decision E8).
    .DESCRIPTION
        The tail is the not-done main-sync rows, the integration-pr step, and one predicted
        main-sync step, each timed by Get-EpicProgressTypeEstimate (ledger median, else the
        default; in-progress credit max(0, median - elapsed)). The predicted sync is omitted
        when a recorded sync row that is not done exists and when integration-pr is in
        progress or done; when integration-pr is done the tail is 0. The step list passed in is
        not changed, so the step total and percentage are unchanged.
    .PARAMETER EpicStep
        The epic-level steps from Get-EpicProgressEpicStep.
    .PARAMETER Ledger
        The duration ledger.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $EpicStep,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds
    )

    $integration = @($EpicStep | Where-Object { $null -ne $_ -and $_.Type -eq 'integration-pr' }) | Select-Object -First 1
    if ($null -eq $integration) { $integration = Get-EpicProgressStepRecord -Issue 'tail' -Type 'integration-pr' }
    if ($integration.Status -eq 'done') { return [pscustomobject]@{ TailSeconds = 0.0; PredictedSync = $false; Step = [object[]] @() } }
    $openSync = @($EpicStep | Where-Object { $null -ne $_ -and $_.Type -eq 'main-sync' -and $_.Status -ne 'done' })
    $predicted = $openSync.Count -eq 0 -and $integration.Status -eq 'remaining'
    $tailSteps = @($openSync) + @($integration)
    if ($predicted) { $tailSteps += Get-EpicProgressStepRecord -Issue 'tail' -Type 'main-sync' -Key 'tail|main-sync|predicted' }
    $estimate = Get-EpicProgressTypeEstimate -Step $tailSteps -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds
    $rows = @($estimate.Type | ForEach-Object { [pscustomobject]@{ Type = $_.Type; Seconds = $_.SubtotalSeconds } })
    return [pscustomobject]@{ TailSeconds = [double] $estimate.TotalSeconds; PredictedSync = $predicted; Step = [object[]] $rows }
}

function Get-EpicProgressFeatureRemainingSecond {
    <#
    .SYNOPSIS
        Return a feature's remaining seconds at a sequential rate: execution tasks at 3600 / rate, other steps at their median (decision E4).
    .DESCRIPTION
        A rate that is not a finite number above 0 prices each remaining execution task at
        infinity. Blocked steps are left out, as in Get-EpicProgressTypeEstimate.
    .PARAMETER Step
        The feature's step records.
    .PARAMETER Rate
        The sequential rate in tasks per hour.
    .PARAMETER Ledger
        The duration ledger.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER BlockedSince
        The start of each blocked item's span, keyed by issue; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Step,
        [Parameter(Mandatory = $true)] [double] $Rate,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [hashtable] $BlockedSince = @{}
    )

    $perTask = [double]::PositiveInfinity
    if ([double]::IsFinite($Rate) -and $Rate -gt 0) { $perTask = 3600.0 / $Rate }
    return Get-EpicProgressTypeEstimate -Step $Step -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -BlockedSince $BlockedSince -MedianOverride @{ execution = $perTask }
}

function Get-EpicProgressScheduleRange {
    <#
    .SYNOPSIS
        Return the range (FastSeconds, SlowSeconds, NoUpperBound, StandardDeviation, SdSource, Reason) by re-running the schedule at rate +/- 2.05 SD (decision E9).
    .DESCRIPTION
        SD is the across-feature SD when at least 2 features qualify, else the aggregate
        interval SD when at least 3 intervals exist; otherwise both ends are NaN and Reason
        states why. The slow end is infinite with NoUpperBound set when the slow rate of any
        feature with a remaining or in-progress execution task is at or below 0.5 tasks per
        hour.
    .PARAMETER Feature
        The scheduled features (Issue, NodeState, Step, Rate, DependsOn).
    .PARAMETER Pooled
        The pooled velocity (Count, StandardDeviation).
    .PARAMETER Aggregate
        The aggregate velocity (Count, StandardDeviation); null for none.
    .PARAMETER Ledger
        The duration ledger.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER Cap
        The parallel cap; 0 for no cap.
    .PARAMETER TailSeconds
        The epic tail seconds.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [Parameter(Mandatory = $true)] [pscustomobject] $Pooled,
        [AllowNull()] [object] $Aggregate = $null,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [int] $Cap = 0,
        [double] $TailSeconds = 0
    )

    $range = [pscustomobject]@{ FastSeconds = [double]::NaN; SlowSeconds = [double]::NaN; NoUpperBound = $false; StandardDeviation = [double]::NaN; SdSource = 'n/a'; Reason = '' }
    if ($Pooled.Count -ge 2) {
        $range.StandardDeviation = [double] $Pooled.StandardDeviation
        $range.SdSource = 'across-feature SD'
    } elseif ($null -ne $Aggregate -and $Aggregate.Count -ge 3) {
        $range.StandardDeviation = [double] $Aggregate.StandardDeviation
        $range.SdSource = 'aggregate interval SD'
    } else {
        $range.Reason = 'fewer than 2 qualifying features and fewer than 3 intervals'
        return $range
    }
    $ends = @{}
    foreach ($side in @(@{ Name = 'fast'; Sign = 1.0 }, @{ Name = 'slow'; Sign = -1.0 })) {
        $nodes = foreach ($record in $Feature) {
            $rate = [double] $record.Rate + $side.Sign * 2.05 * $range.StandardDeviation
            $isExternal = ($record.PSObject.Properties.Name -contains 'External') -and [bool] $record.External
            $hasTask = @($record.Step | Where-Object { $_.Type -eq 'execution' -and $_.Status -in @('remaining', 'in_progress') }).Count -gt 0
            if ($isExternal) { $hasTask = $record.NodeState -ne 'done' -and [int] $record.ExecutionTasks -gt 0 }
            if ($side.Name -eq 'slow' -and $hasTask -and $rate -le 0.5) { $range.NoUpperBound = $true }
            $seconds = 0.0
            if ($isExternal) { $seconds = Get-EpicProgressExternalSecond -Node $record -Rate $rate }
            elseif ($record.NodeState -ne 'done') { $seconds = (Get-EpicProgressFeatureRemainingSecond -Step @($record.Step) -Rate $rate -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds).TotalSeconds }
            [pscustomobject]@{ Issue = $record.Issue; State = $record.NodeState; DurationSeconds = $seconds; DependsOn = [string[]] @($record.DependsOn); External = $isExternal }
        }
        $ends[$side.Name] = (Invoke-EpicProgressListSchedule -Node @($nodes) -Cap $Cap -TailSeconds $TailSeconds).HeadlineSeconds
    }
    $range.FastSeconds = $ends['fast']
    $range.SlowSeconds = $ends['slow']
    if ($range.NoUpperBound) { $range.SlowSeconds = [double]::PositiveInfinity }
    return $range
}

function Get-EpicProgressCriticalPathReport {
    <#
    .SYNOPSIS
        Compose the critical-path report: per-feature rates and remaining time, schedule, chain, cap, dependency source, tail, headline, serial sum, range, and exclusions.
    .DESCRIPTION
        Each feature's rate is its own, the pooled, or the default sequential rate; its
        remaining time prices execution tasks at 3600 / rate through -MedianOverride. Blocked
        features and their dependents are excluded from the schedule and the serial sum and
        listed in Excluded with their remaining time (blocked steps included). The headline is
        the schedule finish plus the tail, and the serial sum is the sum of the scheduled
        features' remaining time plus the tail. In item mode the one feature has no
        dependency, no cap, and no tail, and the chain names the item alone.
    .PARAMETER Feature
        The features (Issue, Wave, Folder, State 'Completed', 'Running', or 'Pending', Blocked, Step, TasksDone, TasksTotal).
    .PARAMETER EpicStep
        The epic-level steps; empty in item mode.
    .PARAMETER Ledger
        The duration ledger merged in this run.
    .PARAMETER Default
        The default seconds per type.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER BlockedSince
        The start of each blocked item's span, keyed by issue; empty for none.
    .PARAMETER CheckpointRow
        The epic checkpoint features rows; empty for none.
    .PARAMETER ManifestRow
        The epic.md frontmatter features rows; empty for none.
    .PARAMETER CheckpointCap
        The epic checkpoint max_parallel_features value; null when absent.
    .PARAMETER ConfigCap
        The routing-config default_max_parallel_features value; null when absent.
    .PARAMETER Aggregate
        The aggregate velocity from Get-EpicProgressAggregateVelocity; null for none.
    .PARAMETER ExternalNode
        The cross-epic external nodes from New-EpicProgressExternalNode (issue #1162); empty for none.
    .PARAMETER CrossEdge
        The cross-epic edges from Get-EpicProgressCrossEpicEdge; empty for none.
    .PARAMETER ItemMode
        Report on one item: one node, no cap, and no tail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [AllowEmptyCollection()] [object[]] $EpicStep = @(),
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [hashtable] $BlockedSince = @{},
        [AllowEmptyCollection()] [object[]] $CheckpointRow = @(),
        [AllowEmptyCollection()] [object[]] $ManifestRow = @(),
        [AllowNull()] [object] $CheckpointCap = $null,
        [AllowNull()] [object] $ConfigCap = $null,
        [AllowNull()] [object] $Aggregate = $null,
        [AllowEmptyCollection()] [object[]] $ExternalNode = @(),
        [AllowEmptyCollection()] [object[]] $CrossEdge = @(),
        [switch] $ItemMode
    )

    $defaultRate = Get-EpicProgressDefaultRate -Default $Default
    $velocities = @($Feature | ForEach-Object { Get-EpicProgressFeatureVelocity -Issue ([string] $_.Issue) -Ledger $Ledger })
    $pooled = Get-EpicProgressPooledVelocity -Feature $velocities -DefaultRate $defaultRate
    $rateOf = @{}
    foreach ($rate in $pooled.Rate) { $rateOf[$rate.Issue] = $rate }
    if ($ItemMode) {
        $graph = [pscustomobject]@{ DependsOn = @{}; Source = 'none'; Message = '' }
        foreach ($record in $Feature) { $graph.DependsOn[[string] $record.Issue] = [string[]] @() }
        $cap = [pscustomobject]@{ Cap = 0; Source = 'none' }
        $tail = [pscustomobject]@{ TailSeconds = 0.0; PredictedSync = $false; Step = [object[]] @() }
    } else {
        $graphInput = @($Feature | ForEach-Object { [pscustomobject]@{ Issue = [string] $_.Issue; Wave = $_.Wave; Folder = [string] $_.Folder; Merged = ($_.State -eq 'Completed') } })
        $graph = Get-EpicProgressDependencyGraph -Feature $graphInput -CheckpointRow $CheckpointRow -ManifestRow $ManifestRow
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue $CheckpointCap -ConfigValue $ConfigCap
        $tail = Get-EpicProgressEpicTail -EpicStep $EpicStep -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds
    }
    $blocked = [string[]] @($Feature | Where-Object { $_.Blocked -and $_.State -ne 'Completed' } | ForEach-Object { [string] $_.Issue })
    $excludedIssues = @(Get-EpicProgressBlockedClosure -Blocked $blocked -DependsOn $graph.DependsOn)
    $nodeStateOf = @{ Completed = 'done'; Running = 'running'; Pending = 'pending' }
    $scheduled = [System.Collections.Generic.List[object]]::new()
    $rows = [System.Collections.Generic.List[object]]::new()
    $excluded = [System.Collections.Generic.List[object]]::new()
    $serial = 0.0
    foreach ($record in $Feature) {
        $issue = [string] $record.Issue
        $rate = $rateOf[$issue]
        $remaining = 0.0
        $blockedPart = 0.0
        if ($record.State -ne 'Completed') {
            $estimate = Get-EpicProgressFeatureRemainingSecond -Step @($record.Step) -Rate $rate.TasksPerHour -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -BlockedSince $BlockedSince
            $remaining = $estimate.TotalSeconds
            $blockedPart = $estimate.BlockedSubtotalSeconds
        }
        $isExcluded = $excludedIssues -contains $issue
        if ($isExcluded) {
            $excluded.Add([pscustomobject]@{ Issue = $issue; RemainingSeconds = $remaining + $blockedPart })
        } else {
            $serial += $remaining
            $crossNodes = @($CrossEdge | Where-Object { [string] $_.Issue -eq $issue } | ForEach-Object { [string] $_.Node })
            $scheduled.Add([pscustomobject]@{ Issue = $issue; NodeState = $nodeStateOf[[string] $record.State]; Step = @($record.Step); Rate = $rate.TasksPerHour; DependsOn = [string[]] (@($graph.DependsOn[$issue]) + $crossNodes) })
        }
        $rows.Add([pscustomobject]@{ Issue = $issue; State = $record.State; TasksDone = $record.TasksDone; TasksTotal = $record.TasksTotal; Rate = $rate.TasksPerHour; RateSource = $rate.Source; RemainingSeconds = $remaining; StartSeconds = [double]::NaN; FinishSeconds = [double]::NaN; Excluded = $isExcluded })
    }
    $nodes = @($scheduled | ForEach-Object { [pscustomobject]@{ Issue = $_.Issue; State = $_.NodeState; DurationSeconds = @($rows | Where-Object Issue -EQ $_.Issue)[0].RemainingSeconds; DependsOn = $_.DependsOn } })
    # Cross-epic external nodes (issue #1162) enter the schedule and the range at the pooled
    # rate, hold no slot, add no feature row, and are not part of the serial sum.
    $externalRate = $defaultRate
    if (-not [double]::IsNaN([double] $pooled.Median)) { $externalRate = [double] $pooled.Median }
    foreach ($node in $ExternalNode) {
        $nodes += [pscustomobject]@{ Issue = [string] $node.Issue; State = $node.NodeState; DurationSeconds = (Get-EpicProgressExternalSecond -Node $node -Rate $externalRate); DependsOn = [string[]] @(); External = $true }
        $scheduled.Add([pscustomobject]@{ Issue = [string] $node.Issue; NodeState = $node.NodeState; Step = @(); Rate = $externalRate; DependsOn = [string[]] @(); External = $true; ExecutionTasks = $node.ExecutionTasks; OtherSeconds = $node.OtherSeconds })
    }
    $schedule = Invoke-EpicProgressListSchedule -Node $nodes -Cap $cap.Cap -TailSeconds $tail.TailSeconds
    foreach ($entry in $schedule.Feature) {
        $matched = @($rows | Where-Object Issue -EQ $entry.Issue)
        if ($matched.Count -eq 0) { continue }
        $row = $matched[0]
        $row.StartSeconds = $entry.StartSeconds
        $row.FinishSeconds = $entry.FinishSeconds
    }
    return [pscustomobject]@{
        Feature          = [object[]] $rows.ToArray()
        Excluded         = [object[]] $excluded.ToArray()
        Pooled           = $pooled
        DefaultRate      = $defaultRate
        Cap              = $cap.Cap
        CapSource        = $cap.Source
        DependencySource = $graph.Source
        GraphMessage     = $graph.Message
        Tail             = $tail
        FinishSeconds    = $schedule.FinishSeconds
        HeadlineSeconds  = $schedule.HeadlineSeconds
        Chain            = Get-EpicProgressCriticalChain -Schedule $schedule -NoTail:$ItemMode
        SerialSumSeconds = $serial + $tail.TailSeconds
        Range            = Get-EpicProgressScheduleRange -Feature @($scheduled) -Pooled $pooled -Aggregate $Aggregate -Ledger $Ledger -Default $Default -NowUnixSeconds $NowUnixSeconds -Cap $cap.Cap -TailSeconds $tail.TailSeconds
        CrossEpic        = [object[]] @($CrossEdge | ForEach-Object { $edge = $_; $node = @($ExternalNode | Where-Object { $_.Issue -eq $edge.Node }) | Select-Object -First 1; [pscustomobject]@{ Issue = [string] $edge.Issue; Node = [string] $edge.Node; State = $(if ($null -ne $node) { $node.NodeState } else { 'pending' }); Label = $(if ($null -ne $node) { $node.Label } else { 'external (default)' }) } })
    }
}
