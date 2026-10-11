#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for scripts/dev-tools/HostBootstrapWorkspace.psm1 (issue #847).

.DESCRIPTION
    Covers the workspace and project-repository functions and the named process
    wrappers that the HostBootstrap size contingency places in this module. Every
    host seam the module reaches is mocked with -ModuleName HostBootstrapWorkspace;
    the default mocks throw so reaching an unmocked seam fails the test. Fixtures are
    inline literals. No test runs a process or writes a file.
#>

BeforeAll {
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../scripts/dev-tools/HostBootstrapWorkspace.psm1").Path
    Import-Module $script:ModulePath -Force

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName New-Item -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: New-Item' }
    Mock -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapVerifyScript' }
}

AfterAll {
    Remove-Module HostBootstrapWorkspace, HostTooling -ErrorAction SilentlyContinue
}

Describe 'process wrappers' {
    Context 'Invoke-HostBootstrapGit' {
        It 'emits the git output when git exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('git fixture output'); ExitCode = 0 } }

            $actual = @(Invoke-HostBootstrapGit -GitArgs @('status'))

            $actual | Should -Be @('git fixture output')
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'git' -and ($ArgumentList -join ' ') -eq 'status' }
        }

        It 'throws when git exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 128 } }

            { Invoke-HostBootstrapGit -GitArgs @('clone', 'https://example.invalid/r.git') } | Should -Throw -ExpectedMessage 'git command failed with exit code 128'
        }
    }

    Context 'Invoke-HostBootstrapWinget' {
        It 'emits the winget output when winget exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('winget fixture output'); ExitCode = 0 } }

            $actual = @(Invoke-HostBootstrapWinget -WingetArgs @('install', '--id', 'Git.Git'))

            $actual | Should -Be @('winget fixture output')
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'winget' }
        }

        It 'throws when winget exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 5 } }

            { Invoke-HostBootstrapWinget -WingetArgs @('install') } | Should -Throw -ExpectedMessage 'winget command failed with exit code 5'
        }
    }

    Context 'Invoke-HostBootstrapNpm' {
        It 'emits the npm output when npm exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('npm fixture output'); ExitCode = 0 } }

            $actual = @(Invoke-HostBootstrapNpm -NpmArgs @('install', '-g', 'fixture'))

            $actual | Should -Be @('npm fixture output')
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'npm' }
        }

        It 'does not throw when npm exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('npm ERR! fixture'); ExitCode = 1 } }

            $actual = @(Invoke-HostBootstrapNpm -NpmArgs @('install'))

            $actual | Should -Be @('npm ERR! fixture')
        }
    }

    Context 'Invoke-HostBootstrapWsl' {
        It 'emits the wsl output when wsl exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('wsl fixture output'); ExitCode = 0 } }

            $actual = @(Invoke-HostBootstrapWsl -WslArgs @('--install', '--no-distribution'))

            $actual | Should -Be @('wsl fixture output')
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'wsl' }
        }

        It 'throws when wsl exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 1 } }

            { Invoke-HostBootstrapWsl -WslArgs @('--install') } | Should -Throw -ExpectedMessage 'wsl command failed with exit code 1'
        }
    }

    Context 'Invoke-HostBootstrapVerifyScript' {
        It 'invokes the given command path and returns its output' {
            # Arrange: the command path names Get-Location, which is mocked inside the
            # module, so the call operator resolves to the mock and starts no process.
            Mock -CommandName Get-Location -ModuleName HostBootstrapWorkspace -MockWith { 'verify fixture output' }

            # Act
            $actual = @(Invoke-HostBootstrapVerifyScript -ScriptPath 'Get-Location')

            # Assert
            $actual | Should -Be @('verify fixture output')
            Should -Invoke -CommandName Get-Location -ModuleName HostBootstrapWorkspace -Times 1 -Exactly
        }
    }

    Context 'Invoke-HostBootstrapPoetry' {
        It 'runs poetry directly when poetry is available and exits 0' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = 'C:\fixture\poetry.exe' } } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('poetry fixture output'); ExitCode = 0 } }

            $actual = @(Invoke-HostBootstrapPoetry -PoetryArgs @('install', '--no-interaction'))

            $actual | Should -Be @('poetry fixture output')
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'C:\fixture\poetry.exe' -and ($ArgumentList -join ' ') -eq 'install --no-interaction'
            }
        }

        It 'throws when poetry exits nonzero' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = 'C:\fixture\poetry.exe' } } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 2 } }

            { Invoke-HostBootstrapPoetry -PoetryArgs @('install') } | Should -Throw -ExpectedMessage 'poetry command failed with exit code 2'
        }

        It 'runs python -m poetry when poetry is missing and python exits 0' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @('python poetry fixture output'); ExitCode = 0 } }

            $actual = @(Invoke-HostBootstrapPoetry -PoetryArgs @('install', '--no-interaction'))

            $actual | Should -Be @('python poetry fixture output')
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'C:\fixture\python.exe' -and ($ArgumentList -join ' ') -eq '-m poetry install --no-interaction'
            }
        }

        It 'throws when python -m poetry exits nonzero' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = 'C:\fixture\python.exe' } } -ParameterFilter { $Name -eq 'python' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 3 } }

            { Invoke-HostBootstrapPoetry -PoetryArgs @('install') } | Should -Throw -ExpectedMessage 'python -m poetry failed with exit code 3'
        }

        It 'throws when neither poetry nor python is available' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { }

            { Invoke-HostBootstrapPoetry -PoetryArgs @('install') } | Should -Throw -ExpectedMessage 'python is required to execute poetry'
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
        }
    }
}

