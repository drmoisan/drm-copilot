#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex parallel child resume live-truth contract' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/scripts/resume-parallel-child.ps1')

        function Get-TestParallelResumeEvidence {
            $head = 'a' * 40
            $specHash = 'b' * 64
            $checkpointHash = 'c' * 64
            $worktree = 'C:/worktrees/parallel-item-101'
            $branch = 'feature/parallel-item-101'
            $entry = [pscustomobject]@{
                launch_id              = 'parallel-101'
                issue_num              = 101
                worktree_path          = $worktree
                branch_name            = $branch
                deployment_agent       = 'orchestrator-c3-elevated'
                model                  = 'gpt-5.6-sol'
                model_reasoning_effort = 'high'
                permissions            = 'orchestrator-workspace'
                launch_status_path     = 'artifacts/orchestration/parallel/item-101-status.json'
            }
            $receipt = [pscustomobject]@{
                schema_version             = 1
                surface                    = 'parallel'
                launch_id                  = 'parallel-101'
                issue_num                  = 101
                repository                 = 'owner/repository'
                worktree_path              = $worktree
                branch_name                = $branch
                deployment_agent           = 'orchestrator-c3-elevated'
                model                      = 'gpt-5.6-sol'
                model_reasoning_effort     = 'high'
                permissions                = 'orchestrator-workspace'
                runtime_permissions        = 'parallel-child-workspace'
                spec_sha256                = $specHash
                checkpoint_sha256          = $checkpointHash
                authority_receipt_path     = 'artifacts/orchestration/parallel/item-101-authority.json'
                delegation_receipt_path    = 'artifacts/orchestration/parallel/item-101-delegation.json'
                topology_receipt_path      = 'artifacts/orchestration/parallel/item-101-topology.json'
                model_routing_receipt_path = 'artifacts/orchestration/parallel/item-101-model-routing.json'
                child_status_path          = 'artifacts/orchestration/parallel/item-101-status.json'
                origin_main_head           = $head
            }
            $spec = [pscustomobject]@{
                schema_version = 1
                surface        = 'parallel'
                repository     = 'owner/repository'
                base_branch    = 'main'
                pr_target      = 'main'
                launches       = @($entry)
            }
            $checkpoint = [pscustomobject]@{
                schema_version     = 1
                route_id           = 'parallel'
                recolor_generation = 2
                items              = @(
                    [pscustomobject]@{
                        issue_num     = 101
                        state         = 'in_flight'
                        cohort        = 0
                        batch         = 0
                        worktree_path = $worktree
                        branch        = $branch
                        branch_name   = $branch
                        launch_id     = 'parallel-101'
                        pr_number     = 444
                    }
                    [pscustomobject]@{
                        issue_num     = 202
                        state         = 'scheduled'
                        cohort        = 0
                        batch         = 1
                        worktree_path = 'C:/worktrees/parallel-item-202'
                        branch        = 'feature/parallel-item-202'
                        branch_name   = 'feature/parallel-item-202'
                        launch_id     = 'parallel-202'
                        pr_number     = 445
                    }
                )
                mutations          = @(
                    [pscustomobject]@{ sequence = 1; op = 'add'; item_key = 101 }
                    [pscustomobject]@{ sequence = 2; op = 'add'; item_key = 202 }
                )
                drift_events       = @(
                    [pscustomobject]@{
                        sequence              = 1
                        status                = 'resolved'
                        resolution_generation = 2
                    }
                )
            }
            $status = [pscustomobject]@{
                launch_id         = 'parallel-101'
                spec_sha256       = $specHash
                checkpoint_sha256 = $checkpointHash
                state             = 'failed'
                pid               = 3210
            }
            $liveTruth = [pscustomobject]@{
                schema_version              = 1
                selected_issue_num          = 101
                repository                  = 'owner/repository'
                origin_main_head            = $head
                worktree_path               = $worktree
                branch_name                 = $branch
                worktree_head               = $head
                pr_number                   = 444
                pr_base_branch              = 'main'
                pr_head_branch              = $branch
                pr_head_sha                 = $head
                pr_state                    = 'OPEN'
                checks_head_sha             = $head
                checks_conclusion           = 'success'
                launch_id                   = 'parallel-101'
                spec_sha256                 = $specHash
                checkpoint_sha256           = $checkpointHash
                latest_mutation_sequence    = 2
                recolor_generation          = 2
                drift_resolution_generation = 2
                unresolved_drift            = $false
                authority_receipt_path      = 'artifacts/orchestration/parallel/item-101-authority.json'
                delegation_receipt_path     = 'artifacts/orchestration/parallel/item-101-delegation.json'
                topology_receipt_path       = 'artifacts/orchestration/parallel/item-101-topology.json'
                model_routing_receipt_path  = 'artifacts/orchestration/parallel/item-101-model-routing.json'
                deployment_agent            = 'orchestrator-c3-elevated'
                model                       = 'gpt-5.6-sol'
                model_reasoning_effort      = 'high'
                permissions                 = 'orchestrator-workspace'
                child_status_path           = 'artifacts/orchestration/parallel/item-101-status.json'
                child_status_launch_id      = 'parallel-101'
                child_status_pid            = 3210
                live_process_pid            = 3210
                live_process_running        = $false
                should_relaunch             = $true
            }
            return [pscustomobject]@{
                Receipt    = $receipt
                Spec       = $spec
                Checkpoint = $checkpoint
                Status     = $status
                LiveTruth  = $liveTruth
            }
        }

        function Invoke-TestParallelResumeValidation {
            param([Parameter(Mandatory)] $Evidence)

            return Test-CodexParallelChildResumeEvidence `
                -Receipt $Evidence.Receipt `
                -Spec $Evidence.Spec `
                -Checkpoint $Evidence.Checkpoint `
                -Status $Evidence.Status `
                -LiveTruth $Evidence.LiveTruth `
                -RequireCompleteEvidence
        }
    }

    It 'accepts one complete live-truth binding without mutating evidence' {
        $evidence = Get-TestParallelResumeEvidence
        $snapshot = $evidence | ConvertTo-Json -Depth 32 -Compress

        @(Invoke-TestParallelResumeValidation -Evidence $evidence) | Should -BeNullOrEmpty
        ($evidence | ConvertTo-Json -Depth 32 -Compress) | Should -BeExactly $snapshot
    }

    It 'rejects a relaunch whose sealed runtime permission changed' {
        $evidence = Get-TestParallelResumeEvidence
        $evidence.Receipt.runtime_permissions = 'orchestrator-workspace'

        @(Invoke-TestParallelResumeValidation -Evidence $evidence) |
            Should -Contain 'parallel resume runtime permissions differ from the sealed child profile.'
    }

    It 'rejects every mismatched authority with a stable reason code' {
        $cases = @(
            @{ Field = 'repository'; Value = 'wrong/repository'; Code = 'PARALLEL_RESUME_GIT_MISMATCH' }
            @{ Field = 'origin_main_head'; Value = ('d' * 40); Code = 'PARALLEL_RESUME_GIT_MISMATCH' }
            @{ Field = 'worktree_path'; Value = 'C:/worktrees/wrong'; Code = 'PARALLEL_RESUME_WORKTREE_MISMATCH' }
            @{ Field = 'pr_head_sha'; Value = ('d' * 40); Code = 'PARALLEL_RESUME_GITHUB_MISMATCH' }
            @{ Field = 'spec_sha256'; Value = ('d' * 64); Code = 'PARALLEL_RESUME_LAUNCH_MISMATCH' }
            @{ Field = 'latest_mutation_sequence'; Value = 1; Code = 'PARALLEL_RESUME_MUTATION_MISMATCH' }
            @{ Field = 'unresolved_drift'; Value = $true; Code = 'PARALLEL_RESUME_DRIFT_UNRESOLVED' }
            @{ Field = 'model'; Value = 'gpt-5.6-terra'; Code = 'PARALLEL_RESUME_ROUTING_MISMATCH' }
            @{ Field = 'child_status_pid'; Value = 9876; Code = 'PARALLEL_RESUME_CHILD_STATUS_MISMATCH' }
            @{ Field = 'selected_issue_num'; Value = 202; Code = 'PARALLEL_RESUME_ORDER_MISMATCH' }
        )

        foreach ($case in $cases) {
            $evidence = Get-TestParallelResumeEvidence
            $evidence.LiveTruth.($case.Field) = $case.Value

            @(Invoke-TestParallelResumeValidation -Evidence $evidence) |
                Should -Contain $case.Code
        }
    }

    It 'rejects missing live truth and all integration or fan-in contamination' {
        $evidence = Get-TestParallelResumeEvidence
        $evidence.LiveTruth = $null
        @(Invoke-TestParallelResumeValidation -Evidence $evidence) |
            Should -Contain 'PARALLEL_RESUME_TRUTH_REQUIRED'

        $evidence = Get-TestParallelResumeEvidence
        $evidence.LiveTruth | Add-Member -NotePropertyName fan_in_pr -NotePropertyValue 9001
        @(Invoke-TestParallelResumeValidation -Evidence $evidence) |
            Should -Contain 'PARALLEL_RESUME_FAN_IN_FORBIDDEN'
    }

    It 'rejects duplicate launch, worktree, branch, and PR identity' {
        foreach ($field in @('launch_id', 'worktree_path', 'branch_name', 'pr_number')) {
            $evidence = Get-TestParallelResumeEvidence
            $evidence.Checkpoint.items[1].$field = $evidence.Checkpoint.items[0].$field

            @(Invoke-TestParallelResumeValidation -Evidence $evidence) |
                Should -Contain 'PARALLEL_RESUME_IDENTITY_DUPLICATE'
        }
    }

    It 'binds live truth through the actual resume context before scheduling' {
        $evidence = Get-TestParallelResumeEvidence
        $receiptPath = Join-Path $script:RepoRoot 'artifacts/orchestration/parallel/test-receipt.json'
        $specPath = Join-Path $script:RepoRoot 'artifacts/orchestration/parallel/test-spec.json'
        $checkpointPath = Join-Path $script:RepoRoot 'artifacts/orchestration/parallel/test-checkpoint.json'
        $statusPath = Join-Path $script:RepoRoot 'artifacts/orchestration/parallel/test-status.json'
        $evidence.Receipt | Add-Member -NotePropertyMembers @{
            trusted_repository_root = $script:RepoRoot
            spec_path               = $specPath
            checkpoint_path         = $checkpointPath
            status_path             = $statusPath
            receipt_path            = $receiptPath
        }
        $script:ResumeContent = @{
            $receiptPath    = $evidence.Receipt | ConvertTo-Json -Depth 32 -Compress
            $specPath       = $evidence.Spec | ConvertTo-Json -Depth 32 -Compress
            $checkpointPath = $evidence.Checkpoint | ConvertTo-Json -Depth 32 -Compress
            $statusPath     = '{}'
        }
        $script:InjectedLiveTruth = $evidence.LiveTruth.PSObject.Copy()
        $script:InjectedLiveTruth.origin_main_head = 'd' * 40
        $script:LiveTruthProviderCalled = $false

        Mock Get-CodexChildCanonicalPath { return [string]$Path }
        Mock Get-Content { return $script:ResumeContent[[string]$LiteralPath] }
        Mock Get-FileHash {
            $hash = if ([string]$LiteralPath -eq $specPath) {
                $evidence.Receipt.spec_sha256
            } else {
                $evidence.Receipt.checkpoint_sha256
            }
            return [pscustomobject]@{ Hash = $hash }
        }
        Mock Get-CodexChildResumeStatusEntryCore { return $evidence.Status }
        Mock Get-CodexChildResumeReconciliationCore { return @() }
        Mock Get-CodexParallelOriginMainHead { return $evidence.Receipt.origin_main_head }
        Mock Get-CodexChildGitScalar {
            if ($GitArgs -contains '--show-current') { return $evidence.Receipt.branch_name }
            return $evidence.LiveTruth.worktree_head
        }
        Mock Test-CodexChildGit { return $true }
        Mock Get-CodexParallelChildProfile { return [pscustomobject]@{} }

        $provider = {
            $script:LiveTruthProviderCalled = $true
            return $script:InjectedLiveTruth
        }
        { Get-CodexParallelChildResumeContext -Path $receiptPath -GetLiveTruth $provider } |
            Should -Throw '*PARALLEL_RESUME_GIT_MISMATCH*'
        $script:LiveTruthProviderCalled | Should -BeTrue
    }

    It 'does not treat cached child status as authority over live process truth' {
        $evidence = Get-TestParallelResumeEvidence
        $evidence.Status.state = 'running'
        $evidence.LiveTruth.live_process_running = $false
        $evidence.LiveTruth.should_relaunch = $true

        @(Invoke-TestParallelResumeValidation -Evidence $evidence) | Should -BeNullOrEmpty

        $evidence.LiveTruth.live_process_running = $true
        $evidence.LiveTruth.should_relaunch = $true
        @(Invoke-TestParallelResumeValidation -Evidence $evidence) |
            Should -Contain 'PARALLEL_RESUME_PROCESS_RUNNING'
    }
}
