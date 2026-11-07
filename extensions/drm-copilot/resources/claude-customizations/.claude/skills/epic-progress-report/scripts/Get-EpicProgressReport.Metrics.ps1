<#
.SYNOPSIS
    Velocity, standard-deviation, estimate, and formatting functions for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Pure functions: each takes data in and returns data, and none reads a file, starts a
    process, calls the network, or reads the clock. Numeric and time text uses the invariant
    culture, and every non-finite value prints as n/a. Get-EpicProgressReport.Logic.ps1
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
