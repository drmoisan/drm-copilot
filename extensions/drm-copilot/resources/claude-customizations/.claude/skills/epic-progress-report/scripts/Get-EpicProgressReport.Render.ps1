<#
.SYNOPSIS
    Summary and line-composition functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: Get-EpicProgressSummary computes every value the report prints, and
    Get-EpicProgressTldrLine and Get-EpicProgressFullLine compose the TL;DR and Full lines from
    that summary. None reads a file, starts a process, calls the network, or reads the clock.
    Get-EpicProgressReport.Logic.ps1 dot-sources this file, so a consumer dot-sources the Logic
    hub, not this file.
#>

function Get-EpicProgressSummary {
    <#
    .SYNOPSIS
        Return one record with every value the progress report prints.
    .PARAMETER Feature
        The feature records (Issue, Wave, Band, Total, Done, State, Phase, Pr).
    .PARAMETER BaselineDone
        The checked task count at the start instant.
    .PARAMETER StartUtc
        The start instant (UTC). A start after NowUtc counts as zero elapsed time, so the
        report shows 0 h 00 min elapsed, zero average velocity, and n/a estimates.
    .PARAMETER NowUtc
        The current instant (UTC).
    .PARAMETER Sample
        The retained samples (ts, done).
    .PARAMETER WaveOverheadHours
        The review and CI overhead added per open wave.
    .PARAMETER WeeklyPct
        The weekly quota percentage now; NaN when unavailable.
    .PARAMETER BaselineWeeklyPct
        The weekly quota percentage at the start instant.
    .PARAMETER EpicIssue
        The epic issue number printed in the report.
    .PARAMETER EpicName
        The epic name printed in the status heading.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [Parameter(Mandatory = $true)] [int] $BaselineDone,
        [Parameter(Mandatory = $true)] [datetime] $StartUtc,
        [Parameter(Mandatory = $true)] [datetime] $NowUtc,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [Parameter(Mandatory = $true)] [double] $WaveOverheadHours,
        [Parameter(Mandatory = $true)] [double] $WeeklyPct,
        [Parameter(Mandatory = $true)] [double] $BaselineWeeklyPct,
        [Parameter(Mandatory = $true)] [string] $EpicIssue,
        [Parameter(Mandatory = $true)] [string] $EpicName
    )

    $total = 0
    $done = 0
    foreach ($record in $Feature) {
        $total += [int] $record.Total
        $done += [int] $record.Done
    }
    $elapsedHours = [math]::Max(0.0, ($NowUtc - $StartUtc).TotalHours)
    $velocity = Get-EpicProgressAverageVelocity -Done $done -BaselineDone $BaselineDone -ElapsedHours $elapsedHours
    $straightHours = [double]::NaN
    if ($velocity -gt 0) { $straightHours = ($total - $done) / $velocity }
    $criticalPath = Get-EpicProgressCriticalPath -Feature $Feature -Velocity $velocity -WaveOverheadHours $WaveOverheadHours
    [double[]] $intervals = @(Get-EpicProgressRecentVelocityInterval -Sample $Sample)
    $recent = [double]::NaN
    if ($intervals.Count -gt 0) { $recent = $intervals[$intervals.Count - 1] }
    $deviation = Get-EpicProgressStandardDeviation -Interval $intervals

    return [pscustomobject]@{
        EpicIssue         = $EpicIssue
        EpicName          = $EpicName
        Feature           = $Feature
        Completed         = [object[]] @($Feature | Where-Object { $_.State -eq 'Completed' })
        Running           = [object[]] @($Feature | Where-Object { $_.State -eq 'Running' })
        Pending           = [object[]] @($Feature | Where-Object { $_.State -eq 'Pending' })
        Total             = $total
        Done              = $done
        Percent           = 100.0 * $done / [math]::Max(1, $total)
        StartUtc          = $StartUtc
        NowUtc            = $NowUtc
        ElapsedHours      = $elapsedHours
        Velocity          = $velocity
        Remaining         = $total - $done
        StraightHours     = $straightHours
        CriticalPath      = $criticalPath
        WaveOverheadHours = $WaveOverheadHours
        IntervalCount     = $intervals.Count
        RecentVelocity    = $recent
        StandardDeviation = $deviation
        RangeText         = Get-EpicProgressRangeText -AverageVelocity $velocity -StandardDeviation $deviation -IntervalCount $intervals.Count -CriticalPath $criticalPath -WaveOverheadHours $WaveOverheadHours
        WeeklyPct         = $WeeklyPct
        WeeklyDelta       = $WeeklyPct - $BaselineWeeklyPct
    }
}

