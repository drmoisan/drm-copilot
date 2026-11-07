# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Stages.ps1 (issue #1118).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies fixed in-memory input and asserts the returned data.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath

    function ConvertFrom-TestJson {
        # Parses an in-memory checkpoint fixture the way the report parses a checkpoint file.
        param([string] $Json)
        ConvertFrom-Json -InputObject $Json
    }
}

Describe 'Get-EpicProgressStepTypeCatalog and ConvertTo-EpicProgressStepType' {
    It 'maps planning and plan to the plan type' {
        ConvertTo-EpicProgressStepType -StageName 'planning' | Should -Be 'plan'
        ConvertTo-EpicProgressStepType -StageName 'plan' | Should -Be 'plan'
        ConvertTo-EpicProgressStepType -StageName ' Planning ' | Should -Be 'plan'
    }

    It 'maps remediation and remediation_cycle_2 to composite' {
        ConvertTo-EpicProgressStepType -StageName 'remediation' | Should -Be 'composite'
        ConvertTo-EpicProgressStepType -StageName 'remediation_cycle_2' | Should -Be 'composite'
    }

    It 'maps promotion to unmapped' {
        ConvertTo-EpicProgressStepType -StageName 'promotion' | Should -Be 'unmapped'
        ConvertTo-EpicProgressStepType -StageName '' | Should -Be 'unmapped'
        ConvertTo-EpicProgressStepType -StageName 'review' | Should -Be 'review'
    }

    It 'returns the eleven catalog types' {
        $catalog = @(Get-EpicProgressStepTypeCatalog)

        $catalog.Count | Should -Be 11
        ($catalog.Type -join ',') | Should -Be 'research,spec,plan,preflight,execution,review,pr,ci,merge,main-sync,integration-pr'
        (@($catalog | Where-Object { $_.Scope -eq 'epic' }).Type -join ',') | Should -Be 'main-sync,integration-pr'
    }
}

Describe 'ConvertTo-EpicProgressUnixSecond and ConvertFrom-EpicProgressStageTiming' {
    It 'converts an ISO string and a parsed DateTime to the same epoch second' {
        # 2026-01-05T09:00:00Z is 1767603600; ConvertFrom-Json returns a DateTime for the same text.
        $parsed = (ConvertFrom-TestJson -Json '{"at":"2026-01-05T09:00:00Z"}').at

        ConvertTo-EpicProgressUnixSecond -Value '2026-01-05T09:00:00Z' | Should -Be 1767603600
        ConvertTo-EpicProgressUnixSecond -Value $parsed | Should -Be 1767603600
        ConvertTo-EpicProgressUnixSecond -Value ([System.DateTimeOffset]::FromUnixTimeSeconds(1767603600)) | Should -Be 1767603600
        ConvertTo-EpicProgressUnixSecond -Value ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Unspecified)) | Should -Be 1767603600
        ConvertTo-EpicProgressUnixSecond -Value 'not a time' | Should -BeNullOrEmpty
        ConvertTo-EpicProgressUnixSecond -Value $null | Should -BeNullOrEmpty
    }

    It 'keeps an open stage with a null end' {
        $checkpoint = ConvertFrom-TestJson -Json '{"stage_timing":[{"stage":"research","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":"2026-01-05T09:10:00Z"},{"stage":"review","attempt":2,"started_at":"2026-01-05T10:00:00Z","ended_at":null}]}'

        $records = @(ConvertFrom-EpicProgressStageTiming -StageTiming $checkpoint.stage_timing)

        $records.Count | Should -Be 2
        $records[0].Type | Should -Be 'research'
        $records[0].EndedUnixSeconds - $records[0].StartedUnixSeconds | Should -Be 600
        $records[1].Stage | Should -Be 'review'
        $records[1].Attempt | Should -Be 2
        $records[1].StartedUnixSeconds | Should -Be 1767607200
        $records[1].EndedUnixSeconds | Should -BeNullOrEmpty
    }

    It 'skips a malformed stage entry' {
        $json = '{"stage_timing":[' +
        '"text",' +
        '{"stage":"","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":null},' +
        '{"stage":"spec","attempt":0,"started_at":"2026-01-05T09:00:00Z","ended_at":null},' +
        '{"stage":"spec","attempt":1,"started_at":"soon","ended_at":null},' +
        '{"stage":"spec","attempt":1,"started_at":"2026-01-05T09:00:00Z"},' +
        '{"stage":"spec","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":"later"},' +
        '{"stage":"spec","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":"2026-01-05T08:00:00Z"},' +
        '{"stage":"promotion","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":"2026-01-05T09:01:00Z"}]}'
        $checkpoint = ConvertFrom-TestJson -Json $json

        $records = @(ConvertFrom-EpicProgressStageTiming -StageTiming $checkpoint.stage_timing)

        $records.Count | Should -Be 1
        $records[0].Stage | Should -Be 'promotion'
        $records[0].Type | Should -Be 'unmapped'
        @(ConvertFrom-EpicProgressStageTiming -StageTiming $null).Count | Should -Be 0
    }
}

