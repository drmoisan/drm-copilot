#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the portable U6.X codex_model_routing_receipts checks.

.DESCRIPTION
    Exercises every inventory row implemented by
    .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1
    against the exact error-string templates recorded in the issue #475 parity
    inventory: rows U6.X1 through U6.X11. Each row has at least one failing
    fixture asserting the exact string, and the family has passing fixtures for a
    single receipt, an unchanged-ceiling sequence, and a correctly evidenced
    ceiling rise.

    The suite also pins the single-implementation rule: the checks must call
    Resolve-CodexDeployment from .claude/lib/codex-routing/CodexDeployment.psm1
    rather than re-implementing the profile table. That contract is proved by
    mocking the resolver inside the module under test and asserting the mocked
    result reaches the error text.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of these
    checks must reproduce every assertion below verbatim, including the Python
    repr() rendering of both sides of a resolved-key mismatch.

    Every fixture is an in-memory JSON string. The suite creates no temporary
    files, starts no external process, and never mutates $PSVersionTable or
    $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCodexModelReceipts.psm1') -Force

    $script:ModuleUnderTest = 'OrchestratorStateCodexModelReceipts'

    # -NoEnumerate plus the unary comma preserve a root array through the return,
    # matching the value a checkpoint property access yields at runtime.
    function script:ConvertFrom-FixtureJson {
        param([Parameter(Mandatory = $true)][string] $Json)
        return , (ConvertFrom-Json -InputObject $Json -NoEnumerate)
    }

    # A receipt that exactly matches the resolver output for a C1 standalone
    # atomic-executor delegation under a C1 ceiling. Fixtures mutate one field.
    $script:ValidReceipt = '{"logical_agent":"atomic-executor","deployment_agent":"atomic-executor-c1",' +
    '"phase":"P1","complexity_band":"C1","execution_context":"standalone",' +
    '"orchestration_complexity_ceiling":"C1","c3_overlay_applied":false,"c3_overlay_reason":null,' +
    '"model":"gpt-5.6-luna","model_reasoning_effort":"low"}'

    # The same receipt with a C3 ceiling, used by the ceiling-rise fixtures.
    $script:C3CeilingReceipt = $script:ValidReceipt -replace '"orchestration_complexity_ceiling":"C1"',
    '"orchestration_complexity_ceiling":"C3"'
}

Describe 'OrchestratorStateCodexModelReceipts shape and key checks' {

    It 'passes a receipt that matches the resolver exactly' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt]") |
            Should -BeNullOrEmpty
    }

    It 'passes an empty receipt list' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json '[]') |
            Should -BeNullOrEmpty
    }

    It 'U6.X1 reports a non-list value' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value 'x' |
            Should -Contain 'Checkpoint codex_model_routing_receipts must be a list when present.'
    }

    It 'U6.X2 reports a non-object entry with bracket index notation' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json '[7]') |
            Should -Contain 'Checkpoint codex_model_routing_receipts[0] must be an object.'
    }

    It 'U6.X3 reports every missing required key in one comma-joined error' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json '[{"logical_agent":"a"}]') |
            Should -Contain ('Checkpoint codex_model_routing_receipts[0] missing required keys: deployment_agent, phase, ' +
                'complexity_band, execution_context, orchestration_complexity_ceiling, c3_overlay_applied, ' +
                'c3_overlay_reason, model, model_reasoning_effort.')
    }

    It 'U6.X3 stops the receipt so no resolver comparison is attempted' {
        @(Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json '[{"logical_agent":"a"}]')).Count |
            Should -Be 1
    }

    It 'U6.X4 reports a blank phase' {
        $json = $script:ValidReceipt -replace '"phase":"P1"', '"phase":"   "'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[0].phase must be a non-empty string.'
    }

    It 'U6.X4 does not stop the receipt, so resolver checks still run' {
        $json = $script:ValidReceipt -replace '"phase":"P1"', '"phase":""' -replace '"model":"gpt-5.6-luna"', '"model":"wrong"'
        $errors = @(Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]"))
        $errors | Should -Contain 'Checkpoint codex_model_routing_receipts[0].phase must be a non-empty string.'
        $errors | Should -Contain "Checkpoint codex_model_routing_receipts[0].model must be 'gpt-5.6-luna', found 'wrong'."
    }

    It 'reports each malformed receipt with its own index' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,7]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1] must be an object.'
    }
}

