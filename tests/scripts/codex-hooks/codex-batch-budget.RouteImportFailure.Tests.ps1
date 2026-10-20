#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Route-helper import-failure proofs for the Codex batch-budget hooks (issue #984).

.DESCRIPTION
    The Codex enforce-python-batch-budget.ps1 governs only .py paths and
    enforce-powershell-batch-budget.ps1 only .ps1, .psm1, and .psd1 paths. When their
    evaluation-only route helper enforce-batch-budget-route.ps1 fails to load, an out-of-scope path
    is allowed and an in-scope path is still denied naming the helper before any state seam runs
    (handlers H11 and H12, codex rows). codex-pretooluse-file-mapping.ps1 is a scope dependency and
    still denies through the decision function. Each row runs for both hooks against the
    repository copy and the bundle mirror.

    The failures are Join-Path mocks throwing for the failed leaf over a no-op Import-Module mock.
    Rows call the hook functions in-process with the root /synthetic-root and recording seams; the
    failure rows CB1 and CB2 assert the handler variable names the leaf (-Because 'E-CONSTRUCTION')
    and every re-dot-sourcing row resets it and the dependency-failure state in finally. No test
    creates, renames, moves, or deletes a file.
#>

BeforeDiscovery {
    $codexRoot = '.codex/hooks'
    $mirrorRoot = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
    $hooks = @(
        @{ Hook = 'enforce-python-batch-budget.ps1'; Variable = 'PythonBatchBudgetRouteImportFailure'; InScope = 'src/app.py'; OutOfScope = 'src/app.ts'; Code = 'PYTHON_LARGE_PATH_REQUIRED:'; HookFunction = 'Invoke-PythonBatchBudgetHook'; DecisionFunction = 'Invoke-PythonBatchBudgetDecision'; StateFunction = 'Get-PythonBatchBudgetState' }
        @{ Hook = 'enforce-powershell-batch-budget.ps1'; Variable = 'PowerShellBatchBudgetRouteImportFailure'; InScope = 'scripts/app.ps1'; OutOfScope = 'src/app.py'; Code = 'POWERSHELL_LARGE_PATH_REQUIRED:'; HookFunction = 'Invoke-PowerShellBatchBudgetHook'; DecisionFunction = 'Invoke-PowerShellBatchBudgetDecision'; StateFunction = 'Get-PowerShellBatchBudgetState' }
    )
    $script:HookRows = foreach ($root in @(@{ Root = 'repository'; Directory = $codexRoot }, @{ Root = 'mirror'; Directory = $mirrorRoot })) {
        foreach ($hook in $hooks) { $row = $hook.Clone(); $row['Root'] = $root.Root; $row['HookRelative'] = "$($root.Directory)/$($hook.Hook)"; $row }
    }
}

Describe 'Codex <Hook> route helper import failure on the <Root> root (#984)' -ForEach $script:HookRows {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $hookPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $HookRelative))
        . $hookPath
        $script:Cb984RouteLeaf = 'enforce-batch-budget-route.ps1'

        function Initialize-Cb984State {
            # Clears the handler variable and the shared dependency-failure state after a re-dot-source.
            Set-Variable -Name $Variable -Scope Script -Value $null
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        function Get-Cb984HandlerValue {
            # Reads the hook's handler variable from the script scope.
            return (Get-Variable -Name $Variable -Scope Script -ValueOnly -ErrorAction SilentlyContinue)
        }

        function Get-Cb984Seam {
            # Returns recording seams for the hook function and empties the call log; every seam call appends its name.
            $script:Cb984Calls = [System.Collections.Generic.List[string]]::new()
            return @{
                ReadCheckpoint  = { param([string] $Path) $null = $Path; $script:Cb984Calls.Add('ReadCheckpoint'); '' }
                TestPathExists  = { param([string] $Path) $null = $Path; $script:Cb984Calls.Add('TestPathExists'); $false }
                EnsureDirectory = { param([string] $Path) $null = $Path; $script:Cb984Calls.Add('EnsureDirectory') }
                ReadState       = { param([string] $Path) $null = $Path; $script:Cb984Calls.Add('ReadState'); '' }
                WriteState      = { param([string] $Path, $State) $null = $Path, $State; $script:Cb984Calls.Add('WriteState') }
            }
        }

        function Invoke-Cb984Hook {
            # Calls the hook function in-process for one path with the synthetic root and the given seams.
            param([string] $FilePath, [hashtable] $Seam)
            $toolInputRaw = @{ file_path = $FilePath } | ConvertTo-Json -Compress
            return & $HookFunction -ToolInputRaw $toolInputRaw -SessionId 'cb-984' -Root '/synthetic-root' @Seam
        }

        Initialize-Cb984State
    }

    AfterAll {
        . $hookPath
        Initialize-Cb984State
    }

    It 'CB0 <Hook> allows <InScope> under the cap when enforce-batch-budget-route.ps1 loads (#984)' {
        Get-Cb984HandlerValue | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'

        $decision = Invoke-Cb984Hook -FilePath $InScope -Seam (Get-Cb984Seam)

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:Cb984Calls | Should -Contain 'ReadCheckpoint' -Because 'the in-scope path reaches the route helper'
    }

    It 'CB1 <Hook> allows <OutOfScope> when enforce-batch-budget-route.ps1 fails to load (#984)' {
        # Arrange: re-dot-source the hook with the route helper dot-source forced to fail.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-batch-budget-route.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-batch-budget-route.ps1' }
        try {
            . $hookPath
            Get-Cb984HandlerValue | Should -Be $script:Cb984RouteLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = Invoke-Cb984Hook -FilePath $OutOfScope -Seam (Get-Cb984Seam)
        }
        finally { Initialize-Cb984State }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:Cb984Calls.Count | Should -Be 0
    }

    It 'CB2 <Hook> denies <InScope> naming enforce-batch-budget-route.ps1 without calling a seam when that file fails to load (#984)' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-batch-budget-route.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-batch-budget-route.ps1' }
        try {
            . $hookPath
            Get-Cb984HandlerValue | Should -Be $script:Cb984RouteLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = Invoke-Cb984Hook -FilePath $InScope -Seam (Get-Cb984Seam)
        }
        finally { Initialize-Cb984State }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith($Code, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecisionReason.Contains($script:Cb984RouteLeaf) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        $script:Cb984Calls.Count | Should -Be 0 -Because ($script:Cb984Calls -join ', ')
    }

    It 'CB3 <Hook> denies through its decision function naming codex-pretooluse-file-mapping.ps1 when that file fails to load (#984)' {
        # Arrange: the transport dot-source fails; every other dependency loads.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: codex-pretooluse-file-mapping.ps1' } -ParameterFilter { $ChildPath -eq 'codex-pretooluse-file-mapping.ps1' }
        try {
            . $hookPath

            # Act
            $decision = & $DecisionFunction -FilePath $InScope -State (& $StateFunction -ProdCap 3)
        }
        finally { Initialize-Cb984State }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith($Code, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecisionReason.Contains('codex-pretooluse-file-mapping.ps1') | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
    }
}
