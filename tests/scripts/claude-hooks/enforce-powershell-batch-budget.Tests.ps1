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

            return ([ordered]@{
                    tool_name  = 'Write'
                    tool_input = [ordered]@{ file_path = $FilePath; content = 'body' }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        # Fixed synthetic out-of-root constants. They are defined by this suite
        # rather than read from the environment so the containment and rehydrate
        # tests carry no dependence on transient local state. Neither path is
        # ever created, opened, or otherwise touched on disk.
        $script:OutOfRootFixture = 'C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py'
        $script:OutOfRootPowerShellFixture = 'C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.ps1'
        $script:ContainmentStateFile = '/repo/.claude/state/powershell-batch-budget.s.json'
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

        $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeTrue
        $result.state.prodFiles | Should -Contain 'scripts/tool.ps1'
        $result.state.testFiles | Should -BeNullOrEmpty
    }

    It 'allows PowerShell module and data files as production files' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 3 -TestCap 1

        $moduleResult = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/module.psm1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'
        $dataResult = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/config.psd1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $moduleResult.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $dataResult.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $dataResult.state.prodFiles | Should -Contain 'scripts/module.psm1'
        $dataResult.state.prodFiles | Should -Contain 'scripts/config.psd1'
    }

    It 'allows a new Pester test file under the test cap and records it' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 2 -TestCap 2

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'tests/scripts/example.Tests.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeTrue
        $result.state.testFiles | Should -Contain 'tests/scripts/example.Tests.ps1'
        $result.state.prodFiles | Should -BeNullOrEmpty
    }

    It 'allows repeated file edits without consuming another slot' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('scripts/tool.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/tool.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.shouldWriteState | Should -BeFalse
        $result.state.prodFiles | Should -HaveCount 1
    }

    It 'denies a new production file when the production cap is full' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('scripts/first.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/second.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*production file cap is 1*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*scripts/second.ps1*'
        $result.state | Should -Not -BeNullOrEmpty
    }

    It 'denies a new test file when the test cap is full' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.testFiles = @('tests/scripts/first.Tests.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'tests/scripts/second.Tests.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*test file cap is 1*'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*tests/scripts/second.Tests.ps1*'
    }

    It 'serializes the deny decision into the PreToolUse hookSpecificOutput envelope' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('scripts/first.ps1')

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/second.ps1' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'
        $parsed = $result | ConvertTo-Json -Depth 5 | ConvertFrom-Json

        $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'ignores non-PowerShell file paths' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1

        $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'README.md' -State $state -StateFile '/repo/.claude/state/powershell-batch-budget.s.json'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
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

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.state.prodFiles | Should -HaveCount 2
        $result.state.prodFiles | Should -Contain 'scripts/first.ps1'
        $result.state.prodFiles | Should -Contain 'scripts/second.ps1'
        $result.state.testFiles | Should -Contain 'tests/scripts/first.Tests.ps1'
    }

    It 'denies an empty payload as an envelope anomaly (fail closed)' {
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw '' -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*empty payload*'
    }

    It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw '{"file_path":"scripts/tool.ps1"}' -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*no tool_input key*'
    }

    It 'allows a well-formed tool_input carrying no file_path (scope filter)' {
        $nested = '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw $nested -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'denies malformed tool-input JSON with a diagnostic before touching state' {
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw '{not-json' -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*not parseable JSON*'
    }

    It 'allows valid non-PowerShell tool input without touching state' {
        $result = Invoke-PowerShellBatchBudgetHook -ToolInputRaw (Get-PowerShellToolInput -FilePath 'docs/readme.md') -SessionId 'session-a' -Root '/repo'

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
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

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
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

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
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

        $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $result.state.prodFiles | Should -Contain 'scripts/tool.ps1'
    }

    It 'denies a nested envelope naming a PowerShell file once the production cap is full (AC-7)' {
        $state = Get-PowerShellBatchBudgetState -ProdCap 1 -TestCap 1
        $state.prodFiles = @('scripts/first.ps1')

        $decision = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/second.ps1' -State $state -StateFile '/repo/.claude/state/x.json'

        $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'reads the payload through the shared reader at the entry point' {
        $hookText = Get-Content -Path $script:ScriptPath -Raw

        $hookText | Should -BeLike '*HookPayload.psm1*'
        $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
    }

    Context 'session identity, containment, and rehydrate filter' {
        It 'composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it' {
            $env:CLAUDE_SESSION_ID = 'env-session-42'
            $script:writtenStateFile = $null

            $result = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -Root '/repo' `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Be 'powershell-batch-budget.env-session-42.json'
        }

        It 'composes the state-file name from the session-id state file when the environment is empty' {
            $env:CLAUDE_SESSION_ID = ''
            $script:writtenStateFile = $null
            $script:sessionIdFileRequested = $null

            $result = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -Root '/repo' `
                -ReadSessionIdFile { param([string] $Path) $script:sessionIdFileRequested = $Path; return "  file-session-7  " } `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Be 'powershell-batch-budget.file-session-7.json'
            ($script:sessionIdFileRequested -replace '\\', '/') | Should -Be '/repo/.claude/state/current-session-id'
        }

        It 'composes a worktree-derived state-file name when both sources are empty' {
            $env:CLAUDE_SESSION_ID = ''
            $script:writtenStateFile = $null

            $result = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -Root '/repo' `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            (Split-Path -Path $script:writtenStateFile -Leaf) | Should -Match '^powershell-batch-budget\.worktree-repo-[0-9a-f]{8}\.json$'
        }

        It 'composes pairwise different state-file names across the three session sources' {
            $script:composedNames = [System.Collections.ArrayList]::new()

            $env:CLAUDE_SESSION_ID = 'env-session-42'
            $script:writtenStateFile = $null
            $null = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -Root '/repo' `
                -ReadSessionIdFile { param([string] $Path) [void] $Path; return 'file-session-7' } `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }
            [void]$script:composedNames.Add((Split-Path -Path $script:writtenStateFile -Leaf))

            $env:CLAUDE_SESSION_ID = ''
            $script:writtenStateFile = $null
            $null = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -Root '/repo' `
                -ReadSessionIdFile { param([string] $Path) [void] $Path; return 'file-session-7' } `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }
            [void]$script:composedNames.Add((Split-Path -Path $script:writtenStateFile -Leaf))

            $env:CLAUDE_SESSION_ID = ''
            $script:writtenStateFile = $null
            $null = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -Root '/repo' `
                -ReadSessionIdFile { param([string] $Path) [void] $Path; return '' } `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }
            [void]$script:composedNames.Add((Split-Path -Path $script:writtenStateFile -Leaf))

            $script:composedNames | Should -HaveCount 3
            (@($script:composedNames) | Select-Object -Unique) | Should -HaveCount 3
        }

        It 'sanitizes a hostile session id into the state-file name pattern' {
            $script:writtenStateFile = $null

            $result = Invoke-PowerShellBatchBudgetHook `
                -ToolInputRaw (Get-PowerShellToolInput -FilePath 'scripts/tool.ps1') `
                -SessionId '../../etc/passwd' `
                -Root '/repo' `
                -TestPathExists { param([string] $Path) [void] $Path; return $false } `
                -EnsureDirectory { param([string] $Path) [void] $Path } `
                -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $State; $script:writtenStateFile = $Path }

            $leaf = Split-Path -Path $script:writtenStateFile -Leaf

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $leaf | Should -Match '^powershell-batch-budget\.[A-Za-z0-9._-]+\.json$'
            $leaf | Should -Be 'powershell-batch-budget..._.._etc_passwd.json'
        }

        It 'records a relative candidate path' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 3 -TestCap 3

            $result = Invoke-PowerShellBatchBudgetDecision -FilePath 'scripts/tool.ps1' -State $state -StateFile $script:ContainmentStateFile -Root '/repo'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeTrue
            $result.state.prodFiles | Should -Contain 'scripts/tool.ps1'
        }

        It 'records an absolute candidate path under the resolved root' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 3 -TestCap 3

            $result = Invoke-PowerShellBatchBudgetDecision -FilePath '/repo/scripts/tool.ps1' -State $state -StateFile $script:ContainmentStateFile -Root '/repo'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeTrue
            $result.state.prodFiles | Should -Contain '/repo/scripts/tool.ps1'
        }

        It 'discards an absolute candidate path outside the resolved root' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 3 -TestCap 3

            $result = Invoke-PowerShellBatchBudgetDecision -FilePath $script:OutOfRootPowerShellFixture -State $state -StateFile $script:ContainmentStateFile -Root '/repo'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeFalse
            $result.state.prodFiles | Should -BeNullOrEmpty
            $result.state.testFiles | Should -BeNullOrEmpty
        }

        It 'records an in-root absolute path that differs from the root only in letter case' {
            $state = Get-PowerShellBatchBudgetState -ProdCap 3 -TestCap 3

            $result = Invoke-PowerShellBatchBudgetDecision -FilePath '/REPO/scripts/tool.ps1' -State $state -StateFile $script:ContainmentStateFile -Root '/repo'

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $result.shouldWriteState | Should -BeTrue
            $result.state.prodFiles | Should -Contain '/REPO/scripts/tool.ps1'
        }

        It 'admits three in-root production files when the persisted state already holds an out-of-root entry' {
            $script:persistedState = ([ordered]@{
                    prodCap   = 3
                    testCap   = 3
                    prodFiles = @($script:OutOfRootFixture)
                    testFiles = @()
                } | ConvertTo-Json -Compress -Depth 5)
            $script:budgetDecisions = [System.Collections.ArrayList]::new()

            foreach ($candidate in @('scripts/one.ps1', 'scripts/two.ps1', 'scripts/three.ps1')) {
                $decision = Invoke-PowerShellBatchBudgetHook `
                    -ToolInputRaw (Get-PowerShellToolInput -FilePath $candidate) `
                    -SessionId 'session-a' `
                    -Root '/repo' `
                    -TestPathExists { param([string] $Path) [void] $Path; return $true } `
                    -EnsureDirectory { param([string] $Path) [void] $Path } `
                    -ReadState { param([string] $Path) [void] $Path; return $script:persistedState } `
                    -WriteState { param([string] $Path, [System.Collections.IDictionary] $State) [void] $Path; $script:persistedState = ($State | ConvertTo-Json -Compress -Depth 5) }
                [void]$script:budgetDecisions.Add($decision)
            }

            $script:budgetDecisions[0].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:budgetDecisions[1].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:budgetDecisions[2].hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:budgetDecisions[2].state.prodFiles | Should -Not -Contain $script:OutOfRootFixture
            $script:budgetDecisions[2].state.prodFiles | Should -Contain 'scripts/three.ps1'
        }
    }

    Context 'entry-point dispatch' {
        It 'returns exit code 0 and emits nothing for an allowed non-PowerShell path (deny-only convention)' {
            $allowed = Get-PowerShellToolInput -FilePath 'README.md'

            $emitted = @(Invoke-PowerShellBatchBudgetEntryPoint -ToolInputRaw $allowed)

            $emitted | Should -HaveCount 1
            [int]$emitted[0] | Should -Be 0
        }

        It 'returns exit code 0 and emits a deny decision with no state property for an empty payload' {
            $emitted = @(Invoke-PowerShellBatchBudgetEntryPoint -ToolInputRaw '')
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            [int]$code | Should -Be 0
            $parsed = $stdout | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            ($parsed.PSObject.Properties.Name -contains 'state') | Should -BeFalse
        }

        It 'returns exit code 0 and emits a deny decision when ToolInputRaw is omitted and the ReadPayload seam is empty' {
            $emitted = @(Invoke-PowerShellBatchBudgetEntryPoint -ReadPayload { '' })
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            [int]$code | Should -Be 0
            ($stdout | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'returns exit code 0 for malformed JSON with non-default session and cap environment variables set' {
            $env:CLAUDE_SESSION_ID = 'entrypoint-session'
            $env:CLAUDE_POWERSHELL_BUDGET_PROD = '5'
            $env:CLAUDE_POWERSHELL_BUDGET_TEST = '5'

            $emitted = @(Invoke-PowerShellBatchBudgetEntryPoint -ToolInputRaw '{not-json')
            $code = $emitted[-1]

            [int]$code | Should -Be 0
        }
    }
}
