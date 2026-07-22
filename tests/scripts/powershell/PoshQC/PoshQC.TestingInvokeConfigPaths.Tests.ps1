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

Describe 'Invoke-PoshQCTest pre-run config and path resolution branches (issue #392)' {
    It 'defaults $Root to $PWD.ProviderPath when -Root is not supplied (line 291)' {
        # Arrange: capture the $RootPath argument the default-$Root fallback flows into via the
        # $ResolveScanConfig seam (reached when -ScanFolders is not supplied).
        $expectedRoot = $PWD.ProviderPath
        $capturedRootForScanConfig = $null

        # Act
        Invoke-PoshQCTest -SettingsPath '/config-paths-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -LoadSettings { @{ Run = @{ Path = @('tests') }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = $null } } `
            -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = $null
                Output       = @{ Verbosity = 'Normal' }
            }
        } -ResolveScanConfig {
            param([string] $RootPath)
            Set-Variable -Scope 1 -Name 'capturedRootForScanConfig' -Value $RootPath
            @()
        } -EnumerateTests { @() } -Logger { param([string] $Message) [void] $Message } | Out-Null

        # Assert
        $capturedRootForScanConfig | Should -Be $expectedRoot
    }

    It 'uses supplied -ScanFolders directly and applies the resolved folders to Run.Path (lines 309, 314-316)' {
        # Arrange
        $capturedResolveRoot = $null
        $capturedResolveFolders = $null
        $capturedRunPaths = $null
        $resolvedFolders = @('/config-paths-root/src', '/config-paths-root/tests')

        # Act
        Invoke-PoshQCTest -Root '/config-paths-root' -ScanFolders @('src', 'tests') -SettingsPath '/config-paths-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -LoadSettings { @{ Run = @{ Path = @('placeholder') }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = $null } } `
            -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = $null
                Output       = @{ Verbosity = 'Normal' }
            }
        } -ResolveScanFolders {
            param([string] $RootPath, [string[]] $Folders)
            Set-Variable -Scope 1 -Name 'capturedResolveRoot' -Value $RootPath
            Set-Variable -Scope 1 -Name 'capturedResolveFolders' -Value $Folders
            $resolvedFolders
        } -EnumerateTests {
            param([string[]] $Paths, [string[]] $Excluded, [scriptblock] $TestPathFn)
            [void] $Excluded
            [void] $TestPathFn
            Set-Variable -Scope 1 -Name 'capturedRunPaths' -Value $Paths
            @()
        } -Logger { param([string] $Message) [void] $Message } | Out-Null

        # Assert: -ScanFolders was used directly (no fallback to $ResolveScanConfig), the resolver
        # was invoked with the supplied folders, and the resolved folders replaced Run.Path.
        $capturedResolveRoot | Should -Be '/config-paths-root'
        $capturedResolveFolders | Should -Be @('src', 'tests')
        $capturedRunPaths | Should -Be $resolvedFolders
    }

    It 'normalizes a truthy Output.Verbosity setting to Normal (line 322)' {
        # Arrange
        $capturedVerbosity = $null

        # Act
        Invoke-PoshQCTest -Root '/config-paths-root' -SettingsPath '/config-paths-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -LoadSettings { @{ Run = @{ Path = @('tests') }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = $null } } `
            -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = $null
                Output       = @{ Verbosity = $Table.Output.Verbosity }
            }
        } -ResolveScanConfig { @() } -EnumerateTests {
            @([pscustomobject]@{ FullName = '/config-paths-root/tests/sample.Tests.ps1' })
        } -InvokePester {
            param($Config)
            Set-Variable -Scope 1 -Name 'capturedVerbosity' -Value $Config.Output.Verbosity
            [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0; CodeCoverage = $null }
        } -Logger { param([string] $Message) [void] $Message } | Out-Null

        # Assert
        $capturedVerbosity | Should -Be 'Normal'
    }

    It 'resolves CodeCoverage.Path entries and creates/relativizes a relative CodeCoverage.OutputPath when coverage is enabled via a raw boolean flag (lines 332, 340-342, 346, 350-354, 356-357, 359)' {
        InModuleScope PoshQC {
            # Arrange: mock New-Item so the coverage-output-directory creation branch executes
            # without touching the real filesystem, and disable $ExpandCoveragePaths so the
            # target inline coverage-path/output resolution block (not the separately injectable
            # $ExpandCoveragePaths default) performs the wrapped-to-raw transformation under test.
            Mock -CommandName New-Item -MockWith { }
            $script:capturedConfig = $null

            # Act
            Invoke-PoshQCTest -Root '/config-paths-root' -SettingsPath '/config-paths-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
                -LoadSettings {
                @{
                    Run          = @{ Path = @('tests') }
                    Output       = @{ Verbosity = 'Detailed' }
                    TestResult   = @{ Enabled = $false }
                    CodeCoverage = @{ Enabled = $true; Path = @('src/**/*.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
                }
            } -BuildConfiguration {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = @{ Enabled = $true; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                    Output       = @{ Verbosity = 'Normal' }
                }
            } -ExpandCoveragePaths { param($Config, [string] $RootPath) [void] $RootPath; $Config } `
                -ResolveScanConfig { @() } -EnumerateTests {
                @([pscustomobject]@{ FullName = '/config-paths-root/tests/sample.Tests.ps1' })
            } -InvokePester {
                param($Config)
                $script:capturedConfig = $Config
                [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0; CodeCoverage = $null }
            } -CopyCoverage { param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath) [void] $CoveragePath; [void] $RepoRoot; [void] $KoveragePath } `
                -Logger { param([string] $Message) [void] $Message } | Out-Null

            # Assert: Path entries were rooted under -Root, and the relative OutputPath was
            # relativized under -Root (after its containing directory was created).
            ($script:capturedConfig.CodeCoverage.Path[0] -replace '\\', '/') | Should -Be '/config-paths-root/src/**/*.ps1'
            ($script:capturedConfig.CodeCoverage.OutputPath -replace '\\', '/') | Should -Be '/config-paths-root/artifacts/pester/coverage.xml'
            Should -Invoke -CommandName New-Item -Times 1 -Exactly
        }
    }

    It 'extracts CodeCoverage.OutputPath from its Value wrapper when coverage is not enabled (lines 332, 368-369)' {
        # Arrange: coverage disabled via a raw boolean $false flag skips the enabled-only
        # resolution block entirely, so OutputPath remains wrapped as { Value = ... } when the
        # unconditional post-resolution extraction below is reached.
        $logs = New-Object System.Collections.Generic.List[string]

        # Act
        { Invoke-PoshQCTest -Root '/config-paths-root' -SettingsPath '/config-paths-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
                -LoadSettings {
                @{
                    Run          = @{ Path = @('tests') }
                    Output       = @{ Verbosity = 'Detailed' }
                    TestResult   = @{ Enabled = $false }
                    CodeCoverage = @{ Enabled = $false; Path = $null; OutputPath = 'artifacts/pester/coverage.xml' }
                }
            } -BuildConfiguration {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = @{ Enabled = $false; Path = @{ Value = $null }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                    Output       = @{ Verbosity = 'Normal' }
                }
            } -ExpandCoveragePaths { param($Config, [string] $RootPath) [void] $RootPath; $Config } `
                -ResolveScanConfig { @() } -EnumerateTests { @() } `
                -Logger { param([string] $Message) $logs.Add($Message) | Out-Null } | Out-Null } |
            Should -Not -Throw

        # Assert: execution proceeded past the coverage-output-path extraction to the
        # no-test-files early return, proving no exception was raised while resolving OutputPath.
        $logs | Should -Contain 'No Pester test files found under configured paths for root /config-paths-root'
    }
}
