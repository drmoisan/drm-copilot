BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-wave-barrier.ps1')
    $script:Now = [datetimeoffset]'2026-07-10T22:00:00Z'

    function Get-WaveLaunchContext {
        param(
            [ValidateSet('epic_preparation_child', 'epic_execution_child')]
            [string] $Context = 'epic_execution_child'
        )
        $waveRoot = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/wave-1'
        $checkpointName = if ($Context -eq 'epic_preparation_child') {
            'epic-planner-state.json'
        } else {
            'epic-orchestrator-state.json'
        }
        $receipt = [ordered]@{
            schema_version          = 2
            state                   = 'active'
            codex_session_id        = 'session-1'
            session_bound_at        = '2026-07-10T21:59:00Z'
            expires_at              = '2026-07-11T22:00:00Z'
            launch_id               = 'launch-2'
            issue_num               = 2
            delegation_id           = 'delegation-2'
            feature_folder          = 'docs/features/active/feature-two'
            deployment_agent        = 'orchestrator-c3-elevated'
            model                   = 'gpt-5.6-sol'
            model_reasoning_effort  = 'high'
            execution_context       = $Context
            worktree_path           = $script:RepoRoot
            branch_name             = 'feature/two'
            receipt_path            = Join-Path $waveRoot 'launch-2.receipt.json'
            status_path             = Join-Path $waveRoot 'wave.wave-1.status.json'
            spec_path               = Join-Path $waveRoot 'spec.json'
            profile_path            = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
            profile_sha256          = 'profile-hash'
            codex_home_path         = Join-Path $HOME '.codex/authority/epic-child'
            checkpoint_kind         = 'epic-orchestrator'
            wave_lock_path          = Join-Path $waveRoot 'semantic-wave.lock'
            trusted_repository_root = $script:RepoRoot
            checkpoint_path         = Join-Path $script:RepoRoot "artifacts/orchestration/$checkpointName"
        }
        $environment = [pscustomobject]@{
            launch_id         = [string]$receipt.launch_id
            receipt_path      = [string]$receipt.receipt_path
            spec_path         = [string]$receipt.spec_path
            worktree_path     = [string]$receipt.worktree_path
            delegation_id     = [string]$receipt.delegation_id
            execution_context = [string]$receipt.execution_context
            deployment_agent  = [string]$receipt.deployment_agent
            model             = [string]$receipt.model
            reasoning_effort  = [string]$receipt.model_reasoning_effort
            profile_sha256    = [string]$receipt.profile_sha256
        }
        return [pscustomobject]@{ Receipt = $receipt; Environment = $environment }
    }

    function Invoke-TestWaveDecision {
        param(
            [Parameter(Mandatory)] $Context,
            [string] $UpstreamStatus = 'pending',
            [string] $Payload = '{"tool_name":"apply_patch","session_id":"session-1"}'
        )
        $checkpoint = [ordered]@{
            features = @(
                [ordered]@{
                    issue_num      = 1
                    feature_folder = 'docs/features/active/feature-one'
                    depends_on     = @()
                    merge_status   = $UpstreamStatus
                },
                [ordered]@{
                    issue_num      = 2
                    feature_folder = 'docs/features/active/feature-two'
                    depends_on     = @('1')
                    merge_status   = 'pending'
                }
            )
        }
        return Invoke-CodexEpicWaveDecision -PayloadRaw $Payload -LocalCheckpointRaw '' -EpicCheckpointRaw ($checkpoint | ConvertTo-Json -Depth 10) -LauncherReceiptRaw ($Context.Receipt | ConvertTo-Json -Depth 10) -LauncherEnvironment $Context.Environment -RepositoryRoot $script:RepoRoot -Now $script:Now
    }
}

Describe 'Receipt-bound epic wave barrier' {
    It 'blocks the first mutation before a local child checkpoint exists' {
        $context = Get-WaveLaunchContext

        $decision = Invoke-TestWaveDecision -Context $context

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'feature-two'
    }

    It 'allows mutation after every dependency is durably merged' {
        $context = Get-WaveLaunchContext

        Invoke-TestWaveDecision -Context $context -UpstreamStatus merged | Should -BeNullOrEmpty
    }

    It 'allows mutation after every dependency worktree is removed' {
        $context = Get-WaveLaunchContext

        Invoke-TestWaveDecision -Context $context -UpstreamStatus worktree_removed |
            Should -BeNullOrEmpty
    }

    It 'fails closed when the launcher receipt is bound to another session' {
        $context = Get-WaveLaunchContext
        $context.Receipt.codex_session_id = 'session-2'

        (Invoke-TestWaveDecision -Context $context).hookSpecificOutput.permissionDecision |
            Should -Be 'deny'
    }

    It 'fails closed when final issue and feature-folder identity do not match' {
        $context = Get-WaveLaunchContext
        $context.Receipt.issue_num = 3

        (Invoke-TestWaveDecision -Context $context).hookSpecificOutput.permissionDecision |
            Should -Be 'deny'
    }

    It 'does not apply execution-wave gating to a preparation child' {
        $context = Get-WaveLaunchContext -Context epic_preparation_child

        Invoke-TestWaveDecision -Context $context | Should -BeNullOrEmpty
    }

    It 'classifies every built-in file mutation tool as a wave mutation' -ForEach @(
        @{ Tool = 'apply_patch' }
        @{ Tool = 'Edit' }
        @{ Tool = 'Write' }
    ) {
        Test-CodexWaveMutation -Payload ([pscustomobject]@{ tool_name = $Tool }) |
            Should -BeTrue
    }

    It 'does not gate a non-mutating read tool' {
        $context = Get-WaveLaunchContext

        Invoke-TestWaveDecision -Context $context -Payload '{"tool_name":"Read","session_id":"session-1"}' |
            Should -BeNullOrEmpty
    }
}
