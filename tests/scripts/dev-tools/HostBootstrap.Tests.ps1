#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the HostBootstrap.psm1 functions other than Invoke-BootstrapHost
    (issue #847).

.DESCRIPTION
    Every host seam the module reaches is mocked with -ModuleName HostBootstrap; the
    default mocks throw so reaching an unmocked seam fails the test. Fixtures are
    inline literals. No test runs a process, writes the registry or an environment
    variable, installs a module, or writes a file. The process-wrapper tests live in
    HostBootstrapWorkspace.Tests.ps1 under the plan's HostBootstrap size contingency.
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
    Mock -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapWinget' }
    Mock -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapWsl' }
}

AfterAll {
    Remove-Module HostBootstrap, HostBootstrapWorkspace, HostTooling -ErrorAction SilentlyContinue
}

Describe 'Get-HostManifest' {
    BeforeEach {
        Mock -CommandName Get-HostToolsManifestPath -ModuleName HostBootstrap -MockWith { 'C:\fixture\host-tools.manifest.json' }
    }

    It 'returns the manifest when it is present' {
        Mock -CommandName Read-HostToolsManifest -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ requiredCommands = @('git') } }

        $actual = Get-HostManifest

        @($actual.requiredCommands) | Should -Be @('git')
        Should -Invoke -CommandName Read-HostToolsManifest -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $Path -eq 'C:\fixture\host-tools.manifest.json' }
    }

    It 'throws when the manifest is absent' {
        Mock -CommandName Read-HostToolsManifest -ModuleName HostBootstrap -MockWith { }

        { Get-HostManifest } | Should -Throw -ExpectedMessage 'Host tools manifest not found at C:\fixture\host-tools.manifest.json'
    }
}

Describe 'Install-WithWinget' {
    It 'reports an already installed package without calling winget' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Source = 'C:\fixture\git.exe' } }

        $actual = @(Install-WithWinget -Id 'Git.Git' -Name 'git' -ApplyMode)

        $actual | Should -Be @('[OK] git already installed')
        Should -Invoke -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'reports the planned install in dry run' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }

        $actual = @(Install-WithWinget -Id 'Git.Git' -Name 'git')

        $actual | Should -Be @("- Would install git using winget id 'Git.Git'")
        Should -Invoke -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'installs through the winget wrapper in apply mode' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -MockWith { 'winget fixture output' }

        $actual = @(Install-WithWinget -Id 'Git.Git' -Name 'git' -ApplyMode)

        $actual | Should -Be @('Installing git (Git.Git)', 'winget fixture output')
        Should -Invoke -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            ($WingetArgs -join ' ') -eq 'install --id Git.Git --exact --source winget --accept-source-agreements --accept-package-agreements'
        }
    }

    It 'AC06-POETRY-PIP-FALLBACK falls back to pip when the poetry winget install fails' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -MockWith { throw 'winget command failed with exit code 1' }
        Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -MockWith { 'pip fallback fixture' }

        $actual = @(Install-WithWinget -Id 'Python.Poetry' -Name 'poetry' -ApplyMode)

        $actual | Should -Contain '[WARN] winget install for poetry failed; trying python -m pip install --user poetry'
        $actual | Should -Contain 'pip fallback fixture'
        Should -Invoke -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $ApplyMode }
    }

    It 'AC06-NONPOETRY-RETHROW rethrows a winget failure for another package' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapWinget -ModuleName HostBootstrap -MockWith { throw 'winget command failed with exit code 1' }
        Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -MockWith { throw 'pip fallback must not run' }

        { Install-WithWinget -Id 'Git.Git' -Name 'git' -ApplyMode } | Should -Throw -ExpectedMessage 'winget command failed with exit code 1'
        Should -Invoke -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -Times 0 -Exactly
    }
}

