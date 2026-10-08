[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Stub function parameters mirror real command signatures for testing')]
param()

Set-StrictMode -Version Latest

BeforeAll {
    # Module-collision guard following the existing pattern in PoshQC.Comprehensive.Tests.ps1:
    # remove any PoshQC instance loaded from a path other than the repo-root module before
    # importing the repo-root copy, so exactly one PoshQC instance is loaded (issue #392).
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force
}

Describe 'Get-PoshQCCoverageConfigRoot (issue #527)' {
    # Every scenario injects the existence and read seams, so no scenario reads the real filesystem.
    BeforeAll {
        InModuleScope PoshQC {
            $script:cfgNewParameters = {
                @{
                    Root           = '/cfg-root'
                    TestPathExists = { param([string] $Path) ($Path -replace '\\', '/') -eq '/cfg-root/config/poshqc-coverage.json' }
                    ReadContent    = { param([string] $Path) [void] $Path; $script:cfgContent }
                }
            }
        }
    }

    It 'reports the configuration as absent when the file does not exist' {
        InModuleScope PoshQC {
            # Arrange: the read seam must not be reached when the file is absent.
            $parameters = & $script:cfgNewParameters
            $parameters.TestPathExists = { param([string] $Path) [void] $Path; $false }
            $parameters.ReadContent = { param([string] $Path) throw "ReadContent must not be called for $Path" }

            # Act
            $result = Get-PoshQCCoverageConfigRoot @parameters

            # Assert
            $result.Present | Should -BeFalse
            @($result.Roots).Count | Should -Be 0
        }
    }

    It 'returns the validated roots for a version 1 document' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:cfgNewParameters
            $script:cfgContent = '{"version": 1, "roots": ["scripts", ".claude/hooks"]}'

            # Act
            $result = Get-PoshQCCoverageConfigRoot @parameters

            # Assert
            $result.Present | Should -BeTrue
            $result.Roots | Should -Be @('scripts', '.claude/hooks')
        }
    }

    It 'fails fast naming config/poshqc-coverage.json for <Case>' -ForEach @(
        @{ Case = 'invalid JSON'; Content = '{"version": 1, "roots": [' }
        @{ Case = 'empty content'; Content = "   `n  " }
        @{ Case = 'unsupported version'; Content = '{"version": 2, "roots": ["scripts"]}' }
        @{ Case = 'missing roots'; Content = '{"version": 1}' }
        @{ Case = 'non-array roots'; Content = '{"version": 1, "roots": "scripts"}' }
        @{ Case = 'blank entry'; Content = '{"version": 1, "roots": ["scripts", "  "]}' }
        @{ Case = 'absolute entry'; Content = '{"version": 1, "roots": ["/abs/scripts"]}' }
        @{ Case = 'parent-traversal entry'; Content = '{"version": 1, "roots": ["scripts/../outside"]}' }
    ) {
        InModuleScope -ModuleName PoshQC -Parameters @{ Content = $Content } -ScriptBlock {
            param([string] $Content)

            # Arrange
            $parameters = & $script:cfgNewParameters
            $script:cfgContent = $Content

            # Act and Assert: every validation failure names the configuration file.
            { Get-PoshQCCoverageConfigRoot @parameters } | Should -Throw -ExpectedMessage '*config/poshqc-coverage.json*'
        }
    }
}

