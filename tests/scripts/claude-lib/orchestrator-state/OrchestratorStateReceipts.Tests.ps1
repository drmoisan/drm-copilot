#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the portable U5, U6.R, and U6.H orchestrator-state checks.

.DESCRIPTION
    Exercises every inventory row implemented by
    .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 against the exact
    error-string templates recorded in the issue #475 parity inventory
    (research/2026-08-15T15-30-full-parity-check-inventory-and-bash-json-research.md):
    U5.1-U5.8 (delegation_receipts shape), U6.R1-U6.R4 (remediation_loop cycles),
    and U6.H1-U6.H5 (human_interaction). Each row has at least one failing fixture
    asserting the exact string, and each family has a passing fixture.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of these
    checks must reproduce every assertion below verbatim, so assertions pin exact
    error text rather than substrings or counts.

    Every fixture is an in-memory JSON string parsed with ConvertFrom-Json. The
    suite creates no temporary files, mutates no environment state, starts no
    external process, and never mutates $PSVersionTable or $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helper is consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    # Resolve the module four levels up: orchestrator-state -> claude-lib ->
    # scripts -> tests -> repo root. Resolution is anchored to $PSScriptRoot so the
    # suite is independent of the caller's working directory.
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCheckpointValue.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateReceipts.psm1') -Force

    # Parse an in-memory JSON document so fixtures exercise the same deserialized
    # value space the hook sees at runtime (PSCustomObject, Object[], typed
    # scalars). -NoEnumerate keeps a root array an array, and the unary comma stops
    # PowerShell from unrolling that array again on function return, so the caller
    # receives the same value a checkpoint property access yields at runtime.
    function script:ConvertFrom-FixtureJson {
        param([Parameter(Mandatory = $true)][string] $Json)
        return , (ConvertFrom-Json -InputObject $Json -NoEnumerate)
    }

    # A single fully-valid list-form delegation receipt, reused by the passing
    # fixtures and cloned textually by the failing ones.
    $script:ValidReceiptJson = @'
{"step":"S5","agent_name":"atomic-executor","agent_id":"a1","skill_source":"skill",
"started_at":"2026-08-15T00:00:00Z","completed_at":"2026-08-15T01:00:00Z",
"result_signal":"complete","artifact_paths":["docs/x.md"]}
'@
}

