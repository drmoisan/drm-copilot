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

Describe 'Get-EpicProgressAggregateVelocity (AC-16, AC-17, E12)' {
    BeforeAll {
        function Get-TestTaskSample {
            # One version-3 check-in sample at Ts seconds holding Tasks done tasks.
            param([long] $Ts, [int] $Tasks)
            [pscustomobject]@{ ts = $Ts; done = 0; tasks = $Tasks; features = @{} }
        }
    }

    It 'averages done tasks since the baseline over elapsed hours minus the pause span' {
        # 3 h elapsed with a 1 h pause: 10 tasks over 2 active hours = 5; without the pause 10 / 3 h.
        # The samples at 0 and 600 s form one interval that ends before the pause, so an average exists.
        $samples = @(Get-TestTaskSample -Ts 0 -Tasks 10; Get-TestTaskSample -Ts 600 -Tasks 11)
        $paused = Get-EpicProgressAggregateVelocity -Sample $samples -PauseSpan @([pscustomobject]@{ startUnixSeconds = 3600; endUnixSeconds = 7200 }) -StartUnixSeconds 0 -NowUnixSeconds 10800 -DoneTasks 20 -BaselineDoneTasks 10
        $plain = Get-EpicProgressAggregateVelocity -Sample $samples -StartUnixSeconds 0 -NowUnixSeconds 10800 -DoneTasks 20 -BaselineDoneTasks 10

        $paused.Average | Should -Be 5
        [math]::Round($plain.Average, 4) | Should -Be 3.3333
    }

    It 'returns a non-finite average below one interval and a finite one from one interval' -ForEach @(
        @{ Gap = 599; Finite = $false }
        @{ Gap = 600; Finite = $true }
        @{ Gap = 601; Finite = $true }
    ) {
        # 1 task since the baseline; samples at 0 and Gap s form an interval only from 600 s (CR2).
        $samples = @(Get-TestTaskSample -Ts 0 -Tasks 0; Get-TestTaskSample -Ts $Gap -Tasks 1)

        $velocity = Get-EpicProgressAggregateVelocity -Sample $samples -StartUnixSeconds 0 -NowUnixSeconds $Gap -DoneTasks 1 -BaselineDoneTasks 0

        [double]::IsNaN($velocity.Average) | Should -Be (-not $Finite) -Because "the interval count is $($velocity.Count)"
        if ($Gap -eq 600) { [math]::Round($velocity.Average, 9) | Should -Be 6 -Because '1 task over 600 s is 6 tasks per hour' }
    }

    It 'returns a non-finite average when every interval overlaps a pause span' {
        # Samples 4000 s apart form one interval; the 1000-2000 span overlaps it, so 0 intervals remain.
        $samples = @(Get-TestTaskSample -Ts 0 -Tasks 0; Get-TestTaskSample -Ts 4000 -Tasks 4)
        $pause = @([pscustomobject]@{ startUnixSeconds = 1000; endUnixSeconds = 2000 })

        $paused = Get-EpicProgressAggregateVelocity -Sample $samples -PauseSpan $pause -StartUnixSeconds 0 -NowUnixSeconds 4000 -DoneTasks 4 -BaselineDoneTasks 0
        $plain = Get-EpicProgressAggregateVelocity -Sample $samples -StartUnixSeconds 0 -NowUnixSeconds 4000 -DoneTasks 4 -BaselineDoneTasks 0

        $paused.Count | Should -Be 0
        [double]::IsNaN($paused.Average) | Should -BeTrue
        $plain.Count | Should -Be 1
        [math]::Round($plain.Average, 4) | Should -Be 3.6
    }

    It 'returns a non-finite average without a task baseline' {
        $velocity = Get-EpicProgressAggregateVelocity -Sample @() -StartUnixSeconds 0 -NowUnixSeconds 3600 -DoneTasks 4

        [double]::IsNaN($velocity.Average) | Should -BeTrue
        [double]::IsNaN($velocity.Recent) | Should -BeTrue
        $velocity.Count | Should -Be 0
    }

    It 'prints n/a for the SD of 2 intervals and a finite SD for 3' {
        # Rates: 0-1200 gives 2 tasks in 1/3 h = 6; 1200-2400 gives 4 in 1/3 h = 12; 2400-3600 gives 3 = 9.
        # Three rates 6, 12, 9: mean 9, squared deviations 9 + 9 + 0 = 18, 18 / 2 = 9, SD 3.
        $two = @(Get-TestTaskSample -Ts 0 -Tasks 0; Get-TestTaskSample -Ts 1200 -Tasks 2; Get-TestTaskSample -Ts 2400 -Tasks 6)
        $three = $two + @(Get-TestTaskSample -Ts 3600 -Tasks 9)

        $velocityTwo = Get-EpicProgressAggregateVelocity -Sample $two -StartUnixSeconds 0 -NowUnixSeconds 2400 -DoneTasks 6 -BaselineDoneTasks 0
        $velocityThree = Get-EpicProgressAggregateVelocity -Sample $three -StartUnixSeconds 0 -NowUnixSeconds 3600 -DoneTasks 9 -BaselineDoneTasks 0

        $velocityTwo.Count | Should -Be 2
        $velocityTwo.Recent | Should -Be 12
        Format-EpicProgressNumber -Value $velocityTwo.StandardDeviation -Digits 1 | Should -Be 'n/a'
        $velocityThree.Count | Should -Be 3
        $velocityThree.Recent | Should -Be 9
        $velocityThree.StandardDeviation | Should -Be 3
    }

    It 'combines consecutive samples until 600 seconds have elapsed' -ForEach @(
        @{ Gap = 599; Expected = 0 }
        @{ Gap = 600; Expected = 1 }
        @{ Gap = 601; Expected = 1 }
    ) {
        $samples = @(Get-TestTaskSample -Ts 0 -Tasks 0; Get-TestTaskSample -Ts $Gap -Tasks 1)

        (Get-EpicProgressAggregateVelocity -Sample $samples -StartUnixSeconds 0 -NowUnixSeconds $Gap -DoneTasks 1 -BaselineDoneTasks 0).Count | Should -Be $Expected
    }

    It 'forms exactly 0-20 and 20-40 from samples at 0, 7, 20, 27 and 40 minutes' {
        $samples = @(0, 7, 20, 27, 40 | ForEach-Object { Get-TestTaskSample -Ts ($_ * 60) -Tasks $_ })

        $velocity = Get-EpicProgressAggregateVelocity -Sample $samples -StartUnixSeconds 0 -NowUnixSeconds 2400 -DoneTasks 40 -BaselineDoneTasks 0

        @($velocity.Interval | ForEach-Object { "$($_.StartUnixSeconds)-$($_.EndUnixSeconds)" }) | Should -Be @('0-1200', '1200-2400')
    }

    It 'skips a trailing remainder under 600 seconds' {
        $samples = @(Get-TestTaskSample -Ts 0 -Tasks 0; Get-TestTaskSample -Ts 1200 -Tasks 4; Get-TestTaskSample -Ts 1500 -Tasks 5)

        $velocity = Get-EpicProgressAggregateVelocity -Sample $samples -StartUnixSeconds 0 -NowUnixSeconds 1500 -DoneTasks 5 -BaselineDoneTasks 0

        @($velocity.Interval | ForEach-Object { "$($_.StartUnixSeconds)-$($_.EndUnixSeconds)" }) | Should -Be @('0-1200')
    }

    It 'drops an interval overlapping a pause span and keeps one ending where it starts' {
        # The 1200-5000 gap is the pause span; 0-1200 ends at its start and 5000-6200 starts at its end.
        $samples = @(Get-TestTaskSample -Ts 0 -Tasks 0; Get-TestTaskSample -Ts 1200 -Tasks 2; Get-TestTaskSample -Ts 5000 -Tasks 3; Get-TestTaskSample -Ts 6200 -Tasks 5)
        $pause = @([pscustomobject]@{ startUnixSeconds = 1200; endUnixSeconds = 5000 })

        $velocity = Get-EpicProgressAggregateVelocity -Sample $samples -PauseSpan $pause -StartUnixSeconds 0 -NowUnixSeconds 6200 -DoneTasks 5 -BaselineDoneTasks 0

        @($velocity.Interval | ForEach-Object { "$($_.StartUnixSeconds)-$($_.EndUnixSeconds)" }) | Should -Be @('0-1200', '5000-6200')
    }

    It 'ignores migrated version-2 samples without a tasks value when forming intervals' {
        # v2 samples at 0 and 20 min carry no tasks; v3 samples at 40, 60 and 80 min give 40-60 and 60-80.
        $v2 = @([pscustomobject]@{ ts = 0; done = 1 }; [pscustomobject]@{ ts = 1200; done = 2 })
        $v3 = @(Get-TestTaskSample -Ts 2400 -Tasks 3; Get-TestTaskSample -Ts 3600 -Tasks 5; Get-TestTaskSample -Ts 4800 -Tasks 8)
        $allTasks = @(Get-TestTaskSample -Ts 0 -Tasks 1; Get-TestTaskSample -Ts 1200 -Tasks 2) + $v3

        $migrated = Get-EpicProgressAggregateVelocity -Sample ($v2 + $v3) -StartUnixSeconds 0 -NowUnixSeconds 4800 -DoneTasks 8 -BaselineDoneTasks 0
        $full = Get-EpicProgressAggregateVelocity -Sample $allTasks -StartUnixSeconds 0 -NowUnixSeconds 4800 -DoneTasks 8 -BaselineDoneTasks 0

        @($migrated.Interval | ForEach-Object { "$($_.StartUnixSeconds)-$($_.EndUnixSeconds)" }) | Should -Be @('2400-3600', '3600-4800')
        @($full.Interval | ForEach-Object { "$($_.StartUnixSeconds)-$($_.EndUnixSeconds)" }) | Should -Be @('0-1200', '1200-2400', '2400-3600', '3600-4800')
    }
}

