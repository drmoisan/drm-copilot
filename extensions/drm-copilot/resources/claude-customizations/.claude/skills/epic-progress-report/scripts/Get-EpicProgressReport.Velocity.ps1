<#
.SYNOPSIS
    Task-velocity functions for Get-EpicProgressReport.ps1: default rate, sequential (per-feature), pooled, and aggregate velocity, pause spans, and excluded seconds.

.DESCRIPTION
    Pure, host-neutral functions (issue #1153, decisions E2, E3, E11, and E12): each takes data
    in and returns data, and none reads a file, starts a process, calls the network, calls an
    I/O seam, or reads the clock. A feature's sequential velocity is its execution-sample count
    divided by the summed sample seconds in hours, read from the duration-ledger samples whose
    key starts with '<issue>|exec|'. A feature qualifies with at least 5 tasks and 900 active
    seconds; the pooled value is the median of the qualifying features' velocities with the
    across-feature standard deviation (n-1). Aggregate velocity combines check-in samples into
    intervals of at least 600 seconds, and a gap between samples longer than 3600 seconds is a
    pause span that is subtracted from active time. Get-EpicProgressReport.Logic.ps1
    dot-sources this file, so a consumer dot-sources the Logic hub, not this file.
#>

function Get-EpicProgressStandardDeviation {
    <#
    .SYNOPSIS
        Return the sample standard deviation (n-1) of the values; NaN for fewer than two values.
    .PARAMETER Value
        The values.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [double[]] $Value)

    if ($Value.Count -lt 2) { return [double]::NaN }
    $mean = 0.0
    foreach ($entry in $Value) { $mean += $entry }
    $mean = $mean / $Value.Count
    $squares = 0.0
    foreach ($entry in $Value) { $squares += ($entry - $mean) * ($entry - $mean) }
    return [math]::Sqrt($squares / ($Value.Count - 1))
}

function Get-EpicProgressDefaultRate {
    <#
    .SYNOPSIS
        Return the default sequential rate in tasks per hour: 3600 divided by the execution default seconds (decision E2).
    .PARAMETER Default
        The default seconds per type from Resolve-EpicProgressStepDefault.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [hashtable] $Default)

    return 3600.0 / [double] $Default['execution']
}

function Get-EpicProgressFeatureVelocity {
    <#
    .SYNOPSIS
        Return Issue, Tasks, ActiveSeconds, TasksPerHour, and Qualifies for one feature from the duration ledger (decision E3).
    .DESCRIPTION
        Only samples whose key starts with '<issue>|exec|' (ordinal comparison) are counted, so
        another issue's execution samples and every non-execution sample are ignored. The rate
        is Tasks / (ActiveSeconds / 3600); with no active seconds it is NaN. The feature
        qualifies when Tasks is at least 5 and ActiveSeconds is at least 900.
    .PARAMETER Issue
        The feature issue number.
    .PARAMETER Ledger
        The duration ledger: a hashtable from step type to its samples.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [string] $Issue,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger
    )

    $prefix = "$Issue|exec|"
    $tasks = 0
    $seconds = 0.0
    if ($null -ne $Ledger) {
        foreach ($type in $Ledger.Keys) {
            foreach ($entry in @($Ledger[$type] | Where-Object { $null -ne $_ })) {
                if (([string] $entry.key).StartsWith($prefix, [System.StringComparison]::Ordinal)) {
                    $tasks++
                    $seconds += [double] $entry.seconds
                }
            }
        }
    }
    $rate = [double]::NaN
    if ($seconds -gt 0) { $rate = $tasks / ($seconds / 3600.0) }
    return [pscustomobject]@{
        Issue         = $Issue
        Tasks         = $tasks
        ActiveSeconds = $seconds
        TasksPerHour  = $rate
        Qualifies     = ($tasks -ge 5 -and $seconds -ge 900)
    }
}

