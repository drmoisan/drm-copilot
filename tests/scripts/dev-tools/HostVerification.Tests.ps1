#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the helper and section functions in
    scripts/dev-tools/HostVerification.psm1 (issue #847).

.DESCRIPTION
    Every host seam reachable from HostVerification and from the HostTooling functions
    it calls is mocked; the top-level default mocks throw, so a test that reaches an
    unmocked seam fails. Each test re-registers the seams it exercises with inline
    literal fixtures. No test starts a process, writes a file, or changes the environment.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostVerification.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Set-HostEnvironmentVariable' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostVerification -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostTooling -MockWith { throw 'unmocked host seam: Get-HostEnvironmentVariable' }
}

AfterAll {
    Remove-Module HostVerification, HostTooling -ErrorAction SilentlyContinue
}

Describe 'Test-VersionAtLeast' {
    It 'returns $false when the actual version is $null' {
        Test-VersionAtLeast -Actual $null -Minimum '1.0' | Should -BeFalse
    }

    It 'returns $true when the actual version equals the minimum' {
        Test-VersionAtLeast -Actual ([version]'3.11.0') -Minimum '3.11.0' | Should -BeTrue
    }

    It 'returns $false when the actual version is lower than the minimum' {
        Test-VersionAtLeast -Actual ([version]'3.10.9') -Minimum '3.11' | Should -BeFalse
    }
}

Describe 'Get-RequiredCommandsForHost' {
    BeforeAll {
        $script:requiredManifest = [pscustomobject]@{ requiredCommands = @('git', 'bashdb', 'copilot', 'node') }
    }

    It 'filters bashdb and copilot on a Windows host' {
        $actual = Get-RequiredCommandsForHost -Manifest $script:requiredManifest -IsWindowsHost $true

        $actual | Should -Be @('git', 'node')
    }

    It 'returns every required command on a non-Windows host' {
        $actual = Get-RequiredCommandsForHost -Manifest $script:requiredManifest -IsWindowsHost $false

        $actual | Should -Be @('git', 'bashdb', 'copilot', 'node')
    }
}

Describe 'Get-PoetryVersionInfo' {
    It 'reports poetry from the poetry command' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\poetry.exe' } } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-CommandVersion -ModuleName HostVerification -MockWith { [version]'1.8.3' }

        # Act
        $actual = Get-PoetryVersionInfo

        # Assert
        $actual.IsAvailable | Should -BeTrue
        $actual.Version | Should -Be ([version]'1.8.3')
        $actual.Source | Should -BeExactly 'poetry'
        Should -Invoke -CommandName Get-CommandVersion -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter { $Command -eq 'poetry' }
    }

    It 'reports poetry through python -m poetry when poetry is not on PATH' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Output = @('Poetry (version 1.8.3)'); ExitCode = 0 } }

        # Act
        $actual = Get-PoetryVersionInfo

        # Assert
        $actual.IsAvailable | Should -BeTrue
        $actual.Version | Should -Be ([version]'1.8.3')
        $actual.Source | Should -BeExactly 'python -m poetry'
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'C:\fixture\python.exe' -and ($ArgumentList -join ' ') -eq '-m poetry --version' -and $MergeErrorStream
        }
    }

    It 'reports poetry unavailable when neither poetry nor python resolves' {
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null }

        $actual = Get-PoetryVersionInfo

        $actual.IsAvailable | Should -BeFalse
        $actual.Version | Should -BeNullOrEmpty
        $actual.Source | Should -BeExactly ''
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -Times 0 -Exactly
    }

    It 'reports poetry unavailable when python -m poetry exits nonzero' {
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Output = @('No module named poetry 1.0'); ExitCode = 1 } }

        $actual = Get-PoetryVersionInfo

        $actual.IsAvailable | Should -BeFalse
        $actual.Source | Should -BeExactly ''
    }

    It 'reports poetry unavailable when python -m poetry output has no version' {
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Output = @('Poetry (version unknown)'); ExitCode = 0 } }

        $actual = Get-PoetryVersionInfo

        $actual.IsAvailable | Should -BeFalse
        $actual.Version | Should -BeNullOrEmpty
    }
}

