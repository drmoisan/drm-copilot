# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Durations.ps1 (issue #1118).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory samples, records, or checkpoint JSON and asserts the result.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath

    function Get-TestSample {
        # One sample with the given key, type, seconds, source, and recorded time.
        param([string] $Key, [string] $Type = 'review', [double] $Seconds = 60, [string] $Source = 'stage_timing', [long] $Recorded = 0)
        Get-EpicProgressDurationSample -Key $Key -Type $Type -Seconds $Seconds -Source $Source -Recorded $Recorded
    }

    function Get-TestRecord {
        # One stage record as ConvertFrom-EpicProgressStageTiming returns it.
        param([string] $Stage, [long] $Attempt = 1, [long] $Start = 1000, [object] $End = 1600)
        [pscustomobject]@{ Stage = $Stage; Type = (ConvertTo-EpicProgressStepType -StageName $Stage); Attempt = $Attempt; StartedUnixSeconds = $Start; EndedUnixSeconds = $End }
    }
}

Describe 'Get-EpicProgressMedian' {
    It 'returns the middle value for an odd count' {
        Get-EpicProgressMedian -Value @(300.0, 60.0, 120.0) | Should -Be 120
    }

    It 'averages the middle pair for an even count' {
        Get-EpicProgressMedian -Value @(60.0, 300.0, 120.0, 600.0) | Should -Be 210
    }

    It 'returns NaN for no samples' {
        [double]::IsNaN((Get-EpicProgressMedian -Value @())) | Should -BeTrue
    }
}

Describe 'Resolve-EpicProgressStepDefault' {
    It 'returns the built-in default for every type' {
        $defaults = Resolve-EpicProgressStepDefault

        $expected = [ordered]@{ research = 13; spec = 6; plan = 11; preflight = 10; execution = 5; review = 14; pr = 3; ci = 17; merge = 5; 'main-sync' = 60; 'integration-pr' = 45 }
        $defaults.Count | Should -Be 11
        foreach ($type in $expected.Keys) {
            $defaults[$type] | Should -Be (60 * $expected[$type]) -Because "$type has a default of $($expected[$type]) minutes"
        }
    }

    It 'applies a -StepDefaultMinutes override' {
        $defaults = Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ ci = 30; merge = 2.5 }

        $defaults['ci'] | Should -Be 1800
        $defaults['merge'] | Should -Be 150
        $defaults['review'] | Should -Be 840
    }

    It 'throws for an unknown -StepDefaultMinutes type' {
        { Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ deploy = 5 } } | Should -Throw -ExpectedMessage "*key 'deploy' is not a step type*"
    }

    It 'throws for a non-positive -StepDefaultMinutes value' {
        { Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ ci = 0 } } | Should -Throw -ExpectedMessage "*value for 'ci' must be a number of minutes above 0*"
        { Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ ci = -3 } } | Should -Throw -ExpectedMessage "*'ci'*"
        { Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ ci = 'ten' } } | Should -Throw -ExpectedMessage "*'ci'*"
    }
}

Describe 'Get-EpicProgressStageSample and Merge-EpicProgressDuration' {
    It 'creates one sample per closed attempt' {
        # Review attempts of 600 s and 900 s are closed; the third attempt is open.
        $records = @(
            Get-TestRecord -Stage 'review' -Attempt 1 -Start 1000 -End 1600
            Get-TestRecord -Stage 'review' -Attempt 2 -Start 2000 -End 2900
            Get-TestRecord -Stage 'review' -Attempt 3 -Start 3000 -End $null
            Get-TestRecord -Stage 'execution' -Attempt 1 -Start 1000 -End 5000
        )

        $result = Get-EpicProgressStageSample -Issue '12' -StageRecord $records -RecordedUnixSeconds 9000

        $result.Sample.Count | Should -Be 2
        ($result.Sample.key -join ',') | Should -Be '12|review|1,12|review|2'
        ($result.Sample.seconds -join ',') | Should -Be '600,900'
        $result.Sample[0].source | Should -Be 'stage_timing'
        $result.Sample[0].recorded | Should -Be 9000
        $result.Unmapped.Count | Should -Be 0
    }

    It 'records composite and unmapped stages as unmapped time without samples' {
        $records = @(
            Get-TestRecord -Stage 'remediation_cycle_1' -Start 1000 -End 4600
            Get-TestRecord -Stage 'promotion' -Start 100 -End 160
        )

        $result = Get-EpicProgressStageSample -Issue '12' -StageRecord $records

        $result.Sample.Count | Should -Be 0
        ($result.Unmapped | ForEach-Object { "$($_.Stage):$($_.Kind):$($_.Seconds)" }) -join ',' | Should -Be 'remediation_cycle_1:composite:3600,promotion:unmapped:60'
    }

    It 'keeps one sample per key across runs' {
        $first = Merge-EpicProgressDuration -Ledger @{} -Sample @(Get-TestSample -Key '12|review|1' -Seconds 600)
        $second = Merge-EpicProgressDuration -Ledger $first.Ledger -Sample @(Get-TestSample -Key '12|review|1' -Seconds 999)

        $first.Changed | Should -BeTrue
        $second.Changed | Should -BeFalse
        $second.Ledger['review'].Count | Should -Be 1
        $second.Ledger['review'][0].seconds | Should -Be 600
    }

    It 'replaces a tick sample with a stage_timing sample of the same key' {
        $key = '12|exec|plan.md|P1-T1'
        $ledger = (Merge-EpicProgressDuration -Ledger @{} -Sample @(Get-TestSample -Key $key -Type 'execution' -Seconds 100 -Source 'tick')).Ledger

        $result = Merge-EpicProgressDuration -Ledger $ledger -Sample @(Get-TestSample -Key $key -Type 'execution' -Seconds 240 -Source 'stage_timing')

        $result.Changed | Should -BeTrue
        $result.Ledger['execution'].Count | Should -Be 1
        $result.Ledger['execution'][0].source | Should -Be 'stage_timing'
        $result.Ledger['execution'][0].seconds | Should -Be 240
    }

    It 'retains more samples than the check-in cap' {
        # The check-in default cap is 14; the ledger keeps all 20 distinct samples.
        $samples = @(1..20 | ForEach-Object { Get-TestSample -Key "12|review|$_" -Recorded $_ })

        $result = Merge-EpicProgressDuration -Ledger @{} -Sample $samples

        $result.Ledger['review'].Count | Should -Be 20
    }

    It 'keeps only the newest 1000 samples of a type' {
        $samples = @(1..1002 | ForEach-Object { Get-TestSample -Key "k$_" -Type 'execution' -Recorded $_ })

        $result = Merge-EpicProgressDuration -Ledger @{} -Sample $samples

        $result.Ledger['execution'].Count | Should -Be 1000
        $result.Ledger['execution'][0].key | Should -Be 'k3'
        $result.Ledger['execution'][-1].key | Should -Be 'k1002'
    }
}