function Get-EpicProgressTldrLine {
    <#
    .SYNOPSIS
        Return the four TL;DR lines (TL;DR, Elapsed, velocity, estimated time remaining).
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $featureCount = $Summary.Feature.Count
    $running = $Summary.Running
    $runSentence = 'No feature is running.'
    if ($running.Count -eq 1) {
        $runSentence = "#$($running[0].Issue) is running ($($running[0].Done) of $($running[0].Total))."
    } elseif ($running.Count -gt 1) {
        $runSentence = (($running | ForEach-Object { "#$($_.Issue) ($($_.Done) of $($_.Total))" }) -join ', ') + ' are running.'
    }
    $doneSentence = "None of the $featureCount features is done yet."
    if ($Summary.Completed.Count -gt 0) { $doneSentence = "$($Summary.Completed.Count) of $featureCount features are done." }
    $percent = Format-EpicProgressNumber -Value $Summary.Percent -Digits 1
    $hoursLeft = Format-EpicProgressNumber -Value $Summary.CriticalPath.Hours -Digits 0
    $velocity = Format-EpicProgressNumber -Value $Summary.Velocity -Digits 1
    $recent = Format-EpicProgressNumber -Value $Summary.RecentVelocity -Digits 1
    $deviation = Format-EpicProgressNumber -Value $Summary.StandardDeviation -Digits 1
    $weekly = Get-EpicProgressWeeklyText -Value $Summary.WeeklyPct

    return [string[]] @(
        "**TL;DR:** Epic #$($Summary.EpicIssue) is at $($Summary.Done) of $($Summary.Total) tasks ($percent%). $doneSentence $runSentence"
        "**Elapsed:** $(Format-EpicProgressHour -Hours $Summary.ElapsedHours), with about $hoursLeft hours left on the wave-parallel estimate. **Weekly** quota is at $weekly."
        "**Avg Velocity:** $velocity tasks / hr. **Recent Velocity:** $recent tasks / hr since last check-in. (SD of recent velocity: $deviation, from $($Summary.IntervalCount) intervals)"
        "**Estimated time remaining:** $($Summary.RangeText)"
    )
}

function Get-EpicProgressFullLine {
    <#
    .SYNOPSIS
        Return the Full-mode lines that follow the TL;DR block.
    .DESCRIPTION
        The status heading, the Elapsed and Progress line, the State table, the Wave table
        with its Total row, the Velocity and Remaining line, the straight-line and
        wave-parallel lines, and the weekly-quota line, with invariant-culture times.
    .PARAMETER Summary
        The record from Get-EpicProgressSummary.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [pscustomobject] $Summary)

    $culture = [cultureinfo]::InvariantCulture
    $percent = Format-EpicProgressNumber -Value $Summary.Percent -Digits 1
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('')
    $lines.Add("## Epic #$($Summary.EpicIssue) $($Summary.EpicName): status at $($Summary.NowUtc.ToString('HH:mm', $culture)) UTC, $($Summary.NowUtc.ToString('MMM d', $culture))")
    $lines.Add('')
    $lines.Add("**Elapsed:** $(Format-EpicProgressHour -Hours $Summary.ElapsedHours) since $($Summary.StartUtc.ToString('HH:mm', $culture)) UTC. **Progress:** $($Summary.Done) of $($Summary.Total) tasks complete, **$percent%**.")
    $lines.Add('')
    $lines.Add('| State | Features |')
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
        $lines.Add("| Running | #$($record.Issue) (wave $($record.Wave), $($record.Band)): $($record.Done) of $($record.Total) tasks ($share%).$phase$pullRequest |")
    }
    $pendingGroups = @($Summary.Pending | Group-Object -Property Wave | Sort-Object -Property { [int] $_.Name })
    foreach ($group in $pendingGroups) {
        $lines.Add("| Pending, wave $($group.Name) | " + (($group.Group | ForEach-Object { "#$($_.Issue) ($($_.Total))" }) -join ', ') + ' |')
    }
    $lines.Add('')
    $lines.Add('| Wave | Children | Tasks | Done |')
    $lines.Add('|---|---|---|---|')
    $waveGroups = @($Summary.Feature | Group-Object -Property Wave | Sort-Object -Property { [int] $_.Name })
    foreach ($group in $waveGroups) {
        $waveTotal = 0
        $waveDone = 0
        foreach ($record in $group.Group) {
            $waveTotal += [int] $record.Total
            $waveDone += [int] $record.Done
        }
        $lines.Add("| $($group.Name) | $($group.Count) | $waveTotal | $waveDone |")
    }
    $lines.Add("| **Total** | **$($Summary.Feature.Count)** | **$($Summary.Total)** | **$($Summary.Done)** |")
    $lines.Add('')
    $lines.Add("**Velocity:** $(Format-EpicProgressNumber -Value $Summary.Velocity -Digits 1) tasks per hour (one child's pace). **Remaining:** $($Summary.Remaining) tasks.")
    $lines.Add("- Straight line, no parallelism: about $(Format-EpicProgressHour -Hours $Summary.StraightHours) (upper bound).")
    $overhead = Format-EpicProgressNumber -Value $Summary.WaveOverheadHours
    $lines.Add("- Wave-parallel (longest chain $($Summary.CriticalPath.Tasks) tasks plus about $overhead h per open wave for review and CI): about **$(Format-EpicProgressHour -Hours $Summary.CriticalPath.Hours)**.")
    $delta = Format-EpicProgressNumber -Value $Summary.WeeklyDelta
    if ($delta -ne 'n/a' -and $Summary.WeeklyDelta -ge 0) { $delta = "+$delta" }
    $lines.Add("**Weekly quota (active account):** $(Get-EpicProgressWeeklyText -Value $Summary.WeeklyPct) used, $delta points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.")
    return $lines.ToArray()
}
