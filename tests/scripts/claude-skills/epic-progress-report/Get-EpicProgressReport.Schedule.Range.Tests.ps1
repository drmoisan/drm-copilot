# Pester tests for the epic tail, range, and report composition of
# .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1 (issue #1153, decisions E4, E8, E9).
# The Logic hub is dot-sourced, which dot-sources the Schedule file; every function under test is
# pure, so each test supplies fixed in-memory steps and ledgers and asserts the returned data.
# Golden values are derived by hand in the comments (seconds; 60 per minute, 3600 per hour).

BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1')

    $script:now = [long] 100000
    $script:defaults = Resolve-EpicProgressStepDefault

    function Get-TestStepList {
        # Count steps of one type and status for an issue, with an optional start.
        param([string] $Issue, [string] $Type, [int] $Count = 1, [string] $Status = 'remaining', [object] $Started = $null)
        @(1..$Count | ForEach-Object { Get-EpicProgressStepRecord -Issue $Issue -Type $Type -Ordinal $_ -Status $Status -StartedUnixSeconds $Started })
    }

    function Get-TestPathFeature {
        # One feature for Get-EpicProgressCriticalPathReport.
        param([string] $Issue, [string] $State = 'Pending', [bool] $Blocked = $false, [object[]] $Step = @(), [int] $Wave = 1)
        [pscustomobject]@{ Issue = $Issue; Wave = $Wave; Folder = ''; State = $State; Blocked = $Blocked; Step = $Step; TasksDone = 0; TasksTotal = 3 }
    }

    function Get-TestRangeFeature {
        # One pending feature for Get-EpicProgressScheduleRange with Tasks remaining execution steps at a rate.
        param([string] $Issue, [double] $Rate, [int] $Tasks = 1, [object[]] $Extra = @())
        $steps = @(Get-TestStepList -Issue $Issue -Type 'execution' -Count $Tasks) + @($Extra)
        if ($Tasks -eq 0) { $steps = @($Extra) }
        [pscustomobject]@{ Issue = $Issue; NodeState = 'pending'; Step = $steps; Rate = $Rate; DependsOn = [string[]] @() }
    }

    function Get-TestExecLedger {
        # Count execution samples of Seconds each for one issue.
        param([string] $Issue, [int] $Count, [double] $Seconds)
        @{ execution = @(1..$Count | ForEach-Object { Get-EpicProgressDurationSample -Key "$Issue|exec|plan.md|P1-T$_" -Type 'execution' -Seconds $Seconds -Source 'tick' }) }
    }
}

