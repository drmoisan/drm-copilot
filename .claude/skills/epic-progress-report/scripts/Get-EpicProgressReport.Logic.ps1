<#
.SYNOPSIS
    Pure logic for Get-EpicProgressReport.ps1.

.DESCRIPTION
    Parsing, counting, velocity, estimate, sample-retention, formatting, and line
    composition functions for the epic progress report. Every function takes data in and
    returns data: none reads a file, starts a process, calls the network, or reads the
    clock. The main script dot-sources this file and supplies the data through its I/O
    wrapper seams. Numeric and date text uses the invariant culture so the printed lines
    do not depend on the host culture.
#>

function Test-EpicProgressJsonText {
    <#
    .SYNOPSIS
        Return whether a text is non-blank, well-formed JSON; guards every JSON conversion.
    .PARAMETER Json
        The text to test. Blank and null text return $false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Json)

    if ([string]::IsNullOrWhiteSpace($Json)) { return $false }
    return [bool] (Test-Json -Json $Json -ErrorAction SilentlyContinue)
}

function ConvertFrom-EpicProgressKickoffRow {
    <#
    .SYNOPSIS
        Return one record (Issue, Wave, Band, PlanPath) per row of the kickoff feature table.
    .DESCRIPTION
        Only the feature-summary table is read: the table whose header row's first cell is
        'issue_num' or 'Issue' (case-insensitive). Lines before that header are skipped, and
        the first line after it that is not a table row ends the table, so every other table
        (for example the wave summary) is ignored. Each line is trimmed before it is matched
        and split, so leading whitespace before the first '|' is allowed on every table line,
        and a blank line ends the table. Inside the table, a feature row is a row
        whose first cell is a numeric issue number of any length; any whitespace, including
        none, may surround each cell, and the separator row is ignored. Cells 1, 3, 4, and 5
        hold the issue, the wave, the band, and the repository-relative plan path. A feature
        row whose wave cell is not all digits raises a terminating error naming the issue and
        the cell, because a skipped row would understate the epic's task total. For the same
        reason, a feature row with fewer than five cells, and a feature row whose plan cell is
        blank, each raise a terminating error naming the issue. Kickoff text
        that holds a non-whitespace character but no such header raises a terminating error;
        empty or whitespace-only text returns no rows.
    .PARAMETER KickoffText
        The full text of the kickoff file.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $KickoffText)

    $lines = $KickoffText -split '\r?\n'
    $inFeatureTable = $false
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $inFeatureTable) {
            $inFeatureTable = $trimmed -match '^\|\s*(issue_num|issue)\s*\|'
            continue
        }
        if ($trimmed -notmatch '^\|') { break }
        if ($trimmed -notmatch '^\|\s*(\d+)\s*\|') { continue }
        $cells = @($trimmed -split '\|' | ForEach-Object { $_.Trim() })
        $cellCount = $cells.Count - 1
        if ($trimmed.EndsWith('|')) { $cellCount-- }
        if ($cellCount -lt 5) {
            throw "The kickoff row for issue #$($cells[1]) has $cellCount cells; a feature row needs 5 (issue, title, wave, band, plan path)."
        }
        if ([string]::IsNullOrWhiteSpace($cells[5])) {
            throw "The kickoff row for issue #$($cells[1]) has a blank plan cell."
        }
        $wave = 0
        if (-not [int]::TryParse($cells[3], [System.Globalization.NumberStyles]::None, [cultureinfo]::InvariantCulture, [ref] $wave)) {
            throw "The kickoff row for issue #$($cells[1]) has a non-numeric wave cell '$($cells[3])'."
        }
        [pscustomobject]@{ Issue = $cells[1]; Wave = $wave; Band = $cells[4]; PlanPath = $cells[5] }
    }
    if (-not $inFeatureTable -and $KickoffText -match '\S') {
        throw "The kickoff has no feature-summary table: no table header row whose first cell is 'issue_num' or 'Issue' was found."
    }
}

function Get-EpicProgressIssueFromKickoff {
    <#
    .SYNOPSIS
        Return the digits of the first 'Epic issue: #n' marker (mid-line allowed), or $null.
    .PARAMETER KickoffText
        The full text of the kickoff file.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $KickoffText)

    $match = [regex]::Match($KickoffText, 'Epic issue: #(\d+)')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}

function ConvertFrom-EpicProgressWorktreeList {
    <#
    .SYNOPSIS
        Return a map from branch name to worktree path from 'git worktree list --porcelain'.
    .DESCRIPTION
        Each 'worktree' line opens a record and the following 'branch refs/heads/' line
        names its branch. Detached worktrees have no branch line and are omitted.
    .PARAMETER PorcelainLine
        The porcelain output lines.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [string[]] $PorcelainLine)

    $map = @{}
    $worktreePath = $null
    foreach ($entry in $PorcelainLine) {
        if ($entry -like 'worktree *') {
            $worktreePath = $entry.Substring(9)
        } elseif ($entry -like 'branch refs/heads/*') {
            $map[$entry.Substring(18)] = $worktreePath
        }
    }
    return $map
}

function ConvertFrom-EpicProgressPrList {
    <#
    .SYNOPSIS
        Return '#number state' for the first entry of a 'gh pr list --json number,state' array.
    .DESCRIPTION
        Returns an empty string for an empty array, blank or unparseable output, or an
        entry without a number.
    .PARAMETER Json
        The JSON text printed by gh.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Json)

    if (-not (Test-EpicProgressJsonText -Json $Json)) { return '' }
    $items = @(ConvertFrom-Json -InputObject $Json)
    if ($items.Count -eq 0) { return '' }
    $first = $items[0]
    if ($null -eq $first -or -not ($first.PSObject.Properties.Name -contains 'number')) { return '' }
    return "#$($first.number) $($first.state)"
}

