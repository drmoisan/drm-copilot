# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1 (issues #1080, #1093, #1118).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory input and asserts the returned lines. Golden lines are
# derived by hand from the fixtures and the step-model rules; each comment states the arithmetic.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath
}

Describe 'Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine' {
    BeforeAll {
        $script:startUtc = [datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc)
        $script:nowUtc = [datetime]::new(2026, 1, 5, 12, 0, 0, [System.DateTimeKind]::Utc)
        # 2026-01-05T12:00:00Z.
        $script:nowUnix = 1767614400
        $script:defaults = Resolve-EpicProgressStepDefault

        function Get-TestFeature {
            param([string] $Issue, [int] $Wave, [string] $Band, [int] $Total, [int] $Done, [string] $State, [string] $Phase = '', [string] $Pr = '', [string] $BlockedReason = '')
            [pscustomobject]@{ Issue = $Issue; Wave = $Wave; Band = $Band; Total = $Total; Done = $Done; State = $State; Phase = $Phase; Pr = $Pr; BlockedReason = $BlockedReason }
        }

        function Get-TestStepSet {
            # Steps from 'type:done/remaining' pairs, for example 'review:1/2'.
            param([string] $Spec, [string] $Issue = '12')
            foreach ($pair in ($Spec -split ',')) {
                $type, $counts = $pair -split ':'
                $done, $remaining = $counts -split '/'
                for ($index = 0; $index -lt [int] $done; $index++) { Get-EpicProgressStepRecord -Issue $Issue -Type $type -Ordinal ($index + 1) -Status 'done' }
                for ($index = 0; $index -lt [int] $remaining; $index++) { Get-EpicProgressStepRecord -Issue $Issue -Type $type -Ordinal (100 + $index) -Status 'remaining' }
            }
        }

        function Get-TestSummary {
            param([object[]] $Feature, [object[]] $Step, [object[]] $EpicStep = @(), [hashtable] $Ledger = @{}, [double] $WeeklyPct = 42.5, [datetime] $StartUtc = $script:startUtc, [double] $WaveSeconds = -1, [object[]] $Unmapped = @(), [string] $Subject = 'Epic', [hashtable] $BlockedSince = @{})
            $estimate = Get-EpicProgressTypeEstimate -Step @(@($Step) + @($EpicStep)) -Ledger $Ledger -Default $script:defaults -NowUnixSeconds $script:nowUnix -BlockedSince $BlockedSince
            if ($WaveSeconds -lt 0) { $WaveSeconds = $estimate.TotalSeconds }
            $name = 'example-epic'
            if ($Subject -eq 'Item') { $name = '' }
            Get-EpicProgressSummary -Feature $Feature -EpicStep $EpicStep -Estimate $estimate -WaveParallelSeconds $WaveSeconds -Unmapped $Unmapped -Subject $Subject -StartUtc $StartUtc -NowUtc $script:nowUtc -WeeklyPct $WeeklyPct -BaselineWeeklyPct 0 -EpicIssue '42' -EpicName $name
        }

        # Three features: #12 Completed (wave 1, 10 of 10 steps), #12345 Running (wave 2, 6 of 13),
        # #77 Pending (wave 3, 3 of 11), plus one remaining integration-pr step: 19 of 35 steps.
        $script:threeFeatures = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 10 -Done 10 -State 'Completed' -Pr '#7 MERGED'
            Get-TestFeature -Issue '12345' -Wave 2 -Band 'large' -Total 13 -Done 6 -State 'Running' -Phase 'Phase 1 - Build' -Pr '#8 OPEN'
            Get-TestFeature -Issue '77' -Wave 3 -Band 'medium' -Total 11 -Done 3 -State 'Pending'
        )
        $script:threeSteps = @(Get-TestStepSet -Spec 'research:3/0,spec:3/0,plan:3/0,preflight:2/1,execution:3/7,review:1/2,pr:2/1,ci:1/2,merge:1/2')
        $script:epicSteps = @(Get-EpicProgressStepRecord -Issue '42' -Type 'integration-pr')
        # Remaining with defaults: preflight 1 x 10 + execution 7 x 5 + review 2 x 14 + pr 1 x 3
        # + ci 2 x 17 + merge 2 x 5 + integration-pr 1 x 45 = 165 min (2 h 45 min, 2.75 h).
        $script:threeSummary = Get-TestSummary -Feature $script:threeFeatures -Step $script:threeSteps -EpicStep $script:epicSteps -WaveSeconds 9900
    }

    It 'composes the four TL;DR lines' {
        $lines = @(Get-EpicProgressTldrLine -Summary $script:threeSummary)

        $expected = @(
            '**TL;DR:** Epic #42 is at 19 of 35 steps (54.3%). 1 of 3 features are done. #12345 is running (6 of 13 steps).'
            '**Elapsed:** 3 h 00 min, with about 2.8 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.'
            '**Now:** no step is in progress. 10 of 10 types use defaults.'
            '**Estimated time remaining:** 2 h 45 min by type (sum); 2 h 45 min wave-parallel.'
        )
        ($lines -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'composes the Full lines in recovered order' {
        $lines = @(Get-EpicProgressFullLine -Summary $script:threeSummary)

        $expected = @(
            ''
            '## Epic #42 example-epic: status at 12:00 UTC, Jan 5'
            ''
            '**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 19 of 35 steps complete, **54.3%**.'
            ''
            '| State | Features |'
            '|---|---|'
            '| Completed | #12 |'
            '| Running | #12345 (wave 2, large): 6 of 13 steps (46%). Now at: Phase 1 - Build. PR #8 OPEN. |'
            '| Blocked | None |'
            '| Pending, wave 3 | #77 (11) |'
            ''
            '| Wave | Children | Steps | Done |'
            '|---|---|---|---|'
            '| 1 | 1 | 10 | 10 |'
            '| 2 | 1 | 13 | 6 |'
            '| 3 | 1 | 11 | 3 |'
            '| Epic | 0 | 1 | 0 |'
            '| **Total** | **3** | **35** | **19** |'
            ''
            '| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |'
            '|---|---|---|---|---|---|---|---|'
            '| research | 3 | 0 | 0 | 0 | 0 h 13 min (default) | 0 | 0 h 00 min |'
            '| spec | 3 | 0 | 0 | 0 | 0 h 06 min (default) | 0 | 0 h 00 min |'
            '| plan | 3 | 0 | 0 | 0 | 0 h 11 min (default) | 0 | 0 h 00 min |'
            '| preflight | 2 | 0 | 1 | 0 | 0 h 10 min (default) | 0 | 0 h 10 min |'
            '| execution | 3 | 0 | 7 | 0 | 0 h 05 min (default) | 0 | 0 h 35 min |'
            '| review | 1 | 0 | 2 | 0 | 0 h 14 min (default) | 0 | 0 h 28 min |'
            '| pr | 2 | 0 | 1 | 0 | 0 h 03 min (default) | 0 | 0 h 03 min |'
            '| ci | 1 | 0 | 2 | 0 | 0 h 17 min (default) | 0 | 0 h 34 min |'
            '| merge | 1 | 0 | 2 | 0 | 0 h 05 min (default) | 0 | 0 h 10 min |'
            '| integration-pr | 0 | 0 | 1 | 0 | 0 h 45 min (default) | 0 | 0 h 45 min |'
            '| **Total** | **19** | **0** | **16** | **0** | | **0** | **2 h 45 min** |'
            ''
            'research: no measured duration; default 13 min'
            'spec: no measured duration; default 6 min'
            'plan: no measured duration; default 11 min'
            'preflight: no measured duration; default 10 min'
            'execution: no measured duration; default 5 min'
            'review: no measured duration; default 14 min'
            'pr: no measured duration; default 3 min'
            'ci: no measured duration; default 17 min'
            'merge: no measured duration; default 5 min'
            'integration-pr: no measured duration; default 45 min'
            '**Unmapped and composite stage time:** none.'
            "**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
        )
        $lines.Count | Should -Be $expected.Count
        ($lines -join "`n") | Should -Be ($expected -join "`n")
    }

    It 'states that no feature is running' {
        $features = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 10 -Done 10 -State 'Completed'
            Get-TestFeature -Issue '77' -Wave 2 -Band 'medium' -Total 11 -Done 0 -State 'Pending'
        )

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:1/1')))

        # 10 + 0 done of 10 + 11 steps: 47.6%.
        $lines[0] | Should -Be '**TL;DR:** Epic #42 is at 10 of 21 steps (47.6%). 1 of 2 features are done. No feature is running.'
    }

    It 'names a single running feature' {
        $features = @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 12 -Done 9 -State 'Running')

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:0/1')))

        $lines[0] | Should -Be '**TL;DR:** Epic #42 is at 9 of 12 steps (75%). None of the 1 features is done yet. #12345 is running (9 of 12 steps).'
    }

    It 'lists several running features' {
        $features = @(
            Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 15 -Done 3 -State 'Running'
            Get-TestFeature -Issue '600' -Wave 1 -Band 'small' -Total 12 -Done 6 -State 'Running'
        )

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:0/1')))

        # 9 of 27 steps: 33.3%.
        $lines[0] | Should -Be '**TL;DR:** Epic #42 is at 9 of 27 steps (33.3%). None of the 2 features is done yet. #12345 (3 of 15), #600 (6 of 12) are running.'
    }

    It 'states that no feature is done yet' {
        $features = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 10 -Done 5 -State 'Running'
            Get-TestFeature -Issue '77' -Wave 2 -Band 'medium' -Total 10 -Done 0 -State 'Pending'
        )
        $summary = Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:0/1')

        $tldr = @(Get-EpicProgressTldrLine -Summary $summary)
        $full = @(Get-EpicProgressFullLine -Summary $summary)

        $tldr[0] | Should -Be '**TL;DR:** Epic #42 is at 5 of 20 steps (25%). None of the 2 features is done yet. #12 is running (5 of 10 steps).'
        $full | Should -Contain '| Completed | None yet |'
        $full | Should -Contain '| Running | #12 (wave 1, small): 5 of 10 steps (50%). |'
    }

    Context 'non-finite values print n/a' {
        BeforeAll {
            $features = @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 4 -Done 0 -State 'Running')
            $script:naSummary = Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:0/1') -WeeklyPct ([double]::NaN)
            $script:naTldr = @(Get-EpicProgressTldrLine -Summary $script:naSummary)
            $script:naFull = @(Get-EpicProgressFullLine -Summary $script:naSummary)

            function Get-TestNanSummary {
                # A summary whose estimate total and review median are NaN.
                param([datetime] $StartUtc = $script:startUtc)
                $row = [pscustomobject]@{ Type = 'review'; Done = 0; InProgress = 0; Remaining = 1; Blocked = 0; MedianSeconds = [double]::NaN; Samples = 1; IsDefault = $false; IsApproximate = $false; SubtotalSeconds = [double]::NaN; BlockedSubtotalSeconds = 0.0 }
                $estimate = [pscustomobject]@{ Type = @($row); InProgress = @(); TotalSeconds = [double]::NaN; BlockedSubtotalSeconds = 0.0; BlockedCount = 0; DefaultCount = 0 }
                Get-EpicProgressSummary -Feature @(Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 4 -Done 2 -State 'Running') -Estimate $estimate -WaveParallelSeconds ([double]::NaN) -StartUtc $StartUtc -NowUtc $script:nowUtc -WeeklyPct 42.5 -BaselineWeeklyPct 0 -EpicIssue '42' -EpicName 'example-epic'
            }
        }

        It 'prints n/a for a non-finite median' {
            $full = @(Get-EpicProgressFullLine -Summary (Get-TestNanSummary))

            $full | Should -Contain '| review | 0 | 0 | 1 | 0 | n/a | 1 | n/a |'
        }

        It 'prints n/a for the hours-left figure' {
            $tldr = @(Get-EpicProgressTldrLine -Summary (Get-TestNanSummary))

            $tldr[1] | Should -BeLike '*, with about n/a hours left on the per-type estimate (0 blocked steps excluded). *'
            $tldr[3] | Should -Be '**Estimated time remaining:** n/a by type (sum); n/a wave-parallel.'
        }

        It 'prints n/a for the weekly quota and its delta' {
            $script:naTldr[1] | Should -BeLike '* **Weekly** quota is at n/a.'
            $script:naFull[-1] | Should -BeLike '**Weekly quota (active account):** n/a used, n/a points since the epic started. *'
        }

        It 'prints n/a estimates at zero elapsed time' {
            $tldr = @(Get-EpicProgressTldrLine -Summary (Get-TestNanSummary -StartUtc $script:nowUtc))

            $tldr[1] | Should -Be '**Elapsed:** 0 h 00 min, with about n/a hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.'
        }

        It 'clamps elapsed time at zero when the start is after now' {
            # A start 30 minutes in the future would otherwise print -1 h 30 min.
            $summary = Get-TestNanSummary -StartUtc $script:nowUtc.AddMinutes(30)

            $tldr = @(Get-EpicProgressTldrLine -Summary $summary)

            $summary.ElapsedHours | Should -Be 0
            $tldr[1] | Should -BeLike '**Elapsed:** 0 h 00 min, with about *'
        }
    }

    It 'prints no NaN or Infinity before the first task completes' {
        # No step is done three hours after the start; every type uses its default.
        $features = @(
            Get-TestFeature -Issue '12345' -Wave 1 -Band 'large' -Total 12 -Done 0 -State 'Running'
            Get-TestFeature -Issue '77' -Wave 2 -Band 'medium' -Total 11 -Done 0 -State 'Pending'
        )
        $summary = Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'research:0/2,execution:0/5')

        $lines = @(Get-EpicProgressTldrLine -Summary $summary) + @(Get-EpicProgressFullLine -Summary $summary)

        # research 2 x 13 + execution 5 x 5 = 51 min (0.85 h).
        $summary.ElapsedHours | Should -BeGreaterThan 0
        ($lines -join "`n") | Should -Not -Match 'NaN|Infinity'
        $lines[1] | Should -Be '**Elapsed:** 3 h 00 min, with about 0.8 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.'
        $lines[3] | Should -Be '**Estimated time remaining:** 0 h 51 min by type (sum); 0 h 51 min wave-parallel.'
    }

    It 'prints the Now line with elapsed against median for review, ci and main-sync' {
        # review started 5 min ago (median 14 min default); ci 20 min ago (median 17, over);
        # main-sync 30 min ago (median 60 default).
        $steps = @(
            Get-EpicProgressStepRecord -Issue '12' -Type 'review' -Status 'in_progress' -StartedUnixSeconds ($script:nowUnix - 300)
            Get-EpicProgressStepRecord -Issue '77' -Type 'ci' -Status 'in_progress' -StartedUnixSeconds ($script:nowUnix - 1200)
        )
        $epicSteps = @(Get-EpicProgressStepRecord -Issue '900' -Type 'main-sync' -Status 'in_progress' -StartedUnixSeconds ($script:nowUnix - 1800))
        $features = @(Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 1 -Done 0 -State 'Running')

        $lines = @(Get-EpicProgressTldrLine -Summary (Get-TestSummary -Feature $features -Step $steps -EpicStep $epicSteps))

        $lines[2] | Should -Be '**Now:** #12 review (0 h 05 min of median 0 h 14 min), #77 ci (0 h 20 min of median 0 h 17 min, over median), #900 main-sync (0 h 30 min of median 1 h 00 min). 3 of 3 types use defaults.'
    }

    It 'prints a blocked item with its reason' {
        # Two blocked review steps of #77 (14 min each) are excluded and listed as 28 min of work.
        $features = @(
            Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 4 -Done 2 -State 'Running'
            Get-TestFeature -Issue '77' -Wave 1 -Band 'medium' -Total 3 -Done 1 -State 'Blocked' -BlockedReason 'policy_hold'
        )
        $steps = @(
            Get-TestStepSet -Spec 'review:0/1' -Issue '12'
            1..2 | ForEach-Object { Get-EpicProgressStepRecord -Issue '77' -Type 'review' -Ordinal $_ -Status 'blocked' }
        )

        $summary = Get-TestSummary -Feature $features -Step $steps
        $tldr = @(Get-EpicProgressTldrLine -Summary $summary)
        $full = @(Get-EpicProgressFullLine -Summary $summary)

        $tldr[0] | Should -Be '**TL;DR:** Epic #42 is at 3 of 7 steps (42.9%). None of the 2 features is done yet. #12 is running (2 of 4 steps). #77 is blocked (policy_hold).'
        $tldr[1] | Should -BeLike '*, with about 0.2 hours left on the per-type estimate (2 blocked steps excluded). *'
        $full | Should -Contain '| Blocked | #77 (policy_hold) |'
        $full | Should -Contain '**Blocked:** 2 steps excluded from the estimate, about 0 h 28 min of work.'
    }

    It 'prints the per-type table with done, in-progress, remaining, blocked, median, samples and subtotal columns' {
        # Review samples 600, 900, 1200 s (median 900 s = 15 min). Steps: 1 done, 1 in progress
        # (started 5 min ago, credit 10 min), 2 remaining (30 min), 1 blocked: subtotal 40 min.
        $ledger = @{ review = @(600, 900, 1200 | ForEach-Object { Get-EpicProgressDurationSample -Key "r$_" -Type 'review' -Seconds $_ -Source 'stage_timing' }) }
        $steps = @(
            Get-EpicProgressStepRecord -Issue '12' -Type 'review' -Ordinal 1 -Status 'done'
            Get-EpicProgressStepRecord -Issue '12' -Type 'review' -Ordinal 2 -Status 'in_progress' -StartedUnixSeconds ($script:nowUnix - 300)
            Get-EpicProgressStepRecord -Issue '12' -Type 'review' -Ordinal 3
            Get-EpicProgressStepRecord -Issue '12' -Type 'review' -Ordinal 4
            Get-EpicProgressStepRecord -Issue '77' -Type 'review' -Ordinal 1 -Status 'blocked'
        )
        $features = @(Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 5 -Done 1 -State 'Running')

        $full = @(Get-EpicProgressFullLine -Summary (Get-TestSummary -Feature $features -Step $steps -Ledger $ledger))

        $full | Should -Contain '| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |'
        $full | Should -Contain '| review | 1 | 1 | 2 | 1 | 0 h 15 min | 3 | 0 h 40 min |'
        $full | Should -Contain '| **Total** | **1** | **1** | **2** | **1** | | **3** | **0 h 40 min** |'
    }

    It 'prints a default line and a default marker for a type without samples' {
        $ledger = @{ review = @(Get-EpicProgressDurationSample -Key 'r1' -Type 'review' -Seconds 600 -Source 'stage_timing') }
        $steps = @(Get-TestStepSet -Spec 'review:0/1,ci:0/2')
        $features = @(Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 3 -Done 0 -State 'Running')

        $summary = Get-TestSummary -Feature $features -Step $steps -Ledger $ledger
        $full = @(Get-EpicProgressFullLine -Summary $summary)
        $tldr = @(Get-EpicProgressTldrLine -Summary $summary)

        $full | Should -Contain '| ci | 0 | 0 | 2 | 0 | 0 h 17 min (default) | 0 | 0 h 34 min |'
        $full | Should -Contain 'ci: no measured duration; default 17 min'
        @($full | Where-Object { $_ -like 'review: no measured duration*' }).Count | Should -Be 0
        $tldr[2] | Should -Be '**Now:** no step is in progress. 1 of 2 types use defaults.'
    }

    It 'prints the unmapped and composite time line' {
        # Composite 3600 s (approximate 1800 s of it) and unmapped 600 s: total 70 min.
        $unmapped = @(
            [pscustomobject]@{ Issue = '12'; Stage = 'remediation_cycle_1'; Kind = 'composite'; Seconds = 1800; Approx = $false; Source = 'stage_timing' }
            [pscustomobject]@{ Issue = '12'; Stage = 'remediation_cycle_2'; Kind = 'composite'; Seconds = 1800; Approx = $true; Source = 'cycle_entry' }
            [pscustomobject]@{ Issue = '12'; Stage = 'promotion'; Kind = 'unmapped'; Seconds = 600; Approx = $false; Source = 'stage_timing' }
        )
        $features = @(Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 1 -Done 0 -State 'Running')

        $full = @(Get-EpicProgressFullLine -Summary (Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:0/1') -Unmapped $unmapped))

        $full | Should -Contain '**Unmapped and composite stage time:** 1 h 10 min (composite remediation 1 h 00 min, unmapped stages 0 h 10 min, approximate 0 h 30 min); it enters no median.'
    }

    It 'marks an approximate median' {
        $ledger = @{ merge = @(Get-EpicProgressDurationSample -Key 'm1' -Type 'merge' -Seconds 420 -Source 'epic_row' -Approx $true) }
        $features = @(Get-TestFeature -Issue '12' -Wave 1 -Band 'small' -Total 1 -Done 0 -State 'Running')

        $full = @(Get-EpicProgressFullLine -Summary (Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'merge:0/1') -Ledger $ledger))

        $full | Should -Contain '| merge | 0 | 0 | 1 | 0 | 0 h 07 min (approx) | 1 | 0 h 07 min |'
    }

    It 'prints Item as the subject in item mode with wave-parallel equal to the sum' {
        # One item: review 1 x 14 + ci 1 x 17 = 31 min, and the wave-parallel figure is the same sum.
        $features = @(Get-TestFeature -Issue '42' -Wave 1 -Band '' -Total 4 -Done 2 -State 'Running')

        $summary = Get-TestSummary -Feature $features -Step @(Get-TestStepSet -Spec 'review:1/1,ci:1/1' -Issue '42') -Subject 'Item'
        $tldr = @(Get-EpicProgressTldrLine -Summary $summary)
        $full = @(Get-EpicProgressFullLine -Summary $summary)

        $tldr[0] | Should -Be '**TL;DR:** Item #42 is at 2 of 4 steps (50%). None of the 1 features is done yet. #42 is running (2 of 4 steps).'
        $tldr[3] | Should -Be '**Estimated time remaining:** 0 h 31 min by type (sum); 0 h 31 min wave-parallel.'
        $full[1] | Should -Be '## Item #42: status at 12:00 UTC, Jan 5'
    }

    It 'prints no velocity, SD or range line in either mode' {
        $epicLines = @(Get-EpicProgressTldrLine -Summary $script:threeSummary) + @(Get-EpicProgressFullLine -Summary $script:threeSummary)
        $itemSummary = Get-TestSummary -Feature @(Get-TestFeature -Issue '42' -Wave 1 -Band '' -Total 2 -Done 1 -State 'Running') -Step @(Get-TestStepSet -Spec 'review:1/1' -Issue '42') -Subject 'Item'
        $itemLines = @(Get-EpicProgressTldrLine -Summary $itemSummary) + @(Get-EpicProgressFullLine -Summary $itemSummary)

        foreach ($line in @($epicLines + $itemLines)) {
            $line | Should -Not -Match 'Velocity|SD of|Straight line|range needs|no upper bound|tasks / hr'
        }
        $epicLines.Count | Should -BeGreaterThan 4
        $itemLines.Count | Should -BeGreaterThan 4
    }
}
