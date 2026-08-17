#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the portable U6.T codex_topology_receipts checks.

.DESCRIPTION
    Exercises every inventory row implemented by
    .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1
    against the exact error-string templates recorded in the issue #475 parity
    inventory: rows U6.T1 through U6.T11. Each row has at least one failing
    fixture asserting the exact string, and the family has passing fixtures for
    the small route, an escalation with null budgets, and a forced root persona.

    Row U6.T6 has dedicated fixtures proving a boolean is rejected where an
    integer is required, for both file-count keys and in both directions. That
    rule exists because Python's bool subclasses int, so a naive port would accept
    `true` as a file count.

    The suite also pins the single-implementation rule: the checks must call
    Resolve-CodexTopology from .claude/lib/codex-routing/CodexTopology.psm1 rather
    than re-implementing the language-budget table or the escalation precedence.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of these
    checks must reproduce every assertion below verbatim, including the Python
    repr() rendering of a list-valued resolved key.

    Every fixture is an in-memory JSON string. The suite creates no temporary
    files, starts no external process, and never mutates $PSVersionTable or
    $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateCodexTopologyReceipts.psm1') -Force

    $script:ModuleUnderTest = 'OrchestratorStateCodexTopologyReceipts'

    function script:ConvertFrom-FixtureJson {
        param([Parameter(Mandatory = $true)][string] $Json)
        return , (ConvertFrom-Json -InputObject $Json -NoEnumerate)
    }

    # A receipt that exactly matches the resolver output for a standalone,
    # single-language PowerShell change inside its 2-file production budget.
    $script:ValidReceipt = '{"phase":"P1","execution_context":"standalone","languages":["powershell"],' +
    '"production_file_count":2,"test_file_count":3,"cross_cutting":false,"root_persona":null,' +
    '"route":"small","topology":"typed_engineer","logical_agent":"powershell-typed-engineer",' +
    '"routing_reason":"within_language_budget","max_production_files":2,"max_test_files":3}'
}

Describe 'OrchestratorStateCodexTopologyReceipts shape and key checks' {

    It 'passes a receipt that matches the resolver exactly' {
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt]") |
            Should -BeNullOrEmpty
    }

    It 'passes an escalation receipt carrying null budgets' {
        $json = '{"phase":"P1","execution_context":"standalone","languages":["rust"],' +
        '"production_file_count":1,"test_file_count":1,"cross_cutting":false,"root_persona":null,' +
        '"route":"large","topology":"orchestrator","logical_agent":"orchestrator",' +
        '"routing_reason":"unsupported_language","max_production_files":null,"max_test_files":null}'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -BeNullOrEmpty
    }

    It 'passes a forced root persona receipt' {
        $json = '{"phase":"P1","execution_context":"standalone","languages":["python"],' +
        '"production_file_count":1,"test_file_count":1,"cross_cutting":false,"root_persona":"epic-planner",' +
        '"route":"epic","topology":"epic_persona","logical_agent":"epic-planner",' +
        '"routing_reason":"forced_root_persona","max_production_files":null,"max_test_files":null}'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -BeNullOrEmpty
    }

    It 'U6.T1 reports a non-list value' {
        Get-OrchestratorStateCodexTopologyReceiptError -Value 5 |
            Should -Contain 'Checkpoint codex_topology_receipts must be a list when present.'
    }

    It 'U6.T2 reports a non-object entry with bracket index notation' {
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json '[7]') |
            Should -Contain 'Checkpoint codex_topology_receipts[0] must be an object.'
    }

    It 'U6.T3 reports every missing required key in one comma-joined error' {
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json '[{"phase":"P1"}]') |
            Should -Contain ('Checkpoint codex_topology_receipts[0] missing required keys: execution_context, languages, ' +
                'production_file_count, test_file_count, cross_cutting, root_persona, route, topology, ' +
                'logical_agent, routing_reason, max_production_files, max_test_files.')
    }

    It 'U6.T3 stops the receipt so no type check or resolution is attempted' {
        @(Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json '[{"phase":"P1"}]')).Count |
            Should -Be 1
    }

    It 'U6.T4 reports a blank phase' {
        $json = $script:ValidReceipt -replace '"phase":"P1"', '"phase":"   "'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].phase must be a non-empty string.'
    }

    It 'reports each malformed receipt with its own index' {
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt,7]") |
            Should -Contain 'Checkpoint codex_topology_receipts[1] must be an object.'
    }
}

