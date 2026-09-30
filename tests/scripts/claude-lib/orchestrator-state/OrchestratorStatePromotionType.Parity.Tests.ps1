#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-runtime parity assertions over the committed promotion-type corpus.

.DESCRIPTION
    Iterates every tests/fixtures/orchestrator_state_promotion_type/*.json file
    and asserts that Get-OrchestratorStateRoutingContractError reproduces each
    fixture's expected_errors list exactly, in order. The same corpus is asserted
    by tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py
    and by extensions/drm-copilot/test/lib/validate/
    orchestrator-state-promotion-type-parity.test.ts, so the fixtures are the
    single artifact that pins the three runtimes together; no suite may relax an
    expectation without the others observing the change.

    Fixture shape: name (equal to the file stem), notes, checkpoint (the object
    handed to the validator), and expected_errors (the ordered error list, empty
    when the checkpoint is accepted).

    The suite reads committed files only. It creates no temporary file and starts
    no external process.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Discovery-time variables are consumed inside It blocks through -ForEach')]
param()

# Discovery-time corpus enumeration. Pester executes the file body during
# discovery, so the case list must be built here for -ForEach to generate one It
# per fixture. The fixture body is re-read inside each It so the assertions run
# against a freshly parsed record.
$fixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_promotion_type").Path
$fixtureCase = @(
    Get-ChildItem -Path $fixtureDirectory -Filter '*.json' -File |
        Sort-Object -Property Name |
            ForEach-Object {
                $parsed = Get-Content -Path $_.FullName -Raw | ConvertFrom-Json
                @{
                    FixtureName = $_.BaseName
                    FixturePath = $_.FullName
                    ErrorCount  = @($parsed.expected_errors).Count
                }
            }
)
$rejectedCase = @($fixtureCase | Where-Object { $_['ErrorCount'] -gt 0 })
$acceptedCase = @($fixtureCase | Where-Object { $_['ErrorCount'] -eq 0 })

# Floor on corpus size, matching MINIMUM_CORPUS_COUNT in the Python parity suite.
# An empty or partially matched glob would make every case below disappear and
# the suite would pass vacuously, so the count is asserted twice: against this
# floor and against the files on disk.
$minimumFixtureCount = 12

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force

    $script:FixtureDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_promotion_type").Path
}

Describe 'Promotion-type fixture corpus discovery' {
    Context 'Non-vacuous iteration' {
        It 'discovers at least <MinimumCount> fixture files' -ForEach @(
            @{ DiscoveredCount = $fixtureCase.Count; MinimumCount = $minimumFixtureCount }
        ) {
            # Arrange / Act: the corpus is enumerated at discovery time.
            # Assert: a short corpus would silently drop behavior classes.
            $DiscoveredCount | Should -BeGreaterOrEqual $MinimumCount
        }

        It 'discovers exactly the number of JSON files in the corpus directory' -ForEach @(
            @{ DiscoveredCount = $fixtureCase.Count }
        ) {
            # Arrange: enumerate the directory again without the discovery
            # filter, so a pattern that silently skipped files is caught.
            $onDisk = @(
                Get-ChildItem -Path $script:FixtureDirectory -File |
                    Where-Object { $_.Extension -eq '.json' }
            )

            # Assert: the counts must agree across all three runtimes' suites.
            $DiscoveredCount | Should -Be $onDisk.Count
        }

        It 'covers both an accepted and a rejected checkpoint' -ForEach @(
            @{ RejectedCount = $rejectedCase.Count; AcceptedCount = $acceptedCase.Count }
        ) {
            # Arrange / Act: the case lists are partitioned at discovery.
            # Assert: a one-sided corpus never exercises both verdict paths.
            $RejectedCount | Should -BeGreaterThan 0
            $AcceptedCount | Should -BeGreaterThan 0
        }
    }
}

Describe 'Promotion-type routing-contract parity' {
    Context 'Corpus cases' {
        It 'reproduces the expected routing errors for <FixtureName>' -ForEach $fixtureCase {
            # Arrange: the corpus checkpoint and its ordered expectation. The
            # fixture is parsed without -AsHashtable so the checkpoint binds to
            # the [psobject] State parameter.
            $fixture = Get-Content -Path $FixturePath -Raw | ConvertFrom-Json
            $expected = @($fixture.expected_errors) -join "`n"

            # Act: drive the checkpoint through the public validator function.
            $observed = @(Get-OrchestratorStateRoutingContractError -State $fixture.checkpoint) -join "`n"

            # Assert: one joined string, so empty and single-element lists are
            # unambiguous and order is pinned.
            $observed | Should -BeExactly $expected
        }
    }
}
