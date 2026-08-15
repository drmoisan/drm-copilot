#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Aggregation tests for the U-family unconditional-block entry point.

.DESCRIPTION
    Exercises Get-OrchestratorStateUnconditionalError in
    .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1, the single
    entry point that composes the base-presence checks (U2-U4) with the
    delegation-receipt family (U5) and every key-gated optional family (U6.R,
    U6.H, U6.C, U6.M, U6.X, U6.T).

    Three properties are pinned:
      1. Every composed family's errors surface through the one entry point.
      2. Key-gated semantics hold: an ABSENT optional key contributes zero errors
         and never produces a "must be a list when present" message, while a
         PRESENT key holding null is validated.
      3. A fully valid checkpoint yields zero errors.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port must
    compose the same families with the same key gating.

    Every fixture is an in-memory JSON string. The suite creates no temporary
    files, starts no external process, and never mutates $PSVersionTable or
    $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateUnconditional.psm1') -Force

    function script:Get-CheckpointState {
        param([Parameter(Mandatory = $true)][string] $Json)
        return ($Json | ConvertFrom-Json)
    }

    # A checkpoint carrying every required top-level key with valid values and no
    # optional key at all. It is the zero-error baseline the gating fixtures add
    # one optional key to.
    $script:BaseCheckpointJson = @'
{"objective":"o","change_budget_estimate":"small","path_selected":"remediation","promotion-type":"feature",
 "short-name":"s","relativeFile":"r","long-name":"l","issue-num":"none","feature-folder":"f",
 "work-mode":"full-feature","plan-path":"p","completed_steps":["step1"],"next_step":"complete",
 "last_updated":"t","step5_status":"verified","step6_status":"verified","step7_status":"verified",
 "step8_status":"verified","step9_status":"verified","step10_status":"verified",
 "delegation_receipts":[],"blocked_reason":"none"}
'@

    # Insert one optional key into the base checkpoint without disturbing the rest.
    function script:Get-CheckpointWithOptionalKey {
        param(
            [Parameter(Mandatory = $true)][string] $Key,
            [Parameter(Mandatory = $true)][string] $ValueJson
        )
        $json = $script:BaseCheckpointJson -replace '"blocked_reason":"none"', "`"$Key`":$ValueJson,`"blocked_reason`":`"none`""
        return (Get-CheckpointState -Json $json)
    }
}

Describe 'Unconditional aggregation: fully valid checkpoint' {

    It 'returns zero errors for a checkpoint with every required key and no optional key' {
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $script:BaseCheckpointJson) |
            Should -BeNullOrEmpty
    }
}

Describe 'Unconditional aggregation: base-presence family (U2-U4)' {

    It 'surfaces a missing required key' {
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json '{}') |
            Should -Contain 'Checkpoint missing required key: objective'
    }

    It 'surfaces an invalid step status' {
        $json = $script:BaseCheckpointJson -replace '"step7_status":"verified"', '"step7_status":"bogus"'
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint has invalid step7_status: bogus'
    }

    It 'surfaces an invalid blocked_reason' {
        $json = $script:BaseCheckpointJson -replace '"blocked_reason":"none"', '"blocked_reason":"made_up"'
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint has invalid blocked_reason: made_up'
    }
}

Describe 'Unconditional aggregation: delegation-receipt family (U5)' {

    It 'surfaces a malformed list-form receipt' {
        $json = $script:BaseCheckpointJson -replace '"delegation_receipts":\[\]', '"delegation_receipts":[7]'
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint delegation receipt #0 must be an object.'
    }

    It 'surfaces a delegation_receipts value that is neither list nor object' {
        $json = $script:BaseCheckpointJson -replace '"delegation_receipts":\[\]', '"delegation_receipts":5'
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint delegation_receipts must be a list or object namespace.'
    }

    It 'contributes nothing when delegation_receipts is null, matching the Python guard' {
        $json = $script:BaseCheckpointJson -replace '"delegation_receipts":\[\]', '"delegation_receipts":null'
        Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $json) |
            Should -BeNullOrEmpty
    }
}

