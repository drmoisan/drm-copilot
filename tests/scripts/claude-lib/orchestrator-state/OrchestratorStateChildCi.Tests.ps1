#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Child CI opt-out (child_ci integration_only) in the PowerShell completion validator (issue #1233).

.DESCRIPTION
    The committed corpus tests/fixtures/orchestrator_state_child_ci pins the local-QC selection inside
    Get-OrchestratorStateCompletionCiGateError to its Python and TypeScript ports: each file records a
    checkpoint and the ordered errors every runtime must emit. The fixtures are read in place; no file
    is written and no process is started.
#>

BeforeDiscovery {
    $corpusDirectory = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_child_ci").Path
    $script:CorpusCase = @(Get-ChildItem -Path $corpusDirectory -Filter '*.json' -File | Sort-Object -Property Name | ForEach-Object { @{ FixtureName = $_.BaseName; FixturePath = $_.FullName } })
    $script:CorpusFloor = @(@{ DiscoveredCount = $script:CorpusCase.Count; MinimumCount = 13 })
}

BeforeAll {
    $script:LibDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
}

Describe 'child_ci integration_only corpus (issue #1233)' {
    BeforeAll {
        Import-Module (Join-Path $script:LibDir 'OrchestratorStateCompletionChecks.psm1') -Force
    }

    It 'OCC-CORPUS-FLOOR discovers at least <MinimumCount> fixture files' -ForEach $script:CorpusFloor {
        $DiscoveredCount | Should -BeGreaterOrEqual $MinimumCount
    }

    It 'OCC-CORPUS-<FixtureName>' -ForEach $script:CorpusCase {
        # Arrange
        $fixture = Get-Content -Path $FixturePath -Raw | ConvertFrom-Json
        $expected = @($fixture.expected_errors) -join "`n"

        # Act
        $actual = @(Get-OrchestratorStateCompletionCiGateError -State $fixture.checkpoint) -join "`n"

        # Assert
        $fixture.name | Should -BeExactly $FixtureName
        $actual | Should -BeExactly $expected
    }

    It 'OCC-ROUTE-OPT-OUT-PREPARATION returns no error for a route without the CI gate' {
        # Arrange: the preparation route sets requires_ci_gate false, so neither gate check runs.
        $state = [pscustomobject]@{ route_id = 'preparation'; epic_mode = $true; child_ci = 'integration_only' }

        # Act
        $errors = @(Get-OrchestratorStateCompletionCiGateError -State $state)

        # Assert
        $errors.Count | Should -Be 0
    }
}
