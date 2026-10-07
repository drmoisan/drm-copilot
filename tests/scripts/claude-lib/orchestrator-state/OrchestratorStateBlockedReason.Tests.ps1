#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Regression tests for the orchestrator-state blocked_reason vocabulary (#523).

.DESCRIPTION
    Covers the PowerShell side of the blocked_reason vocabulary extension:
      - base membership (Get-OrchestratorStateBasePresenceError) accepts the five
        non-mechanical members and rejects case variants case-sensitively;
      - PR-creation readiness (private Get-OrchestratorStatePrCreationReadinessError,
        reached through InModuleScope) blocks each new member and a case variant of
        none;
      - the grouped vocabulary arrays equal the committed partition oracle
        tests/fixtures/orchestrator_state_blocked_reason_partition.json;
      - the unchanged completion check blocks each non-mechanical member with the
        existing message.

    Checkpoints are in-memory objects; the only file read is the committed oracle.
    No file is written and no external process is started.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Discovery-time case lists are consumed by -ForEach')]
param()

# Discovery-time case lists for -ForEach.
$nonMechanicalCase = @(
    @{ Member = 'premise_falsified' },
    @{ Member = 'external_dependency' },
    @{ Member = 'policy_hold' },
    @{ Member = 'awaiting_ci' },
    @{ Member = 'human_decision_required' }
)
$caseVariantCase = @(
    @{ Member = 'PREMISE_FALSIFIED' },
    @{ Member = 'NONE' },
    @{ Member = 'Validator_Failed' }
)
$readinessCase = @($nonMechanicalCase) + @(@{ Member = 'NONE' })

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCompletionChecks.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorState.psm1') -Force

    $oraclePath = (Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/orchestrator_state_blocked_reason_partition.json").Path
    $script:Oracle = Get-Content -LiteralPath $oraclePath -Raw | ConvertFrom-Json -AsHashtable
    $script:CompletionMessage = 'Checkpoint completion validation failed: blocked_reason is not `none`.'
    $script:ReadinessMessage = 'Checkpoint PR-creation readiness validation failed: blocked_reason is not `none`.'

    # Return the values sorted ordinally and joined, so two arrays compare by one
    # case-sensitive string equality.
    function script:Join-SortedOrdinal {
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [string[]] $Value
        )

        $copy = [string[]]$Value.Clone()
        [Array]::Sort($copy, [StringComparer]::Ordinal)
        return ($copy -join ',')
    }
}

Describe 'OrchestratorState blocked_reason base membership' {
    It 'accepts the non-mechanical member <Member>' -ForEach $nonMechanicalCase {
        # Arrange
        $state = [pscustomobject]@{ blocked_reason = $Member }

        # Act
        $errors = @(Get-OrchestratorStateBasePresenceError -State $state | Where-Object { $_ -clike '*blocked_reason*' })

        # Assert
        $errors.Count | Should -Be 0 -Because ($errors -join ' | ')
    }

    It 'rejects the case variant <Member>' -ForEach $caseVariantCase {
        # Arrange
        $state = [pscustomobject]@{ blocked_reason = $Member }

        # Act
        $errors = @(Get-OrchestratorStateBasePresenceError -State $state | Where-Object { $_ -clike '*blocked_reason*' })

        # Assert
        $errors.Count | Should -Be 1 -Because ($errors -join ' | ')
        $errors[0] | Should -BeExactly "Checkpoint has invalid blocked_reason: $Member"
    }
}

Describe 'OrchestratorState blocked_reason PR-creation readiness' {
    It 'blocks readiness for <Member>' -ForEach $readinessCase {
        # Arrange / Act
        $errors = @(InModuleScope OrchestratorState -Parameters @{ Member = $Member } {
                param($Member)
                Get-OrchestratorStatePrCreationReadinessError -State ([pscustomobject]@{ blocked_reason = $Member })
            })

        # Assert
        $errors | Should -Contain $script:ReadinessMessage
    }
}

Describe 'OrchestratorState blocked_reason grouped vocabulary' {
    It 'publishes the mechanical and non-mechanical partitions from the oracle' {
        # Arrange
        $expectedMechanical = Join-SortedOrdinal -Value ([string[]]$script:Oracle['mechanical'])
        $expectedNonMechanical = Join-SortedOrdinal -Value ([string[]]$script:Oracle['non_mechanical'])

        # Act
        $mechanical = @(InModuleScope OrchestratorState { $script:MECHANICAL_BLOCKED_REASONS })
        $nonMechanical = @(InModuleScope OrchestratorState { $script:NON_MECHANICAL_BLOCKED_REASONS })

        # Assert
        (Join-SortedOrdinal -Value ([string[]]$mechanical)) | Should -BeExactly $expectedMechanical
        (Join-SortedOrdinal -Value ([string[]]$nonMechanical)) | Should -BeExactly $expectedNonMechanical
    }

    It 'publishes the vocabulary as none plus both partitions' {
        # Arrange
        $expected = Join-SortedOrdinal -Value ([string[]](@('none') + @($script:Oracle['mechanical']) + @($script:Oracle['non_mechanical'])))

        # Act
        $valid = @(InModuleScope OrchestratorState { $script:VALID_BLOCKED_REASONS })

        # Assert
        $valid.Count | Should -Be 12
        (Join-SortedOrdinal -Value ([string[]]$valid)) | Should -BeExactly $expected
    }
}

Describe 'OrchestratorState blocked_reason completion gate' {
    It 'blocks completion for <Member> with the existing message' -ForEach $nonMechanicalCase {
        # Arrange
        $state = [pscustomobject]@{ blocked_reason = $Member }

        # Act
        $errors = @(Get-OrchestratorStateCompletionBlockedReasonError -State $state)

        # Assert
        $errors.Count | Should -Be 1
        $errors[0] | Should -BeExactly $script:CompletionMessage
    }
}