Describe 'Get-EpicProgressEpicTail (AC-35, E8)' {
    It 'predicts one main sync and the integration PR at the 60 and 45 minute defaults' {
        # 60 + 45 = 105 min.
        $tail = Get-EpicProgressEpicTail -EpicStep @(Get-TestStepList -Issue '42' -Type 'integration-pr') -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $tail.TailSeconds | Should -Be (105 * 60)
        $tail.PredictedSync | Should -BeTrue
    }

    It 'uses the ledger medians of 30 and 20 minutes when they exist' {
        # 30 + 20 = 50 min.
        $ledger = @{
            'main-sync'      = @(Get-EpicProgressDurationSample -Key 's1' -Type 'main-sync' -Seconds 1800 -Source 'epic_row' -Approx $true)
            'integration-pr' = @(Get-EpicProgressDurationSample -Key 'p1' -Type 'integration-pr' -Seconds 1200 -Source 'stage_timing')
        }

        $tail = Get-EpicProgressEpicTail -EpicStep @(Get-TestStepList -Issue '42' -Type 'integration-pr') -Ledger $ledger -Default $script:defaults -NowUnixSeconds $script:now

        $tail.TailSeconds | Should -Be (50 * 60)
    }

    It 'omits the predicted sync while the integration PR is in progress' {
        # No recorded start: 0 s elapsed, so the full 45 min remains and no sync is added.
        $tail = Get-EpicProgressEpicTail -EpicStep @(Get-TestStepList -Issue '42' -Type 'integration-pr' -Status 'in_progress') -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $tail.PredictedSync | Should -BeFalse
        $tail.TailSeconds | Should -Be (45 * 60)
    }

    It 'gives a zero tail when the integration PR is done' {
        $tail = Get-EpicProgressEpicTail -EpicStep @(Get-TestStepList -Issue '42' -Type 'integration-pr' -Status 'done') -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $tail.TailSeconds | Should -Be 0
        $tail.PredictedSync | Should -BeFalse
    }

    It 'uses a recorded sync row in progress for 20 minutes in place of the predicted sync' {
        # Sync credit 60 - 20 = 40 min, plus 45 min for the integration PR: 85 min.
        $steps = @(Get-TestStepList -Issue '900' -Type 'main-sync' -Status 'in_progress' -Started ($script:now - 1200)) + @(Get-TestStepList -Issue '42' -Type 'integration-pr')

        $tail = Get-EpicProgressEpicTail -EpicStep $steps -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $tail.TailSeconds | Should -Be (85 * 60)
        $tail.PredictedSync | Should -BeFalse
    }

    It 'keeps the predicted sync when the recorded sync row is done' {
        $steps = @(Get-TestStepList -Issue '900' -Type 'main-sync' -Status 'done') + @(Get-TestStepList -Issue '42' -Type 'integration-pr')

        $tail = Get-EpicProgressEpicTail -EpicStep $steps -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $tail.TailSeconds | Should -Be (105 * 60)
        $tail.PredictedSync | Should -BeTrue
    }

    It 'credits an integration PR in progress for <Minutes> minutes with <Expected> minutes' -ForEach @(
        @{ Minutes = 15; Expected = 30 }
        @{ Minutes = 50; Expected = 0 }
    ) {
        $steps = @(Get-TestStepList -Issue '42' -Type 'integration-pr' -Status 'in_progress' -Started ($script:now - 60 * $Minutes))

        (Get-EpicProgressEpicTail -EpicStep $steps -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now).TailSeconds | Should -Be ($Expected * 60)
    }

    It 'leaves the step total and percentage unchanged by the predicted sync' {
        $steps = @(Get-TestStepList -Issue '900' -Type 'main-sync' -Status 'done') + @(Get-TestStepList -Issue '42' -Type 'integration-pr')
        $before = Get-EpicProgressStepCount -Step $steps

        $tail = Get-EpicProgressEpicTail -EpicStep $steps -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now
        $after = Get-EpicProgressStepCount -Step $steps

        $tail.PredictedSync | Should -BeTrue
        $steps.Count | Should -Be 2
        $after.Total | Should -Be $before.Total
        $after.Percent | Should -Be $before.Percent
    }
}

