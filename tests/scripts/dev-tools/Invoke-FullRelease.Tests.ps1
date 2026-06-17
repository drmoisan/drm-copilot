Set-StrictMode -Version Latest

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
. (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../powershell/Support/TestHelpers.ps1"))

Describe "Invoke-FullRelease.ps1 - Invoke-FullReleaseGuarded" {
    BeforeAll {
        $script:scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/Invoke-FullRelease.ps1"
    }

    BeforeEach {
        # Import the functions under test from the production script (AST import,
        # no entry-point execution). Wrapper seams are imported before mocking.
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Write-StderrLine")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-GitExe")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-NpmExe")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-PublishScript")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-NpmVersion")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Get-McpServerTagName")
        . (Import-ScriptFunction -Path $script:scriptPath -Name "Invoke-FullReleaseGuarded")

        $script:capturedMessage = $null
        $script:capturedNpmArgs = $null
        $script:capturedGitArgsList = [System.Collections.Generic.List[object]]::new()
    }

    Context "confirmation guard" {
        It "returns 2 and invokes no bump/publish/tag wrapper when ConfirmToken is 'no'" {
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $null = $NpmArgs
                throw "npm wrapper should not be invoked"
            }
            Mock -CommandName Invoke-PublishScript -MockWith {
                param([string]$ScriptPath)
                $null = $ScriptPath
                throw "publish script should not be invoked"
            }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $null = $GitArgs
                throw "git wrapper should not be invoked"
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "no" -RepoRoot "/repo"

            $result | Should -Be 2
            $script:capturedMessage | Should -Match "Full release not confirmed \(got 'no'\)"
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }

        It "is case-sensitive: ConfirmToken 'YES' is rejected with code 2" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-PublishScript -MockWith { param([string]$ScriptPath) $null = $ScriptPath; throw "publish script should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "YES" -RepoRoot "/repo"

            $result | Should -Be 2
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }

        It "is case-sensitive: ConfirmToken 'Yes' is rejected with code 2" {
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-PublishScript -MockWith { param([string]$ScriptPath) $null = $ScriptPath; throw "publish script should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "Yes" -RepoRoot "/repo"

            $result | Should -Be 2
            Should -Invoke -CommandName Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-PublishScript -Times 0 -Exactly
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }

    Context "mcp-server manifest bump" {
        It "requests the patch bump with the expected npm wrapper arguments and uses the derived post-bump version" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-NpmExe -MockWith {
                param([string[]]$NpmArgs)
                $script:capturedNpmArgs = $NpmArgs
                return 0
            }
            # Deterministic post-bump version via stubbed manifest read (no disk access).
            Mock -CommandName Get-NpmVersion -MockWith { param([string]$ManifestPath) $null = $ManifestPath; return "0.0.2" }
            Mock -CommandName Invoke-PublishScript -MockWith { param([string]$ScriptPath) $null = $ScriptPath; return 0 }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                return 0
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            Should -Invoke -CommandName Invoke-NpmExe -Times 1 -Exactly
            ($script:capturedNpmArgs -contains "version") | Should -BeTrue
            ($script:capturedNpmArgs -contains "patch") | Should -BeTrue
            ($script:capturedNpmArgs -contains "--no-git-tag-version") | Should -BeTrue
            ($script:capturedNpmArgs -join " ") | Should -Match "packages[\\/]mcp-server"
            Get-NpmVersion -ManifestPath "/repo/packages/mcp-server/package.json" | Should -Be "0.0.2"
        }
    }

    Context "mcp-server tag derivation and push" {
        It "derives mcp-server-v0.0.2 from input 0.0.2 (pure function)" {
            Get-McpServerTagName -Version "0.0.2" | Should -Be "mcp-server-v0.0.2"
        }

        It "calls the git tag wrapper with the derived mcp-server-v0.0.2 tag on a confirmed run" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $true }
            Mock -CommandName Write-StderrLine -MockWith { param([string]$Message) $null = $Message }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; return 0 }
            Mock -CommandName Get-NpmVersion -MockWith { param([string]$ManifestPath) $null = $ManifestPath; return "0.0.2" }
            Mock -CommandName Invoke-PublishScript -MockWith { param([string]$ScriptPath) $null = $ScriptPath; return 0 }
            Mock -CommandName Invoke-GitExe -MockWith {
                param([string[]]$GitArgs)
                $script:capturedGitArgsList.Add($GitArgs)
                return 0
            }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/repo"

            $result | Should -Be 0
            $flattened = @($script:capturedGitArgsList | ForEach-Object { $_ }) -join " "
            $flattened | Should -Match "mcp-server-v0\.0\.2"
            # Both a tag-create and a tag-push call occurred.
            $script:capturedGitArgsList.Count | Should -Be 2
        }
    }

    Context "missing publish script" {
        It "returns 1, writes an error, and attempts no git tag push when the publish script is missing" {
            Mock -CommandName Test-Path -MockWith { param($LiteralPath) $null = $LiteralPath; return $false }
            Mock -CommandName Write-StderrLine -MockWith {
                param([string]$Message)
                $script:capturedMessage = $Message
            }
            Mock -CommandName Invoke-NpmExe -MockWith { param([string[]]$NpmArgs) $null = $NpmArgs; throw "npm wrapper should not be invoked" }
            Mock -CommandName Invoke-PublishScript -MockWith { param([string]$ScriptPath) $null = $ScriptPath; throw "publish script should not be invoked" }
            Mock -CommandName Invoke-GitExe -MockWith { param([string[]]$GitArgs) $null = $GitArgs; throw "git wrapper should not be invoked" }

            $result = Invoke-FullReleaseGuarded -ConfirmToken "yes" -RepoRoot "/nonexistent/repo"

            $result | Should -Be 1
            $script:capturedMessage | Should -Match "Publish script not found"
            Should -Invoke -CommandName Invoke-GitExe -Times 0 -Exactly
        }
    }
}
