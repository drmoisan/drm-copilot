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

Describe 'Invoke-PoshQCTest post-run summary branches (issue #392)' {
    It 'logs the duration and counts summary for a completed run when coverage is not enabled (lines 401-403, 433-436)' {
        # Arrange
        $logs = New-Object System.Collections.Generic.List[string]

        # Act
        Invoke-PoshQCTest -Root '/summary-root' -SettingsPath '/summary-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -LoadSettings { @{ Run = @{ Path = @('tests') }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = $null } } `
            -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = $null
                Output       = @{ Verbosity = 'Normal' }
            }
        } -ResolveScanConfig { @() } -EnumerateTests {
            @([pscustomobject]@{ FullName = '/summary-root/tests/sample.Tests.ps1' })
        } -InvokePester {
            [pscustomobject]@{
                Duration          = [timespan]::FromSeconds(1.5)
                PassedCount       = 3
                FailedCount       = 0
                SkippedCount      = 1
                InconclusiveCount = 0
                NotRunCount       = 0
                CodeCoverage      = $null
            }
        } -Logger { param([string] $Message) $logs.Add($Message) | Out-Null } | Out-Null

        # Assert: the duration/counts summary lines and the fixed replay header/blank line were
        # all logged; no coverage lines were appended since coverage is not enabled.
        $logs | Should -Contain ''
        $logs | Should -Contain 'Pester summary (replayed for readability):'
        $logs | Should -Contain 'Tests completed in 1.50s'
        $logs | Should -Contain 'Tests Passed: 3, Failed: 0, Skipped: 1, Inconclusive: 0, NotRun: 0'
    }

    It 'replays coverage report lines up to the Missed commands marker and stops (lines 410-415, 417-420, 427-428, 437-439)' {
        # Arrange
        $logs = New-Object System.Collections.Generic.List[string]
        $coverageReport = "Name  Coverage`nfile.ps1  50%`nMissed commands:`nlots of missed detail that must not be logged"

        # Act
        Invoke-PoshQCTest -Root '/summary-root' -SettingsPath '/summary-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -LoadSettings { @{ Run = @{ Path = @('tests') }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = @{ Enabled = $true; Path = $null; OutputPath = $null } } } `
            -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = @{ Enabled = @{ Value = $true }; Path = @{ Value = $null }; OutputPath = @{ Value = $null } }
                Output       = @{ Verbosity = 'Normal' }
            }
        } -ResolveScanConfig { @() } -EnumerateTests {
            @([pscustomobject]@{ FullName = '/summary-root/tests/sample.Tests.ps1' })
        } -InvokePester {
            param($Config)
            [void] $Config
            [pscustomobject]@{
                Duration          = [timespan]::Zero
                PassedCount       = 1
                FailedCount       = 0
                SkippedCount      = 0
                InconclusiveCount = 0
                NotRunCount       = 0
                CodeCoverage      = [pscustomobject]@{ CoverageReport = $coverageReport }
            }
        } -Logger { param([string] $Message) $logs.Add($Message) | Out-Null } | Out-Null

        # Assert: lines before the "Missed commands" marker were replayed; the marker line and
        # everything after it were not.
        $logs | Should -Contain 'Name  Coverage'
        $logs | Should -Contain 'file.ps1  50%'
        $logs | Should -Not -Contain 'Missed commands:'
        $logs | Should -Not -Contain 'lots of missed detail that must not be logged'
    }

    It 'falls back to the first raw line when the Missed commands marker is the first line seen (lines 423-424, 427-428, 437-439)' {
        # Arrange: a single-line coverage report whose only line matches the "Missed commands"
        # marker breaks the accumulation loop before any line is added to $trimmedCoverageLines,
        # leaving it empty despite $rawCoverageLines being non-empty, so the fallback assigns
        # $rawCoverageLines[0] (the same marker line) as the sole replayed coverage line.
        $logs = New-Object System.Collections.Generic.List[string]
        $singleLineCoverageReport = 'Missed commands: none'

        # Act
        Invoke-PoshQCTest -Root '/summary-root' -SettingsPath '/summary-settings.psd1' -EnsureModule { } -TestPathExists { $true } `
            -LoadSettings { @{ Run = @{ Path = @('tests') }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = @{ Enabled = $true; Path = $null; OutputPath = $null } } } `
            -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = @{ Enabled = @{ Value = $true }; Path = @{ Value = $null }; OutputPath = @{ Value = $null } }
                Output       = @{ Verbosity = 'Normal' }
            }
        } -ResolveScanConfig { @() } -EnumerateTests {
            @([pscustomobject]@{ FullName = '/summary-root/tests/sample.Tests.ps1' })
        } -InvokePester {
            param($Config)
            [void] $Config
            [pscustomobject]@{
                Duration          = [timespan]::Zero
                PassedCount       = 1
                FailedCount       = 0
                SkippedCount      = 0
                InconclusiveCount = 0
                NotRunCount       = 0
                CodeCoverage      = [pscustomobject]@{ CoverageReport = $singleLineCoverageReport }
            }
        } -Logger { param([string] $Message) $logs.Add($Message) | Out-Null } | Out-Null

        # Assert: the fallback recovered the marker line itself as the sole replayed coverage
        # line, so the logger emitted exactly one extra message beyond the fixed summary lines.
        $fixedMessageCount = 4
        $logs.Count | Should -Be ($fixedMessageCount + 1)
        $logs[-1] | Should -Be $singleLineCoverageReport
    }
}
