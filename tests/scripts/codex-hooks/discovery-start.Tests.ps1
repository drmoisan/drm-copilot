#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Codex discovery SubagentStart attestation (issue #980).
.DESCRIPTION
    .codex/hooks/record-subagent-routing-attestation.ps1 and its focused helper
    discovery-start-attestation.ps1 are dot-sourced in-process; the shared discovery modules
    resolve to .claude/lib because this repository publishes .codex/lib only into
    destinations. The protected store, clock and nonce are injected from the shared
    fixtures and the identity comes from the payload; the Codex authority writer and the
    generated profile reader are mocked.
    No file, process, network or clock is touched.
#>

Describe 'Codex discovery start attestation' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        . (Join-Path $script:HookRoot 'record-subagent-routing-attestation.ps1')
        . (Join-Path $script:HookRoot 'enforce-codex-model-routing.ps1')
        Import-CodexDiscoveryStartModule
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        $script:Now = [datetimeoffset]::new($script:GateNow)
        $script:CodexProfile = [ordered]@{
            profile_path = '.codex/agents/legacy-parity-analyst-c3.toml'; profile_sha256 = ('a' * 64)
            profile_name = 'legacy-parity-analyst-c3'; profile_model = 'gpt-6.1-sol'; profile_reasoning_effort = 'high'
        }

        function Get-CodexStartPayload {
            param([string]$AgentType = 'legacy-parity-analyst-c3', [string]$Model = 'gpt-6.1-sol')
            return [pscustomobject]@{ session_id = 'session-alpha'; turn_id = 'turn-alpha'; agent_id = 'agent-alpha'; agent_type = $AgentType; model = $Model; transcript_path = 'transcripts/agent-alpha.jsonl' }
        }

        function Get-CodexStartAttestation {
            param(
                [pscustomobject]$Payload = (Get-CodexStartPayload),
                [hashtable]$Store = (Get-StartStore -HostName 'codex'),
                [AllowNull()]$AgentProfile = ([pscustomobject]$script:CodexProfile)
            )
            $parameters = @{ Payload = $Payload; RepositoryRoot = $script:GateWorkspaceRoot; Now = $script:Now; HostEnvironment = $script:GateHostEnvironment; Store = $Store; Nonce = $script:GateNonce }
            if ($null -ne $AgentProfile) { $parameters['AgentProfile'] = $AgentProfile }
            return Get-CodexDiscoveryStartAttestation @parameters
        }
    }

    It 'recognises <AgentType> as discovery: <Expected>' -ForEach @(
        @{ AgentType = 'legacy-parity-analyst'; Expected = $true }
        @{ AgentType = 'migration-coverage-reviewer-c3-elevated'; Expected = $true }
        @{ AgentType = 'runtime-characterization-analyst-c2'; Expected = $true }
        @{ AgentType = 'atomic-executor-c3'; Expected = $false }
        @{ AgentType = 'epic-planner'; Expected = $false }
        @{ AgentType = ''; Expected = $false }
    ) {
        Test-CodexDiscoveryAgentType -AgentType $AgentType | Should -Be $Expected
        Test-CodexModelGateAgentType -AgentType ($(if ($AgentType) { $AgentType } else { 'general-purpose' })) | Should -Be ($Expected -or $AgentType -in @('atomic-executor-c3', 'epic-planner'))
    }

    It 'resolves the shared modules from the published location first and the repository second' {
        ((Get-CodexDiscoveryStartModulePath -ModuleName 'DiscoveryStart.psm1' -ScriptRoot 'C:/dest/.codex/hooks') -replace '\\', '/') | Should -Be 'C:/dest/.codex/hooks/../lib/discovery-validation/DiscoveryStart.psm1'
        Test-Path -LiteralPath (Get-CodexDiscoveryStartModulePath -ModuleName 'DiscoveryStart.psm1') | Should -BeTrue
    }

    It 'projects the Codex profile into the shared agent-profile shape' {
        $shared = ConvertTo-CodexSharedAgentProfile -AgentProfile ([pscustomobject]$script:CodexProfile)
        $shared.ProfileName | Should -Be 'legacy-parity-analyst-c3'
        $shared.ProfileSha256 | Should -Be ('a' * 64)
        $shared.ProfileReasoningEffort | Should -Be 'high'
    }

    It 'attests a Codex discovery start and records a schema-2 routing attestation the model gate accepts' {
        $store = Get-StartStore -HostName 'codex'
        $attestation = Get-CodexStartAttestation -Store $store
        $attestation.routing_valid | Should -BeTrue -Because $attestation.discovery_reason
        $attestation.receipt_kind | Should -Be 'discovery-invocation'
        $attestation.discovery_code | Should -Be 'ATTESTED'
        $attestation.invocation_id | Should -Be 'invocation-alpha'
        $attestation.start_attestation_ref | Should -Be 'start-0123456789abcdef0123'
        $attestation.expected_model | Should -Be 'gpt-6.1-sol'
        $attestation.expected_reasoning_effort | Should -Be 'high'
        $attestation.enforcement_marker | Should -BeNullOrEmpty
        $store.Writes | Should -Be @("$($script:GateInvocationDirectory)/start-attestation.json")
        ($store.Files["$($script:GateInvocationDirectory)/invocation.json"] | ConvertFrom-Json).state | Should -Be 'started'
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
        Mock Get-CodexAgentProfileAttestation { [pscustomobject]$script:CodexProfile }
        Invoke-CodexModelRoutingDecision -PayloadRaw '{"agent_type":"legacy-parity-analyst-c3","model":"gpt-6.1-sol"}' -AttestationRaw ($attestation | ConvertTo-Json -Compress -Depth 5) | Should -BeNullOrEmpty
    }

    It 'rejects <Name> as <Code> and the model gate then denies the agent' -ForEach @(
        @{ Name = 'a model that differs from the deployment'; Code = 'MODEL'; Payload = @{ Model = 'gpt-6-astra' }; Store = @{} }
        @{ Name = 'a missing prepared invocation'; Code = 'NO_INVOCATION'; Payload = @{}; Store = @{ NoInvocation = $true } }
        @{ Name = 'two prepared invocations'; Code = 'AMBIGUOUS'; Payload = @{}; Store = @{ SecondInvocation = $true } }
        @{ Name = 'a capability attestation with another build'; Code = 'RUNTIME'; Payload = @{}; Store = @{ RuntimeOverrides = @{ build_sha256 = ('1' * 64) } } }
    ) {
        $store = Get-StartStore -HostName 'codex' @Store
        $attestation = Get-CodexStartAttestation -Payload (Get-CodexStartPayload @Payload) -Store $store
        $attestation.routing_valid | Should -BeFalse
        $attestation.discovery_code | Should -Be $Code -Because $attestation.discovery_reason
        $attestation.enforcement_marker | Should -Be 'DISCOVERY_START_ATTESTATION_BLOCKED'
        $attestation.start_attestation_ref | Should -BeNullOrEmpty
        $store.Writes.Count | Should -Be 0
        (Invoke-CodexModelRoutingDecision -PayloadRaw '{"agent_type":"legacy-parity-analyst-c3","model":"gpt-6.1-sol"}' -AttestationRaw ($attestation | ConvertTo-Json -Compress -Depth 5)).hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'records a profile read failure as a rejected attestation' {
        Mock Get-CodexAgentProfileAttestation { throw 'profile missing' }
        $attestation = Get-CodexStartAttestation -AgentProfile $null
        $attestation.routing_valid | Should -BeFalse
        $attestation.discovery_code | Should -Be 'PROFILE'
        $attestation.profile_validation_error | Should -Match 'profile missing'
    }

    It 'requires agent_id, agent_type and model in the start payload' {
        { Get-CodexStartAttestation -Payload ([pscustomobject]@{ session_id = 's'; agent_id = ''; agent_type = 'legacy-parity-analyst-c3'; model = 'm' }) } | Should -Throw '*requires agent_id, agent_type, and model*'
    }

    It 'denies a discovery agent without any attestation at the model gate' {
        (Invoke-CodexModelRoutingDecision -PayloadRaw '{"agent_type":"legacy-parity-analyst","model":"m"}' -AttestationRaw '').hookSpecificOutput.permissionDecisionReason | Should -BeLike 'MODEL_ROUTING_ATTESTATION_BLOCKED:*no matching SubagentStart attestation*'
    }

    It 'renders the blocked stdout only for a rejected attestation' {
        Get-CodexDiscoveryStartCommandOutput -Attestation ([ordered]@{ routing_valid = $true }) -AttestationPath 'memory/a.json' | Should -BeNullOrEmpty
        $output = Get-CodexDiscoveryStartCommandOutput -Attestation ([ordered]@{ routing_valid = $false; discovery_reason = 'no invocation' }) -AttestationPath 'memory/a.json' | ConvertFrom-Json
        $output.systemMessage | Should -Be 'DISCOVERY_START_ATTESTATION_BLOCKED: no invocation Attestation: memory/a.json'
        $output.hookSpecificOutput.hookEventName | Should -Be 'SubagentStart'
    }

    Context 'SubagentStart command' {
        BeforeEach {
            $script:WrittenAttestation = $null
            $script:HeadReads = 0
            $script:CheckpointReads = 0
            Mock Write-CodexSubagentAttestation { $script:WrittenAttestation = $Attestation; 'memory-authority/discovery.json' }
            Mock Get-CodexDiscoveryStartAttestation { [ordered]@{ routing_valid = $script:DiscoveryValid; discovery_reason = 'reason'; agent_type = $Payload.agent_type; now = $Now } }
            $script:CommandParameters = @{
                RepositoryRoot = $script:RepoRoot
                ReadInput      = { '{"session_id":"one","turn_id":"turn","agent_id":"child","agent_type":"legacy-parity-analyst-c3","model":"gpt-6.1-sol"}' }
                ReadCheckpoint = { $script:CheckpointReads++; '{}' }
                ReadHead       = { $script:HeadReads++; @{ sha = ('a' * 40); exit_code = 0 } }
                GetNow         = { $script:Now }
            }
        }

        It 'attests a discovery start without reading HEAD or any orchestrator checkpoint' {
            $script:DiscoveryValid = $true
            Mock Test-Path { $true }
            $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
            $result.exit_code | Should -Be 0
            $result.stdout | Should -BeNullOrEmpty
            $result.stderr | Should -BeNullOrEmpty
            $script:HeadReads | Should -Be 0
            $script:CheckpointReads | Should -Be 0
            $script:WrittenAttestation.agent_type | Should -Be 'legacy-parity-analyst-c3'
            $script:WrittenAttestation.now | Should -Be $script:Now
            Should -Invoke Get-CodexDiscoveryStartAttestation -Times 1 -Exactly -ParameterFilter { $RepositoryRoot -eq $script:RepoRoot }
        }

        It 'returns the blocked JSON at exit zero for a rejected discovery start' {
            $script:DiscoveryValid = $false
            $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
            $result.exit_code | Should -Be 0
            ($result.stdout | ConvertFrom-Json).systemMessage | Should -Be 'DISCOVERY_START_ATTESTATION_BLOCKED: reason Attestation: memory-authority/discovery.json'
        }

        It 'propagates a discovery attestation failure through stderr and exit two' {
            Mock Get-CodexDiscoveryStartAttestation { throw 'DISCOVERY_START_ATTESTATION_BLOCKED: SubagentStart requires agent_id, agent_type, and model.' }
            $result = Invoke-CodexSubagentAttestationCommand @script:CommandParameters
            $result.exit_code | Should -Be 2
            $result.stderr | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*'
            Should -Invoke Write-CodexSubagentAttestation -Times 0 -Exactly
        }
    }
}