Describe 'OrchestratorStateCodexTopologyReceipts resolver-input type checks' {

    It 'U6.T5 reports a non-list languages value' {
        $json = $script:ValidReceipt -replace '"languages":\["powershell"\]', '"languages":"powershell"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].languages must be a list of non-empty strings.'
    }

    It 'U6.T5 reports a languages list holding a blank string' {
        $json = $script:ValidReceipt -replace '"languages":\["powershell"\]', '"languages":["powershell","  "]'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].languages must be a list of non-empty strings.'
    }

    It 'U6.T6 rejects a boolean production_file_count' {
        $json = $script:ValidReceipt -replace '"production_file_count":2', '"production_file_count":true'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].production_file_count must be an integer.'
    }

    It 'U6.T6 rejects a boolean test_file_count' {
        $json = $script:ValidReceipt -replace '"test_file_count":3', '"test_file_count":false'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].test_file_count must be an integer.'
    }

    It 'U6.T6 rejects a string production_file_count' {
        $json = $script:ValidReceipt -replace '"production_file_count":2', '"production_file_count":"2"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].production_file_count must be an integer.'
    }

    It 'U6.T6 rejects a null test_file_count' {
        $json = $script:ValidReceipt -replace '"test_file_count":3', '"test_file_count":null'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].test_file_count must be an integer.'
    }

    It 'U6.T6 accepts a zero file count, which is an integer' {
        $json = '{"phase":"P1","execution_context":"standalone","languages":["python"],' +
        '"production_file_count":0,"test_file_count":0,"cross_cutting":false,"root_persona":null,' +
        '"route":"large","topology":"orchestrator","logical_agent":"orchestrator",' +
        '"routing_reason":"invalid_estimate","max_production_files":null,"max_test_files":null}'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -BeNullOrEmpty
    }

    It 'U6.T7 reports a non-boolean cross_cutting' {
        $json = $script:ValidReceipt -replace '"cross_cutting":false', '"cross_cutting":"no"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].cross_cutting must be a boolean.'
    }

    It 'U6.T8 reports a non-string execution_context' {
        $json = $script:ValidReceipt -replace '"execution_context":"standalone"', '"execution_context":5'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].execution_context must be a string.'
    }

    It 'U6.T9 reports an out-of-enum root_persona with the sorted tuple' {
        $json = $script:ValidReceipt -replace '"root_persona":null', '"root_persona":"nope"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_topology_receipts[0].root_persona must be null or one of ('epic-orchestrator', 'epic-planner')."
    }

    It 'U6.T9 accepts a null root_persona' {
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt]") |
            Should -BeNullOrEmpty
    }

    It 'an input type error stops the receipt before resolution' {
        $json = $script:ValidReceipt -replace '"cross_cutting":false', '"cross_cutting":"no"' -replace '"route":"small"', '"route":"large"'
        $errors = @(Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]"))
        $errors.Count | Should -Be 1
        ($errors | Where-Object { $_ -like '*.route must be*' }) | Should -BeNullOrEmpty
    }
}

