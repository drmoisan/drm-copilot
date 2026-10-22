#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Codex discovery SubagentStop output adapter (issue #980).
.DESCRIPTION
    .codex/hooks/validate-discovery-agent-output.ps1 is dot-sourced in-process; the shared
    discovery modules resolve to .claude/lib because this repository publishes .codex/lib only
    into destinations. Every seam is injected from the shared fixtures; entry-point rows redirect
    stdin, stdout and stderr and restore them in finally. No file, process, network or clock is
    touched.
#>

Describe 'Codex validate-discovery-agent-output.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/validate-discovery-agent-output.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStop.TestSupport.ps1')

        function Get-CodexStopOutcome {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-StopEnvelope -HostName 'codex'),
                [Parameter(Mandatory = $false)][hashtable]$Environment = (Get-StartEnvironment -HostName 'codex'),
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StopStore -HostName 'codex')
            )
            return Invoke-DiscoveryAgentOutputDecision -PayloadRaw $Json -EnvironmentValues $Environment -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-StopByteReader)
        }

        function Invoke-CodexStopEntryPoint {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$PayloadRaw)
            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $exitCode = Invoke-DiscoveryAgentOutputEntryPoint -PayloadRaw $PayloadRaw
                return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $outWriter.ToString(); Stderr = $errorWriter.ToString() }
            } finally {
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
        }
    }

    It 'resolves the helper modules from the published location first and the repository second' {
        ((Get-DiscoveryStopHelperModulePath -ModuleName 'DiscoveryStop.psm1' -ScriptRoot 'C:/dest/.codex/hooks') -replace '\\', '/') | Should -Be 'C:/dest/.codex/hooks/../lib/discovery-validation/DiscoveryStop.psm1'
        Test-Path -LiteralPath (Get-DiscoveryStopHelperModulePath -ModuleName 'DiscoveryStop.psm1') | Should -BeTrue
    }

    It 'validates a finalized <Role> stop bound to the codex host' -ForEach @(
        @{ Role = 'legacy-parity-analyst'; AgentType = 'legacy-parity-analyst-c3' }
        @{ Role = 'migration-coverage-reviewer'; AgentType = 'migration-coverage-reviewer-c1' }
    ) {
        $store = Get-StopStore -HostName 'codex' -Role $Role
        $outcome = Get-CodexStopOutcome -Json (Get-StopEnvelope -HostName 'codex' -AgentType $AgentType) -Store $store
        $outcome.Decision | Should -Be 'allow' -Because $outcome.Reason
        $outcome.Code | Should -Be 'VALIDATED'
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
    }

    It 'skips an ordinary Codex stop' {
        $store = Get-StopStore -HostName 'codex'
        (Get-CodexStopOutcome -Json (Get-StopEnvelope -HostName 'codex' -AgentType 'atomic-executor-c3') -Store $store).Decision | Should -Be 'skip'
        $store.Reads.Count | Should -Be 0
    }

    It 'blocks <Name> with code <Code>' -ForEach @(
        @{ Name = 'a specialist whose invocation is bound to the Claude host'; Code = 'NO_INVOCATION'; Store = @{ HostName = 'claude-code' } }
        @{ Name = 'a specialist that never finalized'; Code = 'NOT_FINALIZED'; Store = @{ HostName = 'codex'; State = 'started' } }
        @{ Name = 'a forged receipt'; Code = 'FORGED'; Store = @{ HostName = 'codex'; WriterOverrides = @{ kind = 'workspace-copy' } } }
    ) {
        $outcome = Get-CodexStopOutcome -Store (Get-StopStore @Store)
        $outcome.Decision | Should -Be 'block'
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
    }

    It 'renders a block as a continuation and a repeated block as the stop reason' {
        (Get-DiscoveryAgentOutputContinuation -Reason 'r' -AlreadyContinued $false).decision | Should -Be 'block'
        (Get-DiscoveryAgentOutputContinuation -Reason 'r' -AlreadyContinued $true).continue | Should -BeFalse
    }

    Context 'entry point' {
        It 'exits 2 with the reason on stderr for an unreadable envelope' {
            $result = Invoke-CodexStopEntryPoint -PayloadRaw '{'
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'stays silent for an ordinary stop' {
            $result = Invoke-CodexStopEntryPoint -PayloadRaw (Get-StopEnvelope -HostName 'codex' -AgentType 'pr-author')
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'requests a continuation for a specialist without a receipt and ends the stop once continued' {
            Mock Get-DiscoveryHostEnvironmentValueTable { Get-StartEnvironment -HostName 'codex' }
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { Get-StopStore -HostName 'codex' -NoReceipt }
            $first = Invoke-CodexStopEntryPoint -PayloadRaw (Get-StopEnvelope -HostName 'codex')
            $first.ExitCode | Should -Be 0
            ($first.Stdout | ConvertFrom-Json).decision | Should -Be 'block'
            ($first.Stdout | ConvertFrom-Json).reason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*completion receipt*'
            $second = Invoke-CodexStopEntryPoint -PayloadRaw (Get-StopEnvelope -HostName 'codex' -StopHookActive $true)
            ($second.Stdout | ConvertFrom-Json).continue | Should -BeFalse
        }
    }
}
