#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the portable OrchestratorState PR-creation-readiness module.

.DESCRIPTION
    Exercises Test-OrchestratorStatePrCreationReadiness in
    .claude/lib/orchestrator-state/OrchestratorState.psm1: the PR-creation-ready
    accept path plus every rejection and fail-closed condition (missing required key,
    a step in pending, a step in blocked, a non-`none` blocked_reason, a non-empty
    override list, a missing checkpoint file, and invalid JSON). The checkpoint
    fixture is built in memory and the filesystem boundary (Test-Path / Get-Content)
    is mocked inside the module scope, so the tests create no temporary files and
    invoke no external process.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture builder and helpers are consumed inside It blocks after dot-sourcing in BeforeAll')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected $Invoker stubs mirror the production scriptblock signature param($Path) for testing')]
param()

BeforeAll {
    # Resolve the module four levels up: orchestrator-state -> claude-lib -> scripts
    # -> tests -> repo root, then into .claude/lib/orchestrator-state.
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorState.psm1").Path
    Import-Module $script:ModulePath -Force
    $script:ModuleName = 'OrchestratorState'

    # Build a PR-creation-ready checkpoint object carrying every required key with
    # steps 5-8 verified, valid steps 9-10, a clear blocked_reason, and no override
    # lists. Individual tests clone this template and mutate one field to exercise a
    # single rejection condition.
    function script:New-ReadyCheckpoint {
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
            step9_status           = 'not-applicable'
            step10_status          = 'not-applicable'
            delegation_receipts    = @()
            blocked_reason         = 'none'
        }
    }

    # Register the in-memory checkpoint JSON as the mocked file content for a test.
    function script:Set-CheckpointFixture {
        param([string] $Json, [bool] $Exists = $true)
        $script:FixtureJson = $Json
        $script:FixtureExists = $Exists
        Mock -ModuleName $script:ModuleName -CommandName Test-Path -MockWith { $script:FixtureExists }
        Mock -ModuleName $script:ModuleName -CommandName Get-Content -MockWith { $script:FixtureJson }
    }
}

Describe 'Test-OrchestratorStatePrCreationReadiness' {
    Context 'PR-creation-ready checkpoint' {
        It 'returns ExitCode 0 and empty Output for a ready checkpoint' {
            # Arrange: a fully ready checkpoint fixture.
            $json = (New-ReadyCheckpoint) | ConvertTo-Json -Depth 5
            Set-CheckpointFixture -Json $json

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 0
            $result.Output | Should -BeNullOrEmpty
        }
    }

    Context 'rejection conditions' {
        It 'returns ExitCode 1 for a missing required key' {
            # Arrange: drop a required top-level key.
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.Remove('objective')
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'missing required key: objective'
        }

        It 'returns ExitCode 1 when a readiness step is pending' {
            # Arrange: mark step5 pending.
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.step5_status = 'pending'
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'step5_status is pending'
        }

        It 'returns ExitCode 1 when a readiness step is blocked' {
            # Arrange: mark step6 blocked.
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.step6_status = 'blocked'
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'step6_status is blocked'
        }

        It 'returns ExitCode 1 when blocked_reason is set to a non-none value' {
            # Arrange: a valid-but-non-none blocked_reason (base check passes, readiness fails).
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.blocked_reason = 'validator_failed'
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'blocked_reason is not'
        }

        It 'returns ExitCode 1 when local_execution_overrides is a non-empty list' {
            # Arrange: record a non-empty override list.
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.local_execution_overrides = @('override-a', 'override-b')
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'local_execution_overrides must be an empty list'
        }

        It 'returns ExitCode 1 with a base error when blocked_reason is outside the allowed vocabulary' {
            # Arrange: a blocked_reason value not in VALID_BLOCKED_REASONS triggers the base check.
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.blocked_reason = 'totally-bogus-reason'
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'invalid blocked_reason'
        }
    }

    Context 'fail-closed conditions' {
        It 'returns ExitCode 1 when the checkpoint file is missing' {
            # Arrange: the file does not exist.
            Set-CheckpointFixture -Json '' -Exists $false

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'missing.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'does not exist'
        }

        It 'returns ExitCode 1 when the checkpoint file exists but is empty' {
            # Arrange: an existing file whose content is whitespace only.
            Set-CheckpointFixture -Json "   `n  "

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'empty.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'is empty'
        }

        It 'returns ExitCode 1 when the checkpoint root is not a JSON object' {
            # Arrange: valid JSON that parses to an array, not an object.
            Set-CheckpointFixture -Json '[1, 2, 3]'

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'array.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'root must be a JSON object'
        }

        It 'returns ExitCode 1 when the checkpoint is not valid JSON' {
            # Arrange: existing file with malformed JSON content.
            Set-CheckpointFixture -Json '{ this is not valid json'

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'bad.json'

            # Assert
            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'not valid JSON'
        }
    }
}

