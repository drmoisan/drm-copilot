#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Route-helper import-failure proofs for the Claude batch-budget hooks (issue #984).

.DESCRIPTION
    enforce-python-batch-budget.ps1 governs only .py paths and enforce-powershell-batch-budget.ps1
    only .ps1, .psm1, and .psd1 paths. When their evaluation-only route helper
    enforce-batch-budget-route.ps1 fails to load, an out-of-scope path is allowed and an in-scope
    path is still denied naming the helper before any state seam runs (handlers H11 and H12). A
    HookPayload.psm1 load failure still denies through the decision function. Each row runs for both
    hooks against the repository copy and the bundle mirror.

    The helper failure is a Join-Path mock throwing for its leaf over a no-op Import-Module mock.
    In-process rows call the hook function with the root /synthetic-root and recording seams, and
    the failure rows BB1 and BB2 assert the handler variable names the leaf
    (-Because 'E-CONSTRUCTION') and reset it and the dependency-failure state in finally. BB4 drives
    the hook through the & route with stdin and stderr redirected and restored. No test creates,
    renames, moves, or deletes a file.
#>

BeforeDiscovery {
    $claudeRoot = '.claude/hooks'
    $mirrorRoot = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
    $hooks = @(
        @{ Hook = 'enforce-python-batch-budget.ps1'; Variable = 'PythonBatchBudgetRouteImportFailure'; InScope = 'src/app.py'; OutOfScope = 'src/app.ts'; Code = 'PYTHON_LARGE_PATH_REQUIRED:'; HookFunction = 'Invoke-PythonBatchBudgetHook'; DecisionFunction = 'Invoke-PythonBatchBudgetDecision'; StateFunction = 'Get-PythonBatchBudgetState' }
        @{ Hook = 'enforce-powershell-batch-budget.ps1'; Variable = 'PowerShellBatchBudgetRouteImportFailure'; InScope = 'scripts/app.ps1'; OutOfScope = 'src/app.py'; Code = 'POWERSHELL_LARGE_PATH_REQUIRED:'; HookFunction = 'Invoke-PowerShellBatchBudgetHook'; DecisionFunction = 'Invoke-PowerShellBatchBudgetDecision'; StateFunction = 'Get-PowerShellBatchBudgetState' }
    )
    $script:HookRows = foreach ($root in @(@{ Root = 'repository'; Directory = $claudeRoot }, @{ Root = 'mirror'; Directory = $mirrorRoot })) {
        foreach ($hook in $hooks) { $row = $hook.Clone(); $row['Root'] = $root.Root; $row['HookRelative'] = "$($root.Directory)/$($hook.Hook)"; $row }
    }
}

