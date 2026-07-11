#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex epic provenance and routing attestation hooks' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        . (Join-Path $script:HookRoot 'authorize-root-epic-invocation.ps1')
        . (Join-Path $script:HookRoot 'record-subagent-routing-attestation.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-root-invocation.ps1')
        . (Join-Path $script:HookRoot 'enforce-codex-model-routing.ps1')
        . (Join-Path $script:HookRoot 'validate-codex-subagent-routing.ps1')

        $script:Now = [datetimeoffset]'2026-07-10T15:00:00Z'
        $script:HeadSha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    }

    It 'recognizes the three explicit root epic entry skills' -ForEach @(
        @{ Prompt = '/epic-plan deliver the objective'; Persona = 'epic-planner' }
        @{ Prompt = '/epic-run sample-epic'; Persona = 'epic-orchestrator' }
        @{ Prompt = '/epic-orchestrate docs/features/epics/sample/epic.md'; Persona = 'epic-orchestrator' }
    ) {
        $payload = [pscustomobject]@{
            session_id = 'session-1'
            turn_id    = 'turn-1'
            prompt     = $Prompt
        }

        $receipt = Get-RootEpicInvocationReceipt `
            -Payload $payload `
            -Now $script:Now `
            -RepositoryRoot $script:RepoRoot `
            -HeadSha $script:HeadSha

        $receipt.requested_persona | Should -Be $Persona
        $receipt.prompt_sha256 | Should -Match '^[0-9a-f]{64}$'
        $receipt.consumed | Should -BeFalse
    }

    It 'does not mint a receipt for a non-epic prompt' {
        $payload = [pscustomobject]@{
            session_id = 'session-1'
            turn_id    = 'turn-1'
            prompt     = 'Fix one localized bug.'
        }

        Get-RootEpicInvocationReceipt `
            -Payload $payload `
            -Now $script:Now `
            -RepositoryRoot $script:RepoRoot `
            -HeadSha $script:HeadSha |
            Should -BeNullOrEmpty
    }

    It 'does not authorize negated or explanatory epic persona references' -ForEach @(
        @{ Prompt = 'Do not invoke epic-planner.' }
        @{ Prompt = 'Never use epic-orchestrator.' }
        @{ Prompt = 'Explain why an orchestrator must not delegate to epic-planner.' }
    ) {
        Get-RootEpicRequestedPersona -Prompt $Prompt | Should -BeNullOrEmpty
    }

    It 'derives the epic slug from a committed kickoff path' {
        $receipt = Get-RootEpicInvocationReceipt -Payload ([pscustomobject]@{
                session_id = 'session-1'
                turn_id    = 'turn-1'
                prompt     = '/epic-run docs/features/epics/sample/epic-kickoff.md'
            }) `
            -Now $script:Now `
            -RepositoryRoot $script:RepoRoot `
            -HeadSha $script:HeadSha

        $receipt.kickoff_path | Should -Be 'docs/features/epics/sample/epic-kickoff.md'
    }

    It 'authorizes an epic planner start once with the exact forced model' {
        $receipt = Get-RootEpicInvocationReceipt -Payload ([pscustomobject]@{
                session_id = 'session-1'
                turn_id    = 'turn-1'
                prompt     = '/epic-plan sample'
            }) `
            -Now $script:Now `
            -RepositoryRoot $script:RepoRoot `
            -HeadSha $script:HeadSha
        $receiptObject = $receipt | ConvertTo-Json | ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-1'
            turn_id         = 'turn-1'
            agent_id        = 'agent-1'
            agent_type      = 'epic-planner'
            model           = 'gpt-5.6-sol'
            transcript_path = 'child-transcript.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $receiptObject `
            -Checkpoints @() `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now.AddMinutes(1)

        $attestation.root_authorized | Should -BeTrue
        $attestation.routing_valid | Should -BeTrue
        $attestation.provenance_valid | Should -BeTrue
    }

    It 'rejects stale and previously consumed root receipts' -ForEach @(
        @{ Expires = '2026-07-10T14:59:00Z'; Consumed = $false }
        @{ Expires = '2026-07-10T16:00:00Z'; Consumed = $true }
    ) {
        $receipt = Get-RootEpicInvocationReceipt -Payload ([pscustomobject]@{
                session_id = 'session-1'
                turn_id    = 'turn-1'
                prompt     = '/epic-run sample'
            }) `
            -Now $script:Now `
            -RepositoryRoot $script:RepoRoot `
            -HeadSha $script:HeadSha
        $receipt.expires_at = $Expires
        $receipt.consumed = $Consumed
        if ($Consumed) {
            $receipt.consumed_by = 'agent-prior'
            $receipt.consumed_at = '2026-07-10T14:30:00Z'
        }
        $receipt = $receipt | ConvertTo-Json | ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-1'
            turn_id         = 'turn-1'
            agent_id        = 'agent-2'
            agent_type      = 'epic-orchestrator'
            model           = 'gpt-5.6-sol'
            transcript_path = 'child-two.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $receipt `
            -Checkpoints @() `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now

        $attestation.provenance_valid | Should -BeFalse
        $attestation.enforcement_marker | Should -Be 'EPIC_INVOCATION_ORIGIN_BLOCKED'
    }

    It 'rejects a minimal fabricated root receipt' {
        $receipt = [pscustomobject]@{
            session_id        = 'session-1'
            turn_id           = 'turn-1'
            requested_persona = 'epic-planner'
            expires_at        = '2026-07-10T16:00:00Z'
            consumed          = $false
        }
        $payload = [pscustomobject]@{
            session_id = 'session-1'
            turn_id    = 'turn-1'
            agent_type = 'epic-planner'
        }

        Test-RootEpicReceipt `
            -Receipt $receipt `
            -Payload $payload `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now |
            Should -BeFalse
    }

    It 'rejects altered repository, prompt, entry, and kickoff bindings' -ForEach @(
        @{ Property = 'repository_sha256'; Value = ('b' * 64) }
        @{ Property = 'prompt_sha256'; Value = 'not-a-hash' }
        @{ Property = 'entry_kind'; Value = 'epic-plan' }
        @{ Property = 'kickoff_path'; Value = 'docs/features/epics/other/epic-kickoff.md' }
        @{ Property = 'repository_head_sha'; Value = ('b' * 40) }
    ) {
        $receipt = Get-RootEpicInvocationReceipt -Payload ([pscustomobject]@{
                session_id = 'session-1'
                turn_id    = 'turn-1'
                prompt     = '/epic-run sample'
            }) `
            -Now $script:Now `
            -RepositoryRoot $script:RepoRoot `
            -HeadSha $script:HeadSha
        $receipt[$Property] = $Value
        $payload = [pscustomobject]@{
            session_id = 'session-1'
            turn_id    = 'turn-1'
            agent_type = 'epic-orchestrator'
        }

        Test-RootEpicReceipt `
            -Receipt ($receipt | ConvertTo-Json | ConvertFrom-Json) `
            -Payload $payload `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now |
            Should -BeFalse
    }

    It 'stores authority receipts and attestations outside the repository workspace' {
        $authorityRoot = Get-CodexAuthorityStateRoot `
            -RepositoryRoot $script:RepoRoot `
            -SessionId 'session-1'
        $workspaceRoot = Get-CodexCanonicalAuthorityPath -Path $script:RepoRoot

        (Get-CodexCanonicalAuthorityPath -Path $authorityRoot).StartsWith(
            $workspaceRoot,
            [StringComparison]::OrdinalIgnoreCase
        ) | Should -BeFalse
    }

    It 'rejects a CODEX_HOME authority store inside the repository' {
        $prior = $env:CODEX_HOME
        try {
            $env:CODEX_HOME = Join-Path $script:RepoRoot '.codex-authority-test'
            { Get-CodexAuthorityStateRoot -RepositoryRoot $script:RepoRoot -SessionId 'session-1' } |
                Should -Throw '*outside the repository workspace*'
        } finally {
            $env:CODEX_HOME = $prior
        }
    }

    It 'binds a routed child to the deployment profile model' {
        $checkpoint = '{"codex_model_routing_receipts":[{"deployment_agent":"orchestrator-c3-elevated","model":"gpt-5.6-sol","model_reasoning_effort":"high"}]}' |
            ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-1'
            turn_id         = 'turn-1'
            agent_id        = 'agent-3'
            agent_type      = 'orchestrator-c3-elevated'
            model           = 'gpt-5.6-sol'
            transcript_path = 'child-three.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $null `
            -Checkpoints @($checkpoint) `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now

        $attestation.routing_valid | Should -BeTrue
        $attestation.expected_model | Should -Be 'gpt-5.6-sol'
    }

    It 'rejects a base alias when the receipt requires a generated deployment profile' {
        $checkpoint = '{"codex_model_routing_receipts":[{"logical_agent":"orchestrator","deployment_agent":"orchestrator-c3","model":"gpt-5.6-terra","model_reasoning_effort":"high"}]}' |
            ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-1'
            turn_id         = 'turn-1'
            agent_id        = 'agent-base-alias'
            agent_type      = 'orchestrator'
            model           = 'gpt-5.6-terra'
            transcript_path = 'base-alias.jsonl'
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

    It 'binds a planner child to its per-feature Codex routing receipt' {
        $checkpoint = '{"features":[{"model_routing_receipt":{"deployment_agent":"orchestrator-c3-elevated","model":"gpt-5.6-sol","model_reasoning_effort":"high"}}]}' |
            ConvertFrom-Json
        $payload = [pscustomobject]@{
            session_id      = 'session-1'
            turn_id         = 'turn-1'
            agent_id        = 'agent-planner-child'
            agent_type      = 'orchestrator-c3-elevated'
            model           = 'gpt-5.6-sol'
            transcript_path = 'planner-child.jsonl'
        }

        $attestation = Get-CodexSubagentAttestation `
            -Payload $payload `
            -RootReceipt $null `
            -Checkpoints @($checkpoint) `
            -RepositoryRoot $script:RepoRoot `
            -CurrentHeadSha $script:HeadSha `
            -Now $script:Now

        $attestation.routing_valid | Should -BeTrue
        $attestation.expected_model | Should -Be 'gpt-5.6-sol'
    }

    It 'denies epic mutation with the canonical origin marker' {
        $attestation = @{
            agent_type       = 'epic-planner'
            provenance_valid = $false
        } | ConvertTo-Json -Compress

        $decision = Invoke-EpicRootInvocationDecision -PayloadRaw '{"tool_name":"apply_patch"}' -AttestationRaw $attestation

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason |
            Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
    }

    It 'denies an identified epic persona mutation when its attestation is missing' {
        $payload = @{ tool_name = 'apply_patch'; agent_type = 'epic-planner' } |
            ConvertTo-Json -Compress

        $decision = Invoke-EpicRootInvocationDecision -PayloadRaw $payload -AttestationRaw ''

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason |
            Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
    }

    It 'denies mutation after a model mismatch attestation' {
        $attestation = @{
            agent_type     = 'orchestrator-c3-elevated'
            actual_model   = 'gpt-5.6-terra'
            expected_model = 'gpt-5.6-sol'
            routing_valid  = $false
        } | ConvertTo-Json -Compress

        $decision = Invoke-CodexModelRoutingDecision -PayloadRaw '{"tool_name":"Bash"}' -AttestationRaw $attestation

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason |
            Should -Match 'MODEL_ROUTING_ATTESTATION_BLOCKED'
    }

    It 'rechecks the live PreToolUse model against a valid stored attestation' {
        $agentProfile = Get-CodexAgentProfileAttestation `
            -RepositoryRoot $script:RepoRoot `
            -AgentType 'orchestrator-c3-elevated'
        $attestation = @{
            schema_version            = 2
            agent_type                = 'orchestrator-c3-elevated'
            actual_model              = 'gpt-5.6-sol'
            expected_model            = 'gpt-5.6-sol'
            actual_reasoning_effort   = 'high'
            expected_reasoning_effort = 'high'
            profile_name              = $agentProfile.profile_name
            profile_model             = $agentProfile.profile_model
            profile_path              = $agentProfile.profile_path
            profile_sha256            = $agentProfile.profile_sha256
            profile_validation_error  = $null
            routing_valid             = $true
        } | ConvertTo-Json -Compress
        $matching = @{ tool_name = 'Bash'; model = 'gpt-5.6-sol' } | ConvertTo-Json -Compress
        $drifted = @{ tool_name = 'Bash'; model = 'gpt-5.6-terra' } | ConvertTo-Json -Compress

        Invoke-CodexModelRoutingDecision -PayloadRaw $matching -AttestationRaw $attestation |
            Should -BeNullOrEmpty
        (Invoke-CodexModelRoutingDecision -PayloadRaw $drifted -AttestationRaw $attestation).
        hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'denies an identified routed agent mutation when its attestation is missing' {
        $payload = @{ tool_name = 'Bash'; agent_type = 'orchestrator-c3' } |
            ConvertTo-Json -Compress

        $decision = Invoke-CodexModelRoutingDecision -PayloadRaw $payload -AttestationRaw ''

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason |
            Should -Match 'MODEL_ROUTING_ATTESTATION_BLOCKED'
    }

    It 'requests one continuation when an epic subagent stops without attestation' {
        $payload = @{
            agent_id         = 'agent-4'
            agent_type       = 'epic-orchestrator'
            model            = 'gpt-5.6-sol'
            stop_hook_active = $false
        } | ConvertTo-Json -Compress

        $decision = Invoke-CodexSubagentStopDecision -PayloadRaw $payload -AttestationRaw ''

        $decision.decision | Should -Be 'block'
        $decision.reason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
    }

    It 'uses documented stdin instead of Claude environment variables' {
        $paths = @(
            'authorize-root-epic-invocation.ps1',
            'record-subagent-routing-attestation.ps1',
            'enforce-epic-root-invocation.ps1',
            'enforce-codex-model-routing.ps1',
            'validate-codex-subagent-routing.ps1'
        )
        foreach ($name in $paths) {
            $content = Get-Content -Raw -LiteralPath (Join-Path $script:HookRoot $name)
            $content | Should -Match '\[Console\]::In\.ReadToEnd\(\)'
            $content | Should -Not -Match 'CLAUDE_(?:HOOK|TOOL)_INPUT'
        }
    }
}
