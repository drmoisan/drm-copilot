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
