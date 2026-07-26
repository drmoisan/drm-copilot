<#
.SYNOPSIS
    Static config-parity tests pinning the ModelRouting constants to the routing config.

.DESCRIPTION
    Modeled on tests/scripts/dev_tools/test_orchestration_routing_config_parity.py.
    Reads config/orchestration-routing.json (model_policy / model_budget) and asserts
    that the module's embedded script-scope constants equal the authoritative config
    values. This is a file-read-only assertion: it invokes no external process and
    creates no temporary files. It keeps the two-language mirror pinned to a single
    source of truth.
#>

BeforeAll {
    # Resolve the module four levels up: model-routing -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/model-routing.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = Join-Path $repoRoot '.claude/lib/model-routing/ModelRouting.psm1'
    Import-Module $modulePath -Force

    # Read the authoritative routing config as the parity source of truth.
    $configPath = Join-Path $repoRoot 'config/orchestration-routing.json'
    $script:Config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    $script:ModelPolicy = $script:Config.model_policy
    $script:ModelBudget = $script:Config.model_budget
}

Describe 'ModelRouting config parity' {
    Context 'Base complexity-to-model table' {
        It 'pins BASE_COMPLEXITY_TO_MODEL[<band>] to model_policy.complexity_to_model' -ForEach @(
            @{ band = 'C1' }, @{ band = 'C2' }, @{ band = 'C3' }, @{ band = 'C4' }
        ) {
            # Arrange: the authoritative model for this band from the config.
            $expected = $script:ModelPolicy.complexity_to_model.$band

            # Act: read the module's embedded constant for this band.
            $actual = InModuleScope 'ModelRouting' -Parameters @{ Band = $band } {
                param($Band)
                $script:BASE_COMPLEXITY_TO_MODEL[$Band]
            }

            # Assert: the embedded literal equals the config value.
            $actual | Should -Be $expected
        }
    }

    Context 'Preferred overlay' {
        It 'pins PREFERRED_OVERLAY_AGENTS to model_policy.preferred_overlay.agents' {
            # Arrange: the authoritative overlay agent set from the config.
            $expected = @($script:ModelPolicy.preferred_overlay.agents)

            # Act: read the module's embedded overlay agent set.
            $actual = InModuleScope 'ModelRouting' { $script:PREFERRED_OVERLAY_AGENTS }

            # Assert: the ordered agent sets match exactly.
            @($actual) | Should -Be $expected
        }

        It 'pins PREFERRED_OVERLAY_BAND to model_policy.preferred_overlay.band (C3)' {
            # Arrange / Act.
            $expected = $script:ModelPolicy.preferred_overlay.band
            $actual = InModuleScope 'ModelRouting' { $script:PREFERRED_OVERLAY_BAND }

            # Assert.
            $actual | Should -Be $expected
            $actual | Should -Be 'C3'
        }

        It 'pins PREFERRED_OVERLAY_MODEL to model_policy.preferred_overlay.model (fable)' {
            # Arrange / Act.
            $expected = $script:ModelPolicy.preferred_overlay.model
            $actual = InModuleScope 'ModelRouting' { $script:PREFERRED_OVERLAY_MODEL }

            # Assert.
            $actual | Should -Be $expected
            $actual | Should -Be 'fable'
        }
    }

    Context 'Floor candidate and ceiling bands' {
        It 'pins FLOOR_CANDIDATE_BAND to C3' {
            # Act / Assert: the floor candidate band is the documented C3.
            (InModuleScope 'ModelRouting' { $script:FLOOR_CANDIDATE_BAND }) | Should -Be 'C3'
        }

        It 'pins FLOOR_CEILING_BAND to C3' {
            # Act / Assert: the floor ceiling band is the documented C3.
            (InModuleScope 'ModelRouting' { $script:FLOOR_CEILING_BAND }) | Should -Be 'C3'
        }
    }

    Context 'Floor-signal name set' {
        It 'pins FLOOR_SIGNAL_NAMES to the model_policy.complexity signals flagged floor true' {
            # Arrange: the authoritative floor-signal names read from the config by the
            # test (never by the module, which must remain file-read-free at runtime).
            $floorSignals = @($script:ModelPolicy.complexity.signals | Where-Object { $_.floor -eq $true })
            $expected = @($floorSignals | ForEach-Object { $_.name }) | Sort-Object

            # Act: read the module's embedded floor-signal name set.
            $actual = @(InModuleScope 'ModelRouting' { $script:FLOOR_SIGNAL_NAMES }) | Sort-Object

            # Assert: the embedded set equals the config's "floor": true names exactly.
            $actual | Should -Be $expected
            $expected.Count | Should -Be 4
        }

        It 'excludes every model_policy.complexity signal flagged floor false' {
            # Arrange: the config's non-floor signal names.
            $nonFloorSignals = @($script:ModelPolicy.complexity.signals | Where-Object { $_.floor -ne $true })
            $nonFloor = @($nonFloorSignals | ForEach-Object { $_.name })

            # Act: read the module's embedded floor-signal name set.
            $actual = @(InModuleScope 'ModelRouting' { $script:FLOOR_SIGNAL_NAMES })

            # Assert: no non-floor name is carried in the embedded set.
            $nonFloor.Count | Should -Be 3
            foreach ($name in $nonFloor) { $actual | Should -Not -Contain $name }
        }
    }

    Context 'Disabled policy literal' {
        It 'pins DISABLED_POLICY to the disabled-policy literal' {
            # The disabled-policy enum name is a fixed literal, independent of the
            # session's selected model_budget.fable_policy value.
            $expected = 'disabled'

            # Act: read the module's embedded disabled-policy literal.
            $actual = InModuleScope 'ModelRouting' { $script:DISABLED_POLICY }

            # Assert: the embedded literal equals the fixed disabled-policy name.
            $actual | Should -Be $expected
        }
    }
}