Describe 'Invoke-PoetryCommand' {
    It 'runs the poetry command with the given arguments' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\poetry.exe' } } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Output = @('ruff 0.6.9'); ExitCode = 0 } }

        # Act
        $actual = Invoke-PoetryCommand -PoetryArgs @('run', 'ruff', '--version')

        # Assert
        @($actual.Output) | Should -Be @('ruff 0.6.9')
        $actual.ExitCode | Should -Be 0
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'C:\fixture\poetry.exe' -and ($ArgumentList -join ' ') -eq 'run ruff --version' -and $MergeErrorStream
        }
    }

    It 'runs python -m poetry when poetry is not on PATH and returns the exit code' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -MockWith { [pscustomobject]@{ Output = @('Command not found: black'); ExitCode = 1 } }

        # Act
        $actual = Invoke-PoetryCommand -PoetryArgs @('run', 'black', '--version')

        # Assert
        $actual.ExitCode | Should -Be 1
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'C:\fixture\python.exe' -and ($ArgumentList -join ' ') -eq '-m poetry run black --version'
        }
    }

    It 'throws when neither poetry nor python resolves' {
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null }

        { Invoke-PoetryCommand -PoetryArgs @('--version') } | Should -Throw -ExpectedMessage 'poetry not found'
    }
}

Describe 'Test-HostCoreVersion' {
    BeforeAll {
        $script:coreManifest = [pscustomobject]@{
            minimumVersions = [pscustomobject]@{ python = '3.11'; poetry = '1.8'; pwsh = '7.4'; node = '20.0' }
        }
    }

    BeforeEach {
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith {
            param([string[]]$Name)
            [pscustomobject]@{ Source = "C:\fixture\$(@($Name)[0]).exe" }
        }
        Mock -CommandName Get-CommandVersion -ModuleName HostVerification -MockWith {
            param([string]$Command, [string[]]$VersionArgs)
            $null = $VersionArgs
            switch ($Command) {
                'python' { [version]'3.12.1' }
                'pwsh' { [version]'7.4.6' }
                default { [version]'20.11.0' }
            }
        }
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ IsAvailable = $true; Version = [version]'1.8.3'; Source = 'poetry' }
        }
    }

    It 'reports OK for every tool at or above its minimum' {
        $actual = Test-HostCoreVersion -Manifest $script:coreManifest

        $actual.Lines | Should -Be @(
            '  [OK] python: 3.12.1 (>= 3.11)',
            '  [OK] poetry: 1.8.3 (>= 1.8) via poetry',
            '  [OK] pwsh: 7.4.6 (>= 7.4)',
            '  [OK] node: 20.11.0 (>= 20.0)'
        )
        $actual.FailureCount | Should -Be 0
        Should -Invoke -CommandName Get-CommandVersion -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
            $Command -eq 'node' -and ($VersionArgs -join ' ') -eq '--version'
        }
    }

    It 'reports FAIL for a missing tool, a low version, and missing poetry' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -eq 'node' }
        Mock -CommandName Get-CommandVersion -ModuleName HostVerification -MockWith { [version]'3.10.0' } -ParameterFilter { $Command -eq 'python' }
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ IsAvailable = $false; Version = $null; Source = '' }
        }

        # Act
        $actual = Test-HostCoreVersion -Manifest $script:coreManifest

        # Assert
        $actual.Lines | Should -Be @(
            '  [FAIL] python: 3.10.0 (requires >= 3.11)',
            '  [FAIL] poetry: not found',
            '  [OK] pwsh: 7.4.6 (>= 7.4)',
            '  [FAIL] node: not found'
        )
        $actual.FailureCount | Should -Be 3
    }

    It 'reports FAIL for poetry below its minimum' {
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ IsAvailable = $true; Version = [version]'1.7.0'; Source = 'python -m poetry' }
        }

        $actual = Test-HostCoreVersion -Manifest $script:coreManifest

        $actual.Lines[1] | Should -BeExactly '  [FAIL] poetry: 1.7.0 (requires >= 1.8)'
        $actual.FailureCount | Should -Be 1
    }

    It 'reports the poetry source when poetry resolves through python -m poetry' {
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ IsAvailable = $true; Version = [version]'1.8.3'; Source = 'python -m poetry' }
        }

        $actual = Test-HostCoreVersion -Manifest $script:coreManifest

        $actual.Lines[1] | Should -BeExactly '  [OK] poetry: 1.8.3 (>= 1.8) via python -m poetry'
    }
}

Describe 'Test-HostRequiredCommand' {
    It 'reports OK for a resolved command and FAIL for a missing one' {
        # Arrange
        $manifest = [pscustomobject]@{ requiredCommands = @('git', 'bashdb', 'missingtool') }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\git.exe' } } -ParameterFilter { $Name -eq 'git' }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -ne 'git' }

        # Act
        $actual = Test-HostRequiredCommand -Manifest $manifest -IsWindowsHost $true

        # Assert
        $actual.Lines | Should -Be @('  [OK] git: C:\fixture\git.exe', '  [FAIL] missingtool: not found')
        $actual.FailureCount | Should -Be 1
        Should -Invoke -CommandName Get-Command -ModuleName HostVerification -Times 0 -Exactly -ParameterFilter { $Name -eq 'bashdb' }
    }
}

