<#
.SYNOPSIS
    Summary and line-composition functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: Get-EpicProgressSummary collects every value the report prints, and
    Get-EpicProgressTldrLine and Get-EpicProgressFullLine compose the TL;DR and Full lines from
    that summary: progress in tasks and steps, the critical-path headline with its chain and
    cap, the sequential and aggregate velocity, the range and the serial sum (issue #1153,
    decision E1), the in-progress steps against their medians, the per-feature table, the
    critical-path section, the per-type table, blocked steps, and unmapped and composite stage
    time. Get-EpicProgressPushText derives the push-notification text from the first TL;DR
    line. Every figure passes through Format-EpicProgressHour or Format-EpicProgressNumber, so
    a non-finite value prints n/a. None reads a file, starts a process, calls the network, or
    reads the clock.
    Get-EpicProgressReport.Logic.ps1 dot-sources this file, so a consumer dot-sources the Logic
    hub, not this file.
#>

function Get-EpicProgressSummary {
    <#
    .SYNOPSIS
        Return one record with every value the progress report prints.
    .PARAMETER Feature
        The feature records (Issue, Wave, Band, Total, Done, State, Phase, Pr, BlockedReason,
        TasksDone, TasksTotal); Total and Done count steps, TasksDone and TasksTotal count plan
        tasks, and State is Completed, Running, Blocked, or Pending.
    .PARAMETER EpicStep
        The epic-level step records (main-sync and integration-pr); empty in item mode.
    .PARAMETER Estimate
        The record from Get-EpicProgressTypeEstimate over every step.
    .PARAMETER CriticalPath
        The record from Get-EpicProgressCriticalPathReport.
    .PARAMETER Aggregate
        The record from Get-EpicProgressAggregateVelocity; null for none.
    .PARAMETER Unmapped
        The unmapped and composite stage-time records (Kind, Seconds, Approx).
    .PARAMETER Subject
        Epic or Item: the word before the issue number.
    .PARAMETER StartUtc
        The start instant (UTC). A start after NowUtc counts as zero elapsed time.
    .PARAMETER NowUtc
        The current instant (UTC).
    .PARAMETER WeeklyPct
        The weekly quota percentage now; NaN when unavailable.
    .PARAMETER BaselineWeeklyPct
        The weekly quota percentage at the start instant.
    .PARAMETER EpicIssue
        The epic (or item) issue number printed in the report.
    .PARAMETER EpicName
        The epic name printed in the status heading; blank in item mode.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [AllowEmptyCollection()] [object[]] $EpicStep = @(),
        [Parameter(Mandatory = $true)] [pscustomobject] $Estimate,
        [Parameter(Mandatory = $true)] [pscustomobject] $CriticalPath,
        [AllowNull()] [object] $Aggregate = $null,
        [AllowEmptyCollection()] [object[]] $Unmapped = @(),
        [ValidateSet('Epic', 'Item')] [string] $Subject = 'Epic',
        [Parameter(Mandatory = $true)] [datetime] $StartUtc,
        [Parameter(Mandatory = $true)] [datetime] $NowUtc,
        [Parameter(Mandatory = $true)] [double] $WeeklyPct,
        [Parameter(Mandatory = $true)] [double] $BaselineWeeklyPct,
        [Parameter(Mandatory = $true)] [string] $EpicIssue,
        [AllowEmptyString()] [string] $EpicName = ''
    )

    $total = $EpicStep.Count
    $done = @($EpicStep | Where-Object { $_.Status -eq 'done' }).Count
    $tasksTotal = 0
    $tasksDone = 0
    foreach ($record in $Feature) {
        $total += [int] $record.Total
        $done += [int] $record.Done
        $tasksTotal += [int] $record.TasksTotal
        $tasksDone += [int] $record.TasksDone
    }
    if ($null -eq $Aggregate) { $Aggregate = [pscustomobject]@{ Average = [double]::NaN; Recent = [double]::NaN; StandardDeviation = [double]::NaN; Count = 0 } }
    $composite = 0.0
    $unmappedSeconds = 0.0
    $approximate = 0.0
    foreach ($entry in $Unmapped) {
        if ($entry.Kind -eq 'composite') { $composite += [double] $entry.Seconds } else { $unmappedSeconds += [double] $entry.Seconds }
        if ($entry.Approx) { $approximate += [double] $entry.Seconds }
    }
    return [pscustomobject]@{
        Subject           = $Subject
        EpicIssue         = $EpicIssue
        EpicName          = $EpicName
        Feature           = $Feature
        EpicStep          = $EpicStep
        Completed         = [object[]] @($Feature | Where-Object { $_.State -eq 'Completed' })
        Running           = [object[]] @($Feature | Where-Object { $_.State -eq 'Running' })
        Blocked           = [object[]] @($Feature | Where-Object { $_.State -eq 'Blocked' })
        Pending           = [object[]] @($Feature | Where-Object { $_.State -eq 'Pending' })
        Total             = $total
        Done              = $done
        TasksTotal        = $tasksTotal
        TasksDone         = $tasksDone
        Percent          = 100.0 * $done / [math]::Max(1, $total)
        StartUtc          = $StartUtc
        NowUtc            = $NowUtc
        ElapsedHours      = [math]::Max(0.0, ($NowUtc - $StartUtc).TotalHours)
        Estimate          = $Estimate
        CriticalPath      = $CriticalPath
        Aggregate         = $Aggregate
        CompositeSeconds  = $composite
        UnmappedSeconds   = $unmappedSeconds
        ApproxSeconds     = $approximate
        WeeklyPct         = $WeeklyPct
        WeeklyDelta       = $WeeklyPct - $BaselineWeeklyPct
    }
}