Describe 'Get-EpicProgressBlockage' {
    It 'marks an item blocked for a blocked_reason other than none or awaiting_ci' {
        $result = Get-EpicProgressBlockage -Checkpoint (ConvertFrom-TestJson -Json '{"blocked_reason":"external_dependency"}')

        $result.Blocked | Should -BeTrue
        $result.Reason | Should -Be 'external_dependency'
    }

    It 'does not mark awaiting_ci or none as blocked' {
        foreach ($json in @('{"blocked_reason":"awaiting_ci"}', '{"blocked_reason":"none"}', '{"blocked_reason":null}', '{}')) {
            $result = Get-EpicProgressBlockage -Checkpoint (ConvertFrom-TestJson -Json $json)

            $result.Blocked | Should -BeFalse -Because "$json is not a blockage"
            $result.Reason | Should -Be ''
        }
        (Get-EpicProgressBlockage -Checkpoint $null).Blocked | Should -BeFalse
    }

    It 'marks an item blocked for a halt human_interaction response' {
        $json = '{"human_interaction":{"requirements":[{"response":"scope_change"},{"response":"halt"}]}}'

        $result = Get-EpicProgressBlockage -Checkpoint (ConvertFrom-TestJson -Json $json)

        $result.Blocked | Should -BeTrue
        $result.Reason | Should -Be 'human_interaction halt'
    }

    It 'marks an item blocked for blocked_remediation_loop_limit' {
        $result = Get-EpicProgressBlockage -Checkpoint (ConvertFrom-TestJson -Json '{"step6_status":"blocked_remediation_loop_limit"}')

        $result.Blocked | Should -BeTrue
        $result.Reason | Should -Be 'blocked_remediation_loop_limit'
    }

    It 'marks an item blocked for blocked_ci_loop_limit' {
        $result = Get-EpicProgressBlockage -Checkpoint (ConvertFrom-TestJson -Json '{"step9_status":"blocked_ci_loop_limit"}')

        $result.Blocked | Should -BeTrue
        $result.Reason | Should -Be 'blocked_ci_loop_limit'
    }

    It 'marks an item blocked for blocked_conflict_loop_limit' {
        $result = Get-EpicProgressBlockage -Checkpoint $null -MergeStatus 'blocked_conflict_loop_limit'

        $result.Blocked | Should -BeTrue
        $result.Reason | Should -Be 'blocked_conflict_loop_limit'
    }

    It 'does not mark an item blocked when no task was checked between runs' {
        # The same in-progress checkpoint is evaluated for two runs whose checked-task counts are
        # equal (a zero tick rate); D1 reads recorded state only, so neither run is blocked.
        $checkpoint = ConvertFrom-TestJson -Json '{"next_step":"S5_atomic_execution","step5_status":"in_progress"}'
        $planText = "- [x] [P0-T1] a.`n- [ ] [P1-T1] b."
        $firstCount = (Get-EpicProgressTaskCount -PlanText $planText).Done
        $secondCount = (Get-EpicProgressTaskCount -PlanText $planText).Done

        $first = Get-EpicProgressBlockage -Checkpoint $checkpoint -MergeStatus 'worktree_created'
        $second = Get-EpicProgressBlockage -Checkpoint $checkpoint -MergeStatus 'worktree_created'

        $secondCount - $firstCount | Should -Be 0
        $first.Blocked | Should -BeFalse
        $second.Blocked | Should -BeFalse
    }
}
