Set-StrictMode -Version Latest

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1') -Force
}

Describe 'Convert-PoshQCCoverageToRelative' {
    Context 'When converting coverage paths with repo root' {
        It 'Should convert forward-slash paths in XML to relative paths' {
            $mockXmlContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<report name="Pester">
    <package name="/repo-root/scripts/dev-tools">
    <class name="/repo-root/scripts/dev-tools/collect-commit-context" sourcefilename="collect-commit-context.ps1">
  </class>
  </package>
    <package name="/repo-root/scripts/powershell/PoshQC">
  <sourcefile name="PoshQC.psm1">
  </sourcefile>
  </package>
</report>
'@

            $result = Convert-PoshQCCoverageToRelative -InputContent $mockXmlContent -RepoRoot '/repo-root' -PassThru

            $result | Should -Not -Match '/repo-root/'
            $result | Should -Match '<package name="scripts/dev-tools">'
            $result | Should -Match '<class name="scripts/dev-tools/collect-commit-context"'
            $result | Should -Match '<package name="scripts/powershell/PoshQC">'
        }

        It 'Should convert backslash paths in XML to relative paths (Windows-style)' {
            $mockXmlContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<report name="Pester">
    <package name="\repo-root\scripts\dev-tools">
    <class name="\repo-root\scripts\dev-tools\collect-commit-context" sourcefilename="collect-commit-context.ps1">
  </class>
  </package>
</report>
'@

            $result = Convert-PoshQCCoverageToRelative -InputContent $mockXmlContent -RepoRoot '\repo-root' -PassThru

            $result | Should -Not -Match '/repo-root/'
            $result | Should -Not -Match '\\repo-root\\'
            $result | Should -Match 'scripts'
        }

        It 'Should handle mixed forward and backslash paths' {
            $mockXmlContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<report name="Pester">
    <package name="/repo-root/scripts/dev-tools">
    <class name="\repo-root\scripts\powershell\PoshQC" sourcefilename="PoshQC.psm1">
  </class>
  </package>
</report>
'@

            $result = Convert-PoshQCCoverageToRelative -InputContent $mockXmlContent -RepoRoot '/repo-root' -PassThru

            $result | Should -Not -Match '/repo-root/'
            $result | Should -Not -Match '\\repo-root\\'
            $result | Should -Match 'scripts'
        }
    }

    Context 'When RepoRoot has trailing separator' {
        It 'Should still convert paths correctly' {
            $mockXmlContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<report name="Pester">
    <package name="/repo-root/scripts/dev-tools">
  </package>
</report>
'@

            $result = Convert-PoshQCCoverageToRelative -InputContent $mockXmlContent -RepoRoot '/repo-root/' -PassThru

            $result | Should -Not -Match '/repo-root/'
            $result | Should -Match '<package name="scripts/dev-tools">'
        }
    }

    Context 'When inputs or outputs are injected' {
        It 'skips conversion when neither InputPath nor InputContent is provided' {
            $logs = New-Object System.Collections.Generic.List[string]

            Convert-PoshQCCoverageToRelative -Logger { param([string] $Message) $logs.Add($Message) | Out-Null } | Out-Null

            $logs | Should -Contain 'No coverage input provided; skipping conversion.'
        }

        It 'derives default output path when only InputPath is supplied' {
            $writtenPath = $null
            $writtenContent = $null

            Convert-PoshQCCoverageToRelative -RepoRoot '/repo' -InputPath 'artifacts/pester/coverage.xml' -ResolvePath { param([string] $Path) if ($Path.StartsWith('/repo')) { $Path } else { "/repo/$Path" } } `
                -JoinPath { param([string] $Parent, [string] $Child) "$Parent/$Child" } -TestPathExists { param([string] $Path) [void] $Path; $true } -ReadContent { '<report></report>' } `
                -WriteContent {
                param([string] $Path, [string] $Content)
                Set-Variable -Scope 1 -Name 'writtenPath' -Value $Path
                Set-Variable -Scope 1 -Name 'writtenContent' -Value $Content
            } -EnsureDirectory { param([string] $Path) [void] $Path } -GetDefaultOutputPath {
                param([string] $ResolvedInputPath, [string] $ResolvedRoot)
                [void] $ResolvedInputPath
                "$ResolvedRoot/artifacts/pester/coverage.koverage.xml"
            } -Logger { param([string] $Message) [void] $Message } | Out-Null

            $writtenPath | Should -Be '/repo/artifacts/pester/coverage.koverage.xml'
            $writtenContent | Should -Be '<report></report>'
        }

        It 'returns converted content when PassThru is set with trailing RepoRoot separator' {
            $mockXmlContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<report name="Pester">
    <package name="/repo-root/scripts/dev-tools">
  </package>
</report>
'@

            $result = Convert-PoshQCCoverageToRelative -InputContent $mockXmlContent -RepoRoot '/repo-root/' -PassThru

            $result | Should -Not -Match '/repo-root/'
            $result | Should -Match 'scripts/dev-tools'
        }
    }
}

