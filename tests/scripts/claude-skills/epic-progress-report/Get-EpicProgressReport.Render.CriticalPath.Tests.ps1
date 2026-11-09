# Pester tests for the issue #1153 rendering in .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1:
# the five-line TL;DR (decision E1), the per-feature table and critical-path section, the push text,
# and n/a printing of every new figure. The Logic hub is dot-sourced; every function under test is
# pure, so each test supplies fixed in-memory records and asserts the returned lines. Each comment
# states how a golden value follows from the fixture.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath
}

Describe 'Five-line TL;DR, critical-path section and push text (issue #1153)' {
    BeforeAll {
        $script:startUtc = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)
        $script:nowUtc = [datetime]::new(2026, 1, 5, 12, 10, 0, [System.DateTimeKind]::Utc)
        # 2026-01-05T12:10:00Z.
        $script:nowUnix = 1767615000
        $script:defaults = Resolve-EpicProgressStepDefault

        function Get-TestFeature {
            param([string] $Issue, [int] $Total, [int] $Done, [string] $State, [int] $TasksDone, [int] $TasksTotal, [int] $Wave = 1, [string] $BlockedReason = '')
            [pscustomobject]@{ Issue = $Issue; Wave = $Wave; Band = 'small'; Total = $Total; Done = $Done; State = $State; Phase = ''; Pr = ''; BlockedReason = $BlockedReason; TasksDone = $TasksDone; TasksTotal = $TasksTotal }
        }

        function Get-TestRange {
            param([double] $FastSeconds = 6000, [double] $SlowSeconds = 12600, [bool] $NoUpperBound = $false, [string] $SdSource = 'across-feature SD', [string] $Reason = '')
            [pscustomobject]@{ FastSeconds = $FastSeconds; SlowSeconds = $SlowSeconds; NoUpperBound = $NoUpperBound; StandardDeviation = 2.0; SdSource = $SdSource; Reason = $Reason }
        }

        function Get-TestPath {
            # A critical-path record: pooled median 8 tasks / hr (SD 2, 3 qualifying), cap 4 from config,
            # dependency source checkpoint, a 45-minute integration-pr tail, and the headline 2 h 05 min.
            param(
                [double] $HeadlineSeconds = 7500, [double] $FinishSeconds = 4800, [double] $SerialSumSeconds = 15300,
                [string] $Chain = '#12345 -> #12346 -> tail', [object[]] $Excluded = @(), [object[]] $FeatureRow = @(),
                [object] $Range = (Get-TestRange), [object] $Pooled = $null, [string] $GraphMessage = '', [object] $Tail = $null
            )
            if ($null -eq $Pooled) {
                $rates = @('12', '12345', '12346' | ForEach-Object { [pscustomobject]@{ Issue = $_; TasksPerHour = 8.0; Source = 'pooled' } })
                $Pooled = [pscustomobject]@{ Median = 8.0; StandardDeviation = 2.0; Count = 3; Rate = $rates }
            }
            if ($null -eq $Tail) { $Tail = [pscustomobject]@{ TailSeconds = 2700.0; PredictedSync = $false; Step = @([pscustomobject]@{ Type = 'integration-pr'; Seconds = 2700.0 }) } }
            [pscustomobject]@{
                Feature = $FeatureRow; Excluded = $Excluded; Pooled = $Pooled; DefaultRate = 12.0; Cap = 4; CapSource = 'config'
                DependencySource = 'checkpoint'; GraphMessage = $GraphMessage; Tail = $Tail; FinishSeconds = $FinishSeconds
                HeadlineSeconds = $HeadlineSeconds; Chain = $Chain; SerialSumSeconds = $SerialSumSeconds; Range = $Range
            }
        }

        function Get-TestSummary {
            param([object[]] $Feature, [object] $Path = (Get-TestPath), [object] $Aggregate = $null, [string] $Subject = 'Epic', [string] $EpicIssue = '42', [object[]] $EpicStep = @())
            $estimate = Get-EpicProgressTypeEstimate -Step @(Get-EpicProgressStepRecord -Issue '12' -Type 'review') -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:nowUnix
            Get-EpicProgressSummary -Feature $Feature -EpicStep $EpicStep -Estimate $estimate -CriticalPath $Path -Aggregate $Aggregate -Subject $Subject -StartUtc $script:startUtc -NowUtc $script:nowUtc -WeeklyPct 41 -BaselineWeeklyPct 0 -EpicIssue $EpicIssue
        }

        # AC-02: steps 10/10 + 6/13 + 3/11 + 0/1 (integration-pr) = 19 of 35; tasks 20/20 + 11/25 + 0/15 = 31 of 60.
        $script:features = @(
            Get-TestFeature -Issue '12' -Total 10 -Done 10 -State 'Completed' -TasksDone 20 -TasksTotal 20
            Get-TestFeature -Issue '12345' -Total 13 -Done 6 -State 'Running' -TasksDone 11 -TasksTotal 25 -Wave 2
            Get-TestFeature -Issue '12346' -Total 11 -Done 3 -State 'Pending' -TasksDone 0 -TasksTotal 15 -Wave 3
        )
        $script:epicStep = @(Get-EpicProgressStepRecord -Issue '42' -Type 'integration-pr')
        $script:aggregate = [pscustomobject]@{ Average = 9.5; Recent = 7.2; StandardDeviation = 1.8; Count = 6 }
        $script:summary = Get-TestSummary -Feature $script:features -Aggregate $script:aggregate -EpicStep $script:epicStep
        $script:tldr = @(Get-EpicProgressTldrLine -Summary $script:summary)
    }

    It 'prints exactly five TL;DR lines with the E1 prefixes in order, and the same five before the Full report (AC-01)' {
        $full = @(Get-EpicProgressFullLine -Summary $script:summary)
        $fullMode = @($script:tldr + $full)
        $prefixes = @('**TL;DR:**', '**Elapsed:**', '**Now:**', '**Velocity:**', '**Estimated time remaining:**')

        $script:tldr.Count | Should -Be 5
        for ($index = 0; $index -lt 5; $index++) {
            $script:tldr[$index].StartsWith($prefixes[$index]) | Should -BeTrue -Because "line $index starts with $($prefixes[$index])"
            $fullMode[$index] | Should -Be $script:tldr[$index]
        }
        $fullMode[6] | Should -BeLike '## Epic #42: status at 12:10 UTC*'
    }

    It 'states tasks first and steps second with the step percentage (AC-02)' {
        # 19 / 35 = 54.29%, printed to one decimal.
        $script:tldr[0] | Should -Be '**TL;DR:** Epic #42 is at 31 of 60 tasks, 19 of 35 steps (54.3%). 1 of 3 features are done. #12345 is running (6 of 13 steps).'
    }

    It 'prints the elapsed time, headline, chain and cap, and ends with the weekly quota (AC-03)' {
        # 09:00 to 12:10 is 3 h 10 min; the headline is 7500 s (2 h 05 min).
        $script:tldr[1] | Should -Be '**Elapsed:** 3 h 10 min; critical path about 2 h 05 min left (#12345 -> #12346 -> tail, cap 4). **Weekly** quota is at 41%.'
    }

    It 'prints the sequential rate with its source, count and SD, then the aggregate figures (AC-04)' {
        $script:tldr[3] | Should -Be '**Velocity:** sequential 8 tasks / hr per feature (pooled, median of 3, SD 2); aggregate 9.5 tasks / hr average, 7.2 recent, SD 1.8 over 6 intervals (aggregate, informational).'
    }

    It 'prints a single feature with its own rate and source (AC-04)' {
        $pooled = [pscustomobject]@{ Median = 6.0; StandardDeviation = [double]::NaN; Count = 1; Rate = @([pscustomobject]@{ Issue = '12345'; TasksPerHour = 6.0; Source = 'own' }) }
        $summary = Get-TestSummary -Feature @(Get-TestFeature -Issue '12345' -Total 4 -Done 1 -State 'Running' -TasksDone 5 -TasksTotal 8) -Path (Get-TestPath -Pooled $pooled)

        (Get-EpicProgressTldrLine -Summary $summary)[3] | Should -BeLike '**Velocity:** sequential 6 tasks / hr per feature (own, median of 1, SD n/a); aggregate n/a tasks / hr average, n/a recent, SD n/a over 0 intervals (aggregate, informational).'
    }

    It 'prints the range with its SD source and the labelled serial sum (AC-05)' {
        # Fast 6000 s (1 h 40 min), slow 12600 s (3 h 30 min), serial sum 15300 s (4 h 15 min).
        $script:tldr[4] | Should -Be '**Estimated time remaining:** range 1 h 40 min to 3 h 30 min (velocity +/- 2.05 SD, across-feature SD); serial sum 4 h 15 min (upper bound, no parallelism).'
    }

    It 'prints no upper bound for the slow end and n/a with the reason when no SD exists (AC-05)' {
        $unbounded = Get-TestSummary -Feature $script:features -Path (Get-TestPath -Range (Get-TestRange -SlowSeconds ([double]::PositiveInfinity) -NoUpperBound $true))
        $noSd = Get-TestSummary -Feature $script:features -Path (Get-TestPath -Range (Get-TestRange -SdSource 'n/a' -Reason 'fewer than 2 qualifying features and fewer than 3 intervals'))

        (Get-EpicProgressTldrLine -Summary $unbounded)[4] | Should -BeLike '*range 1 h 40 min to no upper bound (velocity +/- 2.05 SD, across-feature SD); serial sum 4 h 15 min (upper bound, no parallelism).'
        (Get-EpicProgressTldrLine -Summary $noSd)[4] | Should -BeLike '*range n/a (fewer than 2 qualifying features and fewer than 3 intervals); serial sum *'
    }

    It 'prints no wave-parallel text in either mode, and the retired function is not defined (AC-06)' {
        $item = Get-TestSummary -Feature @(Get-TestFeature -Issue '42' -Total 4 -Done 2 -State 'Running' -TasksDone 1 -TasksTotal 2) -Path (Get-TestPath -Chain '#42') -Subject 'Item'
        $lines = @($script:tldr) + @(Get-EpicProgressFullLine -Summary $script:summary) + @(Get-EpicProgressTldrLine -Summary $item) + @(Get-EpicProgressFullLine -Summary $item)

        @($lines | Where-Object { $_ -like '*wave-parallel*' }).Count | Should -Be 0
        Get-Command -Name 'Get-EpicProgressWaveParallelSecond' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    It 'prints the per-feature table, the critical-path section and the step-type table in Full mode (AC-07)' {
        # #12 done; #12345 runs 0 to 1 h 20 min; #12346 is excluded with 50 min left.
        $rows = @(
            [pscustomobject]@{ Issue = '12'; State = 'Completed'; TasksDone = 20; TasksTotal = 20; Rate = 8.0; RateSource = 'own'; RemainingSeconds = 0.0; StartSeconds = 0.0; FinishSeconds = 0.0; Excluded = $false }
            [pscustomobject]@{ Issue = '12345'; State = 'Running'; TasksDone = 11; TasksTotal = 25; Rate = 8.0; RateSource = 'pooled'; RemainingSeconds = 4800.0; StartSeconds = 0.0; FinishSeconds = 4800.0; Excluded = $false }
            [pscustomobject]@{ Issue = '12346'; State = 'Blocked'; TasksDone = 0; TasksTotal = 15; Rate = 12.0; RateSource = 'default'; RemainingSeconds = 3000.0; StartSeconds = [double]::NaN; FinishSeconds = [double]::NaN; Excluded = $true }
        )
        $tail = [pscustomobject]@{ TailSeconds = 6300.0; PredictedSync = $true; Step = @([pscustomobject]@{ Type = 'main-sync'; Seconds = 3600.0 }, [pscustomobject]@{ Type = 'integration-pr'; Seconds = 2700.0 }) }
        $path = Get-TestPath -FeatureRow $rows -Tail $tail -HeadlineSeconds 11100 -Chain '#12345 -> tail' -Excluded @([pscustomobject]@{ Issue = '12346'; RemainingSeconds = 3000.0 }) -GraphMessage 'dependency cycle: #1 -> #2 -> #1; the schedule falls back to waves'

        $full = @(Get-EpicProgressFullLine -Summary (Get-TestSummary -Feature $script:features -Path $path))

        $full | Should -Contain '| Feature | State | Tasks | Rate | Source | Remaining | Start | Finish |'
        $full | Should -Contain '| #12345 | Running | 11 of 25 | 8 tasks / hr | pooled | 1 h 20 min | 0 h 00 min | 1 h 20 min |'
        $full | Should -Contain '| #12346 | Blocked | 0 of 15 | 12 tasks / hr | default | 0 h 50 min | excluded | excluded |'
        # 4800 s of features plus a 6300 s tail is the 11100 s (3 h 05 min) headline.
        $full | Should -Contain '**Critical path:** #12345 -> tail. Headline 3 h 05 min: features finish in 1 h 20 min, then the tail of 1 h 45 min (main-sync 1 h 00 min, integration-pr 0 h 45 min), main-sync predicted.'
        $full | Should -Contain '**Schedule inputs:** dependency source checkpoint; cap 4 (config).'
        $full | Should -Contain '**Dependency graph:** dependency cycle: #1 -> #2 -> #1; the schedule falls back to waves.'
        $full | Should -Contain '**Serial sum:** 4 h 15 min (upper bound, no parallelism). **Range:** 1 h 40 min to 3 h 30 min (velocity +/- 2.05 SD, across-feature SD).'
        $full | Should -Contain '**Excluded (blocked):** #12346 (0 h 50 min).'
        $full | Should -Contain '| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |'
    }

    It 'prints no graph message line for a valid graph (AC-07)' {
        @(Get-EpicProgressFullLine -Summary $script:summary | Where-Object { $_ -like '**Dependency graph:*' }).Count | Should -Be 0
    }

    Context 'push-notification text (AC-08)' {
        BeforeAll {
            function Get-TestPushSummary {
                # One running feature; the epic issue text pads the first line to a chosen length.
                param([string] $EpicIssue)
                Get-TestSummary -Feature @(Get-TestFeature -Issue '12345' -Total 2 -Done 1 -State 'Running' -TasksDone 1 -TasksTotal 2) -EpicIssue $EpicIssue
            }
            $script:baseLength = (Get-EpicProgressPushText -Summary (Get-TestPushSummary -EpicIssue '1')).Length
        }

        It 'keeps the running sentence at 199 characters' {
            $summary = Get-TestPushSummary -EpicIssue ('1' + ('0' * (199 - $script:baseLength)))
            $stripped = (Get-EpicProgressTldrLine -Summary $summary)[0].Replace('**', '')

            $push = Get-EpicProgressPushText -Summary $summary

            $stripped.Length | Should -Be 199
            $push | Should -Be $stripped
            $push | Should -BeLike '*#12345 is running (1 of 2 steps).'
        }

        It 'drops the running sentence at 200 characters' {
            $summary = Get-TestPushSummary -EpicIssue ('1' + ('0' * (200 - $script:baseLength)))
            $stripped = (Get-EpicProgressTldrLine -Summary $summary)[0].Replace('**', '')

            $push = Get-EpicProgressPushText -Summary $summary

            $stripped.Length | Should -Be 200
            $push | Should -Be $stripped.Replace(' #12345 is running (1 of 2 steps).', '')
            $push.Length | Should -BeLessThan 200
            $push | Should -Not -Match '\*\*'
        }

        It 'yields text under 200 characters for eight running features with five-digit task counts' {
            $features = @(1..8 | ForEach-Object { Get-TestFeature -Issue ([string] (10000 + $_)) -Total 13 -Done 3 -State 'Running' -TasksDone 12345 -TasksTotal 54321 })

            $push = Get-EpicProgressPushText -Summary (Get-TestSummary -Feature $features)

            $push.Length | Should -BeLessThan 200
            $push | Should -Not -Match 'are running'
            $push | Should -BeLike 'TL;DR: Epic #42 is at 98760 of 434568 tasks, *'
        }
    }

    It 'prints the item chain with no tail and no cap, and the headline equal to the item remaining time (AC-09)' {
        # One running item with two remaining execution tasks at the 12 tasks / hr default (5 min each)
        # and one remaining review (14 min): 24 min remaining, which is the one-node headline.
        $steps = @(
            Get-EpicProgressStepRecord -Issue '42' -Type 'execution' -Ordinal 1
            Get-EpicProgressStepRecord -Issue '42' -Type 'execution' -Ordinal 2
            Get-EpicProgressStepRecord -Issue '42' -Type 'review'
        )
        $feature = [pscustomobject]@{ Issue = '42'; Wave = 1; Folder = ''; State = 'Running'; Blocked = $false; Step = $steps; TasksDone = 1; TasksTotal = 3 }
        $path = Get-EpicProgressCriticalPathReport -Feature @($feature) -Ledger @{} -Default $script:defaults -NowUnixSeconds $script:nowUnix -ItemMode
        $summary = Get-TestSummary -Feature @(Get-TestFeature -Issue '42' -Total 3 -Done 0 -State 'Running' -TasksDone 1 -TasksTotal 3) -Path $path -Subject 'Item'

        $tldr = @(Get-EpicProgressTldrLine -Summary $summary)

        $path.HeadlineSeconds | Should -Be $path.Feature[0].RemainingSeconds
        $path.HeadlineSeconds | Should -Be 1440
        $tldr[0] | Should -BeLike '**TL;DR:** Item #42 is at 1 of 3 tasks, *'
        $tldr[1] | Should -Be '**Elapsed:** 3 h 10 min; critical path about 0 h 24 min left (#42). **Weekly** quota is at 41%.'
    }

    It 'prints n/a for NaN, positive and negative infinity in every new figure (AC-10)' {
        $nan = [double]::NaN
        $pos = [double]::PositiveInfinity
        $neg = [double]::NegativeInfinity
        $pooled = [pscustomobject]@{ Median = $nan; StandardDeviation = $pos; Count = 2; Rate = @([pscustomobject]@{ Issue = '12'; TasksPerHour = $nan; Source = 'pooled' }, [pscustomobject]@{ Issue = '13'; TasksPerHour = $neg; Source = 'pooled' }) }
        $rows = @([pscustomobject]@{ Issue = '12'; State = 'Running'; TasksDone = 1; TasksTotal = 2; Rate = $neg; RateSource = 'pooled'; RemainingSeconds = $pos; StartSeconds = $neg; FinishSeconds = $nan; Excluded = $false })
        $tail = [pscustomobject]@{ TailSeconds = $nan; PredictedSync = $false; Step = @([pscustomobject]@{ Type = 'integration-pr'; Seconds = $pos }) }
        $path = Get-TestPath -HeadlineSeconds $nan -FinishSeconds $neg -SerialSumSeconds $pos -Pooled $pooled -FeatureRow $rows -Tail $tail -Range (Get-TestRange -FastSeconds $neg -SlowSeconds $nan) -Excluded @([pscustomobject]@{ Issue = '13'; RemainingSeconds = $nan })
        $aggregate = [pscustomobject]@{ Average = $nan; Recent = $pos; StandardDeviation = $neg; Count = 3 }
        $summary = Get-TestSummary -Feature $script:features -Path $path -Aggregate $aggregate

        $lines = @(Get-EpicProgressTldrLine -Summary $summary) + @(Get-EpicProgressFullLine -Summary $summary)

        @($lines | Where-Object { $_ -match 'NaN|Infinity' }).Count | Should -Be 0
        $lines[1] | Should -BeLike '*; critical path about n/a left (*'
        $lines[3] | Should -Be '**Velocity:** sequential n/a tasks / hr per feature (pooled, median of 2, SD n/a); aggregate n/a tasks / hr average, n/a recent, SD n/a over 3 intervals (aggregate, informational).'
        $lines[4] | Should -Be '**Estimated time remaining:** range n/a to n/a (velocity +/- 2.05 SD, across-feature SD); serial sum n/a (upper bound, no parallelism).'
        $lines | Should -Contain '| #12 | Running | 1 of 2 | n/a tasks / hr | pooled | n/a | n/a | n/a |'
        $lines | Should -Contain '**Excluded (blocked):** #13 (n/a).'
    }

    It 'states the blocked exclusion on the Elapsed line, and nothing when no feature is excluded (AC-34)' {
        $excluded = @([pscustomobject]@{ Issue = '77'; RemainingSeconds = 1800.0 }, [pscustomobject]@{ Issue = '78'; RemainingSeconds = 600.0 })
        $summary = Get-TestSummary -Feature $script:features -Path (Get-TestPath -Excluded $excluded)

        $line = (Get-EpicProgressTldrLine -Summary $summary)[1]

        $line | Should -Be '**Elapsed:** 3 h 10 min; critical path about 2 h 05 min left (#12345 -> #12346 -> tail, cap 4; excludes 2 blocked: #77, #78). **Weekly** quota is at 41%.'
        $script:tldr[1] | Should -Not -BeLike '*excludes*'
    }
}
