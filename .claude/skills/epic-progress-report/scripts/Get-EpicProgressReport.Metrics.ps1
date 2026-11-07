<#
.SYNOPSIS
    Velocity, standard-deviation, estimate, and formatting functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. Numeric and time text uses the invariant
    culture, and every non-finite value prints as n/a. Get-EpicProgressTypeEstimate computes
    the per-type remaining-time estimate of the step model (remaining steps times the median
    of each type, with in-progress credit and blocked steps excluded), and
    Get-EpicProgressWaveParallelSecond combines per-feature remaining seconds by wave.
    Get-EpicProgressReport.Logic.ps1
    dot-sources this file, so a consumer dot-sources the Logic hub, not this file.
#>

function Format-EpicProgressHour {
    <#
    .SYNOPSIS
        Format hours as 'H h MM min' from the rounded total minutes; 'n/a' when not finite.
    .PARAMETER Hours
        The hours to format.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Hours)

    if ([double]::IsNaN($Hours) -or [double]::IsInfinity($Hours)) { return 'n/a' }
    $minutes = [math]::Round($Hours * 60, [System.MidpointRounding]::AwayFromZero)
    $wholeHours = [math]::Floor($minutes / 60)
    return [string]::Format([cultureinfo]::InvariantCulture, '{0:N0} h {1:00} min', $wholeHours, ($minutes - 60 * $wholeHours))
}

function Format-EpicProgressClock {
    <#
    .SYNOPSIS
        Format hours as 'HH:MM' from the rounded total minutes; 'n/a' when not finite.
    .PARAMETER Hours
        The hours to format.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Hours)

    if ([double]::IsNaN($Hours) -or [double]::IsInfinity($Hours)) { return 'n/a' }
    $minutes = [math]::Round($Hours * 60)
    $wholeHours = [math]::Floor($minutes / 60)
    return [string]::Format([cultureinfo]::InvariantCulture, '{0:00}:{1:00}', $wholeHours, ($minutes - 60 * $wholeHours))
}

function Format-EpicProgressNumber {
    <#
    .SYNOPSIS
        Return a number rounded to Digits decimals as invariant text; 'n/a' when not finite.
    .PARAMETER Value
        The number to format.
    .PARAMETER Digits
        The decimal digits kept (0 to 15). The default of 15 prints the value unrounded.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [double] $Value,
        [ValidateRange(0, 15)] [int] $Digits = 15
    )

    if ([double]::IsNaN($Value) -or [double]::IsInfinity($Value)) { return 'n/a' }
    return ([math]::Round($Value, $Digits)).ToString([cultureinfo]::InvariantCulture)
}

function Get-EpicProgressAverageVelocity {
    <#
    .SYNOPSIS
        Return (Done - BaselineDone) / ElapsedHours, and 0 when ElapsedHours is not above 0.
    .PARAMETER Done
        The checked task count now.
    .PARAMETER BaselineDone
        The checked task count at the start instant.
    .PARAMETER ElapsedHours
        The hours since the start instant.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory = $true)] [int] $Done,
        [Parameter(Mandatory = $true)] [int] $BaselineDone,
        [Parameter(Mandatory = $true)] [double] $ElapsedHours
    )

    if ($ElapsedHours -gt 0) { return [double] ($Done - $BaselineDone) / $ElapsedHours }
    return [double] 0
}

