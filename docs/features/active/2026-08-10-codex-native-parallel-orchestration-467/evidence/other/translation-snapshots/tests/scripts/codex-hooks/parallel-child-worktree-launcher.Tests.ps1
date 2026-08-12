#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex parallel-child worktree launcher contract' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:ContractPath = Join-Path $script:RepoRoot `
            '.codex/scripts/parallel-child-launch-contract.ps1'
        $script:BatchPath = Join-Path $script:RepoRoot `
            '.codex/scripts/launch-parallel-child-batch.ps1'
        $script:ResumePath = Join-Path $script:RepoRoot `
            '.codex/scripts/resume-parallel-child.ps1'
        $script:AdapterPaths = @(
            $script:ContractPath
            $script:BatchPath
            $script:ResumePath
        )

        function Import-ParallelChildAdapter {
            $missing = @($script:AdapterPaths | Where-Object {
                    -not (Test-Path -LiteralPath $_ -PathType Leaf)
                })
            $missing | Should -BeNullOrEmpty -Because `
                'the parallel child launch, batch, and resume adapters must exist'
        }

        Import-ParallelChildAdapter
        foreach ($path in $script:AdapterPaths) {
            . $path
        }

        $script:Worktree = Join-Path $script:RepoRoot 'worktrees/parallel-101'
        $script:Entry = [pscustomobject]@{
            launch_id                  = 'parallel-101'
            delegation_id              = 'parallel-delegation-101'
            issue_num                  = 101
            feature_folder             = 'docs/features/active/parallel-item-101'
            cohort                     = 0
            batch                      = 0
            deployment_agent           = 'orchestrator-c3-elevated'
            model                      = 'gpt-5.6-sol'
            model_reasoning_effort     = 'high'
            permissions                = 'orchestrator-workspace'
            execution_context          = 'parallel_execution_child'
            worktree_path              = $script:Worktree
            branch_name                = 'feature/parallel-item-101'
            authority_receipt_path     = 'artifacts/orchestration/parallel-101.authority.json'
            delegation_receipt_path    = 'artifacts/orchestration/parallel-101.delegation.json'
            topology_receipt_path      = 'artifacts/orchestration/parallel-101.topology.json'
            model_routing_receipt_path = 'artifacts/orchestration/parallel-101.model.json'
            launch_status_path         = 'artifacts/orchestration/parallel-101.status.json'
            prompt                     = 'Parallel execution from the committed atomic plan.'
        }
        $script:Spec = [pscustomobject]@{
            schema_version  = 2
            surface         = 'parallel'
            parallel_slug   = 'sample-run'
            base_branch     = 'main'
            pr_target       = 'main'
            cohort          = 0
            batch           = 0
            max_concurrency = 2
            checkpoint_path = 'artifacts/orchestration/parallel-orchestrator-state.json'
            launches        = @($script:Entry)
        }
        $script:Checkpoint = [pscustomobject]@{
            route_id        = 'parallel'
            parallel_slug   = 'sample-run'
            mode            = 'closed'
            max_concurrency = 2
            current_cohort  = 0
            items           = @([pscustomobject]@{
                    issue_num           = 101
                    cohort              = 0
                    batch               = 0
                    state               = 'scheduled'
                    worktree_path       = $script:Worktree
                    branch              = 'feature/parallel-item-101'
                    launch_receipt_path = 'artifacts/orchestration/parallel-101.receipt.json'
                    launch_status_path  = 'artifacts/orchestration/parallel-101.status.json'
                })
        }
        $script:Profile = [pscustomobject]@{
            name                   = 'orchestrator-c3-elevated'
            model                  = 'gpt-5.6-sol'
            model_reasoning_effort = 'high'
            default_permissions    = 'orchestrator-workspace'
            developer_instructions = 'exact instructions'
            skills_config          = '[{ name = "orchestrate", enabled = true }]'
            profile_path           = Join-Path $script:Worktree `
                '.codex/agents/orchestrator-c3-elevated.toml'
            profile_sha256         = ('a' * 64)
            worktree_path          = $script:Worktree
        }
        $profileKey = "$($script:Worktree)`norchestrator-c3-elevated"
        $script:Profiles = @{ $profileKey = $script:Profile }
        $script:Branches = @{ $script:Worktree = 'feature/parallel-item-101' }
    }

    It 'accepts only the parallel surface with main as base and PR target' {
        $errors = Test-CodexParallelChildLaunchSpec -Spec $script:Spec `
            -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches

        $errors | Should -BeNullOrEmpty

        $wrongSurface = $script:Spec.PSObject.Copy()
        $wrongSurface.surface = 'epic'
        Test-CodexParallelChildLaunchSpec -Spec $wrongSurface `
            -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "surface must be 'parallel'."

        foreach ($field in @('base_branch', 'pr_target')) {
            $wrongMain = $script:Spec.PSObject.Copy()
            $wrongMain.$field = 'develop'
            Test-CodexParallelChildLaunchSpec -Spec $wrongMain `
                -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
                -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
                Should -Contain "base_branch and pr_target must both be 'main'."
        }
    }

    It 'rejects integration and fan-in state on every parallel launch' {
        foreach ($field in @('integration_branch', 'integration_pr', 'fan_in', 'waves')) {
            $mixed = $script:Spec.PSObject.Copy()
            $mixed | Add-Member -NotePropertyName $field -NotePropertyValue 'forbidden'

            Test-CodexParallelChildLaunchSpec -Spec $mixed `
                -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
                -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
                Should -Contain 'parallel launch state must not contain integration or fan-in fields.'
        }
    }

    It 'binds exactly one item to its issue, worktree, and feature branch' {
        $duplicate = $script:Spec.PSObject.Copy()
        $duplicate.launches = @($script:Entry, $script:Entry)
        Test-CodexParallelChildLaunchSpec -Spec $duplicate `
            -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain 'each parallel item must resolve to exactly one launch entry.'

        $wrongBranch = $script:Entry.PSObject.Copy()
        $wrongBranch.branch_name = 'feature/other'
        $drifted = $script:Spec.PSObject.Copy()
        $drifted.launches = @($wrongBranch)
        Test-CodexParallelChildLaunchSpec -Spec $drifted `
            -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
            Should -Contain "parallel item 101 branch or worktree binding differs from the checkpoint."
    }

    It 'rejects wrong profile, model, branch, or worktree identity' {
        Test-CodexParallelChildLaunchSpec -Spec $script:Spec `
            -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
            -ProfilesByKey @{} -LiveBranchesByWorktree $script:Branches |
            Should -Contain 'parallel item 101 has no exact generated profile.'

        foreach ($field in @('model', 'branch_name', 'worktree_path')) {
            $entry = $script:Entry.PSObject.Copy()
            $entry.$field = 'mismatched'
            $spec = $script:Spec.PSObject.Copy()
            $spec.launches = @($entry)

            Test-CodexParallelChildLaunchSpec -Spec $spec `
                -Checkpoint $script:Checkpoint -RepositoryRoot $script:RepoRoot `
                -ProfilesByKey $script:Profiles -LiveBranchesByWorktree $script:Branches |
                Should -Not -BeNullOrEmpty
        }
    }

    It 'seals immutable launch and checkpoint hashes without epic fields' {
        $receipt = Get-CodexParallelChildLaunchReceipt -Spec $script:Spec `
            -Entry $script:Entry -AgentProfile $script:Profile `
            -CodexRuntime ([pscustomobject]@{
                CommandPath = 'codex.exe'; DeniedPaths = @('C:/codex.exe')
            }) -SpecPath 'spec.json' -SpecSha256 ('b' * 64) `
            -CheckpointPath 'checkpoint.json' -CheckpointSha256 ('c' * 64) `
            -ReceiptPath 'receipt.json' -StatusPath 'status.json' `
            -CodexHomePath 'C:/isolated/parallel-101' -BatchLockPath 'batch.lock'

        $receipt.surface | Should -BeExactly 'parallel'
        $receipt.base_branch | Should -BeExactly 'main'
        $receipt.pr_target | Should -BeExactly 'main'
        $receipt.spec_sha256 | Should -BeExactly ('b' * 64)
        $receipt.checkpoint_sha256 | Should -BeExactly ('c' * 64)
        $receipt.prompt_sha256 | Should -Match '^[0-9a-f]{64}$'
        $receipt.runtime_permissions | Should -BeExactly 'parallel-child-workspace'
        $receipt.PSObject.Properties.Name | Should -Not -Contain 'integration_branch'
        $receipt.PSObject.Properties.Name | Should -Not -Contain 'fan_in'
    }

    It 'orders a bounded cohort batch by item key without thread-capacity reordering' {
        $items = @(
            [pscustomobject]@{ issue_num = 202; cohort = 0; batch = 0; state = 'scheduled' }
            [pscustomobject]@{ issue_num = 101; cohort = 0; batch = 0; state = 'scheduled' }
            [pscustomobject]@{ issue_num = 303; cohort = 0; batch = 1; state = 'scheduled' }
        )
        $ordered = @(Get-CodexParallelChildBatchOrder -Items $items -Cohort 0 `
                -Batch 0 -MaxConcurrency 2 -AvailableThreadCount 8)

        @($ordered.issue_num) | Should -Be @(101, 202)
    }

    It 'invokes the shared bounded scheduler in persisted item order' {
        $script:startedIssueNumbers = [System.Collections.Generic.List[int]]::new()
        $script:activeChildren = 0
        $script:maximumActiveChildren = 0
        Mock Start-CodexParallelChildProcess {
            param($Context, $Entry)
            $null = $Context
            $script:startedIssueNumbers.Add([int]$Entry.issue_num)
            $script:activeChildren++
            $script:maximumActiveChildren = [Math]::Max(
                $script:maximumActiveChildren,
                $script:activeChildren
            )
            return [pscustomobject]@{
                Entry    = $Entry
                ExitTask = [System.Threading.Tasks.Task]::CompletedTask
            }
        }
        Mock Complete-CodexParallelChildProcess {
            param($Context, $Child)
            $null = $Context
            $null = $Child
            $script:activeChildren--
            return [pscustomobject]@{ state = 'completed'; exit_code = 0 }
        }
        $ordered = @(
            [pscustomobject]@{ issue_num = 101; launch_id = 'parallel-101' }
            [pscustomobject]@{ issue_num = 202; launch_id = 'parallel-202' }
            [pscustomobject]@{ issue_num = 303; launch_id = 'parallel-303' }
        )

        Start-CodexParallelChildBatch -Context ([pscustomobject]@{
                OrderedLaunches = $ordered
                Maximum         = 2
            }) -Confirm:$false | Out-Null

        @($script:startedIssueNumbers) | Should -Be @(101, 202, 303)
        $script:maximumActiveChildren | Should -Be 2
        Assert-MockCalled Start-CodexParallelChildProcess -Times 3 -Exactly
        Assert-MockCalled Complete-CodexParallelChildProcess -Times 3 -Exactly

        $source = Get-Content -Raw -LiteralPath $script:BatchPath
        foreach ($requiredCall in @(
                'Start-CodexChildProcessCore',
                'Complete-CodexChildProcessCore',
                'Get-CodexChildAvailableLaunchCount',
                'Write-CodexParallelChildStatus',
                'Start-CodexParallelChildBatch -Context $context'
            )) {
            $source | Should -Match ([regex]::Escape($requiredCall))
        }
    }

    It 'uses the bound worktree and isolated CODEX_HOME for launch and resume' {
        $receipt = [pscustomobject]@{
            surface = 'parallel'; worktree_path = $script:Worktree
            codex_home_path = 'C:/isolated/parallel-101'; codex_session_id = 'session-101'
            spec_sha256 = ('b' * 64); checkpoint_sha256 = ('c' * 64)
            launch_id = 'parallel-101'; deployment_agent = 'orchestrator-c3-elevated'
            model = 'gpt-5.6-sol'; model_reasoning_effort = 'high'
            permissions = 'orchestrator-workspace'; branch_name = 'feature/parallel-item-101'
            runtime_permissions = 'parallel-child-workspace'
            issue_num = 101; launch_status_path = $script:Entry.launch_status_path
        }
        $priorDelegation = $env:CODEX_EPIC_CHILD_DELEGATION_ID
        $priorIntegration = $env:CODEX_EPIC_INTEGRATION_HEAD
        try {
            $env:CODEX_EPIC_CHILD_DELEGATION_ID = 'ambient-epic-delegation'
            $env:CODEX_EPIC_INTEGRATION_HEAD = 'ambient-epic-integration'
            $launch = Get-CodexParallelChildProcessStartInfo -Entry $script:Entry `
                -AgentProfile $script:Profile -Receipt $receipt -LastMessagePath 'last.txt'
        } finally {
            $env:CODEX_EPIC_CHILD_DELEGATION_ID = $priorDelegation
            $env:CODEX_EPIC_INTEGRATION_HEAD = $priorIntegration
        }
        $resumeErrors = @(Test-CodexParallelChildResumeEvidence -Receipt $receipt `
                -Spec $script:Spec -Checkpoint $script:Checkpoint `
                -Status ([pscustomobject]@{
                    state = 'completed'; launch_id = 'parallel-101'
                    spec_sha256 = ('b' * 64); checkpoint_sha256 = ('c' * 64)
                }))

        $launch.WorkingDirectory | Should -BeExactly $script:Worktree
        $launch.Environment['CODEX_HOME'] | Should -BeExactly 'C:/isolated/parallel-101'
        $launch.Environment.ContainsKey('CODEX_EPIC_CHILD_DELEGATION_ID') |
            Should -BeFalse
        $launch.Environment.ContainsKey('CODEX_EPIC_INTEGRATION_HEAD') |
            Should -BeFalse
        ($launch.ArgumentList -join "`n") |
            Should -Match 'default_permissions="parallel-child-workspace"'
        ($launch.ArgumentList -join "`n") | Should -Match 'approval_policy="never"'
        ($launch.ArgumentList -join "`n") |
            Should -Match 'permissions\.parallel-child-workspace='
        $resumeErrors | Should -BeNullOrEmpty

        $permissionMismatch = $receipt.PSObject.Copy()
        $permissionMismatch.runtime_permissions = 'orchestrator-workspace'
        Test-CodexParallelChildResumeEvidence -Receipt $permissionMismatch `
            -Spec $script:Spec -Checkpoint $script:Checkpoint `
            -Status ([pscustomobject]@{
                state = 'completed'; launch_id = 'parallel-101'
                spec_sha256 = ('b' * 64); checkpoint_sha256 = ('c' * 64)
            }) | Should -Contain `
            'parallel resume runtime permissions differ from the sealed child profile.'

        $receipt.spec_sha256 = ('d' * 64)
        Test-CodexParallelChildResumeEvidence -Receipt $receipt `
            -Spec $script:Spec -Checkpoint $script:Checkpoint `
            -Status ([pscustomobject]@{ spec_sha256 = ('b' * 64) }) |
            Should -Contain 'resume launch hashes do not match the sealed evidence.'
    }
}