function Get-EpicProgressTldrHead {
    <#
    .SYNOPSIS
        Return the parts of the first TL;DR line: Head (progress), DoneSentence, and Running (the running and blocked sentences).
    .DESCRIPTION
        In item mode (Subject 'Item') the done sentence is about the item ('#<i> is done.' or
        '#<i> is not done yet.') and no 'No feature is running.' sentence is printed. An epic
        with one feature says 'The only feature is done.' or 'The only feature is not done
        yet.'; an epic with more features counts them.
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $featureCount = $Summary.Feature.Count
    $isItem = $Summary.Subject -eq 'Item'
    $isDone = $Summary.Completed.Count -gt 0
    $running = $Summary.Running
    $sentences = [System.Collections.Generic.List[string]]::new()
    if ($running.Count -eq 1) {
        $sentences.Add("#$($running[0].Issue) is running ($($running[0].Done) of $($running[0].Total) steps).")
    } elseif ($running.Count -gt 1) {
        $sentences.Add((($running | ForEach-Object { "#$($_.Issue) ($($_.Done) of $($_.Total))" }) -join ', ') + ' are running.')
    }
    foreach ($record in $Summary.Blocked) { $sentences.Add("#$($record.Issue) is blocked ($($record.BlockedReason)).") }
    if ($sentences.Count -eq 0 -and -not $isItem) { $sentences.Add('No feature is running.') }
    if ($isItem) {
        $doneSentence = "#$($Summary.EpicIssue) is not done yet."
        if ($isDone) { $doneSentence = "#$($Summary.EpicIssue) is done." }
    } elseif ($featureCount -eq 1) {
        $doneSentence = 'The only feature is not done yet.'
        if ($isDone) { $doneSentence = 'The only feature is done.' }
    } else {
        $doneSentence = "None of the $featureCount features is done yet."
        if ($isDone) { $doneSentence = "$($Summary.Completed.Count) of $featureCount features are done." }
    }
    $percent = Format-EpicProgressNumber -Value $Summary.Percent -Digits 1
    return [pscustomobject]@{
        Head         = "**TL;DR:** $($Summary.Subject) #$($Summary.EpicIssue) is at $($Summary.TasksDone) of $($Summary.TasksTotal) tasks, $($Summary.Done) of $($Summary.Total) steps ($percent%)."
        DoneSentence = $doneSentence
        Running      = ($sentences -join ' ')
    }
}

