#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Entry-point exit-path tests for scripts/dev-tools/bootstrap-host.ps1 (issue #847).

.DESCRIPTION
    Runs the entry script in-process with & and asserts its output and $LASTEXITCODE.
    Invoke-BootstrapHost is mocked at test scope, because the real orchestrator's
    $IsWindows default would make the outcome host-dependent. The top-level default
    mocks throw for every host seam the bootstrap modules can reach, so a test that
    reaches an unmocked seam fails. Each case sets a $LASTEXITCODE sentinel of 99 first.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostBootstrap.psm1").Path
    Import-Module $script:ModulePath -Force
    $script:entryPath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/bootstrap-host.ps1").Path

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

Describe 'bootstrap-host.ps1 entry point' {
    It 'AC05-BOOTSTRAP-DRYRUN-EXIT0 returns exit code 0 after a dry run and forwards every parameter' {
        # Arrange
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global
        Mock -CommandName Invoke-BootstrapHost -MockWith { Write-Output 'Dry run complete. Re-run with -Apply to install tools.' }

        # Act
        $output = @(& $script:entryPath -WorkspaceRoot 'C:\fixture\ws' -RepoRoot 'C:\fixture\repo' -EnableAutoResumeAfterReboot -SkipProjectPoetryInstall)

        # Assert
        $output | Should -Contain 'Dry run complete. Re-run with -Apply to install tools.'
        $LASTEXITCODE | Should -Be 0
        Should -Invoke -CommandName Invoke-BootstrapHost -Times 1 -Exactly -ParameterFilter {
            $WorkspaceRoot -eq 'C:\fixture\ws' -and
            $RepoRoot -eq 'C:\fixture\repo' -and
            -not $Apply -and
            $EnableAutoResumeAfterReboot -and
            $SkipProjectPoetryInstall
        }
    }

    It 'forwards -Apply to the orchestrator and leaves the unset switches off' {
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global
        Mock -CommandName Invoke-BootstrapHost -MockWith { }

        $null = & $script:entryPath -Apply

        $LASTEXITCODE | Should -Be 0
        Should -Invoke -CommandName Invoke-BootstrapHost -Times 1 -Exactly -ParameterFilter {
            $Apply -and -not $EnableAutoResumeAfterReboot -and -not $SkipProjectPoetryInstall -and $WorkspaceRoot -eq '' -and $RepoRoot -eq ''
        }
    }

    It 'AC05-BOOTSTRAP-NONWINDOWS-EXIT1 rethrows the non-Windows terminating error and sets exit code 1' {
        # Arrange
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global
        Mock -CommandName Invoke-BootstrapHost -MockWith {
            Write-Error -Message 'This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.' -ErrorAction Stop
        }

        # Act / Assert
        { & $script:entryPath } | Should -Throw -ExpectedMessage 'This script targets Windows. Use ./scripts/bash/bootstrap-host.sh on Linux/macOS.*'
        $LASTEXITCODE | Should -Be 1
    }

    It 'AC05-BOOTSTRAP-NOWINGET-EXIT1 rethrows the missing-winget terminating error and sets exit code 1' {
        # Arrange
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global
        Mock -CommandName Invoke-BootstrapHost -MockWith {
            Write-Error -Message 'winget is required on Windows. Install App Installer from Microsoft Store and rerun.' -ErrorAction Stop
        }

        # Act / Assert
        { & $script:entryPath } | Should -Throw -ExpectedMessage 'winget is required on Windows. Install App Installer from Microsoft Store and rerun.*'
        $LASTEXITCODE | Should -Be 1
    }

    It 'imports the module without running the orchestrator when dot-sourced' {
        Mock -CommandName Invoke-BootstrapHost -MockWith { throw 'orchestrator must not run when dot-sourced' }

        { . $script:entryPath } | Should -Not -Throw
        Should -Invoke -CommandName Invoke-BootstrapHost -Times 0 -Exactly
    }
}
