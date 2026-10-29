#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Claude Code native discovery SubagentStart adapter (issue #980).
.DESCRIPTION
    .claude/hooks/record-discovery-agent-start.ps1 is dot-sourced in-process; every seam
    (host roots, protected store, clock, nonce, profile bytes) is injected from the
    shared gate and start fixtures and the identity comes from the payload fixture, so
    no file, process, network or clock is touched. Ordinary and epic starts stay silent;
    a discovery start is attested against its protected invocation or observed with the
    DISCOVERY_START_ATTESTATION_BLOCKED: prefix; no orchestrator checkpoint is touched.
#>

Describe 'record-discovery-agent-start.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.claude/hooks/record-discovery-agent-start.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')

        function Invoke-Start {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-StartEnvelope),
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StartStore),
                [Parameter(Mandatory = $false)][scriptblock]$ReadBytes = (Get-StartProfileReader)
            )
            return Invoke-DiscoveryAgentStartDecision -PayloadRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -Now $script:GateNow -Nonce $script:GateNonce -ReadBytes $ReadBytes
        }

        function Invoke-StartEntryPoint {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$PayloadRaw)
            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $exitCode = Invoke-DiscoveryAgentStartEntryPoint -PayloadRaw $PayloadRaw
                return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $outWriter.ToString(); Stderr = $errorWriter.ToString() }
            } finally {
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
        }
    }

    It 'skips an <Name> start without reading or writing the protected store' -ForEach @(
        @{ Name = 'ordinary'; AgentType = 'atomic-executor' }
        @{ Name = 'epic'; AgentType = 'epic-orchestrator' }
    ) {
        $store = Get-StartStore
        $outcome = Invoke-Start -Json (Get-StartEnvelope -AgentType $AgentType) -Store $store
        $outcome.Decision | Should -Be 'skip'
        $store.Reads.Count | Should -Be 0
        $store.Writes.Count | Should -Be 0
    }

    It 'observes an unreadable envelope with the ENVELOPE code' {
        $outcome = Invoke-Start -Json '{not-json'
        $outcome.Decision | Should -Be 'observe'
        $outcome.Code | Should -Be 'ENVELOPE'
    }

    It 'attests a discovery start against the protected invocation and never reads the mirror' {
        $store = Get-StartStore
        $outcome = Invoke-Start -Store $store
        $outcome.Decision | Should -Be 'attest' -Because $outcome.Reason
        $attestation = $store.Files[$outcome.AttestationPath] | ConvertFrom-Json
        $attestation.host | Should -Be 'claude-code'
        $attestation.agent_type | Should -Be 'legacy-parity-analyst-c3'
        $attestation.deployment.actual_model | Should -BeNullOrEmpty
        $attestation.agent_profile.path | Should -Be '.claude/agents/legacy-parity-analyst-c3.md'
        $attestation.writer.handler_sha256 | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:UnderTest)))
        ($store.Files["$($script:GateInvocationDirectory)/invocation.json"] | ConvertFrom-Json).state | Should -Be 'started'
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
        @($store.Reads | Where-Object { $_ -like 'artifacts/orchestration/*' -or $_ -like '*/artifacts/orchestration/*' }).Count | Should -Be 0
    }

    It 'observes <Name> with code <Code> and writes nothing' -ForEach @(
        @{ Name = 'a start without a prepared invocation'; Code = 'NO_INVOCATION'; Store = @{ NoInvocation = $true } }
        @{ Name = 'two prepared invocations'; Code = 'AMBIGUOUS'; Store = @{ SecondInvocation = $true } }
        @{ Name = 'a tampered profile hash in the invocation'; Code = 'BINDING'; Store = @{ InvocationOverrides = @{ workspace = [ordered]@{ workspace_root = 'C:/Users/Example/Repos/Workspace'; workspace_sha256 = '77f077989d4b47c3249dcb4b1f5d5c59fa91f1045e244879660ef1ef212a19b6'; profile_path = 'docs/migration/discovery/domain-profile.yaml'; profile_sha256 = ('0' * 64) } } } }
        @{ Name = 'a capability attestation with other runtime pins'; Code = 'RUNTIME'; Store = @{ RuntimeOverrides = @{ policy_sha256 = ('2' * 64) } } }
    ) {
        $store = Get-StartStore @Store
        $outcome = Invoke-Start -Store $store
        $outcome.Decision | Should -Be 'observe'
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
        $store.Writes.Count | Should -Be 0
    }

    It 'observes a profile the workspace does not hold' {
        (Invoke-Start -ReadBytes (Get-StartProfileReader -Text $null)).Code | Should -Be 'PROFILE'
    }

    Context 'entry point' {
        It 'exits 2 with the reason on stderr for an unreadable envelope' {
            $result = Invoke-StartEntryPoint -PayloadRaw '{'
            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*'
        }

        It 'stays silent for an ordinary start' {
            $result = Invoke-StartEntryPoint -PayloadRaw (Get-StartEnvelope -AgentType 'atomic-planner')
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'writes the observed system message for a discovery start without an invocation' {
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { Get-StartStore -NoInvocation }
            $result = Invoke-StartEntryPoint -PayloadRaw (Get-StartEnvelope)
            $result.ExitCode | Should -Be 0
            $output = $result.Stdout | ConvertFrom-Json
            $output.systemMessage | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*no prepared protected invocation*'
            $output.hookSpecificOutput.hookEventName | Should -Be 'SubagentStart'
        }

        It 'observes two prepared invocations as AMBIGUOUS at exit 0 without writing an attestation' {
            $store = Get-StartStore -SecondInvocation
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { $store }.GetNewClosure()
            $result = Invoke-StartEntryPoint -PayloadRaw (Get-StartEnvelope)
            $result.ExitCode | Should -Be 0
            $output = $result.Stdout | ConvertFrom-Json
            $output.systemMessage | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*2 prepared invocations*'
            @($output.PSObject.Properties.Name) | Should -Not -Contain 'continue'
            $store.Writes.Count | Should -Be 0
        }
    }
}
