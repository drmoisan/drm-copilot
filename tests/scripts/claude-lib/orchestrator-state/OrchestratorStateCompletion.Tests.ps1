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

    # Build a completion-ready checkpoint. As of issue #475 the completion entry
    # point is a COMPLETE-PARITY port, so a checkpoint that reaches ExitCode 0 must
    # now satisfy the whole C family as well: it must name a real routing-matrix
    # route, declare the lists that route requires, evidence every required agent,
    # skill, and MCP tool, carry a passing ci_gate, and keep both override lists
    # present and empty. The remediation route is used because it has the smallest
    # required set and needs no pr_gate. Only this fixture DATA was brought up to
    # the contract; no assertion in this file was changed or weakened.
    #
    # Tests clone this template and mutate one field to exercise a single condition.
    function script:New-CompletionCheckpoint {
        return [ordered]@{
            objective                 = 'deliver portable preflight'
            change_budget_estimate    = 'small'
            path_selected             = 'remediation'
            'promotion-type'          = 'feature'
            'short-name'              = 'portable'
            relativeFile              = 'docs/features/active/portable/issue.md'
            'long-name'               = 'portable orchestrator state preflight'
            'issue-num'               = 'none'
            'feature-folder'          = 'docs/features/active/portable'
            'work-mode'               = 'full-feature'
            'plan-path'               = 'docs/features/active/portable/plan.md'
            completed_steps           = @('step1')
            next_step                 = 'complete'
            last_updated              = '2026-07-06T00-00'
            step5_status              = 'verified'
            step6_status              = 'verified'
            step7_status              = 'verified'
            step8_status              = 'verified'
            step9_status              = 'verified'
            step10_status             = 'verified'
            delegation_receipts       = @(
                (New-DelegationReceipt -AgentName 'atomic-planner'),
                (New-DelegationReceipt -AgentName 'atomic-executor'),
                (New-DelegationReceipt -AgentName 'feature-review')
            )
            model_routing_receipts    = @(
                (New-RoutingReceipt -Agent 'atomic-planner'),
                (New-RoutingReceipt -Agent 'atomic-executor'),
                (New-RoutingReceipt -Agent 'feature-review')
            )
            complexity_assessments    = @(
                @{
                    phase           = 'P1'
                    band            = 'C1'
                    floor           = 'C1'
                    signals_present = @()
                    rationale       = 'routine portable change'
                    assessed_at     = '2026-07-06T00-00'
                }
            )
            required_agents           = @('atomic-planner', 'atomic-executor', 'feature-review')
            required_skills           = @('orchestrate', 'atomic-plan-contract', 'acceptance-criteria-tracking', 'pr-context-artifacts')
            required_mcp_tools        = @('collect_pr_context', 'validate_orchestration_artifacts')
            skill_receipts            = @(
                (New-SkillReceipt -Skill 'orchestrate'),
                (New-SkillReceipt -Skill 'atomic-plan-contract'),
                (New-SkillReceipt -Skill 'acceptance-criteria-tracking'),
                (New-SkillReceipt -Skill 'pr-context-artifacts')
            )
            mcp_call_receipts         = @(
                (New-McpReceipt -Tool 'collect_pr_context'),
                (New-McpReceipt -Tool 'validate_orchestration_artifacts')
            )
            local_execution_overrides = @()
            delegation_bypasses       = @()
            ci_gate                   = @{
                conclusion  = 'success'
                head_sha    = 'abc1234'
                verified_at = '2026-07-06T00-00'
            }
            blocked_reason            = 'none'
        }
    }

    # A delegation receipt carrying all eight keys the U5 rows require.
    function script:New-DelegationReceipt {
        param([Parameter(Mandatory = $true)][string] $AgentName)
        return [ordered]@{
            step           = 'step7'
            agent_name     = $AgentName
            agent_id       = "$AgentName-1"
            skill_source   = 'orchestrate'
            started_at     = '2026-07-06T00-00'
            completed_at   = '2026-07-06T00-01'
            result_signal  = 'complete'
            artifact_paths = @()
        }
    }

    # A model-routing receipt whose model equals Resolve-DelegationModel for a C1
    # band under the available policy, so the U6.M rows pass.
    function script:New-RoutingReceipt {
        param([Parameter(Mandatory = $true)][string] $Agent)
        return [ordered]@{
            agent           = $Agent
            phase           = 'P1'
            complexity_band = 'C1'
            fable_policy    = 'available'
            table_model     = 'haiku'
            clamped_from    = $null
            model           = 'haiku'
        }
    }

    # An acknowledged skill receipt: required is exactly true and evidence is non-blank.
    function script:New-SkillReceipt {
        param([Parameter(Mandatory = $true)][string] $Skill)
        return [ordered]@{ skill = $Skill; required = $true; evidence = 'recorded' }
    }

    # A successful MCP call receipt: ok is exactly true and evidence is non-blank.
    function script:New-McpReceipt {
        param([Parameter(Mandatory = $true)][string] $Tool)
        return [ordered]@{ tool = $Tool; ok = $true; evidence = 'recorded' }
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
            # Arrange: the object namespace form of delegation_receipts. It still
            # evidences every required agent for the routing contract, but the
            # model-routing gate reads only the LIST form as the authoritative
            # record of a delegation, so the gate sees zero delegated agents and
            # imposes no routing-receipt requirement. next_step is non-delegating.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.delegation_receipts = @{
                agents = @(
                    (New-DelegationReceipt -AgentName 'atomic-planner'),
                    (New-DelegationReceipt -AgentName 'atomic-executor'),
                    (New-DelegationReceipt -AgentName 'feature-review')
                )
            }
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

    Context 'M2 complexity-assessment pairing' {
        It 'reports a matched receipt phase that carries no complexity assessment' {
            # Arrange: every routing receipt names phase P1, but the only assessment
            # names a different phase, so the pairing invariant is violated.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.complexity_assessments[0].phase = 'P9'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            @($result.Output -split "`r?`n") |
                Should -Contain 'Checkpoint complexity_assessments is missing an entry for phase P1 referenced by a model_routing_receipts entry.'
        }

        It 'reports a matched receipt phase when the assessments array is absent' {
            # Arrange: no assessments at all, so no matched phase can be paired.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.Remove('complexity_assessments')
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            @($result.Output -split "`r?`n") |
                Should -Contain 'Checkpoint complexity_assessments is missing an entry for phase P1 referenced by a model_routing_receipts entry.'
        }

        It 'does not require an assessment for a receipt that matched no delegated agent' {
            # Arrange: an extra receipt for an agent that was never delegated. Its
            # phase must not force an assessment, because only matched receipts do.
            $checkpoint = New-CompletionCheckpoint
            $unmatched = New-RoutingReceipt -Agent 'task-researcher'
            $unmatched.phase = 'P7'
            $checkpoint.model_routing_receipts = @($checkpoint.model_routing_receipts) + @($unmatched)
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.Output | Should -Not -Match 'missing an entry for phase P7'
        }

        It 'passes when every matched receipt phase carries an assessment' {
            # Arrange: the compliant baseline pairs phase P1 with an assessment.
            Set-CompletionFixture -Json ((New-CompletionCheckpoint) | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.Output | Should -Not -Match 'missing an entry for phase'
        }
    }

    Context 'PD-2 single emission' {
        It 'emits a malformed model_routing_receipts error exactly once' {
            # Arrange: a receipt whose model diverges from the resolved model. The
            # unconditional block and the model-routing gate's M3 leg both validate
            # it, so a duplicating port would emit this string twice.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.model_routing_receipts[1].model = 'opus'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'
            $lines = @($result.Output -split "`r?`n")
            $expected = 'Checkpoint model_routing_receipts #1 model opus does not equal ' +
            'resolve_delegation_model(agent, complexity_band, fable_policy) haiku.'

            # Assert
            $result.ExitCode | Should -Be 1
            @($lines | Where-Object { $_ -eq $expected }).Count | Should -Be 1
        }

        It 'emits a malformed complexity_assessments error exactly once' {
            # Arrange: an assessment whose floor diverges from the recomputed floor.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.complexity_assessments[0].floor = 'C3'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'
            $lines = @($result.Output -split "`r?`n")
            $expected = 'Checkpoint complexity_assessments #0 floor C3 does not equal ' +
            'compute_complexity_floor(signals_present) C1.'

            # Assert
            @($lines | Where-Object { $_ -eq $expected }).Count | Should -Be 1
        }

        It 'emits no duplicate line anywhere in the completion output' {
            # Arrange: a checkpoint that fails several families at once, so any
            # duplicate emission across the composed blocks would surface here.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.model_routing_receipts[0].model = 'opus'
            $checkpoint.complexity_assessments[0].floor = 'C3'
            $checkpoint.step5_status = 'pending'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'
            $lines = @($result.Output -split "`r?`n")

            # Assert
            @($lines | Group-Object | Where-Object { $_.Count -gt 1 }).Count | Should -Be 0
        }
    }

    Context 'M3 reuse of the per-entry validators' {
        It 'invokes the shared model-routing per-entry validator from the gate' {
            # A mocked per-entry validator returning a sentinel string must reach
            # the completion output, proving the gate calls the shared
            # implementation in OrchestratorStateModelReceipts rather than
            # re-implementing the rows.
            Mock -ModuleName 'OrchestratorStateCompletion' -CommandName Get-OrchestratorStateModelRoutingReceiptError `
                -MockWith { return [string[]]@('SENTINEL routing per-entry error') }
            Set-CompletionFixture -Json ((New-CompletionCheckpoint) | ConvertTo-Json -Depth 6)

            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            $result.Output | Should -Match 'SENTINEL routing per-entry error'
            Should -Invoke -ModuleName 'OrchestratorStateCompletion' `
                -CommandName Get-OrchestratorStateModelRoutingReceiptError -Times 1 -Exactly
        }

        It 'invokes the shared complexity per-entry validator from the gate' {
            Mock -ModuleName 'OrchestratorStateCompletion' -CommandName Get-OrchestratorStateComplexityAssessmentError `
                -MockWith { return [string[]]@('SENTINEL complexity per-entry error') }
            Set-CompletionFixture -Json ((New-CompletionCheckpoint) | ConvertTo-Json -Depth 6)

            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            $result.Output | Should -Match 'SENTINEL complexity per-entry error'
            Should -Invoke -ModuleName 'OrchestratorStateCompletion' `
                -CommandName Get-OrchestratorStateComplexityAssessmentError -Times 1 -Exactly
        }
    }

    Context 'complete-parity composition' {
        It 'surfaces a C-family routing-contract failure' {
            # Arrange: a declared list that no longer matches the pinned matrix.
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.required_agents = @('atomic-planner')
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            # Act
            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'required_agents must match routing matrix for route remediation'
        }

        It 'surfaces a C-family ci_gate failure' {
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.ci_gate.conclusion = 'failure'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            $result.Output | Should -Match 'ci_gate.conclusion must be success'
        }

        It 'surfaces a U-family optional-key failure from the unconditional block' {
            $checkpoint = New-CompletionCheckpoint
            $checkpoint['human_interaction'] = @{ requirements = @(@{ response = 'escalate' }) }
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            $result.Output | Should -Match 'response must be one of scope_change, exception, halt; got: escalate'
        }

        It 'surfaces a C-family completion-blocking step status' {
            $checkpoint = New-CompletionCheckpoint
            $checkpoint.step6_status = 'blocked'
            Set-CompletionFixture -Json ($checkpoint | ConvertTo-Json -Depth 6)

            $result = Test-OrchestratorStateCompletionReadiness -CheckpointPath 'x.json'

            $result.Output | Should -Match 'completion validation failed: step6_status is blocked'
        }
    }
}

