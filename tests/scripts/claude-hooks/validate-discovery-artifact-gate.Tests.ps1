#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Envelope, prefix and entry-point contract of the Claude Code discovery SubagentStop adapter (issue #980).
.DESCRIPTION
    The hook keeps its name, its DISCOVERY_ARTIFACT_GATE_BLOCKED: prefix, the shared envelope
    helper and its exit-2 block path while the per-role output validation lives in the shared
    DiscoveryStop module (see discovery-output.Tests.ps1). Entry-point rows drive the script
    through the & route with stdin and stderr redirected and restored in finally. No file,
    process, network or clock is touched.
#>

Describe 'validate-discovery-artifact-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-discovery-artifact-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStop.TestSupport.ps1')
        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')

        function Invoke-Gate {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json,
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StopStore)
            )
            return Invoke-DiscoveryArtifactGateValidation -InputText $Json -EnvironmentValues (Get-StartEnvironment) -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-StopByteReader)
        }

        function Invoke-DiscoveryStdinEntry {
            # Drives the hook through the & route with stdin and stderr redirected; both are restored in finally.
            param([AllowEmptyString()] [string] $Stdin)
            $ErrorActionPreference = 'Continue'
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                try { $null = & $script:UnderTest 2>&1 } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ ExitCode = $exitCode; Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }
    }

    Context 'invalid envelope' {
        It 'returns Ok = $false with a payload anomaly message for <Name>' -ForEach @(
            @{ Name = 'empty input text'; Json = '' }
            @{ Name = 'malformed input text'; Json = '{not json' }
            @{ Name = 'a non-object envelope'; Json = '[1]' }
            @{ Name = 'an envelope without last_assistant_message'; Json = '{"session_id":"s","hook_event_name":"SubagentStop"}' }
            @{ Name = 'a non-string last_assistant_message'; Json = '{"session_id":"s","hook_event_name":"SubagentStop","last_assistant_message":5}' }
        ) {
            $result = Invoke-Gate -Json $Json
            $result.Ok | Should -BeFalse
            $result.Code | Should -Be 'ENVELOPE'
            $result.Message | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly - *'
        }
    }

    Context 'ordinary agents and empty messages' {
        It 'returns Ok = $true for an ordinary agent whose message names a discovery artifact' {
            (Invoke-Gate -Json (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.' -AgentType 'atomic-executor')).Ok | Should -BeTrue
        }

        It 'returns Ok = $true for an ordinary agent with an empty message and keeps validating when stop_hook_active is true' {
            (Invoke-Gate -Json (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage '' -AgentType 'general-purpose')).Ok | Should -BeTrue
            (Invoke-Gate -Json (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage '' -AgentType 'general-purpose' -StopHookActive)).Ok | Should -BeTrue
        }

        It 'blocks a discovery specialist whose empty message hides a missing receipt' {
            $result = Invoke-Gate -Json (Get-StopEnvelope -Text '') -Store (Get-StopStore -NoReceipt)
            $result.Ok | Should -BeFalse
            $result.Code | Should -Be 'RECEIPT'
        }
    }

    Context 'domain neutrality' {
        It 'contains no TaskMaster/TMW/Outlook/VSTO token in its own source text' {
            $text = Get-Content -LiteralPath $script:UnderTest -Raw
            $text | Should -Not -Match 'TaskMaster|TMW|Outlook|VSTO'
        }
    }

    Context 'script entrypoint (stdin envelope, issue #905)' {
        It 'exits 2 with a payload anomaly reason for <Name>' -ForEach @(
            @{ Name = 'empty stdin'; Stdin = '' }
            @{ Name = 'malformed stdin'; Stdin = '{' }
            @{ Name = 'an absent last_assistant_message'; Stdin = (ConvertTo-SubagentStopEnvelopeJson -OmitAssistantMessage) }
        ) {
            $result = Invoke-DiscoveryStdinEntry -Stdin $Stdin
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly'
        }

        It 'exits 0 for an ordinary agent regardless of the message' {
            $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.' -AgentType 'atomic-planner')
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'exits 2 with the gate prefix for a discovery specialist whose protected receipt is missing' {
            Mock Get-DiscoveryHostEnvironmentValueTable { Get-StartEnvironment }
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { Get-StopStore -NoReceipt }
            $result = Invoke-DiscoveryStdinEntry -Stdin (Get-StopEnvelope)
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*completion receipt*'
        }

        It 'exits 2 with a validator-error reason when the envelope helper throws' {
            Mock Read-SubagentStopEnvelope { throw 'simulated helper failure' }
            $result = Invoke-DiscoveryStdinEntry -Stdin (Get-StopEnvelope)
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED: validator error: simulated helper failure*'
        }
    }
}