Describe 'OrchestratorStateCodexTopologyReceipts resolver and resolved-key checks' {

    It 'U6.T10 reports an invalid routing input with the resolver message text' {
        $json = $script:ValidReceipt -replace '"execution_context":"standalone"', '"execution_context":"bogus"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_topology_receipts[0] has invalid routing inputs: execution_context must be one of ('epic_execution_child', 'epic_preparation_child', 'standalone'), found 'bogus'."
    }

    It 'U6.T10 reports a forced root persona outside standalone context' {
        $json = $script:ValidReceipt -replace '"execution_context":"standalone"', '"execution_context":"epic_execution_child"' `
            -replace '"root_persona":null', '"root_persona":"epic-planner"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0] has invalid routing inputs: A forced root persona requires standalone context.'
    }

    It 'U6.T10 stops the receipt so no resolved-key comparison is attempted' {
        $json = $script:ValidReceipt -replace '"execution_context":"standalone"', '"execution_context":"bogus"'
        @(Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]")).Count |
            Should -Be 1
    }

    It 'U6.T11 reports a mismatched list-valued key as a Python list literal' {
        $json = $script:ValidReceipt -replace '"languages":\["powershell"\]', '"languages":["PowerShell"]'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_topology_receipts[0].languages must be ['powershell'], found ['PowerShell']."
    }

    It 'U6.T11 reports a mismatched string key with repr() rendering' {
        $json = $script:ValidReceipt -replace '"route":"small"', '"route":"large"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_topology_receipts[0].route must be 'small', found 'large'."
    }

    It 'U6.T11 reports a mismatched integer key' {
        $json = $script:ValidReceipt -replace '"max_production_files":2', '"max_production_files":9'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].max_production_files must be 2, found 9.'
    }

    It 'U6.T11 reports a null expected budget rendered as None' {
        $json = '{"phase":"P1","execution_context":"standalone","languages":["rust"],' +
        '"production_file_count":1,"test_file_count":1,"cross_cutting":false,"root_persona":null,' +
        '"route":"large","topology":"orchestrator","logical_agent":"orchestrator",' +
        '"routing_reason":"unsupported_language","max_production_files":4,"max_test_files":null}'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain 'Checkpoint codex_topology_receipts[0].max_production_files must be None, found 4.'
    }

    It 'U6.T11 reports every mismatched key, not only the first' {
        $json = $script:ValidReceipt -replace '"topology":"typed_engineer"', '"topology":"orchestrator"' `
            -replace '"routing_reason":"within_language_budget"', '"routing_reason":"cross_cutting"'
        $errors = @(Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]"))
        $errors | Should -Contain "Checkpoint codex_topology_receipts[0].topology must be 'typed_engineer', found 'orchestrator'."
        $errors | Should -Contain "Checkpoint codex_topology_receipts[0].routing_reason must be 'within_language_budget', found 'cross_cutting'."
    }
}

Describe 'Single-implementation rule for the Codex topology resolver' {

    It 'obtains the expected topology by calling Resolve-CodexTopology' {
        # A mocked resolver returning a sentinel logical agent must reach the error
        # text; an inline budget-table lookup would ignore the mock.
        Mock -ModuleName $script:ModuleUnderTest -CommandName Resolve-CodexTopology -MockWith {
            return @{
                execution_context     = 'standalone'
                languages             = [string[]]@('powershell')
                production_file_count = 2
                test_file_count       = 3
                cross_cutting         = $false
                root_persona          = $null
                route                 = 'small'
                topology              = 'typed_engineer'
                logical_agent         = 'sentinel-engineer'
                routing_reason        = 'within_language_budget'
                max_production_files  = 2
                max_test_files        = 3
            }
        }

        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$script:ValidReceipt]") |
            Should -Contain "Checkpoint codex_topology_receipts[0].logical_agent must be 'sentinel-engineer', found 'powershell-typed-engineer'."

        Should -Invoke -ModuleName $script:ModuleUnderTest -CommandName Resolve-CodexTopology -Times 1 -Exactly
    }

    It 'reads the permitted root personas from Get-CodexForcedRootPersona' {
        # A mocked persona set that omits epic-planner must make an otherwise valid
        # persona fail the enum check, proving the set is not restated locally.
        Mock -ModuleName $script:ModuleUnderTest -CommandName Get-CodexForcedRootPersona -MockWith { return [string[]]@('other-persona') }

        $json = $script:ValidReceipt -replace '"root_persona":null', '"root_persona":"epic-planner"'
        Get-OrchestratorStateCodexTopologyReceiptError -Value (ConvertFrom-FixtureJson -Json "[$json]") |
            Should -Contain "Checkpoint codex_topology_receipts[0].root_persona must be null or one of ('epic-orchestrator', 'epic-planner')."

        Should -Invoke -ModuleName $script:ModuleUnderTest -CommandName Get-CodexForcedRootPersona -Times 1 -Exactly
    }
}
