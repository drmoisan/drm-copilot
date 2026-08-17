#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the portable C6 routing-contract completion checks.

.DESCRIPTION
    Exercises every inventory row implemented by
    .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 against
    the exact error-string templates recorded in the issue #475 parity inventory:
    rows C6.1 through C6.14. Each row has at least one failing fixture asserting
    the exact string, both message variants of C6.10 and C6.11 are covered, and
    the family has a fully-valid passing fixture.

    The bug-promotion tool substitution has fixtures in both directions: a bug-type
    checkpoint declaring the feature-type tool fails, the same checkpoint declaring
    the bug-type tool passes, and a feature-type checkpoint is unaffected.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of these
    checks must reproduce every assertion below verbatim.

    Every fixture is an in-memory JSON string. The suite creates no temporary
    files, starts no external process, and never mutates $PSVersionTable or
    $env:PATH.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Fixture helpers are consumed inside It blocks after definition in BeforeAll')]
param()

BeforeAll {
    $libDir = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path $libDir 'OrchestratorStateRoutingContract.psm1') -Force

    function script:Get-CheckpointState {
        param([Parameter(Mandatory = $true)][string] $Json)
        return ($Json | ConvertFrom-Json)
    }

    # A checkpoint that satisfies every C6 row on the remediation route: the three
    # declared lists match the pinned matrix, every required agent, skill, and MCP
    # tool is evidenced, and both empty-list fields exist as empty lists.
    $script:ValidCheckpoint = @'
{"route_id":"remediation",
 "required_agents":["atomic-planner","atomic-executor","feature-review"],
 "required_skills":["orchestrate","atomic-plan-contract","acceptance-criteria-tracking","pr-context-artifacts"],
 "required_mcp_tools":["collect_pr_context","validate_orchestration_artifacts"],
 "delegation_receipts":[{"agent_name":"atomic-planner"},{"agent_name":"atomic-executor"},{"agent_name":"feature-review"}],
 "skill_receipts":[{"skill":"orchestrate","required":true,"evidence":"e"},
                   {"skill":"atomic-plan-contract","required":true,"evidence":"e"},
                   {"skill":"acceptance-criteria-tracking","required":true,"evidence":"e"},
                   {"skill":"pr-context-artifacts","required":true,"evidence":"e"}],
 "mcp_call_receipts":[{"tool":"collect_pr_context","ok":true,"evidence":"e"},
                      {"tool":"validate_orchestration_artifacts","ok":true,"evidence":"e"}],
 "local_execution_overrides":[],"delegation_bypasses":[]}
'@
}

Describe 'C6 terminal rows (matrix, route selection, route membership)' {

    It 'C6.1 reports a matrix carrying no routes object' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json '{"route_id":"small"}') -RoutingMatrix @{} |
            Should -Be @('Routing matrix missing routes object.')
    }

    It 'C6.1 reports a matrix whose routes member is not a mapping' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json '{"route_id":"small"}') -RoutingMatrix @{ routes = 'x' } |
            Should -Be @('Routing matrix missing routes object.')
    }

    It 'C6.2 reports a checkpoint that names no route' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json '{}') |
            Should -Be @('Checkpoint route_id or path_selected must select a route.')
    }

    It 'C6.2 reports a blank route id' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json '{"route_id":"   "}') |
            Should -Be @('Checkpoint route_id or path_selected must select a route.')
    }

    It 'C6.3 reports a fabricated route, naming it' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json '{"route_id":"direct_powershell_engineer_remediation"}') |
            Should -Be @('Checkpoint selected route has no routing-matrix entry: direct_powershell_engineer_remediation.')
    }

    It 'resolves the route from path_selected when route_id is absent' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json '{"path_selected":"fabricated"}') |
            Should -Be @('Checkpoint selected route has no routing-matrix entry: fabricated.')
    }
}

