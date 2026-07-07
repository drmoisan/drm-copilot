Set-StrictMode -Version Latest

BeforeAll {
    # Dot-source the whole script file so its functions are resolved from the original
    # file. The script's dot-source guard defines the functions but does not execute the
    # top-level body, and dot-sourcing (rather than an AST re-parse via Import-ScriptFunction)
    # preserves original line numbers so Pester code-coverage breakpoints attribute correctly.
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-claude-worktree-session.ps1"
    . $script:scriptPath
}

Describe "new-claude-worktree-session.ps1 - Get-WorktreeTimestamp" {
    Context "Default timestamp generation" {
        It "returns a non-empty string" {
            $result = Get-WorktreeTimestamp
            $result | Should -Not -BeNullOrEmpty
        }

        It "returns correct yyyy-MM-ddTHH-mm format for injected fixed datetime" {
            # Shared cross-toolchain fixture: local 2026-04-20 09:59 -> 2026-04-20T09-59.
            # The TypeScript counterpart is the formatWorktreeTimestamp Jest test (P2-T9).
            $fixedDate = [datetime]::new(2026, 4, 20, 9, 59, 37)
            $result = Get-WorktreeTimestamp -GetDateTime { $fixedDate }
            $result | Should -Be "2026-04-20T09-59"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Build-WorktreePath" {
    Context "Path construction" {
        It "output contains the nested repoName-wt/ grouping segment" {
            $result = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "2026-04-20T09-59" -RepoName "auth"
            $result | Should -Match "auth-wt/"
        }

        It "output ends with the timestamp leaf" {
            $result = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "2026-04-20T09-59" -RepoName "auth"
            $result | Should -Match "/2026-04-20T09-59$"
        }

        It "full path matches expected nested format" {
            $result = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "2026-04-20T09-59" -RepoName "auth"
            $result | Should -Be "/parent/auth-wt/2026-04-20T09-59"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Get-WorktreeGroupDirectory" {
    Context "Grouping directory derivation" {
        It "returns <parent>/<repoName>-wt" {
            $result = Get-WorktreeGroupDirectory -WorktreeParentPath "/parent" -RepoName "auth"
            $result | Should -Be "/parent/auth-wt"
        }

        It "Build-WorktreePath output starts with the grouping directory (no drift)" {
            $group = Get-WorktreeGroupDirectory -WorktreeParentPath "/parent" -RepoName "auth"
            $path = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "2026-04-20T09-59" -RepoName "auth"
            $path.StartsWith("$group/") | Should -BeTrue
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Build-BranchName" {
    Context "Branch name derivation" {
        It "returns flat repoName-wt-timestamp branch when BranchName is empty" {
            $result = Build-BranchName -Timestamp "2026-04-20T09-59" -RepoName "auth" -BranchName ""
            $result | Should -Be "auth-wt-2026-04-20T09-59"
        }

        It "returns a flat default branch containing no path separator" {
            $result = Build-BranchName -Timestamp "2026-04-20T09-59" -RepoName "auth" -BranchName ""
            $result | Should -Not -Match "/"
        }

        It "returns custom BranchName unchanged when supplied" {
            $result = Build-BranchName -Timestamp "2026-04-20T09-59" -RepoName "auth" -BranchName "fix/my-custom-branch"
            $result | Should -Be "fix/my-custom-branch"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Test-PreconditionsMet" {
    Context "Precondition failures" {
        It "throws when git is not on PATH" {
            {
                Test-PreconditionsMet `
                    -WorktreePath "/some/path" `
                    -GetCommand { param([string] $Name) $null = $Name; $null } `
                    -TestPath { param([string] $Path) $null = $Path; $false }
            } | Should -Throw "*git*"
        }

        It "throws when claude is not on PATH" {
            {
                Test-PreconditionsMet `
                    -WorktreePath "/some/path" `
                    -GetCommand {
                    param([string] $Name)
                    if ($Name -eq 'git') {
                        return [pscustomobject]@{ Name = 'git' }
                    }
                    return $null
                } `
                    -TestPath { param([string] $Path) $null = $Path; $false }
            } | Should -Throw "*claude*"
        }

        It "throws when target worktree path already exists" {
            {
                Test-PreconditionsMet `
                    -WorktreePath "/some/path" `
                    -GetCommand { param([string] $Name) $null = $Name; [pscustomobject]@{ Name = $Name } } `
                    -TestPath { param([string] $Path) $null = $Path; $true }
            } | Should -Throw "*already exists*"
        }

        It "does not throw when all preconditions pass" {
            {
                Test-PreconditionsMet `
                    -WorktreePath "/some/new/path" `
                    -GetCommand { param([string] $Name) $null = $Name; [pscustomobject]@{ Name = $Name } } `
                    -TestPath { param([string] $Path) $null = $Path; $false }
            } | Should -Not -Throw
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Invoke-GitWorktreeAdd" {
    Context "Git worktree add composition via injected scriptblock seam" {
        It "composes 'worktree add <path> -b <branch>' through the InvokeGit seam" {
            $script:capturedGitArgs = $null
            Invoke-GitWorktreeAdd `
                -WorktreePath "/parent/auth-wt/2026-04-20T09-59" `
                -BranchName "auth-wt-2026-04-20T09-59" `
                -InvokeGit { param([string[]] $GitArgs) $script:capturedGitArgs = $GitArgs }
            $captured = @($script:capturedGitArgs)
            $captured[0] | Should -Be 'worktree'
            $captured[1] | Should -Be 'add'
            $captured[2] | Should -Be '/parent/auth-wt/2026-04-20T09-59'
            $captured[3] | Should -Be '-b'
            $captured[4] | Should -Be 'auth-wt-2026-04-20T09-59'
        }

        It "passes exactly five arguments to the InvokeGit seam" {
            $script:capturedGitArgs = $null
            Invoke-GitWorktreeAdd `
                -WorktreePath "/work/path" `
                -BranchName "feature-branch" `
                -InvokeGit { param([string[]] $GitArgs) $script:capturedGitArgs = $GitArgs }
            @($script:capturedGitArgs).Count | Should -Be 5
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Start-ClaudeBackground" {
    Context "Process launch behavior" {
        BeforeEach {
            $script:capturedStartArgs = $null
        }

        It "does not include -Wait in the captured start arguments" {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            # Captured hashtable should not have a Wait key set to true
            ($script:capturedStartArgs.ContainsKey('Wait') -and $script:capturedStartArgs['Wait'] -eq $true) | Should -Be $false
        }

        It "passes --dangerously-skip-permissions in argument list" {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $script:capturedStartArgs['ArgumentList'] | Should -Contain '--dangerously-skip-permissions'
        }

        It "includes Objective in arguments when supplied" {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -Objective "Refactor auth module" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $script:capturedStartArgs['ArgumentList'] | Should -Contain "Refactor auth module"
        }

        It "returns the process object from InvokeStartProcess" {
            $fakeProcess = [pscustomobject]@{ Id = 99999 }
            $result = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $null = $StartArgs
                return $fakeProcess
            }
            $result.Id | Should -Be 99999
        }

        It "redirects stdout and stderr to distinct paths" {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $script:capturedStartArgs['RedirectStandardOutput'] | Should -Not -BeNullOrEmpty
            $script:capturedStartArgs['RedirectStandardError'] | Should -Not -BeNullOrEmpty
            $script:capturedStartArgs['RedirectStandardOutput'] | Should -Not -Be $script:capturedStartArgs['RedirectStandardError']
        }

        It "routes FilePath through cmd.exe on Windows" -Skip:(-not $IsWindows) {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $expectedFilePath = if ($env:ComSpec) { $env:ComSpec } else { 'cmd.exe' }
            $script:capturedStartArgs['FilePath'] | Should -Be $expectedFilePath
        }

        It "ArgumentList begins with /d /s /c claude on Windows" -Skip:(-not $IsWindows) {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $argumentList = @($script:capturedStartArgs['ArgumentList'])
            $argumentList[0] | Should -Be '/d'
            $argumentList[1] | Should -Be '/s'
            $argumentList[2] | Should -Be '/c'
            $argumentList[3] | Should -Be 'claude'
            $argumentList[4] | Should -Be '--dangerously-skip-permissions'
        }

        It "uses claude as FilePath on non-Windows hosts" -Skip:$IsWindows {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $script:capturedStartArgs['FilePath'] | Should -Be 'claude'
        }

        It "ArgumentList does not contain /c on non-Windows hosts" -Skip:$IsWindows {
            $null = Start-ClaudeBackground `
                -WorktreePath "/work/path" `
                -InvokeStartProcess {
                param([hashtable] $StartArgs)
                $script:capturedStartArgs = $StartArgs
                return [pscustomobject]@{ Id = 12345 }
            }
            $script:capturedStartArgs['ArgumentList'] | Should -Not -Contain '/c'
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Write-LaunchResult" {
    Context "Output format" {
        It "output contains a line starting with WorktreePath:" {
            $output = (Write-LaunchResult -WorktreePath "/some/path" -ProcessId "123" -StdoutLog "/some/path/claude-session.stdout.log" -StderrLog "/some/path/claude-session.stderr.log") -join "`n"
            $output | Should -Match "WorktreePath:"
        }

        It "output contains a line starting with ProcessId:" {
            $output = (Write-LaunchResult -WorktreePath "/some/path" -ProcessId "123" -StdoutLog "/some/path/claude-session.stdout.log" -StderrLog "/some/path/claude-session.stderr.log") -join "`n"
            $output | Should -Match "ProcessId:"
        }

        It "output contains a line starting with StdoutLog:" {
            $output = (Write-LaunchResult -WorktreePath "/some/path" -ProcessId "123" -StdoutLog "/some/path/claude-session.stdout.log" -StderrLog "/some/path/claude-session.stderr.log") -join "`n"
            $output | Should -Match "StdoutLog:"
        }

        It "output contains a line starting with StderrLog:" {
            $output = (Write-LaunchResult -WorktreePath "/some/path" -ProcessId "123" -StdoutLog "/some/path/claude-session.stdout.log" -StderrLog "/some/path/claude-session.stderr.log") -join "`n"
            $output | Should -Match "StderrLog:"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Integration Validation" {
    Context "Script structure" {
        It "contains all nine expected function definitions" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw

            $scriptContent | Should -Match "function Get-WorktreeTimestamp"
            $scriptContent | Should -Match "function Get-WorktreeGroupDirectory"
            $scriptContent | Should -Match "function Build-WorktreePath"
            $scriptContent | Should -Match "function Build-BranchName"
            $scriptContent | Should -Match "function New-WorktreeParentDirectory"
            $scriptContent | Should -Match "function Test-PreconditionsMet"
            $scriptContent | Should -Match "function Invoke-GitWorktreeAdd"
            $scriptContent | Should -Match "function Start-ClaudeBackground"
            $scriptContent | Should -Match "function Write-LaunchResult"
        }

        It "invokes New-WorktreeParentDirectory before Invoke-GitWorktreeAdd in the script body" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $parentInvokeIdx = $scriptContent.IndexOf('New-WorktreeParentDirectory -GroupDirectory $groupDirectory')
            $gitAddInvokeIdx = $scriptContent.IndexOf('Invoke-GitWorktreeAdd -WorktreePath $worktreePath')
            $parentInvokeIdx | Should -BeGreaterThan -1
            $gitAddInvokeIdx | Should -BeGreaterThan -1
            $parentInvokeIdx | Should -BeLessThan $gitAddInvokeIdx
        }
    }
}

Describe "new-claude-worktree-session.ps1 - New-WorktreeParentDirectory" {
    Context "Grouping-directory creation seam" {
        It "invokes the seam with the grouping-directory path" {
            $script:capturedPath = $null
            New-WorktreeParentDirectory `
                -GroupDirectory "/parent/auth-wt" `
                -NewDirectory { param([string] $Path) $script:capturedPath = $Path }
            $script:capturedPath | Should -Be "/parent/auth-wt"
        }

        It "succeeds without error when invoked twice for the same path (idempotent via seam)" {
            $script:seamCallCount = 0
            $seam = { param([string] $Path) $null = $Path; $script:seamCallCount++ }
            { New-WorktreeParentDirectory -GroupDirectory "/parent/auth-wt" -NewDirectory $seam } | Should -Not -Throw
            { New-WorktreeParentDirectory -GroupDirectory "/parent/auth-wt" -NewDirectory $seam } | Should -Not -Throw
            $script:seamCallCount | Should -Be 2
        }

        It "does not invoke the seam under -WhatIf" {
            $script:whatIfInvoked = $false
            New-WorktreeParentDirectory `
                -GroupDirectory "/parent/auth-wt" `
                -NewDirectory { param([string] $Path) $null = $Path; $script:whatIfInvoked = $true } `
                -WhatIf
            $script:whatIfInvoked | Should -BeFalse
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Template parity" {
    Context "Script and bundled template are content-identical" {
        It "bundled template content equals the script content" {
            $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "../../../extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1"
            $scriptContent = Get-Content -Path $script:scriptPath -Raw
            $templateContent = Get-Content -Path $templatePath -Raw
            $templateContent | Should -Be $scriptContent
        }
    }
}