Describe 'Unconditional aggregation: each optional family surfaces' {

    It 'surfaces a U6.R remediation-cycle error' {
        $state = Get-CheckpointWithOptionalKey -Key 'remediation_loop' -ValueJson '{"cycles":[{}]}'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint remediation cycle #0 plan_path must be a non-empty string.'
    }

    It 'surfaces a U6.H human-interaction error' {
        $state = Get-CheckpointWithOptionalKey -Key 'human_interaction' -ValueJson '5'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint human_interaction must be an object when present.'
    }

    It 'surfaces a U6.C complexity-assessment error' {
        $state = Get-CheckpointWithOptionalKey -Key 'complexity_assessments' -ValueJson '"x"'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint complexity_assessments must be a list when present.'
    }

    It 'surfaces a U6.M model-routing-receipt error' {
        $state = Get-CheckpointWithOptionalKey -Key 'model_routing_receipts' -ValueJson '"y"'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint model_routing_receipts must be a list when present.'
    }

    It 'surfaces a U6.X codex model-routing-receipt error' {
        $state = Get-CheckpointWithOptionalKey -Key 'codex_model_routing_receipts' -ValueJson '"z"'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint codex_model_routing_receipts must be a list when present.'
    }

    It 'surfaces a U6.T codex topology-receipt error' {
        $state = Get-CheckpointWithOptionalKey -Key 'codex_topology_receipts' -ValueJson '"w"'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint codex_topology_receipts must be a list when present.'
    }

    It 'surfaces errors from several families at once' {
        $json = $script:BaseCheckpointJson -replace '"blocked_reason":"none"',
        '"human_interaction":5,"complexity_assessments":"x","blocked_reason":"none"'
        $errors = @(Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $json))
        $errors | Should -Contain 'Checkpoint human_interaction must be an object when present.'
        $errors | Should -Contain 'Checkpoint complexity_assessments must be a list when present.'
    }
}

Describe 'Unconditional aggregation: key-gated semantics' {

    It 'contributes zero errors for every absent optional key' {
        $errors = @(Get-OrchestratorStateUnconditionalError -State (Get-CheckpointState -Json $script:BaseCheckpointJson))
        ($errors | Where-Object { $_ -like '*must be a list when present*' }) | Should -BeNullOrEmpty
        ($errors | Where-Object { $_ -like '*must be an object when present*' }) | Should -BeNullOrEmpty
    }

    It 'validates a present optional key holding null rather than skipping it' {
        # A present human_interaction key holding null is a malformed block, not an
        # absent one, so it must be reported.
        $state = Get-CheckpointWithOptionalKey -Key 'human_interaction' -ValueJson 'null'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint human_interaction must be an object when present.'
    }

    It 'validates a present complexity_assessments key holding null' {
        $state = Get-CheckpointWithOptionalKey -Key 'complexity_assessments' -ValueJson 'null'
        Get-OrchestratorStateUnconditionalError -State $state |
            Should -Contain 'Checkpoint complexity_assessments must be a list when present.'
    }

    It 'accepts a present optional key holding a well-formed value' {
        $state = Get-CheckpointWithOptionalKey -Key 'complexity_assessments' `
            -ValueJson '[{"phase":"P1","band":"C1","floor":"C1","signals_present":[],"rationale":"r"}]'
        Get-OrchestratorStateUnconditionalError -State $state | Should -BeNullOrEmpty
    }

    It 'contributes zero errors for a remediation_loop that carries no cycles list' {
        $state = Get-CheckpointWithOptionalKey -Key 'remediation_loop' -ValueJson '{"cycles":"x"}'
        Get-OrchestratorStateUnconditionalError -State $state | Should -BeNullOrEmpty
    }
}
