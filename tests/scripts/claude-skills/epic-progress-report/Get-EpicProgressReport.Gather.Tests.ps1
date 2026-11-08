# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1 (issue #1118).
# The entry script is dot-sourced with its mandatory parameter bound, so the entry-point block is
# skipped and the I/O seams exist. Every seam the Gather functions call is mocked with a matching
# parameter signature over in-memory fixtures; no test starts git, reads a file, or writes one.

BeforeAll {
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'
    . $script:scriptPath -EpicFolder 'example-epic' -StartUtc ([datetime]::new(2026, 1, 5, 9, 0, 0, [System.DateTimeKind]::Utc))
}

Describe 'Gather functions' {
    BeforeAll {
        $script:worktree = '/fixture-repo-wt/alpha'
        $script:checkpointFile = Join-Path -Path $script:worktree -ChildPath 'artifacts/orchestration/orchestrator-state.json'
        $script:integration = 'origin/epic/example-epic-integration'
    }

    BeforeEach {
        $script:files = @{}
        $script:gitCalls = [System.Collections.Generic.List[string]]::new()
        $script:gitShow = @{}
        Mock Test-EpicProgressPath { param([string] $Path) return $script:files.ContainsKey($Path) }
        Mock Read-EpicProgressFile { param([string] $Path) return $script:files[$Path] }
        Mock Invoke-GitExe {
            param([string[]] $GitArgs)
            $script:gitCalls.Add(($GitArgs -join ' '))
            return ($script:gitShow[$GitArgs[1]] -split "`n")
        }
    }

    It 'reads an item checkpoint from the feature worktree' {
        $script:files[$script:checkpointFile] = '{"issue-num":"12","next_step":"S7_feature_review"}'

        $checkpoint = Read-EpicProgressItemCheckpoint -WorktreePath $script:worktree

        $checkpoint.'issue-num' | Should -Be '12'
        $checkpoint.next_step | Should -Be 'S7_feature_review'
        Should -Invoke Read-EpicProgressFile -Times 1 -Exactly -ParameterFilter { $Path -eq $script:checkpointFile }
        Read-EpicProgressItemCheckpoint -WorktreePath '' | Should -BeNullOrEmpty
        Read-EpicProgressItemCheckpoint -WorktreePath '/fixture-repo-wt/absent' | Should -BeNullOrEmpty
    }

    It 'returns no checkpoint for an unparseable file' {
        $script:files[$script:checkpointFile] = 'not json {'

        Read-EpicProgressItemCheckpoint -WorktreePath $script:worktree | Should -BeNullOrEmpty
    }

    It 'reads a remediation plan named by cycles plan_path from the worktree' {
        $checkpoint = ConvertFrom-Json -InputObject '{"feature-folder":"docs/features/active/x","remediation_loop":{"cycles":[{"plan_path":"docs/features/active/x/remediation-plan.md"}]}}'
        $script:files[(Join-Path -Path $script:worktree -ChildPath 'docs/x/plan.md')] = "- [x] [P0-T1] a."
        $script:files[(Join-Path -Path $script:worktree -ChildPath 'docs/features/active/x/remediation-plan.md')] = "- [ ] [P0-T1] fix."
        $script:files[(Join-Path -Path $script:worktree -ChildPath 'docs/features/active/x/spec.md')] = '# spec'

        $item = Get-EpicProgressItemInput -Issue '12' -PlanPath 'docs/x/plan.md' -WorktreePath $script:worktree -IntegrationBranch $script:integration -Checkpoint $checkpoint

        $item.PlanText | Should -Be '- [x] [P0-T1] a.'
        $item.PlanFile | Should -Be 'plan.md'
        $item.CycleText['docs/features/active/x/remediation-plan.md'] | Should -Be '- [ ] [P0-T1] fix.'
        $item.SpecExists | Should -BeTrue
        $item.PreparedPlan | Should -BeFalse
        $item.MergeStatus | Should -Be 'not_started'
        $script:gitCalls.Count | Should -Be 0
    }

    It 'falls back to git show for a cycle plan without a live worktree' {
        $checkpoint = ConvertFrom-Json -InputObject '{"remediation_loop":{"cycles":[{"plan_path":"docs/x/remediation-plan.md"}]}}'
        $script:gitShow["$($script:integration):docs/x/plan.md"] = "- [x] [P0-T1] a.`n- [ ] [P0-T2] b."
        $script:gitShow["$($script:integration):docs/x/remediation-plan.md"] = '- [ ] [P0-T1] fix.'
        $row = ConvertFrom-Json -InputObject '{"issue_num":12,"merge_status":"pr_open"}'

        $item = Get-EpicProgressItemInput -Issue '12' -PlanPath 'docs/x/plan.md' -IntegrationBranch $script:integration -Checkpoint $checkpoint -EpicRow $row -Wave 2 -Band 'large'

        ($script:gitCalls -join "`n") | Should -Be "show $($script:integration):docs/x/plan.md`nshow $($script:integration):docs/x/remediation-plan.md"
        $item.CycleText['docs/x/remediation-plan.md'] | Should -Be '- [ ] [P0-T1] fix.'
        $item.MergeStatus | Should -Be 'pr_open'
        $item.Wave | Should -Be 2
        $item.SpecExists | Should -BeFalse
    }

    It 'locates the item worktree by issue-num' {
        $map = @{ 'feature/alpha' = $script:worktree; 'feature/beta' = '/fixture-repo-wt/beta' }
        $script:files[$script:checkpointFile] = '{"issue-num":"12"}'
        $script:files[(Join-Path -Path '/fixture-repo-wt/beta' -ChildPath 'artifacts/orchestration/orchestrator-state.json')] = '{"issue-num":1118}'

        $found = Find-EpicProgressItemWorktree -Issue '1118' -WorktreeMap $map

        $found.Branch | Should -Be 'feature/beta'
        $found.Path | Should -Be '/fixture-repo-wt/beta'
        $found.Checkpoint.'issue-num' | Should -Be 1118
    }

    It 'throws when no worktree checkpoint carries the issue' {
        $script:files[$script:checkpointFile] = '{"issue-num":"12"}'

        { Find-EpicProgressItemWorktree -Issue '999' -WorktreeMap @{ 'feature/alpha' = $script:worktree } } | Should -Throw -ExpectedMessage '*carries issue-num 999*'
    }

    It 'separates sync rows from kickoff feature rows' {
        $path = '/fixture-repo/artifacts/orchestration/epic-orchestrator-state.json'
        $script:files[$path] = '{"features":[{"issue_num":12,"merge_status":"merged"},{"issue_num":900,"merge_status":"merged"},{"issue_num":77}],"epic_merge_pr":{"pr_number":5}}'

        $rows = Get-EpicProgressEpicCheckpointRow -CheckpointPath $path -KickoffIssue @('12', '77')
        $absent = Get-EpicProgressEpicCheckpointRow -CheckpointPath '/fixture-repo/absent.json' -KickoffIssue @('12')

        (@($rows.Feature.Keys | Sort-Object) -join ',') | Should -Be '12,77'
        ($rows.Sync.issue_num -join ',') | Should -Be '900'
        $rows.MergePr.pr_number | Should -Be 5
        $absent.Checkpoint | Should -BeNullOrEmpty
        $absent.Sync.Count | Should -Be 0
    }

    It 'composes steps, ledger and estimate for gathered items' {
        # One item: review closed after 600 s and an open ci stage; plan of two tasks, one checked;
        # a stored anchor at 1767610800 with no checked task, so P0-T1 is ticked over 3600 s.
        $checkpoint = ConvertFrom-Json -InputObject ('{"completed_steps":["S2_research","S3_promotion","S4_atomic_planning"],"stage_timing":[' +
            '{"stage":"review","attempt":1,"started_at":"2026-01-05T10:00:00Z","ended_at":"2026-01-05T10:10:00Z"},' +
            '{"stage":"ci","attempt":1,"started_at":"2026-01-05T11:50:00Z","ended_at":null}]}')
        $item = [pscustomobject]@{
            Issue = '12'; Wave = 1; Band = 'small'; Checkpoint = $checkpoint; EpicRow = $null
            PlanText = "- [x] [P0-T1] a.`n- [ ] [P0-T2] b."; PlanFile = 'plan.md'; CycleText = @{}; SpecExists = $true
            MergeStatus = 'pr_open'; PrState = '#8 OPEN'; PreparedPlan = $false; Blockage = (Get-EpicProgressBlockage -Checkpoint $checkpoint)
        }
        $state = ConvertFrom-EpicProgressStateText -Text '{"version":2,"items":{"12":{"plans":{"plan.md":{"checked":[],"lastTickUnixSeconds":1767610800}},"blockedSinceUnixSeconds":null}}}'

        # 2026-01-05T12:00:00Z.
        $report = Get-EpicProgressStepReport -Item @($item) -EpicIssue '42' -State $state -NowUnixSeconds 1767614400 -Default (Resolve-EpicProgressStepDefault)

        $report.Feature[0].State | Should -Be 'Running'
        # 10 steps (one per non-execution item type, plus two tasks); research, spec, plan,
        # preflight, review, pr (open PR), and one task are done (7).
        "$($report.Feature[0].Done) of $($report.Feature[0].Total)" | Should -Be '7 of 10'
        $report.EpicStep.Count | Should -Be 1
        $report.Done | Should -Be 7
        $report.LedgerChanged | Should -BeTrue
        $report.Ledger['review'][0].seconds | Should -Be 600
        $report.Ledger['execution'][0].seconds | Should -Be 3600
        $report.ItemsChanged | Should -BeTrue
        ($report.Items['12'].Plans['plan.md'].Checked -join ',') | Should -Be 'P0-T1'
        # ci in progress 600 s of its 17-min default (credit 420); execution 1 x 3600; merge 5 min; integration-pr 45 min.
        $report.Estimate.InProgress[0].Type | Should -Be 'ci'
        $report.Estimate.TotalSeconds | Should -Be (420 + 3600 + 300 + 2700)
        $report.WaveParallelSeconds | Should -Be (420 + 3600 + 300 + 2700)
    }

    Context 'merged item anchors' {
        BeforeAll {
            function Get-TestAnchorItem {
                # One item with a one-task unchecked plan and an empty checkpoint.
                param([string] $Issue, [string] $MergeStatus, [string] $PrState = '')
                $checkpoint = ConvertFrom-Json -InputObject '{}'
                [pscustomobject]@{
                    Issue = $Issue; Wave = 1; Band = 'small'; Checkpoint = $checkpoint; EpicRow = $null
                    PlanText = '- [ ] [P0-T1] a.'; PlanFile = 'plan.md'; CycleText = @{}; SpecExists = $true
                    MergeStatus = $MergeStatus; PrState = $PrState; PreparedPlan = $false; Blockage = (Get-EpicProgressBlockage -Checkpoint $checkpoint -MergeStatus $MergeStatus)
                }
            }
        }

        It 'drops the stored anchor of a merged item and keeps an unmerged one' {
            # Both items hold a stored plan.md anchor with no checked task; #77 ticks nothing, so only
            # the removal of the merged #12 entry changes the items table.
            $items = @(
                Get-TestAnchorItem -Issue '12' -MergeStatus 'merged' -PrState '#7 MERGED'
                Get-TestAnchorItem -Issue '77' -MergeStatus 'pr_open'
            )
            $anchor = '{"plans":{"plan.md":{"checked":[],"lastTickUnixSeconds":1767610800}},"blockedSinceUnixSeconds":null}'
            $state = ConvertFrom-EpicProgressStateText -Text ('{"version":2,"items":{"12":' + $anchor + ',"77":' + $anchor + '}}')

            # 2026-01-05T12:00:00Z.
            $report = Get-EpicProgressStepReport -Item $items -EpicIssue '42' -State $state -NowUnixSeconds 1767614400 -Default (Resolve-EpicProgressStepDefault)

            $report.Items.ContainsKey('12') | Should -BeFalse
            $report.Items.ContainsKey('77') | Should -BeTrue
            $report.ItemsChanged | Should -BeTrue
        }

        It 'leaves ItemsChanged false for a merged item with no stored entry' {
            $state = ConvertFrom-EpicProgressStateText -Text '{"version":2,"items":{}}'

            $report = Get-EpicProgressStepReport -Item @(Get-TestAnchorItem -Issue '12' -MergeStatus 'merged' -PrState '#7 MERGED') -EpicIssue '42' -State $state -NowUnixSeconds 1767614400 -Default (Resolve-EpicProgressStepDefault) -NoEpicStep

            $report.Items.Count | Should -Be 0
            $report.ItemsChanged | Should -BeFalse
        }

        It 'keeps no entry for an unmerged item with no anchor and no blocked span' {
            # #77 is open with no plan text and no stored entry, so no anchor is created for it.
            $item = Get-TestAnchorItem -Issue '77' -MergeStatus 'pr_open'
            $item.PlanText = ''
            $state = ConvertFrom-EpicProgressStateText -Text '{"version":2,"items":{}}'

            $report = Get-EpicProgressStepReport -Item @($item) -EpicIssue '42' -State $state -NowUnixSeconds 1767614400 -Default (Resolve-EpicProgressStepDefault) -NoEpicStep

            $report.Items.Count | Should -Be 0
            $report.ItemsChanged | Should -BeFalse
        }
    }

    Context 'in-progress execution start' {
        BeforeAll {
            function Get-TestExecutionReport {
                # One item with an open execution stage since 10:00 and P0-T1 of two tasks checked;
                # the stored anchor holds P0-T1 at the given last tick, and the run is at 12:00.
                param([long] $LastTick)
                $checkpoint = ConvertFrom-Json -InputObject '{"stage_timing":[{"stage":"execution","attempt":1,"started_at":"2026-01-05T10:00:00Z","ended_at":null}]}'
                $item = [pscustomobject]@{
                    Issue = '12'; Wave = 1; Band = 'small'; Checkpoint = $checkpoint; EpicRow = $null
                    PlanText = "- [x] [P0-T1] a.`n- [ ] [P0-T2] b."; PlanFile = 'plan.md'; CycleText = @{}; SpecExists = $true
                    MergeStatus = 'worktree_created'; PrState = ''; PreparedPlan = $false; Blockage = (Get-EpicProgressBlockage -Checkpoint $checkpoint)
                }
                $state = ConvertFrom-EpicProgressStateText -Text ('{"version":2,"items":{"12":{"plans":{"plan.md":{"checked":["P0-T1"],"lastTickUnixSeconds":' + $LastTick + '}},"blockedSinceUnixSeconds":null}}}')
                # 2026-01-05T12:00:00Z.
                Get-EpicProgressStepReport -Item @($item) -EpicIssue '42' -State $state -NowUnixSeconds 1767614400 -Default (Resolve-EpicProgressStepDefault) -NoEpicStep
            }
        }

        It 'starts the in-progress execution step at a later plan tick' {
            # The last tick at 11:58 (1767614280) is later than the stage start at 10:00: 120 s elapsed.
            $report = Get-TestExecutionReport -LastTick 1767614280

            $running = @($report.Estimate.InProgress | Where-Object { $_.Type -eq 'execution' })
            $running.Count | Should -Be 1
            $running[0].ElapsedSeconds | Should -Be 120
            # Against the 5-minute execution default.
            $running[0].MedianSeconds | Should -Be 300
            $running[0].OverMedian | Should -BeFalse
        }

        It 'keeps the execution stage start when the last tick is earlier' {
            # The last tick at 09:00 (1767603600) is before the stage start at 10:00: 7200 s elapsed.
            $report = Get-TestExecutionReport -LastTick 1767603600

            $running = @($report.Estimate.InProgress | Where-Object { $_.Type -eq 'execution' })
            $running.Count | Should -Be 1
            $running[0].ElapsedSeconds | Should -Be 7200
        }
    }
}
