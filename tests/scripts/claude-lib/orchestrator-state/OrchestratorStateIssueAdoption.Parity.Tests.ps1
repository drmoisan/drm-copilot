#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-language parity assertions over the committed issue-adoption corpus.

.DESCRIPTION
    Iterates every tests/fixtures/orchestrator_state_issue_adoption/*.json file
    and asserts that Get-OrchestratorStateRoutingContractError reproduces the
    fixture's ordered expected_errors list exactly. The same corpus is asserted
    by tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
    and by extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts,
    so the fixtures are the single artifact that pins the three runtimes
    together. PowerShell reads the pinned routing matrix in
    OrchestratorStateRoutingMatrix.psm1, whose equality with
    config/orchestration-routing.json is pinned by
    OrchestratorStateRoutingMatrix.Tests.ps1.

    The assertions are file-read-only over committed fixtures, create no
    temporary file, and start no external process.
#>

# Discovery-time corpus enumeration. Pester executes the file body during
# discovery, so the case list must be built here for -ForEach to generate one It
# per fixture.
$fixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_issue_adoption").Path
$fixtureCase = @(
    Get-ChildItem -Path $fixtureDirectory -Filter '*.json' -File |
        Sort-Object -Property Name |
            ForEach-Object {
                $parsed = Get-Content -Path $_.FullName -Raw | ConvertFrom-Json
                @{
                    FixtureName   = $_.BaseName
                    FixturePath   = $_.FullName
                    ExpectedCount = @($parsed.expected_errors).Count
                }
            }
)
$passingCase = @($fixtureCase | Where-Object { $_['ExpectedCount'] -eq 0 })
$failingCase = @($fixtureCase | Where-Object { $_['ExpectedCount'] -gt 0 })

# Floor on corpus size, matching MINIMUM_CORPUS_COUNT in the Python and
# TypeScript readers. An empty or partially matched glob would make every case
# below disappear and the suite would pass vacuously.
$minimumFixtureCount = 34

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force

    $script:FixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_issue_adoption").Path

    # Read one committed corpus file as the validator receives a checkpoint.
    function Get-FixtureContent {
        [CmdletBinding()]
        [OutputType([psobject])]
        param(
            [Parameter(Mandatory = $true)]
            [string] $Path
        )

        return (Get-Content -Path $Path -Raw | ConvertFrom-Json)
    }
}

Describe 'Issue-adoption fixture corpus discovery' {
    Context 'Non-vacuous iteration' {
        It 'discovers at least <MinimumCount> fixture files' -ForEach @(
            @{ DiscoveredCount = $fixtureCase.Count; MinimumCount = $minimumFixtureCount }
        ) {
            # Assert: a short corpus would silently drop scenarios the parity
            # claim depends on, and an empty one would make the suite vacuous.
            $DiscoveredCount | Should -BeGreaterOrEqual $MinimumCount
        }

        It 'discovers exactly the number of JSON files in the corpus directory' -ForEach @(
            @{ DiscoveredCount = $fixtureCase.Count }
        ) {
            # Arrange: enumerate the directory again without the discovery filter.
            $onDisk = @(
                Get-ChildItem -Path $script:FixtureDirectory -File |
                    Where-Object { $_.Extension -ceq '.json' }
            )

            # Assert: the two counts must agree.
            $DiscoveredCount | Should -Be $onDisk.Count
        }

        It 'covers both an empty and a non-empty expected error list' -ForEach @(
            @{ PassingCount = $passingCase.Count; FailingCount = $failingCase.Count }
        ) {
            $PassingCount | Should -BeGreaterThan 0
            $FailingCount | Should -BeGreaterThan 0
        }
    }
}

Describe 'Issue-adoption routing-contract parity' {
    It 'reproduces the expected routing-contract errors for <FixtureName>' -ForEach $fixtureCase {
        # Arrange: the fixture checkpoint and its ordered expectation.
        $fixture = Get-FixtureContent -Path $FixturePath
        $expected = @($fixture.expected_errors) -join "`n"

        # Act: run the routing contract against the pinned matrix.
        $actual = @(Get-OrchestratorStateRoutingContractError -State $fixture.checkpoint) -join "`n"

        # Assert: ordered, exact equality, the same comparison the other runtimes perform.
        $actual | Should -BeExactly $expected
    }
}
