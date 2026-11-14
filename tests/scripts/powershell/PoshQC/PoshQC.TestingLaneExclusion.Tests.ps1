Set-StrictMode -Version Latest

# Unit tests for the Invoke-PoshQCTest, Invoke-PoshQCSuite, and Get-PoshQCParallelShardArgument lane
# parameters -ExcludeTag and -ExcludeTestFileSuffix (issue #1158, spec D27).
# Every seam is injected, so no module is imported by Pester, no workspace file is read, and no file is written.

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

    $script:TestPaths = @(
        '/lane-root/tests/a.Tests.ps1'
        '/lane-root/tests/b.Integration.Tests.ps1'
        '/lane-root/tests/c.Tests.ps1'
        '/lane-root/tests/d.Tests.ps1'
    )

    # Returns the splat of every Invoke-PoshQCTest seam; InvokePester, Logger, and WriteShardFileList record
    # what they receive in the supplied capture table.
    $script:NewSeams = {
        param([hashtable] $Capture, [object[]] $Enumerated)
        $captureTable = $Capture
        $enumeratedItems = $Enumerated
        $captureTable['Messages'] = [System.Collections.Generic.List[string]]::new()
        @{
            Root                      = '/lane-root'
            SettingsPath              = '/lane-settings.psd1'
            EnsureModule              = { }
            TestPathExists            = { $true }
            LoadSettings              = { @{ Run = @{ Path = @('tests') } } }
            BuildConfiguration        = {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() }; PassThru = $true }
                    Filter       = @{ ExcludeTag = @{ Value = @('Existing') } }
                    TestResult   = @{ Enabled = @{ Value = $false }; OutputPath = @{ Value = $null } }
                    CodeCoverage = $null
                    Output       = @{ Verbosity = 'Normal' }
                }
            }
            ExpandRunPaths            = { param($Config) $Config }
            EnsureResultPath          = { param($Config) $Config }
            ExpandCoveragePaths       = { param($Config) $Config }
            ResolveScanConfig         = { @() }
            ResolveScanFolders        = { @() }
            EnumerateTests            = { $enumeratedItems }.GetNewClosure()
            InvokePester              = { param($Config) $captureTable['RunPath'] = $Config.Run.Path; $captureTable['ExcludeTag'] = $Config.Filter.ExcludeTag; $captureTable['Invoked'] = $true; $null }.GetNewClosure()
            CopyCoverage              = { }
            ResolveCoveragePopulation = { [pscustomobject]@{ Source = 'config'; Paths = @() } }
            Logger                    = { param([string] $Message) $captureTable['Messages'].Add($Message) }.GetNewClosure()
            WriteShardFileList        = { param([string] $Path, [string] $Json) [void] $Path; $captureTable['ListJson'] = $Json }.GetNewClosure()
        }
    }

    $script:ShardArguments = @{
        ModuleManifestPath = '/lane-root/scripts/powershell/PoshQC/PoshQC.psd1'
        Root               = '/lane-root'
        ShardIndex         = 1
        ShardCount         = 2
        ShardDirectory     = '/lane-root/artifacts/pester/parallel/shard-1'
    }
}

Describe 'Invoke-PoshQCTest lane exclusion (issue #1158)' {
    It 'LE01-TAGS-REACH-FILTER appends the excluded tags to Filter.ExcludeTag' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams -ExcludeTag @('Integration', 'Golden')

        # Assert
        (@($capture['ExcludeTag']) -join ',') | Should -BeExactly 'Existing,Integration,Golden'
    }

    It 'LE02-SUFFIX-FILTERED-BEFORE-SHARDING removes a suffixed file from the shard population' {
        # Arrange
        $capture = @{}
        $enumerated = @($script:TestPaths | ForEach-Object { [pscustomobject]@{ FullName = $_ } })
        $seams = & $script:NewSeams $capture $enumerated

        # Act
        Invoke-PoshQCTest @seams -ShardIndex 1 -ShardCount 1 -ShardFileListPath '/lane-root/shard-files.json' -ExcludeTestFileSuffix @('.integration.tests.ps1')

        # Assert
        $manifest = $capture['ListJson'] | ConvertFrom-Json
        (@($manifest.all) -join ',') | Should -BeExactly 'tests/a.Tests.ps1,tests/c.Tests.ps1,tests/d.Tests.ps1'
    }

    It 'LE03-UNSHARDED-RUNPATH-FILTERED sets Run.Path to the kept files when a suffix removes one' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams -ExcludeTestFileSuffix @('.INTEGRATION.tests.ps1')

        # Assert
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/lane-root/tests/a.Tests.ps1,/lane-root/tests/c.Tests.ps1,/lane-root/tests/d.Tests.ps1'
    }

    It 'LE04-UNSHARDED-NO-SUFFIX-RUNPATH-UNCHANGED keeps the scan folders when no suffix is given' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams

        # Assert
        (@($capture['RunPath'].Value) -join ',') | Should -BeExactly 'tests'
        (@($capture['ExcludeTag'].Value) -join ',') | Should -BeExactly 'Existing'
    }

    It 'LE05-UNMATCHED-SUFFIX-RUNPATH-UNCHANGED keeps the scan folders when the suffix removes no file' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams -ExcludeTestFileSuffix @('.golden.tests.ps1')

        # Assert
        (@($capture['RunPath'].Value) -join ',') | Should -BeExactly 'tests'
    }

    It 'LE06-ALL-FILES-EXCLUDED logs no test files and does not invoke Pester' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams -ExcludeTestFileSuffix @('.tests.ps1')

        # Assert
        $capture.ContainsKey('Invoked') | Should -BeFalse
        @($capture['Messages'] | Where-Object { $_ -like 'No Pester test files found*' }).Count | Should -Be 1
    }
}

