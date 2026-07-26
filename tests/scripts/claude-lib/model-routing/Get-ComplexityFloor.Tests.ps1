<#
.SYNOPSIS
    Behavioral tests for Get-ComplexityFloor.

.DESCRIPTION
    Translates the pytest truth-table suite in
    tests/scripts/dev_tools/test_compute_complexity_floor.py into Pester. Each It
    targets a single behavior with Arrange-Act-Assert structure. The tests read no
    external process and create no temporary files.
#>

BeforeAll {
    # Resolve the module four levels up: model-routing -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/model-routing.
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/model-routing/ModelRouting.psm1").Path
    Import-Module $modulePath -Force

    # The [floor]-flagged signal names from the model_policy.complexity catalog,
    # matching the floor signals exercised by the Python suite.
    $script:FloorSignals = @(
        'classifier_or_model_logic',
        'auth_or_token_handling',
        'concurrency_or_ordering',
        'cross_module_contract_change'
    )
}

Describe 'Get-ComplexityFloor' {
    Context 'No floor signals present' {
        It 'returns C1 when the signal collection is empty' {
            # Arrange: an empty present-signal collection.
            $signalsPresent = @()

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: the floor is the lowest band C1.
            $floor | Should -Be 'C1'
        }
    }

    Context 'A single present floor signal' {
        It 'raises the floor to C3 for signal <_>' -ForEach @(
            'classifier_or_model_logic',
            'auth_or_token_handling',
            'concurrency_or_ordering',
            'cross_module_contract_change'
        ) {
            # Arrange: a single present floor signal.
            $signalsPresent = @($_)

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: one floor signal on its own resolves to exactly C3.
            $floor | Should -Be 'C3'
        }
    }

    Context 'Multiple present floor signals' {
        It 'resolves the max triggered band to C3 when all floor signals are present' {
            # Arrange: every floor signal present at once.
            $signalsPresent = $script:FloorSignals

            # Act: compute the floor across all present floor signals.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: the maximum triggered candidate band is C3.
            $floor | Should -Be 'C3'
        }

        It 'clamps to C3 and never reaches C4 with many repeated floor signals' {
            # Arrange: a large multiset of floor signals, including repeats, to
            # prove the ceiling clamp holds regardless of how many are present.
            $signalsPresent = $script:FloorSignals * 5

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: the floor is clamped to C3 and never reaches C4.
            $floor | Should -Be 'C3'
            $floor | Should -Not -Be 'C4'
        }
    }

    Context 'Non-floor and unknown signals' {
        It 'returns C1 for the single non-floor signal <_>' -ForEach @(
            'single_file_localized_edit',
            'mechanical_rename_or_move',
            'docs_or_comment_only'
        ) {
            # Arrange: a single catalog signal flagged "floor": false.
            $signalsPresent = @($_)

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: a non-floor signal contributes no candidate band.
            $floor | Should -Be 'C1'
        }

        It 'returns C1 for a single unknown signal name' {
            # Arrange: a name that is not in the model_policy.complexity catalog.
            $signalsPresent = @('not_a_real_signal')

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: unknown names are treated as non-floor and contribute nothing.
            $floor | Should -Be 'C1'
        }

        It 'returns C1 for a list containing only non-floor and unknown signals' {
            # Arrange: several non-contributing names together.
            $signalsPresent = @('docs_or_comment_only', 'mechanical_rename_or_move', 'not_a_real_signal')

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: no floor signal is present, so the floor stays at the lowest band.
            $floor | Should -Be 'C1'
        }
    }

    Context 'Mixed floor and non-floor signals' {
        It 'returns C3 for a mixed list whose only floor signal is <_>' -ForEach @(
            'classifier_or_model_logic',
            'auth_or_token_handling',
            'concurrency_or_ordering',
            'cross_module_contract_change'
        ) {
            # Arrange: one floor signal alongside non-floor and unknown names.
            $signalsPresent = @('docs_or_comment_only', $_, 'not_a_real_signal')

            # Act: compute the floor.
            $floor = Get-ComplexityFloor -SignalsPresent $signalsPresent

            # Assert: a single present floor signal raises the floor to C3.
            $floor | Should -Be 'C3'
        }

        It 'never returns C4 across the full truth table' {
            # Arrange: every catalog name plus an unknown, in one call and singly.
            $allNames = @(
                'classifier_or_model_logic', 'auth_or_token_handling',
                'concurrency_or_ordering', 'cross_module_contract_change',
                'single_file_localized_edit', 'mechanical_rename_or_move',
                'docs_or_comment_only', 'not_a_real_signal'
            )

            # Act: compute the floor for the combined list, each single name, and the
            # empty list.
            $results = @(Get-ComplexityFloor -SignalsPresent $allNames)
            $results += @($allNames | ForEach-Object { Get-ComplexityFloor -SignalsPresent @($_) })
            $results += @(Get-ComplexityFloor -SignalsPresent @())

            # Assert: C4 is never floor-forced; every result is C1 or C3.
            $results | Should -Not -Contain 'C4'
            ($results | Where-Object { $_ -notin @('C1', 'C3') }) | Should -BeNullOrEmpty
        }
    }

    Context 'Determinism' {
        It 'returns an identical band across repeated calls with the same input' {
            # Arrange: a fixed present-signal sequence.
            $signalsPresent = $script:FloorSignals

            # Act: compute the floor repeatedly.
            $results = 1..5 | ForEach-Object { Get-ComplexityFloor -SignalsPresent $signalsPresent }

            # Assert: every call returns the same band.
            ($results | Select-Object -Unique).Count | Should -Be 1
        }

        It 'is independent of input ordering' {
            # Arrange: the same signals in forward and reversed order.
            $forward = $script:FloorSignals
            $reversedOrder = $script:FloorSignals[($script:FloorSignals.Count - 1)..0]

            # Act: compute the floor for both orderings.
            $forwardFloor = Get-ComplexityFloor -SignalsPresent $forward
            $reversedFloor = Get-ComplexityFloor -SignalsPresent $reversedOrder

            # Assert: ordering does not affect the result.
            $forwardFloor | Should -Be $reversedFloor
        }
    }
}
