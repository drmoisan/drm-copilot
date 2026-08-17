#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the portable U6.C and U6.M orchestrator-state checks.

.DESCRIPTION
    Exercises every inventory row implemented by
    .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 against the
    exact error-string templates recorded in the issue #475 parity inventory
    (research/2026-08-15T15-30-full-parity-check-inventory-and-bash-json-research.md):
    U6.C1-U6.C7 (complexity_assessments per-entry) and U6.M1-U6.M6
    (model_routing_receipts per-entry). Each row has at least one failing fixture
    asserting the exact string, and each family has a passing fixture.

    The suite also pins the single-implementation rule: rows U6.C5 and U6.M4 must
    call Get-ComplexityFloor and Resolve-DelegationModel from
    .claude/lib/model-routing/ModelRouting.psm1 rather than re-implementing either
    formula. Those two contracts are proved by mocking each formula inside the
    module under test and asserting that the mocked result reaches the error text.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of these
    checks must reproduce every assertion below verbatim, so assertions pin exact
    error text rather than substrings or counts.

    Every fixture is an in-memory JSON string. The suite creates no temporary
    files, starts no external process, and never mutates $PSVersionTable or
    $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helper is consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    # Resolve the module four levels up: orchestrator-state -> claude-lib ->
    # scripts -> tests -> repo root, anchored to $PSScriptRoot so the suite is
    # independent of the caller's working directory.
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCheckpointValue.psm1') -Force
    Import-Module (Join-Path $libDir 'OrchestratorStateModelReceipts.psm1') -Force

    $script:ModuleUnderTest = 'OrchestratorStateModelReceipts'

    # -NoEnumerate keeps a root array an array, and the unary comma stops PowerShell
    # from unrolling that array again on function return, so the caller receives the
    # same value a checkpoint property access yields at runtime.
    function script:ConvertFrom-FixtureJson {
        param([Parameter(Mandatory = $true)][string] $Json)
        return , (ConvertFrom-Json -InputObject $Json -NoEnumerate)
    }
}

Describe 'OrchestratorStateModelReceipts complexity_assessments checks (U6.C)' {

    It 'passes a well-formed assessment (U6.C passing fixture)' {
        $json = '[{"phase":"P1","band":"C3","floor":"C3",' +
        '"signals_present":["auth_or_token_handling"],"rationale":"auth surface","assessed_at":"t"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'passes an assessment with no floor signals and a C1 floor' {
        $json = '[{"phase":"P1","band":"C2","floor":"C1","signals_present":[],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'U6.C1 reports a non-list complexity_assessments value' {
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json '{"a":1}') |
            Should -Contain 'Checkpoint complexity_assessments must be a list when present.'
    }

    It 'U6.C2 reports a non-object entry' {
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json '[5]') |
            Should -Contain 'Checkpoint complexity_assessments #0 must be an object.'
    }

    It 'U6.C3 reports an out-of-enum band with the raw value interpolated' {
        $json = '[{"band":"C9","floor":"C1","signals_present":[],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 band must be one of C1, C2, C3, C4; got: C9.'
    }

    It 'U6.C3 renders an absent band as Python None' {
        $json = '[{"floor":"C1","signals_present":[],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 band must be one of C1, C2, C3, C4; got: None.'
    }

    It 'U6.C4 reports a non-list signals_present' {
        $json = '[{"band":"C1","floor":"C1","signals_present":"x","rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 signals_present must be a list of strings.'
    }

    It 'U6.C4 reports a signals_present list holding a non-string element' {
        $json = '[{"band":"C1","floor":"C1","signals_present":["a",7],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 signals_present must be a list of strings.'
    }

    It 'U6.C4 suppresses the floor-equality check when signals_present is malformed' {
        $json = '[{"band":"C1","floor":"C4","signals_present":"x","rationale":"r"}]'
        $errors = @(Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json))
        $errors | Should -Not -Contain 'Checkpoint complexity_assessments #0 floor C4 does not equal compute_complexity_floor(signals_present) C1.'
    }

    It 'U6.C5 reports a floor that does not equal the recomputed floor' {
        $json = '[{"band":"C3","floor":"C1","signals_present":["auth_or_token_handling"],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 floor C1 does not equal compute_complexity_floor(signals_present) C3.'
    }

    It 'U6.C5 renders an absent floor as Python None' {
        $json = '[{"band":"C3","signals_present":[],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 floor None does not equal compute_complexity_floor(signals_present) C1.'
    }

    It 'U6.C6 reports a band below its floor' {
        $json = '[{"band":"C1","floor":"C3","signals_present":["auth_or_token_handling"],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 band C1 is below its floor C3.'
    }

    It 'U6.C6 does not fire when the band enum is already invalid' {
        $json = '[{"band":"C0","floor":"C3","signals_present":["auth_or_token_handling"],"rationale":"r"}]'
        $errors = @(Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json))
        ($errors | Where-Object { $_ -like '*is below its floor*' }) | Should -BeNullOrEmpty
    }

    It 'U6.C7 reports a missing rationale' {
        $json = '[{"band":"C1","floor":"C1","signals_present":[]}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 rationale must be a non-empty string.'
    }

    It 'U6.C7 reports a whitespace-only rationale' {
        $json = '[{"band":"C1","floor":"C1","signals_present":[],"rationale":"   "}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 rationale must be a non-empty string.'
    }

    It 'reports each malformed entry with its own index' {
        $json = '[{"band":"C1","floor":"C1","signals_present":[],"rationale":"r"},{}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #1 rationale must be a non-empty string.'
    }
}

