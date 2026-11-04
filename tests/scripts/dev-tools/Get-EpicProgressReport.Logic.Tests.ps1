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