Describe 'Get-EpicProgressScheduleRange (AC-38, AC-39, AC-40, E9)' {
    It 'uses the across-feature SD with 2 qualifiers even when 3 intervals exist' {
        $range = Get-EpicProgressScheduleRange -Feature @(Get-TestRangeFeature -Issue '1' -Rate 8) -Pooled ([pscustomobject]@{ Count = 2; StandardDeviation = 2.0 }) -Aggregate ([pscustomobject]@{ Count = 3; StandardDeviation = 1.0 }) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $range.SdSource | Should -Be 'across-feature SD'
        $range.StandardDeviation | Should -Be 2
    }

    It 'uses the aggregate interval SD with 1 qualifier and 3 intervals' {
        # Rates 8 + 2.05 = 10.05 and 8 - 2.05 = 5.95 for one remaining task.
        $range = Get-EpicProgressScheduleRange -Feature @(Get-TestRangeFeature -Issue '1' -Rate 8) -Pooled ([pscustomobject]@{ Count = 1; StandardDeviation = [double]::NaN }) -Aggregate ([pscustomobject]@{ Count = 3; StandardDeviation = 1.0 }) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $range.SdSource | Should -Be 'aggregate interval SD'
        [math]::Round($range.FastSeconds, 6) | Should -Be ([math]::Round(3600 / 10.05, 6))
        [math]::Round($range.SlowSeconds, 6) | Should -Be ([math]::Round(3600 / 5.95, 6))
    }

    It 'prints n/a with a reason for 1 qualifier and 2 intervals' {
        $range = Get-EpicProgressScheduleRange -Feature @(Get-TestRangeFeature -Issue '1' -Rate 8) -Pooled ([pscustomobject]@{ Count = 1; StandardDeviation = [double]::NaN }) -Aggregate ([pscustomobject]@{ Count = 2; StandardDeviation = 1.0 }) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $range.SdSource | Should -Be 'n/a'
        $range.Reason | Should -Not -BeNullOrEmpty
        Format-EpicProgressHour -Hours ($range.FastSeconds / 3600) | Should -Be 'n/a'
        Format-EpicProgressHour -Hours ($range.SlowSeconds / 3600) | Should -Be 'n/a'
    }

    It 're-runs the schedule at 12.1 and 3.9 tasks per hour for rate 8 and SD 2' {
        # 8 + 2.05 x 2 = 12.1 and 8 - 4.1 = 3.9; three remaining tasks give 3 x 3600 / rate.
        $range = Get-EpicProgressScheduleRange -Feature @(Get-TestRangeFeature -Issue '1' -Rate 8 -Tasks 3) -Pooled ([pscustomobject]@{ Count = 2; StandardDeviation = 2.0 }) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now -TailSeconds 600

        [math]::Round($range.FastSeconds, 6) | Should -Be ([math]::Round(3 * 3600 / 12.1 + 600, 6))
        [math]::Round($range.SlowSeconds, 6) | Should -Be ([math]::Round(3 * 3600 / 3.9 + 600, 6))
        $range.NoUpperBound | Should -BeFalse
    }

    It 'has no upper bound at a slow rate of <Rate> with remaining tasks: <Expected>' -ForEach @(
        @{ Rate = 0.49; Expected = $true }
        @{ Rate = 0.5; Expected = $true }
        @{ Rate = 0.51; Expected = $false }
    ) {
        # An SD of 0 keeps the slow rate equal to the rate.
        $range = Get-EpicProgressScheduleRange -Feature @(Get-TestRangeFeature -Issue '1' -Rate $Rate) -Pooled ([pscustomobject]@{ Count = 2; StandardDeviation = 0.0 }) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $range.NoUpperBound | Should -Be $Expected
        [double]::IsInfinity($range.SlowSeconds) | Should -Be $Expected
    }

    It 'keeps an upper bound when the slow feature has no remaining task' {
        $feature = Get-TestRangeFeature -Issue '1' -Rate 0.4 -Tasks 0 -Extra @(Get-TestStepList -Issue '1' -Type 'review')

        $range = Get-EpicProgressScheduleRange -Feature @($feature) -Pooled ([pscustomobject]@{ Count = 2; StandardDeviation = 0.0 }) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $range.NoUpperBound | Should -BeFalse
        $range.SlowSeconds | Should -Be 840
    }
}

