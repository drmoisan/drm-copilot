#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the PowerShell port of the Codex topology resolver.

.DESCRIPTION
    Exercises Resolve-CodexTopology and Get-CodexForcedRootPersona in
    .claude/lib/codex-routing/CodexTopology.psm1 against the documented behavior
    of the Python reference scripts/dev_tools/resolve_codex_topology.py, in the
    house pattern of tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1.

    Coverage spans the small-route selection for every direct-mode language, the
    complete escalation precedence (each of the seven reasons plus the precedence
    ordering between them), language normalization and deduplication, the forced
    root persona branch and its standalone requirement, and every invalid-input
    throw. The invalid-input assertions pin the exact exception Message text,
    including Python tuple and repr() rendering, because inventory row U6.T10
    interpolates that text verbatim into a checkpoint error string.

    ORACLE INTENT: this suite is written to serve as the behavioral oracle for the
    eventual bash migration of the enforcement-hook surface. A bash port of this
    resolver must reproduce every assertion below verbatim.

    The suite creates no temporary files, starts no external process, and never
    mutates $PSVersionTable or $env:PATH.
#>

param()

BeforeAll {
    # Resolve the module four levels up: codex-routing -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/codex-routing.
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/codex-routing/CodexTopology.psm1").Path
    Import-Module $modulePath -Force
}

Describe 'Resolve-CodexTopology small route' {

    It 'selects the powershell typed engineer inside its 2-file production budget' {
        $result = Resolve-CodexTopology -Language @('powershell') -ProductionFileCount 2 `
            -TestFileCount 3 -ExecutionContext 'standalone'
        $result['route'] | Should -Be 'small'
        $result['topology'] | Should -Be 'typed_engineer'
        $result['logical_agent'] | Should -Be 'powershell-typed-engineer'
        $result['routing_reason'] | Should -Be 'within_language_budget'
        $result['max_production_files'] | Should -Be 2
        $result['max_test_files'] | Should -Be 3
        $result['root_persona'] | Should -BeNullOrEmpty
    }

    It 'selects the python typed engineer inside its 3-file production budget' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 3 `
            -TestFileCount 3 -ExecutionContext 'standalone'
        $result['logical_agent'] | Should -Be 'python-typed-engineer'
        $result['max_production_files'] | Should -Be 3
    }

    It 'selects the csharp typed engineer inside its 3-file production budget' {
        $result = Resolve-CodexTopology -Language @('csharp') -ProductionFileCount 3 `
            -TestFileCount 3 -ExecutionContext 'standalone'
        $result['logical_agent'] | Should -Be 'csharp-typed-engineer'
    }

    It 'does not escalate on a test count above the language test budget' {
        $result = Resolve-CodexTopology -Language @('powershell') -ProductionFileCount 1 `
            -TestFileCount 99 -ExecutionContext 'standalone'
        $result['route'] | Should -Be 'small'
    }

    It 'returns exactly the twelve resolved keys' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        ($result.Keys | Sort-Object) | Should -Be @(
            'cross_cutting', 'execution_context', 'languages', 'logical_agent',
            'max_production_files', 'max_test_files', 'production_file_count',
            'root_persona', 'route', 'routing_reason', 'test_file_count', 'topology'
        )
    }
}

