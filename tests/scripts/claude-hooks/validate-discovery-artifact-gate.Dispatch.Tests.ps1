#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Validator-dispatch suite for `.claude/hooks/validate-discovery-artifact-gate.ps1`
    (issue #929, review note NB-9).

    The E3 discovery corpus used the default declaration reader, which reports the
    declaration absent, so the gate allowed before its dispatch loop. These cases inject a
    present-declaration reader and mock the Invoke-DiscoveryValidatorExe seam so the loop
    runs. They live in a sibling container because validate-discovery-artifact-gate.Tests.ps1
    would exceed 470 lines with them. The message carries no scripts/dev_tools path: the
    profile prefix match in Get-DiscoveryArtifactType is an existing out-of-scope follow-up
    owned by #9002. No test creates, writes, or deletes a file.
#>

Describe 'validate-discovery-artifact-gate.ps1 validator dispatch (issue #929)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-discovery-artifact-gate.ps1").Path
        . $script:UnderTest

        # A required-artifact reader stub that reports the declaration as present.
        $script:PresentReader = { @{ Present = $true; Declaration = @{ types = @('coverage-ledger', 'parity-matrix', 'feature-contract') } } }

        # Corpus-shaped message: three discovery types, one duplicated reference, backtick-wrapped,
        # trailing-comma and parenthesized references, and two empty-after-trim tokens.
        $script:DispatchMessage = 'Wrote `discovery/coverage-ledger/coverage-ledger.json` and "" then discovery/parity-matrix/parity-matrix.json, plus ` (discovery/feature-contract/feature-contract.json) and re-checked discovery/coverage-ledger/coverage-ledger.json'
        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
        $script:DispatchEnvelope = ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:DispatchMessage
    }

    Context 'validator dispatch with a present declaration (issue #929)' {
        It 'dispatches each distinct discovery reference exactly once' {
            # Arrange: every reference validates.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }
            $thrown = $null
            $result = $null
            # Act
            try { $result = Invoke-DiscoveryArtifactGateValidation -InputText $script:DispatchEnvelope -RequiredArtifactReader $script:PresentReader -ErrorAction Stop } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'coverage-ledger' -and $ValidatorArgs[1] -eq 'discovery/coverage-ledger/coverage-ledger.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'parity-matrix' -and $ValidatorArgs[1] -eq 'discovery/parity-matrix/parity-matrix.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'feature-contract' -and $ValidatorArgs[1] -eq 'discovery/feature-contract/feature-contract.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 3 -Exactly
        }

        It 'stops at the first failing reference and returns DISCOVERY_ARTIFACT_GATE_BLOCKED' {
            # Arrange: the second distinct reference (parity-matrix) fails; the others validate.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: parity-matrix' } } -ParameterFilter { $ValidatorArgs[0] -eq 'parity-matrix' }
            $thrown = $null
            $result = $null
            # Act
            try { $result = Invoke-DiscoveryArtifactGateValidation -InputText $script:DispatchEnvelope -RequiredArtifactReader $script:PresentReader -ErrorAction Stop } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $result.Ok | Should -Be $false
            $result.Message.StartsWith('DISCOVERY_ARTIFACT_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'coverage-ledger' -and $ValidatorArgs[1] -eq 'discovery/coverage-ledger/coverage-ledger.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'parity-matrix' -and $ValidatorArgs[1] -eq 'discovery/parity-matrix/parity-matrix.json' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq 'feature-contract' }
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 2 -Exactly
        }
    }
}
