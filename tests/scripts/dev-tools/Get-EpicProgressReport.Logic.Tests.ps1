# Pester 5 tests for scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 (issue #1080).
# Every function under test is pure, so each test supplies fixed in-memory input and
# asserts the returned data; no file, process, network, or clock is touched.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath

    # Kickoff fixture with a two-digit and a five-digit feature issue and a mid-line marker.
    $script:kickoffText = @(
        '# Example epic kickoff'
        ''
        'Coordinator note. Epic issue: #42 tracks this epic.'
        ''
        '| Issue | Title | Wave | Band | Plan |'
        '|---|---|---|---|---|'
        '| 12 | Alpha | 1 | small | docs/a/plan.md |'
        '| 12345 | Beta | 2 | large | docs/b/plan.md |'
    ) -join "`n"
}

Describe 'ConvertFrom-EpicProgressKickoffRow' {
    It 'parses a feature row with a two-digit issue number' {
        $rows = @(ConvertFrom-EpicProgressKickoffRow -KickoffText $script:kickoffText)

        $rows[0].Issue | Should -Be '12'
        $rows[0].Wave | Should -Be 1
        $rows[0].Band | Should -Be 'small'
        $rows[0].PlanPath | Should -Be 'docs/a/plan.md'
    }

    It 'parses a feature row with a five-digit issue number' {
        $rows = @(ConvertFrom-EpicProgressKickoffRow -KickoffText $script:kickoffText)

        $rows[1].Issue | Should -Be '12345'
        $rows[1].Wave | Should -Be 2
        $rows[1].Band | Should -Be 'large'
        $rows[1].PlanPath | Should -Be 'docs/b/plan.md'
    }

    It 'ignores the header and separator rows' {
        $rows = @(ConvertFrom-EpicProgressKickoffRow -KickoffText $script:kickoffText)

        $rows.Count | Should -Be 2
        ($rows.Issue -join ',') | Should -Be '12,12345'
    }

    It 'returns no rows for an empty kickoff' {
        @(ConvertFrom-EpicProgressKickoffRow -KickoffText '').Count | Should -Be 0
    }
}

Describe 'Get-EpicProgressIssueFromKickoff' {
    It 'returns the issue number from a mid-line Epic issue marker' {
        Get-EpicProgressIssueFromKickoff -KickoffText $script:kickoffText | Should -Be '42'
    }

    It 'returns null when the kickoff has no Epic issue marker' {
        Get-EpicProgressIssueFromKickoff -KickoffText "# Kickoff`n| 12 | Alpha | 1 | small | docs/a/plan.md |" | Should -BeNullOrEmpty
    }
}

Describe 'ConvertFrom-EpicProgressWorktreeList' {
    It 'maps each branch to its worktree path' {
        $lines = @(
            'worktree /repo'
            'HEAD 0000000000000000000000000000000000000001'
            'branch refs/heads/main'
            ''
            'worktree /repo-wt/beta'
            'HEAD 0000000000000000000000000000000000000002'
            'branch refs/heads/feature/beta'
            ''
            'worktree /repo-wt/detached'
            'HEAD 0000000000000000000000000000000000000003'
            'detached'
        )

        $map = ConvertFrom-EpicProgressWorktreeList -PorcelainLine $lines

        $map.Count | Should -Be 2
        $map['main'] | Should -Be '/repo'
        $map['feature/beta'] | Should -Be '/repo-wt/beta'
    }
}

Describe 'ConvertFrom-EpicProgressPrList' {
    It 'returns the number and state of the first pull request' {
        ConvertFrom-EpicProgressPrList -Json '[{"number":8,"state":"OPEN"},{"number":3,"state":"CLOSED"}]' | Should -Be '#8 OPEN'
    }

    It 'returns an empty string for an empty pull request list' {
        ConvertFrom-EpicProgressPrList -Json '[]' | Should -Be ''
    }

    It 'returns an empty string for unparseable pull request output' {
        ConvertFrom-EpicProgressPrList -Json 'no pull requests found {' | Should -Be ''
    }

    It 'returns an empty string for blank pull request output' {
        ConvertFrom-EpicProgressPrList -Json '' | Should -Be ''
    }

    It 'returns an empty string for an entry without a number' {
        ConvertFrom-EpicProgressPrList -Json '[{"state":"OPEN"}]' | Should -Be ''
    }
}

