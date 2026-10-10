#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Entry-point exit-path tests for scripts/dev-tools/verify-host.ps1 (issue #847).

.DESCRIPTION
    Runs the entry script in-process with & against the real Invoke-HostVerification.
    The manifest read, the session Path seams, command and module discovery, and the
    poetry calls are mocked with -ModuleName HostVerification. The manifest fixture's
    requiredCommands omit bashdb and copilot, so the result does not depend on the host
    OS. The top-level default mocks throw for every host seam, so a test that reaches an
    unmocked seam fails. Each case sets a $LASTEXITCODE sentinel of 99 first.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostVerification.psm1").Path
    Import-Module $script:ModulePath -Force
    $script:entryPath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/verify-host.ps1").Path

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Set-HostEnvironmentVariable' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
}

AfterAll {
    Remove-Module HostVerification, HostTooling -ErrorAction SilentlyContinue
}

Describe 'verify-host.ps1 entry point' {
    BeforeEach {
        Mock -CommandName Read-HostToolsManifest -ModuleName HostVerification -MockWith {
            [pscustomobject]@{
                minimumVersions   = [pscustomobject]@{ python = '3.11'; poetry = '1.8'; pwsh = '7.4'; node = '20.0' }
                requiredCommands  = @('git', 'node')
                optionalCommands  = @('gh')
                powershellModules = @([pscustomobject]@{ name = 'Pester'; minimumVersion = '5.0.0' })
                pythonTools       = @('ruff')
            }
        }
        Mock -CommandName Get-SessionPathFromMachineAndUser -ModuleName HostVerification -MockWith { 'C:\machine;C:\user' }
        Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -MockWith { }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\tool.exe' } }
        Mock -CommandName Get-CommandVersion -ModuleName HostVerification -MockWith { [version]'99.0.0' }
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ IsAvailable = $true; Version = [version]'1.8.3'; Source = 'poetry' }
        }
        Mock -CommandName Get-Module -ModuleName HostVerification -MockWith { [pscustomobject]@{ Name = 'Pester'; Version = [version]'5.6.1' } }
        Mock -CommandName Invoke-PoetryCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Output = @('ruff 0.6.9'); ExitCode = 0 } }
    }

    It 'AC05-VERIFY-PASS-EXIT0 writes the passing report and returns exit code 0' {
        # Arrange
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global

        # Act
        $output = @(& $script:entryPath)

        # Assert
        $output[-1] | Should -BeExactly '[OK] Host verification passed'
        $output | Should -Contain 'Required commands:'
        $output | Should -Contain '  [OK] ruff: ruff 0.6.9'
        $LASTEXITCODE | Should -Be 0
        Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'Path' -and $Target -eq 'Process'
        }
    }

    It 'AC05-VERIFY-ONEFAIL-EXIT1 writes the one-issue summary and returns exit code 1' {
        # Arrange
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global
        Mock -CommandName Get-Module -ModuleName HostVerification -MockWith { }

        # Act
        $output = @(& $script:entryPath)

        # Assert
        $output | Should -Contain '  [FAIL] Pester: not found'
        $output | Should -Contain '[WARN] Host verification failed with 1 issue(s)'
        $output[-1] | Should -BeExactly 'Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply'
        $LASTEXITCODE | Should -Be 1
    }

    It 'AC05-VERIFY-NOMANIFEST-EXIT1 rethrows the missing-manifest terminating error and sets exit code 1' {
        # Arrange
        Set-Variable -Name LASTEXITCODE -Value 99 -Scope Global
        Mock -CommandName Read-HostToolsManifest -ModuleName HostVerification -MockWith { }

        # Act / Assert
        { & $script:entryPath } | Should -Throw -ExpectedMessage 'Manifest not found at*'
        $LASTEXITCODE | Should -Be 1
        Should -Invoke -CommandName Get-SessionPathFromMachineAndUser -ModuleName HostVerification -Times 0 -Exactly
    }
}