function Get-EpicProgressRecentVelocityInterval {
    <#
    .SYNOPSIS
        Return the tasks-per-hour rate of each pair of consecutive samples at least 2 minutes apart.
    .DESCRIPTION
        Each rate is clamped to at least 0; pairs closer than 2 minutes are skipped.
    .PARAMETER Sample
        The retained samples, each with a 'ts' (Unix seconds) and a 'done' count.
    #>
    [CmdletBinding()]
    [OutputType([double[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample)

    $intervals = [System.Collections.Generic.List[double]]::new()
    for ($index = 1; $index -lt $Sample.Count; $index++) {
        $hours = ([long] $Sample[$index].ts - [long] $Sample[$index - 1].ts) / 3600.0
        if ($hours -ge (2 / 60)) {
            $rate = ([double] $Sample[$index].done - [double] $Sample[$index - 1].done) / $hours
            $intervals.Add([math]::Max(0.0, $rate))
        }
    }
    return $intervals.ToArray()
}

function Get-EpicProgressStandardDeviation {
    <#
    .SYNOPSIS
        Return the sample standard deviation (n - 1 denominator), or NaN below 3 intervals.
    .PARAMETER Interval
        The interval rates from Get-EpicProgressRecentVelocityInterval.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [double[]] $Interval)

    if ($Interval.Count -lt 3) { return [double]::NaN }
    $sum = 0.0
    foreach ($value in $Interval) { $sum += $value }
    $mean = $sum / $Interval.Count
    $squares = 0.0
    foreach ($value in $Interval) { $squares += ($value - $mean) * ($value - $mean) }
    return [math]::Sqrt($squares / ($Interval.Count - 1))
}

function Get-EpicProgressCriticalPath {
    <#
    .SYNOPSIS
        Return the wave-parallel critical-path estimate (Tasks, OpenWaves, Hours).
    .DESCRIPTION
        A wave is open when it holds a feature that is not Completed. Tasks sums, over open
        waves, the largest remaining count among the wave's open features. Hours is
        Tasks / Velocity plus WaveOverheadHours per open wave, and NaN when Velocity is
        not above 0.
    .PARAMETER Feature
        The feature records (Wave, Total, Done, State).
    .PARAMETER Velocity
        The average velocity in tasks per hour.
    .PARAMETER WaveOverheadHours
        The review and CI overhead added per open wave.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [Parameter(Mandatory = $true)] [double] $Velocity,
        [Parameter(Mandatory = $true)] [double] $WaveOverheadHours
    )

    $largestRemaining = @{}
    foreach ($record in $Feature) {
        if ($record.State -eq 'Completed') { continue }
        $remaining = [int] $record.Total - [int] $record.Done
        $wave = [string] $record.Wave
        if (-not $largestRemaining.ContainsKey($wave) -or $remaining -gt $largestRemaining[$wave]) {
            $largestRemaining[$wave] = $remaining
        }
    }
    $tasks = 0
    foreach ($value in $largestRemaining.Values) { $tasks += $value }
    $openWaves = $largestRemaining.Count
    $hours = [double]::NaN
    if ($Velocity -gt 0) { $hours = $tasks / $Velocity + $openWaves * $WaveOverheadHours }
    return [pscustomobject]@{ Tasks = $tasks; OpenWaves = $openWaves; Hours = $hours }
}

function Get-EpicProgressRangeText {
    <#
    .SYNOPSIS
        Return the estimated-time-remaining range text.
    .DESCRIPTION
        Below 3 intervals the text states that the range needs 3 or more check-in
        intervals. Otherwise the fast and slow velocities are the average plus and minus
        2.05 standard deviations: a slow velocity above 0.5 tasks per hour gives a bounded
        range, and otherwise the text states that there is no upper bound.
    .PARAMETER AverageVelocity
        The average velocity in tasks per hour.
    .PARAMETER StandardDeviation
        The sample standard deviation of the interval rates.
    .PARAMETER IntervalCount
        The number of check-in intervals.
    .PARAMETER CriticalPath
        The record from Get-EpicProgressCriticalPath.
    .PARAMETER WaveOverheadHours
        The review and CI overhead added per open wave.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [double] $AverageVelocity,
        [Parameter(Mandatory = $true)] [double] $StandardDeviation,
        [Parameter(Mandatory = $true)] [int] $IntervalCount,
        [Parameter(Mandatory = $true)] [pscustomobject] $CriticalPath,
        [Parameter(Mandatory = $true)] [double] $WaveOverheadHours
    )

    if ($IntervalCount -lt 3) {
        return "$(Format-EpicProgressClock -Hours $CriticalPath.Hours) hrs (range needs 3 or more check-in intervals)"
    }
    $overhead = $CriticalPath.OpenWaves * $WaveOverheadHours
    $slowVelocity = $AverageVelocity - 2.05 * $StandardDeviation
    $fastHours = [double] $CriticalPath.Tasks / ($AverageVelocity + 2.05 * $StandardDeviation) + $overhead
    $fastText = Format-EpicProgressClock -Hours $fastHours
    if ($slowVelocity -gt 0.5) {
        $slowText = Format-EpicProgressClock -Hours ([double] $CriticalPath.Tasks / $slowVelocity + $overhead)
        return "$fastText hrs to $slowText hrs"
    }
    return "$fastText hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)"
}

function Get-EpicProgressWeeklyText {
    <#
    .SYNOPSIS
        Return a weekly quota percentage as 'N%', or 'n/a' when it is not finite.
    .PARAMETER Value
        The percentage.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [double] $Value)

    $text = Format-EpicProgressNumber -Value $Value
    if ($text -eq 'n/a') { return $text }
    return "$text%"
}