Describe 'Get-EpicProgressWeeklyQuota' {
    It 'returns the seven-day percentage of the active account' {
        $json = '{"accounts":[{"active":false,"usage":{"sevenDay":{"pct":90}}},{"active":true,"usage":{"sevenDay":{"pct":42.5}}}]}'

        Get-EpicProgressWeeklyQuota -Json $json | Should -Be 42.5
    }

    It 'returns NaN when no account is active' {
        $json = '{"accounts":[{"active":false,"usage":{"sevenDay":{"pct":90}}}]}'

        [double]::IsNaN((Get-EpicProgressWeeklyQuota -Json $json)) | Should -BeTrue
    }

    It 'returns NaN for unparseable quota output' {
        [double]::IsNaN((Get-EpicProgressWeeklyQuota -Json 'cswap: command failed')) | Should -BeTrue
    }

    It 'returns NaN when the output has no accounts list' {
        [double]::IsNaN((Get-EpicProgressWeeklyQuota -Json '{"version":1}')) | Should -BeTrue
    }

    It 'returns NaN when the active account has no seven-day percentage' {
        [double]::IsNaN((Get-EpicProgressWeeklyQuota -Json '{"accounts":[{"active":true,"usage":{}}]}')) | Should -BeTrue
    }
}

Describe 'Get-EpicProgressTaskCount' {
    It 'counts checked and unchecked task checkboxes' {
        $plan = @(
            '### Phase 0 - Setup'
            '- [x] [P0-T1] Read the policies.'
            '  - [x] [P0-T2] Capture the baseline.'
            '- [ ] [P1-T1] Implement.'
        ) -join "`n"

        $count = Get-EpicProgressTaskCount -PlanText $plan

        $count.Total | Should -Be 3
        $count.Done | Should -Be 2
    }

    It 'ignores checkboxes without a task identifier' {
        $plan = @(
            '- [x] AC1: a criterion.'
            '- [ ] AC2: another criterion.'
            '- [ ] [P1-T1] Implement.'
        ) -join "`n"

        $count = Get-EpicProgressTaskCount -PlanText $plan

        $count.Total | Should -Be 1
        $count.Done | Should -Be 0
    }
}

Describe 'Get-EpicProgressCurrentPhase' {
    It 'returns the heading of the phase holding the first unchecked task' {
        $plan = @(
            '### Phase 0 - Setup'
            '- [x] [P0-T1] Read.'
            '### Phase 1 - Build the parser'
            '- [ ] [P1-T1] Implement.'
            '### Phase 2 - QA'
            '- [ ] [P2-T1] Test.'
        ) -join "`n"

        Get-EpicProgressCurrentPhase -PlanText $plan | Should -Be 'Phase 1 - Build the parser'
    }

    It 'falls back to Phase N when no heading matches' {
        Get-EpicProgressCurrentPhase -PlanText "- [x] [P0-T1] Read.`n- [ ] [P3-T1] Implement." | Should -Be 'Phase 3'
    }

    It 'returns an empty string when every task is checked' {
        Get-EpicProgressCurrentPhase -PlanText "### Phase 0 - Setup`n- [x] [P0-T1] Read." | Should -Be ''
    }
}

Describe 'Get-EpicProgressFeatureState' {
    It 'classifies merged and worktree_removed features as Completed' {
        Get-EpicProgressFeatureState -MergeStatus 'merged' -PrState '' -Done 0 | Should -Be 'Completed'
        Get-EpicProgressFeatureState -MergeStatus 'worktree_removed' -PrState '' -Done 3 | Should -Be 'Completed'
    }

    It 'classifies a feature with a MERGED pull request as Completed' {
        Get-EpicProgressFeatureState -MergeStatus 'in_progress' -PrState '#7 MERGED' -Done 2 | Should -Be 'Completed'
    }

    It 'classifies a started feature as Running' {
        Get-EpicProgressFeatureState -MergeStatus 'not_started' -PrState '' -Done 1 | Should -Be 'Running'
        Get-EpicProgressFeatureState -MergeStatus 'in_progress' -PrState '' -Done 0 | Should -Be 'Running'
        Get-EpicProgressFeatureState -MergeStatus 'not_started' -PrState '#8 OPEN' -Done 0 | Should -Be 'Running'
    }

    It 'classifies an unstarted feature as Pending' {
        Get-EpicProgressFeatureState -MergeStatus 'not_started' -PrState '' -Done 0 | Should -Be 'Pending'
    }
}