Describe 'Install-PoetryWithPip' {
    It 'reports an already installed poetry' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Source = 'C:\fixture\poetry.exe' } }

        @(Install-PoetryWithPip -ApplyMode) | Should -Be @('[OK] poetry already installed')
    }

    It 'reports the planned install in dry run' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }

        @(Install-PoetryWithPip) | Should -Be @('- Would install poetry using python -m pip install --user poetry')
    }

    It 'throws when python is missing' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }

        { Install-PoetryWithPip -ApplyMode } | Should -Throw -ExpectedMessage 'python is required to install poetry fallback'
    }

    It 'throws when pip exits nonzero' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 1 } }

        { Install-PoetryWithPip -ApplyMode } | Should -Throw -ExpectedMessage 'Poetry fallback install failed with exit code 1'
    }

    It 'installs poetry, emits pip output, adds the poetry directory, and refreshes the session Path' {
        # Arrange
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { } -ParameterFilter { $Name -eq 'poetry' }
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
        Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Output = @('Successfully installed poetry-fixture-1.0'); ExitCode = 0 } }
        Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { 'C:\fixture\AppData' } -ParameterFilter { $Name -eq 'APPDATA' }
        Mock -CommandName Get-ChildItem -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Directory = [pscustomobject]@{ FullName = 'C:\fixture\AppData\Python\Scripts' } } }
        Mock -CommandName Add-DirectoryToUserPath -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Get-SessionPathFromMachineAndUser -ModuleName HostBootstrap -MockWith { 'C:\machine;C:\user' }
        Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { }

        # Act
        $actual = @(Install-PoetryWithPip -ApplyMode)

        # Assert
        $actual | Should -Be @('Installing poetry via python -m pip', 'Successfully installed poetry-fixture-1.0')
        Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'C:\fixture\python.exe' -and ($ArgumentList -join ' ') -eq '-m pip install --user poetry'
        }
        Should -Invoke -CommandName Get-ChildItem -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $Path -eq 'C:\fixture\AppData\Python' }
        Should -Invoke -CommandName Add-DirectoryToUserPath -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $DirectoryPath -eq 'C:\fixture\AppData\Python\Scripts' }
        Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'Path' -and $Value -eq 'C:\machine;C:\user' -and $Target -eq 'Process'
        }
    }
}

Describe 'Install-WslIfMissing' {
    It 'reports an already installed wsl' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { [pscustomobject]@{ Source = 'C:\fixture\wsl.exe' } }

        @(Install-WslIfMissing -ApplyMode) | Should -Be @('[OK] wsl already installed')
        Should -Invoke -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'reports the planned install in dry run' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }

        @(Install-WslIfMissing) | Should -Be @('- Would install WSL (requires elevation and may require reboot)')
        Should -Invoke -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'installs wsl through the wsl wrapper in apply mode' {
        Mock -CommandName Get-Command -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -MockWith { }

        @(Install-WslIfMissing -ApplyMode) | Should -Be @('Installing WSL (requires elevation and may require reboot)')
        Should -Invoke -CommandName Invoke-HostBootstrapWsl -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { ($WslArgs -join ' ') -eq '--install --no-distribution' }
    }
}

Describe 'Add-DirectoryToUserPath' {
    It 'writes nothing when the directory does not exist' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $false }

        Add-DirectoryToUserPath -DirectoryPath 'C:\fixture\missing'

        Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -Times 0 -Exactly
        Should -Invoke -CommandName Get-HostEnvironmentVariable -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'writes nothing when the directory is present with different case and a trailing backslash' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $true }
        Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { 'C:\Tools\Poetry\;C:\other' } -ParameterFilter { $Name -eq 'Path' -and $Target -eq 'User' }

        Add-DirectoryToUserPath -DirectoryPath 'c:\tools\poetry'

        Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'appends a new directory to the User Path once' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $true }
        Mock -CommandName Get-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { 'C:\a;C:\b' } -ParameterFilter { $Name -eq 'Path' -and $Target -eq 'User' }
        Mock -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -MockWith { }

        Add-DirectoryToUserPath -DirectoryPath 'C:\new'

        Should -Invoke -CommandName Set-HostEnvironmentVariable -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'Path' -and $Value -eq 'C:\a;C:\b;C:\new' -and $Target -eq 'User'
        }
    }
}