Describe 'OrchestratorStateModelReceipts model_routing_receipts checks (U6.M)' {

    It 'passes a well-formed receipt (U6.M passing fixture)' {
        $json = '[{"agent":"atomic-executor","phase":"P1","complexity_band":"C3",' +
        '"fable_policy":"disabled","table_model":"opus","clamped_from":null,"model":"opus"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'passes a correctly clamped disabled-policy fable table cell' {
        $json = '[{"agent":"atomic-planner","phase":"P1","complexity_band":"C4",' +
        '"fable_policy":"disabled","table_model":"fable","clamped_from":"fable","model":"opus"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'U6.M1 reports a non-list model_routing_receipts value' {
        Get-OrchestratorStateModelRoutingReceiptError -Value 'x' |
            Should -Contain 'Checkpoint model_routing_receipts must be a list when present.'
    }

    It 'U6.M2 reports a non-object entry' {
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json '[7]') |
            Should -Contain 'Checkpoint model_routing_receipts #0 must be an object.'
    }

    It 'U6.M3 reports an out-of-enum complexity_band with the raw value interpolated' {
        $json = '[{"agent":"a","complexity_band":"CX","fable_policy":"available","model":"opus"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #0 complexity_band must be one of C1, C2, C3, C4; got: CX.'
    }

    It 'U6.M3 stops the receipt so no model comparison is attempted' {
        $json = '[{"agent":"a","complexity_band":"CX","fable_policy":"available","model":"opus"}]'
        @(Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json)).Count |
            Should -Be 1
    }

    It 'U6.M4 reports a model that does not equal the resolved model' {
        $json = '[{"agent":"atomic-executor","complexity_band":"C1","fable_policy":"available","model":"opus"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #0 model opus does not equal resolve_delegation_model(agent, complexity_band, fable_policy) haiku.'
    }

    It 'U6.M4 renders an absent model as Python None' {
        $json = '[{"agent":"atomic-executor","complexity_band":"C1","fable_policy":"available"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #0 model None does not equal resolve_delegation_model(agent, complexity_band, fable_policy) haiku.'
    }

    It 'U6.M4 honors the preferred overlay for an overlay agent at C3' {
        $json = '[{"agent":"atomic-planner","complexity_band":"C3","fable_policy":"preferred","model":"fable"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'U6.M5 reports a fable model under the disabled policy' {
        $json = '[{"agent":"atomic-planner","complexity_band":"C4","fable_policy":"disabled",' +
        '"table_model":"fable","clamped_from":"fable","model":"fable"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #0 model must not be fable under fable_policy disabled.'
    }

    It 'U6.M6 reports a disabled-policy fable table cell with no clamp provenance' {
        $json = '[{"agent":"atomic-planner","complexity_band":"C4","fable_policy":"disabled",' +
        '"table_model":"fable","clamped_from":null,"model":"opus"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #0 table_model fable under fable_policy disabled must record clamped_from fable and model opus.'
    }

    It 'U6.M5 and U6.M6 do not fire outside the disabled policy' {
        $json = '[{"agent":"atomic-planner","complexity_band":"C4","fable_policy":"available",' +
        '"table_model":"fable","clamped_from":null,"model":"fable"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'reports each malformed receipt with its own index' {
        $json = '[{"agent":"atomic-executor","complexity_band":"C1","fable_policy":"available","model":"haiku"},' +
        '{"agent":"atomic-executor","complexity_band":"C1","fable_policy":"available","model":"opus"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #1 model opus does not equal resolve_delegation_model(agent, complexity_band, fable_policy) haiku.'
    }
}

Describe 'Single-implementation rule for the shared reference formulas' {

    It 'U6.C5 recomputes the floor by calling the shared Get-ComplexityFloor' {
        # A mocked floor formula returning a sentinel band must reach the error
        # text; an inline re-implementation would ignore the mock and emit C1.
        Mock -ModuleName $script:ModuleUnderTest -CommandName Get-ComplexityFloor -MockWith { 'C4' }

        $json = '[{"band":"C4","floor":"C1","signals_present":[],"rationale":"r"}]'
        Get-OrchestratorStateComplexityAssessmentError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint complexity_assessments #0 floor C1 does not equal compute_complexity_floor(signals_present) C4.'

        Should -Invoke -ModuleName $script:ModuleUnderTest -CommandName Get-ComplexityFloor -Times 1 -Exactly
    }

    It 'U6.M4 resolves the expected model by calling the shared Resolve-DelegationModel' {
        # A mocked resolver returning a sentinel model must reach the error text;
        # an inline table lookup would ignore the mock and emit haiku.
        Mock -ModuleName $script:ModuleUnderTest -CommandName Resolve-DelegationModel -MockWith {
            return @{ table_model = 'sentinel'; model = 'sentinel'; clamped_from = $null; clamp_reason = $null }
        }

        $json = '[{"agent":"atomic-executor","complexity_band":"C1","fable_policy":"available","model":"haiku"}]'
        Get-OrchestratorStateModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json $json) |
            Should -Contain 'Checkpoint model_routing_receipts #0 model haiku does not equal resolve_delegation_model(agent, complexity_band, fable_policy) sentinel.'

        Should -Invoke -ModuleName $script:ModuleUnderTest -CommandName Resolve-DelegationModel -Times 1 -Exactly
    }
}