Describe 'Format-EpicProgressHours, Format-EpicProgressClock, and Format-EpicProgressNumber' {
    It 'formats hours as H h MM min' {
        Format-EpicProgressHours -Hours 5.25 | Should -Be '5 h 15 min'
        Format-EpicProgressHours -Hours 1234.5 | Should -Be '1,234 h 30 min'
        Format-EpicProgressHours -Hours 0 | Should -Be '0 h 00 min'
    }

    It 'formats hours as HH:MM' {
        Format-EpicProgressClock -Hours 5.25 | Should -Be '05:15'
        Format-EpicProgressClock -Hours 22.5 | Should -Be '22:30'
    }

    It 'never prints 60 in the minute field' {
        # 1.995 hours is 119.7 minutes; both fields derive from the rounded 120 minutes.
        Format-EpicProgressHours -Hours 1.995 | Should -Be '2 h 00 min'
        Format-EpicProgressClock -Hours 1.995 | Should -Be '02:00'
    }

    It 'returns n/a from each formatter for NaN' {
        Format-EpicProgressHours -Hours ([double]::NaN) | Should -Be 'n/a'
        Format-EpicProgressClock -Hours ([double]::NaN) | Should -Be 'n/a'
        Format-EpicProgressNumber -Value ([double]::NaN) -Digits 1 | Should -Be 'n/a'
    }

    It 'returns n/a from each formatter for infinity' {
        Format-EpicProgressHours -Hours ([double]::PositiveInfinity) | Should -Be 'n/a'
        Format-EpicProgressClock -Hours ([double]::NegativeInfinity) | Should -Be 'n/a'
        Format-EpicProgressNumber -Value ([double]::PositiveInfinity) | Should -Be 'n/a'
    }

    It 'rounds a number to the given digits with invariant text' {
        Format-EpicProgressNumber -Value 42.857 -Digits 1 | Should -Be '42.9'
        Format-EpicProgressNumber -Value 5.25 -Digits 0 | Should -Be '5'
        Format-EpicProgressNumber -Value 1.25 | Should -Be '1.25'
    }
}

Describe 'Select-EpicProgressSample' {
    It 'adds the first sample' {
        $result = Select-EpicProgressSample -Sample @() -NowUnixSeconds 1000 -Done 5 -SampleCap 14

        $result.Changed | Should -BeTrue
        $result.Sample.Count | Should -Be 1
        $result.Sample[0].ts | Should -Be 1000
        $result.Sample[0].done | Should -Be 5
    }

    It 'adds a sample 90 seconds after the last' {
        $existing = @([pscustomobject]@{ ts = 1000; done = 5 })

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 1090 -Done 6 -SampleCap 14

        $result.Changed | Should -BeTrue
        ($result.Sample.ts -join ',') | Should -Be '1000,1090'
    }

    It 'does not add a sample 89 seconds after the last' {
        $existing = @([pscustomobject]@{ ts = 1000; done = 5 })

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 1089 -Done 6 -SampleCap 14

        $result.Changed | Should -BeFalse
        $result.Sample.Count | Should -Be 1
        $result.Sample[0].ts | Should -Be 1000
    }

    It 'drops samples without a timestamp when adding' {
        $existing = @(
            [pscustomobject]@{ done = 1 }
            [pscustomobject]@{ ts = 900; done = 2 }
            [pscustomobject]@{ done = 3 }
        )

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 950 -Done 4 -SampleCap 14

        $result.Changed | Should -BeTrue
        ($result.Sample.ts -join ',') | Should -Be '900,950'
    }

    It 'keeps only the last SampleCap samples' {
        $existing = @(0, 100, 200, 300, 400 | ForEach-Object { [pscustomobject]@{ ts = $_; done = 1 } })

        $result = Select-EpicProgressSample -Sample $existing -NowUnixSeconds 1000 -Done 2 -SampleCap 3

        $result.Sample.Count | Should -Be 3
        ($result.Sample.ts -join ',') | Should -Be '300,400,1000'
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
    }
}