function Get-EpicProgressSequentialText {
    <#
    .SYNOPSIS
        Return the sequential-rate text 'v tasks / hr per feature (source, median of n, SD sd)' of a critical-path report.
    .DESCRIPTION
        One feature prints its own rate and source; otherwise the pooled median prints with
        source 'pooled' when a feature qualifies, else the default rate with source 'default'.
    .PARAMETER CriticalPath
        The record from Get-EpicProgressCriticalPathReport.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $CriticalPath)

    $pooled = $CriticalPath.Pooled
    $rate = [double] $CriticalPath.DefaultRate
    $source = 'default'
    $rates = @($pooled.Rate)
    if ($rates.Count -eq 1) {
        $rate = [double] $rates[0].TasksPerHour
        $source = [string] $rates[0].Source
    } elseif ($pooled.Count -gt 0) {
        $rate = [double] $pooled.Median
        $source = 'pooled'
    }
    return "$(Format-EpicProgressNumber -Value $rate -Digits 1) tasks / hr per feature ($source, median of $($pooled.Count), SD $(Format-EpicProgressNumber -Value ([double] $pooled.StandardDeviation) -Digits 1))"
}

function Get-EpicProgressRangeText {
    <#
    .SYNOPSIS
        Return the range text 'fast to slow (velocity +/- 2.05 SD, source)', 'fast to no upper bound (...)', or 'n/a (reason)'.
    .PARAMETER Range
        The record from Get-EpicProgressScheduleRange.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Range)

    if ($Range.SdSource -eq 'n/a') { return "n/a ($($Range.Reason))" }
    $slow = Format-EpicProgressHour -Hours ([double] $Range.SlowSeconds / 3600.0)
    if ($Range.NoUpperBound) { $slow = 'no upper bound' }
    return "$(Format-EpicProgressHour -Hours ([double] $Range.FastSeconds / 3600.0)) to $slow (velocity +/- 2.05 SD, $($Range.SdSource))"
}

function Get-EpicProgressTldrLine {
    <#
    .SYNOPSIS
        Return the five TL;DR lines (TL;DR, Elapsed, Now, Velocity, estimated time remaining; decision E1).
    .DESCRIPTION
        Line 1 states tasks and steps with the step percentage (decision D8) and the done and
        running sentences of Get-EpicProgressTldrHead. Line 2 states the elapsed time, the
        critical-path headline with its chain and cap, the blocked exclusion, and the weekly
        quota last; item mode prints the chain with no cap text. On the Now line an in-progress
        step with a recorded start prints its elapsed time against its median; a step without a
        recorded start prints '(start not recorded; median <m>)'. Line 4 prints the sequential
        and aggregate velocity, and line 5 the range and the serial sum.
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $head = Get-EpicProgressTldrHead -Summary $Summary
    $path = $Summary.CriticalPath
    $parts = [System.Collections.Generic.List[string]]::new()
    if ($path.Chain) { $parts.Add([string] $path.Chain) }
    if ($Summary.Subject -ne 'Item') { $parts.Add("cap $($path.Cap)") }
    $inner = $parts -join ', '
    $excluded = @($path.Excluded)
    if ($excluded.Count -gt 0) {
        $exclusion = "excludes $($excluded.Count) blocked: $((@($excluded | ForEach-Object { "#$($_.Issue)" })) -join ', ')"
        $inner = (@(@($inner, $exclusion) | Where-Object { $_ })) -join '; '
    }
    $estimate = $Summary.Estimate
    $now = 'no step is in progress'
    if ($estimate.InProgress.Count -gt 0) {
        $now = (@($estimate.InProgress | ForEach-Object {
                    $median = Format-EpicProgressHour -Hours ($_.MedianSeconds / 3600.0)
                    if ($_.StartRecorded -eq $false) {
                        "#$($_.Issue) $($_.Type) (start not recorded; median $median)"
                    } else {
                        $over = ''
                        if ($_.OverMedian) { $over = ', over median' }
                        "#$($_.Issue) $($_.Type) ($(Format-EpicProgressHour -Hours ($_.ElapsedSeconds / 3600.0)) of median $median$over)"
                    }
                }) -join ', ')
    }

    $aggregate = $Summary.Aggregate
    $aggregateText = "aggregate $(Format-EpicProgressNumber -Value ([double] $aggregate.Average) -Digits 1) tasks / hr average, $(Format-EpicProgressNumber -Value ([double] $aggregate.Recent) -Digits 1) recent, SD $(Format-EpicProgressNumber -Value ([double] $aggregate.StandardDeviation) -Digits 1) over $($aggregate.Count) intervals (aggregate, informational)"
    $headline = Format-EpicProgressHour -Hours ([double] $path.HeadlineSeconds / 3600.0)
    return [string[]] @(
        (@($head.Head, $head.DoneSentence, $head.Running) | Where-Object { $_ }) -join ' '
        "**Elapsed:** $(Format-EpicProgressHour -Hours $Summary.ElapsedHours); critical path about $headline left ($inner). **Weekly** quota is at $(Get-EpicProgressWeeklyText -Value $Summary.WeeklyPct)."
        "**Now:** $now. $($estimate.DefaultCount) of $($estimate.Type.Count) types use defaults."
        "**Velocity:** sequential $(Get-EpicProgressSequentialText -CriticalPath $path); $aggregateText."
        "**Estimated time remaining:** range $(Get-EpicProgressRangeText -Range $path.Range); serial sum $(Format-EpicProgressHour -Hours ([double] $path.SerialSumSeconds / 3600.0)) (upper bound, no parallelism)."
    )
}

