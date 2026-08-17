#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the portable C1, C2, C3, C4, C5, and C7 completion checks.

.DESCRIPTION
    Exercises every inventory row implemented by
    .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 against
    the exact error-string templates recorded in the issue #475 parity inventory:
    C1.1, C2.1, C3.1-C3.2, C4.1-C4.4, C5.1, and C7.1-C7.2. Each row has at least
    one failing fixture asserting the exact string, and each family has a passing
    fixture.

    Route gating is covered in both directions: fixtures prove C3 fires only for a
    route whose pinned requires_pr_gate is true, and that C4 fires unless a route
    pins requires_ci_gate to false. That asymmetry is the Python reference's
    behavior and is asserted rather than assumed.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of these
    checks must reproduce every assertion below verbatim, including the backtick
    quoting in the C2 message and the Python repr() rendering in C7.

    Every fixture is an in-memory JSON string. The suite creates no temporary
    files, starts no external process, and never mutates $PSVersionTable or
    $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helper is consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCompletionChecks.psm1') -Force

    function script:Get-CheckpointState {
        param([Parameter(Mandatory = $true)][string] $Json)
        return ($Json | ConvertFrom-Json)
    }

    # A pr_gate and ci_gate pair that satisfies every field rule and matches on
    # head_sha, used by the passing fixtures.
    $script:ValidPrGate = '"pr_gate":{"pr_number":7,"pr_url":"https://x/7","head_branch":"b","head_sha":"abc"}'
    $script:ValidCiGate = '"ci_gate":{"conclusion":"success","head_sha":"abc","verified_at":"2026-08-15T00:00:00Z"}'
}

Describe 'C1 completion-blocking step statuses' {

    It 'passes a checkpoint whose step statuses are all non-blocking' {
        $state = Get-CheckpointState -Json '{"step5_status":"verified","step6_status":"completed","step9_status":"passed"}'
        Get-OrchestratorStateCompletionStepStatusError -State $state | Should -BeNullOrEmpty
    }

    It 'C1.1 reports a pending step status' {
        Get-OrchestratorStateCompletionStepStatusError -State (Get-CheckpointState -Json '{"step5_status":"pending"}') |
            Should -Contain 'Checkpoint completion validation failed: step5_status is pending.'
    }

    It 'C1.1 reports every value in the five-value blocking set' {
        $state = Get-CheckpointState -Json ('{"step5_status":"pending","step6_status":"blocked",' +
            '"step7_status":"failed_remediation_required","step8_status":"blocked_ci_loop_limit",' +
            '"step9_status":"blocked_remediation_loop_limit"}')
        $errors = @(Get-OrchestratorStateCompletionStepStatusError -State $state)
        $errors.Count | Should -Be 5
        $errors | Should -Contain 'Checkpoint completion validation failed: step6_status is blocked.'
        $errors | Should -Contain 'Checkpoint completion validation failed: step7_status is failed_remediation_required.'
        $errors | Should -Contain 'Checkpoint completion validation failed: step8_status is blocked_ci_loop_limit.'
        $errors | Should -Contain 'Checkpoint completion validation failed: step9_status is blocked_remediation_loop_limit.'
    }

    It 'C1.1 does not block on the documented S9 success value passed' {
        Get-OrchestratorStateCompletionStepStatusError -State (Get-CheckpointState -Json '{"step9_status":"passed"}') |
            Should -BeNullOrEmpty
    }

    It 'C1.1 reports in step-key order' {
        $state = Get-CheckpointState -Json '{"step10_status":"blocked","step5_status":"pending"}'
        $errors = @(Get-OrchestratorStateCompletionStepStatusError -State $state)
        $errors[0] | Should -Be 'Checkpoint completion validation failed: step5_status is pending.'
        $errors[1] | Should -Be 'Checkpoint completion validation failed: step10_status is blocked.'
    }
}

Describe 'C2 completion blocked_reason' {

    It 'passes an absent blocked_reason' {
        Get-OrchestratorStateCompletionBlockedReasonError -State (Get-CheckpointState -Json '{}') |
            Should -BeNullOrEmpty
    }

    It 'passes a null blocked_reason' {
        Get-OrchestratorStateCompletionBlockedReasonError -State (Get-CheckpointState -Json '{"blocked_reason":null}') |
            Should -BeNullOrEmpty
    }

    It 'passes the literal none' {
        Get-OrchestratorStateCompletionBlockedReasonError -State (Get-CheckpointState -Json '{"blocked_reason":"none"}') |
            Should -BeNullOrEmpty
    }

    It 'C2.1 reports any other blocked_reason, quoting none with backticks' {
        Get-OrchestratorStateCompletionBlockedReasonError -State (Get-CheckpointState -Json '{"blocked_reason":"validator_failed"}') |
            Should -Contain 'Checkpoint completion validation failed: blocked_reason is not `none`.'
    }
}

