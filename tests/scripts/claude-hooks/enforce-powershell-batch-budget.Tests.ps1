<#
.SYNOPSIS
    Pester tests for the enforce-powershell-batch-budget.ps1 Claude Code hook.
#>

Set-StrictMode -Version Latest

Describe 'enforce-powershell-batch-budget.ps1' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'enforce-powershell-batch-budget.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        function Get-PowerShellToolInput {
            param([Parameter(Mandatory)][string] $FilePath)

            return ([ordered]@{ file_path = $FilePath } | ConvertTo-Json -Compress)
        }
    }

    AfterEach {
        $env:CLAUDE_TOOL_INPUT = $null
        $env:CLAUDE_SESSION_ID = $null
        $env:CLAUDE_POWERSHELL_BUDGET_PROD = $null
        $env:CLAUDE_POWERSHELL_BUDGET_TEST = $null
    }

    It 'allows a new production file under the production cap and records it' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 2 -TestCap 2

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/tool.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeTrue
        $result.state.prodFiles | Should -Contain 'scripts/tool.ps1'
        $result.state.testFiles | Should -BeNullOrEmpty
    }

    It 'allows PowerShell module and data files as production files' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 3 -TestCap 1

        $moduleResult = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/module.psm1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'
        $dataResult = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/config.psd1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $moduleResult.decision | Should -Be 'allow'
        $dataResult.decision | Should -Be 'allow'
        $dataResult.state.prodFiles | Should -Contain 'scripts/module.psm1'
        $dataResult.state.prodFiles | Should -Contain 'scripts/config.psd1'
    }

    It 'allows a new Pester test file under the test cap and records it' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 2 -TestCap 2

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'tests/scripts/example.Tests.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeTrue
        $result.state.testFiles | Should -Contain 'tests/scripts/example.Tests.ps1'
        $result.state.prodFiles | Should -BeNullOrEmpty
    }

    It 'allows repeated file edits without consuming another slot' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('scripts/tool.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/tool.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeFalse
        $result.state.prodFiles | Should -HaveCount 1
    }

    It 'blocks a new production file when the production cap is full' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('scripts/first.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/second.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'block'
        $result.reason | Should -BeLike '*production file cap is 1*'
        $result.reason | Should -BeLike '*scripts/second.ps1*'
    }

    It 'blocks a new test file when the test cap is full' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.testFiles = @('tests/scripts/first.Tests.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'tests/scripts/second.Tests.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'block'
        $result.reason | Should -BeLike '*test file cap is 1*'
        $result.reason | Should -BeLike '*tests/scripts/second.Tests.ps1*'
    }

    It 'ignores non-PowerShell file paths' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'README.md' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeFalse
        $result.state.prodFiles | Should -BeNullOrEmpty
        $result.state.testFiles | Should -BeNullOrEmpty
    }

    It 'uses loaded state when evaluating session budget' {
        $loaded = [pscustomobject]@{
            prodCap   = 2
            testCap   = 2
            prodFiles = @('scripts/first.ps1')
            testFiles = @('tests/scripts/first.Tests.ps1')
        }
        $state = ConvertTo-PowerShellBatchBudgetState -InputObject $loaded -ProdCap 3 -TestCap 3

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/second.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.decision | Should -Be 'allow'
        $result.state.prodFiles | Should -HaveCount 2
        $result.state.prodFiles | Should -Contain 'scripts/first.ps1'
        $result.state.prodFiles | Should -Contain 'scripts/second.ps1'
        $result.state.testFiles | Should -Contain 'tests/scripts/first.Tests.ps1'
    }

    It 'blocks malformed tool-input JSON with a diagnostic before touching state' {
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw '{not-json' -SessionId 'session-a' -Root '/repo'

        $result.decision | Should -Be 'block'
        $result.reason | Should -BeLike '*malformed JSON*'
    }

    It 'allows valid non-PowerShell tool input without touching state' {
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-PowerShellToolInput -FilePath 'docs/readme.md') -SessionId 'session-a' -Root '/repo'

        $result.decision | Should -Be 'allow'
    }

    It 'writes state for valid PowerShell tool input through injected state operations' {
        $script:createdStateDir = $null
        $script:writtenStateFile = $null
        $script:writtenState = $null

        $result = Invoke-PowerShellBatchBudgetHook `
            -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
            -SessionId 'session-a' `
            -Root '/repo' `
            -TestPathExists { param([string] $Path) [void] $Path; return $false } `
            -EnsureDirectory { param([string] $Path) $script:createdStateDir = $Path } `
            -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) $script:writtenStateFile = $Path; $script:writtenState = $State }

        $result.decision | Should -Be 'allow'
        ($script:createdStateDir -replace '\\', '/') | Should -BeLike '*/.claude/state'
        $script:writtenStateFile | Should -BeLike '*powershell-batch-budget.session-a.json'
        $script:writtenState.prodFiles | Should -Contain 'scripts/tool.ps1'
    }

    It 'loads existing state through injected state operations' {
        $stateJson = @{
            prodCap   = 2
            testCap   = 2
            prodFiles = @('scripts/first.ps1')
            testFiles = @()
        } | ConvertTo-Json -Compress
        $script:writtenState = $null

        $result = Invoke-PowerShellBatchBudgetHook `
            -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/second.ps1') `
            -SessionId 'session-a' `
            -Root '/repo' `
            -TestPathExists { param([string] $Path) return ($Path -like '*powershell-batch-budget.session-a.json') } `
            -EnsureDirectory { param([string] $Path) [void] $Path } `
            -ReadState { param([string] $Path) [void] $Path; return $stateJson } `
            -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $Path; $script:writtenState = $State }

        $result.decision | Should -Be 'allow'
        $script:writtenState.prodFiles | Should -Contain 'scripts/first.ps1'
        $script:writtenState.prodFiles | Should -Contain 'scripts/second.ps1'
    }

    It 'continues when injected state read and write operations fail' {
        $result = Invoke-PowerShellBatchBudgetHook `
            -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
            -SessionId 'session-a' `
            -Root '/repo' `
            -TestPathExists { param([string] $Path) [void] $Path; return $true } `
            -ReadState { param([string] $Path) [void] $Path; return '{not-json' } `
            -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $Path; [void] $State; throw 'write failed' }

        $result.decision | Should -Be 'allow'
        $result.state.prodFiles | Should -Contain 'scripts/tool.ps1'
    }

    It 'honors entrypoint environment caps while blocking malformed JSON' {
        $env:CLAUDE_TOOL_INPUT = '{not-json'
        $env:CLAUDE_SESSION_ID = 'session-a'
        $env:CLAUDE_POWERSHELL_BUDGET_PROD = '7'
        $env:CLAUDE_POWERSHELL_BUDGET_TEST = '8'

        $result = & $script:ScriptPath | ConvertFrom-Json

        $result.decision | Should -Be 'block'
        $result.reason | Should -BeLike '*malformed JSON*'
    }
}