Describe 'C6 declared-list equality rows' {

    It 'passes a fully valid checkpoint' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $script:ValidCheckpoint) |
            Should -BeNullOrEmpty
    }

    It 'C6.4 reports a required_agents list that does not match the matrix' {
        $json = $script:ValidCheckpoint -replace '"required_agents":\["atomic-planner","atomic-executor","feature-review"\]',
        '"required_agents":["atomic-planner"]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint required_agents must match routing matrix for route remediation.'
    }

    It 'C6.4 reports an absent required_agents list' {
        $json = $script:ValidCheckpoint -replace '"required_agents":\["atomic-planner","atomic-executor","feature-review"\],', ''
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint required_agents must match routing matrix for route remediation.'
    }

    It 'C6.4 treats a differently ordered list as a mismatch' {
        $json = $script:ValidCheckpoint -replace '"required_agents":\["atomic-planner","atomic-executor","feature-review"\]',
        '"required_agents":["feature-review","atomic-executor","atomic-planner"]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint required_agents must match routing matrix for route remediation.'
    }

    It 'C6.5 reports a required_skills list that does not match the matrix' {
        $json = $script:ValidCheckpoint -replace '"required_skills":\["orchestrate","atomic-plan-contract","acceptance-criteria-tracking","pr-context-artifacts"\]',
        '"required_skills":["orchestrate"]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint required_skills must match routing matrix for route remediation.'
    }

    It 'C6.6 reports a required_mcp_tools list that does not match the matrix' {
        $json = $script:ValidCheckpoint -replace '"required_mcp_tools":\["collect_pr_context","validate_orchestration_artifacts"\]',
        '"required_mcp_tools":["collect_pr_context"]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint required_mcp_tools must match routing matrix for route remediation.'
    }

    It 'reports a malformed declared list as a mismatch, not a shape error' {
        $json = $script:ValidCheckpoint -replace '"required_agents":\["atomic-planner","atomic-executor","feature-review"\]',
        '"required_agents":"atomic-planner"'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint required_agents must match routing matrix for route remediation.'
    }
}

Describe 'C6 receipt-presence rows' {

    It 'C6.7 reports a required agent with no delegation receipt' {
        $json = $script:ValidCheckpoint -replace '\{"agent_name":"feature-review"\}', '{"agent_name":"other"}'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint missing required agent receipt: feature-review.'
    }

    It 'C6.7 accepts the object namespace form of delegation_receipts' {
        $json = $script:ValidCheckpoint -replace '"delegation_receipts":\[', '"delegation_receipts":{"agents":['
        $json = $json -replace '\{"agent_name":"feature-review"\}\]', '{"agent_name":"feature-review"}]}'
        ((Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json)) |
            Where-Object { $_ -like '*agent receipt*' }) | Should -BeNullOrEmpty
    }

    It 'C6.8 reports a required skill with no acknowledged receipt' {
        $json = $script:ValidCheckpoint -replace '\{"skill":"orchestrate","required":true,"evidence":"e"\}',
        '{"skill":"other","required":true,"evidence":"e"}'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint missing required skill receipt: orchestrate.'
    }

    It 'C6.8 does not count a skill receipt whose required flag is false' {
        $json = $script:ValidCheckpoint -replace '"skill":"orchestrate","required":true', '"skill":"orchestrate","required":false'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint missing required skill receipt: orchestrate.'
    }

    It 'C6.8 does not count a skill receipt with blank evidence' {
        $json = $script:ValidCheckpoint -replace '"skill":"orchestrate","required":true,"evidence":"e"',
        '"skill":"orchestrate","required":true,"evidence":"   "'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint missing required skill receipt: orchestrate.'
    }

    It 'C6.9 reports a required MCP tool with no successful receipt' {
        $json = $script:ValidCheckpoint -replace '\{"tool":"collect_pr_context","ok":true,"evidence":"e"\}',
        '{"tool":"other","ok":true,"evidence":"e"}'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint missing successful MCP receipt: collect_pr_context.'
    }

    It 'C6.9 does not count an MCP receipt whose ok flag is false' {
        $json = $script:ValidCheckpoint -replace '"tool":"collect_pr_context","ok":true', '"tool":"collect_pr_context","ok":false'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint missing successful MCP receipt: collect_pr_context.'
    }
}

Describe 'C6 empty-list rows, both message variants' {

    It 'C6.10 reports a non-list local_execution_overrides with the list-shape variant' {
        $json = $script:ValidCheckpoint -replace '"local_execution_overrides":\[\]', '"local_execution_overrides":"x"'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint local_execution_overrides must be an empty list at completion.'
    }

    It 'C6.10 reports an absent local_execution_overrides with the list-shape variant' {
        $json = $script:ValidCheckpoint -replace '"local_execution_overrides":\[\],', ''
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint local_execution_overrides must be an empty list at completion.'
    }

    It 'C6.10 reports a non-empty local_execution_overrides with the emptiness variant' {
        $json = $script:ValidCheckpoint -replace '"local_execution_overrides":\[\]', '"local_execution_overrides":["LEO-1"]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint local_execution_overrides must be empty at completion.'
    }

    It 'C6.11 reports a non-list delegation_bypasses with the list-shape variant' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]', '"delegation_bypasses":null'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint delegation_bypasses must be an empty list at completion.'
    }

    It 'C6.11 reports a non-empty delegation_bypasses with the emptiness variant' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]', '"delegation_bypasses":["b"]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint delegation_bypasses must be empty at completion.'
    }
}