Describe 'Get-EpicProgressCriticalPathReport (AC-09, AC-34, E4)' {
    It 'reports an item headline equal to its remaining time with no cap and no tail' {
        # Default rate 12: 2 tasks x 300 s + one review at 840 s = 1440 s.
        $item = Get-TestPathFeature -Issue '77' -State 'Running' -Step (@(Get-TestStepList -Issue '77' -Type 'execution' -Count 2) + @(Get-TestStepList -Issue '77' -Type 'review'))

        $report = Get-EpicProgressCriticalPathReport -Feature @($item) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now -ItemMode

        $report.Feature[0].RemainingSeconds | Should -Be 1440
        $report.HeadlineSeconds | Should -Be 1440
        $report.Chain | Should -Be '#77'
        $report.Cap | Should -Be 0
        $report.CapSource | Should -Be 'none'
        $report.Tail.TailSeconds | Should -Be 0
    }

    It 'prices execution tasks at the own rate of 6 and the default rate of 12' {
        # Own rate: 6 samples of 600 s = 3600 s, 6 tasks per hour; 3 tasks x 600 s = 30 min. Default: 3 x 300 s = 15 min.
        $feature = Get-TestPathFeature -Issue '21' -State 'Running' -Step @(Get-TestStepList -Issue '21' -Type 'execution' -Count 3)

        $own = Get-EpicProgressCriticalPathReport -Feature @($feature) -Ledger (Get-TestExecLedger -Issue '21' -Count 6 -Seconds 600) -Default $script:defaults -NowUnixSeconds $script:now
        $default = Get-EpicProgressCriticalPathReport -Feature @($feature) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $own.Feature[0].RateSource | Should -Be 'own'
        $own.Feature[0].RemainingSeconds | Should -Be (30 * 60)
        $default.Feature[0].RateSource | Should -Be 'default'
        $default.Feature[0].RemainingSeconds | Should -Be (15 * 60)
    }

    It 'sets the serial sum to the feature remaining time plus the tail' {
        # Two independent features of 15 min each at the default rate, plus the 105 min no-median tail: 135 min.
        $features = @('21', '22' | ForEach-Object { Get-TestPathFeature -Issue $_ -Step @(Get-TestStepList -Issue $_ -Type 'execution' -Count 3) })

        $report = Get-EpicProgressCriticalPathReport -Feature $features -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now

        $report.Tail.TailSeconds | Should -Be (105 * 60)
        $report.SerialSumSeconds | Should -Be ((@($report.Feature | ForEach-Object { $_.RemainingSeconds }) | Measure-Object -Sum).Sum + 105 * 60)
        $report.SerialSumSeconds | Should -Be (135 * 60)
        $report.HeadlineSeconds | Should -Be (120 * 60)
        $report.HeadlineSeconds | Should -BeLessOrEqual $report.SerialSumSeconds
    }

    It 'excludes a blocked feature and its dependent and lists them with their remaining time' {
        # 31 is blocked (one task of 300 s plus a blocked review of 840 s); 32 depends on 31 (300 s);
        # 33 is independent (300 s) and is the only scheduled feature: headline and serial sum 300 + 6300.
        $features = @(
            Get-TestPathFeature -Issue '31' -State 'Running' -Blocked $true -Step (@(Get-TestStepList -Issue '31' -Type 'execution') + @(Get-TestStepList -Issue '31' -Type 'review' -Status 'blocked'))
            Get-TestPathFeature -Issue '32' -Step @(Get-TestStepList -Issue '32' -Type 'execution')
            Get-TestPathFeature -Issue '33' -Step @(Get-TestStepList -Issue '33' -Type 'execution')
        )
        $rows = @(
            [pscustomobject]@{ issue_num = 31; depends_on = @() }
            [pscustomobject]@{ issue_num = 32; depends_on = @(31) }
            [pscustomobject]@{ issue_num = 33; depends_on = @() }
        )

        $report = Get-EpicProgressCriticalPathReport -Feature $features -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now -CheckpointRow $rows -CheckpointCap 2

        @($report.Excluded | ForEach-Object { $_.Issue }) | Should -Be @('31', '32')
        @($report.Excluded | ForEach-Object { $_.RemainingSeconds }) | Should -Be @(1140, 300)
        $report.HeadlineSeconds | Should -Be 6600
        $report.SerialSumSeconds | Should -Be 6600
        $report.Chain | Should -Be '#33 -> tail'
        @($report.Feature | Where-Object { $_.Excluded } | ForEach-Object { $_.Issue }) | Should -Be @('31', '32')
        $report.Cap | Should -Be 2
        $report.CapSource | Should -Be 'checkpoint'
    }

    It 'carries no graph message for a valid graph' {
        $features = @('21', '22' | ForEach-Object { Get-TestPathFeature -Issue $_ -Step @(Get-TestStepList -Issue $_ -Type 'execution') })
        $rows = @([pscustomobject]@{ issue_num = 22; depends_on = @(21) })

        $report = Get-EpicProgressCriticalPathReport -Feature $features -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:now -CheckpointRow $rows

        $report.GraphMessage | Should -BeNullOrEmpty
        $report.DependencySource | Should -Be 'checkpoint'
        $report.Chain | Should -Be '#21 -> #22 -> tail'
    }
}
