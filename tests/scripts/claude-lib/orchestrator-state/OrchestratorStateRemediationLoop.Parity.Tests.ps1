<#
.SYNOPSIS
    Cross-runtime parity assertions over the remediation-loop corpus (issue #484).

.DESCRIPTION
    Iterates every tests/fixtures/orchestrator_state_remediation_loop/*.json case
    and asserts that Get-OrchestratorStateUnconditionalError, filtered to the
    errors containing 'remediation', reproduces the case's expected_errors list
    in order with case-sensitive element comparison. The same corpus is asserted
    by tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py
    and extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts,
    so the corpus is the single artifact that pins the three runtimes together.
    The pattern follows tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1.

    The corpus is committed and read in place. No temporary file is created and
    no external process is started.
#>

# Discovery-time corpus enumeration, so -ForEach generates one It per case.
$corpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_remediation_loop").Path
$corpusCase = @(
    Get-ChildItem -LiteralPath $corpusDirectory -Filter '*.json' -File |
        Sort-Object -Property Name |
            ForEach-Object { @{ Stem = $_.BaseName; CasePath = $_.FullName } }
)

BeforeAll {
    # Resolve the module directory four levels up: orchestrator-state ->
    # claude-lib -> scripts -> tests -> repo root.
    $moduleDirectory = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateCompletion.psm1') -Force
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateUnconditional.psm1') -Force
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorState.psm1') -Force

    $script:CorpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_remediation_loop").Path

    # Floor on corpus size, equal to MINIMUM_CORPUS_COUNT in the Python and
    # TypeScript parity suites. Published at script scope for the It below.
    $MinimumCorpusCount = 41
    $script:MinimumCorpusFloor = $MinimumCorpusCount

    # Read one committed corpus case. The corpus is read-only for this suite.
    function Get-CorpusCase {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param([Parameter(Mandatory = $true)] [string] $Path)

        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    }
}

Describe 'Remediation-loop corpus discovery' {
    It 'discovers at least the minimum remediation corpus count' {
        # Arrange / Act: enumerate the committed corpus directory.
        $discovered = @(Get-ChildItem -LiteralPath $script:CorpusDirectory -Filter '*.json' -File).Count

        # Assert: a short corpus would silently drop behavior classes.
        $discovered | Should -BeGreaterOrEqual $script:MinimumCorpusFloor
    }

    It 'discovers exactly the number of JSON files in the corpus directory' -ForEach @(
        @{ DiscoveredCount = $corpusCase.Count }
    ) {
        $onDisk = @(
            Get-ChildItem -LiteralPath $script:CorpusDirectory -File |
                Where-Object { $_.Extension -eq '.json' }
        )
        $DiscoveredCount | Should -Be $onDisk.Count
    }
}

Describe 'Remediation-loop corpus parity' {
    It 'keeps the case name equal to the file stem for <Stem>' -ForEach $corpusCase {
        (Get-CorpusCase -Path $CasePath).name | Should -BeExactly $Stem
    }

    It 'reproduces the expected remediation errors for <Stem>' -ForEach $corpusCase {
        # Arrange: the case checkpoint and its ordered expectation.
        $case = Get-CorpusCase -Path $CasePath
        $expected = [string[]]@($case.expected_errors)

        # Act: plain validation filtered to the remediation family.
        $actual = [string[]]@(
            Get-OrchestratorStateUnconditionalError -State $case.checkpoint |
                Where-Object { ([string]$_).Contains('remediation') }
        )

        # Assert: same length, then case-sensitive equality element by element.
        $actual.Count | Should -Be $expected.Count -Because ($actual -join ' | ')
        $mismatch = @(
            for ($index = 0; $index -lt $expected.Count; $index++) {
                if (-not ($actual[$index] -ceq $expected[$index])) {
                    "#${index}: expected '$($expected[$index])' got '$($actual[$index])'"
                }
            }
        )
        $mismatch | Should -BeNullOrEmpty
    }
}
