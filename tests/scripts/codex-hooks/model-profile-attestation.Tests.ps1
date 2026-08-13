#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'Codex routed model profile attestation' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        . (Join-Path $script:HookRoot 'record-subagent-routing-attestation.ps1')
        . (Join-Path $script:HookRoot 'enforce-codex-model-routing.ps1')
        $script:ModelGateHookPath = Join-Path $script:HookRoot 'enforce-codex-model-routing.ps1'
        $script:Now = [datetimeoffset]'2026-07-10T15:00:00Z'
        $script:HeadSha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

        function Invoke-TestModelGateHook {
            param([Parameter(Mandatory)][string] $PayloadRaw)

            $originalIn = [Console]::In
            $originalError = [Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [Console]::SetError($errorWriter)
                $stdout = & $script:ModelGateHookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = (@($stdout) -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [Console]::SetIn($originalIn)
                [Console]::SetError($originalError)
            }
        }
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

    It 'derives canonical authority paths without creating filesystem state' {
        $priorCodexHome = $env:CODEX_HOME
        $outsideRoot = Join-Path (Split-Path $script:RepoRoot -Parent) 'authority-not-created'
        try {
            $env:CODEX_HOME = $outsideRoot
            Get-CodexAuthoritySha256 -Text '' | Should -Match '^[0-9a-f]{64}$'
            Get-CodexCanonicalAuthorityPath -Path $script:RepoRoot |
                Should -Be ([System.IO.Path]::GetFullPath($script:RepoRoot).ToLowerInvariant())
            Get-CodexAuthorityRepositoryKey -RepositoryRoot $script:RepoRoot |
                Should -Match '^[0-9a-f]{64}$'
            Get-CodexResolvedAuthorityPath -Path (Join-Path $script:RepoRoot 'absent/child') |
                Should -Match 'absent[\\/]child$'
            { Assert-CodexAuthorityOutsideRepository `
                    -AuthorityPath (Join-Path $script:RepoRoot 'inside') `
                    -RepositoryRoot $script:RepoRoot } |
                Should -Throw '*outside the repository workspace*'
            { Assert-CodexAuthorityOutsideRepository `
                    -AuthorityPath $outsideRoot `
                    -RepositoryRoot $script:RepoRoot } |
                Should -Not -Throw
            Get-CodexAuthorityHome | Should -Be ([System.IO.Path]::GetFullPath($outsideRoot))

            $stateRoot = Get-CodexAuthorityStateRoot `
                -RepositoryRoot $script:RepoRoot -SessionId 'session/root:1' -Surface parallel
            $stateRoot | Should -Match 'parallel-entry'
            Get-CodexAuthorityReceiptPath `
                -RepositoryRoot $script:RepoRoot -SessionId 'session-1' `
                -TurnId 'turn/root:1' -Surface parallel |
                Should -Match 'parallel-root-invocation\.turn_root_1\.json$'
            Get-CodexAuthorityAttestationPath `
                -RepositoryRoot $script:RepoRoot -SessionId 'session-1' `
                -AttestationKey 'agent/root:1' -Surface parallel |
                Should -Match 'codex-routing-attestation\.agent_root_1\.json$'
        } finally {
            $env:CODEX_HOME = $priorCodexHome
        }
    }

    It 'uses the user profile when CODEX_HOME is not configured' {
        $priorCodexHome = $env:CODEX_HOME
        try {
            $env:CODEX_HOME = $null
            Get-CodexAuthorityHome | Should -Match '[\\/]\.codex$'
        } finally {
            $env:CODEX_HOME = $priorCodexHome
        }
    }

    It 'validates model-gate JSON and denial envelopes' {
        (ConvertFrom-CodexModelGateJson -Raw '{"model":"gpt-5.6-sol"}' -Name payload).model |
            Should -Be 'gpt-5.6-sol'
        { ConvertFrom-CodexModelGateJson -Raw ' ' -Name payload } |
            Should -Throw '*payload is empty*'
        { ConvertFrom-CodexModelGateJson -Raw '{' -Name payload } |
            Should -Throw '*payload is malformed JSON*'
        Get-CodexModelGateAttestationKey -TranscriptPath 'transcript.jsonl' |
            Should -Match '^[0-9a-f]{64}$'
        (Get-CodexModelGateDenyDecision -Reason denied).
        hookSpecificOutput.permissionDecisionReason | Should -Be 'denied'
    }

    It 'rejects incomplete and invalid profile attestations before mutation' {
        $payload = [pscustomobject]@{ model = 'gpt-5.6-sol' }
        $invalid = [pscustomobject]@{ schema_version = 1; routing_valid = $true }
        Test-CodexModelGateProfileAttestation `
            -Payload $payload -Attestation $invalid -RepositoryRoot $script:RepoRoot |
            Should -BeFalse

        $invalid = [pscustomobject]@{
            schema_version = 2; routing_valid = $true; profile_validation_error = $null
            agent_type = ''; actual_model = ''; expected_model = ''
            actual_reasoning_effort = ''; expected_reasoning_effort = ''
            profile_name = ''; profile_model = ''; profile_path = ''; profile_sha256 = ''
        }
        Test-CodexModelGateProfileAttestation `
            -Payload $payload -Attestation $invalid -RepositoryRoot $script:RepoRoot |
            Should -BeFalse
        $invalid.agent_type = 'missing-profile'
        foreach ($name in @(
                'actual_model', 'expected_model', 'actual_reasoning_effort',
                'expected_reasoning_effort', 'profile_name', 'profile_model',
                'profile_path', 'profile_sha256'
            )) {
            $invalid.$name = 'value'
        }
        $invalid.profile_sha256 = 'not-a-hash'
        Test-CodexModelGateProfileAttestation `
            -Payload $payload -Attestation $invalid -RepositoryRoot $script:RepoRoot |
            Should -BeFalse
        $invalid.profile_sha256 = 'a' * 64
        Test-CodexModelGateProfileAttestation `
            -Payload $payload -Attestation $invalid -RepositoryRoot $script:RepoRoot |
            Should -BeFalse
    }

    It 'distinguishes ungated, missing, and malformed routing attestations' {
        Invoke-CodexModelRoutingDecision `
            -PayloadRaw '{"tool_name":"Read"}' -AttestationRaw '' |
            Should -BeNullOrEmpty
        $missing = Invoke-CodexModelRoutingDecision `
            -PayloadRaw '{"tool_name":"Read","agent_type":"atomic-executor-c3"}' `
            -AttestationRaw ''
        $missing.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        { Invoke-CodexModelRoutingDecision `
                -PayloadRaw '{"tool_name":"Read"}' -AttestationRaw '{' } |
            Should -Throw '*routing attestation is malformed JSON*'
    }

    It 'executes allow, deny, and malformed native model-gate transport' {
        $allow = Invoke-TestModelGateHook -PayloadRaw '{"tool_name":"Read"}'
        $allow.ExitCode | Should -Be 0
        $allow.Stdout | Should -BeNullOrEmpty

        $deny = Invoke-TestModelGateHook -PayloadRaw (
            '{"tool_name":"Read","agent_type":"atomic-executor-c3"}'
        )
        $deny.ExitCode | Should -Be 0
        $deny.Stdout | Should -Match 'MODEL_ROUTING_ATTESTATION_BLOCKED'

        $malformed = Invoke-TestModelGateHook -PayloadRaw '{'
        $malformed.ExitCode | Should -Be 2
        $malformed.Stderr | Should -Match 'malformed JSON'
    }
}