function Get-EpicProgressPushText {
    <#
    .SYNOPSIS
        Return the push-notification text: the first TL;DR line with every '**' removed, without the running sentence when it is 200 characters or longer.
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $head = Get-EpicProgressTldrHead -Summary $Summary
    $text = ((@($head.Head, $head.DoneSentence, $head.Running) | Where-Object { $_ }) -join ' ').Replace('**', '')
    if ($text.Length -lt 200) { return $text }
    return ("$($head.Head) $($head.DoneSentence)").Replace('**', '')
}

function Get-EpicProgressCriticalPathLine {
    <#
    .SYNOPSIS
        Return the Full-mode per-feature table and critical-path section lines (decision E1).
    .DESCRIPTION
        The table has one row per feature: issue, state, tasks done of total, rate, rate
        source, remaining time, and the scheduled start and finish from now; an excluded
        (blocked or blocked-dependent) feature prints 'excluded' for both. The section names
        the chain, the headline, the feature finish, the tail steps, the dependency source,
        the cap and its source (item mode: none), the graph message when one exists, the
        serial sum, the range with its SD source, and the excluded features with their
        remaining time.
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $path = $Summary.CriticalPath
    $hourText = { param([double] $Seconds) Format-EpicProgressHour -Hours ($Seconds / 3600.0) }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('| Feature | State | Tasks | Rate | Source | Remaining | Start | Finish |')
    $lines.Add('|---|---|---|---|---|---|---|---|')
    foreach ($row in @($path.Feature)) {
        $startText = & $hourText $row.StartSeconds
        $finishText = & $hourText $row.FinishSeconds
        if ($row.Excluded) {
            $startText = 'excluded'
            $finishText = 'excluded'
        }
        $lines.Add("| #$($row.Issue) | $($row.State) | $($row.TasksDone) of $($row.TasksTotal) | $(Format-EpicProgressNumber -Value ([double] $row.Rate) -Digits 1) tasks / hr | $($row.RateSource) | $(& $hourText $row.RemainingSeconds) | $startText | $finishText |")
    }
    $lines.Add('')
    $headline = & $hourText $path.HeadlineSeconds
    if ($Summary.Subject -eq 'Item') {
        $lines.Add("**Critical path:** $($path.Chain). Headline $($headline): the item finishes in $(& $hourText $path.FinishSeconds); no dependency, cap, or tail.")
    } else {
        $tailSteps = @($path.Tail.Step | ForEach-Object { "$($_.Type) $(& $hourText $_.Seconds)" })
        $tailText = & $hourText $path.Tail.TailSeconds
        if ($tailSteps.Count -gt 0) { $tailText = "$tailText ($($tailSteps -join ', '))" }
        if ($path.Tail.PredictedSync) { $tailText = "$tailText, main-sync predicted" }
        $lines.Add("**Critical path:** $($path.Chain). Headline $($headline): features finish in $(& $hourText $path.FinishSeconds), then the tail of $tailText.")
        $lines.Add("**Schedule inputs:** dependency source $($path.DependencySource); cap $($path.Cap) ($($path.CapSource)).")
    }
    if ($path.GraphMessage) { $lines.Add("**Dependency graph:** $($path.GraphMessage).") }
    $lines.Add("**Serial sum:** $(& $hourText $path.SerialSumSeconds) (upper bound, no parallelism). **Range:** $(Get-EpicProgressRangeText -Range $path.Range).")
    $excluded = @($path.Excluded)
    if ($excluded.Count -gt 0) {
        $lines.Add("**Excluded (blocked):** $((@($excluded | ForEach-Object { "#$($_.Issue) ($(& $hourText $_.RemainingSeconds))" })) -join ', ').")
    }
    return $lines.ToArray()
}

function Get-EpicProgressFullLine {
    <#
    .SYNOPSIS
        Return the Full-mode lines that follow the TL;DR block.
    .DESCRIPTION
        The status heading, the Elapsed and Progress line in steps, the State table with a
        Blocked row, the Wave table with an Epic row for epic-level steps and its Total row,
        the per-feature table and critical-path section (Get-EpicProgressCriticalPathLine),
        the per-type table with its Total row, one line per type that uses a default duration,
        the blocked-work line when a step is blocked, the unmapped and composite stage-time
        line, and the weekly-quota line, with invariant-culture times. A median that includes
        approximate samples is marked '(approx)'. In item mode the State header reads 'Item',
        the Running and Pending rows carry no wave or band label, and the weekly line speaks of
        the measurement and of this item; a blocked count of one is singular.
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $culture = [cultureinfo]::InvariantCulture
    $isItem = $Summary.Subject -eq 'Item'
    $percent = Format-EpicProgressNumber -Value $Summary.Percent -Digits 1
    $hourText = { param([double] $Seconds) Format-EpicProgressHour -Hours ($Seconds / 3600.0) }
    $lines = [System.Collections.Generic.List[string]]::new()
    $title = "$($Summary.Subject) #$($Summary.EpicIssue)"
    if ($Summary.EpicName) { $title = "$title $($Summary.EpicName)" }
    $lines.Add('')
    $lines.Add("## $($title): status at $($Summary.NowUtc.ToString('HH:mm', $culture)) UTC, $($Summary.NowUtc.ToString('MMM d', $culture))")
    $lines.Add('')
    $lines.Add("**Elapsed:** $(Format-EpicProgressHour -Hours $Summary.ElapsedHours) since $($Summary.StartUtc.ToString('HH:mm', $culture)) UTC. **Progress:** $($Summary.Done) of $($Summary.Total) steps complete, **$percent%**.")
    $lines.Add('')
    $lines.Add($(if ($isItem) { '| State | Item |' } else { '| State | Features |' }))
    $lines.Add('|---|---|')
    $completedText = 'None yet'
    if ($Summary.Completed.Count -gt 0) { $completedText = ($Summary.Completed | ForEach-Object { "#$($_.Issue)" }) -join ', ' }
    $lines.Add("| Completed | $completedText |")
    foreach ($record in $Summary.Running) {
        $pullRequest = ''
        if ($record.Pr) { $pullRequest = " PR $($record.Pr)." }
        $phase = ''
        if ($record.Phase) { $phase = " Now at: $($record.Phase)." }
        $share = Format-EpicProgressNumber -Value (100.0 * $record.Done / [math]::Max(1, $record.Total)) -Digits 0
        $where = " (wave $($record.Wave)"
        if ($record.Band) { $where = "$where, $($record.Band)" }
        $where = "$where)"
        if ($isItem) { $where = '' }
        $lines.Add("| Running | #$($record.Issue)$($where): $($record.Done) of $($record.Total) steps ($share%).$phase$pullRequest |")
    }
    $blockedText = 'None'
    if ($Summary.Blocked.Count -gt 0) { $blockedText = ($Summary.Blocked | ForEach-Object { "#$($_.Issue) ($($_.BlockedReason))" }) -join ', ' }
    $lines.Add("| Blocked | $blockedText |")
    $pendingGroups = @($Summary.Pending | Group-Object -Property Wave | Sort-Object -Property { [int] $_.Name })
    foreach ($group in $pendingGroups) {
        $label = "Pending, wave $($group.Name)"
        if ($isItem) { $label = 'Pending' }
        $lines.Add("| $label | " + (($group.Group | ForEach-Object { "#$($_.Issue) ($($_.Total))" }) -join ', ') + ' |')
    }
    $lines.Add('')
    $lines.Add('| Wave | Children | Steps | Done |')
    $lines.Add('|---|---|---|---|')
    foreach ($group in @($Summary.Feature | Group-Object -Property Wave | Sort-Object -Property { [int] $_.Name })) {
        $waveTotal = 0
        $waveDone = 0
        foreach ($record in $group.Group) {
            $waveTotal += [int] $record.Total
            $waveDone += [int] $record.Done
        }
        $lines.Add("| $($group.Name) | $($group.Count) | $waveTotal | $waveDone |")
    }
    if ($Summary.EpicStep.Count -gt 0) {
        $lines.Add("| Epic | 0 | $($Summary.EpicStep.Count) | $(@($Summary.EpicStep | Where-Object { $_.Status -eq 'done' }).Count) |")
    }
    $lines.Add("| **Total** | **$($Summary.Feature.Count)** | **$($Summary.Total)** | **$($Summary.Done)** |")
    $lines.Add('')
    $lines.AddRange([string[]] @(Get-EpicProgressCriticalPathLine -Summary $Summary))
    $lines.Add('')
    $lines.Add('| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |')
    $lines.Add('|---|---|---|---|---|---|---|---|')
    $rows = @($Summary.Estimate.Type)
    foreach ($row in $rows) {
        $median = & $hourText $row.MedianSeconds
        if ($row.IsDefault) { $median = "$median (default)" }
        if ($row.IsApproximate) { $median = "$median (approx)" }
        $lines.Add("| $($row.Type) | $($row.Done) | $($row.InProgress) | $($row.Remaining) | $($row.Blocked) | $median | $($row.Samples) | $(& $hourText $row.SubtotalSeconds) |")
    }
    $sumColumn = { param([string] $Name) $sum = 0; foreach ($row in $rows) { $sum += $row.$Name }; $sum }
    $lines.Add("| **Total** | **$(& $sumColumn 'Done')** | **$(& $sumColumn 'InProgress')** | **$(& $sumColumn 'Remaining')** | **$(& $sumColumn 'Blocked')** | | **$(& $sumColumn 'Samples')** | **$(& $hourText $Summary.Estimate.TotalSeconds)** |")
    $lines.Add('')
    foreach ($row in @($rows | Where-Object { $_.IsDefault })) {
        $lines.Add("$($row.Type): no measured duration; default $(Format-EpicProgressNumber -Value ($row.MedianSeconds / 60.0) -Digits 1) min")
    }
    if ($Summary.Estimate.BlockedCount -gt 0) {
        $stepWord = 'steps'
        if ($Summary.Estimate.BlockedCount -eq 1) { $stepWord = 'step' }
        $lines.Add("**Blocked:** $($Summary.Estimate.BlockedCount) $stepWord excluded from the estimate, about $(& $hourText $Summary.Estimate.BlockedSubtotalSeconds) of work.")
    }
    $unmappedText = 'none.'
    $unmappedTotal = $Summary.CompositeSeconds + $Summary.UnmappedSeconds
    if ($unmappedTotal -gt 0) {
        $unmappedText = "$(& $hourText $unmappedTotal) (composite remediation $(& $hourText $Summary.CompositeSeconds), unmapped stages $(& $hourText $Summary.UnmappedSeconds), approximate $(& $hourText $Summary.ApproxSeconds)); it enters no median."
    }
    $lines.Add("**Unmapped and composite stage time:** $unmappedText")
    $delta = Format-EpicProgressNumber -Value $Summary.WeeklyDelta
    if ($delta -ne 'n/a' -and $Summary.WeeklyDelta -ge 0) { $delta = "+$delta" }
    $weeklyTail = "points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
    if ($isItem) { $weeklyTail = "points since the measurement started. This pool also covers the other runs in this session, so it is not this item's cost alone." }
    $lines.Add("**Weekly quota (active account):** $(Get-EpicProgressWeeklyText -Value $Summary.WeeklyPct) used, $delta $weeklyTail")
    return $lines.ToArray()
}
