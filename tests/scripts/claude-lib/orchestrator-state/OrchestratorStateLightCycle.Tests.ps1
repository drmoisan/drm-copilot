#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Invariant 8 (light remediation) and the invariant 2 exemption in PowerShell (issue #1097).

.DESCRIPTION
    Drives Get-OrchestratorStateRemediationLoopError with remediation_loop JSON parsed in memory,
    so the private Get-RemediationLightCycleError and the Get-RemediationCycleError exemption run
    through the public entry point. The shared corpus rows are asserted by
    OrchestratorStateRemediationLoop.Parity.Tests.ps1; these rows cover the PowerShell-specific
    shapes (an array value, a non-object finding, a non-list findings value, a non-object prior
    cycle). No test creates a file or starts a process.
#>

BeforeAll {
    $moduleDirectory = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state").Path
    Import-Module (Join-Path -Path $moduleDirectory -ChildPath 'OrchestratorStateReceipts.psm1') -Force

    $script:Prefix = 'Checkpoint remediation cycle #0 remediation_path is light but'
    $script:Invariant2 = "Checkpoint remediation cycle #0 execution_status is complete but preflight.final_status is not 'clear'."

    function Get-LoopError {
        <#
        .SYNOPSIS
            Return every remediation_loop error of a JSON loop, optionally only invariant 8 errors.
        .PARAMETER Json
            The remediation_loop value as JSON text.
        .PARAMETER Invariant8Only
            Keep only the errors that name remediation_path.
        #>
        [CmdletBinding()]
        [OutputType([string[]])]
        param(
            [Parameter(Mandatory)][string] $Json,
            [switch] $Invariant8Only
        )

        $errors = [string[]]@(Get-OrchestratorStateRemediationLoopError -Value ($Json | ConvertFrom-Json))
        if ($Invariant8Only) { return [string[]]@($errors | Where-Object { $_.Contains('remediation_path') }) }
        return $errors
    }

    function Get-LightLoopJson {
        <#
        .SYNOPSIS
            Return a loop with one review outcome and one cycle, as JSON text.
        .PARAMETER Findings
            The JSON text of the outcome's findings value.
        .PARAMETER Path
            The JSON text of the cycle's remediation_path value.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [string] $Findings = '[{"remediability":"autonomous","scope":"contained"}]',
            [string] $Path = '"light"'
        )

        return '{"review_outcomes":[{"verdict":"REMEDIATION_REQUIRED","findings":' + $Findings + '}],' +
            '"cycles":[{"plan_path":"docs/features/active/x/remediation-inputs.md","remediation_path":' + $Path +
            ',"opened_by_review":0,"execution_status":"complete"}]}'
    }
}

Describe 'Get-RemediationLightCycleError through Get-OrchestratorStateRemediationLoopError (issue #1097)' {
    It 'OLC-VALID-LIGHT-REPORTS-NOTHING' {
        # Arrange
        $json = Get-LightLoopJson -Findings '[{"remediability":"autonomous","scope":"contained"},{"remediability":"autonomous","scope":"contained"},{"remediability":"autonomous","scope":"contained"}]'

        # Act
        $errors = @(Get-LoopError -Json $json)

        # Assert: no invariant 2 error and no invariant 8 error.
        $errors | Should -BeNullOrEmpty
    }

    It 'OLC-INVARIANT-2-SKIPPED-ONLY-FOR-EXACT-LIGHT' {
        # Arrange / Act: record, in value order, whether invariant 2 fired for each
        # remediation_path value. A list keeps light and Light apart, which a hashtable
        # key would merge.
        $fired = [System.Collections.Generic.List[bool]]::new()
        foreach ($value in @('"light"', '"Light"', '"full"', '["light"]')) {
            $fired.Add(((Get-LoopError -Json (Get-LightLoopJson -Path $value)) -ccontains $script:Invariant2))
        }

        # Assert: only the exact string light skips invariant 2.
        ($fired -join ',') | Should -BeExactly 'False,True,True,True'
    }

    It 'OLC-ABSENT-KEY-REPORTS-NOTHING' {
        # Arrange: a cycle without the key, and a loop without cycles.
        $withCycle = '{"cycles":[{"plan_path":"p","preflight":{"final_status":"clear"}}]}'
        $withoutCycles = '{"review_outcomes":[]}'

        # Act / Assert
        Get-LoopError -Json $withCycle | Should -BeNullOrEmpty
        Get-LoopError -Json $withoutCycles | Should -BeNullOrEmpty
    }

    It 'OLC-ARRAY-VALUE-IS-NOT-LIGHT' {
        # Arrange: -ceq on an array filters, so the value must be tested as a string first.
        $json = '{"cycles":[{"plan_path":"p","remediation_path":["light"]}]}'

        # Act
        $errors = @(Get-LoopError -Json $json -Invariant8Only)

        # Assert
        $errors.Count | Should -Be 1
        $errors[0] | Should -BeExactly 'Checkpoint remediation cycle #0 remediation_path must be light or full.'
    }

    It 'OLC-NON-OBJECT-FINDING-REPORTS-BOTH-RULES' {
        # Act
        $errors = @(Get-LoopError -Json (Get-LightLoopJson -Findings '["not-an-object"]') -Invariant8Only)

        # Assert
        ($errors -join ' | ') | Should -BeExactly "$script:Prefix finding #0 is not autonomous. | $script:Prefix finding #0 scope is not contained."
    }

    It 'OLC-NON-LIST-FINDINGS-COUNT-AS-EMPTY' {
        # Act: R9b reports the shape; invariant 8 counts no finding.
        $errors = @(Get-LoopError -Json (Get-LightLoopJson -Findings '"none"') -Invariant8Only)

        # Assert
        $errors | Should -BeNullOrEmpty
    }

    It 'OLC-NON-OBJECT-PRIOR-CYCLE-IGNORED' {
        # Arrange: a string cycle before a light cycle opened by review 0.
        $json = '{"review_outcomes":[{"verdict":"REMEDIATION_REQUIRED","findings":[{"remediability":"autonomous","scope":"contained"}]}],' +
            '"cycles":["light",{"plan_path":"p","remediation_path":"light","opened_by_review":0}]}'

        # Act
        $errors = @(Get-LoopError -Json $json -Invariant8Only)

        # Assert
        $errors | Should -BeNullOrEmpty
    }
}
