<#
.SYNOPSIS
    Behavioral tests for Resolve-DelegationModel.

.DESCRIPTION
    Translates the pytest suite in
    tests/scripts/dev_tools/test_resolve_delegation_model.py into Pester and adds
    the out-of-table-band negative case required by the spec Test Strategy. Each It
    targets a single behavior with Arrange-Act-Assert structure. The tests read no
    external process and create no temporary files.
#>

BeforeAll {
    # Resolve the module four levels up: model-routing -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/model-routing.
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/model-routing/ModelRouting.psm1").Path
    Import-Module $modulePath -Force

    # The four preferred-overlay agents and the two non-overlay agents whose C3
    # cell stays opus under every policy, matching the Python fixtures.
    $script:OverlayAgents = @('atomic-planner', 'prd-feature', 'feature-review', 'task-researcher')
    $script:NonOverlayAgents = @('atomic-executor', 'pr-author')
}

Describe 'Resolve-DelegationModel' {
    Context 'Base table under the available policy' {
        It 'resolves band <band> to <expected> with no clamp' -ForEach @(
            @{ band = 'C1'; expected = 'haiku' },
            @{ band = 'C2'; expected = 'sonnet' },
            @{ band = 'C3'; expected = 'opus' },
            @{ band = 'C4'; expected = 'fable' }
        ) {
            # Arrange / Act: resolve a non-overlay-affecting agent under available.
            $result = Resolve-DelegationModel -Agent 'atomic-executor' -Band $band -FablePolicy 'available'

            # Assert: model and table_model both equal the base table lookup; no clamp.
            $result.model | Should -Be $expected
            $result.table_model | Should -Be $expected
            $result.clamped_from | Should -Be $null
            $result.clamp_reason | Should -Be $null
        }

        It 'leaves a fable (C4) cell intact under available' {
            # Arrange / Act: C4 resolves to fable under available for any agent.
            $result = Resolve-DelegationModel -Agent 'atomic-planner' -Band 'C4' -FablePolicy 'available'

            # Assert: fable is preserved and no clamp provenance is recorded.
            $result.model | Should -Be 'fable'
            $result.clamped_from | Should -Be $null
        }
    }

    Context 'Disabled policy clamp' {
        It 'clamps the C4 fable cell to opus with provenance for agent <_>' -ForEach @(
            'atomic-planner', 'prd-feature', 'feature-review', 'task-researcher', 'atomic-executor', 'pr-author'
        ) {
            # Arrange / Act: C4 is a fable cell for every agent; disabled clamps it.
            $result = Resolve-DelegationModel -Agent $_ -Band 'C4' -FablePolicy 'disabled'

            # Assert: table_model records the pre-clamp fable; model is the opus clamp.
            $result.table_model | Should -Be 'fable'
            $result.model | Should -Be 'opus'
            $result.clamped_from | Should -Be 'fable'
            $result.clamp_reason | Should -Be 'fable_disabled'
        }

        It 'does not apply the preferred overlay so an overlay agent C3 stays opus' {
            # Arrange / Act: an overlay agent at C3 under disabled; overlay is inert.
            $result = Resolve-DelegationModel -Agent 'atomic-planner' -Band 'C3' -FablePolicy 'disabled'

            # Assert: base C3 opus, no fable, no clamp (table_model was never fable).
            $result.table_model | Should -Be 'opus'
            $result.model | Should -Be 'opus'
            $result.clamped_from | Should -Be $null
        }
    }

    Context 'Preferred overlay' {
        It 'resolves the C3 cell to fable for overlay agent <_>' -ForEach @(
            'atomic-planner', 'prd-feature', 'feature-review', 'task-researcher'
        ) {
            # Arrange / Act: overlay agent at C3 under preferred.
            $result = Resolve-DelegationModel -Agent $_ -Band 'C3' -FablePolicy 'preferred'

            # Assert: the overlay redirects C3 to fable, with no clamp under preferred.
            $result.table_model | Should -Be 'fable'
            $result.model | Should -Be 'fable'
            $result.clamped_from | Should -Be $null
        }

        It 'leaves non-overlay agent <_> C3 at opus under preferred' -ForEach @(
            'atomic-executor', 'pr-author'
        ) {
            # Arrange / Act: non-overlay agent at C3 under preferred.
            $result = Resolve-DelegationModel -Agent $_ -Band 'C3' -FablePolicy 'preferred'

            # Assert: the overlay does not apply; C3 stays at the base opus.
            $result.table_model | Should -Be 'opus'
            $result.model | Should -Be 'opus'
        }
    }

    Context 'Determinism' {
        It 'returns an identical mapping across repeated calls with the same input' {
            # Arrange: a fixed input triple.
            $calls = 1..5 | ForEach-Object { Resolve-DelegationModel -Agent 'atomic-planner' -Band 'C3' -FablePolicy 'preferred' }

            # Assert: every call returns an identical mapping (compare to the first).
            foreach ($result in $calls) {
                $result.table_model | Should -Be $calls[0].table_model
                $result.model | Should -Be $calls[0].model
                $result.clamped_from | Should -Be $calls[0].clamped_from
                $result.clamp_reason | Should -Be $calls[0].clamp_reason
            }
        }
    }

    Context 'Out-of-table band (negative case)' {
        It 'throws on a band outside the base table' {
            # Arrange / Act / Assert: an out-of-table band is the PowerShell analog
            # of the Python KeyError; the function must fail fast rather than return
            # a silently wrong value.
            { Resolve-DelegationModel -Agent 'atomic-executor' -Band 'C9' -FablePolicy 'available' } |
                Should -Throw
        }
    }
}