Describe 'Test-HostOptionalCommand' {
    It 'reports OK for a resolved command and WARN for a missing one without failures' {
        # Arrange
        $manifest = [pscustomobject]@{ optionalCommands = @('gh', 'gt') }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { [pscustomobject]@{ Source = 'C:\fixture\gh.exe' } } -ParameterFilter { $Name -eq 'gh' }
        Mock -CommandName Get-Command -ModuleName HostVerification -MockWith { $null } -ParameterFilter { $Name -eq 'gt' }

        # Act
        $actual = Test-HostOptionalCommand -Manifest $manifest

        # Assert
        $actual.Lines | Should -Be @('  [OK] gh: C:\fixture\gh.exe', '  [WARN] gt: not found (optional)')
        $actual.FailureCount | Should -Be 0
    }
}

Describe 'Test-HostPowerShellModule' {
    It 'reports OK for the newest installed version, FAIL below minimum, and FAIL when absent' {
        # Arrange
        $manifest = [pscustomobject]@{
            powershellModules = @(
                [pscustomobject]@{ name = 'Pester'; minimumVersion = '5.5.0' },
                [pscustomobject]@{ name = 'PSScriptAnalyzer'; minimumVersion = '1.22.0' },
                [pscustomobject]@{ name = 'AbsentModule'; minimumVersion = '1.0.0' }
            )
        }
        Mock -CommandName Get-Module -ModuleName HostVerification -MockWith {
            param([string[]]$Name, [switch]$ListAvailable)
            $null = $ListAvailable
            switch (@($Name)[0]) {
                'Pester' { [pscustomobject]@{ Version = [version]'5.4.0' }; [pscustomobject]@{ Version = [version]'5.6.1' } }
                'PSScriptAnalyzer' { [pscustomobject]@{ Version = [version]'1.21.0' } }
                default { }
            }
        }

        # Act
        $actual = Test-HostPowerShellModule -Manifest $manifest

        # Assert
        $actual.Lines | Should -Be @(
            '  [OK] Pester: 5.6.1',
            '  [FAIL] PSScriptAnalyzer: 1.21.0 (requires >= 1.22.0)',
            '  [FAIL] AbsentModule: not found'
        )
        $actual.FailureCount | Should -Be 2
    }
}

Describe 'Test-HostPoetryTool' {
    BeforeAll {
        $script:toolManifest = [pscustomobject]@{ pythonTools = @('ruff', 'black') }
    }

    It 'reports one failure when poetry is unavailable and runs no tool' {
        # Arrange
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith { [pscustomobject]@{ IsAvailable = $false; Version = $null; Source = '' } }
        Mock -CommandName Invoke-PoetryCommand -ModuleName HostVerification -MockWith { throw 'Invoke-PoetryCommand must not be called' }

        # Act
        $actual = Test-HostPoetryTool -Manifest $script:toolManifest

        # Assert
        $actual.Lines | Should -Be @('  [FAIL] poetry: not found (cannot verify Python tooling)')
        $actual.FailureCount | Should -Be 1
    }

    It 'reports the first non-blank output line for a passing tool and FAIL for a failing tool' {
        # Arrange
        Mock -CommandName Get-PoetryVersionInfo -ModuleName HostVerification -MockWith { [pscustomobject]@{ IsAvailable = $true; Version = [version]'1.8.3'; Source = 'poetry' } }
        Mock -CommandName Invoke-PoetryCommand -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ Output = @('', '   ', 'ruff 0.6.9', 'second line'); ExitCode = 0 }
        } -ParameterFilter { $PoetryArgs[1] -eq 'ruff' }
        Mock -CommandName Invoke-PoetryCommand -ModuleName HostVerification -MockWith {
            [pscustomobject]@{ Output = @('Command not found: black'); ExitCode = 1 }
        } -ParameterFilter { $PoetryArgs[1] -eq 'black' }

        # Act
        $actual = Test-HostPoetryTool -Manifest $script:toolManifest

        # Assert
        $actual.Lines | Should -Be @('  [OK] ruff: ruff 0.6.9', '  [FAIL] black: not available via poetry')
        $actual.FailureCount | Should -Be 1
        Should -Invoke -CommandName Invoke-PoetryCommand -ModuleName HostVerification -Times 1 -Exactly -ParameterFilter {
            ($PoetryArgs -join ' ') -eq 'run ruff --version'
        }
    }
}
