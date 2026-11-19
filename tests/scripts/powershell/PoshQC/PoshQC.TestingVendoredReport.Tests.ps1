Set-StrictMode -Version Latest

# Unit tests for the vendored push-down exemption report call site in Invoke-PoshQCTest (issue #1049).
# Every seam is injected or its file-system cmdlet is mocked, so the code under test reads no workspace
# file and writes no file or directory.

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

    $script:Root = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'vendored-report-root'
    $script:SettingsTable = @{
        Run          = @{ Path = @('tests') }
        TestResult   = @{ Enabled = $true; OutputFormat = 'JUnitXml'; OutputPath = 'artifacts/pester/pester-junit.xml' }
        CodeCoverage = @{ Enabled = $true; OutputFormat = 'JaCoCo'; OutputPath = 'artifacts/pester/powershell-coverage.xml' }
    }
    $script:Exemptions = @(
        [pscustomobject]@{ path = '.claude/hooks/a.ps1'; status = 'exempt'; manifest_sha256 = 'aa'; actual_sha256 = 'aa' }
        [pscustomobject]@{ path = '.claude/hooks/b.ps1'; status = 'modified'; manifest_sha256 = 'aa'; actual_sha256 = 'bb' }
    )

    # Returns the splat of every Invoke-PoshQCTest seam. ResolveCoveragePopulation returns the supplied
    # population; InvokePester and WriteVendoredCoverageReport record their calls in the capture table.
    $script:NewSeams = {
        param([hashtable] $Capture, $Population)
        $captureTable = $Capture
        $settingsTable = $script:SettingsTable
        $populationValue = $Population
        @{
            Root                        = $script:Root
            SettingsPath                = 'vendored-report-settings.psd1'
            EnsureModule                = { }
            TestPathExists              = { $true }
            LoadSettings                = { $settingsTable }.GetNewClosure()
            BuildConfiguration          = { param($Table) New-PesterConfiguration -Hashtable $Table }
            ExpandRunPaths              = { param($Config) $Config }
            EnsureResultPath            = { param($Config) $Config }
            ExpandCoveragePaths         = { param($Config) $Config }
            ResolveScanConfig           = { @() }
            ResolveScanFolders          = { @() }
            EnumerateTests              = { @('t1.Tests.ps1') }
            InvokePester                = { param($Config) [void] $Config; $captureTable['PesterCalls'] = 1 + [int] $captureTable['PesterCalls']; $null }.GetNewClosure()
            CopyCoverage                = { }
            ResolveCoveragePopulation   = { $populationValue }.GetNewClosure()
            WriteVendoredCoverageReport = {
                param([string] $RootPath, [string] $OutputPath, $Exemptions)
                $captureTable['ReportCalls'] = 1 + [int] $captureTable['ReportCalls']
                $captureTable['ReportRoot'] = $RootPath
                $captureTable['ReportOutputPath'] = $OutputPath
                $captureTable['ReportExemptions'] = @($Exemptions)
            }.GetNewClosure()
            Logger                      = { param([string] $Message) [void] $Message }
        }
    }
}

Describe 'Invoke-PoshQCTest vendored coverage report (issue #1049)' {
    It 'passes the exemptions and the effective coverage output path to the report seam' {
        # Arrange: a shard coverage path relative to the root.
        $capture = @{}
        $population = [pscustomobject]@{ Source = 'config'; Paths = @('scripts/a.ps1'); Exemptions = $script:Exemptions }
        $seams = & $script:NewSeams $capture $population

        # Act
        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams -CoverageOutputPath 'artifacts/pester/parallel/shard-2/powershell-coverage.xml'
        }

        # Assert
        $capture['ReportCalls'] | Should -Be 1
        $capture['ReportRoot'] | Should -BeExactly $script:Root
        $capture['ReportOutputPath'] | Should -BeExactly (Join-Path $script:Root 'artifacts/pester/parallel/shard-2/powershell-coverage.xml')
        @($capture['ReportExemptions'] | ForEach-Object path) | Should -Be @('.claude/hooks/a.ps1', '.claude/hooks/b.ps1')
        $capture['PesterCalls'] | Should -Be 1
    }

    It 'default report seam calls Write-PoshQCVendoredCoverageReport' {
        # Arrange
        $capture = @{}
        $population = [pscustomobject]@{ Source = 'config'; Paths = @('scripts/a.ps1'); Exemptions = $script:Exemptions }
        $seams = & $script:NewSeams $capture $population
        $seams.Remove('WriteVendoredCoverageReport')

        # Act and Assert
        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName New-Item -MockWith { }
            Mock -CommandName Write-PoshQCVendoredCoverageReport -MockWith { 'report-path' }
            Invoke-PoshQCTest @Seams
            Should -Invoke Write-PoshQCVendoredCoverageReport -Times 1 -Exactly -ParameterFilter {
                @($Exemptions).Count -eq 2 -and $CoverageOutputPath -like '*powershell-coverage.xml'
            }
        }
    }

    It 'does not call the report seam when the population has no Exemptions property' {
        $capture = @{}
        $population = [pscustomobject]@{ Source = 'config'; Paths = @('scripts/a.ps1') }
        $seams = & $script:NewSeams $capture $population

        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams
        }

        $capture.ContainsKey('ReportCalls') | Should -BeFalse
        $capture['PesterCalls'] | Should -Be 1
    }

    It 'does not call the report seam when Exemptions is null' {
        $capture = @{}
        $population = [pscustomobject]@{ Source = 'settings'; Paths = @('scripts/a.ps1'); Exemptions = $null }
        $seams = & $script:NewSeams $capture $population

        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName New-Item -MockWith { }
            Invoke-PoshQCTest @Seams
        }

        $capture.ContainsKey('ReportCalls') | Should -BeFalse
    }

    It 'stops before Pester when the resolver throws for an invalid manifest' {
        # Arrange: the resolver fails the way an invalid manifest does.
        $capture = @{}
        $seams = & $script:NewSeams $capture $null
        $seams.ResolveCoveragePopulation = { throw 'Invalid .push-down-manifest.json: unknown major schema_version ''2.0.0''.' }

        # Act and Assert
        {
            InModuleScope PoshQC -Parameters @{ Seams = $seams } {
                param([hashtable] $Seams)
                Mock -CommandName New-Item -MockWith { }
                Invoke-PoshQCTest @Seams
            }
        } | Should -Throw -ExpectedMessage '*.push-down-manifest.json*'
        $capture.ContainsKey('PesterCalls') | Should -BeFalse
        $capture.ContainsKey('ReportCalls') | Should -BeFalse
    }
}