Describe 'OrchestratorStateReceipts delegation_receipts checks (U5)' {

    It 'contributes no error when delegation_receipts is null (absent-key parity)' {
        Get-OrchestratorStateDelegationReceiptError -Value $null | Should -BeNullOrEmpty
    }

    It 'passes a well-formed list-form receipt (U5 passing fixture)' {
        $value = ConvertFrom-FixtureJson -Json "[$script:ValidReceiptJson]"
        Get-OrchestratorStateDelegationReceiptError -Value $value | Should -BeNullOrEmpty
    }

    It 'passes a well-formed object-form namespace (U5 passing fixture)' {
        $json = '{"agents":[' + $script:ValidReceiptJson + '],"promotion":{"issue":{"n":1}}}'
        Get-OrchestratorStateDelegationReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'U5.1 reports a non-object list entry' {
        $value = ConvertFrom-FixtureJson -Json '["not-an-object"]'
        Get-OrchestratorStateDelegationReceiptError -Value $value |
            Should -Contain 'Checkpoint delegation receipt #0 must be an object.'
    }

    It 'U5.2 reports each missing receipt key by name' {
        $value = ConvertFrom-FixtureJson -Json '[{"step":"S5"}]'
        $errors = @(Get-OrchestratorStateDelegationReceiptError -Value $value)
        $errors | Should -Contain 'Checkpoint delegation receipt #0 missing key: agent_name'
        $errors | Should -Contain 'Checkpoint delegation receipt #0 missing key: artifact_paths'
        $errors.Count | Should -Be 7
    }

    It 'U5.2 treats a present null key as satisfied (presence, not truthiness)' {
        $json = '[{"step":null,"agent_name":null,"agent_id":null,"skill_source":null,' +
        '"started_at":null,"completed_at":null,"result_signal":null,"artifact_paths":null}]'
        Get-OrchestratorStateDelegationReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'U5.3 reports a non-list artifact_paths' {
        $json = $script:ValidReceiptJson -replace '\["docs/x.md"\]', '"docs/x.md"'
        Get-OrchestratorStateDelegationReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint delegation receipt #0 artifact_paths must be a list.'
    }

    It 'U5.4 reports an unsupported object-form namespace key' {
        $value = ConvertFrom-FixtureJson -Json '{"bogus":1}'
        Get-OrchestratorStateDelegationReceiptError -Value $value |
            Should -Contain 'Checkpoint delegation_receipts object contains unsupported key: bogus'
    }

    It 'U5.4 orders unsupported keys ordinally, matching Python sorted()' {
        $value = ConvertFrom-FixtureJson -Json '{"weird":1,"Alpha":2}'
        $errors = @(Get-OrchestratorStateDelegationReceiptError -Value $value)
        $errors[0] | Should -Be 'Checkpoint delegation_receipts object contains unsupported key: Alpha'
        $errors[1] | Should -Be 'Checkpoint delegation_receipts object contains unsupported key: weird'
    }

    It 'U5.5 reports a non-list agents namespace' {
        $value = ConvertFrom-FixtureJson -Json '{"agents":"x"}'
        Get-OrchestratorStateDelegationReceiptError -Value $value |
            Should -Contain 'Checkpoint delegation_receipts.agents must be a list.'
    }

    It 'U5.5 applies the list-form rows to a well-formed agents namespace' {
        $value = ConvertFrom-FixtureJson -Json '{"agents":[42]}'
        Get-OrchestratorStateDelegationReceiptError -Value $value |
            Should -Contain 'Checkpoint delegation receipt #0 must be an object.'
    }

    It 'U5.6 reports a non-object promotion namespace' {
        $value = ConvertFrom-FixtureJson -Json '{"promotion":[1]}'
        Get-OrchestratorStateDelegationReceiptError -Value $value |
            Should -Contain 'Checkpoint delegation_receipts.promotion must be an object namespace.'
    }

    It 'U5.6 treats a null promotion namespace as absent' {
        Get-OrchestratorStateDelegationReceiptError -Value (ConvertFrom-FixtureJson -Json '{"promotion":null}') |
            Should -BeNullOrEmpty
    }

    It 'U5.7 reports an unsupported promotion sub-key' {
        $value = ConvertFrom-FixtureJson -Json '{"promotion":{"bogus":1}}'
        Get-OrchestratorStateDelegationReceiptError -Value $value |
            Should -Contain 'Checkpoint delegation_receipts.promotion contains unsupported key: bogus'
    }

    It 'U5.8 reports a delegation_receipts value that is neither list nor object' {
        Get-OrchestratorStateDelegationReceiptError -Value 5 |
            Should -Contain 'Checkpoint delegation_receipts must be a list or object namespace.'
    }
}

Describe 'OrchestratorStateReceipts remediation_loop checks (U6.R)' {

    It 'passes a well-formed cycle (U6.R passing fixture)' {
        $json = '{"cycles":[{"plan_path":"docs/plan.md","execution_status":"complete",' +
        '"preflight":{"final_status":"clear"},"exit_condition_met":true,"blocking_count":0}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'contributes zero errors for a non-object remediation_loop (Python tolerance)' {
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json '[1,2]') |
            Should -BeNullOrEmpty
    }

    It 'contributes zero errors for a non-list cycles value (Python tolerance)' {
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json '{"cycles":"x"}') |
            Should -BeNullOrEmpty
    }

    It 'U6.R1 reports a non-object cycle' {
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json '{"cycles":[7]}') |
            Should -Contain 'Checkpoint remediation cycle #0 must be an object.'
    }

    It 'U6.R2 reports a missing plan_path' {
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json '{"cycles":[{}]}') |
            Should -Contain 'Checkpoint remediation cycle #0 plan_path must be a non-empty string.'
    }

    It 'U6.R2 reports a whitespace-only plan_path' {
        $value = ConvertFrom-FixtureJson -Json '{"cycles":[{"plan_path":"   "}]}'
        Get-OrchestratorStateRemediationLoopError -Value $value |
            Should -Contain 'Checkpoint remediation cycle #0 plan_path must be a non-empty string.'
    }

    It 'U6.R3 reports execution recorded before preflight cleared' {
        $json = '{"cycles":[{"plan_path":"p","execution_status":"in_progress",' +
        '"preflight":{"final_status":"revisions"}}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain "Checkpoint remediation cycle #0 execution_status is in_progress but preflight.final_status is not 'clear'."
    }

    It 'U6.R3 treats a missing preflight object as not cleared' {
        $json = '{"cycles":[{"plan_path":"p","execution_status":"failed"}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain "Checkpoint remediation cycle #0 execution_status is failed but preflight.final_status is not 'clear'."
    }

    It 'U6.R3 does not fire for an execution_status outside the blocked set' {
        $json = '{"cycles":[{"plan_path":"p","execution_status":"not_started"}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'U6.R4 reports a satisfied exit gate with non-zero blocking_count' {
        $json = '{"cycles":[{"plan_path":"p","exit_condition_met":true,"blocking_count":3}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint remediation cycle #0 exit_condition_met is true but blocking_count is not 0.'
    }

    It 'U6.R4 reports a satisfied exit gate with an absent blocking_count' {
        $json = '{"cycles":[{"plan_path":"p","exit_condition_met":true}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint remediation cycle #0 exit_condition_met is true but blocking_count is not 0.'
    }

    It 'U6.R4 does not fire when exit_condition_met is merely truthy, not boolean true' {
        $json = '{"cycles":[{"plan_path":"p","exit_condition_met":1,"blocking_count":3}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'reports each malformed cycle with its own index' {
        $json = '{"cycles":[{"plan_path":"p"},{}]}'
        Get-OrchestratorStateRemediationLoopError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint remediation cycle #1 plan_path must be a non-empty string.'
    }
}

