#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the PowerShell port of the Codex deployment resolver.

.DESCRIPTION
    Exercises Resolve-CodexDeployment in
    .claude/lib/codex-routing/CodexDeployment.psm1 against the documented behavior
    of the Python reference scripts/dev_tools/resolve_codex_deployment.py, in the
    house pattern of tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1.

    Coverage spans the full base profile table, both alias and non-alias family
    resolution, every branch of the C3 overlay rule (epic context alone, C4
    ceiling alone, both together, and neither), the forced-persona bypass, the
    availability-set failure, and every invalid-input throw. The invalid-input
    assertions pin the exact exception Message text, including Python tuple and
    repr() rendering, because inventory row U6.X5 interpolates that text verbatim
    into a checkpoint error string.

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
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/codex-routing/CodexDeployment.psm1").Path
    Import-Module $modulePath -Force
}

Describe 'Resolve-CodexDeployment base profile table' {

    It 'resolves C1 to luna at low reasoning' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C1' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1'
        $result['model'] | Should -Be 'gpt-5.6-luna'
        $result['model_reasoning_effort'] | Should -Be 'low'
        $result['deployment_agent'] | Should -Be 'atomic-executor-c1'
    }

    It 'resolves C2 to terra at medium reasoning' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C2' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C2'
        $result['model'] | Should -Be 'gpt-5.6-terra'
        $result['model_reasoning_effort'] | Should -Be 'medium'
        $result['deployment_agent'] | Should -Be 'atomic-executor-c2'
    }

    It 'resolves C3 to terra at high reasoning when no overlay applies' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C3' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C3'
        $result['model'] | Should -Be 'gpt-5.6-terra'
        $result['model_reasoning_effort'] | Should -Be 'high'
        $result['deployment_agent'] | Should -Be 'atomic-executor-c3'
        $result['c3_overlay_applied'] | Should -BeFalse
        $result['c3_overlay_reason'] | Should -BeNullOrEmpty
    }

    It 'resolves C4 to sol at max reasoning' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C4' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C4'
        $result['model'] | Should -Be 'gpt-5.6-sol'
        $result['model_reasoning_effort'] | Should -Be 'max'
        $result['deployment_agent'] | Should -Be 'atomic-executor-c4'
    }

    It 'echoes every input back into the receipt' {
        $result = Resolve-CodexDeployment -LogicalAgent 'task-researcher' -ComplexityBand 'C2' `
            -ExecutionContext 'epic_preparation_child' -OrchestrationComplexityCeiling 'C3'
        $result['logical_agent'] | Should -Be 'task-researcher'
        $result['complexity_band'] | Should -Be 'C2'
        $result['execution_context'] | Should -Be 'epic_preparation_child'
        $result['orchestration_complexity_ceiling'] | Should -Be 'C3'
    }

    It 'returns exactly the nine resolved keys' {
        $result = Resolve-CodexDeployment -LogicalAgent 'pr-author' -ComplexityBand 'C1' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1'
        ($result.Keys | Sort-Object) | Should -Be @(
            'c3_overlay_applied', 'c3_overlay_reason', 'complexity_band', 'deployment_agent',
            'execution_context', 'logical_agent', 'model', 'model_reasoning_effort',
            'orchestration_complexity_ceiling'
        )
    }
}

Describe 'Resolve-CodexDeployment agent family resolution' {

    It 'maps the feature-review alias to the feature-reviewer family' {
        $result = Resolve-CodexDeployment -LogicalAgent 'feature-review' -ComplexityBand 'C2' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C2'
        $result['deployment_agent'] | Should -Be 'feature-reviewer-c2'
        $result['logical_agent'] | Should -Be 'feature-review'
    }

    It 'accepts every generated agent family' {
        $families = @(
            'orchestrator', 'atomic-planner', 'atomic-executor', 'feature-reviewer',
            'task-researcher', 'prd-feature', 'pr-author', 'python-typed-engineer',
            'powershell-typed-engineer', 'csharp-typed-engineer', 'typescript-engineer'
        )
        foreach ($family in $families) {
            $result = Resolve-CodexDeployment -LogicalAgent $family -ComplexityBand 'C1' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1'
            $result['deployment_agent'] | Should -Be "$family-c1"
        }
    }

    It 'rejects an agent outside the generated families and the alias map' {
        { Resolve-CodexDeployment -LogicalAgent 'nope' -ComplexityBand 'C1' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1' } |
            Should -Throw -ExpectedMessage "Unsupported Codex logical agent: 'nope'."
    }
}

Describe 'Resolve-CodexDeployment C3 overlay rule' {

    It 'elevates for an epic execution child with a C4 ceiling, reporting the combined reason' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C3' `
            -ExecutionContext 'epic_execution_child' -OrchestrationComplexityCeiling 'C4'
        $result['c3_overlay_applied'] | Should -BeTrue
        $result['c3_overlay_reason'] | Should -Be 'epic_context_and_c4_ceiling'
        $result['model'] | Should -Be 'gpt-5.6-sol'
        $result['model_reasoning_effort'] | Should -Be 'high'
        $result['deployment_agent'] | Should -Be 'atomic-executor-c3-elevated'
    }

    It 'elevates for an epic preparation child below a C4 ceiling, reporting epic_context' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C3' `
            -ExecutionContext 'epic_preparation_child' -OrchestrationComplexityCeiling 'C3'
        $result['c3_overlay_reason'] | Should -Be 'epic_context'
        $result['model'] | Should -Be 'gpt-5.6-sol'
    }

    It 'elevates a standalone delegation under a C4 ceiling, reporting c4_orchestration_ceiling' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C3' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C4'
        $result['c3_overlay_reason'] | Should -Be 'c4_orchestration_ceiling'
        $result['model'] | Should -Be 'gpt-5.6-sol'
    }

    It 'does not elevate a standalone C3 delegation under a C3 ceiling' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C3' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C3'
        $result['c3_overlay_applied'] | Should -BeFalse
    }

    It 'does not apply the overlay to a non-C3 band in an epic context under a C4 ceiling' {
        $result = Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C2' `
            -ExecutionContext 'epic_execution_child' -OrchestrationComplexityCeiling 'C4'
        $result['c3_overlay_applied'] | Should -BeFalse
        $result['model'] | Should -Be 'gpt-5.6-terra'
        $result['model_reasoning_effort'] | Should -Be 'medium'
    }
}

