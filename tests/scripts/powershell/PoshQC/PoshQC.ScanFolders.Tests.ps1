Set-StrictMode -Version Latest

BeforeAll {
    $modulePath = (Resolve-Path -Path (Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1')).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $modulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module $modulePath -Force
}

Describe 'Get-PoshQCFileList scan-folder support' {
    It 'enumerates only the selected workspace folders' {
        $script:enumeratedRoots = @()

        $result = Get-PoshQCFileList -Root '/repo' -ScanFolders @('src', 'tests/powershell') -ResolvePath {
            param([string] $Path)
            if ($Path -eq '/repo') {
                return [pscustomobject]@{ Path = '/repo' }
            }

            return [pscustomobject]@{ Path = $Path }
        } -ResolveScanFolders {
            param([string] $ResolvedRoot, [string[]] $Folders, [scriptblock] $ResolvePathFn)
            [void] $ResolvedRoot
            [void] $ResolvePathFn
            $Folders | ForEach-Object { "/repo/$_" }
        } -EnumerateFiles {
            param([string] $Path)
            $script:enumeratedRoots += $Path
            @([pscustomobject]@{ FullName = "$Path/file.ps1"; Extension = '.ps1' })
        }

        $script:enumeratedRoots | Should -Be @('/repo/src', '/repo/tests/powershell')
        $result | Should -HaveCount 2
    }

    It 'throws when a selected scan folder escapes the root' {
        InModuleScope PoshQC {
            { Resolve-PoshQCScanFolder -Root '/repo' -ScanFolders @('../outside') -ResolvePath {
                    param([string] $Path)
                    if ($Path -eq '/repo') {
                        return [pscustomobject]@{ Path = '/repo' }
                    }

                    return [pscustomobject]@{ Path = '/outside' }
                } } | Should -Throw "Scan folder '../outside' must resolve inside root '/repo'."
        }
    }

    It 'rejects blank scan-folder values' {
        InModuleScope PoshQC {
            {
                Resolve-PoshQCScanFolder -Root '/repo' -ScanFolders @('') -ResolvePath {
                    param([string] $Path)
                    [pscustomobject]@{ Path = $Path }
                }
            } | Should -Throw 'Scan folder values must not be blank.'
        }
    }

    It 'returns an empty array when selected scan roots contain no PowerShell files' {
        $result = Get-PoshQCFileList -Root '/repo' -ScanFolders @('src', 'tests') -ResolvePath {
            param([string] $Path)
            [pscustomobject]@{ Path = $Path }
        } -ResolveScanFolders {
            param([string] $ResolvedRoot, [string[]] $Folders, [scriptblock] $ResolvePathFn)
            [void] $ResolvedRoot
            [void] $ResolvePathFn
            $Folders | ForEach-Object { "/repo/$_" }
        } -EnumerateFiles {
            param([string] $Path)
            @([pscustomobject]@{ FullName = "$Path/readme.txt"; Extension = '.txt' })
        }

        $result | Should -BeNullOrEmpty
    }
}

Describe 'Invoke-PoshQCSuite' {
    It 'forwards the selected scan folders to format, analyze, and test' {
        InModuleScope PoshQC {
            Mock -CommandName Invoke-PoshQCFormat -MockWith {
                param(
                    [string] $Root,
                    [string[]] $ScanFolders,
                    [string] $SettingsPath,
                    [string[]] $ExcludeDirs
                )
                [void] $Root
                [void] $ScanFolders
                [void] $SettingsPath
                [void] $ExcludeDirs
            }
            Mock -CommandName Invoke-PoshQCAnalyze -MockWith {
                param(
                    [string] $Root,
                    [string[]] $ScanFolders,
                    [string] $SettingsPath,
                    [string[]] $ExcludeDirs
                )
                [void] $Root
                [void] $ScanFolders
                [void] $SettingsPath
                [void] $ExcludeDirs
            }
            Mock -CommandName Invoke-PoshQCTest -MockWith {
                param(
                    [string] $Root,
                    [string[]] $ScanFolders,
                    [string] $SettingsPath,
                    [string[]] $ExcludeDirs,
                    [switch] $DisableKoverageCopy,
                    [string] $KoverageOutputPath
                )
                [void] $Root
                [void] $ScanFolders
                [void] $SettingsPath
                [void] $ExcludeDirs
                [void] $DisableKoverageCopy
                [void] $KoverageOutputPath
            }

            Invoke-PoshQCSuite -Root '/repo' -ScanFolders @('/repo/src')

            Assert-MockCalled -CommandName Invoke-PoshQCFormat -Times 1 -Exactly -Scope It -ParameterFilter {
                $Root -eq '/repo' -and $ScanFolders.Count -eq 1 -and $ScanFolders[0] -eq '/repo/src'
            }
            Assert-MockCalled -CommandName Invoke-PoshQCAnalyze -Times 1 -Exactly -Scope It -ParameterFilter {
                $Root -eq '/repo' -and $ScanFolders.Count -eq 1 -and $ScanFolders[0] -eq '/repo/src'
            }
            Assert-MockCalled -CommandName Invoke-PoshQCTest -Times 1 -Exactly -Scope It -ParameterFilter {
                $Root -eq '/repo' -and $ScanFolders.Count -eq 1 -and $ScanFolders[0] -eq '/repo/src'
            }
        }
    }
}

Describe 'Invoke-PoshQCAnalyzeAutofix' {
    It 'applies fixes to selected scan folders, then reruns analysis' {
        $script:fixedFiles = @()
        $script:analysisInvocations = @()

        Invoke-PoshQCAnalyzeAutofix -Root '/repo' -ScanFolders @('/repo/src') -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -GetFileList {
            param([string] $RootPath, [string[]] $ScanFoldersPath, [string[]] $Excluded)
            [void] $RootPath
            [void] $ScanFoldersPath
            [void] $Excluded
            @(
                [pscustomobject]@{ FullName = '/repo/src/format.ps1'; Extension = '.ps1' },
                [pscustomobject]@{ FullName = '/repo/src/module.psm1'; Extension = '.psm1' }
            )
        } -FixFile {
            param([string] $Path, [string] $Settings)
            $script:fixedFiles += @($Path, $Settings)
        } -InvokeAnalyze {
            param([string] $RootPath, [string[]] $ScanFoldersPath, [string] $AnalyzeSettingsPath, [string[]] $Excluded)
            $script:analysisInvocations += , @($RootPath, $ScanFoldersPath[0], $AnalyzeSettingsPath, $Excluded.Count)
        } -Logger { param([string] $Message) [void] $Message }

        $script:fixedFiles | Should -Be @(
            '/repo/src/format.ps1', '/settings.psd1',
            '/repo/src/module.psm1', '/settings.psd1'
        )
        $script:analysisInvocations | Should -HaveCount 1
        $script:analysisInvocations[0][0] | Should -Be '/repo'
        $script:analysisInvocations[0][1] | Should -Be '/repo/src'
        $script:analysisInvocations[0][2] | Should -Be '/settings.psd1'
    }

    It 'preserves selected scan folders when it reruns analysis after autofix' {
        $script:rerunScanFolders = $null

        Invoke-PoshQCAnalyzeAutofix -Root '/repo' -ScanFolders @('/repo/src', '/repo/tests/powershell') -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -GetFileList {
            @([pscustomobject]@{ FullName = '/repo/src/file.ps1'; Extension = '.ps1' })
        } -FixFile {
            param([string] $Path, [string] $Settings)
            [void] $Path
            [void] $Settings
        } -InvokeAnalyze {
            param([string] $RootPath, [string[]] $ScanFoldersPath, [string] $AnalyzeSettingsPath, [string[]] $Excluded)
            [void] $RootPath
            [void] $AnalyzeSettingsPath
            [void] $Excluded
            $script:rerunScanFolders = $ScanFoldersPath
        } -Logger { param([string] $Message) [void] $Message }

        $script:rerunScanFolders | Should -Be @('/repo/src', '/repo/tests/powershell')
    }

    It 'still reruns analysis when no files are discovered' {
        $script:analysisRan = $false

        Invoke-PoshQCAnalyzeAutofix -Root '/repo' -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -GetFileList { @() } -FixFile { throw 'should not fix' } -InvokeAnalyze {
            param([string] $RootPath, [string[]] $ScanFoldersPath, [string] $AnalyzeSettingsPath, [string[]] $Excluded)
            [void] $RootPath
            [void] $ScanFoldersPath
            [void] $AnalyzeSettingsPath
            [void] $Excluded
            $script:analysisRan = $true
        } -Logger { param([string] $Message) [void] $Message }

        $script:analysisRan | Should -BeTrue
    }
}

Describe 'Invoke-PoshQCTest scan-folder support' {
    It 'overrides run paths and preserves configured coverage paths when scan folders are supplied' {
        $script:capturedRunPaths = $null
        $script:capturedCoveragePaths = $null

        Invoke-PoshQCTest -Root '/repo' -ScanFolders @('/repo/src', '/repo/tests/powershell') -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } -LoadSettings {
            @{
                Run          = @{ Path = @('tests') }
                Should       = @{ ErrorAction = 'Stop' }
                Output       = @{ Verbosity = 'Detailed' }
                TestResult   = @{ Enabled = $false }
                CodeCoverage = @{ Enabled = $true; Path = @('src/**/*.ps1'); OutputPath = 'artifacts/coverage.xml' }
            }
        } -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{
                    Path        = @{ Value = $Table.Run.Path }
                    ExcludePath = @{ Value = @() }
                }
                TestResult   = @{
                    Enabled    = @{ Value = $false }
                    OutputPath = @{ Value = $null }
                }
                CodeCoverage = @{
                    Enabled    = @{ Value = $true }
                    Path       = @{ Value = $Table.CodeCoverage.Path }
                    OutputPath = @{ Value = 'artifacts/coverage.xml' }
                }
                Output       = @{ Verbosity = 'Normal' }
            }
        } -EnsureResultPath { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } -ExpandRunPaths {
            param($cfg, [string] $RootPath, [string[]] $Excluded)
            [void] $RootPath
            [void] $Excluded
            $cfg
        } -ExpandCoveragePaths {
            param($cfg, [string] $RootPath)
            [void] $RootPath
            $cfg
        } -ResolveScanFolders {
            param([string] $RootPath, [string[]] $Folders)
            [void] $RootPath
            $Folders
        } -EnumerateTests {
            param([string[]] $Paths, [string[]] $Excluded, [scriptblock] $TestPathFn)
            [void] $Excluded
            [void] $TestPathFn
            $script:capturedRunPaths = $Paths
            @([pscustomobject]@{ FullName = '/repo/tests/test.Tests.ps1' })
        } -InvokePester {
            param($Config)
            $script:capturedCoveragePaths = $Config.CodeCoverage.Path
            [pscustomobject]@{
                Duration          = [timespan]::Zero
                PassedCount       = 1
                FailedCount       = 0
                SkippedCount      = 0
                InconclusiveCount = 0
                NotRunCount       = 0
                CodeCoverage      = [pscustomobject]@{ CoverageReport = 'Coverage: 100%' }
            }
        } -CopyCoverage {
            param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath)
            [void] $CoveragePath
            [void] $RepoRoot
            [void] $KoveragePath
        } -Logger { param([string] $Message) [void] $Message } | Out-Null

        $script:capturedRunPaths | Should -Be @('/repo/src', '/repo/tests/powershell')
        ($script:capturedCoveragePaths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/repo/src/**/*.ps1')
    }
}