Describe 'Get-EpicProgressPauseSpan and Get-EpicProgressResetPauseSpan (AC-18, AC-19)' {
    It 'records a span only for a gap strictly longer than 3600 seconds' -ForEach @(
        @{ Gap = 3599; Expected = 0 }
        @{ Gap = 3600; Expected = 0 }
        @{ Gap = 3601; Expected = 1 }
    ) {
        @(Get-EpicProgressPauseSpan -SampleInstant @(1000, (1000 + $Gap))).Count | Should -Be $Expected
    }

    It 'records the span from the earlier to the later sample of a 3601-second gap' {
        $spans = @(Get-EpicProgressPauseSpan -SampleInstant @(500, 1000, 4601, 5000))

        $spans.Count | Should -Be 1
        $spans[0].startUnixSeconds | Should -Be 1000
        $spans[0].endUnixSeconds | Should -Be 4601
    }

    It 'returns the reset span from the newest stored sample to the resume instant' {
        $span = Get-EpicProgressResetPauseSpan -SampleInstant @(100, 500, 300) -ResumeUnixSeconds 9000

        $span.startUnixSeconds | Should -Be 500
        $span.endUnixSeconds | Should -Be 9000
    }

    It 'returns no reset span without a stored sample' {
        Get-EpicProgressResetPauseSpan -SampleInstant @() -ResumeUnixSeconds 9000 | Should -BeNullOrEmpty
    }
}

