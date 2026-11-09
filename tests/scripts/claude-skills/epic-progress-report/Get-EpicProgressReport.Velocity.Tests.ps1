# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Velocity.ps1 (issue #1153).
# The Logic hub is dot-sourced, which dot-sources the Velocity file; every function under test is
# pure, so each test supplies fixed in-memory input and asserts the returned data. Golden values
# are derived by hand in the comments.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath

    function Get-TestExecLedger {
        # A ledger holding Count execution samples of Seconds each for one issue, keyed '<issue>|exec|plan.md|P1-T<n>'.
        param([string] $Issue, [int] $Count, [double] $Seconds)
        @(1..$Count | ForEach-Object { Get-EpicProgressDurationSample -Key "$Issue|exec|plan.md|P1-T$_" -Type 'execution' -Seconds $Seconds -Source 'tick' })
    }

    function Get-TestFeatureRecord {
        # A Get-EpicProgressFeatureVelocity-shaped record with a given rate and qualification.
        param([string] $Issue, [double] $Rate, [bool] $Qualifies = $true)
        [pscustomobject]@{ Issue = $Issue; Tasks = 6; ActiveSeconds = 3600; TasksPerHour = $Rate; Qualifies = $Qualifies }
    }
}

Describe 'Get-EpicProgressFeatureVelocity (AC-11, AC-12)' {
    It 'counts only ledger keys that start with the issue exec prefix' {
        # Issue 12: 6 samples of 600 s = 3600 s, so 6 tasks per hour. Issue 120 shares the digit
        # prefix but not '12|exec|'; the review sample keyed '12|review|1' is not an execution sample.
        $ledger = @{
            execution = @(Get-TestExecLedger -Issue '12' -Count 6 -Seconds 600) + @(Get-TestExecLedger -Issue '120' -Count 3 -Seconds 60) + @(Get-TestExecLedger -Issue '77' -Count 2 -Seconds 60)
            review    = @(Get-EpicProgressDurationSample -Key '12|review|1' -Type 'review' -Seconds 900 -Source 'stage_timing')
        }

        $velocity = Get-EpicProgressFeatureVelocity -Issue '12' -Ledger $ledger

        $velocity.Tasks | Should -Be 6
        $velocity.ActiveSeconds | Should -Be 3600
        $velocity.TasksPerHour | Should -Be 6
        $velocity.Qualifies | Should -BeTrue
    }

    It 'returns a non-finite rate that prints n/a for zero active seconds' {
        $velocity = Get-EpicProgressFeatureVelocity -Issue '12' -Ledger @{ execution = @(Get-TestExecLedger -Issue '12' -Count 2 -Seconds 0) }
        $empty = Get-EpicProgressFeatureVelocity -Issue '12' -Ledger $null

        [double]::IsNaN($velocity.TasksPerHour) | Should -BeTrue
        Format-EpicProgressNumber -Value $velocity.TasksPerHour -Digits 1 | Should -Be 'n/a'
        $empty.Tasks | Should -Be 0
        [double]::IsNaN($empty.TasksPerHour) | Should -BeTrue
    }

    It 'applies the qualification boundaries of 5 tasks and 900 seconds' -ForEach @(
        @{ Tasks = 4; Seconds = 900; Expected = $false }
        @{ Tasks = 5; Seconds = 900; Expected = $true }
        @{ Tasks = 6; Seconds = 900; Expected = $true }
        @{ Tasks = 5; Seconds = 899; Expected = $false }
        @{ Tasks = 5; Seconds = 901; Expected = $true }
    ) {
        # Tasks samples share Seconds equally, so the summed active time is exactly Seconds.
        $ledger = @{ execution = @(Get-TestExecLedger -Issue '12' -Count $Tasks -Seconds ($Seconds / $Tasks)) }

        $velocity = Get-EpicProgressFeatureVelocity -Issue '12' -Ledger $ledger

        $velocity.Tasks | Should -Be $Tasks
        $velocity.Qualifies | Should -Be $Expected
    }
}