Describe 'Invoke-OrchestratorStatePreflight' {
    <#
    Relocated from tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
    per remediation-plan.2026-07-06T15-01.md (P3-T1/P3-T2): Invoke-OrchestratorStatePreflight and
    Test-PythonOrchestratorValidatorAvailable now live in this module, so tests that mock those
    sibling functions while exercising Invoke-OrchestratorStatePreflight's default $Invoker must use
    -ModuleName OrchestratorState (module-internal, unqualified calls resolve in the module's own
    session state and are invisible to an unqualified Mock issued from outside the module).
    #>
    Context 'Invoke-OrchestratorStatePreflight (direct seam tests)' {
        It 'reports HasErrors when the injected $Invoker returns a non-zero exit code' {
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 1; Output = 'some error' } }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'some error'
        }

        It 'reports no errors when the injected $Invoker returns exit 0' {
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 0; Output = 'orchestrator-state validation passed: x.json' } }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeFalse
        }

        It 'reports HasErrors with empty ErrorText when the injected $Invoker returns a non-zero exit with no output' {
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 1; Output = '' } }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -BeNullOrEmpty
        }

        It 'defaults ExitCode/Output when the injected $Invoker result carries neither property' {
            $stub = { param($Path) [pscustomobject]@{} }
            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json' -Invoker $stub
            $result.HasErrors | Should -BeFalse
            $result.ErrorText | Should -BeNullOrEmpty
        }
    }

    Context 'capability detection (portable-path routing)' {
        BeforeAll {
            # Dot-source the hook so its own decision-path functions (Invoke-PrAuthorSkillDecision,
            # Get-PrContextArtifactExistence) are available to the first test below, which exercises
            # capability-detection routing end-to-end through the hook's call site. The hook's own
            # Import-Module -Force call re-imports this same module, which is idempotent.
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
            . $script:HookPath
        }

        It 'routes to the portable module and blocks a not-ready checkpoint with ORCHESTRATOR_STATE_PREFLIGHT_FAILED when the probe reports unavailable' {
            # The probe reports the Python validator is unavailable, so the default invoker runs the
            # real portable module function (Test-OrchestratorStatePrCreationReadiness, unmocked)
            # against a deliberately-nonexistent, non-temp checkpoint path; the portable module fails
            # closed on the missing file and the hook surfaces ORCHESTRATOR_STATE_PREFLIGHT_FAILED.
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            Mock -ModuleName OrchestratorState -CommandName Test-PythonOrchestratorValidatorAvailable -MockWith { $false }
            $script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'

            $json = '{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
        }

        It 'selects the Python-CLI branch (portable seam not invoked) when the probe reports available' {
            # With the probe reporting available, the default invoker must take the Python branch:
            # the portable seam must not be called. The probe seam is mocked (never python directly);
            # the portable function is mocked only to detect whether it is invoked.
            Mock -ModuleName OrchestratorState -CommandName Test-PythonOrchestratorValidatorAvailable -MockWith { $true }
            Mock -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $null = Invoke-OrchestratorStatePreflight -CheckpointPath 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'

            Should -Invoke -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -Times 0 -Exactly
        }

        It 'allows the preflight to pass when the portable path reports a ready checkpoint' {
            # With the probe reporting unavailable and the portable seam reporting a ready checkpoint
            # (ExitCode 0), the preflight must not block, so PR creation is allowed to proceed to
            # receipt verification.
            Mock -ModuleName OrchestratorState -CommandName Test-PythonOrchestratorValidatorAvailable -MockWith { $false }
            Mock -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json'

            $result.HasErrors | Should -BeFalse
            Should -Invoke -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -Times 1 -Exactly
        }
    }
}

