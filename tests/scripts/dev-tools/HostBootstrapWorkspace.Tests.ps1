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

    # Portable fixture root: fully qualified on every host (the checkout drive on Windows,
    # '/' elsewhere) and never created; every fixture path and expectation is joined from it.
    $script:FixtureRoot = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'hostbootstrapworkspace-root'
    $script:Ws = Join-Path $script:FixtureRoot 'ws'
    $script:Repo = Join-Path $script:FixtureRoot 'repo'
    $script:Cwd = Join-Path $script:FixtureRoot 'cwd'
    $script:PoetryExe = Join-Path $script:FixtureRoot 'poetry.exe'
    $script:PythonExe = Join-Path $script:FixtureRoot 'python.exe'

    Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostNativeCommand' }
    Mock -CommandName New-Item -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: New-Item' }
    Mock -CommandName Invoke-HostBootstrapVerifyScript -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapVerifyScript' }
}

AfterAll {
    Remove-Module HostBootstrapWorkspace, HostTooling -ErrorAction SilentlyContinue
}

Describe 'process wrappers' {
    Context 'Invoke-HostBootstrapGit' {
        It 'AC11-GIT-STREAMS passes -StreamToHost and emits no captured output when git exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('git fixture output'); ExitCode = 0 }
            }

            @(Invoke-HostBootstrapGit -GitArgs @('status')).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'git' -and ($ArgumentList -join ' ') -eq 'status' -and $StreamToHost
            }
        }

        It 'throws when git exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 128 } }

            { Invoke-HostBootstrapGit -GitArgs @('clone', 'https://example.invalid/r.git') } | Should -Throw -ExpectedMessage 'git command failed with exit code 128'
        }
    }

    Context 'Invoke-HostBootstrapWinget' {
        It 'AC11-WINGET-STREAMS passes -StreamToHost and emits no captured output when winget exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('winget fixture output'); ExitCode = 0 }
            }

            @(Invoke-HostBootstrapWinget -WingetArgs @('install', '--id', 'Git.Git')).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'winget' -and $StreamToHost
            }
        }

        It 'throws when winget exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 5 } }

            { Invoke-HostBootstrapWinget -WingetArgs @('install') } | Should -Throw -ExpectedMessage 'winget command failed with exit code 5'
        }
    }

    Context 'Invoke-HostBootstrapNpm' {
        It 'AC11-NPM-STREAMS passes -StreamToHost and emits no captured output' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('npm fixture output'); ExitCode = 0 }
            }

            @(Invoke-HostBootstrapNpm -NpmArgs @('install', '-g', 'fixture')).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'npm' -and $StreamToHost
            }
        }

        It 'AC11-NPM-NONZERO-NO-THROW does not throw and emits nothing when npm exits nonzero' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('npm ERR! fixture'); ExitCode = 1 }
            }

            { $script:npmOutput = @(Invoke-HostBootstrapNpm -NpmArgs @('install')) } | Should -Not -Throw
            $script:npmOutput.Count | Should -Be 0
        }
    }

    Context 'Invoke-HostBootstrapWsl' {
        It 'AC11-WSL-STREAMS passes -StreamToHost and emits no captured output when wsl exits 0' {
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('wsl fixture output'); ExitCode = 0 }
            }

            @(Invoke-HostBootstrapWsl -WslArgs @('--install', '--no-distribution')).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'wsl' -and $StreamToHost
            }
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
        It 'AC11-POETRY-STREAMS passes -StreamToHost and emits no captured output when poetry exits 0' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = $script:PoetryExe } } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('poetry fixture output'); ExitCode = 0 }
            }

            @(Invoke-HostBootstrapPoetry -PoetryArgs @('install', '--no-interaction')).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq $script:PoetryExe -and ($ArgumentList -join ' ') -eq 'install --no-interaction' -and $StreamToHost
            }
        }

        It 'throws when poetry exits nonzero' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = $script:PoetryExe } } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Output = @(); ExitCode = 2 } }

            { Invoke-HostBootstrapPoetry -PoetryArgs @('install') } | Should -Throw -ExpectedMessage 'poetry command failed with exit code 2'
        }

        It 'AC11-PYTHON-POETRY-STREAMS passes -StreamToHost and emits no captured output when python -m poetry exits 0' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = $script:PythonExe } } -ParameterFilter { $Name -eq 'python' }
            Mock -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -MockWith {
                param([string]$FilePath, [string[]]$ArgumentList, [switch]$StreamToHost)
                $null = $FilePath
                $null = $ArgumentList
                $null = $StreamToHost
                [pscustomobject]@{ Output = @('python poetry fixture output'); ExitCode = 0 }
            }

            @(Invoke-HostBootstrapPoetry -PoetryArgs @('install', '--no-interaction')).Count | Should -Be 0
            Should -Invoke -CommandName Invoke-HostNativeCommand -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq $script:PythonExe -and ($ArgumentList -join ' ') -eq '-m poetry install --no-interaction' -and $StreamToHost
            }
        }

        It 'throws when python -m poetry exits nonzero' {
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { } -ParameterFilter { $Name -eq 'poetry' }
            Mock -CommandName Get-Command -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Source = $script:PythonExe } } -ParameterFilter { $Name -eq 'python' }
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
        Mock -CommandName Get-Location -ModuleName HostBootstrapWorkspace -MockWith { [pscustomobject]@{ Path = $script:Cwd } }

        Resolve-WorkspaceRoot -WorkspaceRootPath '  ' | Should -BeExactly $script:Cwd
    }

    It 'returns the full form of an explicit path' {
        Resolve-WorkspaceRoot -WorkspaceRootPath $script:Ws | Should -BeExactly $script:Ws
    }

    It 'resolves a relative path against the PowerShell location, not the process directory' {
        # Arrange: Set-Location does not move the process directory, so the two differ here
        # as they do after a location change in an interactive session.
        $priorProcessDirectory = [Environment]::CurrentDirectory
        Push-Location -LiteralPath $PSScriptRoot
        try {
            [Environment]::CurrentDirectory = [System.IO.Path]::GetPathRoot($PSScriptRoot)

            # Act
            $actual = Resolve-WorkspaceRoot -WorkspaceRootPath 'relative-ws'

            # Assert
            $actual | Should -BeExactly (Join-Path $PSScriptRoot 'relative-ws')
        }
        finally {
            [Environment]::CurrentDirectory = $priorProcessDirectory
            Pop-Location
        }
    }
}