Describe 'C3 completion pr_gate' {

    It 'passes a complete pr_gate on a route that requires it' {
        $state = Get-CheckpointState -Json "{`"route_id`":`"large`",$script:ValidPrGate}"
        Get-OrchestratorStateCompletionPrGateError -State $state | Should -BeNullOrEmpty
    }

    It 'C3.1 reports an absent pr_gate on a gated route' {
        Get-OrchestratorStateCompletionPrGateError -State (Get-CheckpointState -Json '{"route_id":"large"}') |
            Should -Contain 'Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.'
    }

    It 'C3.1 reports a non-object pr_gate and does not additionally list fields' {
        $errors = @(Get-OrchestratorStateCompletionPrGateError -State (Get-CheckpointState -Json '{"route_id":"large","pr_gate":"x"}'))
        $errors.Count | Should -Be 1
        $errors[0] | Should -Be 'Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.'
    }

    It 'C3.2 names each absent or blank pr_gate field' {
        $state = Get-CheckpointState -Json '{"route_id":"large","pr_gate":{"pr_number":1,"pr_url":"u","head_branch":"  ","head_sha":null}}'
        Get-OrchestratorStateCompletionPrGateError -State $state |
            Should -Contain 'Checkpoint completion validation failed: pr_gate missing required fields: head_branch, head_sha.'
    }

    It 'route gate off: contributes nothing on a route whose flag is absent' {
        Get-OrchestratorStateCompletionPrGateError -State (Get-CheckpointState -Json '{"route_id":"small"}') |
            Should -BeNullOrEmpty
    }

    It 'route gate off: contributes nothing on a route whose flag is false' {
        Get-OrchestratorStateCompletionPrGateError -State (Get-CheckpointState -Json '{"route_id":"parallel"}') |
            Should -BeNullOrEmpty
    }

    It 'route gate off: contributes nothing when no route is selected' {
        Get-OrchestratorStateCompletionPrGateError -State (Get-CheckpointState -Json '{}') |
            Should -BeNullOrEmpty
    }
}

Describe 'C4 completion ci_gate' {

    It 'passes a complete ci_gate whose head_sha matches pr_gate' {
        $state = Get-CheckpointState -Json "{`"route_id`":`"small`",$script:ValidPrGate,$script:ValidCiGate}"
        Get-OrchestratorStateCompletionCiGateError -State $state | Should -BeNullOrEmpty
    }

    It 'passes a complete ci_gate when no pr_gate head_sha exists to match' {
        $state = Get-CheckpointState -Json "{`"route_id`":`"small`",$script:ValidCiGate}"
        Get-OrchestratorStateCompletionCiGateError -State $state | Should -BeNullOrEmpty
    }

    It 'C4.1 reports an absent ci_gate on a gated route' {
        Get-OrchestratorStateCompletionCiGateError -State (Get-CheckpointState -Json '{"route_id":"small"}') |
            Should -Contain 'Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.'
    }

    It 'C4.1 reports a non-object ci_gate and stops there' {
        $errors = @(Get-OrchestratorStateCompletionCiGateError -State (Get-CheckpointState -Json '{"route_id":"small","ci_gate":[1]}'))
        $errors.Count | Should -Be 1
    }

    It 'C4.2 names each absent or blank ci_gate field' {
        $state = Get-CheckpointState -Json '{"route_id":"small","ci_gate":{"conclusion":"success","head_sha":"abc","verified_at":"  "}}'
        Get-OrchestratorStateCompletionCiGateError -State $state |
            Should -Contain 'Checkpoint completion validation failed: ci_gate missing required fields: verified_at.'
    }

    It 'C4.3 reports a conclusion other than success' {
        $state = Get-CheckpointState -Json '{"route_id":"small","ci_gate":{"conclusion":"failure","head_sha":"abc","verified_at":"t"}}'
        Get-OrchestratorStateCompletionCiGateError -State $state |
            Should -Contain 'Checkpoint completion validation failed: ci_gate.conclusion must be success.'
    }

    It 'C4.4 reports a ci_gate head_sha that does not match pr_gate' {
        $state = Get-CheckpointState -Json ('{"route_id":"small","pr_gate":{"head_sha":"aaa"},' +
            '"ci_gate":{"conclusion":"success","head_sha":"bbb","verified_at":"t"}}')
        Get-OrchestratorStateCompletionCiGateError -State $state |
            Should -Contain 'Checkpoint completion validation failed: ci_gate.head_sha must match pr_gate.head_sha.'
    }

    It 'C4.4 does not fire when pr_gate head_sha is null' {
        $state = Get-CheckpointState -Json ('{"route_id":"small","pr_gate":{"head_sha":null},' +
            '"ci_gate":{"conclusion":"success","head_sha":"bbb","verified_at":"t"}}')
        Get-OrchestratorStateCompletionCiGateError -State $state | Should -BeNullOrEmpty
    }

    It 'route gate on by default: fires for a route whose flag is absent' {
        @(Get-OrchestratorStateCompletionCiGateError -State (Get-CheckpointState -Json '{"route_id":"small"}')).Count |
            Should -BeGreaterThan 0
    }

    It 'route gate on by default: fires when no route is selected' {
        @(Get-OrchestratorStateCompletionCiGateError -State (Get-CheckpointState -Json '{}')).Count |
            Should -BeGreaterThan 0
    }

    It 'route gate off: contributes nothing on a route whose flag is exactly false' {
        Get-OrchestratorStateCompletionCiGateError -State (Get-CheckpointState -Json '{"route_id":"preparation"}') |
            Should -BeNullOrEmpty
    }
}

