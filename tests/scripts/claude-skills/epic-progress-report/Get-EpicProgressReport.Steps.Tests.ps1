# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Steps.ps1 (issue #1118).
# The Logic hub is dot-sourced, which dot-sources this file; every function under test is pure,
# so each test supplies an in-memory item record and checkpoint JSON and asserts the steps.

BeforeAll {
    $script:logicPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1'
    . $script:logicPath

    function Get-TestItem {
        # One item record with no checkpoint, a three-task plan, and no epic row.
        param(
            [string] $CheckpointJson = '',
            [string] $PlanText = "- [x] [P0-T1] a.`n- [ ] [P1-T1] b.`n- [ ] [P1-T2] c.",
            [hashtable] $CycleText = @{},
            [string] $MergeStatus = 'worktree_created',
            [string] $PrState = '',
            [bool] $PreparedPlan = $false,
            [bool] $SpecExists = $true
        )
        $checkpoint = $null
        if ($CheckpointJson) { $checkpoint = ConvertFrom-Json -InputObject $CheckpointJson }
        [pscustomobject]@{
            Issue        = '12'
            Checkpoint   = $checkpoint
            PlanText     = $PlanText
            PlanFile     = 'plan.md'
            CycleText    = $CycleText
            SpecExists   = $SpecExists
            MergeStatus  = $MergeStatus
            PrState      = $PrState
            PreparedPlan = $PreparedPlan
            Blockage     = (Get-EpicProgressBlockage -Checkpoint $checkpoint -MergeStatus $MergeStatus)
        }
    }

    function Get-TestTypeCount {
        # The step types of a step list joined as 'type:count' in first-seen order.
        param([object[]] $Step, [string] $Status = '')
        $counts = [ordered]@{}
        foreach ($entry in @($Step | Where-Object { -not $Status -or $_.Status -eq $Status })) { $counts[$entry.Type] = 1 + [int] $counts[$entry.Type] }
        (@($counts.Keys | ForEach-Object { "$($_):$($counts[$_])" }) -join ',')
    }

    # A remediation plan with two tasks, one checked.
    $script:cyclePlan = "- [x] [P0-T1] fix.`n- [ ] [P0-T2] test."
}

