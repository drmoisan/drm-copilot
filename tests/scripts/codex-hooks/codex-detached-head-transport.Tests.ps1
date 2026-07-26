#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Regression tests for issue #415: Codex PreToolUse hooks must not report a
    transport failure when the repository is on a detached HEAD.

.DESCRIPTION
    On a detached HEAD `git branch --show-current` exits 0 and emits nothing.
    Casting an empty pipeline with [string](...) yields $null rather than '', so a
    guard keyed only on $LASTEXITCODE does not fire and the subsequent .Trim()
    throws. GitHub Actions checks out refs/pull/N/merge in a detached state, which
    is why CI reproduced the failure and local runs on a named branch did not.

    These tests pin the corrected transport behaviour at the resolver seam by
    mocking the git wrapper function (never the git executable) so the detached
    condition is deterministic on any checkout, and additionally drive each hook's
    real entrypoint in-process with stdin supplied by a StringReader. No temporary
    files and no worktrees are created.
#>

Describe 'enforce-epic-child-worktree-binding.ps1 resolves the live branch on a detached HEAD (issue #415 C1)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookPath = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-child-worktree-binding.ps1'

        . $script:HookPath

        # The attestation environment the hook reads. Cleared for every entrypoint
        # case so the guard runs in its dormant default, and restored in finally.
        $script:ChildGuardEnvNames = @(
            'CODEX_EPIC_CHILD_LAUNCH_ID',
            'CODEX_EPIC_CHILD_LAUNCH_RECEIPT',
            'CODEX_EPIC_CHILD_LAUNCH_SPEC',
            'CODEX_EPIC_CHILD_EXPECTED_WORKTREE',
            'CODEX_EPIC_CHILD_DELEGATION_ID',
            'CODEX_EPIC_CHILD_EXECUTION_CONTEXT',
            'CODEX_EPIC_CHILD_AGENT',
            'CODEX_EPIC_CHILD_MODEL',
            'CODEX_EPIC_CHILD_REASONING_EFFORT',
            'CODEX_EPIC_CHILD_PROFILE_SHA256'
        )

        function Invoke-ChildGuardEntrypoint {
            <#
                Drives the hook's own entrypoint in-process. Stdin is supplied by a
                StringReader rather than a temporary file; the console readers and the
                CODEX_EPIC_CHILD_* environment are restored in finally.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw)

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            $savedEnvironment = @{}
            foreach ($name in $script:ChildGuardEnvNames) {
                $savedEnvironment[$name] = [System.Environment]::GetEnvironmentVariable($name)
                [System.Environment]::SetEnvironmentVariable($name, $null)
            }
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $script:HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
                foreach ($name in $script:ChildGuardEnvNames) {
                    [System.Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name])
                }
            }
        }
    }

    It 'returns an empty string when git succeeds with no output (the detached-HEAD condition)' {
        # Arrange: the wrapper seam emits nothing and reports success, exactly as
        # `git branch --show-current` behaves on a detached HEAD.
        Mock -CommandName Invoke-CodexChildGuardGit -MockWith {
            param([string[]] $GitArgs)
            $null = $GitArgs
            $global:LASTEXITCODE = 0
        }

        # Act
        $result = Get-CodexChildGuardLiveBranch -RepositoryRoot $script:RepoRoot

        # Assert: '' rather than $null, so no method call can throw downstream.
        $result | Should -BeOfType ([string])
        $result | Should -Be ''
        Should -Invoke Invoke-CodexChildGuardGit -Times 1 -Exactly
    }

    It 'returns an empty string when the git wrapper reports a non-zero exit code' {
        # Arrange: the pre-existing git-failure path must keep producing ''.
        Mock -CommandName Invoke-CodexChildGuardGit -MockWith {
            param([string[]] $GitArgs)
            $null = $GitArgs
            $global:LASTEXITCODE = 1
        }

        # Act
        $result = Get-CodexChildGuardLiveBranch -RepositoryRoot $script:RepoRoot

        # Assert
        $result | Should -BeOfType ([string])
        $result | Should -Be ''
    }

    It 'returns the trimmed branch name when git succeeds with output' {
        # Arrange
        Mock -CommandName Invoke-CodexChildGuardGit -MockWith {
            param([string[]] $GitArgs)
            $null = $GitArgs
            $global:LASTEXITCODE = 0
            return "main`n"
        }

        # Act
        $result = Get-CodexChildGuardLiveBranch -RepositoryRoot $script:RepoRoot

        # Assert
        $result | Should -Be 'main'
    }

    It 'passes the repository root through to the git wrapper as a -C argument' {
        # Arrange
        Mock -CommandName Invoke-CodexChildGuardGit -MockWith {
            param([string[]] $GitArgs)
            $null = $GitArgs
            $global:LASTEXITCODE = 0
            return 'feature/x'
        }

        # Act
        Get-CodexChildGuardLiveBranch -RepositoryRoot 'C:/some/root' | Out-Null

        # Assert
        Should -Invoke Invoke-CodexChildGuardGit -Times 1 -Exactly -ParameterFilter {
            $GitArgs.Count -eq 4 -and
            $GitArgs[0] -eq '-C' -and
            $GitArgs[1] -eq 'C:/some/root' -and
            $GitArgs[2] -eq 'branch' -and
            $GitArgs[3] -eq '--show-current'
        }
    }

    It 'exits 0 with no stdout for a benign Bash payload when the attestation is dormant' {
        # Arrange: the payload the failing CI case used, with the attestation cleared.
        # This case is deliberately environment-agnostic: on a named local branch the
        # resolver returns a branch name and on a detached CI merge ref it returns '',
        # and in both cases a dormant guard must allow the call with exit 0.
        $payloadRaw = [ordered]@{
            session_id      = 'issue-415-detached-head'
            hook_event_name = 'PreToolUse'
            tool_name       = 'Bash'
            tool_input      = @{ command = 'git status' }
            cwd             = $script:RepoRoot
        } | ConvertTo-Json -Compress -Depth 10

        # Act
        $result = Invoke-ChildGuardEntrypoint -PayloadRaw $payloadRaw

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -BeNullOrEmpty
        $result.Stderr | Should -Not -Match 'You cannot call a method on a null-valued expression'
    }
}
