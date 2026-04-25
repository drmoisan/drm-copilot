Set-StrictMode -Version Latest

BeforeAll {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    . (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))
    $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-claude-worktree-session.ps1"
}

Describe "new-claude-worktree-session.ps1 - Get-WorktreeTimestamp" {
    Context "Default timestamp generation" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-WorktreeTimestamp")
        }

        It "returns a non-empty string" {
            $result = Get-WorktreeTimestamp
            $result | Should -Not -BeNullOrEmpty
        }

        It "returns correct yyyyMMddHHmmss format for injected fixed datetime" {
            $fixedDate = [datetime]::new(2026, 4, 20, 9, 59, 37)
            $result = Get-WorktreeTimestamp -GetDateTime { $fixedDate }
            $result | Should -Be "20260420095937"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Build-WorktreePath" {
    Context "Path construction" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Build-WorktreePath")
        }

        It "output contains the drm-copilot-wt- prefix" {
            $result = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "20260420095937" -ShortName "auth"
            $result | Should -Match "drm-copilot-wt-"
        }

        It "output ends with the ShortName" {
            $result = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "20260420095937" -ShortName "auth"
            $result | Should -Match "-auth$"
        }

        It "full path matches expected format" {
            $result = Build-WorktreePath -WorktreeParentPath "/parent" -Timestamp "20260420095937" -ShortName "auth"
            $result | Should -Be "/parent/drm-copilot-wt-20260420095937-auth"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Build-BranchName" {
    Context "Branch name derivation" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Build-BranchName")
        }

        It "returns default feature branch when BranchName is empty" {
            $result = Build-BranchName -Timestamp "20260420095937" -ShortName "auth" -BranchName ""
            $result | Should -Be "feature/20260420095937-auth"
        }

        It "returns custom BranchName unchanged when supplied" {
            $result = Build-BranchName -Timestamp "20260420095937" -ShortName "auth" -BranchName "fix/my-custom-branch"
            $result | Should -Be "fix/my-custom-branch"
        }
    }
}

Describe "new-claude-worktree-session.ps1 - Test-PreconditionsMet" {
    Context "Precondition failures" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Test-PreconditionsMet")
        }

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

Describe "new-claude-worktree-session.ps1 - Start-ClaudeBackground" {
    Context "Process launch behavior" {
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Start-ClaudeBackground")
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
        BeforeEach {
            . (Import-ScriptFunction -Path $script:scriptPath -Name "Write-LaunchResult")
        }

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
        It "contains all seven expected function definitions" {
            $scriptContent = Get-Content -Path $script:scriptPath -Raw

            $scriptContent | Should -Match "function Get-WorktreeTimestamp"
            $scriptContent | Should -Match "function Build-WorktreePath"
            $scriptContent | Should -Match "function Build-BranchName"
            $scriptContent | Should -Match "function Test-PreconditionsMet"
            $scriptContent | Should -Match "function Invoke-GitWorktreeAdd"
            $scriptContent | Should -Match "function Start-ClaudeBackground"
            $scriptContent | Should -Match "function Write-LaunchResult"
        }
    }
}
