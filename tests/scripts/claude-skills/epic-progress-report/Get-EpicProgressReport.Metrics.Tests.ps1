# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1 (issues #1080, #1093, #1118).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory input and asserts the returned data.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath
}

Describe 'Format-EpicProgressHour and Format-EpicProgressNumber' {
    It 'formats hours as H h MM min' {
        Format-EpicProgressHour -Hours 5.25 | Should -Be '5 h 15 min'
        Format-EpicProgressHour -Hours 1234.5 | Should -Be '1,234 h 30 min'
        Format-EpicProgressHour -Hours 0 | Should -Be '0 h 00 min'
    }

    It 'never prints 60 in the minute field' {
        # 1.995 hours is 119.7 minutes; the hour and minute fields derive from the rounded 120 minutes.
        Format-EpicProgressHour -Hours 1.995 | Should -Be '2 h 00 min'
    }

    It 'returns n/a from each formatter for NaN' {
        Format-EpicProgressHour -Hours ([double]::NaN) | Should -Be 'n/a'
        Format-EpicProgressNumber -Value ([double]::NaN) -Digits 1 | Should -Be 'n/a'
    }

    It 'returns n/a from each formatter for infinity' {
        Format-EpicProgressHour -Hours ([double]::PositiveInfinity) | Should -Be 'n/a'
        Format-EpicProgressNumber -Value ([double]::PositiveInfinity) | Should -Be 'n/a'
    }

    It 'rounds a number to the given digits with invariant text' {
        Format-EpicProgressNumber -Value 42.857 -Digits 1 | Should -Be '42.9'
        Format-EpicProgressNumber -Value 5.25 -Digits 0 | Should -Be '5'
        Format-EpicProgressNumber -Value 1.25 | Should -Be '1.25'
    }
}

Describe 'Get-EpicProgressTypeEstimate (issue #1118)' {
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

    It 'marks an in-progress step without a start as start not recorded' {
        # Issue #12 review has no start (0 s elapsed); issue #77 review started at 4700 (300 s elapsed).
        $steps = @(
            Get-TestStep -Type 'review' -Status 'in_progress'
            Get-TestStep -Type 'review' -Status 'in_progress' -Issue '77' -Started 4700
        )

        $estimate = Get-EpicProgressTypeEstimate -Step $steps -Ledger $script:ledger -Default $script:defaults -NowUnixSeconds 5000

        $estimate.InProgress.Count | Should -Be 2
        $estimate.InProgress[0].StartRecorded | Should -BeFalse
        $estimate.InProgress[0].ElapsedSeconds | Should -Be 0
        $estimate.InProgress[1].StartRecorded | Should -BeTrue
        $estimate.InProgress[1].ElapsedSeconds | Should -Be 300
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
}

Describe 'Get-EpicProgressTypeEstimate -MedianOverride (issue #1153, AC-21, AC-22, E4)' {
    BeforeAll {
        $script:defaults = Resolve-EpicProgressStepDefault
        # Execution samples of 600 s (median 600) so the ledger median differs from the 300 s override.
        $script:execLedger = @{ execution = @(Get-EpicProgressDurationSample -Key 'e1' -Type 'execution' -Seconds 600 -Source 'tick') }

        function Get-TestOverrideStep {
            # One step record with the given type, status, and start for issue 12.
            param([string] $Type, [string] $Status = 'remaining', [object] $Started = $null)
            [pscustomobject]@{ Issue = '12'; Type = $Type; Cycle = 0; Ordinal = 1; Status = $Status; Key = "12|$Type"; StartedUnixSeconds = $Started }
        }
    }

    It 'prices remaining execution tasks at the override and other steps at their median' {
        # 6 tasks x 300 s (12 tasks per hour) = 1800 s; one review at the 14-minute default = 840 s; 2640 s = 44 min.
        $steps = @(1..6 | ForEach-Object { Get-TestOverrideStep -Type 'execution' }) + @(Get-TestOverrideStep -Type 'review')

        $estimate = Get-EpicProgressTypeEstimate -Step $steps -Ledger @{} -Default $script:defaults -NowUnixSeconds 5000 -MedianOverride @{ execution = 300.0 }

        $estimate.TotalSeconds | Should -Be 2640
        $estimate.TotalSeconds / 60 | Should -Be 44
        @($estimate.Type | Where-Object { $_.Type -eq 'execution' })[0].IsDefault | Should -BeFalse
    }

    It 'credits max(0, override - elapsed) at the in-progress boundaries' -ForEach @(
        @{ Elapsed = 299; Expected = 1 }
        @{ Elapsed = 300; Expected = 0 }
        @{ Elapsed = 301; Expected = 0 }
    ) {
        $step = Get-TestOverrideStep -Type 'execution' -Status 'in_progress' -Started (5000 - $Elapsed)

        $estimate = Get-EpicProgressTypeEstimate -Step @($step) -Ledger $script:execLedger -Default $script:defaults -NowUnixSeconds 5000 -MedianOverride @{ execution = 300.0 }

        $estimate.TotalSeconds | Should -Be $Expected
    }

    It 'credits an in-progress execution step with the override and with the ledger median without it' {
        # 100 s elapsed: 300 - 100 = 200 s with the override; 600 - 100 = 500 s at the ledger median.
        $step = Get-TestOverrideStep -Type 'execution' -Status 'in_progress' -Started 4900

        $withOverride = Get-EpicProgressTypeEstimate -Step @($step) -Ledger $script:execLedger -Default $script:defaults -NowUnixSeconds 5000 -MedianOverride @{ execution = 300.0 }
        $without = Get-EpicProgressTypeEstimate -Step @($step) -Ledger $script:execLedger -Default $script:defaults -NowUnixSeconds 5000

        $withOverride.TotalSeconds | Should -Be 200
        $withOverride.InProgress[0].MedianSeconds | Should -Be 300
        $without.TotalSeconds | Should -Be 500
    }
}
