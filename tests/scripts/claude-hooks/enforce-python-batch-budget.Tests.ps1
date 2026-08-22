<#
.SYNOPSIS
    Pester tests for the enforce-python-batch-budget.ps1 Claude Code hook.
#>

Set-StrictMode -Version Latest

Describe 'enforce-python-batch-budget.ps1' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'enforce-python-batch-budget.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        function Get-PythonToolInput {
            param([Parameter(Mandatory)][string] $FilePath)

            return ([ordered]@{
                    tool_name  = 'Write'
                    tool_input = [ordered]@{ file_path = $FilePath; content = 'body' }
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    AfterEach {
        $env:CLAUDE_TOOL_INPUT = $null
        $env:CLAUDE_SESSION_ID = $null
        $env:CLAUDE_PYTHON_BUDGET_PROD = $null
        $env:CLAUDE_PYTHON_BUDGET_TEST = $null
    }

    It 'allows a new production file under the production cap and records it' {
        $state = Get-PythonBatchBudgetState -ProdCap 2 -TestCap 2

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/app.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeTrue
        $result.state.prodFiles | Should -Contain 'src/app.py'
        $result.state.testFiles | Should -BeNullOrEmpty
    }

    It 'allows a new test file under the test cap and records it' {
        $state = Get-PythonBatchBudgetState -ProdCap 2 -TestCap 2

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'tests/unit/test_app.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeTrue
        $result.state.testFiles | Should -Contain 'tests/unit/test_app.py'
        $result.state.prodFiles | Should -BeNullOrEmpty
    }

    It 'allows repeated file edits without consuming another slot' {
        $state = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('src/app.py')

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/app.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeFalse
        $result.state.prodFiles | Should -HaveCount 1
    }

    It 'denies a new production file when the production cap is full' {
        $state = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('src/first.py')

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/second.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*production file cap is 1*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*src/second.py*'
        $result.state | Should -Not -BeNullOrEmpty
    }

    It 'denies a new test file when the test cap is full' {
        $state = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1
        $state.testFiles = @('tests/unit/test_first.py')

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'tests/unit/test_second.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*test file cap is 1*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*tests/unit/test_second.py*'
    }

    It 'serializes the deny decision into the PreToolUse hookSpecificOutput envelope' {
        $state = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('src/first.py')

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/second.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'
        $parsed = $result | ConvertTo-Json -Depth 5 | ConvertFrom-Json

        $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'ignores non-Python file paths' {
        $state = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'README.md' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeFalse
        $result.state.prodFiles | Should -BeNullOrEmpty
        $result.state.testFiles | Should -BeNullOrEmpty
    }

    It 'uses loaded state when evaluating session budget' {
        $loaded = [pscustomobject]@{
            prodCap   = 2
            testCap   = 2
            prodFiles = @('src/first.py')
            testFiles = @('tests/unit/test_first.py')
        }
        $state = ConvertTo-PythonBatchBudgetState -InputObject $loaded -ProdCap 3 -TestCap 3

        $result = Invoke-PythonBatchBudgetDecision -FilePath 'src/second.py' -State $state -StateFile '/repo/.claude/state/python-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.state.prodFiles | Should -HaveCount 2
        $result.state.prodFiles | Should -Contain 'src/first.py'
        $result.state.prodFiles | Should -Contain 'src/second.py'
        $result.state.testFiles | Should -Contain 'tests/unit/test_first.py'
    }

    It 'denies malformed tool-input JSON with a diagnostic before touching state' {
        $result = Invoke-PythonBatchBudgetHook -ToolInputRaw '{not-json' -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*not parseable JSON*'
    }

    It 'denies an empty payload as an envelope anomaly (fail closed)' {
        $result = Invoke-PythonBatchBudgetHook -ToolInputRaw '' -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*empty payload*'
    }

    It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
        $result = Invoke-PythonBatchBudgetHook -ToolInputRaw '{"file_path":"src/app.py"}' -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*no tool_input key*'
    }

    It 'allows a well-formed tool_input carrying no file_path (scope filter)' {
        $nested = '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'
        $result = Invoke-PythonBatchBudgetHook -ToolInputRaw $nested -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'allows valid non-Python tool input without touching state' {
        $result = Invoke-PythonBatchBudgetHook -ToolInputRaw (Get-PythonToolInput -FilePath 'docs/readme.md') -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'writes state for valid Python tool input through injected state operations' {
        $script:createdStateDir = $null
        $script:writtenStateFile = $null
        $script:writtenState = $null

        $result = Invoke-PythonBatchBudgetHook `
            -ToolInputRaw (Get-PythonToolInput -FilePath 'src/app.py') `
            -SessionId 'session-a' `
            -Root '/repo' `
            -TestPathExists { param([string] $Path) [void] $Path; return $false } `
            -EnsureDirectory { param([string] $Path) $script:createdStateDir = $Path } `
            -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) $script:writtenStateFile = $Path; $script:writtenState = $State }

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        ($script:createdStateDir -replace '\\', '/') | Should -BeLike '*/.claude/state'
        $script:writtenStateFile | Should -BeLike '*python-batch-budget.session-a.json'
        $script:writtenState.prodFiles | Should -Contain 'src/app.py'
    }

    It 'loads existing state through injected state operations' {
        $stateJson = @{
            prodCap   = 2
            testCap   = 2
            prodFiles = @('src/first.py')
            testFiles = @()
        } | ConvertTo-Json -Compress
        $script:writtenState = $null

        $result = Invoke-PythonBatchBudgetHook `
            -ToolInputRaw (Get-PythonToolInput -FilePath 'src/second.py') `
            -SessionId 'session-a' `
            -Root '/repo' `
            -TestPathExists { param([string] $Path) return ($Path -like '*python-batch-budget.session-a.json') } `
            -EnsureDirectory { param([string] $Path) [void] $Path } `
            -ReadState { param([string] $Path) [void] $Path; return $stateJson } `
            -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $Path; $script:writtenState = $State }

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $script:writtenState.prodFiles | Should -Contain 'src/first.py'
        $script:writtenState.prodFiles | Should -Contain 'src/second.py'
    }

    It 'continues when injected state read and write operations fail' {
        $result = Invoke-PythonBatchBudgetHook `
            -ToolInputRaw (Get-PythonToolInput -FilePath 'src/app.py') `
            -SessionId 'session-a' `
            -Root '/repo' `
            -TestPathExists { param([string] $Path) [void] $Path; return $true } `
            -ReadState { param([string] $Path) [void] $Path; return '{not-json' } `
            -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $Path; [void] $State; throw 'write failed' }

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.state.prodFiles | Should -Contain 'src/app.py'
    }

    It 'denies a nested envelope naming a Python file once the production cap is full (AC-7)' {
        $state = Get-PythonBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('src/first.py')

        $decision = Invoke-PythonBatchBudgetDecision -FilePath 'src/second.py' -State $state -StateFile '/repo/.claude/state/x.json'

        $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'reads the payload through the shared reader at the entry point' {
        $hookText = Get-Content -Path $script:ScriptPath -Raw

        $hookText | Should -BeLike '*HookPayload.psm1*'
        $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
    }
}