function Get-EpicProgressPooledVelocity {
    <#
    .SYNOPSIS
        Return the pooled sequential velocity (Median, StandardDeviation, Count) and each feature's Rate with its Source.
    .DESCRIPTION
        The median and the across-feature standard deviation (n-1; NaN below 2) are taken over
        the qualifying features only; Count is their number, and Median is NaN when none
        qualifies. Each feature's rate is its own when it qualifies (source 'own'), else the
        pooled median when one exists (source 'pooled'), else the default rate (source
        'default').
    .PARAMETER Feature
        The per-feature records from Get-EpicProgressFeatureVelocity.
    .PARAMETER DefaultRate
        The default rate from Get-EpicProgressDefaultRate.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [Parameter(Mandatory = $true)] [double] $DefaultRate
    )

    [double[]] $qualifying = @($Feature | Where-Object { $null -ne $_ -and $_.Qualifies } | ForEach-Object { [double] $_.TasksPerHour })
    $median = Get-EpicProgressMedian -Value $qualifying
    $rates = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $Feature) {
        if ($null -eq $record) { continue }
        if ($record.Qualifies) {
            $rates.Add([pscustomobject]@{ Issue = [string] $record.Issue; TasksPerHour = [double] $record.TasksPerHour; Source = 'own' })
        } elseif ($qualifying.Count -gt 0) {
            $rates.Add([pscustomobject]@{ Issue = [string] $record.Issue; TasksPerHour = $median; Source = 'pooled' })
        } else {
            $rates.Add([pscustomobject]@{ Issue = [string] $record.Issue; TasksPerHour = $DefaultRate; Source = 'default' })
        }
    }
    return [pscustomobject]@{
        Median            = $median
        StandardDeviation = Get-EpicProgressStandardDeviation -Value $qualifying
        Count             = $qualifying.Count
        Rate              = [object[]] $rates.ToArray()
    }
}

function Get-EpicProgressPauseSpan {
    <#
    .SYNOPSIS
        Return one pause span (startUnixSeconds, endUnixSeconds) per consecutive gap strictly longer than 3600 seconds (decision E11).
    .DESCRIPTION
        The threshold is 3 times the 20-minute TL;DR cadence, a documented constant rather
        than a parameter. A gap of exactly 3600 seconds records no span.
    .PARAMETER SampleInstant
        The check-in sample instants in Unix seconds, in chronological order.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [long[]] $SampleInstant)

    for ($index = 1; $index -lt $SampleInstant.Count; $index++) {
        if ($SampleInstant[$index] - $SampleInstant[$index - 1] -gt 3600) {
            [pscustomobject]@{ startUnixSeconds = $SampleInstant[$index - 1]; endUnixSeconds = $SampleInstant[$index] }
        }
    }
}

function Get-EpicProgressResetPauseSpan {
    <#
    .SYNOPSIS
        Return the -ResetBaseline pause span from the newest stored sample to the resume instant; nothing without a sample (decision E11).
    .PARAMETER SampleInstant
        The stored check-in sample instants in Unix seconds.
    .PARAMETER ResumeUnixSeconds
        The resume instant (the current epoch second of the reset run).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [long[]] $SampleInstant,
        [Parameter(Mandatory = $true)] [long] $ResumeUnixSeconds
    )

    if ($SampleInstant.Count -eq 0) { return }
    $newest = ($SampleInstant | Measure-Object -Maximum).Maximum
    return [pscustomobject]@{ startUnixSeconds = [long] $newest; endUnixSeconds = $ResumeUnixSeconds }
}

