# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1 (issues #1080, #1093).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory input and asserts the returned data.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath
}

Describe 'Format-EpicProgressHour, Format-EpicProgressClock, and Format-EpicProgressNumber' {
    It 'formats hours as H h MM min' {
        Format-EpicProgressHour -Hours 5.25 | Should -Be '5 h 15 min'
        Format-EpicProgressHour -Hours 1234.5 | Should -Be '1,234 h 30 min'
        Format-EpicProgressHour -Hours 0 | Should -Be '0 h 00 min'
    }

    It 'formats hours as HH:MM' {
        Format-EpicProgressClock -Hours 5.25 | Should -Be '05:15'
        Format-EpicProgressClock -Hours 22.5 | Should -Be '22:30'
    }

    It 'never prints 60 in the minute field' {
        # 1.995 hours is 119.7 minutes; both fields derive from the rounded 120 minutes.
        Format-EpicProgressHour -Hours 1.995 | Should -Be '2 h 00 min'
        Format-EpicProgressClock -Hours 1.995 | Should -Be '02:00'
    }

    It 'returns n/a from each formatter for NaN' {
        Format-EpicProgressHour -Hours ([double]::NaN) | Should -Be 'n/a'
        Format-EpicProgressClock -Hours ([double]::NaN) | Should -Be 'n/a'
        Format-EpicProgressNumber -Value ([double]::NaN) -Digits 1 | Should -Be 'n/a'
    }

    It 'returns n/a from each formatter for infinity' {
        Format-EpicProgressHour -Hours ([double]::PositiveInfinity) | Should -Be 'n/a'
        Format-EpicProgressClock -Hours ([double]::NegativeInfinity) | Should -Be 'n/a'
        Format-EpicProgressNumber -Value ([double]::PositiveInfinity) | Should -Be 'n/a'
    }

    It 'rounds a number to the given digits with invariant text' {
        Format-EpicProgressNumber -Value 42.857 -Digits 1 | Should -Be '42.9'
        Format-EpicProgressNumber -Value 5.25 -Digits 0 | Should -Be '5'
        Format-EpicProgressNumber -Value 1.25 | Should -Be '1.25'
    }
}

Describe 'Get-EpicProgressAverageVelocity' {
    It 'returns the average velocity since the baseline' {
        Get-EpicProgressAverageVelocity -Done 30 -BaselineDone 10 -ElapsedHours 4 | Should -Be 5
    }

    It 'returns zero velocity when elapsed time is zero' {
        Get-EpicProgressAverageVelocity -Done 30 -BaselineDone 10 -ElapsedHours 0 | Should -Be 0
        Get-EpicProgressAverageVelocity -Done 30 -BaselineDone 10 -ElapsedHours -1 | Should -Be 0
    }
}

Describe 'Get-EpicProgressRecentVelocityInterval' {
    It 'skips intervals shorter than two minutes' {
        $samples = @(
            [pscustomobject]@{ ts = 0; done = 0 }
            [pscustomobject]@{ ts = 60; done = 1 }
            [pscustomobject]@{ ts = 3660; done = 3 }
        )

        $intervals = @(Get-EpicProgressRecentVelocityInterval -Sample $samples)

        $intervals.Count | Should -Be 1
        $intervals[0] | Should -Be 2
    }

    It 'counts a pair exactly two minutes apart' {
        # 120 / 3600.0 and 2 / 60 are the same double, so this pair sits on the inclusive boundary.
        $samples = @(
            [pscustomobject]@{ ts = 0; done = 0 }
            [pscustomobject]@{ ts = 120; done = 1 }
        )

        $intervals = @(Get-EpicProgressRecentVelocityInterval -Sample $samples)

        $intervals.Count | Should -Be 1
        $intervals[0] | Should -BeGreaterOrEqual (30 - 1e-9)
        $intervals[0] | Should -BeLessOrEqual (30 + 1e-9)
    }

    It 'clamps a negative interval rate to zero' {
        $samples = @(
            [pscustomobject]@{ ts = 0; done = 5 }
            [pscustomobject]@{ ts = 3600; done = 3 }
        )

        $intervals = @(Get-EpicProgressRecentVelocityInterval -Sample $samples)

        $intervals.Count | Should -Be 1
        $intervals[0] | Should -Be 0
    }
}