Describe 'Get-EpicProgressTickSample and Get-EpicProgressBlockedSecond' {
    BeforeAll {
        # Four tasks; P0-T1 was checked at the last tick (1000), and P0-T2 to P0-T4 are checked now (1900).
        $script:batchPlan = "- [x] [P0-T1] a.`n- [x] [P0-T2] b.`n- [x] [P0-T3] c.`n- [x] [P0-T4] d."
        $script:priorAnchor = [pscustomobject]@{ Checked = [string[]] @('P0-T1'); LastTickUnixSeconds = [long] 1000 }
    }

    It 'splits a batch of three newly checked tasks evenly over the interval' {
        # (1900 - 1000 - 0) / 3 = 300 seconds per task.
        $result = Get-EpicProgressTickSample -Issue '12' -PlanFile 'plan.md' -PlanText $script:batchPlan -Anchor $script:priorAnchor -NowUnixSeconds 1900

        ($result.Sample.key -join ',') | Should -Be '12|exec|plan.md|P0-T2,12|exec|plan.md|P0-T3,12|exec|plan.md|P0-T4'
        ($result.Sample.seconds -join ',') | Should -Be '300,300,300'
        $result.Sample[0].source | Should -Be 'tick'
        $result.Anchor.LastTickUnixSeconds | Should -Be 1900
        ($result.Anchor.Checked -join ',') | Should -Be 'P0-T1,P0-T2,P0-T3,P0-T4'
        $result.Changed | Should -BeTrue
    }

    It 'subtracts blocked seconds from the tick interval' {
        # Blocked from 1300 to now inside the 1000..1900 interval: 600 s; (900 - 600) / 3 = 100 s.
        $blocked = Get-EpicProgressBlockedSecond -BlockedSinceUnixSeconds 1300 -IntervalStartUnixSeconds 1000 -IntervalEndUnixSeconds 1900
        $closedSpan = Get-EpicProgressBlockedSecond -BlockedSinceUnixSeconds 800 -BlockedUntilUnixSeconds 1200 -IntervalStartUnixSeconds 1000 -IntervalEndUnixSeconds 1900

        $result = Get-EpicProgressTickSample -Issue '12' -PlanFile 'plan.md' -PlanText $script:batchPlan -Anchor $script:priorAnchor -NowUnixSeconds 1900 -BlockedSecond $blocked

        $blocked | Should -Be 600
        $closedSpan | Should -Be 200
        Get-EpicProgressBlockedSecond -IntervalStartUnixSeconds 1000 -IntervalEndUnixSeconds 1900 | Should -Be 0
        ($result.Sample.seconds -join ',') | Should -Be '100,100,100'
    }

    It 'seeds the anchor from the execution stage start' {
        # No anchor; the execution stage opened at 400, and two tasks are checked at 1000: 300 s each.
        $plan = "- [x] [P0-T1] a.`n- [x] [P0-T2] b.`n- [ ] [P0-T3] c."
        $record = [pscustomobject]@{ Stage = 'execution'; Type = 'execution'; Attempt = 1; StartedUnixSeconds = 400; EndedUnixSeconds = $null }

        $result = Get-EpicProgressTickSample -Issue '12' -PlanFile 'plan.md' -PlanText $plan -NowUnixSeconds 1000 -ExecutionRecord $record

        ($result.Sample.seconds -join ',') | Should -Be '300,300'
        $result.Anchor.LastTickUnixSeconds | Should -Be 1000
    }

    It 'seeds the anchor without a sample when no stage start is recorded' {
        $result = Get-EpicProgressTickSample -Issue '12' -PlanFile 'plan.md' -PlanText $script:batchPlan -NowUnixSeconds 1000

        $result.Sample.Count | Should -Be 0
        $result.Changed | Should -BeTrue
        $result.Anchor.LastTickUnixSeconds | Should -Be 1000
        $result.Anchor.Checked.Count | Should -Be 4
    }

    It 'replaces tick samples with per-task samples when execution closes' {
        # The stage ran 0..1200 for four tasks: 300 s per task replaces each tick sample.
        $ticks = Get-EpicProgressTickSample -Issue '12' -PlanFile 'plan.md' -PlanText $script:batchPlan -Anchor $script:priorAnchor -NowUnixSeconds 1900
        $ledger = (Merge-EpicProgressDuration -Ledger @{} -Sample $ticks.Sample).Ledger
        $record = [pscustomobject]@{ Stage = 'execution'; Type = 'execution'; Attempt = 1; StartedUnixSeconds = 0; EndedUnixSeconds = 1200 }

        $closed = Get-EpicProgressTickSample -Issue '12' -PlanFile 'plan.md' -PlanText $script:batchPlan -Anchor $ticks.Anchor -NowUnixSeconds 2000 -ExecutionRecord $record
        $merged = Merge-EpicProgressDuration -Ledger $ledger -Sample $closed.Sample

        $closed.Changed | Should -BeFalse
        $merged.Changed | Should -BeTrue
        $merged.Ledger['execution'].Count | Should -Be 4
        (@($merged.Ledger['execution'] | ForEach-Object { "$($_.source):$($_.seconds)" }) | Sort-Object -Unique) | Should -Be 'stage_timing:300'
    }
}