Describe 'Resolve-PoshQCCoveragePopulation precedence (issue #527)' {
    # Every scenario injects the config, file-set, and settings-existence seams; the file-set seam
    # wraps Get-PoshQCCoverageFileSet with in-memory existence and enumeration answers.
    BeforeAll {
        InModuleScope PoshQC {
            $script:resNewParameters = {
                @{
                    Root               = '/res-root'
                    Settings           = @{ Run = @{ Path = @('tests') }; CodeCoverage = @{ Enabled = $true } }
                    SettingsFile       = '/custom/pester.runsettings.psd1'
                    ScanFolderRoots    = @()
                    SettingsPathExists = { param([string] $Path) ($Path -replace '\\', '/') -notlike '*missing*' }
                    Logger             = { param([string] $Message) $script:resLogs.Add($Message) }
                    WarningLogger      = { param([string] $Message) $script:resWarnings.Add($Message) }
                    ReadConfig         = { param([string] $RootPath) [void] $RootPath; $script:resConfig }
                    GetFileSet         = {
                        param([string] $RootPath, [string[]] $Roots, [string[]] $Excluded, [scriptblock] $Warn)
                        $fileSetParameters = @{
                            Root           = $RootPath
                            Roots          = $Roots
                            ExcludeDirs    = $Excluded
                            WarningLogger  = $Warn
                            TestPathExists = { param([string] $Path) $script:resDirectories -contains (($Path -replace '\\', '/').TrimEnd('/')) }
                            EnumerateFiles = {
                                param([string] $Path)
                                $prefix = ($Path -replace '\\', '/').TrimEnd('/') + '/'
                                foreach ($fullName in $script:resFiles) {
                                    if ($fullName.StartsWith($prefix)) {
                                        [pscustomobject]@{ FullName = $fullName; Extension = [IO.Path]::GetExtension($fullName); Name = [IO.Path]::GetFileName($fullName) }
                                    }
                                }
                            }
                        }
                        Get-PoshQCCoverageFileSet @fileSetParameters
                    }
                }
            }
        }
    }

    BeforeEach {
        InModuleScope PoshQC {
            $script:resLogs = [System.Collections.Generic.List[string]]::new()
            $script:resWarnings = [System.Collections.Generic.List[string]]::new()
            $script:resConfig = [pscustomobject]@{ Present = $false; Roots = [string[]] @() }
            $script:resDirectories = @('/res-root/scripts', '/res-root/tools', '/res-root/tests')
            $script:resFiles = @('/res-root/scripts/a.ps1', '/res-root/tools/t.ps1', '/res-root/tests/x.ps1')
        }
    }

    It 'honors a non-empty CodeCoverage.Path from a caller-supplied settings file over the workspace config' {
        InModuleScope PoshQC {
            # Arrange: a workspace config exists, but the custom settings list takes precedence.
            $parameters = & $script:resNewParameters
            $parameters.Settings = @{ CodeCoverage = @{ Enabled = $true; Path = @('scripts/a.ps1', '/abs/b.ps1') } }
            $script:resConfig = [pscustomobject]@{ Present = $true; Roots = [string[]] @('tools') }

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert: a relative entry is joined to the root; a rooted entry is kept as written.
            $result.Source | Should -Be 'settings'
            @($result.Paths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/res-root/scripts/a.ps1', '/abs/b.ps1')
        }
    }

    It 'prunes and logs each nonexistent caller-supplied settings path' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:resNewParameters
            $parameters.Settings = @{ CodeCoverage = @{ Enabled = $true; Path = @('scripts/a.ps1', 'scripts/missing-one.ps1', '/abs/missing-two.ps1') } }

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert: survivors keep their order and every pruned path is logged individually.
            $result.Source | Should -Be 'settings'
            @($result.Paths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/res-root/scripts/a.ps1')
            $pruneLines = @($script:resLogs | Where-Object { $_ -like 'Pruned nonexistent code coverage path:*' } | ForEach-Object { $_ -replace '\\', '/' })
            $pruneLines | Should -Be @('Pruned nonexistent code coverage path: /res-root/scripts/missing-one.ps1', 'Pruned nonexistent code coverage path: /abs/missing-two.ps1')
        }
    }

    It 'ignores CodeCoverage.Path in the module-default settings file and logs that it was ignored' {
        InModuleScope PoshQC {
            # Arrange: the settings file is the module default, so its list is not honored.
            $parameters = & $script:resNewParameters
            $parameters.Settings = @{ CodeCoverage = @{ Enabled = $true; Path = @('scripts/a.ps1') } }
            $parameters.DefaultSettingsFile = $parameters.SettingsFile
            $script:resConfig = [pscustomobject]@{ Present = $true; Roots = [string[]] @('tools') }

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert
            $result.Source | Should -Be 'config'
            @($result.Paths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/res-root/tools/t.ps1')
            $script:resLogs | Should -Contain 'Ignored CodeCoverage.Path from the module-default settings file; the coverage population is derived from the workspace.'
        }
    }

    It 'uses the workspace config roots over the fallback scan folders' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:resNewParameters
            $parameters.ScanFolderRoots = @('scripts')
            $script:resConfig = [pscustomobject]@{ Present = $true; Roots = [string[]] @('tools') }

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert
            $result.Source | Should -Be 'config'
            @($result.Paths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/res-root/tools/t.ps1')
        }
    }

    It 'falls back to the scan-folder roots when no workspace config exists' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:resNewParameters
            $parameters.ScanFolderRoots = @('scripts')

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert
            $result.Source | Should -Be 'fallback'
            @($result.Paths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/res-root/scripts/a.ps1')
        }
    }

    It 'falls back to the settings Run.Path when no scan folders are supplied' {
        InModuleScope PoshQC {
            # Arrange: no config and no scan folders; the settings Run.Path names the tools folder.
            $parameters = & $script:resNewParameters
            $parameters.Settings = @{ Run = @{ Path = @('tools') }; CodeCoverage = @{ Enabled = $true } }

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert
            $result.Source | Should -Be 'fallback'
            @($result.Paths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/res-root/tools/t.ps1')
        }
    }

    It 'returns source config with an empty population when every configured root is missing' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:resNewParameters
            $script:resConfig = [pscustomobject]@{ Present = $true; Roots = [string[]] @('gone', 'absent') }

            # Act
            $result = Resolve-PoshQCCoveragePopulation @parameters

            # Assert: the empty set is reported as config-sourced, with one warning per missing root.
            $result.Source | Should -Be 'config'
            $paths = @($result.Paths)
            $paths | Should -Be @()
            $script:resWarnings.Count | Should -Be 2
        }
    }
}
