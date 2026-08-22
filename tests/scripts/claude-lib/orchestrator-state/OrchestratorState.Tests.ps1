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

        It 'returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit' {
            # Arrange: step6 records a halted remediation loop. The value is plain-valid on
            # step6_status (base validation accepts it) but must still block PR creation, matching
            # validate_orchestrator_state_pr_creation_readiness in the Python reference.
            $checkpoint = New-ReadyCheckpoint
            $checkpoint.step6_status = 'blocked_remediation_loop_limit'
            Set-CheckpointFixture -Json ($checkpoint | ConvertTo-Json -Depth 5)

            # Act
            $result = Test-OrchestratorStatePrCreationReadiness -CheckpointPath 'x.json'

            # Assert: -BeLike, not -Match, so the trailing period is compared literally rather than
            # as a regex wildcard; the message must be byte-identical to the Python gate's string.
            $result.ExitCode | Should -Be 1
            $result.Output | Should -BeLike '*Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.*'
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
    per remediation-plan.2026-07-06T15-01.md (P3-T1/P3-T2): Invoke-OrchestratorStatePreflight lives in
    this module, so tests that mock its sibling functions while exercising the default $Invoker must
    use -ModuleName OrchestratorState (module-internal, unqualified calls resolve in the module's own
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

    Context 'default invoker (portable path is the only path)' {
        <#
        Rewritten for issue #475. The capability-detection probe
        Test-PythonOrchestratorValidatorAvailable has been deleted, so there is no
        probe to mock and no Python-CLI branch to select. A Pester Mock of a removed
        command fails at mock-registration time, so no probe mock may survive here.
        The $false-branch tests become plain default-behavior tests, and the
        $true-branch test that asserted Python-CLI selection is replaced by an
        assertion that the portable path is the default and is actually taken.
        #>
        BeforeAll {
            # Dot-source the hook so its own decision-path functions (Invoke-PrAuthorSkillDecision,
            # Get-PrContextArtifactExistence) are available to the first test below, which exercises
            # the preflight end-to-end through the hook's call site. The hook's own
            # Import-Module -Force call re-imports this same module, which is idempotent.
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
            . $script:HookPath
        }

        It 'blocks a not-ready checkpoint with ORCHESTRATOR_STATE_PREFLIGHT_FAILED through the default path' {
            # The default invoker runs the real portable validation (unmocked) against a
            # deliberately-nonexistent, non-temp checkpoint path; it fails closed on the
            # missing file and the hook surfaces ORCHESTRATOR_STATE_PREFLIGHT_FAILED.
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            $script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'

            $json = '{"tool_name":"Bash","tool_input":{"command":"gh pr create --title \"foo\" --body-file artifacts/pr_body_1.md"}}'
            $decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
        }

        It 'invokes the portable readiness function as the default, with no branch to bypass it' {
            # Replaces the deleted probe-reports-available test. There is exactly one
            # path now, so the portable readiness seam must be invoked on every call
            # whose checkpoint loads. The load boundary is mocked because the collapsed
            # invoker loads the checkpoint to feed the unconditional block, and a
            # fail-closed load would correctly short-circuit before the readiness leg.
            Mock -ModuleName OrchestratorState -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{ Ok = $true; State = ('{}' | ConvertFrom-Json); Error = '' }
            }
            Mock -ModuleName OrchestratorState -CommandName Get-OrchestratorStateUnconditionalError -MockWith { @() }
            Mock -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $null = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json'

            Should -Invoke -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -Times 1 -Exactly
        }

        It 'names no python, python3, py, or poetry command anywhere in the default invoker' {
            # Negative-invocation AST assertion over the collapsed default $Invoker: the
            # seam's default value must contain no interpreter CommandAst on any code
            # path. Each CommandAst is classified by its resolved command name, so an
            # interpreter name in a comment or string neither satisfies nor defeats it.
            $invokerDefault = (Get-Command -Name Invoke-OrchestratorStatePreflight).Parameters['Invoker'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } | Select-Object -First 1
            $invokerDefault | Should -Not -BeNullOrEmpty -Because 'the [scriptblock] $Invoker seam must be retained'

            $functionAst = (Get-Command -Name Invoke-OrchestratorStatePreflight).ScriptBlock.Ast
            $commandAsts = @($functionAst.FindAll(
                    { param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            $bannedNames = @('python', 'python3', 'py', 'poetry')
            $invokedNames = @(
                $commandAsts |
                    ForEach-Object { $_.GetCommandName() } |
                        Where-Object { $_ } |
                            ForEach-Object { $_.ToLowerInvariant() }
            )
            $violations = @($invokedNames | Where-Object { $bannedNames -contains $_ })

            $violations | Should -BeNullOrEmpty -Because (
                'the preflight default invoker must name no interpreter; found: ' + ($violations -join ', '))
        }

        It 'allows the preflight to pass when both portable legs report a ready checkpoint' {
            # Both legs clean (unconditional block empty, readiness ExitCode 0), so the
            # preflight must not block and PR creation proceeds to receipt verification.
            Mock -ModuleName OrchestratorState -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{ Ok = $true; State = ('{}' | ConvertFrom-Json); Error = '' }
            }
            Mock -ModuleName OrchestratorState -CommandName Get-OrchestratorStateUnconditionalError -MockWith { @() }
            Mock -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json'

            $result.HasErrors | Should -BeFalse
            Should -Invoke -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -Times 1 -Exactly
        }

        It 'fails the preflight for a checkpoint carrying a U-family violation' {
            # The collapsed default invoker now runs the ported unconditional block before
            # the readiness gate, so a malformed delegation_receipts entry (U5) fails the
            # preflight even though the readiness gate alone would not report it. The
            # readiness seam is stubbed clean so the U-family leg is the sole cause.
            Mock -ModuleName OrchestratorState -CommandName Test-OrchestratorStatePrCreationReadiness -MockWith { @{ ExitCode = 0; Output = '' } }
            Mock -ModuleName OrchestratorState -CommandName Get-OrchestratorStateCheckpoint -MockWith {
                @{
                    Ok    = $true
                    State = ('{"delegation_receipts":[{"agent_name":"atomic-executor"}]}' | ConvertFrom-Json)
                    Error = ''
                }
            }

            $result = Invoke-OrchestratorStatePreflight -CheckpointPath 'x.json'

            $result.HasErrors | Should -BeTrue
            $result.ErrorText | Should -Match 'delegation receipt #0 missing key'
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

