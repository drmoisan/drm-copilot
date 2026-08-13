BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-wave-barrier.ps1')
    . (Join-Path $script:RepoRoot '.codex/hooks/validate-codex-subagent-routing.ps1')
    . (Join-Path $script:RepoRoot '.codex/scripts/launch-epic-child-wave.ps1')
    . (Join-Path $script:RepoRoot '.codex/scripts/resume-epic-child.ps1') -ReceiptPath unused
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

    It 'normalizes routed stop payloads and classifies every gated agent family' {
        (ConvertFrom-CodexStopJson -Raw '{"agent_type":"default"}' -Name payload).
        agent_type | Should -Be 'default'
        { ConvertFrom-CodexStopJson -Raw ' ' -Name payload } |
            Should -Throw '*payload is empty*'
        { ConvertFrom-CodexStopJson -Raw '{' -Name payload } |
            Should -Throw '*payload is malformed JSON*'
        Test-CodexStopGatedAgent -AgentType atomic-executor-c3 | Should -BeTrue
        Test-CodexStopGatedAgent -AgentType parallel-orchestrator | Should -BeTrue
        Test-CodexStopGatedAgent -AgentType default | Should -BeFalse
        (Get-CodexStopContinuation -Reason blocked -AlreadyContinued $false).decision |
            Should -Be 'block'
        (Get-CodexStopContinuation -Reason blocked -AlreadyContinued $true).continue |
            Should -BeFalse
    }

    It 'fails routed stop decisions closed for missing or invalid attestations' {
        $payloads = @(
            @{ agent_type = 'epic-planner'; agent_id = 'agent'; stop_hook_active = $false },
            @{ agent_type = 'parallel-planner'; agent_id = 'agent'; stop_hook_active = $false },
            @{ agent_type = 'atomic-executor-c3'; agent_id = 'agent'; stop_hook_active = $true }
        )
        foreach ($payload in $payloads) {
            $decision = Invoke-CodexSubagentStopDecision `
                -PayloadRaw ($payload | ConvertTo-Json -Compress) -AttestationRaw ''
            ($decision.reason + $decision.stopReason) | Should -Match 'BLOCKED'
        }
        Invoke-CodexSubagentStopDecision `
            -PayloadRaw '{"agent_type":"default"}' -AttestationRaw '' |
            Should -BeNullOrEmpty

        $payloadRaw = '{"agent_type":"epic-planner","agent_id":"agent","model":"gpt-5.6-sol"}'
        $identityDrift = @{ agent_type = 'epic-planner'; agent_id = 'other' } |
            ConvertTo-Json -Compress
        (Invoke-CodexSubagentStopDecision `
            -PayloadRaw $payloadRaw -AttestationRaw $identityDrift).reason |
            Should -Match 'identity does not match'
        $badProvenance = @{
            agent_type = 'epic-planner'; agent_id = 'agent'; provenance_valid = $false
        } | ConvertTo-Json -Compress
        (Invoke-CodexSubagentStopDecision `
            -PayloadRaw $payloadRaw -AttestationRaw $badProvenance).reason |
            Should -Match 'lacks valid root provenance'
    }

    It 'enforces parallel model identity and delegates valid output validation' {
        $payload = @{
            agent_type = 'parallel-orchestrator'; agent_id = 'agent'
            model = 'gpt-5.6-sol'
        }
        $attestation = @{
            agent_type = 'parallel-orchestrator'; agent_id = 'agent'; surface = 'parallel'
            provenance_valid = $true; root_authorized = $true; routing_valid = $true
            actual_model = 'gpt-5.6-sol'; expected_model = 'gpt-5.6-sol'
            profile_model = 'gpt-5.6-sol'; actual_reasoning_effort = 'ultra'
            expected_reasoning_effort = 'ultra'; fallback_used = $false
            parallel_identity = 'identity'; mutation_identity = 'identity'
        }
        $payloadRaw = $payload | ConvertTo-Json -Compress
        $invalid = $attestation.Clone(); $invalid.fallback_used = $true
        (Invoke-CodexSubagentStopDecision -PayloadRaw $payloadRaw `
            -AttestationRaw ($invalid | ConvertTo-Json -Compress)).reason |
            Should -Match 'no-fallback routing'
        $invalid = $attestation.Clone(); $invalid.routing_valid = $false
        (Invoke-CodexSubagentStopDecision -PayloadRaw $payloadRaw `
            -AttestationRaw ($invalid | ConvertTo-Json -Compress)).reason |
            Should -Match 'recorded deployment model'
        $payload.model = 'gpt-5.6-terra'; $invalid = $attestation.Clone()
        (Invoke-CodexSubagentStopDecision -PayloadRaw ($payload | ConvertTo-Json -Compress) `
            -AttestationRaw ($invalid | ConvertTo-Json -Compress)).reason |
            Should -Match 'stop model differs'
        $payload.model = 'gpt-5.6-sol'; $script:ValidatedWorkspace = ''
        $validator = {
            param($raw, $root)
            $raw | Should -Match 'parallel-orchestrator'
            $script:ValidatedWorkspace = $root
            'validated'
        }
        Invoke-CodexSubagentStopDecision -PayloadRaw ($payload | ConvertTo-Json -Compress) `
            -AttestationRaw ($attestation | ConvertTo-Json -Compress) `
            -WorkspaceRoot $script:RepoRoot -ParallelOutputValidator $validator |
            Should -Be 'validated'
        $script:ValidatedWorkspace | Should -Be $script:RepoRoot
        { Invoke-CodexSubagentStopDecision -PayloadRaw ($payload | ConvertTo-Json -Compress) `
                -AttestationRaw ($attestation | ConvertTo-Json -Compress) `
                -ParallelOutputValidator $validator } |
            Should -Throw '*workspace root is required*'
    }

    It 'finds matching stop attestations while ignoring malformed candidates' {
        Mock Test-Path { $true }
        Mock Get-ChildItem {
            @([pscustomobject]@{ FullName = 'bad.json' }, [pscustomobject]@{ FullName = 'good.json' })
        }
        Mock Get-Content {
            param($LiteralPath)
            if ($LiteralPath -eq 'bad.json') { return '{' }
            return '{"agent_id":"agent"}'
        }
        Find-CodexStopAttestationRaw -StateRoot state -AgentId agent |
            Should -Match 'agent_id'
        Find-CodexStopAttestationRaw -StateRoot state -AgentId absent |
            Should -BeNullOrEmpty
        Mock Test-Path { $false }
        Find-CodexStopAttestationRaw -StateRoot absent -AgentId agent |
            Should -BeNullOrEmpty
    }

    It 'builds resume process arguments and updates terminal wave entries' {
        $receipt = [pscustomobject]@{
            worktree_path = 'C:\worktree'; codex_denied_paths = @('C:\denied')
            model = 'gpt-5.6-sol'; model_reasoning_effort = 'high'
            launch_id = 'launch'; receipt_path = 'C:\receipt.json'; spec_path = 'C:\spec.json'
            status_path = 'NUL'; state = 'active'; completed_at = ''; failed_at = ''; exit_code = 0
            delegation_id = 'delegation'; execution_context = 'epic_execution_child'
            deployment_agent = 'orchestrator-c3'; profile_sha256 = 'profile'
            codex_session_id = 'session'; codex_home_path = 'C:\home'
        }
        $context = [pscustomobject]@{
            Receipt      = $receipt
            Profile      = [pscustomobject]@{ developer_instructions = 'instructions'; skills_config = '[]' }
            CodexRuntime = [pscustomobject]@{ CommandPath = 'C:\codex.ps1' }
        }
        $info = Get-CodexChildResumeStartInfo -Context $context `
            -ResumePrompt continue -OutputPath 'C:\last.txt'
        $info.FileName | Should -Be pwsh
        $info.ArgumentList | Should -Contain resume
        $info.ArgumentList | Should -Contain session
        $info.ArgumentList | Should -Contain continue
        $info.Environment['CODEX_EPIC_CHILD_SESSION_ID'] | Should -Be session

        Mock Write-CodexChildJsonAtomic { }
        Mock Get-Content {
            '{"updated_at":"","launches":{"launch":{"state":"active","codex_session_id":"","receipt_path":"","exit_code":0,"completed_at":"","failed_at":""}}}'
        }
        $receipt.state = 'completed'; $receipt.completed_at = 'done'
        Set-CodexChildResumeWaveStatus -Receipt $receipt -Confirm:$false
        Should -Invoke Write-CodexChildJsonAtomic -Times 1 -ParameterFilter {
            $Value.launches.launch.exit_code -eq 0 -and
            $Value.launches.launch.completed_at -eq 'done'
        }
        $receipt.state = 'failed'; $receipt.exit_code = 7; $receipt.failed_at = 'failed'
        Set-CodexChildResumeWaveStatus -Receipt $receipt -Confirm:$false
        Should -Invoke Write-CodexChildJsonAtomic -Times 1 -ParameterFilter {
            $Value.launches.launch.exit_code -eq 7 -and
            $Value.launches.launch.failed_at -eq 'failed'
        }
        $receipt.launch_id = 'missing'
        { Set-CodexChildResumeWaveStatus -Receipt $receipt -Confirm:$false } |
            Should -Throw '*lacks the receipt launch_id*'
    }
}