Describe 'Get-OrchestratorStateBasePresenceError per-step-key status vocabulary' {
    <#
    Mirrors the Python per-step-key additive vocabulary in
    scripts/dev_tools/_orchestrator_state_step_status.py: the shared
    VALID_STEP_STATUS set is unchanged, and each extra value is valid only on its
    owning step key. The base-presence function is exercised directly with an
    in-memory parsed checkpoint object, so no filesystem boundary is involved.
    #>
    BeforeAll {
        # Materialize the in-memory fixture as the parsed PSCustomObject shape the
        # base-presence check consumes, applying any per-test field overrides.
        function script:New-CheckpointObject {
            param([hashtable] $Overrides = @{})
            $checkpoint = New-ReadyCheckpoint
            foreach ($name in $Overrides.Keys) { $checkpoint[$name] = $Overrides[$name] }
            return ($checkpoint | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
        }
    }

    Context 'per-key extra statuses accepted on their owning key' {
        It 'accepts step9_status value <_>' -ForEach @(
            'passed',
            'failed_remediation_required',
            'blocked_ci_loop_limit'
        ) {
            # Arrange: an otherwise-valid checkpoint carrying a documented S9 value.
            $state = New-CheckpointObject -Overrides @{ step9_status = $_ }

            # Act
            $errors = @(Get-OrchestratorStateBasePresenceError -State $state)

            # Assert: the documented S9 vocabulary is valid on its owning key.
            $errors | Should -BeNullOrEmpty
        }

        It 'accepts step6_status value blocked_remediation_loop_limit' {
            # Arrange: the documented third-remediation-pass halt value on step6.
            $state = New-CheckpointObject -Overrides @{ step6_status = 'blocked_remediation_loop_limit' }

            # Act
            $errors = @(Get-OrchestratorStateBasePresenceError -State $state)

            # Assert: the value is valid on its owning key.
            $errors | Should -BeNullOrEmpty
        }
    }

    Context 'per-key extra statuses rejected on every non-owning key' {
        It 'rejects <value> on <key>' -ForEach @(
            foreach ($extra in @('passed', 'failed_remediation_required', 'blocked_ci_loop_limit')) {
                foreach ($stepKey in @('step5_status', 'step6_status', 'step7_status', 'step8_status', 'step10_status')) {
                    @{ key = $stepKey; value = $extra }
                }
            }
            foreach ($stepKey in @('step5_status', 'step7_status', 'step8_status', 'step9_status', 'step10_status')) {
                @{ key = $stepKey; value = 'blocked_remediation_loop_limit' }
            }
        ) {
            # Arrange: write an extra value to a step key that does not own it.
            $state = New-CheckpointObject -Overrides @{ $key = $value }

            # Act
            $errors = @(Get-OrchestratorStateBasePresenceError -State $state)

            # Assert: the exact primary-validator message form is emitted.
            $errors | Should -Contain "Checkpoint has invalid ${key}: $value"
        }
    }

    Context 'epic-merge-gate regression scenario' {
        It 'passes base validation for an epic_mode checkpoint recording step9_status passed' {
            # Arrange: the checkpoint shape .claude/hooks/enforce-epic-merge-gate.ps1
            # requires (epic_mode plus step9_status 'passed'), which the validator
            # previously rejected.
            $state = New-CheckpointObject -Overrides @{ epic_mode = $true; step9_status = 'passed' }

            # Act
            $errors = @(Get-OrchestratorStateBasePresenceError -State $state)

            # Assert: no base-presence error is produced.
            $errors | Should -BeNullOrEmpty
        }
    }
}