Describe 'Invoke-PoshQCAnalyze scan-folder support' {
    It 'honors ScanFolders when requesting the file list' {
        $script:capturedAnalyzeRoot = $null
        $script:capturedAnalyzeScanFolders = $null

        Invoke-PoshQCAnalyze -Root '/repo' -ScanFolders @('/repo/src', '/repo/tests/powershell') -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -GetFileList {
            param([string] $RootPath, [string[]] $ScanFoldersPath, [string[]] $Excluded)
            [void] $Excluded
            $script:capturedAnalyzeRoot = $RootPath
            $script:capturedAnalyzeScanFolders = $ScanFoldersPath
            @([pscustomobject]@{ FullName = '/repo/src/file.ps1'; Extension = '.ps1' })
        } -AnalyzeFile {
            param([string] $Path, [string] $Settings)
            [void] $Path
            [void] $Settings
            @()
        } -Logger { param([string] $Message) [void] $Message }

        $script:capturedAnalyzeRoot | Should -Be '/repo'
        $script:capturedAnalyzeScanFolders | Should -Be @('/repo/src', '/repo/tests/powershell')
    }
}

Describe 'bundled wrapper ScanFoldersJson transport' {
    AfterEach {
        Remove-Item Env:\POSHQC_CAPTURED_SCAN_FOLDERS -ErrorAction SilentlyContinue
    }

    It 'run-poshqc-format decodes ScanFoldersJson into string array input' {
        Remove-Item Env:\POSHQC_CAPTURED_SCAN_FOLDERS -ErrorAction SilentlyContinue

        $wrapperPath = Join-Path $PSScriptRoot '../../../../extensions/drm-copilot/resources/templates/run-poshqc-format.ps1'

        Mock -CommandName Import-Module -MockWith { }
        Mock -CommandName Invoke-PoshQCFormat -MockWith {
            param([string] $Root, [string[]] $ScanFolders)
            [void] $Root
            $env:POSHQC_CAPTURED_SCAN_FOLDERS = $ScanFolders -join '|'
        }

        & $wrapperPath -WorkspaceRoot '/repo' -ScanFoldersJson '["/repo/src","/repo/tests/powershell"]'

        ($env:POSHQC_CAPTURED_SCAN_FOLDERS -split '\|') | Should -Be @('/repo/src', '/repo/tests/powershell')
    }

    It 'run-poshqc-analyze decodes ScanFoldersJson into string array input' {
        Remove-Item Env:\POSHQC_CAPTURED_SCAN_FOLDERS -ErrorAction SilentlyContinue

        $wrapperPath = Join-Path $PSScriptRoot '../../../../extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1'

        Mock -CommandName Import-Module -MockWith { }
        Mock -CommandName Invoke-PoshQCAnalyze -MockWith {
            param([string] $Root, [string[]] $ScanFolders)
            [void] $Root
            $env:POSHQC_CAPTURED_SCAN_FOLDERS = $ScanFolders -join '|'
        }

        & $wrapperPath -WorkspaceRoot '/repo' -ScanFoldersJson '["/repo/src","/repo/tests/powershell"]'

        ($env:POSHQC_CAPTURED_SCAN_FOLDERS -split '\|') | Should -Be @('/repo/src', '/repo/tests/powershell')
    }

    It 'run-poshqc-test decodes ScanFoldersJson into string array input' {
        Remove-Item Env:\POSHQC_CAPTURED_SCAN_FOLDERS -ErrorAction SilentlyContinue

        $wrapperPath = Join-Path $PSScriptRoot '../../../../extensions/drm-copilot/resources/templates/run-poshqc-test.ps1'

        Mock -CommandName Import-Module -MockWith { }
        Mock -CommandName Invoke-PoshQCTest -MockWith {
            param(
                [string] $Root,
                [string[]] $ScanFolders,
                [switch] $DisableKoverageCopy,
                [string] $KoverageOutputPath
            )
            [void] $Root
            [void] $DisableKoverageCopy
            [void] $KoverageOutputPath
            $env:POSHQC_CAPTURED_SCAN_FOLDERS = $ScanFolders -join '|'
        }

        & $wrapperPath -WorkspaceRoot '/repo' -ScanFoldersJson '["/repo/tests/claude-runtime","/repo/tests/claude-hooks"]'

        ($env:POSHQC_CAPTURED_SCAN_FOLDERS -split '\|') | Should -Be @('/repo/tests/claude-runtime', '/repo/tests/claude-hooks')
    }
}