Describe 'Initialize-WorkspaceRoot' {
    It 'reports an existing workspace root without creating it' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }

        $actual = @(Initialize-WorkspaceRoot -WorkspaceRootPath $script:Ws -ApplyMode)

        $actual | Should -Be @("[OK] Workspace root exists: $($script:Ws)")
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'reports the planned creation in dry run' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }

        $actual = @(Initialize-WorkspaceRoot -WorkspaceRootPath $script:Ws)

        $actual | Should -Be @("- Would create workspace root: $($script:Ws)")
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'creates the workspace root in apply mode' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        Mock -CommandName New-Item -ModuleName HostBootstrapWorkspace -MockWith { }

        $actual = @(Initialize-WorkspaceRoot -WorkspaceRootPath $script:Ws -ApplyMode)

        $actual | Should -Be @("[OK] Created workspace root: $($script:Ws)")
        Should -Invoke -CommandName New-Item -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Ws -and $ItemType -eq 'Directory' }
    }
}

Describe 'Sync-ProjectsFromManifest' {
    BeforeEach {
        Mock -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -MockWith { throw 'unmocked host seam: Invoke-HostBootstrapGit' }
    }

    It 'throws when a project has no url' {
        $projects = @([pscustomobject]@{ name = 'no-url' })

        { Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $script:Ws } | Should -Throw -ExpectedMessage "Each projectRepositories entry must include a non-empty 'url'."
    }

    It 'derives the target path from the url in dry run' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $script:Ws)

        $actual | Should -Be @("- Would clone https://example.invalid/org/sample-repo.git to $(Join-Path $script:Ws 'sample-repo')")
        Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'skips a project that is already present' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git'; targetPath = 'custom-dir' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $script:Ws -ApplyMode)

        $actual | Should -Be @("[OK] Project already present: $(Join-Path $script:Ws 'custom-dir')")
        Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 0 -Exactly
    }

    It 'reports the planned clone with an explicit target path in dry run' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git'; targetPath = 'custom-dir' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $script:Ws)

        $actual | Should -Be @("- Would clone https://example.invalid/org/sample-repo.git to $(Join-Path $script:Ws 'custom-dir')")
    }

    It 'clones the project through the git wrapper in apply mode' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        Mock -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -MockWith { }
        $projects = @([pscustomobject]@{ url = 'https://example.invalid/org/sample-repo.git' })

        $actual = @(Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath $script:Ws -ApplyMode)

        $actual | Should -Be @("Cloning https://example.invalid/org/sample-repo.git into $(Join-Path $script:Ws 'sample-repo')")
        Should -Invoke -CommandName Invoke-HostBootstrapGit -ModuleName HostBootstrapWorkspace -Times 1 -Exactly -ParameterFilter {
            ($GitArgs -join '|') -eq "clone|https://example.invalid/org/sample-repo.git|$(Join-Path $script:Ws 'sample-repo')"
        }
    }
}