Describe 'Get-WingetPackagesFromManifest' {
    It 'throws when no winget packages are configured' {
        $manifest = [pscustomobject]@{ installPackages = [pscustomobject]@{ windows = [pscustomobject]@{ winget = @() } } }

        { Get-WingetPackagesFromManifest -Manifest $manifest } | Should -Throw -ExpectedMessage 'No Windows winget packages configured in host-tools.manifest.json (installPackages.windows.winget).'
    }

    It 'returns the configured winget packages' {
        $manifest = [pscustomobject]@{
            installPackages = [pscustomobject]@{
                windows = [pscustomobject]@{
                    winget = @([pscustomobject]@{ id = 'Git.Git'; name = 'git' }, [pscustomobject]@{ id = 'Python.Poetry'; name = 'poetry' })
                }
            }
        }

        $actual = @(Get-WingetPackagesFromManifest -Manifest $manifest)

        @($actual.id) | Should -Be @('Git.Git', 'Python.Poetry')
    }
}

Describe 'Get-BootstrapResumeArgument' {
    It 'includes all three values when set' {
        Get-BootstrapResumeArgument -WorkspaceRoot 'C:\ws' -RepoRoot 'C:\repo' -SkipProjectPoetryInstall | Should -BeExactly '-WorkspaceRoot "C:\ws" -RepoRoot "C:\repo" -SkipProjectPoetryInstall'
    }

    It 'returns an empty string when nothing is set' {
        Get-BootstrapResumeArgument | Should -BeExactly ''
    }

    It 'omits a whitespace-only workspace root' {
        Get-BootstrapResumeArgument -WorkspaceRoot '   ' -RepoRoot 'C:\repo' | Should -BeExactly '-RepoRoot "C:\repo"'
    }
}

Describe 'Set-BootstrapResumeRunOnce' {
    It 'creates the RunOnce key when absent and writes the resume command' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $false }
        Mock -CommandName New-Item -ModuleName HostBootstrap -MockWith { }
        Mock -CommandName New-ItemProperty -ModuleName HostBootstrap -MockWith { }

        Set-BootstrapResumeRunOnce -ResumeArguments '-RepoRoot "C:\repo"'

        Should -Invoke -CommandName New-Item -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' }
        Should -Invoke -CommandName New-ItemProperty -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'DrmCopilotHostBootstrapResume' -and $Value -like '*bootstrap-host.ps1" -Apply -EnableAutoResumeAfterReboot -RepoRoot "C:\repo"'
        }
    }

    It 'writes no RunOnce value under -WhatIf' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $true }

        Set-BootstrapResumeRunOnce -ResumeArguments '' -WhatIf

        Should -Invoke -CommandName New-ItemProperty -ModuleName HostBootstrap -Times 0 -Exactly
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrap -Times 0 -Exactly
    }
}

Describe 'Remove-BootstrapResumeRunOnce' {
    It 'does nothing when the RunOnce key is absent' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $false }

        Remove-BootstrapResumeRunOnce

        Should -Invoke -CommandName Remove-ItemProperty -ModuleName HostBootstrap -Times 0 -Exactly
    }

    It 'removes the resume value when the RunOnce key is present' {
        Mock -CommandName Test-Path -ModuleName HostBootstrap -MockWith { $true }
        Mock -CommandName Remove-ItemProperty -ModuleName HostBootstrap -MockWith { }

        Remove-BootstrapResumeRunOnce

        Should -Invoke -CommandName Remove-ItemProperty -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -and $Name -eq 'DrmCopilotHostBootstrapResume'
        }
    }
}

Describe 'Install-HostPowerShellModule' {
    It 'installs the module at the required version for the current user' {
        Mock -CommandName Install-Module -ModuleName HostBootstrap -MockWith { }

        Install-HostPowerShellModule -Name 'Pester' -RequiredVersion '5.9.0'

        Should -Invoke -CommandName Install-Module -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'Pester' -and $RequiredVersion -eq '5.9.0' -and $Scope -eq 'CurrentUser' -and $AllowClobber -and $Force
        }
    }
}
