#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Real-dispatch companion suite for `.claude/hooks/enforce-discovery-artifact-gate.ps1`
    (issue #475).

    Why this file exists as a SIBLING of `enforce-discovery-artifact-gate.Tests.ps1`
    rather than as additional `It`s inside it: `Invoke-DiscoveryValidatorExe` is the
    universally mocked seam in that suite (9 `Mock` registrations), so the seam's own
    body never executes there. Keeping the real-dispatch `It`s in a separate Pester
    container guarantees that no mock in either file can shadow the other, and leaves
    every existing mock registration and `Should -Invoke` assertion byte-unchanged.

    A `Mock` registration for the seam function MUST NOT appear anywhere in this file.
    The seam is invoked for real here; only its collaborators are stubbed.

    This suite is also intended as a behavioral oracle for the eventual bash migration
    of the hook surface: it pins the seam's module-path resolution, its module-not-found
    early return, and the defect D-2 empty-output success contract.
#>

Describe 'enforce-discovery-artifact-gate.ps1 real Invoke-DiscoveryValidatorExe dispatch' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-discovery-artifact-gate.ps1").Path
        . $script:UnderTest

        # Imported here so the module-exported delegate is a resolvable command at mock
        # registration time. The seam re-imports it itself with -Force; this import does
        # not stand in for that call, which stays on the covered execution path.
        $script:ValidationModulePath = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/discovery-validation/DiscoveryValidation.psm1").Path
        Import-Module -Name $script:ValidationModulePath -Force

        # A path that is deliberately absent from the repository. Nothing is created:
        # the value only has to be a path the validator cannot find on disk.
        $script:AbsentArtifactPath = Join-Path -Path $PSScriptRoot -ChildPath 'no-such-discovery-artifact.coverage-ledger.json'
    }

    Context 'module-not-found early return' {
        It 'returns ExitCode 1 and the module-not-found message when the shared module is absent' {
            # A filesystem-boundary cmdlet mock narrowed to the single literal path the
            # seam probes. No external executable is mocked and no temporary file is used;
            # this is the only way to drive the guard's true branch without deleting a
            # committed production module.
            Mock Test-Path { $false } -ParameterFilter { $LiteralPath -like '*DiscoveryValidation.psm1' }

            $result = Invoke-DiscoveryValidatorExe -ValidatorArgs @('coverage-ledger', $script:AbsentArtifactPath)

            $result.ExitCode | Should -Be 1
            $result.Output | Should -BeLike 'Discovery-validation module not found:*'
            $result.Output | Should -BeLike '*DiscoveryValidation.psm1'
        }
    }

    Context 'success path (defect D-2 empty-output contract)' {
        It 'returns ExitCode 0 with EMPTY Output when the shared module reports no error' {
            # The seam itself is unmocked and fully executed: it resolves the module path,
            # passes the Test-Path guard, imports the module, and delegates. Only the
            # module-exported delegate is stubbed, so the assertion is about the seam's
            # pass-through of the success contract, not about schema validation.
            Mock Invoke-DiscoveryArtifactValidation { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-DiscoveryValidatorExe -ValidatorArgs @('coverage-ledger', $script:AbsentArtifactPath)

            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeNullOrEmpty
            Should -Invoke Invoke-DiscoveryArtifactValidation -Times 1 -Exactly
        }
    }

    Context 'failure path' {
        It 'returns a non-zero ExitCode and non-empty Output for an artifact that is not on disk' {
            # Fully real: no mock at all. The seam imports the shared module and the real
            # validator reports the missing artifact.
            $result = Invoke-DiscoveryValidatorExe -ValidatorArgs @('coverage-ledger', $script:AbsentArtifactPath)

            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
            $result.Output | Should -BeLike 'Artifact not found:*'
        }

        It 'returns a non-zero ExitCode and non-empty Output when ValidatorArgs is incomplete' {
            $result = Invoke-DiscoveryValidatorExe -ValidatorArgs @('coverage-ledger')

            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Not -BeNullOrEmpty
        }
    }
}
