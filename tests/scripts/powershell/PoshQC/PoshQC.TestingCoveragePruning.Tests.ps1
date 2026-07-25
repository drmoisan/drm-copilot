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

Describe 'Invoke-PoshQCTest coverage-path pruning (issue #409)' {
    # Every scenario below drives the coverage-enabled block of Invoke-PoshQCTest through its
    # injectable seams only. The injected $TestPathExists predicate is deliberately
    # path-discriminating rather than a blanket { $false }: the same seam also gates the
    # settings-existence check, so a blanket false would throw "Settings not found:" before the
    # coverage block is ever reached. Each scenario runs inside InModuleScope with New-Item
    # mocked, because the inline coverage block creates the coverage output directory whenever
    # CodeCoverage.OutputPath is set; the mock keeps these tests free of filesystem writes.

    It 'passes the full resolved coverage set through and logs no prune lines when every configured path exists' {
        InModuleScope PoshQC {
            # Arrange
            Mock -CommandName New-Item -MockWith { }
            $script:capturedConfig = $null
            $script:logs = New-Object 'System.Collections.Generic.List[string]'

            # Act
            Invoke-PoshQCTest -Root '/prune-root' -SettingsPath '/prune-settings.psd1' -EnsureModule { } `
                -TestPathExists {
                param([string] $Path)
                # Settings path must report present; coverage entries are classified by name.
                if ($Path -eq '/prune-settings.psd1') { return $true }
                return ($Path -like '*present*')
            } `
                -LoadSettings {
                @{
                    Run          = @{ Path = @('tests') }
                    Output       = @{ Verbosity = 'Detailed' }
                    TestResult   = @{ Enabled = $false }
                    CodeCoverage = @{ Enabled = $true; Path = @('present-a.ps1', 'present-b.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
                }
            } `
                -BuildConfiguration {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = @{ Enabled = $true; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                    Output       = @{ Verbosity = 'Normal' }
                }
            } `
                -ExpandCoveragePaths { param($Config, [string] $RootPath) [void] $RootPath; $Config } `
                -ResolveScanConfig { @() } `
                -EnumerateTests { @([pscustomobject]@{ FullName = '/prune-root/tests/sample.Tests.ps1' }) } `
                -InvokePester {
                param($Config)
                $script:capturedConfig = $Config
                [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0; CodeCoverage = $null }
            } `
                -CopyCoverage { param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath) [void] $CoveragePath; [void] $RepoRoot; [void] $KoveragePath } `
                -Logger { param([string] $Message) $script:logs.Add($Message) } | Out-Null

            # Assert: the full resolved set reached Pester, coverage stayed enabled, nothing pruned.
            $forwarded = @($script:capturedConfig.CodeCoverage.Path | ForEach-Object { $_ -replace '\\', '/' })
            $forwarded | Should -Be @('/prune-root/present-a.ps1', '/prune-root/present-b.ps1')
            $script:capturedConfig.CodeCoverage.Enabled | Should -BeTrue
            @($script:logs | Where-Object { $_ -like 'Pruned nonexistent code coverage path:*' }).Count | Should -Be 0
            @($script:logs | Where-Object { $_ -like 'Code coverage disabled for this invocation*' }).Count | Should -Be 0
        }
    }

    It 'keeps only the existing paths and logs each pruned path with its resolved value for a mixed set' {
        InModuleScope PoshQC {
            # Arrange
            Mock -CommandName New-Item -MockWith { }
            $script:capturedConfig = $null
            $script:logs = New-Object 'System.Collections.Generic.List[string]'

            # Act
            Invoke-PoshQCTest -Root '/prune-root' -SettingsPath '/prune-settings.psd1' -EnsureModule { } `
                -TestPathExists {
                param([string] $Path)
                if ($Path -eq '/prune-settings.psd1') { return $true }
                return ($Path -like '*present*')
            } `
                -LoadSettings {
                @{
                    Run          = @{ Path = @('tests') }
                    Output       = @{ Verbosity = 'Detailed' }
                    TestResult   = @{ Enabled = $false }
                    CodeCoverage = @{ Enabled = $true; Path = @('present-a.ps1', 'missing-b.ps1', 'present-c.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
                }
            } `
                -BuildConfiguration {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = @{ Enabled = $true; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                    Output       = @{ Verbosity = 'Normal' }
                }
            } `
                -ExpandCoveragePaths { param($Config, [string] $RootPath) [void] $RootPath; $Config } `
                -ResolveScanConfig { @() } `
                -EnumerateTests { @([pscustomobject]@{ FullName = '/prune-root/tests/sample.Tests.ps1' }) } `
                -InvokePester {
                param($Config)
                $script:capturedConfig = $Config
                [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0; CodeCoverage = $null }
            } `
                -CopyCoverage { param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath) [void] $CoveragePath; [void] $RepoRoot; [void] $KoveragePath } `
                -Logger { param([string] $Message) $script:logs.Add($Message) } | Out-Null

            # Assert: only the existing entries survived, in their original order.
            $forwarded = @($script:capturedConfig.CodeCoverage.Path | ForEach-Object { $_ -replace '\\', '/' })
            $forwarded | Should -Be @('/prune-root/present-a.ps1', '/prune-root/present-c.ps1')
            $script:capturedConfig.CodeCoverage.Enabled | Should -BeTrue

            # Assert: the single pruned path was logged individually, naming its resolved value.
            $pruneLines = @($script:logs | Where-Object { $_ -like 'Pruned nonexistent code coverage path:*' })
            $pruneLines.Count | Should -Be 1
            ($pruneLines[0] -replace '\\', '/') | Should -Be 'Pruned nonexistent code coverage path: /prune-root/missing-b.ps1'

            # Assert: a non-empty surviving set must not trigger the disable notice.
            @($script:logs | Where-Object { $_ -like 'Code coverage disabled for this invocation*' }).Count | Should -Be 0
        }
    }

    It 'disables coverage at the $InvokePester boundary, logs one explanation, proceeds with the run, and skips the coverage copy when no configured path exists' {
        InModuleScope PoshQC {
            # Arrange: CodeCoverage.OutputPath is deliberately non-null so that $coverageOutputPath
            # is populated. That makes the "coverage copy not invoked" assertion meaningful: the
            # only remaining reason to skip the copy is $coverageEnabled having been set to false.
            Mock -CommandName New-Item -MockWith { }
            $script:capturedConfig = $null
            $script:logs = New-Object 'System.Collections.Generic.List[string]'
            $script:copyCoverageInvoked = $false

            # Act
            Invoke-PoshQCTest -Root '/prune-root' -SettingsPath '/prune-settings.psd1' -EnsureModule { } `
                -TestPathExists {
                param([string] $Path)
                if ($Path -eq '/prune-settings.psd1') { return $true }
                return ($Path -like '*present*')
            } `
                -LoadSettings {
                @{
                    Run          = @{ Path = @('tests') }
                    Output       = @{ Verbosity = 'Detailed' }
                    TestResult   = @{ Enabled = $false }
                    CodeCoverage = @{ Enabled = $true; Path = @('missing-a.ps1', 'missing-b.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
                }
            } `
                -BuildConfiguration {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = @{ Enabled = $true; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                    Output       = @{ Verbosity = 'Normal' }
                }
            } `
                -ExpandCoveragePaths { param($Config, [string] $RootPath) [void] $RootPath; $Config } `
                -ResolveScanConfig { @() } `
                -EnumerateTests { @([pscustomobject]@{ FullName = '/prune-root/tests/sample.Tests.ps1' }) } `
                -InvokePester {
                param($Config)
                $script:capturedConfig = $Config
                [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0; CodeCoverage = $null }
            } `
                -CopyCoverage {
                param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath)
                [void] $CoveragePath; [void] $RepoRoot; [void] $KoveragePath
                $script:copyCoverageInvoked = $true
            } `
                -Logger { param([string] $Message) $script:logs.Add($Message) } | Out-Null

            # Assert: coverage is disabled at the boundary, never handed over as enabled-but-empty.
            $script:capturedConfig | Should -Not -BeNullOrEmpty
            $script:capturedConfig.CodeCoverage.Enabled | Should -BeFalse

            # Assert: both pruned paths were logged, and the disable explanation appeared exactly once.
            @($script:logs | Where-Object { $_ -like 'Pruned nonexistent code coverage path:*' }).Count | Should -Be 2
            @($script:logs | Where-Object { $_ -like 'Code coverage disabled for this invocation*' }).Count | Should -Be 1

            # Assert: the run proceeded - Pester was invoked and the summary was replayed.
            $script:logs | Should -Contain 'Pester summary (replayed for readability):'

            # Assert: the Koverage copy step was not invoked, because coverage was disabled.
            $script:copyCoverageInvoked | Should -BeFalse
        }
    }

    It 'evaluates a rooted absolute entry with the same predicate and never re-joins it to -Root' {
        InModuleScope PoshQC {
            # Arrange: one rooted-and-present entry and one rooted-and-missing entry. A rooted entry
            # must be tested, kept, and logged using its own value, not a value re-joined to -Root.
            Mock -CommandName New-Item -MockWith { }
            $script:capturedConfig = $null
            $script:logs = New-Object 'System.Collections.Generic.List[string]'

            # Act
            Invoke-PoshQCTest -Root '/prune-root' -SettingsPath '/prune-settings.psd1' -EnsureModule { } `
                -TestPathExists {
                param([string] $Path)
                if ($Path -eq '/prune-settings.psd1') { return $true }
                return ($Path -like '*present*')
            } `
                -LoadSettings {
                @{
                    Run          = @{ Path = @('tests') }
                    Output       = @{ Verbosity = 'Detailed' }
                    TestResult   = @{ Enabled = $false }
                    CodeCoverage = @{ Enabled = $true; Path = @('/rooted-present.ps1', '/rooted-missing.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
                }
            } `
                -BuildConfiguration {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = @{ Enabled = $true; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                    Output       = @{ Verbosity = 'Normal' }
                }
            } `
                -ExpandCoveragePaths { param($Config, [string] $RootPath) [void] $RootPath; $Config } `
                -ResolveScanConfig { @() } `
                -EnumerateTests { @([pscustomobject]@{ FullName = '/prune-root/tests/sample.Tests.ps1' }) } `
                -InvokePester {
                param($Config)
                $script:capturedConfig = $Config
                [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0; CodeCoverage = $null }
            } `
                -CopyCoverage { param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath) [void] $CoveragePath; [void] $RepoRoot; [void] $KoveragePath } `
                -Logger { param([string] $Message) $script:logs.Add($Message) } | Out-Null

            # Assert: the rooted survivor kept its own value; it was not prefixed with -Root.
            $forwarded = @($script:capturedConfig.CodeCoverage.Path | ForEach-Object { $_ -replace '\\', '/' })
            $forwarded | Should -Be @('/rooted-present.ps1')
            $forwarded[0] | Should -Not -BeLike '/prune-root/*'

            # Assert: the rooted missing entry was pruned and logged with its un-rejoined value.
            $pruneLines = @($script:logs | Where-Object { $_ -like 'Pruned nonexistent code coverage path:*' })
            $pruneLines.Count | Should -Be 1
            ($pruneLines[0] -replace '\\', '/') | Should -Be 'Pruned nonexistent code coverage path: /rooted-missing.ps1'
        }
    }
}
