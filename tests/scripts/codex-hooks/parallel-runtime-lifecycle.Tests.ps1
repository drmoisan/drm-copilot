#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex parallel runtime lifecycle' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/scripts/launch-parallel-child-batch.ps1')
        . (Join-Path $script:RepoRoot '.codex/scripts/parallel-child-post-session.ps1')
        . (Join-Path $script:RepoRoot '.codex/scripts/resume-parallel-child.ps1')

        function Copy-LifecycleValue {
            param([Parameter(Mandatory)] $Value)

            return $Value | ConvertTo-Json -Depth 32 | ConvertFrom-Json -Depth 32
        }

        function Get-LifecycleLaunchFixture {
            $worktree = Join-Path $script:RepoRoot 'worktrees/parallel-lifecycle-101'
            $branch = 'feature/parallel-lifecycle-101'
            $entry = [pscustomobject]@{
                launch_id                  = 'parallel-lifecycle-101'
                delegation_id              = 'parallel-delegation-101'
                issue_num                  = 101
                feature_folder             = 'docs/features/active/parallel-lifecycle-101'
                cohort                     = 0
                batch                      = 0
                deployment_agent           = 'orchestrator-c3-elevated'
                model                      = 'gpt-5.6-sol'
                model_reasoning_effort     = 'high'
                permissions                = 'orchestrator-workspace'
                execution_context          = 'parallel_execution_child'
                worktree_path              = $worktree
                branch_name                = $branch
                authority_receipt_path     = 'artifacts/orchestration/parallel-101.authority.json'
                delegation_receipt_path    = 'artifacts/orchestration/parallel-101.delegation.json'
                topology_receipt_path      = 'artifacts/orchestration/parallel-101.topology.json'
                model_routing_receipt_path = 'artifacts/orchestration/parallel-101.model.json'
                launch_status_path         = 'artifacts/orchestration/parallel-101.status.json'
                prompt                     = 'Execute the committed atomic plan.'
            }
            $spec = [pscustomobject]@{
                schema_version  = 2
                surface         = 'parallel'
                parallel_slug   = 'lifecycle-run'
                base_branch     = 'main'
                pr_target       = 'main'
                cohort          = 0
                batch           = 0
                max_concurrency = 2
                launches        = @($entry)
            }
            $checkpoint = [pscustomobject]@{
                route_id        = 'parallel'
                parallel_slug   = 'lifecycle-run'
                current_cohort  = 0
                max_concurrency = 2
                items           = @([pscustomobject]@{
                        issue_num     = 101
                        cohort        = 0
                        batch         = 0
                        state         = 'scheduled'
                        worktree_path = $worktree
                        branch        = $branch
                    })
            }
            $agentProfile = [pscustomobject]@{
                name                    = 'orchestrator-c3-elevated'
                model                   = 'gpt-5.6-sol'
                model_reasoning_effort  = 'high'
                default_permissions     = 'orchestrator-workspace'
                developer_instructions  = 'exact instructions'
                skills_config           = '[{ name = "orchestrate", enabled = true }]'
                profile_path            = Join-Path $worktree '.codex/agents/orchestrator-c3-elevated.toml'
                profile_sha256          = ('a' * 64)
                worktree_path           = $worktree
                trusted_repository_root = $script:RepoRoot
            }
            $profileKey = Get-CodexChildProfileKey -WorktreePath $worktree `
                -AgentName $entry.deployment_agent -RepositoryRoot $script:RepoRoot
            return [pscustomobject]@{
                Entry      = $entry
                Spec       = $spec
                Checkpoint = $checkpoint
                Profiles   = @{ $profileKey = $agentProfile }
                Branches   = @{ $worktree = $branch }
            }
        }
    }

    It 'fills one and multiple launch slots without reordering persisted items' {
        Mock Start-CodexParallelChildProcess {
            param($Context, $Entry)
            $null = $Context
            $script:Started.Add([int]$Entry.issue_num)
            $script:Active += 1
            $script:MaximumActive = [Math]::Max($script:MaximumActive, $script:Active)
            return [pscustomobject]@{
                Entry    = $Entry
                ExitTask = [System.Threading.Tasks.Task]::CompletedTask
            }
        }
        Mock Complete-CodexParallelChildProcess {
            param($Context, $Child)
            $null = $Context
            $null = $Child
            $script:Active -= 1
            return [pscustomobject]@{ state = 'completed'; exit_code = 0 }
        }
        $ordered = @(
            [pscustomobject]@{ issue_num = 101; launch_id = 'parallel-101' }
            [pscustomobject]@{ issue_num = 202; launch_id = 'parallel-202' }
            [pscustomobject]@{ issue_num = 303; launch_id = 'parallel-303' }
        )

        foreach ($maximum in @(1, 2)) {
            $script:Started = [System.Collections.Generic.List[int]]::new()
            $script:Active = 0
            $script:MaximumActive = 0
            Start-CodexParallelChildBatch -Context ([pscustomobject]@{
                    OrderedLaunches = $ordered
                    Maximum         = $maximum
                }) -Confirm:$false | Out-Null

            @($script:Started) | Should -Be @(101, 202, 303)
            $script:MaximumActive | Should -Be $maximum
        }
    }

    It 'rejects later-cohort, wrong identity, and integration or fan-in launch state' {
        $fixture = Get-LifecycleLaunchFixture
        Test-CodexParallelChildLaunchSpec -Spec $fixture.Spec `
            -Checkpoint $fixture.Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $fixture.Profiles -LiveBranchesByWorktree $fixture.Branches |
            Should -BeNullOrEmpty

        $later = Copy-LifecycleValue $fixture.Spec
        $later.cohort = 1
        Test-CodexParallelChildLaunchSpec -Spec $later `
            -Checkpoint $fixture.Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $fixture.Profiles -LiveBranchesByWorktree $fixture.Branches |
            Should -Contain 'parallel launch cohort differs from the checkpoint current cohort.'

        foreach ($field in @('model', 'branch_name', 'worktree_path')) {
            $invalid = Copy-LifecycleValue $fixture.Spec
            $invalid.launches[0].$field = 'mismatched'
            Test-CodexParallelChildLaunchSpec -Spec $invalid `
                -Checkpoint $fixture.Checkpoint -RepositoryRoot $script:RepoRoot `
                -ProfilesByKey $fixture.Profiles -LiveBranchesByWorktree $fixture.Branches |
                Should -Not -BeNullOrEmpty
        }

        $fanIn = Copy-LifecycleValue $fixture.Spec
        $fanIn | Add-Member -NotePropertyName fan_in -NotePropertyValue $true
        Test-CodexParallelChildLaunchSpec -Spec $fanIn `
            -Checkpoint $fixture.Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $fixture.Profiles -LiveBranchesByWorktree $fixture.Branches |
            Should -Contain 'parallel launch state must not contain integration or fan-in fields.'
    }

    It 'does not treat green CI as merged lifecycle completion' {
        $items = @(
            [pscustomobject]@{
                issue_num = 303; cohort = 0; batch = 0; state = 'scheduled'; merge_status = 'not_started'
            }
            [pscustomobject]@{
                issue_num = 202; cohort = 0; batch = 0; state = 'merged'; merge_status = 'merged'
            }
            [pscustomobject]@{
                issue_num = 101; cohort = 0; batch = 0; state = 'in_flight'; merge_status = 'ci_green'
            }
        )

        $ordered = @(Get-CodexParallelChildBatchOrder -Items $items -Cohort 0 `
                -Batch 0 -MaxConcurrency 2 -AvailableThreadCount 8)

        @($ordered.issue_num) | Should -Be @(101, 303)
        @($ordered.issue_num) | Should -Not -Contain 202
    }

    It 'retains the tested per-item post-session and interrupted-resume public seams' {
        (Get-Command Invoke-CodexParallelChildPostSession -CommandType Function) |
            Should -Not -BeNullOrEmpty
        (Get-Command Get-CodexParallelChildResumeContext -CommandType Function) |
            Should -Not -BeNullOrEmpty
        (Get-Command Test-CodexParallelChildResumeEvidence -CommandType Function) |
            Should -Not -BeNullOrEmpty
    }
}
