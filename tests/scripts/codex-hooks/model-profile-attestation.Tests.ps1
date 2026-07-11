#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex routed model profile attestation' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        . (Join-Path $script:HookRoot 'record-subagent-routing-attestation.ps1')
        . (Join-Path $script:HookRoot 'enforce-codex-model-routing.ps1')
        $script:Now = [datetimeoffset]'2026-07-10T15:00:00Z'
        $script:HeadSha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    }

    It 'parses and hashes the exact checked-in generated profile' {
        $agentProfile = Get-CodexAgentProfileAttestation `
            -RepositoryRoot $script:RepoRoot `
            -AgentType 'orchestrator-c3-elevated'

        $agentProfile.profile_path | Should -Be '.codex/agents/orchestrator-c3-elevated.toml'
        $agentProfile.profile_name | Should -Be 'orchestrator-c3-elevated'
        $agentProfile.profile_model | Should -Be 'gpt-5.6-sol'
        $agentProfile.profile_reasoning_effort | Should -Be 'high'
        $agentProfile.profile_sha256 | Should -Match '^[0-9a-f]{64}$'
    }

    It 'persists the receipt and profile model-reasoning binding' {
        $checkpoint = @{
            codex_model_routing_receipts = @(@{
                    deployment_agent       = 'orchestrator-c3-elevated'
                    model                  = 'gpt-5.6-sol'
                    model_reasoning_effort = 'high'
                })
        } | ConvertTo-Json -Depth 4 | ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-profile'
            turn_id         = 'turn-profile'
            agent_id        = 'agent-profile'
            agent_type      = 'orchestrator-c3-elevated'
            model           = 'gpt-5.6-sol'
            transcript_path = 'profile-transcript.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $null `
            -Checkpoints @($checkpoint) `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now

        $attestation.routing_valid | Should -BeTrue
        $attestation.schema_version | Should -Be 2
        $attestation.expected_reasoning_effort | Should -Be 'high'
        $attestation.actual_reasoning_effort | Should -Be 'high'
        $attestation.profile_name | Should -Be $payload.agent_type
        $attestation.profile_model | Should -Be $payload.model
        $attestation.profile_sha256 | Should -Match '^[0-9a-f]{64}$'
    }

    It 'rejects a routing receipt whose reasoning differs from the profile' {
        $checkpoint = @{
            codex_model_routing_receipts = @(@{
                    deployment_agent       = 'orchestrator-c3-elevated'
                    model                  = 'gpt-5.6-sol'
                    model_reasoning_effort = 'medium'
                })
        } | ConvertTo-Json -Depth 4 | ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-reasoning'
            turn_id         = 'turn-reasoning'
            agent_id        = 'agent-reasoning'
            agent_type      = 'orchestrator-c3-elevated'
            model           = 'gpt-5.6-sol'
            transcript_path = 'reasoning-transcript.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $null `
            -Checkpoints @($checkpoint) `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now

        $attestation.routing_valid | Should -BeFalse
        $attestation.expected_reasoning_effort | Should -Be 'medium'
        $attestation.actual_reasoning_effort | Should -Be 'high'
    }

    It 'rejects a receipt that omits the exact generated deployment agent' {
        $checkpoint = @{
            codex_model_routing_receipts = @(@{
                    logical_agent          = 'orchestrator'
                    model                  = 'gpt-5.6-sol'
                    model_reasoning_effort = 'high'
                })
        } | ConvertTo-Json -Depth 4 | ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-logical-alias'
            turn_id         = 'turn-logical-alias'
            agent_id        = 'agent-logical-alias'
            agent_type      = 'orchestrator-c3-elevated'
            model           = 'gpt-5.6-sol'
            transcript_path = 'logical-alias-transcript.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $null `
            -Checkpoints @($checkpoint) `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now

        $attestation.routing_valid | Should -BeFalse
        $attestation.expected_model | Should -BeNullOrEmpty
    }

    It 'rehashes the current profile before allowing a routed mutation' {
        $checkpoint = @{
            codex_model_routing_receipts = @(@{
                    deployment_agent       = 'orchestrator-c3-elevated'
                    model                  = 'gpt-5.6-sol'
                    model_reasoning_effort = 'high'
                })
        } | ConvertTo-Json -Depth 4 | ConvertFrom-Json
        $startPayload = [pscustomobject]@{
            session_id      = 'session-rehash'
            turn_id         = 'turn-rehash'
            agent_id        = 'agent-rehash'
            agent_type      = 'orchestrator-c3-elevated'
            model           = 'gpt-5.6-sol'
            transcript_path = 'rehash-transcript.jsonl'
        }
        $attestation = Get-CodexSubagentAttestation `
            -Payload $startPayload `
            -RootReceipt $null `
            -Checkpoints @($checkpoint) `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now
        $payloadRaw = @{ tool_name = 'apply_patch'; model = 'gpt-5.6-sol' } |
            ConvertTo-Json -Compress

        Invoke-CodexModelRoutingDecision `
            -PayloadRaw $payloadRaw `
            -AttestationRaw ($attestation | ConvertTo-Json -Compress) |
            Should -BeNullOrEmpty

        $attestation.profile_sha256 = '0' * 64
        $decision = Invoke-CodexModelRoutingDecision `
            -PayloadRaw $payloadRaw `
            -AttestationRaw ($attestation | ConvertTo-Json -Compress)
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason |
            Should -Match 'profile drift'
    }

    It 'rejects profile path traversal before reading a file' {
        {
            Get-CodexAgentProfileAttestation `
                -RepositoryRoot $script:RepoRoot `
                -AgentType '../orchestrator-c3'
        } | Should -Throw '*invalid agent profile name*'
    }

    It 'rejects missing profiles and a stored path that differs from the current profile' {
        {
            Get-CodexAgentProfileAttestation `
                -RepositoryRoot $script:RepoRoot `
                -AgentType 'missing-routed-profile'
        } | Should -Throw '*does not exist*'
        $agentProfile = Get-CodexAgentProfileAttestation `
            -RepositoryRoot $script:RepoRoot `
            -AgentType 'orchestrator-c3-elevated'

        Test-CodexAgentProfileBinding `
            -AgentProfile $agentProfile `
            -AgentType 'orchestrator-c3-elevated' `
            -ActualModel 'gpt-5.6-sol' `
            -ExpectedModel 'gpt-5.6-sol' `
            -ExpectedReasoningEffort 'high' `
            -ExpectedProfilePath '.codex/agents/orchestrator-c4.toml' |
            Should -BeFalse
    }
}