Describe 'Get-EpicProgressItemStep' {
    It 'counts one execution step per plan task' {
        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem))

        $execution = @($steps | Where-Object { $_.Type -eq 'execution' })
        $execution.Count | Should -Be 3
        ($execution.Status -join ',') | Should -Be 'done,remaining,remaining'
        $execution[0].Key | Should -Be '12|exec|plan.md|P0-T1'
        # Eight non-execution item types, one step each, plus three tasks.
        $steps.Count | Should -Be 11
    }

    It 'adds plan, preflight, execution, review and ci steps for a full cycle opened after a PR' {
        # The pr stage started at 10:00, before the cycle entry at 11:00, so the cycle adds a ci step.
        $json = '{"stage_timing":[{"stage":"pr","attempt":1,"started_at":"2026-01-05T10:00:00Z","ended_at":"2026-01-05T10:03:00Z"}],' +
        '"remediation_loop":{"cycles":[{"entry_timestamp":"2026-01-05T11:00:00Z","plan_path":"docs/x/remediation-plan.md","remediation_path":"full"}]}}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json -CycleText @{ 'docs/x/remediation-plan.md' = $script:cyclePlan }))

        $cycleSteps = @($steps | Where-Object { $_.Cycle -eq 1 })
        Get-TestTypeCount -Step $cycleSteps | Should -Be 'plan:1,preflight:1,execution:2,review:1,ci:1'
        (@($cycleSteps | Where-Object { $_.Type -eq 'execution' }).Key -join ',') | Should -Be '12|exec|remediation-plan.md|P0-T1,12|exec|remediation-plan.md|P0-T2'
    }

    It 'adds no plan or preflight step for a light cycle' {
        $json = '{"remediation_loop":{"cycles":[{"plan_path":"docs/x/remediation-inputs.md","remediation_path":"light"}]}}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json -CycleText @{ 'docs/x/remediation-inputs.md' = $script:cyclePlan }))

        Get-TestTypeCount -Step @($steps | Where-Object { $_.Cycle -eq 1 }) | Should -Be 'execution:2,review:1'
    }

    It 'treats a cycle without remediation_path as full' {
        $json = '{"remediation_loop":{"cycles":[{"plan_path":"docs/x/remediation-plan.md"}]}}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json -CycleText @{ 'docs/x/remediation-plan.md' = $script:cyclePlan }))

        Get-TestTypeCount -Step @($steps | Where-Object { $_.Cycle -eq 1 }) | Should -Be 'plan:1,preflight:1,execution:2,review:1'
    }

    It 'grows the total and lowers the percentage when a cycle opens' {
        # Before: 11 steps with research, spec, plan, preflight, review, and one task done (6 of 11).
        # After: the newly opened full cycle adds plan (done, text present), preflight (no
        # final_status, no task checked), two unchecked tasks, and review (no second outcome):
        # 16 steps, 7 done, so 54.5% falls to 43.75%.
        $before = '{"completed_steps":["S2_research","S3_promotion","S4_atomic_planning","S7_feature_review"],"step5_status":"verified","remediation_loop":{"review_outcomes":[{"verdict":"FAIL"}],"cycles":[]}}'
        $after = '{"completed_steps":["S2_research","S3_promotion","S4_atomic_planning","S7_feature_review"],"step5_status":"verified","remediation_loop":{"review_outcomes":[{"verdict":"FAIL"}],"cycles":[{"plan_path":"docs/x/remediation-plan.md","remediation_path":"full"}]}}'
        $openedPlan = "- [ ] [P0-T1] fix.`n- [ ] [P0-T2] test."

        $first = Get-EpicProgressStepCount -Step @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $before))
        $second = Get-EpicProgressStepCount -Step @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $after -CycleText @{ 'docs/x/remediation-plan.md' = $openedPlan }))

        "$($first.Done) of $($first.Total)" | Should -Be '6 of 11'
        "$($second.Done) of $($second.Total)" | Should -Be '7 of 16'
        $second.Total | Should -BeGreaterThan $first.Total
        $second.Percent | Should -BeLessThan $first.Percent
    }

    It 'counts one step per recorded attempt' {
        # Planning ran three times and preflight twice (decision D4).
        $json = '{"stage_timing":[' +
        '{"stage":"planning","attempt":1,"started_at":"2026-01-05T09:00:00Z","ended_at":"2026-01-05T09:10:00Z"},' +
        '{"stage":"planning","attempt":2,"started_at":"2026-01-05T09:20:00Z","ended_at":"2026-01-05T09:30:00Z"},' +
        '{"stage":"planning","attempt":3,"started_at":"2026-01-05T09:40:00Z","ended_at":"2026-01-05T09:50:00Z"},' +
        '{"stage":"preflight","attempt":1,"started_at":"2026-01-05T09:10:00Z","ended_at":"2026-01-05T09:20:00Z"},' +
        '{"stage":"preflight","attempt":2,"started_at":"2026-01-05T09:50:00Z","ended_at":"2026-01-05T10:00:00Z"}]}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json))

        Get-TestTypeCount -Step @($steps | Where-Object { $_.Type -in @('plan', 'preflight') }) -Status 'done' | Should -Be 'plan:3,preflight:2'
        (@($steps | Where-Object { $_.Type -eq 'plan' }).Key -join ',') | Should -Be '12|plan|c0|1,12|plan|c0|2,12|plan|c0|3'
    }

    It 'marks the open stage_timing entry in progress' {
        $json = '{"stage_timing":[{"stage":"review","attempt":1,"started_at":"2026-01-05T11:00:00Z","ended_at":null}]}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json))

        $running = @($steps | Where-Object { $_.Status -eq 'in_progress' })
        $running.Count | Should -Be 1
        $running[0].Type | Should -Be 'review'
        # 2026-01-05T11:00:00Z is 1767610800.
        $running[0].StartedUnixSeconds | Should -Be 1767610800
    }

    It 'marks an open re-audit attempt in progress on the cycle review step' {
        # Review attempt 1 closed and attempt 2 (the cycle 1 re-audit) is open since 11:50
        # (1767613800); the initial review keeps attempt 1 and the cycle review carries the start.
        $json = '{"next_step":"remediation.cycle_1.reaudit","stage_timing":[' +
        '{"stage":"review","attempt":1,"started_at":"2026-01-05T10:20:00Z","ended_at":"2026-01-05T10:35:00Z"},' +
        '{"stage":"review","attempt":2,"started_at":"2026-01-05T11:50:00Z","ended_at":null}],' +
        '"remediation_loop":{"cycles":[{"plan_path":"docs/x/remediation-plan.md","remediation_path":"light"}]}}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json -CycleText @{ 'docs/x/remediation-plan.md' = $script:cyclePlan }))

        $reviews = @($steps | Where-Object { $_.Type -eq 'review' })
        (@($reviews | ForEach-Object { "$($_.Cycle):$($_.Status)" }) -join ',') | Should -Be '0:done,1:in_progress'
        $reviews[1].StartedUnixSeconds | Should -Be 1767613800
    }

    It 'maps next_step to the in-progress step without stage_timing' {
        $initial = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson '{"next_step":"S9_ci_green"}'))
        $json = '{"next_step":"remediation.cycle_1.reaudit","remediation_loop":{"cycles":[{"plan_path":"docs/x/remediation-plan.md","remediation_path":"light"}]}}'
        $cycle = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json -CycleText @{ 'docs/x/remediation-plan.md' = $script:cyclePlan }))

        $initialRunning = @($initial | Where-Object { $_.Status -eq 'in_progress' })
        $cycleRunning = @($cycle | Where-Object { $_.Status -eq 'in_progress' })
        "$($initialRunning[0].Type)/$($initialRunning[0].Cycle)" | Should -Be 'ci/0'
        "$($cycleRunning[0].Type)/$($cycleRunning[0].Cycle)" | Should -Be 'review/1'
        $initialRunning.Count + $cycleRunning.Count | Should -Be 2
    }

    It 'counts research, spec and plan done for a prepared plan without a checkpoint' {
        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -PlanText "- [ ] [P0-T1] a." -PreparedPlan $true -MergeStatus 'not_started'))

        Get-TestTypeCount -Step $steps -Status 'done' | Should -Be 'research:1,spec:1,plan:1'
    }

    It 'marks every step done for a merged item' {
        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -MergeStatus 'merged'))
        $byPr = @(Get-EpicProgressItemStep -Item (Get-TestItem -PrState '#7 MERGED'))

        @($steps | Where-Object { $_.Status -ne 'done' }).Count | Should -Be 0
        @($byPr | Where-Object { $_.Status -ne 'done' }).Count | Should -Be 0
        $steps.Count | Should -Be 11
    }

    It 'marks the remaining steps of a blocked item blocked' {
        $json = '{"completed_steps":["S2_research"],"blocked_reason":"policy_hold","next_step":"S3_promotion"}'

        $steps = @(Get-EpicProgressItemStep -Item (Get-TestItem -CheckpointJson $json))

        Get-TestTypeCount -Step $steps -Status 'done' | Should -Be 'research:1,preflight:1,execution:1'
        @($steps | Where-Object { $_.Status -eq 'blocked' }).Count | Should -Be 8
        @($steps | Where-Object { $_.Status -in @('remaining', 'in_progress') }).Count | Should -Be 0
    }
}