Describe 'OrchestratorStateCodexModelReceipts resolver-input and resolved-key checks' {

    It 'U6.X5 reports an invalid routing input with the resolver message text' {
        $json = $script:ValidReceipt -replace '"complexity_band":"C1"', '"complexity_band":"CX"'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_model_routing_receipts[0] has invalid routing inputs: complexity_band must be one of ('C1', 'C2', 'C3', 'C4'), found 'CX'."
    }

    It 'U6.X5 reports an unsupported logical agent through the same surface' {
        $json = $script:ValidReceipt -replace '"logical_agent":"atomic-executor"', '"logical_agent":"nope"'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_model_routing_receipts[0] has invalid routing inputs: Unsupported Codex logical agent: 'nope'."
    }

    It 'U6.X5 stops the receipt so no resolved-key comparison is attempted' {
        $json = $script:ValidReceipt -replace '"complexity_band":"C1"', '"complexity_band":"CX"'
        @(Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]")).Count |
            Should -Be 1
    }

    It 'U6.X11 reports a mismatched string key with repr() rendering on both sides' {
        $json = $script:ValidReceipt -replace '"deployment_agent":"atomic-executor-c1"', '"deployment_agent":"wrong"'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_model_routing_receipts[0].deployment_agent must be 'atomic-executor-c1', found 'wrong'."
    }

    It 'U6.X11 reports a mismatched boolean key with Python capitalization' {
        $json = $script:ValidReceipt -replace '"c3_overlay_applied":false', '"c3_overlay_applied":true'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[0].c3_overlay_applied must be False, found True.'
    }

    It 'U6.X11 reports a mismatched null key as None' {
        $json = $script:ValidReceipt -replace '"c3_overlay_reason":null', '"c3_overlay_reason":"epic_context"'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_model_routing_receipts[0].c3_overlay_reason must be None, found 'epic_context'."
    }

    It 'U6.X11 reports every mismatched key, not only the first' {
        $json = $script:ValidReceipt -replace '"model":"gpt-5.6-luna"', '"model":"wrong"' `
            -replace '"model_reasoning_effort":"low"', '"model_reasoning_effort":"max"'
        $errors = @(Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]"))
        $errors | Should -Contain "Checkpoint codex_model_routing_receipts[0].model must be 'gpt-5.6-luna', found 'wrong'."
        $errors | Should -Contain "Checkpoint codex_model_routing_receipts[0].model_reasoning_effort must be 'low', found 'max'."
    }
}

Describe 'OrchestratorStateCodexModelReceipts ceiling monotonicity and transition checks' {

    It 'passes a sequence whose ceiling never changes' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$script:ValidReceipt]") |
            Should -BeNullOrEmpty
    }

    It 'U6.X6 reports a ceiling that drops between receipts' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:C3CeilingReceipt,$script:ValidReceipt]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].orchestration_complexity_ceiling must be monotonic; found C1 after C3.'
    }

    It 'U6.X6 suppresses the transition check for the offending receipt' {
        $errors = @(Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:C3CeilingReceipt,$script:ValidReceipt]"))
        ($errors | Where-Object { $_ -like '*ceiling_transition*' }) | Should -BeNullOrEmpty
    }

    It 'U6.X7 reports transition evidence on the first receipt, where no rise is possible' {
        $json = $script:ValidReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C1","to":"C3","affected_delegation_ids":["d1"]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[0].ceiling_transition must be absent unless the ceiling rises.'
    }

    It 'U6.X7 reports transition evidence when the ceiling is unchanged' {
        $json = $script:ValidReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C1","to":"C1","affected_delegation_ids":["d1"]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition must be absent unless the ceiling rises.'
    }

    It 'U6.X8 reports a rise with no transition object' {
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$script:C3CeilingReceipt]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition must record a ceiling increase.'
    }

    It 'U6.X8 reports a rise whose transition is not an object' {
        $json = $script:C3CeilingReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":"rose"'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition must record a ceiling increase.'
    }

    It 'U6.X9 reports a transition recording the wrong from/to pair' {
        $json = $script:C3CeilingReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C2","to":"C4","affected_delegation_ids":["d1"]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition must record C1 to C3.'
    }

    It 'U6.X10 reports an empty affected_delegation_ids list' {
        $json = $script:C3CeilingReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C1","to":"C3","affected_delegation_ids":[]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition.affected_delegation_ids must be a non-empty unique string list.'
    }

    It 'U6.X10 reports duplicated affected_delegation_ids' {
        $json = $script:C3CeilingReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C1","to":"C3","affected_delegation_ids":["d1","d1"]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition.affected_delegation_ids must be a non-empty unique string list.'
    }

    It 'U6.X10 reports a non-string affected_delegation_ids member' {
        $json = $script:C3CeilingReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C1","to":"C3","affected_delegation_ids":["d1",7]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -Contain 'Checkpoint codex_model_routing_receipts[1].ceiling_transition.affected_delegation_ids must be a non-empty unique string list.'
    }

    It 'passes a rise carrying complete and correct transition evidence' {
        $json = $script:C3CeilingReceipt -replace '"model_reasoning_effort":"low"',
        '"model_reasoning_effort":"low","ceiling_transition":{"from":"C1","to":"C3","affected_delegation_ids":["d1","d2"]}'
        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,$json]") |
            Should -BeNullOrEmpty
    }
}

Describe 'Single-implementation rule for the Codex deployment resolver' {

    It 'obtains the expected deployment by calling Resolve-CodexDeployment' {
        # A mocked resolver returning a sentinel model must reach the error text;
        # an inline profile-table lookup would ignore the mock.
        Mock -ModuleName $script:ModuleUnderTest -CommandName Resolve-CodexDeployment -MockWith {
            return @{
                logical_agent                    = 'atomic-executor'
                deployment_agent                 = 'atomic-executor-c1'
                complexity_band                  = 'C1'
                execution_context                = 'standalone'
                orchestration_complexity_ceiling = 'C1'
                c3_overlay_applied               = $false
                c3_overlay_reason                = $null
                model                            = 'sentinel-model'
                model_reasoning_effort           = 'low'
            }
        }

        Get-OrchestratorStateCodexModelRoutingReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt]") |
            Should -Contain "Checkpoint codex_model_routing_receipts[0].model must be 'sentinel-model', found 'gpt-5.6-luna'."

        Should -Invoke -ModuleName $script:ModuleUnderTest -CommandName Resolve-CodexDeployment -Times 1 -Exactly
    }
}