Describe 'Get-EpicProgressStandardDeviation' {
    It 'returns NaN with fewer than three intervals' {
        [double]::IsNaN((Get-EpicProgressStandardDeviation -Interval @(1.0, 2.0))) | Should -BeTrue
        [double]::IsNaN((Get-EpicProgressStandardDeviation -Interval @())) | Should -BeTrue
    }

    It 'returns the sample standard deviation of three intervals' {
        Get-EpicProgressStandardDeviation -Interval @(1.0, 2.0, 3.0) | Should -Be 1
    }
}

Describe 'Get-EpicProgressCriticalPath' {
    BeforeAll {
        $script:criticalFeatures = @(
            [pscustomobject]@{ Wave = 1; Total = 10; Done = 0; State = 'Completed' }
            [pscustomobject]@{ Wave = 1; Total = 5; Done = 1; State = 'Running' }
            [pscustomobject]@{ Wave = 1; Total = 3; Done = 0; State = 'Pending' }
            [pscustomobject]@{ Wave = 2; Total = 6; Done = 0; State = 'Pending' }
            [pscustomobject]@{ Wave = 3; Total = 9; Done = 2; State = 'Completed' }
        )
    }

    It 'sums the largest remaining count of each open wave' {
        $path = Get-EpicProgressCriticalPath -Feature $script:criticalFeatures -Velocity 2 -WaveOverheadHours 1.25

        $path.Tasks | Should -Be 10
        $path.OpenWaves | Should -Be 2
        $path.Hours | Should -Be 7.5
    }

    It 'returns NaN hours when velocity is zero' {
        $path = Get-EpicProgressCriticalPath -Feature $script:criticalFeatures -Velocity 0 -WaveOverheadHours 1.25

        $path.Tasks | Should -Be 10
        [double]::IsNaN($path.Hours) | Should -BeTrue
    }
}

Describe 'Get-EpicProgressRangeText' {
    BeforeAll {
        $script:rangePath = [pscustomobject]@{ Tasks = 10; OpenWaves = 2; Hours = 5.25 }
    }

    It 'states that three intervals are needed' {
        $text = Get-EpicProgressRangeText -AverageVelocity 5 -StandardDeviation ([double]::NaN) -IntervalCount 2 -CriticalPath $script:rangePath -WaveOverheadHours 1.25

        $text | Should -Be '05:15 hrs (range needs 3 or more check-in intervals)'
    }

    It 'returns a bounded range when the slow velocity exceeds 0.5' {
        # Fast 10 / 7.05 + 2.5 = 3.918 h (235 min); slow 10 / 2.95 + 2.5 = 5.890 h (353 min).
        $text = Get-EpicProgressRangeText -AverageVelocity 5 -StandardDeviation 1 -IntervalCount 3 -CriticalPath $script:rangePath -WaveOverheadHours 1.25

        $text | Should -Be '03:55 hrs to 05:53 hrs'
    }

    It 'returns the no-upper-bound wording at a slow velocity of 0.5' {
        $text = Get-EpicProgressRangeText -AverageVelocity 0.5 -StandardDeviation 0 -IntervalCount 3 -CriticalPath $script:rangePath -WaveOverheadHours 1.25

        $text | Should -Be '22:30 hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)'
    }
}

Describe 'Zero-rate and interval-count boundaries (issue #1093)' {
    It 'prints n/a hrs to no upper bound for zero-rate intervals' {
        # Four samples with no task done give three zero-rate intervals: average 0 and SD 0 (spec DEC-6).
        $samples = @(0, 600, 1200, 1800 | ForEach-Object { [pscustomobject]@{ ts = $_; done = 5 } })
        [double[]] $intervals = @(Get-EpicProgressRecentVelocityInterval -Sample $samples)
        $deviation = Get-EpicProgressStandardDeviation -Interval $intervals
        $path = Get-EpicProgressCriticalPath -Feature @([pscustomobject]@{ Wave = 1; Total = 10; Done = 0; State = 'Running' }) -Velocity 0 -WaveOverheadHours 1.25

        $text = Get-EpicProgressRangeText -AverageVelocity 0 -StandardDeviation $deviation -IntervalCount $intervals.Count -CriticalPath $path -WaveOverheadHours 1.25

        $intervals.Count | Should -Be 3
        $deviation | Should -Be 0
        $text | Should -Be 'n/a hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)'
    }

    It 'returns NaN for exactly 2 intervals and a finite value for 3 or more' {
        $twoIntervals = @(Get-EpicProgressRecentVelocityInterval -Sample @(0, 600, 1200 | ForEach-Object { [pscustomobject]@{ ts = $_; done = $_ / 600 } }))
        $threeIntervals = @(Get-EpicProgressRecentVelocityInterval -Sample @(0, 600, 1200, 1800 | ForEach-Object { [pscustomobject]@{ ts = $_; done = $_ / 300 } }))

        $twoIntervals.Count | Should -Be 2
        [double]::IsNaN((Get-EpicProgressStandardDeviation -Interval $twoIntervals)) | Should -BeTrue
        $threeIntervals.Count | Should -Be 3
        $finite = Get-EpicProgressStandardDeviation -Interval $threeIntervals
        ([double]::IsNaN($finite) -or [double]::IsInfinity($finite)) | Should -BeFalse
        Format-EpicProgressNumber -Value (Get-EpicProgressStandardDeviation -Interval @(6.0, 12.0, 6.0, 12.0)) -Digits 1 | Should -Be '3.5'
    }
}

