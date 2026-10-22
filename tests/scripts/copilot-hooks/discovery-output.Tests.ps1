#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot discovery SubagentStop output adapter (issue #980).
.DESCRIPTION
    .github/hooks/discovery-agent-stop.ps1 is dot-sourced in-process over camelCase envelopes;
    every seam is injected from the shared fixtures, so no file, process, network or clock is
    touched.
#>

Describe 'discovery-agent-stop.ps1 (GitHub Copilot)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-agent-stop.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStop.TestSupport.ps1')

        function Get-CopilotStopOutcome {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-StopEnvelope -HostName 'github-copilot'),
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StopStore -HostName 'github-copilot')
            )
            return Invoke-DiscoveryAgentStopDecision -PayloadRaw $Json -EnvironmentValues (Get-StartEnvironment -HostName 'github-copilot') -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-StopByteReader)
        }

        function Invoke-CopilotStopEntryPoint {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$PayloadRaw)
            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $exitCode = Invoke-DiscoveryAgentStopEntryPoint -PayloadRaw $PayloadRaw
                return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $outWriter.ToString(); Stderr = $errorWriter.ToString() }
            } finally {
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
        }
    }

    It 'loads every helper module without a recorded failure' {
        $script:DiscoveryStopDependencyFailures.Count | Should -Be 0
    }

    It 'validates a finalized Copilot specialist stop from its protected receipt' {
        $store = Get-StopStore -HostName 'github-copilot'
        $outcome = Get-CopilotStopOutcome -Store $store
        $outcome.Decision | Should -Be 'allow' -Because $outcome.Reason
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
    }

    It 'skips an ordinary camelCase stop and blocks a specialist without a receipt' {
        (Get-CopilotStopOutcome -Json (Get-StopEnvelope -HostName 'github-copilot' -AgentType 'feature-review')).Decision | Should -Be 'skip'
        (Get-CopilotStopOutcome -Store (Get-StopStore -HostName 'github-copilot' -NoReceipt)).Code | Should -Be 'RECEIPT'
    }

    It 'blocks a stop whose final text claims success without the receipt result' {
        (Get-CopilotStopOutcome -Json (Get-StopEnvelope -HostName 'github-copilot' -Text 'All artifacts written successfully.')).Code | Should -Be 'RESULT_TEXT'
    }

    Context 'entry point' {
        It 'exits 2 with the reason on stderr for an unreadable envelope' {
            $result = Invoke-CopilotStopEntryPoint -PayloadRaw ''
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'writes the block decision for a specialist whose invocation never finalized' {
            Mock Get-DiscoveryHostEnvironmentValueTable { Get-StartEnvironment -HostName 'github-copilot' }
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { Get-StopStore -HostName 'github-copilot' -State 'started' }
            $result = Invoke-CopilotStopEntryPoint -PayloadRaw (Get-StopEnvelope -HostName 'github-copilot')
            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).decision | Should -Be 'block'
            ($result.Stdout | ConvertFrom-Json).reason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*not finalized*'
        }

        It 'stays silent for an ordinary stop' {
            $result = Invoke-CopilotStopEntryPoint -PayloadRaw (Get-StopEnvelope -HostName 'github-copilot' -AgentType 'pr-author')
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }
    }
}
