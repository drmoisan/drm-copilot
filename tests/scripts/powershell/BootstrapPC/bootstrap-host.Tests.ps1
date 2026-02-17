Set-StrictMode -Version Latest

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
. (Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "../Support/TestHelpers.ps1"))

Describe "bootstrap-host.ps1" {
    BeforeAll {
        $script:scriptPath = Join-Path $PSScriptRoot '..\..\..\..\scripts\powershell\BootstrapPC\bootstrap-host.ps1' -Resolve

        # Dot-source the script so coverage is attributed to the source file.
        . $script:scriptPath
    }

    Context "Get-HostManifest" {
        It "returns parsed manifest object when file exists" {
            # Arrange
            Mock -CommandName Join-Path -MockWith { 'C:\repo\scripts\powershell\BootstrapPC\host-tools.manifest.json' }
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-Content -MockWith {
                '{"minimumVersions":{"python":"3.13.0"},"installPackages":{"windows":{"winget":[{"id":"X","name":"x"}]}}}'
            }

            # Act
            $result = Get-HostManifest

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.minimumVersions.python | Should -Be '3.13.0'
            $result.installPackages.windows.winget.Count | Should -Be 1
        }

        It "throws when manifest path does not exist" {
            # Arrange
            Mock -CommandName Join-Path -MockWith { 'C:\repo\scripts\powershell\BootstrapPC\host-tools.manifest.json' }
            Mock -CommandName Test-Path -MockWith { $false }

            # Act & Assert
            { Get-HostManifest } | Should -Throw -ExpectedMessage '*Host tools manifest not found*'
        }
    }

    Context "Get-WingetPackagesFromManifest" {
        It "returns winget packages when configured" {
            # Arrange
            $manifest = [pscustomobject]@{
                installPackages = [pscustomobject]@{
                    windows = [pscustomobject]@{
                        winget = @(
                            [pscustomobject]@{ id = 'Python.Python.3.13'; name = 'python' },
                            [pscustomobject]@{ id = 'Git.Git'; name = 'git' }
                        )
                    }
                }
            }

            # Act
            $result = Get-WingetPackagesFromManifest -Manifest $manifest

            # Assert
            $result.Count | Should -Be 2
            $result[0].id | Should -Be 'Python.Python.3.13'
            $result[1].name | Should -Be 'git'
        }

        It "throws when winget packages are missing" {
            # Arrange
            $manifest = [pscustomobject]@{
                installPackages = [pscustomobject]@{
                    windows = [pscustomobject]@{
                        winget = @()
                    }
                }
            }

            # Act & Assert
            { Get-WingetPackagesFromManifest -Manifest $manifest } |
                Should -Throw -ExpectedMessage '*No Windows winget packages configured*'
        }
    }

    Context "Install-WithWinget" {
        It "does not invoke winget when tool is already installed" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                [pscustomobject]@{ Source = 'C:\Tool\python.exe' }
            }
            Mock -CommandName Invoke-WingetExe -MockWith { }

            # Act
            Install-WithWinget -Id 'Python.Python.3.13' -Name 'python'

            # Assert
            Should -Invoke Invoke-WingetExe -Times 0 -Exactly
        }

        It "does not invoke winget during dry run when tool is missing" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Invoke-WingetExe -MockWith { }

            # Act
            Install-WithWinget -Id 'Git.Git' -Name 'git'

            # Assert
            Should -Invoke Invoke-WingetExe -Times 0 -Exactly
        }

        It "invokes winget with expected arguments when Apply is true" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Invoke-WingetExe -MockWith { }

            # Act
            Install-WithWinget -Id 'Git.Git' -Name 'git' -ApplyMode

            # Assert
            Should -Invoke Invoke-WingetExe -Times 1 -Exactly -ParameterFilter {
                ($WingetArgs -join ' ') -eq 'install --id Git.Git --exact --source winget --accept-source-agreements --accept-package-agreements'
            }
        }

        It "falls back to pip install when poetry winget install fails" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Invoke-WingetExe -MockWith { throw 'winget-failed' }
            Mock -CommandName Install-PoetryWithPip -MockWith { }

            # Act
            Install-WithWinget -Id 'Python.Poetry' -Name 'poetry' -ApplyMode

            # Assert
            Should -Invoke Install-PoetryWithPip -Times 1 -Exactly -ParameterFilter { $ApplyMode }
        }

        It "rethrows winget install failures for non-poetry packages" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Invoke-WingetExe -MockWith { throw 'winget-failed' }

            # Act & Assert
            { Install-WithWinget -Id 'Git.Git' -Name 'git' -ApplyMode } | Should -Throw -ExpectedMessage '*winget-failed*'
        }
    }

    Context "Wrapper seams" {
        It "forwards arguments to winget via Invoke-WingetExe" {
            # Arrange
            $script:capturedWingetArgs = @()

            function global:winget {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $script:capturedWingetArgs = @($Args)
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Invoke-WingetExe -WingetArgs @('install', '--id', 'Git.Git')

                # Assert
                $script:capturedWingetArgs | Should -Be @('install', '--id', 'Git.Git')
            }
            finally {
                Remove-Item -Path function:\winget -ErrorAction SilentlyContinue
            }
        }

        It "forwards arguments to npm via Invoke-NpmExe" {
            # Arrange
            $script:capturedNpmArgs = @()

            function global:npm {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $script:capturedNpmArgs = @($Args)
            }

            try {
                # Act
                Invoke-NpmExe -NpmArgs @('install', '-g', '@withgraphite/graphite-cli@1.7.14')

                # Assert
                $script:capturedNpmArgs | Should -Be @('install', '-g', '@withgraphite/graphite-cli@1.7.14')
            }
            finally {
                Remove-Item -Path function:\npm -ErrorAction SilentlyContinue
            }
        }

        It "forwards arguments to git via Invoke-GitExe" {
            # Arrange
            $script:capturedGitArgs = @()

            function global:git {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $script:capturedGitArgs = @($Args)
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Invoke-GitExe -GitArgs @('clone', 'https://github.com/drmoisan/drm-copilot.git', 'C:\bootstrap\drm-copilot')

                # Assert
                $script:capturedGitArgs | Should -Be @('clone', 'https://github.com/drmoisan/drm-copilot.git', 'C:\bootstrap\drm-copilot')
            }
            finally {
                Remove-Item -Path function:\git -ErrorAction SilentlyContinue
            }
        }

        It "forwards arguments to wsl via Invoke-WslExe" {
            # Arrange
            $script:capturedWslArgs = @()

            function global:wsl {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $script:capturedWslArgs = @($Args)
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Invoke-WslExe -WslArgs @('--install', '--no-distribution')

                # Assert
                $script:capturedWslArgs | Should -Be @('--install', '--no-distribution')
            }
            finally {
                Remove-Item -Path function:\wsl -ErrorAction SilentlyContinue
            }
        }

        It "executes verify script path via Invoke-VerifyHostScript" {
            # Arrange
            $verifyScript = Join-Path $PSScriptRoot '..\..\..\fixtures\shell_qc\scripts\pwsh_script.ps1' -Resolve

            # Act
            $result = Invoke-VerifyHostScript -ScriptPath $verifyScript

            # Assert
            $result | Should -Be 'not a shell script'
        }

        It "invokes poetry command directly when poetry is available" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'poetry') {
                    return [pscustomobject]@{ Source = 'poetry' }
                }

                return $null
            }

            $script:capturedPoetryArgs = @()
            function global:poetry {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $script:capturedPoetryArgs = @($Args)
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Invoke-PoetryExe -PoetryArgs @('install', '--no-interaction')

                # Assert
                $script:capturedPoetryArgs | Should -Be @('install', '--no-interaction')
            }
            finally {
                Remove-Item -Path function:\poetry -ErrorAction SilentlyContinue
            }
        }

        It "falls back to python -m poetry when poetry command is missing" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'python') {
                    return [pscustomobject]@{ Source = 'python' }
                }

                return $null
            }

            $script:capturedPythonArgs = @()
            function global:python {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $script:capturedPythonArgs = @($Args)
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Invoke-PoetryExe -PoetryArgs @('install', '--no-interaction')

                # Assert
                $script:capturedPythonArgs | Should -Be @('-m', 'poetry', 'install', '--no-interaction')
            }
            finally {
                Remove-Item -Path function:\python -ErrorAction SilentlyContinue
            }
        }

        It "throws when poetry execution via python fails" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'python') {
                    return [pscustomobject]@{ Source = 'python' }
                }

                return $null
            }

            function global:python {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $null = $Args
                $global:LASTEXITCODE = 1
            }

            try {
                # Act & Assert
                { Invoke-PoetryExe -PoetryArgs @('install', '--no-interaction') } | Should -Throw -ExpectedMessage '*python -m poetry failed*'
            }
            finally {
                Remove-Item -Path function:\python -ErrorAction SilentlyContinue
            }
        }

        It "throws when poetry and python are both missing" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }

            # Act & Assert
            { Invoke-PoetryExe -PoetryArgs @('install', '--no-interaction') } | Should -Throw -ExpectedMessage '*python is required to execute poetry*'
        }

        It "throws when poetry command exits with non-zero code" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'poetry') {
                    return [pscustomobject]@{ Source = 'poetry' }
                }

                return $null
            }

            function global:poetry {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $null = $Args
                $global:LASTEXITCODE = 1
            }

            try {
                # Act & Assert
                { Invoke-PoetryExe -PoetryArgs @('install', '--no-interaction') } | Should -Throw -ExpectedMessage '*poetry command failed*'
            }
            finally {
                Remove-Item -Path function:\poetry -ErrorAction SilentlyContinue
            }
        }

        It "throws when winget exits with non-zero code" {
            # Arrange
            function global:winget {
                $global:LASTEXITCODE = 1
            }

            try {
                # Act & Assert
                { Invoke-WingetExe -WingetArgs @('install', '--id', 'Git.Git') } | Should -Throw -ExpectedMessage '*winget command failed*'
            }
            finally {
                Remove-Item -Path function:\winget -ErrorAction SilentlyContinue
            }
        }

        It "throws when wsl exits with non-zero code" {
            # Arrange
            function global:wsl {
                $global:LASTEXITCODE = 1
            }

            try {
                # Act & Assert
                { Invoke-WslExe -WslArgs @('--install', '--no-distribution') } | Should -Throw -ExpectedMessage '*wsl command failed*'
            }
            finally {
                Remove-Item -Path function:\wsl -ErrorAction SilentlyContinue
            }
        }

        It "throws when git exits with non-zero code" {
            # Arrange
            function global:git {
                $global:LASTEXITCODE = 1
            }

            try {
                # Act & Assert
                { Invoke-GitExe -GitArgs @('clone', 'https://github.com/drmoisan/drm-copilot.git', 'C:\bootstrap\drm-copilot') } | Should -Throw -ExpectedMessage '*git command failed*'
            }
            finally {
                Remove-Item -Path function:\git -ErrorAction SilentlyContinue
            }
        }

    }

    Context "Project repository manifest helpers" {
        It "returns project repositories when configured" {
            # Arrange
            $manifest = [pscustomobject]@{
                projectRepositories = @(
                    [pscustomobject]@{ name = 'drm-copilot'; url = 'https://github.com/drmoisan/drm-copilot.git'; targetPath = 'drm-copilot' }
                )
            }

            # Act
            $result = Get-ProjectRepositoriesFromManifest -Manifest $manifest

            # Assert
            $result.Count | Should -Be 1
            $result[0].name | Should -Be 'drm-copilot'
        }

        It "returns empty array when project repositories are missing" {
            # Arrange
            $manifest = [pscustomobject]@{ minimumVersions = [pscustomobject]@{ python = '3.13.0' } }

            # Act
            $result = Get-ProjectRepositoriesFromManifest -Manifest $manifest

            # Assert
            @($result).Count | Should -Be 0
        }
    }

    Context "Workspace and project helpers" {
        It "uses current location when workspace root is not provided" {
            # Act
            $result = Resolve-WorkspaceRoot -WorkspaceRootPath ''

            # Assert
            $result | Should -Be (Get-Location).Path
        }

        It "resolves explicit workspace root path" {
            # Act
            $result = Resolve-WorkspaceRoot -WorkspaceRootPath '.\\'

            # Assert
            $result | Should -Not -BeNullOrEmpty
        }

        It "syncs projects via git clone in apply mode" {
            # Arrange
            $projects = @(
                [pscustomobject]@{ name = 'drm-copilot'; url = 'https://github.com/drmoisan/drm-copilot.git'; targetPath = 'drm-copilot' }
            )
            Mock -CommandName Join-Path -MockWith { 'C:\bootstrap\drm-copilot' }
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName Invoke-GitExe -MockWith { }

            # Act
            Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\bootstrap' -ApplyMode

            # Assert
            Should -Invoke Invoke-GitExe -Times 1 -Exactly -ParameterFilter {
                ($GitArgs -join ' ') -eq 'clone https://github.com/drmoisan/drm-copilot.git C:\bootstrap\drm-copilot'
            }
        }

        It "prints dry-run clone message when apply mode is false" {
            # Arrange
            $projects = @(
                [pscustomobject]@{ name = 'drm-copilot'; url = 'https://github.com/drmoisan/drm-copilot.git'; targetPath = 'drm-copilot' }
            )
            Mock -CommandName Join-Path -MockWith { 'C:\bootstrap\drm-copilot' }
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName Write-Output -MockWith { }
            Mock -CommandName Invoke-GitExe -MockWith { }

            # Act
            Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\bootstrap'

            # Assert
            Should -Invoke Invoke-GitExe -Times 0 -Exactly
            Should -Invoke Write-Output -Times 1 -ParameterFilter { $InputObject -like '- Would clone *' }
        }

        It "skips clone when project path already exists" {
            # Arrange
            $projects = @(
                [pscustomobject]@{ name = 'drm-copilot'; url = 'https://github.com/drmoisan/drm-copilot.git'; targetPath = 'drm-copilot' }
            )
            Mock -CommandName Join-Path -MockWith { 'C:\bootstrap\drm-copilot' }
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Invoke-GitExe -MockWith { }

            # Act
            Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\bootstrap' -ApplyMode

            # Assert
            Should -Invoke Invoke-GitExe -Times 0 -Exactly
        }

        It "throws when project entry is missing url" {
            # Arrange
            $projects = @(
                [pscustomobject]@{ name = 'missing-url'; targetPath = 'missing-url' }
            )

            # Act & Assert
            { Sync-ProjectsFromManifest -Projects $projects -WorkspaceRootPath 'C:\bootstrap' -ApplyMode } | Should -Throw -ExpectedMessage '*must include a non-empty ''url''*'
        }

        It "resolves repo root from explicit path" {
            # Arrange
            $projects = @([pscustomobject]@{ name = 'drm-copilot'; targetPath = 'drm-copilot' })

            # Act
            $result = Resolve-ProjectRepoRoot -RepoRootPath 'C:\repo' -WorkspaceRootPath 'C:\bootstrap' -Projects $projects

            # Assert
            $result | Should -Be ([System.IO.Path]::GetFullPath('C:\repo'))
        }

        It "resolves repo root from default script location when pyproject exists" {
            # Arrange
            $projects = @([pscustomobject]@{ name = 'drm-copilot'; targetPath = 'drm-copilot' })
            Mock -CommandName Test-Path -MockWith { $true }

            # Act
            $result = Resolve-ProjectRepoRoot -WorkspaceRootPath 'C:\bootstrap' -Projects $projects

            # Assert
            $result | Should -Not -BeNullOrEmpty
        }

        It "resolves repo root from manifest drm-copilot target path when default pyproject is missing" {
            # Arrange
            $projects = @([pscustomobject]@{ name = 'drm-copilot'; targetPath = 'drm-copilot' })
            Mock -CommandName Test-Path -MockWith { $false }

            # Act
            $result = Resolve-ProjectRepoRoot -WorkspaceRootPath 'C:\bootstrap' -Projects $projects

            # Assert
            $result | Should -Be ([System.IO.Path]::GetFullPath('C:\bootstrap\drm-copilot'))
        }

        It "returns empty repo root when neither default pyproject nor drm project target exists" {
            # Arrange
            $projects = @([pscustomobject]@{ name = 'other-project'; targetPath = 'other-project' })
            Mock -CommandName Test-Path -MockWith { $false }

            # Act
            $result = Resolve-ProjectRepoRoot -WorkspaceRootPath 'C:\bootstrap' -Projects $projects

            # Assert
            $result | Should -Be ''
        }

        It "creates workspace root in apply mode when missing" {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName New-Item -MockWith { }

            # Act
            Initialize-WorkspaceRoot -WorkspaceRootPath 'C:\bootstrap' -ApplyMode

            # Assert
            Should -Invoke New-Item -Times 1 -Exactly -ParameterFilter {
                $Path -eq 'C:\bootstrap' -and $ItemType -eq 'Directory' -and $Force
            }
        }

        It "reports dry-run workspace creation when apply mode is false and directory is missing" {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName New-Item -MockWith { }
            Mock -CommandName Write-Output -MockWith { }

            # Act
            Initialize-WorkspaceRoot -WorkspaceRootPath 'C:\bootstrap'

            # Assert
            Should -Invoke New-Item -Times 0 -Exactly
            Should -Invoke Write-Output -Times 1 -ParameterFilter { $InputObject -eq '- Would create workspace root: C:\bootstrap' }
        }

        It "reports workspace exists when path is already present" {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName New-Item -MockWith { }
            Mock -CommandName Write-Output -MockWith { }

            # Act
            Initialize-WorkspaceRoot -WorkspaceRootPath 'C:\bootstrap' -ApplyMode

            # Assert
            Should -Invoke New-Item -Times 0 -Exactly
            Should -Invoke Write-Output -Times 1 -ParameterFilter { $InputObject -eq '[OK] Workspace root exists: C:\bootstrap' }
        }
    }

    Context "Install-WslIfMissing" {
        It "returns when wsl is already installed" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                [pscustomobject]@{ Source = 'C:\Windows\System32\wsl.exe' }
            }
            Mock -CommandName Invoke-WslExe -MockWith { }

            # Act
            Install-WslIfMissing -ApplyMode

            # Assert
            Should -Invoke Invoke-WslExe -Times 0 -Exactly
        }

        It "writes dry-run message when apply mode is false" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Write-Output -MockWith { }
            Mock -CommandName Invoke-WslExe -MockWith { }

            # Act
            Install-WslIfMissing

            # Assert
            Should -Invoke Write-Output -Times 1 -Exactly -ParameterFilter {
                $InputObject -eq '- Would install WSL (requires elevation and may require reboot)'
            }
            Should -Invoke Invoke-WslExe -Times 0 -Exactly
        }

        It "invokes wsl install in apply mode when missing" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Invoke-WslExe -MockWith { }

            # Act
            Install-WslIfMissing -ApplyMode

            # Assert
            Should -Invoke Invoke-WslExe -Times 1 -Exactly -ParameterFilter {
                ($WslArgs -join ' ') -eq '--install --no-distribution'
            }
        }
    }

    Context "RunOnce resume helpers" {
        It "creates RunOnce resume entry when registry path is missing" {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName New-Item -MockWith { }
            Mock -CommandName Join-Path -MockWith { 'C:\repo\scripts\powershell\BootstrapPC\bootstrap-host.ps1' }
            Mock -CommandName New-ItemProperty -MockWith { }

            # Act
            Set-BootstrapResumeRunOnce -ResumeArguments '-WorkspaceRoot "C:\bootstrap"'

            # Assert
            Should -Invoke New-Item -Times 1 -Exactly
            Should -Invoke New-ItemProperty -Times 1 -Exactly -ParameterFilter {
                $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -and
                $Name -eq 'DrmCopilotHostBootstrapResume' -and
                $PropertyType -eq 'String' -and
                $Force
            }
        }

        It "removes RunOnce resume entry when registry path exists" {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Remove-ItemProperty -MockWith { }

            # Act
            Remove-BootstrapResumeRunOnce

            # Assert
            Should -Invoke Remove-ItemProperty -Times 1 -Exactly -ParameterFilter {
                $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -and
                $Name -eq 'DrmCopilotHostBootstrapResume'
            }
        }

        It "returns when RunOnce registry path does not exist" {
            # Arrange
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName Remove-ItemProperty -MockWith { }

            # Act
            Remove-BootstrapResumeRunOnce

            # Assert
            Should -Invoke Remove-ItemProperty -Times 0 -Exactly
        }
    }

    Context "Invoke-BootstrapHost" {
        BeforeEach {
            Mock -CommandName Get-HostManifest -MockWith {
                [pscustomobject]@{
                    installPackages   = [pscustomobject]@{
                        windows = [pscustomobject]@{
                            winget = @(
                                [pscustomobject]@{ id = 'Git.Git'; name = 'git' },
                                [pscustomobject]@{ id = 'GitHub.cli'; name = 'gh' }
                            )
                        }
                    }
                    powershellModules = @(
                        [pscustomobject]@{ name = 'PSScriptAnalyzer'; minimumVersion = '1.22.0' },
                        [pscustomobject]@{ name = 'Pester'; minimumVersion = '5.6.1' }
                    )
                }
            }

            Mock -CommandName Get-WingetPackagesFromManifest -MockWith {
                @(
                    [pscustomobject]@{ id = 'Git.Git'; name = 'git' },
                    [pscustomobject]@{ id = 'GitHub.cli'; name = 'gh' }
                )
            }
            Mock -CommandName Get-ProjectRepositoriesFromManifest -MockWith {
                @(
                    [pscustomobject]@{ name = 'drm-copilot'; url = 'https://github.com/drmoisan/drm-copilot.git'; targetPath = 'drm-copilot' }
                )
            }
            Mock -CommandName Resolve-WorkspaceRoot -MockWith { 'C:\bootstrap' }
            Mock -CommandName Initialize-WorkspaceRoot -MockWith { }
            Mock -CommandName Sync-ProjectsFromManifest -MockWith { }
            Mock -CommandName Resolve-ProjectRepoRoot -MockWith { 'C:\repo' }
            Mock -CommandName Install-WithWinget -MockWith { }
            Mock -CommandName Install-WslIfMissing -MockWith { }
            Mock -CommandName Install-Module -MockWith { }
            Mock -CommandName Invoke-NpmExe -MockWith { }
            Mock -CommandName Invoke-PoetryExe -MockWith { }
            Mock -CommandName Invoke-VerifyHostScript -MockWith { }
            Mock -CommandName Push-Location -MockWith { }
            Mock -CommandName Pop-Location -MockWith { }
            Mock -CommandName Join-Path -MockWith { 'C:\repo\scripts\powershell\BootstrapPC\verify-host.ps1' }
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Write-Output -MockWith { }
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'winget' -or $Name -eq 'npm') {
                    return [pscustomobject]@{ Source = "C:\tools\$Name.exe" }
                }

                return $null
            }
        }

        It "throws on non-Windows hosts" {
            # Arrange
            Mock -CommandName Write-Error -MockWith { throw 'non-windows' }

            # Act & Assert
            { Invoke-BootstrapHost -IsWindowsHost:$false } | Should -Throw -ExpectedMessage '*non-windows*'
        }

        It "throws when winget is missing" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Write-Error -MockWith { throw 'missing-winget' }

            # Act & Assert
            { Invoke-BootstrapHost -IsWindowsHost:$true } | Should -Throw -ExpectedMessage '*missing-winget*'
        }

        It "runs dry-run workflow and skips module install" {
            # Act
            Invoke-BootstrapHost -IsWindowsHost:$true

            # Assert
            Should -Invoke Install-WithWinget -Times 2 -Exactly
            Should -Invoke Install-WslIfMissing -Times 1 -Exactly
            Should -Invoke Initialize-WorkspaceRoot -Times 1 -Exactly
            Should -Invoke Sync-ProjectsFromManifest -Times 1 -Exactly
            Should -Invoke Install-Module -Times 0 -Exactly
            Should -Invoke Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke Invoke-PoetryExe -Times 0 -Exactly
        }

        It "runs apply workflow including npm and module install" {
            # Act
            Invoke-BootstrapHost -Apply -IsWindowsHost:$true

            # Assert
            Should -Invoke Install-WithWinget -Times 2 -Exactly
            Should -Invoke Install-WslIfMissing -Times 1 -Exactly -ParameterFilter { $ApplyMode }
            Should -Invoke Sync-ProjectsFromManifest -Times 1 -Exactly -ParameterFilter { $ApplyMode }
            Should -Invoke Install-Module -Times 2 -Exactly
            Should -Invoke Invoke-NpmExe -Times 1 -Exactly -ParameterFilter { ($NpmArgs -join ' ') -eq 'install -g @withgraphite/graphite-cli@1.7.14' }
            Should -Invoke Invoke-PoetryExe -Times 1 -Exactly -ParameterFilter { ($PoetryArgs -join ' ') -eq 'install --no-interaction' }
            Should -Invoke Invoke-VerifyHostScript -Times 1 -Exactly
        }

        It "handles missing npm by skipping npm install" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'winget') {
                    return [pscustomobject]@{ Source = 'C:\tools\winget.exe' }
                }

                return $null
            }

            # Act
            Invoke-BootstrapHost -Apply -IsWindowsHost:$true

            # Assert
            Should -Invoke Invoke-NpmExe -Times 0 -Exactly
            Should -Invoke Install-WslIfMissing -Times 1 -Exactly -ParameterFilter { $ApplyMode }
            Should -Invoke Sync-ProjectsFromManifest -Times 1 -Exactly -ParameterFilter { $ApplyMode }
            Should -Invoke Invoke-PoetryExe -Times 1 -Exactly
            Should -Invoke Write-Output -Times 1 -ParameterFilter { $InputObject -eq '[WARN] npm not found; Graphite CLI install skipped' }
            Should -Invoke Invoke-VerifyHostScript -Times 1 -Exactly
        }

        It "warns when poetry dependency install fails during apply" {
            # Arrange
            Mock -CommandName Invoke-PoetryExe -MockWith { throw 'poetry-install-failed' }

            # Act
            Invoke-BootstrapHost -Apply -IsWindowsHost:$true

            # Assert
            Should -Invoke Write-Output -Times 1 -ParameterFilter {
                $InputObject -eq '[WARN] Poetry dependency install failed; python quality tools may be unavailable'
            }
        }

        It "skips poetry install when skip switch is set" {
            # Act
            Invoke-BootstrapHost -Apply -SkipProjectPoetryInstall -IsWindowsHost:$true

            # Assert
            Should -Invoke Invoke-PoetryExe -Times 0 -Exactly
            Should -Invoke Write-Output -Times 1 -ParameterFilter { $InputObject -eq '[INFO] Skipping project poetry install by request' }
        }

        It "skips verify when verify script does not exist" {
            # Arrange
            Mock -CommandName Test-Path -MockWith {
                param([string]$Path)
                if ($Path -eq 'C:\repo\scripts\powershell\BootstrapPC\verify-host.ps1') {
                    return $false
                }

                return $true
            }

            # Act
            Invoke-BootstrapHost -Apply -IsWindowsHost:$true

            # Assert
            Should -Invoke Invoke-VerifyHostScript -Times 0 -Exactly
            Should -Invoke Write-Output -Times 1 -ParameterFilter { $InputObject -eq '[WARN] verify-host.ps1 not found beside bootstrap-host.ps1; verification skipped' }
        }
    }

    Context "Install-PoetryWithPip" {
        It "returns early when poetry is already installed" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                [pscustomobject]@{ Source = 'C:\tools\poetry.exe' }
            }

            # Act
            Install-PoetryWithPip -ApplyMode

            # Assert
            Should -Invoke Get-Command -Times 1 -Exactly
        }

        It "throws when python fallback command is missing" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }

            # Act & Assert
            { Install-PoetryWithPip -ApplyMode } | Should -Throw -ExpectedMessage '*python is required to install poetry fallback*'
        }

        It "writes dry-run install message when not in apply mode" {
            # Arrange
            Mock -CommandName Get-Command -MockWith { $null }
            Mock -CommandName Write-Output -MockWith { }

            # Act
            Install-PoetryWithPip

            # Assert
            Should -Invoke Write-Output -Times 1 -Exactly -ParameterFilter {
                $InputObject -eq '- Would install poetry using python -m pip install --user poetry'
            }
        }

        It "installs poetry via python and refreshes path in apply mode" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'python') {
                    return [pscustomobject]@{ Source = 'python' }
                }

                return $null
            }
            Mock -CommandName Get-SessionPathFromMachineAndUser -MockWith { 'C:\bin;C:\userbin' }
            Mock -CommandName Get-ChildItem -MockWith {
                [pscustomobject]@{
                    Directory = [pscustomobject]@{
                        FullName = 'C:\Users\test\AppData\Roaming\Python\Python313\Scripts'
                    }
                }
            }
            Mock -CommandName Add-DirectoryToUserPath -MockWith { }

            function global:python {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $null = $Args
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Install-PoetryWithPip -ApplyMode

                # Assert
                $env:Path | Should -Be 'C:\bin;C:\userbin'
                Should -Invoke Add-DirectoryToUserPath -Times 1 -Exactly -ParameterFilter {
                    $DirectoryPath -eq 'C:\Users\test\AppData\Roaming\Python\Python313\Scripts'
                }
                Should -Invoke Get-SessionPathFromMachineAndUser -Times 1 -Exactly
            }
            finally {
                Remove-Item -Path function:\python -ErrorAction SilentlyContinue
            }
        }

        It "skips user PATH update when poetry executable is not found after install" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'python') {
                    return [pscustomobject]@{ Source = 'python' }
                }

                return $null
            }
            Mock -CommandName Get-ChildItem -MockWith { @() }
            Mock -CommandName Add-DirectoryToUserPath -MockWith { }
            Mock -CommandName Get-SessionPathFromMachineAndUser -MockWith { 'C:\bin;C:\userbin' }

            function global:python {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $null = $Args
                $global:LASTEXITCODE = 0
            }

            try {
                # Act
                Install-PoetryWithPip -ApplyMode

                # Assert
                Should -Invoke Add-DirectoryToUserPath -Times 0 -Exactly
            }
            finally {
                Remove-Item -Path function:\python -ErrorAction SilentlyContinue
            }
        }

        It "throws when python pip poetry install fails" {
            # Arrange
            Mock -CommandName Get-Command -MockWith {
                param([string]$Name)
                if ($Name -eq 'python') {
                    return [pscustomobject]@{ Source = 'python' }
                }

                return $null
            }

            function global:python {
                param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
                $null = $Args
                $global:LASTEXITCODE = 1
            }

            try {
                # Act & Assert
                { Install-PoetryWithPip -ApplyMode } | Should -Throw -ExpectedMessage '*Poetry fallback install failed*'
            }
            finally {
                Remove-Item -Path function:\python -ErrorAction SilentlyContinue
            }
        }
    }
}