Describe 'Get-EpicProgressTypeEstimate and Get-EpicProgressWaveParallelSecond (issue #1118)' {
    BeforeAll {
        $script:defaults = Resolve-EpicProgressStepDefault
        # Review samples of 600, 900, and 1200 s (median 900); execution samples of 240 and 360 s (median 300).
        $script:ledger = @{
            review    = @(600, 900, 1200 | ForEach-Object { Get-EpicProgressDurationSample -Key "r$_" -Type 'review' -Seconds $_ -Source 'stage_timing' })
            execution = @(240, 360 | ForEach-Object { Get-EpicProgressDurationSample -Key "e$_" -Type 'execution' -Seconds $_ -Source 'tick' })
        }

        function Get-TestStep {
            # One step record with the given type, status, issue, and start.
            param([string] $Type, [string] $Status = 'remaining', [string] $Issue = '12', [object] $Started = $null)
            [pscustomobject]@{ Issue = $Issue; Type = $Type; Cycle = 0; Ordinal = 1; Status = $Status; Key = "$Issue|$Type"; StartedUnixSeconds = $Started }
        }

        function Get-TestRow {
            param([object] $Estimate, [string] $Type)
            @($Estimate.Type | Where-Object { $_.Type -eq $Type })[0]
        }
    }

    It 'sums remaining steps times median per type' {
        # Execution 3 x 300 = 900; review 2 x 900 = 1800; done steps add nothing; total 2700.
        $steps = @(
            Get-TestStep -Type 'execution' -Status 'done'
            1..3 | ForEach-Object { Get-TestStep -Type 'execution' }
            1..2 | ForEach-Object { Get-TestStep -Type 'review' }
        )

        $estimate = Get-EpicProgressTypeEstimate -Step $steps -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5000

        (Get-TestRow -Estimate $estimate -Type 'execution').SubtotalSeconds | Should -Be 900
        (Get-TestRow -Estimate $estimate -Type 'execution').Done | Should -Be 1
        (Get-TestRow -Estimate $estimate -Type 'review').SubtotalSeconds | Should -Be 1800
        (Get-TestRow -Estimate $estimate -Type 'review').Samples | Should -Be 3
        $estimate.TotalSeconds | Should -Be 2700
    }

    It 'credits the unelapsed median of an in-progress step' {
        # Review started 300 s ago: max(0, 900 - 300) = 600.
        $estimate = Get-EpicProgressTypeEstimate -Step @(Get-TestStep -Type 'review' -Status 'in_progress' -Started 4700) -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5000

        $estimate.TotalSeconds | Should -Be 600
        $estimate.InProgress.Count | Should -Be 1
        $estimate.InProgress[0].ElapsedSeconds | Should -Be 300
        $estimate.InProgress[0].MedianSeconds | Should -Be 900
        $estimate.InProgress[0].OverMedian | Should -BeFalse
    }

    It 'flags an in-progress step over its median' {
        # Review started 1000 s ago, above the 900 s median: no credit and OverMedian.
        $estimate = Get-EpicProgressTypeEstimate -Step @(Get-TestStep -Type 'review' -Status 'in_progress' -Started 4000) -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5000

        $estimate.TotalSeconds | Should -Be 0
        $estimate.InProgress[0].OverMedian | Should -BeTrue
    }

    It 'uses the default and sets IsDefault for a type without samples' {
        # ci has no samples: default 17 min (1020 s) per remaining step.
        $estimate = Get-EpicProgressTypeEstimate -Step @(Get-TestStep -Type 'ci'; Get-TestStep -Type 'ci') -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5000
        $override = Get-EpicProgressTypeEstimate -Step @(Get-TestStep -Type 'ci') -Ledger @{} -Default (Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ ci = 30 }) -NowUnixSeconds 5000

        $row = Get-TestRow -Estimate $estimate -Type 'ci'
        $row.IsDefault | Should -BeTrue
        $row.MedianSeconds | Should -Be 1020
        $row.SubtotalSeconds | Should -Be 2040
        $estimate.DefaultCount | Should -Be 1
        $override.TotalSeconds | Should -Be 1800
    }

    It 'excludes blocked steps from the sum and reports their subtotal' {
        $steps = @(
            Get-TestStep -Type 'review' -Status 'blocked' -Issue '77'
            Get-TestStep -Type 'review' -Issue '12'
        )

        $estimate = Get-EpicProgressTypeEstimate -Step $steps -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5000

        $estimate.TotalSeconds | Should -Be 900
        $estimate.BlockedSubtotalSeconds | Should -Be 900
        $estimate.BlockedCount | Should -Be 1
        (Get-TestRow -Estimate $estimate -Type 'review').Blocked | Should -Be 1
    }

    It 'freezes elapsed time while blocked' {
        # The review started at 4000 and the item was blocked at 4300: elapsed stays 300 s at
        # both later instants, so the would-be subtotal stays 900 - 300 = 600.
        $step = Get-TestStep -Type 'review' -Status 'blocked' -Issue '77' -Started 4000

        $early = Get-EpicProgressTypeEstimate -Step @($step) -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 4500 -BlockedSince @{ '77' = 4300 }
        $late = Get-EpicProgressTypeEstimate -Step @($step) -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 9000 -BlockedSince @{ '77' = 4300 }

        $early.BlockedSubtotalSeconds | Should -Be 600
        $late.BlockedSubtotalSeconds | Should -Be 600
        $late.TotalSeconds | Should -Be 0
    }

    It 'returns a lower estimate at a later instant with no new done step' {
        $steps = @(
            Get-TestStep -Type 'review' -Status 'in_progress' -Started 4800
            Get-TestStep -Type 'ci'
        )

        $first = Get-EpicProgressTypeEstimate -Step $steps -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 4900
        $second = Get-EpicProgressTypeEstimate -Step $steps -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5200

        # 800 + 1020 = 1820 at the first run; 500 + 1020 = 1520 at the second.
        $first.TotalSeconds | Should -Be 1820
        $second.TotalSeconds | Should -Be 1520
        $second.TotalSeconds | Should -BeLessThan $first.TotalSeconds
    }

    It 'sets IsApproximate when a median includes approximate samples' {
        $ledger = @{ 'main-sync' = @(Get-EpicProgressDurationSample -Key 's1' -Type 'main-sync' -Seconds 3000 -Source 'epic_row' -Approx $true) }

        $estimate = Get-EpicProgressTypeEstimate -Step @(Get-TestStep -Type 'main-sync'; Get-TestStep -Type 'review') -Ledger ($ledger + $script:ledger) -Default $script:defaults -NowUnixSeconds 5000

        (Get-TestRow -Estimate $estimate -Type 'main-sync').IsApproximate | Should -BeTrue
        (Get-TestRow -Estimate $estimate -Type 'main-sync').MedianSeconds | Should -Be 3000
        (Get-TestRow -Estimate $estimate -Type 'review').IsApproximate | Should -BeFalse
    }

    It 'sums the largest remaining feature per open wave plus epic steps' {
        # Wave 1: max(600, 900) = 900; wave 2: 300; wave 3 holds only a finished feature; epic 2700.
        $features = @(
            [pscustomobject]@{ Wave = 1; RemainingSeconds = 600 }
            [pscustomobject]@{ Wave = 1; RemainingSeconds = 900 }
            [pscustomobject]@{ Wave = 2; RemainingSeconds = 300 }
            [pscustomobject]@{ Wave = 3; RemainingSeconds = 0 }
        )

        Get-EpicProgressWaveParallelSecond -Feature $features -EpicSeconds 2700 | Should -Be 3900
        Get-EpicProgressWaveParallelSecond -Feature @() | Should -Be 0
    }
}