Describe 'Get-PoshQCParallelShardArgument lane exclusion (issue #1158)' {
    It 'LE07-SHARD-TEXT-BINDS-ARRAYS writes values that parse as array constants in order' {
        # Arrange
        $tags = @('Integration', 'Golden')
        $suffixes = @('.integration.tests.ps1', '-integration.test.ts', "it's.tests.ps1")

        # Act
        $arguments = InModuleScope PoshQC -Parameters @{ Splat = $script:ShardArguments; Tags = $tags; Suffixes = $suffixes } {
            param($Splat, $Tags, $Suffixes)
            Get-PoshQCParallelShardArgument @Splat -ExcludeTag $Tags -ExcludeTestFileSuffix $Suffixes
        }
        $command = $arguments[-1]
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($command, [ref]$tokens, [ref]$errors)
        $invocation = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Invoke-PoshQCTest' }, $true))[0]
        $bound = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($invocation, $false)
        $valuesOf = {
            param([string] $Name)
            $expression = $bound.BoundParameters[$Name].Value
            @($expression.FindAll({ param($node) $node -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true) | ForEach-Object { $_.Value })
        }

        # Assert
        @($errors).Count | Should -Be 0
        $bound.BoundParameters['ExcludeTag'].Value | Should -BeOfType ([System.Management.Automation.Language.ArrayExpressionAst])
        $bound.BoundParameters['ExcludeTestFileSuffix'].Value | Should -BeOfType ([System.Management.Automation.Language.ArrayExpressionAst])
        (& $valuesOf 'ExcludeTag') -join '|' | Should -BeExactly 'Integration|Golden'
        (& $valuesOf 'ExcludeTestFileSuffix') -join '|' | Should -BeExactly ".integration.tests.ps1|-integration.test.ts|it's.tests.ps1"
    }

    It 'LE08-SHARD-TEXT-UNCHANGED-WITHOUT-LANES leaves the command text unchanged when both are omitted' {
        # Act
        $default = InModuleScope PoshQC -Parameters @{ Splat = $script:ShardArguments } { param($Splat) Get-PoshQCParallelShardArgument @Splat }
        $empty = InModuleScope PoshQC -Parameters @{ Splat = $script:ShardArguments } {
            param($Splat)
            Get-PoshQCParallelShardArgument @Splat -ExcludeTag @() -ExcludeTestFileSuffix @()
        }

        # Assert
        $default[-1] | Should -Not -Match 'Exclude'
        ($empty -join "`n") | Should -BeExactly ($default -join "`n")
    }
}

Describe 'Invoke-PoshQCSuite lane exclusion (issue #1158)' {
    It 'LE09-SUITE-PASSES-LANES forwards both lane parameters to Invoke-PoshQCTest once' {
        InModuleScope PoshQC {
            # Arrange
            Mock -CommandName Invoke-PoshQCFormat -MockWith { }
            Mock -CommandName Invoke-PoshQCAnalyze -MockWith { }
            Mock -CommandName Invoke-PoshQCTest -MockWith { }

            # Act
            Invoke-PoshQCSuite -Root '/lane-root' -ScanFolders @('tests') -ExcludeTag @('Integration', 'Golden') -ExcludeTestFileSuffix @('.integration.tests.ps1')

            # Assert
            Should -Invoke -CommandName Invoke-PoshQCTest -Times 1 -Exactly -ParameterFilter {
                ($ExcludeTag -join ',') -ceq 'Integration,Golden' -and ($ExcludeTestFileSuffix -join ',') -ceq '.integration.tests.ps1'
            }
        }
    }

    It 'LE10-SUITE-OMITS-LANES binds neither lane parameter when both are omitted' {
        InModuleScope PoshQC {
            # Arrange
            Mock -CommandName Invoke-PoshQCFormat -MockWith { }
            Mock -CommandName Invoke-PoshQCAnalyze -MockWith { }
            Mock -CommandName Invoke-PoshQCTest -MockWith { }

            # Act
            Invoke-PoshQCSuite -Root '/lane-root' -ScanFolders @('tests')

            # Assert
            Should -Invoke -CommandName Invoke-PoshQCTest -Times 1 -Exactly -ParameterFilter {
                -not $PesterBoundParameters.ContainsKey('ExcludeTag') -and -not $PesterBoundParameters.ContainsKey('ExcludeTestFileSuffix')
            }
        }
    }
}
