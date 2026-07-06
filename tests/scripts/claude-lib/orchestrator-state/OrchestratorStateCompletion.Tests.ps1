#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the portable OrchestratorStateCompletion presence gate.

.DESCRIPTION
    Exercises Test-OrchestratorStateCompletionReadiness in
    .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1: a checkpoint
    whose delegated-agent set is fully covered by model_routing_receipts[].agent
    passes; an uncovered delegated agent fails with a model_routing_receipts message;
    and the fail-closed conditions (missing checkpoint file, invalid JSON, invalid
    step status) each fail. The checkpoint fixture is built in memory and the
    filesystem boundary (Test-Path / Get-Content) is mocked inside the shared
    OrchestratorState module scope, so the tests create no temporary files and invoke
    no external process.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture builder and helpers are consumed inside It blocks after dot-sourcing in BeforeAll')]
param()

BeforeAll {
    # Resolve both modules four levels up: orchestrator-state -> claude-lib ->
    # scripts -> tests -> repo root. The completion module imports the shared module
    # itself; both are imported here so the shared module's filesystem boundary can
    # be mocked by name.
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorState.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateCompletion.psm1') -Force

    # The shared load helper (Get-OrchestratorStateCheckpoint) lives in the
    # OrchestratorState module, so its Test-Path / Get-Content calls are mocked in
    # that module's scope.
    $script:SharedModuleName = 'OrchestratorState'

    # Build a completion-ready checkpoint carrying every required key, a single
    # delegation of atomic-executor, and a matching model-routing receipt. Tests
    # clone this template and mutate one field to exercise a single condition.
    function script:New-CompletionCheckpoint {
        return [ordered]@{
            objective              = 'deliver portable preflight'
            change_budget_estimate = 'small'
            path_selected          = 'short'
            'promotion-type'       = 'feature'
            'short-name'           = 'portable'
            relativeFile           = 'docs/features/active/portable/issue.md'
            'long-name'            = 'portable orchestrator state preflight'
            'issue-num'            = 'none'
            'feature-folder'       = 'docs/features/active/portable'
            'work-mode'            = 'full-feature'
            'plan-path'            = 'docs/features/active/portable/plan.md'
            completed_steps        = @('step1')
            next_step              = 'complete'
            last_updated           = '2026-07-06T00-00'
            step5_status           = 'verified'
            step6_status           = 'verified'
            step7_status           = 'verified'
            step8_status           = 'verified'
            step9_status           = 'verified'
            step10_status          = 'verified'
            delegation_receipts    = @(@{ agent_name = 'atomic-executor'; step = 'step7' })
            model_routing_receipts = @(@{ agent = 'atomic-executor'; phase = 'P1' })
            blocked_reason         = 'none'
        }
    }

    # Register the in-memory checkpoint JSON as the mocked file content for a test.
    function script:Set-CompletionFixture {
        param([string] $Json, [bool] $Exists = $true)
        $script:FixtureJson = $Json
        $script:FixtureExists = $Exists
        Mock -ModuleName $script:SharedModuleName -CommandName Test-Path -MockWith { $script:FixtureExists }
        Mock -ModuleName $script:SharedModuleName -CommandName Get-Content -MockWith { $script:FixtureJson }
    }
}

Describe 'Test-OrchestratorStateCompletionReadiness' {
    Context 'model-routing existence gate' {
        It 'returns ExitCode 0 when every delegated agent has a routing receipt' {
            # Arrange: delegated atomic-executor is covered by a matching receipt.
            $json = (New-CompletionCheckpoint) | ConvertTo-Json -Depth 6
            Set-CompletionFixture -Json $json

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeNullOrEmpty
        }

        It 'returns ExitCode 1 with a model_routing_receipts message for an uncovered delegated agent' {
            # Arrange: a delegation with no matching routing receipt.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.model_routing_receipts = @()
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'model_routing_receipts'
            $result.Output | Should -Match 'atomic-executor'
        }

        It 'treats a delegating next_step as a delegated agent requiring a receipt' {
            # Arrange: no delegation receipts, but next_step names a delegating agent
            # with no routing receipt, so the gate must fire on the next_step agent.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.delegation_receipts = @()
            $checkpoint.model_routing_receipts = @()
            $checkpoint.next_step = 'atomic-planner'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'model_routing_receipts'
            $result.Output | Should -Match 'atomic-planner'
        }

        It 'returns ExitCode 0 for a delegation-free checkpoint (gate imposes no requirement)' {
            # Arrange: no delegation receipts and a non-delegating next_step, so the
            # existence gate does not fire even without any routing receipts.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.delegation_receipts = @()
            $checkpoint.model_routing_receipts = @()
            $checkpoint.next_step = 'complete'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeNullOrEmpty
        }
    }

    Context 'fail-closed conditions' {
        It 'returns ExitCode 1 when the checkpoint file is missing' {
            # Arrange: the file does not exist.
            Set-CompletionFixture -Json '' -Exists $false

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'missing.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'does not exist'
        }

        It 'returns ExitCode 1 when the checkpoint is not valid JSON' {
            # Arrange: existing file with malformed JSON content.
            Set-CompletionFixture -Json '{ this is not valid json'

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'bad.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'not valid JSON'
        }

        It 'returns ExitCode 1 for an invalid step status' {
            # Arrange: a step status outside the allowed vocabulary.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.step7_status = 'bogus-status'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'invalid step7_status'
        }
    }
}

