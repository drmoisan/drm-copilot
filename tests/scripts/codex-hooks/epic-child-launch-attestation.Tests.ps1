BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.codex/hooks/codex-epic-child-launch-attestation.ps1')
    $script:Now = [datetimeoffset]'2026-07-10T22:00:00Z'

    function Get-TestLaunchReceipt {
        param(
            [ValidateSet('epic_preparation_child', 'epic_execution_child')]
            [string] $Context = 'epic_execution_child'
        )
        $waveRoot = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-child-launches/wave-1'
        $checkpoint = if ($Context -eq 'epic_preparation_child') {
            'epic-planner-state.json'
        } else {
            'epic-orchestrator-state.json'
        }
        return [ordered]@{
            schema_version          = 2
            state                   = 'active'
            codex_session_id        = 'session-1'
            session_bound_at        = '2026-07-10T21:59:00Z'
            expires_at              = '2026-07-11T22:00:00Z'
            launch_id               = 'launch-1'
            delegation_id           = 'delegation-1'
            feature_folder          = 'docs/features/active/feature-one'
            deployment_agent        = 'orchestrator-c3-elevated'
            model                   = 'gpt-5.6-sol'
            model_reasoning_effort  = 'high'
            execution_context       = $Context
            worktree_path           = $script:RepoRoot
            branch_name             = 'feature/one'
            receipt_path            = Join-Path $waveRoot 'launch-1.receipt.json'
            status_path             = Join-Path $waveRoot 'wave.wave-1.status.json'
            spec_path               = Join-Path $waveRoot 'spec.json'
            profile_path            = Join-Path $script:RepoRoot '.codex/agents/orchestrator-c3-elevated.toml'
            profile_sha256          = 'profile-hash'
            codex_home_path         = Join-Path $HOME '.codex/authority/epic-child'
            checkpoint_kind         = $(if ($Context -eq 'epic_preparation_child') { 'epic-planner' } else { 'epic-orchestrator' })
            wave_lock_path          = Join-Path $waveRoot 'semantic-wave.lock'
            trusted_repository_root = $script:RepoRoot
            checkpoint_path         = Join-Path $script:RepoRoot "artifacts/orchestration/$checkpoint"
        }
    }

    function Get-TestLaunchEnvironment {
        param([Parameter(Mandatory)] $Receipt)
        return [pscustomobject]@{
            launch_id         = [string]$Receipt.launch_id
            receipt_path      = [string]$Receipt.receipt_path
            spec_path         = [string]$Receipt.spec_path
            worktree_path     = [string]$Receipt.worktree_path
            delegation_id     = [string]$Receipt.delegation_id
            execution_context = [string]$Receipt.execution_context
            deployment_agent  = [string]$Receipt.deployment_agent
            model             = [string]$Receipt.model
            reasoning_effort  = [string]$Receipt.model_reasoning_effort
            profile_sha256    = [string]$Receipt.profile_sha256
        }
    }

    function Test-LaunchAuthority {
        param(
            [Parameter(Mandatory)] $Receipt,
            [Parameter(Mandatory)] $Environment,
            [string] $SessionId = 'session-1'
        )
        $routing = [pscustomobject]@{ execution_context = [string]$Receipt.execution_context }
        $payload = [pscustomobject]@{ session_id = $SessionId }
        return Test-CodexEpicChildRoutingLaunchAuthority -RoutingReceipt $routing -Payload $payload -RepositoryRoot $script:RepoRoot -LaunchEnvironment $Environment -LaunchReceiptRaw ($Receipt | ConvertTo-Json -Depth 12) -Now $script:Now
    }
}

Describe 'Codex epic-child launch attestation' {
    It 'requires the launch-authority result in the routed SubagentStart attestation' {
        $recordHook = Get-Content -Raw -LiteralPath (
            Join-Path $script:RepoRoot '.codex/hooks/record-subagent-routing-attestation.ps1'
        )

        $recordHook | Should -Match 'Test-CodexEpicChildRoutingLaunchAuthority'
        $recordHook | Should -Match '\$routingValid\s*=\s*\$routingValid\s+-and\s+\$launchAuthorityValid'
    }

    It 'does not require external launch authority for standalone routing' {
        $result = Test-CodexEpicChildRoutingLaunchAuthority -RoutingReceipt ([pscustomobject]@{ execution_context = 'standalone' }) -Payload ([pscustomobject]@{ session_id = 'session-1' }) -RepositoryRoot $script:RepoRoot

        $result | Should -BeTrue
    }

    It 'accepts a session-bound launch receipt for <Context>' -ForEach @(
        @{ Context = 'epic_preparation_child' }
        @{ Context = 'epic_execution_child' }
    ) {
        $receipt = Get-TestLaunchReceipt -Context $Context

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeTrue
    }

    It 'rejects epic-child routing without inherited launcher environment' {
        $receipt = Get-TestLaunchReceipt

        Test-LaunchAuthority -Receipt $receipt -Environment ([pscustomobject]@{}) |
            Should -BeFalse
    }

    It 'rejects a launch receipt bound to another Codex session' {
        $receipt = Get-TestLaunchReceipt

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) -SessionId 'session-2' |
            Should -BeFalse
    }

    It 'rejects drift in an inherited launch field' {
        $receipt = Get-TestLaunchReceipt
        $environment = Get-TestLaunchEnvironment $receipt
        $environment.spec_path = Join-Path $script:RepoRoot 'other-spec.json'

        Test-LaunchAuthority -Receipt $receipt -Environment $environment | Should -BeFalse
    }

    It 'rejects a different inherited root delegation id' {
        $receipt = Get-TestLaunchReceipt
        $environment = Get-TestLaunchEnvironment $receipt
        $environment.delegation_id = 'other-delegation'

        Test-LaunchAuthority -Receipt $receipt -Environment $environment | Should -BeFalse
    }

    It 'rejects case drift in an inherited root model identity' {
        $receipt = Get-TestLaunchReceipt
        $environment = Get-TestLaunchEnvironment $receipt
        $environment.model = 'GPT-5.6-SOL'

        Test-LaunchAuthority -Receipt $receipt -Environment $environment | Should -BeFalse
    }

    It 'rejects an expired active receipt' {
        $receipt = Get-TestLaunchReceipt
        $receipt.expires_at = '2026-07-10T21:00:00Z'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'rejects a checkpoint that does not match the epic child context' {
        $receipt = Get-TestLaunchReceipt -Context epic_execution_child
        $receipt.checkpoint_path = Join-Path $script:RepoRoot 'artifacts/orchestration/epic-planner-state.json'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }

    It 'rejects a receipt outside the trusted launch-artifact root' {
        $receipt = Get-TestLaunchReceipt
        $receipt.receipt_path = Join-Path $script:RepoRoot 'outside.receipt.json'

        Test-LaunchAuthority -Receipt $receipt -Environment (Get-TestLaunchEnvironment $receipt) |
            Should -BeFalse
    }
}