Describe 'Resolve-CodexTopology language normalization' {

    It 'lowercases and trims a language name' {
        $result = Resolve-CodexTopology -Language @('  PowerShell  ') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['languages'] | Should -Be @('powershell')
        $result['logical_agent'] | Should -Be 'powershell-typed-engineer'
    }

    It 'deduplicates case variants into a single language' {
        $result = Resolve-CodexTopology -Language @('Python', 'python', 'PYTHON') `
            -ProductionFileCount 1 -TestFileCount 1 -ExecutionContext 'standalone'
        $result['languages'] | Should -Be @('python')
        $result['route'] | Should -Be 'small'
    }

    It 'orders multiple languages ordinally, independent of input order' {
        $result = Resolve-CodexTopology -Language @('python', 'csharp') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['languages'] | Should -Be @('csharp', 'python')
    }
}

Describe 'Resolve-CodexTopology escalation precedence' {

    It 'escalates an epic execution child before any other condition' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 0 `
            -TestFileCount (-5) -ExecutionContext 'epic_execution_child'
        $result['routing_reason'] | Should -Be 'epic_child_context'
        $result['route'] | Should -Be 'large'
        $result['topology'] | Should -Be 'orchestrator'
        $result['logical_agent'] | Should -Be 'orchestrator'
        $result['max_production_files'] | Should -BeNullOrEmpty
    }

    It 'escalates an epic preparation child' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'epic_preparation_child'
        $result['routing_reason'] | Should -Be 'epic_child_context'
    }

    It 'escalates a zero production file count as an invalid estimate' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 0 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'invalid_estimate'
    }

    It 'escalates a negative test file count as an invalid estimate' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount (-1) -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'invalid_estimate'
    }

    It 'escalates an invalid estimate before a cross-language check' {
        $result = Resolve-CodexTopology -Language @('python', 'csharp') -ProductionFileCount 0 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'invalid_estimate'
    }

    It 'escalates two distinct languages as cross-language' {
        $result = Resolve-CodexTopology -Language @('python', 'csharp') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'cross_language'
        $result['max_production_files'] | Should -BeNullOrEmpty
    }

    It 'escalates an empty language list as unsupported' {
        $result = Resolve-CodexTopology -Language @() -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'unsupported_language'
        @($result['languages']).Count | Should -Be 0
    }

    It 'escalates a language with no budget entry as unsupported' {
        $result = Resolve-CodexTopology -Language @('rust') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'unsupported_language'
        $result['max_production_files'] | Should -BeNullOrEmpty
    }

    It 'escalates a cross-cutting change and reports the resolved budget' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone' -CrossCutting $true
        $result['routing_reason'] | Should -Be 'cross_cutting'
        $result['cross_cutting'] | Should -BeTrue
        $result['max_production_files'] | Should -Be 3
        $result['max_test_files'] | Should -Be 3
    }

    It 'escalates cross-cutting before the direct-mode-disabled check' {
        $result = Resolve-CodexTopology -Language @('typescript') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone' -CrossCutting $true
        $result['routing_reason'] | Should -Be 'cross_cutting'
    }

    It 'escalates a direct-mode-disabled language and reports its zero budget' {
        $result = Resolve-CodexTopology -Language @('typescript') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'direct_mode_disabled'
        $result['max_production_files'] | Should -Be 0
    }

    It 'escalates a production count above the language budget' {
        $result = Resolve-CodexTopology -Language @('powershell') -ProductionFileCount 3 `
            -TestFileCount 3 -ExecutionContext 'standalone'
        $result['routing_reason'] | Should -Be 'production_budget_exceeded'
        $result['max_production_files'] | Should -Be 2
    }
}

Describe 'Resolve-CodexTopology forced root persona' {

    It 'selects the epic planner on the epic route' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone' -RootPersona 'epic-planner'
        $result['route'] | Should -Be 'epic'
        $result['topology'] | Should -Be 'epic_persona'
        $result['logical_agent'] | Should -Be 'epic-planner'
        $result['root_persona'] | Should -Be 'epic-planner'
        $result['routing_reason'] | Should -Be 'forced_root_persona'
        $result['max_production_files'] | Should -BeNullOrEmpty
    }

    It 'selects the epic orchestrator on the epic route' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone' -RootPersona 'epic-orchestrator'
        $result['logical_agent'] | Should -Be 'epic-orchestrator'
    }

    It 'bypasses every escalation condition, including an invalid estimate' {
        $result = Resolve-CodexTopology -Language @('rust', 'go') -ProductionFileCount 0 `
            -TestFileCount 1 -ExecutionContext 'standalone' -RootPersona 'epic-planner'
        $result['routing_reason'] | Should -Be 'forced_root_persona'
    }

    It 'rejects an unsupported root persona' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'standalone' -RootPersona 'nope' } |
            Should -Throw -ExpectedMessage "Unsupported Codex root persona: 'nope'."
    }

    It 'requires a standalone context for a forced root persona' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'epic_execution_child' -RootPersona 'epic-planner' } |
            Should -Throw -ExpectedMessage 'A forced root persona requires standalone context.'
    }

    It 'treats a null root persona as absent' {
        $result = Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
            -TestFileCount 1 -ExecutionContext 'standalone' -RootPersona $null
        $result['route'] | Should -Be 'small'
    }
}

Describe 'Get-CodexForcedRootPersona' {

    It 'reports exactly the two forced root personas' {
        @(Get-CodexForcedRootPersona) | Should -Be @('epic-planner', 'epic-orchestrator')
    }
}

Describe 'Resolve-CodexTopology invalid-input throw surface' {

    It 'rejects an out-of-enum execution_context with the sorted-tuple message text' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'bogus' } |
            Should -Throw -ExpectedMessage "execution_context must be one of ('epic_execution_child', 'epic_preparation_child', 'standalone'), found 'bogus'."
    }

    It 'rejects a blank language name' {
        { Resolve-CodexTopology -Language @('python', '   ') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'standalone' } |
            Should -Throw -ExpectedMessage 'languages must contain non-empty strings.'
    }

    It 'rejects a non-string language member' {
        { Resolve-CodexTopology -Language @('python', 7) -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'standalone' } |
            Should -Throw -ExpectedMessage 'languages must contain non-empty strings.'
    }

    It 'rejects a boolean production_file_count, matching the Python bool guard' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount $true `
                -TestFileCount 1 -ExecutionContext 'standalone' } |
            Should -Throw -ExpectedMessage 'production_file_count must be an integer.'
    }

    It 'rejects a non-integer production_file_count' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount 'two' `
                -TestFileCount 1 -ExecutionContext 'standalone' } |
            Should -Throw -ExpectedMessage 'production_file_count must be an integer.'
    }

    It 'rejects a boolean test_file_count' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
                -TestFileCount $false -ExecutionContext 'standalone' } |
            Should -Throw -ExpectedMessage 'test_file_count must be an integer.'
    }

    It 'rejects a non-boolean cross_cutting indicator' {
        { Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'standalone' -CrossCutting 'yes' } |
            Should -Throw -ExpectedMessage 'cross_cutting must be a boolean.'
    }

    It 'validates the execution context before the language collection' {
        { Resolve-CodexTopology -Language @('') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'bogus' } |
            Should -Throw -ExpectedMessage "execution_context must be one of ('epic_execution_child', 'epic_preparation_child', 'standalone'), found 'bogus'."
    }

    It 'raises the ValueError-equivalent exception type for every invalid input' {
        $thrown = $null
        try {
            Resolve-CodexTopology -Language @('python') -ProductionFileCount 1 `
                -TestFileCount 1 -ExecutionContext 'bogus' | Out-Null
        } catch {
            $thrown = $_.Exception
        }
        $thrown | Should -BeOfType ([System.ArgumentException])
    }
}