function Get-EpicProgressWeeklyQuota {
    <#
    .SYNOPSIS
        Return usage.sevenDay.pct of the first active account in 'cswap list --json' output.
    .DESCRIPTION
        Returns NaN when no account is active, the percentage is missing, or the output is
        blank or unparseable.
    .PARAMETER Json
        The JSON text printed by cswap.
    #>
    [CmdletBinding()]
    [OutputType([double])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Json)

    if (-not (Test-EpicProgressJsonText -Json $Json)) { return [double]::NaN }
    $data = ConvertFrom-Json -InputObject $Json
    if ($null -eq $data -or -not ($data.PSObject.Properties.Name -contains 'accounts')) { return [double]::NaN }
    $active = @($data.accounts | Where-Object { $null -ne $_ -and $_.active }) | Select-Object -First 1
    if ($null -eq $active -or $null -eq $active.usage -or $null -eq $active.usage.sevenDay -or $null -eq $active.usage.sevenDay.pct) {
        return [double]::NaN
    }
    return [double] $active.usage.sevenDay.pct
}

function Get-EpicProgressTaskCount {
    <#
    .SYNOPSIS
        Return Total and Done counts of '- [ ] [P#-T#]' and '- [x] [P#-T#]' plan checkboxes.
    .PARAMETER PlanText
        The full plan text. Checkboxes without a task identifier are not counted.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PlanText)

    $taskMatches = [regex]::Matches($PlanText, '(?m)^\s*- \[( |x)\] \[P\d+-T\d+\]')
    $done = 0
    foreach ($taskMatch in $taskMatches) {
        if ($taskMatch.Groups[1].Value -eq 'x') { $done++ }
    }
    return [pscustomobject]@{ Total = $taskMatches.Count; Done = $done }
}

function Get-EpicProgressCurrentPhase {
    <#
    .SYNOPSIS
        Return the heading text of the phase that holds the first unchecked task.
    .DESCRIPTION
        Returns the first level-2 to level-4 'Phase N' heading without its hash marks,
        'Phase N' when no heading matches, and an empty string when every task is checked.
    .PARAMETER PlanText
        The full plan text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PlanText)

    $first = [regex]::Match($PlanText, '(?m)^\s*- \[ \] \[P(\d+)-T\d+\]')
    if (-not $first.Success) { return '' }
    $phaseNumber = $first.Groups[1].Value
    $heading = [regex]::Match($PlanText, "(?m)^#{2,4}\s+Phase\s+$phaseNumber\b[^\r\n]*")
    if ($heading.Success) { return ($heading.Value -replace '^#+\s+', '').Trim() }
    return "Phase $phaseNumber"
}

function Get-EpicProgressFeatureState {
    <#
    .SYNOPSIS
        Classify a feature as Completed, Running, or Pending.
    .DESCRIPTION
        Completed when the merge status is 'merged' or 'worktree_removed' or the PR state
        contains MERGED; Running when a task is checked, the merge status is not
        'not_started', or a PR exists; Pending otherwise.
    .PARAMETER MergeStatus
        The checkpoint merge status ('not_started' when the feature has no entry).
    .PARAMETER PrState
        The pull-request text from ConvertFrom-EpicProgressPrList; empty when none.
    .PARAMETER Done
        The number of checked plan tasks.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $MergeStatus,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $PrState,
        [Parameter(Mandatory = $true)] [int] $Done
    )

    $isMerged = ($MergeStatus -eq 'merged') -or ($MergeStatus -eq 'worktree_removed') -or ($PrState -match 'MERGED')
    if ($isMerged) { return 'Completed' }
    if ($Done -gt 0 -or $MergeStatus -ne 'not_started' -or $PrState) { return 'Running' }
    return 'Pending'
}

function Select-EpicProgressSample {
    <#
    .SYNOPSIS
        Apply the sample-retention rule for one check-in; return Sample and Changed.
    .DESCRIPTION
        A sample (ts, done) is added only when there is no previous sample, the previous
        sample has no 'ts', or it is at least 90 seconds older than now. On add, samples
        without 'ts' are dropped and only the last SampleCap samples are kept.
    .PARAMETER Sample
        The samples read from the state file.
    .PARAMETER NowUnixSeconds
        The current instant in Unix seconds.
    .PARAMETER Done
        The checked task count now.
    .PARAMETER SampleCap
        The maximum number of samples kept.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Sample,
        [Parameter(Mandatory = $true)] [long] $NowUnixSeconds,
        [Parameter(Mandatory = $true)] [int] $Done,
        [Parameter(Mandatory = $true)] [ValidateRange(1, 100000)] [int] $SampleCap
    )

    $last = $null
    if ($Sample.Count -gt 0) { $last = $Sample[$Sample.Count - 1] }
    $add = ($null -eq $last) -or -not ($last.PSObject.Properties.Name -contains 'ts') -or (($NowUnixSeconds - [long] $last.ts) -ge 90)
    if (-not $add) { return [pscustomobject]@{ Sample = $Sample; Changed = $false } }
    $kept = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Sample) {
        if ($null -ne $entry -and $entry.PSObject.Properties.Name -contains 'ts') { $kept.Add($entry) }
    }
    $kept.Add([pscustomobject]@{ ts = $NowUnixSeconds; done = $Done })
    $retained = [object[]] @($kept | Select-Object -Skip ([math]::Max(0, $kept.Count - $SampleCap)))
    return [pscustomobject]@{ Sample = $retained; Changed = $true }
}

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
