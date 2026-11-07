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