Describe 'Get-EpicProgressEpicStep' {
    It 'derives main-sync steps from sync rows only' {
        # Rows 12 and 77 are kickoff children; 900 and 901 are sync rows.
        $json = '{"features":[{"issue_num":12,"merge_status":"merged"},{"issue_num":77,"merge_status":"pr_open"},' +
        '{"issue_num":900,"merge_status":"merged","worktree_created_at":"2026-01-05T09:00:00Z","merge_confirmed_at":"2026-01-05T10:00:00Z"},' +
        '{"issue_num":901,"merge_status":"pr_open","worktree_created_at":"2026-01-05T11:00:00Z"}]}'

        $steps = @(Get-EpicProgressEpicStep -Checkpoint (ConvertFrom-Json -InputObject $json) -KickoffIssue @('12', '77') -EpicIssue '42')

        $sync = @($steps | Where-Object { $_.Type -eq 'main-sync' })
        ($sync.Issue -join ',') | Should -Be '900,901'
        ($sync.Status -join ',') | Should -Be 'done,in_progress'
        $sync[0].Key | Should -Be '42|main-sync|900|1767603600'
        $sync[1].StartedUnixSeconds | Should -Be 1767610800
        @($steps | Where-Object { $_.Type -eq 'integration-pr' }).Count | Should -Be 1
    }

    It 'marks integration-pr done when merge_commit_sha is present' {
        $merged = @(Get-EpicProgressEpicStep -Checkpoint (ConvertFrom-Json -InputObject '{"features":[],"epic_merge_pr":{"pr_number":5,"merge_commit_sha":"abc"}}') -KickoffIssue @() -EpicIssue '42')
        $open = @(Get-EpicProgressEpicStep -Checkpoint (ConvertFrom-Json -InputObject '{"features":[],"epic_merge_pr":{"pr_number":5}}') -KickoffIssue @() -EpicIssue '42')
        $none = @(Get-EpicProgressEpicStep -Checkpoint $null -KickoffIssue @() -EpicIssue '42')

        $merged[0].Status | Should -Be 'done'
        $merged[0].Key | Should -Be '42|integration-pr|c0|1'
        $open[0].Status | Should -Be 'in_progress'
        $none.Count | Should -Be 1
        $none[0].Status | Should -Be 'remaining'
    }
}