Describe 'C6 lifecycle-operation rows' {

    It 'C6.12 reports a non-list lifecycle_operations' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]', '"delegation_bypasses":[],"lifecycle_operations":"x"'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint lifecycle_operations must be a list when present.'
    }

    It 'C6.12 contributes nothing when lifecycle_operations is absent' {
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $script:ValidCheckpoint) |
            Should -BeNullOrEmpty
    }

    It 'C6.12 contributes nothing when lifecycle_operations is null' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]', '"delegation_bypasses":[],"lifecycle_operations":null'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -BeNullOrEmpty
    }

    It 'C6.13 reports a non-object lifecycle operation with its index' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]', '"delegation_bypasses":[],"lifecycle_operations":[7]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint lifecycle_operations #0 must be an object.'
    }

    It 'C6.14 reports an operation that did not use the MCP surface' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]',
        '"delegation_bypasses":[],"lifecycle_operations":[{"surface":"mcp"},{"surface":"cli"}]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint lifecycle_operations #1 did not use MCP surface.'
    }

    It 'C6.14 reports an operation with no surface at all' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]', '"delegation_bypasses":[],"lifecycle_operations":[{}]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -Contain 'Checkpoint lifecycle_operations #0 did not use MCP surface.'
    }

    It 'passes lifecycle operations that all used the MCP surface' {
        $json = $script:ValidCheckpoint -replace '"delegation_bypasses":\[\]',
        '"delegation_bypasses":[],"lifecycle_operations":[{"surface":"mcp"},{"surface":"mcp"}]'
        Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json) |
            Should -BeNullOrEmpty
    }
}

Describe 'C6 bug-promotion tool substitution' {

    It 'expects the bug-type promotion-entry tool when promotion-type is bug' {
        $json = '{"route_id":"small","promotion-type":"bug","required_mcp_tools":' +
        '["new_potential_entry","potential_to_issue","new_active_feature_folder","collect_pr_context","validate_orchestration_artifacts"]}'
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json))
        $errors | Should -Contain 'Checkpoint required_mcp_tools must match routing matrix for route small.'
        $errors | Should -Contain 'Checkpoint missing successful MCP receipt: new_potential_bug_entry.'
        $errors | Should -Not -Contain 'Checkpoint missing successful MCP receipt: new_potential_entry.'
    }

    It 'accepts the bug-type promotion-entry tool in the declared list' {
        $json = '{"route_id":"small","promotion-type":"bug","required_mcp_tools":' +
        '["new_potential_bug_entry","potential_to_issue","new_active_feature_folder","collect_pr_context","validate_orchestration_artifacts"]}'
        ((Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json)) |
            Where-Object { $_ -like '*required_mcp_tools must match*' }) | Should -BeNullOrEmpty
    }

    It 'leaves the matrix list unchanged for a feature promotion' {
        $json = '{"route_id":"small","promotion-type":"feature","required_mcp_tools":' +
        '["new_potential_entry","potential_to_issue","new_active_feature_folder","collect_pr_context","validate_orchestration_artifacts"]}'
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json))
        ($errors | Where-Object { $_ -like '*required_mcp_tools must match*' }) | Should -BeNullOrEmpty
        $errors | Should -Contain 'Checkpoint missing successful MCP receipt: new_potential_entry.'
    }

    It 'leaves the matrix list unchanged when promotion-type is absent' {
        $json = '{"route_id":"small","required_mcp_tools":' +
        '["new_potential_entry","potential_to_issue","new_active_feature_folder","collect_pr_context","validate_orchestration_artifacts"]}'
        ((Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json)) |
            Where-Object { $_ -like '*required_mcp_tools must match*' }) | Should -BeNullOrEmpty
    }

    It 'substitutes every occurrence while preserving the other tools and their order' {
        $json = '{"route_id":"small","promotion-type":"bug","required_mcp_tools":' +
        '["new_potential_bug_entry","potential_to_issue","new_active_feature_folder","collect_pr_context","validate_orchestration_artifacts"],' +
        '"mcp_call_receipts":[{"tool":"potential_to_issue","ok":true,"evidence":"e"}]}'
        $errors = @(Get-OrchestratorStateRoutingContractError -State (Get-CheckpointState -Json $json))
        $errors | Should -Contain 'Checkpoint missing successful MCP receipt: new_potential_bug_entry.'
        ($errors | Where-Object { $_ -like '*receipt: potential_to_issue*' }) | Should -BeNullOrEmpty
    }
}