Describe 'Invoke-PoshQCTest' {
    It 'throws when Pester is missing' {
        { Invoke-PoshQCTest -EnsureModule { param([string] $Name, [string] $ErrorMessage) [void] $Name; throw $ErrorMessage } } |
            Should -Throw '*Pester is not installed*'
    }

    It 'throws when settings file is missing' {
        { Invoke-PoshQCTest -Root '/repo' -SettingsPath '/missing.psd1' -EnsureModule { } -TestPathExists { $false } } |
            Should -Throw 'Settings not found: /missing.psd1'
    }

    It 'expands Run.Path and merges ExcludeDirs into ExcludePath' {
        $config = $null
        $script:capturedRunPaths = $null
        $script:capturedExcludes = $null
        $settings = @{
            Run          = @{ Path = @('tests') }
            Should       = @{ ErrorAction = 'Stop' }
            Output       = @{ Verbosity = 'Detailed' }
            TestResult   = @{ Enabled = $false }
            CodeCoverage = $null
        }

        Invoke-PoshQCTest -Root '/repo' -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } -LoadSettings { $settings } `
            -BuildConfiguration {
            param($Table)
            $config = [pscustomobject]@{
                Run          = @{
                    Path        = @{ Value = $Table.Run.Path }
                    ExcludePath = @{ Value = @() }
                }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = $null
                Output       = @{ Verbosity = 'Normal' }
            }
            return $config
        } -EnsureResultPath { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } -ExpandCoveragePaths { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } `
            -ExpandRunPaths {
            param($cfg, [string] $RootPath, [string[]] $Excluded)
            $cfg.Run.Path = @($cfg.Run.Path.Value | ForEach-Object { Join-Path $RootPath $_ })
            $cfg.Run.ExcludePath = @($Excluded | ForEach-Object { Join-Path $RootPath $_ })
            $cfg
        } `
            -EnumerateTests {
            param([string[]] $Paths, [string[]] $Excluded, [scriptblock] $TestPathFn)
            [void] $TestPathFn
            Set-Variable -Scope Script -Name capturedRunPaths -Value $Paths -Force
            Set-Variable -Scope Script -Name capturedExcludes -Value $Excluded -Force
            @([pscustomobject]@{ FullName = '/repo/tests/sample.Tests.ps1' })
        } -InvokePester {
            [pscustomobject]@{ Duration = [timespan]::Zero; PassedCount = 1; FailedCount = 0; SkippedCount = 0; InconclusiveCount = 0; NotRunCount = 0 }
        } -Logger { param([string] $Message) [void] $Message } -ExcludeDirs @('skip') | Out-Null

        ($script:capturedRunPaths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/repo/tests')
        ($script:capturedExcludes | ForEach-Object { $_ -replace '\\', '/' }) | Should -Contain 'skip'
    }

    It 'logs and returns when no test files are found' {
        $logs = New-Object System.Collections.Generic.List[string]

        Invoke-PoshQCTest -Root '/repo' -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } -LoadSettings {
            @{ Run = @{ Path = @('tests') }; Should = @{ ErrorAction = 'Stop' }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = $null }
        } -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = $null
                Output       = @{ Verbosity = 'Normal' }
            }
        } -EnsureResultPath { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } -ExpandCoveragePaths { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } `
            -EnumerateTests { @() } -Logger { param([string] $Message) $logs.Add($Message) | Out-Null } | Out-Null

        $logs | Should -Contain 'No Pester test files found under configured paths for root /repo'
    }

    It 'invokes coverage copy when coverage is enabled and not disabled' {
        $copyArgs = $null
        $repoRoot = $PSScriptRoot
        $coveragePath = Join-Path $repoRoot 'coverage.xml'
        $coverageSrcPath = Join-Path $repoRoot 'src'
        $expectedCoveragePath = $coveragePath
        $expectedRepoRoot = $repoRoot
        $expectedKoveragePath = Join-Path $repoRoot 'coverage.koverage.xml'

        Invoke-PoshQCTest -Root $repoRoot -SettingsPath '/settings.psd1' -EnsureModule { } -TestPathExists { $true } -LoadSettings {
            @{ Run = @{ Path = @('tests') }; Should = @{ ErrorAction = 'Stop' }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = @{ Enabled = $true; Path = @($coverageSrcPath); OutputPath = $coveragePath } }
        } -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = @{ Enabled = @{ Value = $true }; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                Output       = @{ Verbosity = 'Normal' }
            }
        } -EnsureResultPath { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } -ExpandCoveragePaths { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } `
            -EnumerateTests { @([pscustomobject]@{ FullName = '/repo/tests/sample.Tests.ps1' }) } -InvokePester {
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
            Set-Variable -Scope 1 -Name 'copyArgs' -Value @($CoveragePath, $RepoRoot, $KoveragePath)
        } -Logger { param([string] $Message) [void] $Message } | Out-Null

        ($copyArgs[0] -replace '\\', '/') | Should -Be ($expectedCoveragePath -replace '\\', '/')
        ($copyArgs[1] -replace '\\', '/') | Should -Be ($expectedRepoRoot -replace '\\', '/')
        ($copyArgs[2] -replace '\\', '/') | Should -Be ($expectedKoveragePath -replace '\\', '/')
    }

    It 'preserves a custom KoverageOutputPath when ScanFolders narrow Run.Path and preserve coverage paths' {
        $script:capturedRunPaths = $null
        $script:capturedCoveragePaths = $null
        $copyArgs = $null
        $customKoveragePath = '/repo/artifacts/custom.koverage.xml'

        Invoke-PoshQCTest -Root '/repo' -ScanFolders @('/repo/src', '/repo/tests/powershell') -SettingsPath '/settings.psd1' -KoverageOutputPath $customKoveragePath -EnsureModule { } -TestPathExists { $true } -LoadSettings {
            @{ Run = @{ Path = @('tests') }; Should = @{ ErrorAction = 'Stop' }; Output = @{ Verbosity = 'Detailed' }; TestResult = @{ Enabled = $false }; CodeCoverage = @{ Enabled = $true; Path = @('src/**/*.ps1'); OutputPath = 'artifacts/coverage.xml' } }
        } -BuildConfiguration {
            param($Table)
            [pscustomobject]@{
                Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() }; PassThru = $false }
                TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                CodeCoverage = @{ Enabled = @{ Value = $true }; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = 'artifacts/coverage.xml' } }
                Output       = @{ Verbosity = 'Normal' }
            }
        } -EnsureResultPath { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } -ExpandRunPaths { param($cfg, [string] $RootPath, [string[]] $Excluded) [void] $RootPath; [void] $Excluded; $cfg } -ExpandCoveragePaths { param($cfg, [string] $RootPath) [void] $RootPath; $cfg } -ResolveScanFolders {
            param([string] $RootPath, [string[]] $Folders)
            [void] $RootPath
            $Folders
        } -EnumerateTests {
            param([string[]] $Paths, [string[]] $Excluded, [scriptblock] $TestPathFn)
            [void] $Excluded
            [void] $TestPathFn
            $script:capturedRunPaths = $Paths
            @([pscustomobject]@{ FullName = '/repo/tests/sample.Tests.ps1' })
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
            $script:copyArgs = @($CoveragePath, $RepoRoot, $KoveragePath)
        } -Logger { param([string] $Message) [void] $Message } | Out-Null

        $script:capturedRunPaths | Should -Be @('/repo/src', '/repo/tests/powershell')
        ($script:capturedCoveragePaths | ForEach-Object { $_ -replace '\\', '/' }) | Should -Be @('/repo/src/**/*.ps1')
        $script:copyArgs[2] | Should -Be $customKoveragePath
    }
}
