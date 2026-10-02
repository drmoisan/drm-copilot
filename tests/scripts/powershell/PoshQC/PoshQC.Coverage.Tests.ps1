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

Describe 'Invoke-PoshQCTest coverage population (issue #527)' {
    # Every scenario drives Invoke-PoshQCTest through injected seams and an in-memory workspace
    # rooted at /cov-root. No test creates a file: Test-Path, Get-ChildItem, and Get-Content are
    # answered from $script:covTreeFiles, and New-Item is mocked so no directory is created.
    BeforeAll {
        InModuleScope PoshQC {
            $script:covConfigJson = '{"version": 1, "roots": ["scripts", ".claude/hooks"]}'
            $script:covFirstTree = @('/cov-root/scripts/a.ps1', '/cov-root/scripts/b.psm1', '/cov-root/.claude/hooks/h.ps1', '/cov-root/config/poshqc-coverage.json')
            $script:covFirstSettings = @{
                Run          = @{ Path = @('tests') }
                Output       = @{ Verbosity = 'Detailed' }
                TestResult   = @{ Enabled = $false }
                CodeCoverage = @{ Enabled = $true; Path = @('scripts/a.ps1', 'scripts/b.psm1', '.claude/hooks/h.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
            }

            # Registers the in-memory filesystem mocks used by R1 to R3. The default coverage seams
            # run unmocked on top of these, so they execute and count toward coverage.
            $script:covRegisterTreeMocks = {
                Mock -CommandName New-Item -MockWith { }
                Mock -CommandName Test-Path -MockWith {
                    param([string[]] $Path, [string[]] $LiteralPath, $PathType)
                    $requested = if ($LiteralPath) { $LiteralPath[0] } else { $Path[0] }
                    $normalized = ([string] $requested -replace '\\', '/').TrimEnd('/')
                    $isFile = $script:covTreeFiles -contains $normalized
                    $isDirectory = @($script:covTreeFiles | Where-Object { $_.StartsWith("$normalized/") }).Count -gt 0
                    if ([string] $PathType -eq 'Container') { return $isDirectory }
                    if ([string] $PathType -eq 'Leaf') { return $isFile }
                    return ($isFile -or $isDirectory)
                }
                Mock -CommandName Get-ChildItem -MockWith {
                    param([string[]] $Path, [string[]] $LiteralPath, [switch] $Recurse, [switch] $File, [switch] $Force)
                    $requested = if ($LiteralPath) { $LiteralPath[0] } else { $Path[0] }
                    $prefix = ([string] $requested -replace '\\', '/').TrimEnd('/') + '/'
                    foreach ($treeFile in $script:covTreeFiles) {
                        if ($treeFile.StartsWith($prefix)) {
                            [pscustomobject]@{ FullName = $treeFile; Extension = [IO.Path]::GetExtension($treeFile); Name = [IO.Path]::GetFileName($treeFile) }
                        }
                    }
                }
                Mock -CommandName Get-Content -MockWith {
                    param([string[]] $Path, [string[]] $LiteralPath, [switch] $Raw)
                    $requested = if ($LiteralPath) { $LiteralPath[0] } else { $Path[0] }
                    if (([string] $requested -replace '\\', '/') -eq '/cov-root/config/poshqc-coverage.json') { return $script:covConfigJson }
                    throw "Unexpected Get-Content path in the in-memory workspace: $requested"
                }
            }

            # Returns a fresh parameter set for Invoke-PoshQCTest; tests override individual seams.
            $script:covNewParameters = {
                @{
                    Root                = '/cov-root'
                    EnsureModule        = { }
                    TestPathExists      = {
                        param([string] $Path)
                        $normalized = ($Path -replace '\\', '/').TrimEnd('/')
                        if ($normalized -like '*pester.runsettings.psd1') { return $true }
                        $isDirectory = @($script:covTreeFiles | Where-Object { $_.StartsWith("$normalized/") }).Count -gt 0
                        return (($script:covTreeFiles -contains $normalized) -or $isDirectory)
                    }
                    LoadSettings        = { $script:covSettings }
                    BuildConfiguration  = {
                        param($Table)
                        [pscustomobject]@{
                            Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() } }
                            TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                            CodeCoverage = @{ Enabled = $true; Path = @{ Value = $Table.CodeCoverage.Path }; OutputPath = @{ Value = $Table.CodeCoverage.OutputPath } }
                            Output       = @{ Verbosity = 'Normal' }
                        }
                    }
                    ExpandCoveragePaths = { param($Config, [string] $RootPath) [void] $RootPath; $Config }
                    ResolveScanConfig   = { @() }
                    EnumerateTests      = { @([pscustomobject]@{ FullName = '/cov-root/tests/sample.Tests.ps1' }) }
                    InvokePester        = { param($Config) $script:covCapturedConfig = $Config; $script:covPesterInvoked = $true }
                    CopyCoverage        = { param([string] $CoveragePath, [string] $RepoRoot, [string] $KoveragePath) $script:covCopyInvoked = $true }
                    Logger              = { param([string] $Message) $script:covLogs.Add($Message) }
                }
            }
        }
    }

    BeforeEach {
        InModuleScope PoshQC {
            $script:covCapturedConfig = $null
            $script:covPesterInvoked = $false
            $script:covCopyInvoked = $false
            $script:covRecordedScanFolderRoots = $null
            $script:covLogs = [System.Collections.Generic.List[string]]::new()
            $script:covSettings = $script:covFirstSettings
            $script:covTreeFiles = $script:covFirstTree
        }
    }

    It 'measures an identical population for the repository and bundled settings copies over the same workspace' {
        InModuleScope PoshQC {
            # Arrange: one workspace and two settings tables that differ only in CodeCoverage.Path,
            # standing in for the repository copy and a stale bundled copy of the runsettings.
            & $script:covRegisterTreeMocks
            $secondSettings = @{
                Run          = @{ Path = @('tests') }
                Output       = @{ Verbosity = 'Detailed' }
                TestResult   = @{ Enabled = $false }
                CodeCoverage = @{ Enabled = $true; Path = @('scripts/a.ps1', '.claude/hooks/h.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
            }
            $parameters = & $script:covNewParameters

            # Act
            $script:covSettings = $script:covFirstSettings
            Invoke-PoshQCTest @parameters | Out-Null
            $firstPopulation = @($script:covCapturedConfig.CodeCoverage.Path | ForEach-Object { $_ -replace '\\', '/' })
            $script:covSettings = $secondSettings
            Invoke-PoshQCTest @parameters | Out-Null
            $secondPopulation = @($script:covCapturedConfig.CodeCoverage.Path | ForEach-Object { $_ -replace '\\', '/' })

            # Assert: the measured set depends on the workspace, not on the settings copy.
            $secondPopulation | Should -Be $firstPopulation
            $firstPopulation | Should -Be @('/cov-root/.claude/hooks/h.ps1', '/cov-root/scripts/a.ps1', '/cov-root/scripts/b.psm1')
        }
    }

    It 'measures only the consumer production file when a stale bundled allow-list names pushed-down files' {
        InModuleScope PoshQC {
            # Arrange: the #623 item 1 layout with no workspace coverage configuration.
            & $script:covRegisterTreeMocks
            $script:covTreeFiles = @('/cov-root/scripts/Sample.psm1', '/cov-root/tests/scripts/Sample.Tests.ps1', '/cov-root/.claude/hooks/validate-bash.ps1')
            $script:covSettings = @{
                Run          = @{ Path = @('scripts', 'tests/powershell', 'tests/scripts') }
                Output       = @{ Verbosity = 'Detailed' }
                TestResult   = @{ Enabled = $false }
                CodeCoverage = @{ Enabled = $true; Path = @('.claude/hooks/validate-bash.ps1', 'scripts/dev-tools/run-pester.ps1'); OutputPath = 'artifacts/pester/coverage.xml' }
            }
            $parameters = & $script:covNewParameters
            $parameters.Remove('ResolveScanConfig')
            $parameters.ScanFolders = @('scripts', 'tests/scripts')
            $parameters.ResolveScanFolders = { param([string] $RootPath, [string[]] $Folders) @($Folders | ForEach-Object { Join-Path -Path $RootPath -ChildPath $_ }) }

            # Act
            Invoke-PoshQCTest @parameters | Out-Null

            # Assert: only the consumer's production file is measured.
            $population = @($script:covCapturedConfig.CodeCoverage.Path | ForEach-Object { $_ -replace '\\', '/' })
            $population | Should -Be @('/cov-root/scripts/Sample.psm1')
        }
    }

    It 'logs the population source and file count before Pester runs' {
        InModuleScope PoshQC {
            # Arrange: the R1 workspace; the Pester seam appends a marker to the same log list.
            & $script:covRegisterTreeMocks
            $parameters = & $script:covNewParameters
            $parameters.InvokePester = { param($Config) $script:covCapturedConfig = $Config; $script:covLogs.Add('PESTER-INVOKED') }

            # Act
            Invoke-PoshQCTest @parameters | Out-Null

            # Assert: the population line is present and precedes the Pester invocation.
            $populationLine = 'Code coverage population: source=config; files=3'
            $script:covLogs | Should -Contain $populationLine
            $script:covLogs.IndexOf('PESTER-INVOKED') | Should -BeGreaterThan $script:covLogs.IndexOf($populationLine)
        }
    }

    It 'resolves a relative Root to an absolute path before building run, coverage, and output paths' {
        InModuleScope -ModuleName PoshQC -Parameters @{ TestDirectory = $PSScriptRoot } -ScriptBlock {
            param([string] $TestDirectory)

            # Arrange
            Mock -CommandName New-Item -MockWith { }
            $parameters = & $script:covNewParameters
            $parameters.Root = '.'
            $parameters.TestPathExists = { $true }
            $parameters.ResolveCoveragePopulation = { param([string] $RootPath) [pscustomobject]@{ Source = 'config'; Paths = @(Join-Path -Path $RootPath -ChildPath 'scripts/a.ps1') } }

            # Act: run from the test directory so '.' has a known absolute meaning.
            Push-Location -LiteralPath $TestDirectory
            try {
                Invoke-PoshQCTest @parameters | Out-Null
            } finally {
                Pop-Location
            }

            # Assert: every run, coverage, and output path is absolute and under the test directory.
            $prefix = ($TestDirectory -replace '\\', '/').TrimEnd('/')
            $runPaths = @($script:covCapturedConfig.Run.Path)
            $runPaths.Count | Should -BeGreaterThan 0
            $capturedPaths = $runPaths + @($script:covCapturedConfig.CodeCoverage.Path) + @($script:covCapturedConfig.CodeCoverage.OutputPath)
            foreach ($capturedPath in $capturedPaths) {
                [IO.Path]::IsPathRooted([string] $capturedPath) | Should -BeTrue -Because "'$capturedPath' must be absolute"
                ([string] $capturedPath -replace '\\', '/').StartsWith("$prefix/", [StringComparison]::OrdinalIgnoreCase) | Should -BeTrue -Because "'$capturedPath' must sit under '$prefix'"
            }
        }
    }

    It 'disables coverage, logs once, and still runs Pester when the derived population is empty' {
        InModuleScope PoshQC {
            # Arrange
            Mock -CommandName New-Item -MockWith { }
            $parameters = & $script:covNewParameters
            $parameters.TestPathExists = { $true }
            $parameters.ResolveCoveragePopulation = { [pscustomobject]@{ Source = 'fallback'; Paths = @() } }

            # Act
            Invoke-PoshQCTest @parameters | Out-Null

            # Assert: coverage is disabled at the Pester boundary, the run proceeds, and no copy is made.
            $script:covCapturedConfig.CodeCoverage.Enabled | Should -BeFalse
            @($script:covLogs | Where-Object { $_ -like 'Code coverage disabled for this invocation*' }).Count | Should -Be 1
            $script:covPesterInvoked | Should -BeTrue
            $script:covCopyInvoked | Should -BeFalse
        }
    }

    It 'hands the scan-configuration folders to the coverage resolver when -ScanFolders is absent' {
        InModuleScope PoshQC {
            # Arrange: no -Root and no -ScanFolders; every filesystem seam is injected.
            Mock -CommandName New-Item -MockWith { }
            $parameters = & $script:covNewParameters
            $parameters.Remove('Root')
            $parameters.TestPathExists = { $true }
            $parameters.ResolveScanConfig = { @('scripts') }
            $parameters.ResolveScanFolders = { param([string] $RootPath, [string[]] $Folders) @($Folders | ForEach-Object { Join-Path -Path $RootPath -ChildPath $_ }) }
            $parameters.ResolveCoveragePopulation = {
                param([string] $RootPath, $Settings, [string] $SettingsFile, [string[]] $ScanFolderRoots)
                $script:covRecordedScanFolderRoots = $ScanFolderRoots
                [pscustomobject]@{ Source = 'fallback'; Paths = @('/cov-root/scripts/a.ps1') }
            }

            # Act
            Invoke-PoshQCTest @parameters | Out-Null

            # Assert: the scan-configuration folders reached the coverage resolver.
            $script:covRecordedScanFolderRoots | Should -Be @('scripts')
        }
    }
}

Describe 'Get-PoshQCCoverageFileSet (issue #527)' {
    # Every scenario answers existence and enumeration from $script:setDirectories and
    # $script:setFiles, so no scenario reads the real filesystem.
    BeforeAll {
        InModuleScope PoshQC {
            $script:newFileSetParameters = {
                @{
                    Root           = '/set-root'
                    TestPathExists = { param([string] $Path) $script:setDirectories -contains (($Path -replace '\\', '/').TrimEnd('/')) }
                    EnumerateFiles = {
                        param([string] $Path)
                        $prefix = ($Path -replace '\\', '/').TrimEnd('/') + '/'
                        foreach ($fullName in $script:setFiles) {
                            if ($fullName.StartsWith($prefix)) {
                                [pscustomobject]@{ FullName = $fullName; Extension = [IO.Path]::GetExtension($fullName); Name = [IO.Path]::GetFileName($fullName) }
                            }
                        }
                    }
                    WarningLogger  = { param([string] $Message) $script:setWarnings.Add($Message) }
                }
            }
        }
    }

    BeforeEach {
        InModuleScope PoshQC {
            $script:setDirectories = @('/set-root/scripts')
            $script:setFiles = @()
            $script:setWarnings = [System.Collections.Generic.List[string]]::new()
        }
    }

    It 'returns the same ordinally sorted list for shuffled enumeration order' {
        InModuleScope PoshQC {
            # Arrange: ordinal order puts 'B2' before 'a' and 'b'; a culture-aware sort would not.
            $parameters = & $script:newFileSetParameters
            $expected = @('scripts/B2.ps1', 'scripts/a.psm1', 'scripts/b.ps1', 'scripts/sub/c.ps1')

            # Act: enumerate the same files in two different orders.
            $script:setFiles = @('/set-root/scripts/b.ps1', '/set-root/scripts/sub/c.ps1', '/set-root/scripts/B2.ps1', '/set-root/scripts/a.psm1')
            $first = @(Get-PoshQCCoverageFileSet -Roots @('scripts') @parameters | ForEach-Object { $_.RelativePath })
            $script:setFiles = @('/set-root/scripts/a.psm1', '/set-root/scripts/B2.ps1', '/set-root/scripts/sub/c.ps1', '/set-root/scripts/b.ps1')
            $second = @(Get-PoshQCCoverageFileSet -Roots @('scripts') @parameters | ForEach-Object { $_.RelativePath })

            # Assert
            $first | Should -Be $expected
            $second | Should -Be $expected
        }
    }

    It 'collapses case-variant duplicates to one entry' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:newFileSetParameters
            $script:setFiles = @('/set-root/scripts/tool.ps1', '/set-root/scripts/other.ps1', '/set-root/scripts/Tool.ps1')

            # Act
            $relativePaths = @(Get-PoshQCCoverageFileSet -Roots @('scripts') @parameters | ForEach-Object { $_.RelativePath })

            # Assert: one entry per case-insensitive path; the ordinally smallest variant is kept.
            $relativePaths | Should -Be @('scripts/Tool.ps1', 'scripts/other.ps1')
            $relativePaths[0] | Should -BeExactly 'scripts/Tool.ps1'
        }
    }

    It 'collapses files reached through overlapping roots' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:newFileSetParameters
            $script:setDirectories = @('/set-root/scripts', '/set-root/scripts/powershell')
            $script:setFiles = @('/set-root/scripts/a.ps1', '/set-root/scripts/powershell/b.psm1')

            # Act
            $relativePaths = @(Get-PoshQCCoverageFileSet -Roots @('scripts', 'scripts/powershell') @parameters | ForEach-Object { $_.RelativePath })

            # Assert
            $relativePaths | Should -Be @('scripts/a.ps1', 'scripts/powershell/b.psm1')
        }
    }

    It 'excludes *.Tests.ps1 files, the root-level tests tree, and default excluded directories' {
        InModuleScope PoshQC {
            # Arrange: a nested 'tests' directory is not the root-level tests tree and is kept.
            $parameters = & $script:newFileSetParameters
            $script:setDirectories = @('/set-root/scripts', '/set-root/tests')
            $script:setFiles = @(
                '/set-root/scripts/keep.ps1',
                '/set-root/scripts/keep.Tests.ps1',
                '/set-root/scripts/node_modules/dep.ps1',
                '/set-root/scripts/artifacts/out.ps1',
                '/set-root/scripts/tests/nested.ps1',
                '/set-root/tests/helper.ps1'
            )

            # Act
            $relativePaths = @(Get-PoshQCCoverageFileSet -Roots @('scripts', 'tests') @parameters | ForEach-Object { $_.RelativePath })

            # Assert
            $relativePaths | Should -Be @('scripts/keep.ps1', 'scripts/tests/nested.ps1')
        }
    }

    It 'keeps only .ps1 and .psm1 files' {
        InModuleScope PoshQC {
            # Arrange: the extension check is case-insensitive.
            $parameters = & $script:newFileSetParameters
            $script:setFiles = @('/set-root/scripts/a.ps1', '/set-root/scripts/b.psm1', '/set-root/scripts/c.psd1', '/set-root/scripts/d.txt', '/set-root/scripts/E.PS1')

            # Act
            $relativePaths = @(Get-PoshQCCoverageFileSet -Roots @('scripts') @parameters | ForEach-Object { $_.RelativePath })

            # Assert
            $relativePaths | Should -Be @('scripts/E.PS1', 'scripts/a.ps1', 'scripts/b.psm1')
        }
    }

    It 'skips a nonexistent root with one warning naming the root' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:newFileSetParameters
            $script:setFiles = @('/set-root/scripts/a.ps1')

            # Act
            $relativePaths = @(Get-PoshQCCoverageFileSet -Roots @('scripts', 'missing') @parameters | ForEach-Object { $_.RelativePath })

            # Assert
            $relativePaths | Should -Be @('scripts/a.ps1')
            $script:setWarnings.Count | Should -Be 1
            $script:setWarnings[0] | Should -Be "Coverage root 'missing' does not exist under '/set-root'; skipping."
        }
    }

    It 'returns an empty set when every root is missing' {
        InModuleScope PoshQC {
            # Arrange
            $parameters = & $script:newFileSetParameters
            $script:setDirectories = @()

            # Act
            $relativePaths = @(Get-PoshQCCoverageFileSet -Roots @('gone', 'absent') @parameters | ForEach-Object { $_.RelativePath })

            # Assert: one warning per missing root, each naming its root.
            $relativePaths | Should -Be @()
            $script:setWarnings.Count | Should -Be 2
            $script:setWarnings[0] | Should -BeLike "*'gone'*"
            $script:setWarnings[1] | Should -BeLike "*'absent'*"
        }
    }
}