function Select-EpicProgressRetainedPauseSpan {
    <#
    .SYNOPSIS
        Return, in order, the pause spans that end at or after the earliest stored instant; every span when no instant is stored.
    .DESCRIPTION
        The cutoff is the minimum of the start instant, the oldest sample 'ts', and the oldest
        plan tick anchor (LastTickUnixSeconds). No later calculation reads time before it: the
        aggregate elapsed time starts at the start instant, every interval starts at a sample,
        and every tick batch starts at an anchor. A span whose endUnixSeconds is before the
        cutoff is dropped; a span ending at the cutoff or later, or without an end, is kept.
    .PARAMETER PauseSpan
        The pause spans (startUnixSeconds, endUnixSeconds); empty for none.
    .PARAMETER StartUnixSeconds
        The stored start instant; null when none is stored.
    .PARAMETER Sample
        The stored check-in samples (ts, ...); a sample without 'ts' is ignored.
    .PARAMETER Item
        The per-item state: a hashtable from issue to a record whose Plans hashtable maps each
        plan file to its Checked list and LastTickUnixSeconds.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyCollection()] [object[]] $PauseSpan = @(),
        [AllowNull()] [object] $StartUnixSeconds = $null,
        [AllowEmptyCollection()] [object[]] $Sample = @(),
        [hashtable] $Item = @{}
    )

    $instants = [System.Collections.Generic.List[long]]::new()
    if ($null -ne $StartUnixSeconds) { $instants.Add([long] $StartUnixSeconds) }
    foreach ($entry in $Sample) {
        if ($null -ne $entry -and $entry.PSObject.Properties.Name -contains 'ts' -and $null -ne $entry.ts) { $instants.Add([long] $entry.ts) }
    }
    foreach ($issue in @($Item.Keys)) {
        $plans = $Item[$issue].Plans
        if ($null -eq $plans) { continue }
        foreach ($file in @($plans.Keys)) {
            $tick = $plans[$file].LastTickUnixSeconds
            if ($null -ne $tick) { $instants.Add([long] $tick) }
        }
    }
    $cutoff = [long]::MinValue
    if ($instants.Count -gt 0) { $cutoff = [long] ($instants | Measure-Object -Minimum).Minimum }
    foreach ($span in @($PauseSpan | Where-Object { $null -ne $_ })) {
        if ($null -eq $span.endUnixSeconds -or [long] $span.endUnixSeconds -ge $cutoff) { $span }
    }
}

function Get-EpicProgressExcludedSecond {
    <#
    .SYNOPSIS
        Return the seconds of an interval covered by the union of the pause spans and the blocked span; overlapping spans count once.
    .DESCRIPTION
        Each span is clipped to the interval with the Get-EpicProgressBlockedSecond arithmetic
        (a span without an end runs to the interval end), the clipped segments are merged, and
        their lengths are summed.
    .PARAMETER PauseSpan
        The pause spans (startUnixSeconds, endUnixSeconds); empty for none.
    .PARAMETER BlockedSinceUnixSeconds
        The start of the blocked span; null when the item is not blocked.
    .PARAMETER BlockedUntilUnixSeconds
        The end of the blocked span; null while the span is still open.
    .PARAMETER IntervalStartUnixSeconds
        The start of the interval.
    .PARAMETER IntervalEndUnixSeconds
        The end of the interval.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [AllowEmptyCollection()] [object[]] $PauseSpan = @(),
        [AllowNull()] [object] $BlockedSinceUnixSeconds = $null,
        [AllowNull()] [object] $BlockedUntilUnixSeconds = $null,
        [Parameter(Mandatory = $true)] [long] $IntervalStartUnixSeconds,
        [Parameter(Mandatory = $true)] [long] $IntervalEndUnixSeconds
    )

    $spans = [System.Collections.Generic.List[object]]::new()
    foreach ($span in $PauseSpan) {
        if ($null -ne $span -and $null -ne $span.startUnixSeconds) { $spans.Add(@([long] $span.startUnixSeconds, $span.endUnixSeconds)) }
    }
    if ($null -ne $BlockedSinceUnixSeconds) { $spans.Add(@([long] $BlockedSinceUnixSeconds, $BlockedUntilUnixSeconds)) }
    $segments = [System.Collections.Generic.List[object]]::new()
    foreach ($span in $spans) {
        $segmentEnd = $IntervalEndUnixSeconds
        if ($null -ne $span[1]) { $segmentEnd = [math]::Min([long] $span[1], $IntervalEndUnixSeconds) }
        $segmentStart = [math]::Max([long] $span[0], $IntervalStartUnixSeconds)
        if ($segmentEnd -gt $segmentStart) { $segments.Add([pscustomobject]@{ Start = [long] $segmentStart; End = [long] $segmentEnd }) }
    }
    $total = 0.0
    $currentStart = $null
    $currentEnd = $null
    foreach ($segment in @($segments | Sort-Object -Property Start, End)) {
        if ($null -ne $currentEnd -and $segment.Start -le $currentEnd) {
            $currentEnd = [math]::Max($currentEnd, $segment.End)
            continue
        }
        if ($null -ne $currentEnd) { $total += $currentEnd - $currentStart }
        $currentStart = $segment.Start
        $currentEnd = $segment.End
    }
    if ($null -ne $currentEnd) { $total += $currentEnd - $currentStart }
    return [double] $total
}

