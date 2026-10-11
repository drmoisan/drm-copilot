#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for Invoke-BootstrapHost in scripts/dev-tools/HostBootstrap.psm1
    (issue #847).

.DESCRIPTION
    Runs the real orchestrator and the real HostBootstrapWorkspace functions with every
    host seam mocked in both modules (-ModuleName HostBootstrap and
    -ModuleName HostBootstrapWorkspace). The top-level default mocks throw; each
    Describe re-registers the seams a run needs with inline literal fixtures. Every
    case passes -IsWindowsHost explicitly so no case depends on the host OS.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostBootstrap.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Set-HostEnvironmentVariable' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
    Mock -CommandName New-Item -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: New-Item' }
    Mock -CommandName New-ItemProperty -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: New-ItemProperty' }
    Mock -CommandName Remove-ItemProperty -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Remove-ItemProperty' }
    Mock -CommandName Install-Module -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Install-Module' }
    Mock -CommandName Push-Location -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Push-Location' }
    Mock -CommandName Pop-Location -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Pop-Location' }
    Mock -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapVerifyScript' }
    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName New-Item -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: New-Item' }
}

AfterAll {
    Remove-Module HostBootstrap, HostBootstrapWorkspace, HostTooling -ErrorAction SilentlyContinue
}

Describe 'Invoke-BootstrapHost' {
    BeforeEach {
        # HostBootstrap seams: winget and npm resolve; every other command is missing.
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith {
            param([string[]]$Name)
            $commandName = @($Name)[0]
            if ($commandName -in @('winget', 'npm')) {
                [pscustomobject]@{ Source = "C:\fixture\$commandName.exe" }
            }
        }
        Mock -CommandName Get-HostToolsManifestPath -ModuleName HostBootstrap -MockWith { 'C:\fixture\host-tools.manifest.json' }
        Mock -CommandName Read-HostToolsManifest -ModuleName HostBootstrap -MockWith {
            [pscustomobject]@{
                installPackages     = [pscustomobject]@{
                    windows = [pscustomobject]@{
                        winget = @([pscustomobject]@{ id = 'Git.Git'; name = 'git' }, [pscustomobject]@{ id = 'Python.Poetry'; name = 'poetry' })
                    }
                }
                powershellModules   = @([pscustomobject]@{ name = 'Pester'; minimumVersion = '5.9.0' })
                projectRepositories = @(
                    [pscustomobject]@{ name = 'sample-a'; url = 'https://example.invalid/org/sample-a.git' },
                    [pscustomobject]@{ name = 'sample-b'; url = 'https://example.invalid/org/sample-b.git' }
                )
            }
        }
        Mock -CommandName Get-SessionPathFromMachineAndUser -ModuleName HostBootstrap -MockWith { 'C:\machine;C:\user' }
        Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapNpm -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapPoetry -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Install-HostPowerShellModule -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Set-BootstrapResumeRunOnce -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Remove-BootstrapResumeRunOnce -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $true }
        Mock -CommandName Push-Location -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Pop-Location -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrap -MockWith { 'verify fixture output' }

        # HostBootstrapWorkspace seams: the workspace and clone targets are absent.
        Mock -CommandName Get-Location -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Path = 'C:\fixture\ws' } }
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        Mock -CommandName New-Item -ModuleName HostBootstrapWorkspace -MockWith { }
        Mock -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -MockWith { }
    }

    Context 'dry run' {
        It 'AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS performs no installs, registry writes, or clones and prints Would lines' {
            # Act
            $actual = @(Invoke-BootstrapHost -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            # Assert: the planned actions are reported.
            $actual | Should -Contain '- Would create workspace root: C:\fixture\ws'
            $actual | Should -Contain '- Would install WSL (requires elevation and may require reboot)'
            $actual | Should -Contain "- Would install git using winget id 'Git.Git'"
            $actual | Should -Contain '- Would install Graphite CLI: npm install -g @withgraphite/graphite-cli@1.7.14'
            $actual | Should -Contain '- Would install PowerShell modules: Pester 5.9.0'
            $actual | Should -Contain '- Would clone https://example.invalid/org/sample-a.git to C:\fixture\ws\sample-a'
            $actual | Should -Contain '- Would install Python project dependencies via poetry'
            $actual[-1] | Should -BeExactly 'Dry run complete. Re-run with -Apply to install tools.'

            # Assert: no install, registry write, clone, or directory creation occurred.
            foreach ($seam in @('Invoke-HostBootstrapWinget', 'Invoke-HostBootstrapWsl', 'Invoke-HostBootstrapNpm', 'Invoke-HostBootstrapPoetry', 'Install-HostPowerShellModule', 'Set-BootstrapResumeRunOnce', 'Remove-BootstrapResumeRunOnce', 'Invoke-HostBootstrapVerifyScript')) {
                Should -Invoke -CommandName $seam -ModuleName HostBootstrap -Times 0 -Exactly
            }
            Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
            Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
        }

        It 'AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -EnableAutoResumeAfterReboot' {
            $null = @(Invoke-BootstrapHost -IsWindowsHost $true -RepoRoot 'C:\fixture\repo' -EnableAutoResumeAfterReboot)

            Should -Invoke -CommandName Set-BootstrapResumeRunOnce -ModuleName HostBootstrap -Times 0 -Exactly
        }
    }

    Context 'failure paths' {
        It 'AC06-BOOTSTRAP-NOMANIFEST-THROWS throws when the host tools manifest is missing' {
            Mock -CommandName Read-HostToolsManifest -ModuleName HostBootstrap -MockWith { }

            { Invoke-BootstrapHost -IsWindowsHost $true -RepoRoot 'C:\fixture\repo' } | Should -Throw -ExpectedMessage 'Host tools manifest not found at C:\fixture\host-tools.manifest.json'
        }

        It 'AC06-BOOTSTRAP-PRECONDITION-ERRORS raises terminating errors for a non-Windows host and a missing winget' {
            # Act / Assert: non-Windows host.
            { Invoke-BootstrapHost -IsWindowsHost $false } | Should -Throw -ExpectedMessage 'This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.'

            # Arrange / Act / Assert: winget missing.
            Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }
            { Invoke-BootstrapHost -IsWindowsHost $true } | Should -Throw -ExpectedMessage 'winget is required on Windows. Install App Installer from Microsoft Store and rerun.'
            Should -Invoke -CommandName Read-HostToolsManifest -ModuleName HostBootstrap -Times 0 -Exactly
        }

        It 'keeps the non-Windows precondition terminating when the caller passes -ErrorAction SilentlyContinue' {
            { Invoke-BootstrapHost -IsWindowsHost $false -ErrorAction SilentlyContinue } | Should -Throw -ExpectedMessage 'This script targets Windows.*'
        }

        It 'propagates a terminating error raised by the verify script' {
            Mock -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrap -MockWith { throw 'verify fixture failure' }

            { Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo' } | Should -Throw -ExpectedMessage 'verify fixture failure'
        }
    }

    Context 'RunOnce resume' {
        It 'AC06-RUNONCE-SET-APPLY-AND-RESUME registers RunOnce with -Apply and -EnableAutoResumeAfterReboot' {
            $actual = @(Invoke-BootstrapHost -Apply -EnableAutoResumeAfterReboot -IsWindowsHost $true -WorkspaceRoot 'C:\fixture\ws' -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain '[INFO] Registered one-time bootstrap resume after reboot.'
            Should -Invoke -CommandName Set-BootstrapResumeRunOnce -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
                $ResumeArguments -eq '-WorkspaceRoot "C:\fixture\ws" -RepoRoot "C:\fixture\repo"'
            }
        }

        It 'AC06-RUNONCE-NOT-SET-WITHOUT-BOTH does not register RunOnce with only -Apply' {
            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Not -Contain '[INFO] Registered one-time bootstrap resume after reboot.'
            Should -Invoke -CommandName Set-BootstrapResumeRunOnce -ModuleName HostBootstrap -Times 0 -Exactly
            Should -Invoke -CommandName Remove-BootstrapResumeRunOnce -ModuleName HostBootstrap -Times 0 -Exactly
        }

        It 'AC06-RUNONCE-CLEARED-AFTER-APPLY clears RunOnce after a successful apply' {
            $actual = @(Invoke-BootstrapHost -Apply -EnableAutoResumeAfterReboot -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual[-1] | Should -BeExactly '[INFO] Cleared one-time bootstrap resume entry.'
            Should -Invoke -CommandName Remove-BootstrapResumeRunOnce -ModuleName HostBootstrap -Times 1 -Exactly
        }
    }

    Context 'apply' {
        It 'installs packages, modules, Graphite CLI, and clones projects' {
            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain 'Installing Graphite CLI via npm'
            Should -Invoke -CommandName Invoke-HostBootstrapNpm -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { ($NpmArgs -join ' ') -eq 'install -g @withgraphite/graphite-cli@1.7.14' }
            Should -Invoke -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 2 -Exactly
            Should -Invoke -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -Times 1 -Exactly
            Should -Invoke -CommandName Install-HostPowerShellModule -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $Name -eq 'Pester' -and $RequiredVersion -eq '5.9.0' }
            Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 2 -Exactly
            Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Path' -and $Value -eq 'C:\machine;C:\user' -and $Target -eq 'Process'
            }
        }

        It 'warns and skips Graphite CLI when npm is missing' {
            Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Source = 'C:\fixture\winget.exe' } } -ParameterFilter { $Name -eq 'winget' }
            Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { } -ParameterFilter { $Name -ne 'winget' }

            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain '[WARN] npm not found; Graphite CLI install skipped'
            Should -Invoke -CommandName Invoke-HostBootstrapNpm -ModuleName HostBootstrap -Times 0 -Exactly
        }

        It 'AC06-POETRY-PROJECT-INSTALL-WARNS reports a poetry project-install failure as a warning' {
            Mock -CommandName Invoke-HostBootstrapPoetry -ModuleName HostBootstrap -MockWith { throw 'poetry command failed with exit code 1' }

            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain 'Installing Python project dependencies via poetry in C:\fixture\repo'
            $actual | Should -Contain '[WARN] Poetry dependency install failed; python quality tools may be unavailable'
            Should -Invoke -CommandName Push-Location -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $Path -eq 'C:\fixture\repo' }
            Should -Invoke -CommandName Pop-Location -ModuleName HostBootstrap -Times 1 -Exactly
        }

        It 'warns when pyproject.toml is absent' {
            Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { -not (@($Path)[0] -like '*pyproject.toml') }

            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain '[WARN] pyproject.toml not found; skipping poetry project install'
            Should -Invoke -CommandName Invoke-HostBootstrapPoetry -ModuleName HostBootstrap -Times 0 -Exactly
        }

        It 'skips the project poetry install by request' {
            $actual = @(Invoke-BootstrapHost -Apply -SkipProjectPoetryInstall -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain '[INFO] Skipping project poetry install by request'
            Should -Invoke -CommandName Invoke-HostBootstrapPoetry -ModuleName HostBootstrap -Times 0 -Exactly
        }

        It 'warns and skips verification when verify-host.ps1 is absent' {
            Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { -not (@($Path)[0] -like '*verify-host.ps1') }

            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')

            $actual | Should -Contain '[WARN] verify-host.ps1 not found beside bootstrap-host.ps1; verification skipped'
            Should -Invoke -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrap -Times 0 -Exactly
        }

        It 'AC06-VERIFY-SCRIPT-EXITCODE-IGNORED invokes the sibling verify script by path and ignores its result' {
            # Arrange: the verify script reports a failure and leaves exit code 1 behind.
            Mock -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrap -MockWith {
                Set-Variable -Name LASTEXITCODE -Value 1 -Scope Global
                '[WARN] Host verification failed with 1 issue(s)'
            }

            # Act
            $actual = @(Invoke-BootstrapHost -Apply -IsWindowsHost $true -RepoRoot 'C:\fixture\repo')
            Set-Variable -Name LASTEXITCODE -Value 0 -Scope Global

            # Assert: bootstrap completed and reported the verify output.
            $actual | Should -Contain 'Running host verification'
            $actual | Should -Contain '[WARN] Host verification failed with 1 issue(s)'
            Should -Invoke -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
                ($ScriptPath -replace '\\', '/') -like '*/scripts/dev-tools/verify-host.ps1'
            }
        }
    }
}