Describe 'Get-EpicProgressExcludedSecond (E11)' {
    It 'counts a pause span alone inside the interval' {
        # Pause 100-300 inside 0-1000: 200 s.
        Get-EpicProgressExcludedSecond -PauseSpan @([pscustomobject]@{ startUnixSeconds = 100; endUnixSeconds = 300 }) -IntervalStartUnixSeconds 0 -IntervalEndUnixSeconds 1000 | Should -Be 200
    }

    It 'counts an open blocked span alone up to the interval end' {
        # Blocked since 600 with no end: 600-1000 = 400 s.
        Get-EpicProgressExcludedSecond -BlockedSinceUnixSeconds 600 -IntervalStartUnixSeconds 0 -IntervalEndUnixSeconds 1000 | Should -Be 400
    }

    It 'counts overlapping pause and blocked spans once' {
        # Pause 100-500 and blocked 300-700 merge to 100-700 = 600 s, not 400 + 400.
        Get-EpicProgressExcludedSecond -PauseSpan @([pscustomobject]@{ startUnixSeconds = 100; endUnixSeconds = 500 }) -BlockedSinceUnixSeconds 300 -BlockedUntilUnixSeconds 700 -IntervalStartUnixSeconds 0 -IntervalEndUnixSeconds 1000 | Should -Be 600
    }

    It 'sums disjoint pause and blocked spans and clips them to the interval' {
        # Pause 100-200 (100 s) plus blocked 800 to beyond the end, clipped at 1000 (200 s); a span before the interval adds nothing.
        $pauses = @([pscustomobject]@{ startUnixSeconds = 100; endUnixSeconds = 200 }; [pscustomobject]@{ startUnixSeconds = -500; endUnixSeconds = -100 })

        Get-EpicProgressExcludedSecond -PauseSpan $pauses -BlockedSinceUnixSeconds 800 -BlockedUntilUnixSeconds 5000 -IntervalStartUnixSeconds 0 -IntervalEndUnixSeconds 1000 | Should -Be 300
        Get-EpicProgressExcludedSecond -IntervalStartUnixSeconds 0 -IntervalEndUnixSeconds 1000 | Should -Be 0
    }
}