function Get-EpicProgressAggregateVelocity {
    <#
    .SYNOPSIS
        Return the aggregate (epic-wide) task velocity: Average, Recent, StandardDeviation, Count, and Interval (decision E11).
    .DESCRIPTION
        Average is (DoneTasks - BaselineDoneTasks) over the elapsed hours since the start minus
        the pause seconds inside that time; NaN without a task baseline, without active time, or
        while no interval exists (Count 0, including when every interval overlaps a pause span).
        Intervals are formed from the samples that carry a 'tasks' value, so samples kept by a
        version-2 migration are ignored (decision E12): starting at a sample, consecutive
        samples are combined until at least 600 seconds have elapsed, which closes one interval
        and starts the next; a trailing remainder shorter than 600 seconds is skipped, and an
        interval that overlaps a pause span is dropped (an interval that ends where a span
        starts is kept). Each interval's rate is its task difference over its hours. Recent is
        the last interval's rate; StandardDeviation (n-1) is NaN below 3 intervals.
    .PARAMETER Sample
        The check-in samples (ts, tasks), in any order.
    .PARAMETER PauseSpan
        The pause spans (startUnixSeconds, endUnixSeconds); empty for none.
    .PARAMETER StartUnixSeconds
        The baseline start instant.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER DoneTasks
        The epic done task count now.
    .PARAMETER BaselineDoneTasks
        The done task count at the baseline; null when none is resolved.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [AllowEmptyCollection()] [object[]] $PauseSpan = @(),
        [Parameter(Mandatory = $true)] [long] $StartUnixSeconds,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [Parameter(Mandatory = $true)] [int] $DoneTasks,
        [AllowNull()] [object] $BaselineDoneTasks = $null
    )

    $withTasks = @($Sample | Where-Object { $null -ne $_ -and $_.PSObject.Properties.Name -contains 'tasks' -and $null -ne $_.tasks -and $null -ne $_.ts } | Sort-Object -Property { [long] $_.ts } -Stable)
    $intervals = [System.Collections.Generic.List[object]]::new()
    $first = 0
    for ($index = 1; $index -lt $withTasks.Count; $index++) {
        $start = [long] $withTasks[$first].ts
        $end = [long] $withTasks[$index].ts
        if ($end - $start -lt 600) { continue }
        $overlaps = @($PauseSpan | Where-Object { $null -ne $_ -and [long] $_.startUnixSeconds -lt $end -and [long] $_.endUnixSeconds -gt $start }).Count -gt 0
        if (-not $overlaps) {
            $rate = ([double] $withTasks[$index].tasks - [double] $withTasks[$first].tasks) / (($end - $start) / 3600.0)
            $intervals.Add([pscustomobject]@{ StartUnixSeconds = $start; EndUnixSeconds = $end; TasksPerHour = $rate })
        }
        $first = $index
    }
    [double[]] $rates = @($intervals | ForEach-Object { $_.TasksPerHour })
    $average = [double]::NaN
    if ($rates.Count -gt 0) {
        $active = ($NowUnixSeconds - $StartUnixSeconds) - (Get-EpicProgressExcludedSecond -PauseSpan $PauseSpan -IntervalStartUnixSeconds $StartUnixSeconds -IntervalEndUnixSeconds $NowUnixSeconds)
        if ($null -ne $BaselineDoneTasks -and $active -gt 0) { $average = ($DoneTasks - [int] $BaselineDoneTasks) / ($active / 3600.0) }
    }
    $recent = [double]::NaN
    if ($rates.Count -gt 0) { $recent = $rates[$rates.Count - 1] }
    $deviation = [double]::NaN
    if ($rates.Count -ge 3) { $deviation = Get-EpicProgressStandardDeviation -Value $rates }
    return [pscustomobject]@{
        Average           = $average
        Recent            = $recent
        StandardDeviation = $deviation
        Count             = $rates.Count
        Interval          = [object[]] $intervals.ToArray()
    }
}
