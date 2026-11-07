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