Describe 'C5 mandatory route phases' {

    It 'passes a small route recording both mandatory phases' {
        $state = Get-CheckpointState -Json '{"route_id":"small","completed_steps":["S3_promotion","S4_atomic_planning"]}'
        Get-OrchestratorStatePhaseCompletenessError -State $state | Should -BeNullOrEmpty
    }

    It 'C5.1 reports a missing mandatory phase, naming the route and the phase' {
        $state = Get-CheckpointState -Json '{"route_id":"small","completed_steps":["S3_promotion"]}'
        Get-OrchestratorStatePhaseCompletenessError -State $state |
            Should -Contain 'Checkpoint completion validation failed: route small is missing mandatory phase S4_atomic_planning.'
    }

    It 'C5.1 reports both mandatory phases for the preparation route' {
        $state = Get-CheckpointState -Json '{"route_id":"preparation","completed_steps":[]}'
        $errors = @(Get-OrchestratorStatePhaseCompletenessError -State $state)
        $errors.Count | Should -Be 2
        $errors | Should -Contain 'Checkpoint completion validation failed: route preparation is missing mandatory phase S3_promotion.'
    }

    It 'C5.1 treats a malformed completed_steps as recording no phases' {
        $state = Get-CheckpointState -Json '{"route_id":"small","completed_steps":"S3_promotion"}'
        @(Get-OrchestratorStatePhaseCompletenessError -State $state).Count | Should -Be 2
    }

    It 'imposes no requirement on a route absent from the static map' {
        $state = Get-CheckpointState -Json '{"route_id":"large","completed_steps":[]}'
        Get-OrchestratorStatePhaseCompletenessError -State $state | Should -BeNullOrEmpty
    }

    It 'imposes no requirement when no route is selected' {
        Get-OrchestratorStatePhaseCompletenessError -State (Get-CheckpointState -Json '{"completed_steps":[]}') |
            Should -BeNullOrEmpty
    }
}

Describe 'C7 preparation terminal contract' {

    It 'passes a compliant preparation checkpoint' {
        $state = Get-CheckpointState -Json ('{"route_id":"preparation","next_step":"S5_atomic_execution",' +
            '"step5_status":"not-applicable","step6_status":"not-applicable","step7_status":"not-applicable",' +
            '"step8_status":"not-applicable","step9_status":"not-applicable","step10_status":"not-applicable"}')
        Get-OrchestratorStatePreparationTerminalError -State $state | Should -BeNullOrEmpty
    }

    It 'C7.1 reports a wrong next_step with repr() rendering on both sides' {
        $state = Get-CheckpointState -Json '{"route_id":"preparation","next_step":"complete"}'
        Get-OrchestratorStatePreparationTerminalError -State $state |
            Should -Contain "Preparation checkpoint next_step must be 'S5_atomic_execution', found 'complete'."
    }

    It 'C7.1 renders an absent next_step as None' {
        $state = Get-CheckpointState -Json '{"route_id":"preparation"}'
        Get-OrchestratorStatePreparationTerminalError -State $state |
            Should -Contain "Preparation checkpoint next_step must be 'S5_atomic_execution', found None."
    }

    It 'C7.2 reports a step status other than not-applicable with repr() rendering' {
        $state = Get-CheckpointState -Json '{"route_id":"preparation","next_step":"S5_atomic_execution","step5_status":"verified"}'
        Get-OrchestratorStatePreparationTerminalError -State $state |
            Should -Contain "Preparation checkpoint step5_status must be 'not-applicable', found 'verified'."
    }

    It 'C7.2 reports all six step keys when every one is absent' {
        $state = Get-CheckpointState -Json '{"route_id":"preparation","next_step":"S5_atomic_execution"}'
        $errors = @(Get-OrchestratorStatePreparationTerminalError -State $state)
        $errors.Count | Should -Be 6
        $errors | Should -Contain "Preparation checkpoint step10_status must be 'not-applicable', found None."
    }

    It 'contributes nothing on a route other than preparation' {
        $state = Get-CheckpointState -Json '{"route_id":"small","next_step":"complete"}'
        Get-OrchestratorStatePreparationTerminalError -State $state | Should -BeNullOrEmpty
    }

    It 'gates on the raw route value, so a present null route_id does not fall back' {
        $state = Get-CheckpointState -Json '{"route_id":null,"path_selected":"preparation","next_step":"complete"}'
        Get-OrchestratorStatePreparationTerminalError -State $state | Should -BeNullOrEmpty
    }

    It 'gates on path_selected when the route_id key is absent' {
        $state = Get-CheckpointState -Json '{"path_selected":"preparation","next_step":"complete"}'
        Get-OrchestratorStatePreparationTerminalError -State $state |
            Should -Contain "Preparation checkpoint next_step must be 'S5_atomic_execution', found 'complete'."
    }
}
