#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for Invoke-HostVerification in scripts/dev-tools/HostVerification.psm1
    (issue #847).

.DESCRIPTION
    Runs the real orchestrator with the manifest read, the session Path seams, and the
    five section functions mocked with -ModuleName HostVerification. The top-level
    default mocks throw, so a test that reaches an unmocked host seam fails. Every case
    passes -IsWindowsHost explicitly so no case depends on the host OS.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostVerification.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Set-HostEnvironmentVariable' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }

    $script:fixtureManifestPath = 'C:\fixture\host-tools.manifest.json'
    $script:banner = '========================================='
}

AfterAll {
    Remove-Module HostVerification, HostTooling -ErrorAction SilentlyContinue
}

Describe 'Invoke-HostVerification' {
    BeforeEach {
        Mock -CommandName Read-HostToolsManifest -ModuleName HostVerification -MockWith { [pscustomobject]@{ requiredCommands = @('git') } }
        Mock -CommandName Get-SessionPathFromMachineAndUser -ModuleName HostVerification -MockWith { 'C:\machine;C:\user' }
        Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -MockWith { }
        Mock -CommandName Test-HostCoreVersion -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [OK] python: 3.12.1 (>= 3.11)'); FailureCount = 0 } }
        Mock -CommandName Test-HostRequiredCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [OK] git: C:\fixture\git.exe'); FailureCount = 0 } }
        Mock -CommandName Test-HostOptionalCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [WARN] gh: not found (optional)'); FailureCount = 0 } }
        Mock -CommandName Test-HostPowerShellModule -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [OK] Pester: 5.6.1'); FailureCount = 0 } }
        Mock -CommandName Test-HostPoetryTool -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [OK] ruff: ruff 0.6.9'); FailureCount = 0 } }
    }

    Context 'manifest' {
        It 'AC06-VERIFY-NOMANIFEST-THROWS raises Manifest not found at the manifest path when the manifest is missing' {
            # Arrange
            Mock -CommandName Read-HostToolsManifest -ModuleName HostVerification -MockWith { }

            # Act / Assert
            { Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true } | Should -Throw -ExpectedMessage "Manifest not found at $($script:fixtureManifestPath)"
            Should -Invoke -CommandName Test-HostCoreVersion -ModuleName HostVerification -Times 0 -Exactly
        }

        It 'keeps the missing-manifest error terminating when the caller passes -ErrorAction SilentlyContinue' {
            Mock -CommandName Read-HostToolsManifest -ModuleName HostVerification -MockWith { }

            { Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true -ErrorAction SilentlyContinue } | Should -Throw -ExpectedMessage 'Manifest not found at*'
        }

        It 'reads the default manifest path when -ManifestPath is not supplied' {
            Mock -CommandName Get-HostToolsManifestPath -ModuleName HostVerification -MockWith { 'C:\fixture\default\host-tools.manifest.json' }

            $null = Invoke-HostVerification -IsWindowsHost $true

            Should -Invoke -CommandName Read-HostToolsManifest -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
                $Path -eq 'C:\fixture\default\host-tools.manifest.json'
            }
        }
    }

    Context 'session Path refresh' {
        It 'sets the Process Path from the Machine and User values' {
            $null = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Path' -and $Value -eq 'C:\machine;C:\user' -and $Target -eq 'Process'
            }
        }

        It 'leaves the Process Path unchanged when the session Path is empty' {
            Mock -CommandName Get-SessionPathFromMachineAndUser -ModuleName HostVerification -MockWith { '' }

            $null = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -Times 0 -Exactly
        }
    }

    Context 'report' {
        It 'AC06-VERIFY-SECTION-ORDER emits the banner, five headings, and item lines in the original order' {
            # Act
            $actual = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            # Assert
            $actual.Lines | Should -Be @(
                $script:banner,
                'Host Environment Verification',
                $script:banner,
                '',
                'Core versions:',
                '  [OK] python: 3.12.1 (>= 3.11)',
                '',
                'Required commands:',
                '  [OK] git: C:\fixture\git.exe',
                '',
                'Optional commands:',
                '  [WARN] gh: not found (optional)',
                '',
                'PowerShell modules:',
                '  [OK] Pester: 5.6.1',
                '',
                'Poetry quality tools:',
                '  [OK] ruff: ruff 0.6.9',
                '',
                $script:banner,
                '[OK] Host verification passed'
            )
        }

        It 'AC06-VERIFY-EXIT-BOUNDARY returns ExitCode 0 at zero failures and 1 at one failure' {
            # Act: zero failures.
            $passing = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            # Arrange / Act: one failure in one section.
            Mock -CommandName Test-HostPowerShellModule -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [FAIL] Pester: not found'); FailureCount = 1 } }
            $failing = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            # Assert
            $passing.ExitCode | Should -Be 0
            $failing.ExitCode | Should -Be 1
        }

        It 'emits the failure summary and the bootstrap hint when a check fails' {
            # Arrange
            Mock -CommandName Test-HostCoreVersion -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [FAIL] node: not found'); FailureCount = 1 } }
            Mock -CommandName Test-HostPoetryTool -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [FAIL] ruff: not available via poetry'); FailureCount = 1 } }

            # Act
            $actual = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            # Assert
            $actual.Lines[-2] | Should -BeExactly '[WARN] Host verification failed with 2 issue(s)'
            $actual.Lines[-1] | Should -BeExactly 'Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply'
            $actual.ExitCode | Should -Be 1
        }

        It 'emits the one-issue failure summary line' {
            Mock -CommandName Test-HostRequiredCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Lines = @('  [FAIL] git: not found'); FailureCount = 1 } }

            $actual = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $true

            $actual.Lines | Should -Contain '[WARN] Host verification failed with 1 issue(s)'
            $actual.Lines[-1] | Should -BeExactly 'Run: ./scripts/dev-tools/bootstrap-host.ps1 -Apply'
        }

        It 'passes the host flag to the required-command section' {
            $null = Invoke-HostVerification -ManifestPath $script:fixtureManifestPath -IsWindowsHost $false

            Should -Invoke -CommandName Test-HostRequiredCommand -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter { $IsWindowsHost -eq $false }
        }
    }
}