Describe 'Resolve-ProjectRepoRoot' {
    It 'AC08-RESOLVE-EMPTY-PROJECTS returns the default repo root for an empty project list' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath $script:Ws -Projects @() | Should -BeExactly (Resolve-Path "$PSScriptRoot/../../..").Path
    }

    It 'returns the full form of an explicit repo root' {
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })

        Resolve-ProjectRepoRoot -RepoRootPath $script:Repo -WorkspaceRootPath $script:Ws -Projects $projects | Should -BeExactly $script:Repo
    }

    It 'resolves a relative explicit repo root against the PowerShell location, not the process directory' {
        # Arrange: the PowerShell location and the process directory differ.
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })
        $priorProcessDirectory = [Environment]::CurrentDirectory
        Push-Location -LiteralPath $PSScriptRoot
        try {
            [Environment]::CurrentDirectory = [System.IO.Path]::GetPathRoot($PSScriptRoot)

            # Act
            $actual = Resolve-ProjectRepoRoot -RepoRootPath 'relative-repo' -WorkspaceRootPath $script:Ws -Projects $projects

            # Assert
            $actual | Should -BeExactly (Join-Path $PSScriptRoot 'relative-repo')
        }
        finally {
            [Environment]::CurrentDirectory = $priorProcessDirectory
            Pop-Location
        }
    }

    It 'returns the default repo root when it contains pyproject.toml' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $true }
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })
        $expected = (Resolve-Path "$PSScriptRoot/../../..").Path

        $actual = Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath $script:Ws -Projects $projects

        $actual | Should -BeExactly $expected
    }

    It 'returns the drm-copilot project target path under the workspace' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ name = 'drm-copilot'; url = 'https://example.invalid/drm-copilot.git'; targetPath = 'custom-dir' })

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath $script:Ws -Projects $projects | Should -BeExactly (Join-Path $script:Ws 'custom-dir')
    }

    It 'falls back to the drm-copilot folder name when the project target path is empty' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ name = 'drm-copilot'; url = 'https://example.invalid/drm-copilot.git'; targetPath = '' })

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath $script:Ws -Projects $projects | Should -BeExactly (Join-Path $script:Ws 'drm-copilot')
    }

    It 'returns an empty string when no root can be resolved' {
        Mock -CommandName Test-Path -ModuleName HostBootstrapWorkspace -MockWith { $false }
        $projects = @([pscustomobject]@{ name = 'other'; url = 'https://example.invalid/other.git' })

        Resolve-ProjectRepoRoot -RepoRootPath '' -WorkspaceRootPath $script:Ws -Projects $projects | Should -BeExactly ''
    }
}
