#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for .claude/hooks/enforce-worktree-poetry-venv.ps1 and its helper (issue #1127).

.DESCRIPTION
    The helper Describe dot-sources only .claude/hooks/worktree-poetry-venv-policy.ps1 and
    tests its path functions directly. The decision Describe dot-sources the hook, runs the
    shared case table of WorktreePoetryVenv.Cases.ps1 through
    Invoke-WorktreePoetryVenvDecision with an injected VIRTUAL_ENV value, and drives the hook
    through the & route with [Console]::In replaced by an in-memory reader and restored in
    finally. The registration Describe reads .claude/settings.json and .codex/config.toml.
    No test sets an environment variable or creates a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'WorktreePoetryVenv.Cases.ps1')
    $script:DecisionCases = @(Get-WorktreePoetryVenvCase)
}

Describe 'worktree-poetry-venv-policy helper functions (issue #1127)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/worktree-poetry-venv-policy.ps1')
    }

    It 'normalizes <Path> to <Expected>' -ForEach @(
        @{ Path = 'C:\Repo\.venv\'; Expected = 'c:/repo/.venv' }
        @{ Path = '/c/Repo/.venv'; Expected = 'c:/repo/.venv' }
        @{ Path = '/c'; Expected = 'c:' }
        @{ Path = 'C:\'; Expected = 'c:' }
        @{ Path = 'C:/repo/./a/../b'; Expected = 'c:/repo/b' }
        @{ Path = 'C:/..'; Expected = 'c:' }
        @{ Path = '/home/u//repo/'; Expected = '/home/u/repo' }
        @{ Path = '/'; Expected = '/' }
        @{ Path = '/..'; Expected = '/' }
        @{ Path = ''; Expected = '' }
    ) {
        # Act
        $actual = ConvertTo-WorktreePoetryComparablePath -Path $Path

        # Assert
        $actual | Should -BeExactly $Expected
    }

    It 'reports within=<Expected> for <Path> under <Container>' -ForEach @(
        @{ Path = 'C:\repo\.venv'; Container = 'C:/repo'; Expected = $true }
        @{ Path = 'C:\repo'; Container = 'c:\REPO\'; Expected = $true }
        @{ Path = 'C:\repo\.venv-old'; Container = 'C:\repo\.venv'; Expected = $false }
        @{ Path = 'C:\repo2\.venv'; Container = 'C:\repo'; Expected = $false }
        @{ Path = '/home/u/.venv'; Container = '/'; Expected = $true }
        @{ Path = ''; Container = 'C:\repo'; Expected = $false }
        @{ Path = 'C:\repo\.venv'; Container = ''; Expected = $false }
    ) {
        # Act
        $actual = Test-WorktreePoetryPathWithin -Path $Path -Container $Container

        # Assert
        $actual | Should -Be $Expected
    }

    It 'joins <ChildPath> to <BasePath> as <Expected>' -ForEach @(
        @{ BasePath = 'C:\repo\'; ChildPath = 'sub'; Expected = 'C:\repo/sub' }
        @{ BasePath = 'C:\repo'; ChildPath = 'D:\other'; Expected = 'D:\other' }
        @{ BasePath = 'C:\repo'; ChildPath = '/c/other'; Expected = '/c/other' }
        @{ BasePath = ''; ChildPath = 'sub'; Expected = $null }
        @{ BasePath = 'C:\repo'; ChildPath = ''; Expected = $null }
        @{ BasePath = 'C:\repo'; ChildPath = '~/x'; Expected = $null }
        @{ BasePath = 'C:\repo'; ChildPath = '$HOME/x'; Expected = $null }
    ) {
        # Act
        $actual = Join-WorktreePoetryTargetPath -BasePath $BasePath -ChildPath $ChildPath

        # Assert
        $actual | Should -Be $Expected
    }

    It 'returns the deny reason with the prefix and the legitimate path' {
        # Act
        $reason = Get-WorktreePoetryVenvBlockedReason

        # Assert
        $reason.StartsWith('WORKTREE_VENV_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue
        $reason | Should -BeLike '*env -u VIRTUAL_ENV poetry install*'
        $reason | Should -BeLike "*never repoint the main checkout's environment*"
    }

    It 'names the poetry -C form for an agent outside the worktree root (issue #1165)' {
        # Act
        $reason = Get-WorktreePoetryVenvBlockedReason

        # Assert
        $reason.Contains('poetry -C <worktree root>', [System.StringComparison]::Ordinal) | Should -BeTrue
    }
}

Describe 'enforce-worktree-poetry-venv decision (issue #1127)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.claude/hooks/enforce-worktree-poetry-venv.ps1'
        . $script:HookPath
        . (Join-Path $PSScriptRoot 'WorktreePoetryVenv.Cases.ps1')

        function Invoke-WorktreePoetryVenvHookProcess {
            # Drives the hook through the & route with stdin replaced; stdin is restored in finally.
            param([string] $PayloadRaw)
            $priorIn = [System.Console]::In
            $stdout = @()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                $global:LASTEXITCODE = 0
                $stdout = @(& $script:HookPath)
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
            }
            return [pscustomobject]@{ Stdout = (@($stdout | ForEach-Object { [string]$_ }) -join "`n"); ExitCode = $exitCode }
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
        } else {
            $decision | Should -BeNullOrEmpty -Because "$Name must allow"
        }
    }

    It 'emits the deny JSON shape with the reason prefix and the legitimate path' {
        # Arrange
        $payload = '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"poetry install"},"cwd":"C:\\repo\\.claude\\worktrees\\wf-1"}'

        # Act
        $json = Invoke-WorktreePoetryVenvEntryPoint -ReadPayload { $payload } -VirtualEnv 'C:\repo\.venv'
        $parsed = $json | ConvertFrom-Json

        # Assert
        $parsed.hookSpecificOutput.hookEventName | Should -BeExactly 'PreToolUse'
        $parsed.hookSpecificOutput.permissionDecision | Should -BeExactly 'deny'
        $reason = $parsed.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('WORKTREE_VENV_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue
        $reason | Should -BeLike '*env -u VIRTUAL_ENV poetry install*'
        $reason | Should -BeLike "*never repoint the main checkout's environment*"
    }

    It 'returns no output from the entry point for an allowed command' {
        # Act
        $json = Invoke-WorktreePoetryVenvEntryPoint -ReadPayload { '{"tool_input":{"command":"git status"},"cwd":"C:\\repo"}' } -VirtualEnv 'C:\repo\.venv'

        # Assert
        $json | Should -BeNullOrEmpty
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

    It 'writes nothing and exits 0 through the & route for <Label>' -ForEach @(
        @{ Label = 'a malformed payload'; Payload = '{not-json' }
        @{ Label = 'a non-Poetry command'; Payload = '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git status"}}' }
    ) {
        # Act
        $result = Invoke-WorktreePoetryVenvHookProcess -PayloadRaw $Payload

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeNullOrEmpty
    }
}

Describe 'enforce-worktree-poetry-venv registration (issue #1127)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    }

    It 'registers the Claude hook in the Bash matcher group of .claude/settings.json' {
        # Arrange
        $settings = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.claude/settings.json') | ConvertFrom-Json

        # Act
        $bashGroups = @($settings.hooks.PreToolUse | Where-Object { $_.matcher -ceq 'Bash' })
        $commands = @($bashGroups | ForEach-Object { $_.hooks } | ForEach-Object { $_.command })

        # Assert
        $bashGroups.Count | Should -Be 1
        $commands | Should -Contain 'pwsh -NoProfile -File .claude/hooks/enforce-worktree-poetry-venv.ps1'
    }

    It 'registers the Codex hook in the ^Bash$ group of .codex/config.toml' {
        # Arrange
        $config = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.codex/config.toml')

        # Act
        $groups = @($config -split '\[\[hooks\.PreToolUse\]\]' | Where-Object { $_ -match '^\s*matcher = "\^Bash\$"' })
        $lines = @($groups | ForEach-Object { $_ -split "`n" } | Where-Object { $_ -like '*.codex/hooks/enforce-worktree-poetry-venv.ps1*' })

        # Assert
        $groups.Count | Should -Be 1
        @($lines | Where-Object { $_ -like 'command = *' }).Count | Should -Be 1
        @($lines | Where-Object { $_ -like 'command_windows = *' }).Count | Should -Be 1
    }
}