Describe '<Hook> route helper import failure on the <Root> root (#984)' -ForEach $script:HookRows {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $hookPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $HookRelative))
        . $hookPath
        $script:Bb984RouteLeaf = 'enforce-batch-budget-route.ps1'

        function Initialize-Bb984State {
            # Clears the handler variable and the shared dependency-failure state after a re-dot-source.
            Set-Variable -Name $Variable -Scope Script -Value $null
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }

        function Get-Bb984HandlerValue {
            # Reads the hook's handler variable from the script scope.
            return (Get-Variable -Name $Variable -Scope Script -ValueOnly -ErrorAction SilentlyContinue)
        }

        function Get-Bb984Seam {
            # Returns recording seams for the hook function and empties the call log; every seam call appends its name.
            $script:Bb984Calls = [System.Collections.Generic.List[string]]::new()
            return @{
                ReadCheckpoint  = { param([string] $Path) $null = $Path; $script:Bb984Calls.Add('ReadCheckpoint'); '' }
                TestPathExists  = { param([string] $Path) $null = $Path; $script:Bb984Calls.Add('TestPathExists'); $false }
                EnsureDirectory = { param([string] $Path) $null = $Path; $script:Bb984Calls.Add('EnsureDirectory') }
                ReadState       = { param([string] $Path) $null = $Path; $script:Bb984Calls.Add('ReadState'); '' }
                WriteState      = { param([string] $Path, $State) $null = $Path, $State; $script:Bb984Calls.Add('WriteState') }
            }
        }

        function Invoke-Bb984Hook {
            # Calls the hook function in-process for one path with the synthetic root and the given seams.
            param([string] $FilePath, [hashtable] $Seam)
            $toolInputRaw = @{ session_id = 'bb-984'; tool_name = 'Write'; tool_input = @{ file_path = $FilePath; content = 'x' } } | ConvertTo-Json -Compress -Depth 5
            return & $HookFunction -ToolInputRaw $toolInputRaw -SessionId 'bb-984' -Root '/synthetic-root' @Seam
        }

        function Invoke-Bb984HookProcess {
            # Drives the hook through the & route with stdin and stderr redirected; both restored in finally.
            param([string] $Stdin)
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $hookPath)
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
        }

        Initialize-Bb984State
    }

    AfterAll {
        . $hookPath
        Initialize-Bb984State
    }

    It 'BB0 <Hook> allows <InScope> under the cap when enforce-batch-budget-route.ps1 loads (#984)' {
        Get-Bb984HandlerValue | Should -BeNullOrEmpty -Because 'E-CONSTRUCTION'

        $decision = Invoke-Bb984Hook -FilePath $InScope -Seam (Get-Bb984Seam)

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:Bb984Calls | Should -Contain 'ReadCheckpoint' -Because 'the in-scope path reaches the route helper'
    }

    It 'BB1 <Hook> allows <OutOfScope> when enforce-batch-budget-route.ps1 fails to load (#984)' {
        # Arrange: re-dot-source the hook with the route helper dot-source forced to fail.
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-batch-budget-route.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-batch-budget-route.ps1' }
        try {
            . $hookPath
            Get-Bb984HandlerValue | Should -Be $script:Bb984RouteLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = Invoke-Bb984Hook -FilePath $OutOfScope -Seam (Get-Bb984Seam)
        }
        finally { Initialize-Bb984State }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:Bb984Calls.Count | Should -Be 0
    }

    It 'BB2 <Hook> denies <InScope> naming enforce-batch-budget-route.ps1 without calling a seam when that file fails to load (#984)' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-batch-budget-route.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-batch-budget-route.ps1' }
        try {
            . $hookPath
            Get-Bb984HandlerValue | Should -Be $script:Bb984RouteLeaf -Because 'E-CONSTRUCTION'

            # Act
            $decision = Invoke-Bb984Hook -FilePath $InScope -Seam (Get-Bb984Seam)
        }
        finally { Initialize-Bb984State }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith($Code, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecisionReason.Contains($script:Bb984RouteLeaf) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        $script:Bb984Calls.Count | Should -Be 0 -Because ($script:Bb984Calls -join ', ')
    }

    It 'BB3 <Hook> denies through its decision function naming HookPayload.psm1 when that module fails to load (#984)' {
        # Arrange: the payload module import fails; every other import is a no-op.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated load failure: HookPayload.psm1' } -ParameterFilter { $Name -like '*HookPayload.psm1' }
        try {
            . $hookPath

            # Act
            $decision = & $DecisionFunction -FilePath $InScope -State (& $StateFunction -ProdCap 3) -Root '/synthetic-root'
        }
        finally { Initialize-Bb984State }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith($Code, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
        $decision.hookSpecificOutput.permissionDecisionReason.Contains('HookPayload.psm1') | Should -BeTrue -Because $decision.hookSpecificOutput.permissionDecisionReason
    }

    It 'BB4 <Hook> emits no deny for <OutOfScope> through the & route when enforce-batch-budget-route.ps1 fails to load (#984)' {
        # Arrange: the payload reader returns the in-memory envelope so the row does not depend on the host console.
        $envelope = @{ session_id = 'bb-984'; hook_event_name = 'PreToolUse'; tool_name = 'Write'; tool_input = @{ file_path = $OutOfScope; content = 'x' } } | ConvertTo-Json -Compress -Depth 5
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: enforce-batch-budget-route.ps1' } -ParameterFilter { $ChildPath -eq 'enforce-batch-budget-route.ps1' }
        Mock Read-ClaudeHookRawPayload { $envelope }

        # Act
        try { $result = Invoke-Bb984HookProcess -Stdin $envelope }
        finally { Initialize-Bb984State }

        # Assert: both hooks are deny-only, so an allow writes nothing to stdout.
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Not -Match '"deny"'
    }
}
