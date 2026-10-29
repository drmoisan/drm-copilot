#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot native discovery SubagentStart adapter (issue #980).
.DESCRIPTION
    .github/hooks/discovery-agent-start.ps1 is dot-sourced in-process over camelCase
    envelopes; every seam is injected from the shared gate and start fixtures, so no file,
    process, network or clock is touched.
#>

Describe 'discovery-agent-start.ps1 (GitHub Copilot)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-agent-start.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')

        function Invoke-CopilotStart {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-StartEnvelope -HostName 'github-copilot'),
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StartStore -HostName 'github-copilot'),
                [Parameter(Mandatory = $false)][scriptblock]$ReadBytes = (Get-StartProfileReader -HostName 'github-copilot')
            )
            return Invoke-DiscoveryAgentStartDecision -PayloadRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -Now $script:GateNow -Nonce $script:GateNonce -ReadBytes $ReadBytes
        }

        function Invoke-CopilotStartEntryPoint {
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

    It 'loads every helper module without a recorded failure' {
        $script:DiscoveryStartDependencyFailures.Count | Should -Be 0
    }

    It 'skips an ordinary camelCase start' {
        $store = Get-StartStore -HostName 'github-copilot'
        (Invoke-CopilotStart -Json (Get-StartEnvelope -HostName 'github-copilot' -AgentType 'feature-review') -Store $store).Decision | Should -Be 'skip'
        $store.Reads.Count | Should -Be 0
    }

    It 'attests a Copilot discovery start against the protected invocation bound to the github-copilot host' {
        $store = Get-StartStore -HostName 'github-copilot'
        $outcome = Invoke-CopilotStart -Store $store
        $outcome.Decision | Should -Be 'attest' -Because $outcome.Reason
        $attestation = $store.Files[$outcome.AttestationPath] | ConvertFrom-Json
        $attestation.host | Should -Be 'github-copilot'
        $attestation.agent_profile.path | Should -Be '.github/agents/legacy-parity-analyst-c3.agent.md'
        $attestation.writer.handler_sha256 | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:UnderTest)))
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
    }

    It 'observes a Copilot start whose invocation is bound to the Claude host' {
        $outcome = Invoke-CopilotStart -Store (Get-StartStore -HostName 'claude-code')
        $outcome.Decision | Should -Be 'observe'
        $outcome.Code | Should -Be 'NO_INVOCATION'
    }

    It 'observes a start without an agent identifier, which the first controlled call binds instead' {
        $store = Get-StartStore -HostName 'github-copilot'
        $outcome = Invoke-CopilotStart -Json (Get-StartEnvelope -HostName 'github-copilot' -AgentId $null) -Store $store
        $outcome.Decision | Should -Be 'observe'
        $outcome.Code | Should -Be 'IDENTITY'
        $store.Writes.Count | Should -Be 0
    }

    It 'observes two prepared invocations and an unsupported capability' {
        $store = Get-StartStore -HostName 'github-copilot' -SecondInvocation
        $outcome = Invoke-CopilotStart -Store $store
        $outcome.Decision | Should -Be 'observe'
        $outcome.Code | Should -Be 'AMBIGUOUS'
        $store.Writes.Count | Should -Be 0
        (Invoke-CopilotStart -Store (Get-StartStore -HostName 'github-copilot' -CapabilityOverrides @{ status = 'unsupported' })).Code | Should -Be 'CAPABILITY'
    }

    Context 'entry point' {
        It 'exits 2 with the reason on stderr for an unreadable envelope' {
            $result = Invoke-CopilotStartEntryPoint -PayloadRaw ''
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*'
        }

        It 'writes the observed system message for a discovery start without an activation' {
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { Get-StartStore -HostName 'github-copilot' -NoActivation }
            $result = Invoke-CopilotStartEntryPoint -PayloadRaw (Get-StartEnvelope -HostName 'github-copilot')
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).systemMessage | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*not active*'
        }

        It 'observes two prepared invocations as AMBIGUOUS at exit 0 without writing an attestation' {
            $store = Get-StartStore -HostName 'github-copilot' -SecondInvocation
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { $store }.GetNewClosure()
            $result = Invoke-CopilotStartEntryPoint -PayloadRaw (Get-StartEnvelope -HostName 'github-copilot')
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).systemMessage | Should -BeLike 'DISCOVERY_START_ATTESTATION_BLOCKED:*2 prepared invocations*'
            $store.Writes.Count | Should -Be 0
        }

        It 'stays silent for an ordinary start' {
            $result = Invoke-CopilotStartEntryPoint -PayloadRaw (Get-StartEnvelope -HostName 'github-copilot' -AgentType 'pr-author')
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }
    }
}