Describe 'Get-EpicProgressApproximateSample' {
    It 'records an approximate main-sync sample from a sync row' {
        # 2026-01-05T09:00:00Z (1767603600) to 10:00:00Z: 3600 s.
        $row = ConvertFrom-Json -InputObject '{"issue_num":900,"worktree_created_at":"2026-01-05T09:00:00Z","merge_confirmed_at":"2026-01-05T10:00:00Z"}'

        $result = Get-EpicProgressApproximateSample -Issue '900' -EpicRow $row -EpicIssue '42' -SyncRow

        $result.Sample.Count | Should -Be 1
        $result.Sample[0].key | Should -Be '42|main-sync|900|1767603600'
        $result.Sample[0].type | Should -Be 'main-sync'
        $result.Sample[0].seconds | Should -Be 3600
        $result.Sample[0].source | Should -Be 'epic_row'
        $result.Sample[0].approx | Should -BeTrue
    }

    It 'records an approximate merge sample from the last ci end' {
        # The second ci attempt ends at 11:00; the merge is confirmed at 11:05: 300 s.
        $checkpoint = ConvertFrom-Json -InputObject ('{"stage_timing":[' +
            '{"stage":"ci","attempt":1,"started_at":"2026-01-05T10:00:00Z","ended_at":"2026-01-05T10:20:00Z"},' +
            '{"stage":"ci","attempt":2,"started_at":"2026-01-05T10:40:00Z","ended_at":"2026-01-05T11:00:00Z"}]}')
        $row = ConvertFrom-Json -InputObject '{"issue_num":12,"merge_confirmed_at":"2026-01-05T11:05:00Z"}'

        $result = Get-EpicProgressApproximateSample -Issue '12' -Checkpoint $checkpoint -EpicRow $row

        $result.Sample.Count | Should -Be 1
        $result.Sample[0].key | Should -Be '12|merge|c0|1'
        $result.Sample[0].seconds | Should -Be 300
        $result.Sample[0].approx | Should -BeTrue
    }

    It 'records cycle entry differences as approximate composite time' {
        # Cycle 1 entered 12:00, cycle 2 entered 13:30 (5400 s); cycle 2's audit is stamped 14:00 (1800 s).
        $checkpoint = ConvertFrom-Json -InputObject ('{"remediation_loop":{"cycles":[' +
            '{"entry_timestamp":"2026-01-05T12:00:00Z"},' +
            '{"entry_timestamp":"2026-01-05T13:30:00Z","audit_paths":["docs/x/feature-audit.2026-01-05T14-00.md"]}]}}')

        $result = Get-EpicProgressApproximateSample -Issue '12' -Checkpoint $checkpoint

        $result.Sample.Count | Should -Be 0
        (@($result.Unmapped | ForEach-Object { "$($_.Stage):$($_.Kind):$($_.Seconds):$($_.Source):$($_.Approx)" }) -join ',') | Should -Be 'remediation_cycle_1:composite:5400:cycle_entry:True,remediation_cycle_2:composite:1800:artifact_stamp:True'
    }
}
