# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1 (issues #1080, #1093).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory input and asserts the returned lines.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath
}

Describe 'Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine' {
    BeforeAll {
        $script:startUtc = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)
        $script:nowUtc = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)

        function Get-TestFeature {
            param([string] $Issue, [int] $Wave, [string] $Band, [int] $Total, [int] $Done, [string] $State, [string] $Phase = '', [string] $Pr = '')
            [pscustomobject]@{ Issue = $Issue; Wave = $Wave; Band = $Band; Total = $Total; Done = $Done; State = $State; Phase = $Phase; Pr = $Pr }
        }

        function Get-TestSummary {
            param([object[]] $Feature, [object[]] $Sample = @(), [double] $WeeklyPct = 42.5, [datetime] $StartUtc = $script:startUtc)
            Get-EpicProgressSummary -Feature $Feature -BaselineDone 0 -StartUtc $StartUtc -NowUtc $script:nowUtc -Sample $Sample -WaveOverheadHours 1.25 -WeeklyPct $WeeklyPct -BaselineWeeklyPct 0 -EpicIssue '42' -EpicName 'example-epic'
        }

        # Three features: one Completed (wave 1), one Running (wave 2), one Pending (wave 3).
        $script:threeFeatures = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 2 -Done 2 -State 'Completed' -Pr '#7 MERGED'
            Get-TestFeature -Issue '12345' -Wave 2 -Band 'large' -Total 5 -Done 1 -State 'Running' -Phase 'Phase 1 - Build' -Pr '#8 OPEN'
            Get-TestFeature -Issue '77' -Wave 3 -Band 'medium' -Total 3 -Done 0 -State 'Pending'
        )
        # Hourly samples with done 0, 1, 3, 3: intervals 1, 2, 0 (mean 1, SD 1, recent 0).
        $script:hourlySamples = @(
            [pscustomobject]@{ ts = 1000; done = 0 }
            [pscustomobject]@{ ts = 4600; done = 1 }
            [pscustomobject]@{ ts = 8200; done = 3 }
            [pscustomobject]@{ ts = 11800; done = 3 }
        )
    }

    It 'composes the four TL;DR lines' {
        $summary = Get-TestSummary -Feature $script:threeFeatures -Sample $script:hourlySamples

        $lines = @(Get-EpicProgressTldrLine -Summary $summary)

        $expected = @(
            '**TL;DR:** Epic #42 is at 3 of 10 tasks (30%). 1 of 3 features are done. #12345 is running (1 of 5).'
            '**Elapsed:** 3 h 00 min, with about 10 hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.'
            '**Avg Velocity:** 1 tasks / hr. **Recent Velocity:** 0 tasks / hr since last check-in. (SD of recent velocity: 1, from 3 intervals)'
            '**Estimated time remaining:** 04:48 hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)'
        )
        ($lines -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'composes the Full lines in recovered order' {
        $summary = Get-TestSummary -Feature $script:threeFeatures -Sample $script:hourlySamples

        $lines = @(Get-EpicProgressFullLine -Summary $summary)

        $expected = @(
            ''
            '## Epic #42 example-epic: status at 12:00 UTC, Jan 5'
            ''
            '**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 3 of 10 tasks complete, **30%**.'
            ''
            '| State | Features |'
            '|---|---|'
            '| Completed | #12 |'
            '| Running | #12345 (wave 2, large): 1 of 5 tasks (20%). Now at: Phase 1 - Build. PR #8 OPEN. |'
            '| Pending, wave 3 | #77 (3) |'
            ''
            '| Wave | Children | Tasks | Done |'
            '|---|---|---|---|'
            '| 1 | 1 | 2 | 2 |'
            '| 2 | 1 | 5 | 1 |'
            '| 3 | 1 | 3 | 0 |'
            '| **Total** | **3** | **10** | **3** |'
            ''
            "**Velocity:** 1 tasks per hour (one child's pace). **Remaining:** 7 tasks."
            '- Straight line, no parallelism: about 7 h 00 min (upper bound).'
            '- Wave-parallel (longest chain 7 tasks plus about 1.25 h per open wave for review and CI): about **9 h 30 min**.'
            "**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
        )
        $lines.Count | Should -Be $expected.Count
        ($lines -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'states that no feature is running' {
        $features = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 2 -Done 2 -State 'Completed'
            Get-TestFeature -Issue '77' -Wave 2 -Band 'medium' -Total 3 -Done 0 -State 'Pending'
        )

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features))

        $lines[0] | Should -Be '**TL;DR:** Epic #42 is at 2 of 5 tasks (40%). 1 of 2 features are done. No feature is running.'
    }

    It 'names a single running feature' {
        $features = @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 4 -Done 3 -State 'Running')

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features))

        $lines[0] | Should -Be '**TL;DR:** Epic #42 is at 3 of 4 tasks (75%). None of the 1 features is done yet. #12345 is running (3 of 4).'
    }

    It 'lists several running features' {
        $features = @(
            Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 5 -Done 1 -State 'Running'
            Get-TestFeature -Issue '600' -Wave 1 -Band 'small' -Total 4 -Done 2 -State 'Running'
        )

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features))

        $lines[0] | Should -Be '**TL;DR:** Epic #42 is at 3 of 9 tasks (33.3%). None of the 2 features is done yet. #12345 (1 of 5), #600 (2 of 4) are running.'
    }

    It 'states that no feature is done yet' {
        $features = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 2 -Done 1 -State 'Running'
            Get-TestFeature -Issue '77' -Wave 2 -Band 'medium' -Total 3 -Done 0 -State 'Pending'
        )
        $summary = Get-TestSummary -Feature $features

        $tldr = @(Get-EpicProgressTldrLine -Summary $summary)
        $full = @(Get-EpicProgressFullLine -Summary $summary)

        $tldr[0] | Should -Be '**TL;DR:** Epic #42 is at 1 of 5 tasks (20%). None of the 2 features is done yet. #12 is running (1 of 2).'
        $full | Should -Contain '| Completed | None yet |'
        $full | Should -Contain '| Running | #12 (wave 1, small): 1 of 2 tasks (50%). |'
    }

    Context 'non-finite values print n/a' {
        BeforeAll {
            # No task done since the baseline (velocity 0), no samples, and no weekly quota.
            $features = @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 4 -Done 0 -State 'Running')
            $script:naSummary = Get-TestSummary -Feature $features -WeeklyPct ([double]::NaN)
            $script:naTldr = @(Get-EpicProgressTldrLine -Summary $script:naSummary)
            $script:naFull = @(Get-EpicProgressFullLine -Summary $script:naSummary)
        }

        It 'prints n/a for the straight-line hours' {
            $script:naFull | Should -Contain '- Straight line, no parallelism: about n/a (upper bound).'
        }

        It 'prints n/a for the wave-parallel hours' {
            $script:naFull | Should -Contain '- Wave-parallel (longest chain 4 tasks plus about 1.25 h per open wave for review and CI): about **n/a**.'
        }

        It 'prints n/a for the hours-left figure' {
            $script:naTldr[1] | Should -BeLike '*, with about n/a hours left on the wave-parallel estimate. *'
        }

        It 'prints n/a for the range' {
            $script:naTldr[3] | Should -Be '**Estimated time remaining:** n/a hrs (range needs 3 or more check-in intervals)'
        }

        It 'prints n/a for the weekly quota and its delta' {
            $script:naTldr[1] | Should -BeLike '* **Weekly** quota is at n/a.'
            $script:naFull[-1] | Should -BeLike '**Weekly quota (active account):** n/a used, n/a points since the epic started. *'
        }

        It 'prints n/a estimates at zero elapsed time' {
            $features = @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 4 -Done 2 -State 'Running')
            $summary = Get-TestSummary -Feature $features -StartUtc $script:nowUtc

            $tldr = @(Get-EpicProgressTldrLine -Summary $summary)

            $tldr[1] | Should -Be '**Elapsed:** 0 h 00 min, with about n/a hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.'
            $tldr[2] | Should -Be '**Avg Velocity:** 0 tasks / hr. **Recent Velocity:** n/a tasks / hr since last check-in. (SD of recent velocity: n/a, from 0 intervals)'
        }

        It 'clamps elapsed time at zero when the start is after now' {
            # A start 30 minutes in the future would otherwise print -1 h 30 min.
            $features = @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 4 -Done 2 -State 'Running')
            $summary = Get-TestSummary -Feature $features -StartUtc $script:nowUtc.AddMinutes(30)

            $tldr = @(Get-EpicProgressTldrLine -Summary $summary)

            $summary.ElapsedHours | Should -Be 0
            $tldr[1] | Should -Be '**Elapsed:** 0 h 00 min, with about n/a hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.'
        }
    }
}