function Get-EpicProgressTypeEstimate {
    <#
    .SYNOPSIS
        Return the per-type remaining-time estimate (Type rows, InProgress rows, and totals) of a step list.
    .DESCRIPTION
        Each type with at least one step gives a row (Type, Done, InProgress, Remaining,
        Blocked, MedianSeconds, Samples, IsDefault, IsApproximate, SubtotalSeconds,
        BlockedSubtotalSeconds). The median is taken over the type's retained ledger samples;
        a type without a sample uses its default and sets IsDefault, and IsApproximate is set
        when an approximate sample is retained. The subtotal is remaining steps times the
        median plus, per in-progress step, max(0, median - elapsed). Blocked steps are left out
        of the subtotal and summed in BlockedSubtotalSeconds; a blocked step that had started
        counts its elapsed time only up to the start of the item's blocked span. Each
        in-progress step also gives an InProgress row (Issue, Type, ElapsedSeconds,
        MedianSeconds, OverMedian). TotalSeconds is the sum of the subtotals (decision D7).
    .PARAMETER Step
        The step records.
    .PARAMETER Ledger
        The duration ledger: a hashtable from step type to its samples.
    .PARAMETER Default
        The default seconds per type from Resolve-EpicProgressStepDefault.
    .PARAMETER NowUnixSeconds
        The current epoch second.
    .PARAMETER BlockedSince
        The start of each blocked item's span, keyed by issue; empty for none.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Step,
        [Parameter(Mandatory = $true)] [AllowNull()] [hashtable] $Ledger,
        [Parameter(Mandatory = $true)] [hashtable] $Default,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [hashtable] $BlockedSince = @{}
    )

    $rows = [System.Collections.Generic.List[object]]::new()
    $running = [System.Collections.Generic.List[object]]::new()
    $total = 0.0
    $blockedTotal = 0.0
    foreach ($type in @(Get-EpicProgressStepTypeCatalog | ForEach-Object { $_.Type })) {
        $typeSteps = @($Step | Where-Object { $_.Type -eq $type })
        if ($typeSteps.Count -eq 0) { continue }
        $samples = @()
        if ($null -ne $Ledger -and $Ledger.ContainsKey($type)) { $samples = @($Ledger[$type] | Where-Object { $null -ne $_ }) }
        $isDefault = $samples.Count -eq 0
        $median = [double] $Default[$type]
        if (-not $isDefault) { $median = Get-EpicProgressMedian -Value ([double[]] @($samples | ForEach-Object { [double] $_.seconds })) }
        $subtotal = 0.0
        $blockedSubtotal = 0.0
        foreach ($entry in $typeSteps) {
            $elapsed = 0.0
            if ($null -ne $entry.StartedUnixSeconds) {
                $until = $NowUnixSeconds
                if ($entry.Status -eq 'blocked' -and $BlockedSince.ContainsKey([string] $entry.Issue) -and $null -ne $BlockedSince[[string] $entry.Issue]) {
                    $until = [math]::Min($NowUnixSeconds, [long] $BlockedSince[[string] $entry.Issue])
                }
                $elapsed = [double] [math]::Max(0, $until - [long] $entry.StartedUnixSeconds)
            }
            switch ($entry.Status) {
                'remaining' { $subtotal += $median }
                'in_progress' {
                    $subtotal += [math]::Max(0.0, $median - $elapsed)
                    $running.Add([pscustomobject]@{ Issue = $entry.Issue; Type = $type; ElapsedSeconds = $elapsed; MedianSeconds = $median; OverMedian = ($elapsed -gt $median) })
                }
                'blocked' { $blockedSubtotal += [math]::Max(0.0, $median - $elapsed) }
            }
        }
        $total += $subtotal
        $blockedTotal += $blockedSubtotal
        $rows.Add([pscustomobject]@{
                Type                   = $type
                Done                   = @($typeSteps | Where-Object { $_.Status -eq 'done' }).Count
                InProgress             = @($typeSteps | Where-Object { $_.Status -eq 'in_progress' }).Count
                Remaining              = @($typeSteps | Where-Object { $_.Status -eq 'remaining' }).Count
                Blocked                = @($typeSteps | Where-Object { $_.Status -eq 'blocked' }).Count
                MedianSeconds          = $median
                Samples                = $samples.Count
                IsDefault              = $isDefault
                IsApproximate          = @($samples | Where-Object { $_.approx }).Count -gt 0
                SubtotalSeconds        = $subtotal
                BlockedSubtotalSeconds = $blockedSubtotal
            })
    }
    return [pscustomobject]@{
        Type                   = [object[]] $rows.ToArray()
        InProgress             = [object[]] $running.ToArray()
        TotalSeconds           = $total
        BlockedSubtotalSeconds = $blockedTotal
        BlockedCount           = @($Step | Where-Object { $_.Status -eq 'blocked' }).Count
        DefaultCount           = @($rows | Where-Object { $_.IsDefault }).Count
    }
}

function Get-EpicProgressWaveParallelSecond {
    <#
    .SYNOPSIS
        Return the wave-parallel remaining seconds: the largest remaining feature of each open wave, summed, plus the epic-level seconds.
    .DESCRIPTION
        A wave is open when one of its features has remaining seconds above 0. The figure is
        secondary to the per-type sum (decision D7). In item mode, with one feature and no
        epic-level steps, it equals the item's sum.
    .PARAMETER Feature
        The per-feature records (Wave, RemainingSeconds).
    .PARAMETER EpicSeconds
        The remaining seconds of the epic-level steps.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Feature,
        [double] $EpicSeconds = 0
    )

    $largest = @{}
    foreach ($record in $Feature) {
        $seconds = [double] $record.RemainingSeconds
        if ($seconds -le 0) { continue }
        $wave = [string] $record.Wave
        if (-not $largest.ContainsKey($wave) -or $seconds -gt $largest[$wave]) { $largest[$wave] = $seconds }
    }
    $sum = [double] $EpicSeconds
    foreach ($value in $largest.Values) { $sum += $value }
    return $sum
}