Describe 'Resolve-CodexDeployment forced personas' {

    It 'forces the epic planner to sol at ultra reasoning with no suffix' {
        $result = Resolve-CodexDeployment -LogicalAgent 'epic-planner' -ComplexityBand 'C1' `
            -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1'
        $result['deployment_agent'] | Should -Be 'epic-planner'
        $result['model'] | Should -Be 'gpt-5.6-sol'
        $result['model_reasoning_effort'] | Should -Be 'ultra'
        $result['c3_overlay_applied'] | Should -BeFalse
    }

    It 'forces the epic orchestrator to sol at ultra reasoning' {
        $result = Resolve-CodexDeployment -LogicalAgent 'epic-orchestrator' -ComplexityBand 'C4' `
            -ExecutionContext 'epic_execution_child' -OrchestrationComplexityCeiling 'C4'
        $result['deployment_agent'] | Should -Be 'epic-orchestrator'
        $result['model_reasoning_effort'] | Should -Be 'ultra'
    }

    It 'never applies the C3 overlay to a forced persona' {
        $result = Resolve-CodexDeployment -LogicalAgent 'epic-planner' -ComplexityBand 'C3' `
            -ExecutionContext 'epic_execution_child' -OrchestrationComplexityCeiling 'C4'
        $result['c3_overlay_applied'] | Should -BeFalse
        $result['c3_overlay_reason'] | Should -BeNullOrEmpty
        $result['model_reasoning_effort'] | Should -Be 'ultra'
    }
}

Describe 'Resolve-CodexDeployment invalid-input throw surface' {

    It 'rejects an out-of-enum complexity_band with the Python message text' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'CX' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C3' } |
            Should -Throw -ExpectedMessage "complexity_band must be one of ('C1', 'C2', 'C3', 'C4'), found 'CX'."
    }

    It 'rejects an out-of-enum orchestration_complexity_ceiling with the Python message text' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C1' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C9' } |
            Should -Throw -ExpectedMessage "orchestration_complexity_ceiling must be one of ('C1', 'C2', 'C3', 'C4'), found 'C9'."
    }

    It 'rejects an out-of-enum execution_context with the sorted-tuple message text' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C1' `
                -ExecutionContext 'bogus' -OrchestrationComplexityCeiling 'C3' } |
            Should -Throw -ExpectedMessage "execution_context must be one of ('epic_execution_child', 'epic_preparation_child', 'standalone'), found 'bogus'."
    }

    It 'rejects a ceiling below the complexity band' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C4' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1' } |
            Should -Throw -ExpectedMessage 'orchestration_complexity_ceiling must be greater than or equal to complexity_band, found C1 below C4.'
    }

    It 'accepts a ceiling equal to the complexity band' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C4' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C4' } |
            Should -Not -Throw
    }

    It 'validates the band before the execution context, matching the Python order' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'CX' `
                -ExecutionContext 'bogus' -OrchestrationComplexityCeiling 'C3' } |
            Should -Throw -ExpectedMessage "complexity_band must be one of ('C1', 'C2', 'C3', 'C4'), found 'CX'."
    }

    It 'raises the ValueError-equivalent exception type for every invalid input' {
        $thrown = $null
        try {
            Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'CX' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C3' | Out-Null
        } catch {
            $thrown = $_.Exception
        }
        $thrown | Should -BeOfType ([System.ArgumentException])
    }
}

Describe 'Resolve-CodexDeployment model availability' {

    It 'returns normally when the routed model is in the availability set' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C1' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1' `
                -AvailableModel @('gpt-5.6-luna') } | Should -Not -Throw
    }

    It 'refuses to fall back when the routed model is absent from the availability set' {
        { Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C1' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1' `
                -AvailableModel @('gpt-5.6-terra') } |
            Should -Throw -ExpectedMessage "model_unavailable: required Codex model 'gpt-5.6-luna' is unavailable; silent fallback is prohibited."
    }

    It 'raises a non-ValueError exception type for model unavailability, so U6.X5 does not catch it' {
        $thrown = $null
        try {
            Resolve-CodexDeployment -LogicalAgent 'atomic-executor' -ComplexityBand 'C1' `
                -ExecutionContext 'standalone' -OrchestrationComplexityCeiling 'C1' `
                -AvailableModel @('gpt-5.6-terra') | Out-Null
        } catch {
            $thrown = $_.Exception
        }
        $thrown | Should -BeOfType ([System.InvalidOperationException])
        $thrown -is [System.ArgumentException] | Should -BeFalse
    }
}