Describe 'Get-ProjectRepositoriesFromManifest' {
    It 'returns the projectRepositories entries when present' {
        $manifest = [pscustomobject]@{ projectRepositories = @([pscustomobject]@{ url = 'https://example.invalid/a.git' }, [pscustomobject]@{ url = 'https://example.invalid/b.git' }) }

        $actual = @(Get-ProjectRepositoriesFromManifest -Manifest $manifest)

        $actual.Count | Should -Be 2
        $actual[1].url | Should -BeExactly 'https://example.invalid/b.git'
    }

    It 'returns an empty list when projectRepositories is absent' {
        $manifest = [pscustomobject]@{ requiredCommands = @('git') }

        $actual = @(Get-ProjectRepositoriesFromManifest -Manifest $manifest)

        $actual.Count | Should -Be 0
    }
}

Describe 'Resolve-WorkspaceRoot' {
    It 'returns the current location when the path is blank' {
        Mock -CommandName Get-Location -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Path = 'C:\fixture\cwd' } }

        Resolve-WorkspaceRoot -WorkspaceRootPath '  ' | Should -BeExactly 'C:\fixture\cwd'
    }

    It 'returns the full form of an explicit path' {
        Resolve-WorkspaceRoot -WorkspaceRootPath 'C:\fixture\ws' | Should -BeExactly 'C:\fixture\ws'
    }
}

Describe 'Initialize-WorkspaceRoot' {
    It 'reports an existing workspace root without creating it' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }

        $actual = @(Initialize-WorkspaceRoot -WorkspaceRootPath 'C:\fixture\ws' -ApplyMode)

        $actual | Should -Be @('[OK] Workspace root exists: C:\fixture\ws')
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'reports the planned creation in dry run' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }

        $actual = @(Initialize-WorkspaceRoot -WorkspaceRootPath 'C:\fixture\ws')

        $actual | Should -Be @('- Would create workspace root: C:\fixture\ws')
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'creates the workspace root in apply mode' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        Mock -CommandName New-Item -ModuleName HostBootstrapWorkspace -MockWith { }

        $actual = @(Initialize-WorkspaceRoot -WorkspaceRootPath 'C:\fixture\ws' -ApplyMode)

        $actual | Should -Be @('[OK] Created workspace root: C:\fixture\ws')
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter { $Path -eq 'C:\fixture\ws' -and $ItemType -eq 'Directory' }
    }
}

Describe 'Sync-ProjectsFromManifest' {
    BeforeEach {
        Mock -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapGit' }
    }

    It 'throws when a project has no url' {
        $projects = @([pscustomobject]@{ name = 'no-url' })

        { Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\fixture\ws' } | Should -Throw -ExpectedMessage "Each projectRepositories entry must include a non-empty 'url'."
    }

    It 'derives the target path from the url in dry run' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\fixture\ws')

        $actual | Should -Be @('- Would clone https://example.invalid/org/sample-repo.git to C:\fixture\ws\sample-repo')
        Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'skips a project that is already present' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git'; targetPath = 'custom-dir' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\fixture\ws' -ApplyMode)

        $actual | Should -Be @('[OK] Project already present: C:\fixture\ws\custom-dir')
        Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'reports the planned clone with an explicit target path in dry run' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git'; targetPath = 'custom-dir' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\fixture\ws')

        $actual | Should -Be @('- Would clone https://example.invalid/org/sample-repo.git to C:\fixture\ws\custom-dir')
    }

    It 'clones the project through the git wrapper in apply mode' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        Mock -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -MockWith { }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\fixture\ws' -ApplyMode)

        $actual | Should -Be @('Cloning https://example.invalid/org/sample-repo.git into C:\fixture\ws\sample-repo')
        Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
            ($GitArgs -join '|') -eq 'clone|https://example.invalid/org/sample-repo.git|C:\fixture\ws\sample-repo'
        }
    }
}

Describe 'Resolve-ProjectRepoRoot' {
    It 'returns the full form of an explicit repo root' {
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })

        Resolve-ProjectRepoRoot -RepoRootPath 'C:\fixture\repo' -WorkspaceRootPath 'C:\fixture\ws' -Projects $projects | Should -BeExactly 'C:\fixture\repo'
    }

    It 'returns the default repo root when it contains pyproject.toml' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })
        $expected = (Resolve-Path "$PSScriptRoot/../../..").Path

        $actual = Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath 'C:\fixture\ws' -Projects $projects

        $actual | Should -BeExactly $expected
    }

    It 'returns the drm-copilot project target path under the workspace' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ name = 'drm-copilot'; url = 'https://example.invalid/drm-copilot.git'; targetPath = 'custom-dir' })

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath 'C:\fixture\ws' -Projects $projects | Should -BeExactly 'C:\fixture\ws\custom-dir'
    }

    It 'falls back to the drm-copilot folder name when the project target path is empty' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ name = 'drm-copilot'; url = 'https://example.invalid/drm-copilot.git'; targetPath = '' })

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath 'C:\fixture\ws' -Projects $projects | Should -BeExactly 'C:\fixture\ws\drm-copilot'
    }

    It 'returns an empty string when no root can be resolved' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath 'C:\fixture\ws' -Projects $projects | Should -BeExactly ''
    }
}
