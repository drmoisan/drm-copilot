#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for .codex/hooks/enforce-worktree-poetry-venv.ps1 (issue #1127).

.DESCRIPTION
    Runs the shared case table of tests/scripts/claude-hooks/WorktreePoetryVenv.Cases.ps1
    through the Codex decision function with an injected VIRTUAL_ENV value, asserts that the
    Codex helper is byte-identical to the Claude helper, and drives the Codex hook through
    the & route with [Console]::In and [Console]::Error replaced by in-memory readers and
    writers, both restored in finally. Empty or unparseable stdin exits 2 with a
    WORKTREE_VENV_BLOCKED: stderr line (the Codex convention for every registered PreToolUse
    handler); an allowed payload exits 0 with no stdout. No test sets an environment
    variable or creates a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/WorktreePoetryVenv.Cases.ps1')
    $script:DecisionCases = @(Get-WorktreePoetryVenvCase)
}

Describe 'Codex enforce-worktree-poetry-venv (issue #1127)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-worktree-poetry-venv.ps1'
        . $script:HookPath
        . (Join-Path $PSScriptRoot '../claude-hooks/WorktreePoetryVenv.Cases.ps1')

        function Invoke-CodexWorktreePoetryVenvHookProcess {
            # Drives the hook through the & route with stdin and stderr replaced; both are restored in finally.
            param([string] $PayloadRaw)
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $stdout = @()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $script:HookPath)
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); Stderr = $errorWriter.ToString(); ExitCode = $exitCode }
        }
    }

    It '<Name> is <Expected>' -ForEach $script:DecisionCases {
        # Arrange
        $case = $_
        $payload = ConvertTo-WorktreePoetryVenvCasePayload -Case $case

        # Act
        $decision = Invoke-WorktreePoetryVenvDecision -ToolInputRaw $payload -VirtualEnv $case['VirtualEnv']

        # Assert
        if ($Expected -eq 'deny') {
            $decision | Should -Not -BeNullOrEmpty -Because "$Name must deny"
            $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('WORKTREE_VENV_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue
        } else {
            $decision | Should -BeNullOrEmpty -Because "$Name must allow"
        }
    }

    It 'keeps the Codex helper byte-identical to the Claude helper' {
        # Arrange
        $claude = [System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot '.claude/hooks/worktree-poetry-venv-policy.ps1'))
        $codex = [System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot '.codex/hooks/worktree-poetry-venv-policy.ps1'))

        # Act
        $equal = [System.Linq.Enumerable]::SequenceEqual($claude, $codex)

        # Assert
        $equal | Should -BeTrue
    }

    It 'names the poetry -C form in the deny reason for an agent outside the worktree root (issue #1165)' {
        # Act
        $reason = Get-WorktreePoetryVenvBlockedReason

        # Assert
        $reason.Contains('poetry -C <worktree root>', [System.StringComparison]::Ordinal) | Should -BeTrue
    }

    It 'reads VIRTUAL_ENV through the process seam when no value is injected' {
        # Arrange
        Mock Get-WorktreePoetryVenvProcessValue { 'C:\repo\.venv' }
        $payload = '{"tool_input":{"command":"poetry install"},"cwd":"C:\\repo\\.claude\\worktrees\\wf-1"}'

        # Act
        $decision = Invoke-WorktreePoetryVenvDecision -ToolInputRaw $payload

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
        Should -Invoke Get-WorktreePoetryVenvProcessValue -Times 1 -Exactly
    }

    It 'returns a string from the process seam' {
        # Act
        $value = Get-WorktreePoetryVenvProcessValue

        # Assert
        $value | Should -BeOfType [string]
    }

    It 'exits 2 with empty stdout and a WORKTREE_VENV_BLOCKED: stderr line for <Label>' -ForEach @(
        @{ Label = 'empty stdin'; Payload = '' }
        @{ Label = 'invalid JSON'; Payload = '{not-json' }
    ) {
        # Act
        $result = Invoke-CodexWorktreePoetryVenvHookProcess -PayloadRaw $Payload

        # Assert
        $result.ExitCode | Should -Be 2
        $result.Stdout | Should -BeNullOrEmpty
        $result.Stderr.StartsWith('WORKTREE_VENV_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }

    It 'exits 0 with no stdout through the & route for <Label>' -ForEach @(
        @{ Label = 'a non-Poetry command'; Payload = '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git status"},"cwd":"C:\\repo"}' }
        @{ Label = 'a payload with no tool_input'; Payload = '{"hook_event_name":"PreToolUse","tool_name":"Bash"}' }
    ) {
        # Act
        $result = Invoke-CodexWorktreePoetryVenvHookProcess -PayloadRaw $Payload

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeNullOrEmpty
    }
}