Describe 'Get-EpicProgressPooledVelocity (AC-13, AC-14)' {
    It 'pools 6, 8 and 10 tasks per hour into median 8, SD 2 and count 3' {
        # Mean 8; squared deviations 4 + 0 + 4 = 8; 8 / (3 - 1) = 4; sqrt 4 = 2.
        $features = @(
            Get-TestFeatureRecord -Issue '1' -Rate 6
            Get-TestFeatureRecord -Issue '2' -Rate 8
            Get-TestFeatureRecord -Issue '3' -Rate 10
        )

        $pooled = Get-EpicProgressPooledVelocity -Feature $features -DefaultRate 12

        $pooled.Median | Should -Be 8
        $pooled.StandardDeviation | Should -Be 2
        $pooled.Count | Should -Be 3
    }

    It 'ignores a non-qualifying feature at 30 tasks per hour' {
        $features = @(
            Get-TestFeatureRecord -Issue '1' -Rate 6
            Get-TestFeatureRecord -Issue '2' -Rate 8
            Get-TestFeatureRecord -Issue '3' -Rate 10
            Get-TestFeatureRecord -Issue '4' -Rate 30 -Qualifies $false
        )

        $pooled = Get-EpicProgressPooledVelocity -Feature $features -DefaultRate 12

        $pooled.Median | Should -Be 8
        $pooled.Count | Should -Be 3
    }

    It 'returns a non-finite SD for one qualifier and a finite SD for two' {
        # Two qualifiers at 6 and 10: median 8; SD sqrt((4 + 4) / 1) = 2.8284.
        $one = Get-EpicProgressPooledVelocity -Feature @(Get-TestFeatureRecord -Issue '1' -Rate 6) -DefaultRate 12
        $two = Get-EpicProgressPooledVelocity -Feature @(Get-TestFeatureRecord -Issue '1' -Rate 6; Get-TestFeatureRecord -Issue '2' -Rate 10) -DefaultRate 12

        [double]::IsNaN($one.StandardDeviation) | Should -BeTrue
        $one.Count | Should -Be 1
        [double]::IsFinite($two.StandardDeviation) | Should -BeTrue
        [math]::Round($two.StandardDeviation, 4) | Should -Be 2.8284
        $two.Median | Should -Be 8
    }

    It 'labels a qualifying feature own and a short feature pooled' {
        # Issue 12 qualifies at 6 tasks per hour (6 x 600 s); issue 13 has 4 tasks and takes the pooled 6.
        $ledger = @{ execution = @(Get-TestExecLedger -Issue '12' -Count 6 -Seconds 600) + @(Get-TestExecLedger -Issue '13' -Count 4 -Seconds 60) }
        $features = @('12', '13' | ForEach-Object { Get-EpicProgressFeatureVelocity -Issue $_ -Ledger $ledger })

        $pooled = Get-EpicProgressPooledVelocity -Feature $features -DefaultRate (Get-EpicProgressDefaultRate -Default (Resolve-EpicProgressStepDefault))

        $pooled.Rate[0].Source | Should -Be 'own'
        $pooled.Rate[0].TasksPerHour | Should -Be 6
        $pooled.Rate[1].Source | Should -Be 'pooled'
        $pooled.Rate[1].TasksPerHour | Should -Be 6
    }

    It 'labels every feature default with rate 12 when none qualifies' {
        $ledger = @{ execution = @(Get-TestExecLedger -Issue '12' -Count 4 -Seconds 600) }
        $features = @('12', '13' | ForEach-Object { Get-EpicProgressFeatureVelocity -Issue $_ -Ledger $ledger })

        $pooled = Get-EpicProgressPooledVelocity -Feature $features -DefaultRate (Get-EpicProgressDefaultRate -Default (Resolve-EpicProgressStepDefault))

        $pooled.Count | Should -Be 0
        [double]::IsNaN($pooled.Median) | Should -BeTrue
        @($pooled.Rate | ForEach-Object { $_.Source }) | Should -Be @('default', 'default')
        @($pooled.Rate | ForEach-Object { $_.TasksPerHour }) | Should -Be @(12, 12)
    }
}

Describe 'Get-EpicProgressDefaultRate (AC-15)' {
    It 'derives 12 tasks per hour from the built-in 5-minute execution default' {
        # 3600 / 300 = 12.
        Get-EpicProgressDefaultRate -Default (Resolve-EpicProgressStepDefault) | Should -Be 12
    }

    It 'derives 10 tasks per hour from an execution override of 6 minutes' {
        # 3600 / 360 = 10.
        Get-EpicProgressDefaultRate -Default (Resolve-EpicProgressStepDefault -StepDefaultMinutes @{ execution = 6 }) | Should -Be 10
    }
}