Describe 'OrchestratorStateReceipts human_interaction checks (U6.H)' {

    It 'passes a well-formed human_interaction block (U6.H passing fixture)' {
        $json = '{"requirements":[{"response":"scope_change"},' +
        '{"response":"exception","runbook_path":"docs/runbook.md"},{"response":"halt"}]}'
        Get-OrchestratorStateHumanInteractionError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'passes an empty requirements list' {
        Get-OrchestratorStateHumanInteractionError -Value (ConvertFrom-FixtureJson -Json '{"requirements":[]}') |
            Should -BeNullOrEmpty
    }

    It 'U6.H1 reports a non-object human_interaction value' {
        Get-OrchestratorStateHumanInteractionError -Value (ConvertFrom-FixtureJson -Json '[1]') |
            Should -Contain 'Checkpoint human_interaction must be an object when present.'
    }

    It 'U6.H2 reports a missing requirements list' {
        Get-OrchestratorStateHumanInteractionError -Value (ConvertFrom-FixtureJson -Json '{}') |
            Should -Contain 'Checkpoint human_interaction.requirements must be a list.'
    }

    It 'U6.H2 reports a non-list requirements value' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":{"a":1}}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements must be a list.'
    }

    It 'U6.H3 reports a non-object requirement' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":["x"]}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements #0 must be an object.'
    }

    It 'U6.H4 reports an out-of-enum response with the raw value interpolated' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":[{"response":"escalate"}]}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements #0 response must be one of scope_change, exception, halt; got: escalate'
    }

    It 'U6.H4 renders an absent response as Python None' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":[{}]}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements #0 response must be one of scope_change, exception, halt; got: None'
    }

    It 'U6.H5 reports an exception response with no runbook_path' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":[{"response":"exception"}]}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements #0 response is exception but runbook_path is missing or empty.'
    }

    It 'U6.H5 reports an exception response with a whitespace-only runbook_path' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":[{"response":"exception","runbook_path":"  "}]}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements #0 response is exception but runbook_path is missing or empty.'
    }

    It 'U6.H5 does not fire for a non-exception response missing a runbook_path' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":[{"response":"halt"}]}'
        Get-OrchestratorStateHumanInteractionError -Value $value | Should -BeNullOrEmpty
    }

    It 'reports each malformed requirement with its own index' {
        $value = ConvertFrom-FixtureJson -Json '{"requirements":[{"response":"halt"},{"response":"bad"}]}'
        Get-OrchestratorStateHumanInteractionError -Value $value |
            Should -Contain 'Checkpoint human_interaction.requirements #1 response must be one of scope_change, exception, halt; got: bad'
    }
}
