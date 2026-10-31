Set-StrictMode -Version Latest

# Unit tests for the Invoke-PoshQCTest output-path parameters (issue #1048).
# Every seam is injected or its file-system cmdlet is mocked, so the code under test imports no module,
# reads no workspace file, and writes no file or directory.

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root module.
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force

    $script:Root = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'output-path-root'
    $script:SettingsTable = @{
        Run          = @{ Path = @('tests') }
        TestResult   = @{ Enabled = $true; OutputFormat = 'JUnitXml'; OutputPath = 'artifacts/pester/pester-junit.xml' }
        CodeCoverage = @{ Enabled = $true; OutputFormat = 'CoverageGutters'; OutputPath = 'artifacts/pester/powershell-coverage.xml' }
    }

    # Returns the splat of every Invoke-PoshQCTest seam. BuildConfiguration returns a real Pester
    # configuration, so TestResult and CodeCoverage carry OutputPath options; InvokePester records
    # the OutputPath values it receives in the supplied capture table.
    $script:NewSeams = {
        param([hashtable] $Capture)
        $captureTable = $Capture
        $settingsTable = $script:SettingsTable
        @{
            Root                      = $script:Root
            SettingsPath              = 'output-path-settings.psd1'
            EnsureModule              = { }
            TestPathExists            = { $true }
            LoadSettings              = { $settingsTable }.GetNewClosure()
            BuildConfiguration        = { param($Table) New-PesterConfiguration -Hashtable $Table }
            ExpandRunPaths            = { param($Config) $Config }
            EnsureResultPath          = { param($Config) $Config }
            ExpandCoveragePaths       = { param($Config) $Config }
            ResolveScanConfig         = { @() }
            ResolveScanFolders        = { @() }
            EnumerateTests            = { @('t1.Tests.ps1') }
            InvokePester              = {
                param($Config)
                $captureTable['TestResultPath'] = [string] $Config.TestResult.OutputPath.Value
                $captureTable['CoveragePath'] = [string] $Config.CodeCoverage.OutputPath.Value
                $null
            }.GetNewClosure()
            CopyCoverage              = { }
            ResolveCoveragePopulation = { [pscustomobject]@{ Source = 'config'; Paths = @('scripts/a.ps1') } }
            Logger                    = { param([string] $Message) [void] $Message }
        }
    }
}

Describe 'Invoke-PoshQCTest output-path parameters' {
    It 'OP01-TESTRESULT-PATH-OVERRIDES-SETTINGS replaces the settings JUnit path with -TestResultPath' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture
        $override = Join-Path $script:Root 'artifacts/pester/parallel/shard-1/pester-junit.xml'

        # Act
        InModuleScope PoshQC -Parameters @{ Seams = $seams; Override = $override } {
            param([hashtable] $Seams, [string] $Override)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams -TestResultPath $Override
        }

        # Assert
        $capture['TestResultPath'] | Should -BeExactly $override
        $capture['CoveragePath'] | Should -BeExactly (Join-Path $script:Root 'artifacts/pester/powershell-coverage.xml') -Because 'the coverage path keeps the settings value'
    }

    It 'OP02-COVERAGE-PATH-OVERRIDES-SETTINGS replaces the settings coverage path with -CoverageOutputPath' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture
        $override = Join-Path $script:Root 'artifacts/pester/parallel/shard-2/powershell-coverage.xml'

        # Act
        InModuleScope PoshQC -Parameters @{ Seams = $seams; Override = $override } {
            param([hashtable] $Seams, [string] $Override)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams -CoverageOutputPath $Override
        }

        # Assert
        $capture['CoveragePath'] | Should -BeExactly $override
        $capture['TestResultPath'] | Should -BeExactly 'artifacts/pester/pester-junit.xml' -Because 'the JUnit path keeps the settings value'
    }

    It 'OP03-OMITTED-PATHS-KEEP-SETTINGS leaves both settings paths unchanged when neither parameter is supplied' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture

        # Act
        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams
        }

        # Assert
        $capture['TestResultPath'] | Should -BeExactly 'artifacts/pester/pester-junit.xml'
        $capture['CoveragePath'] | Should -BeExactly (Join-Path $script:Root 'artifacts/pester/powershell-coverage.xml')
    }

    It 'OP04-RELATIVE-OVERRIDE-RESOLVED-AGAINST-ROOT resolves relative overrides against -Root through the default path seams' {
        # Arrange: the default EnsureResultPath and ExpandCoveragePaths seams run; New-Item is mocked so no directory is created.
        $capture = @{}
        $seams = & $script:NewSeams $capture
        $seams.Remove('EnsureResultPath')
        $seams.Remove('ExpandCoveragePaths')

        # Act
        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams -TestResultPath 'out/shard-3/pester-junit.xml' -CoverageOutputPath 'out/shard-3/powershell-coverage.xml'
        }

        # Assert
        $capture['TestResultPath'] | Should -BeExactly (Join-Path $script:Root 'out/shard-3/pester-junit.xml')
        $capture['CoveragePath'] | Should -BeExactly (Join-Path $script:Root 'out/shard-3/powershell-coverage.xml')
    }
}
