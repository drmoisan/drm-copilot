Set-StrictMode -Version Latest

# Unit tests for the Invoke-PoshQCTest shard parameters (issue #953, FR-09).
# Every seam is injected: the defaults import Pester, read the workspace, or create directories,
# so no module is imported, no workspace file is read, and no file is written.

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

    $script:Root = '/shard-root'
    $script:TestPaths = @(1..5 | ForEach-Object { "/shard-root/tests/t$_.Tests.ps1" })

    # Returns the splat of every Invoke-PoshQCTest seam; InvokePester and WriteShardFileList
    # record what they receive in the supplied capture table.
    $script:NewSeams = {
        param([hashtable] $Capture, [object[]] $Enumerated)
        $captureTable = $Capture
        $enumeratedItems = $Enumerated
        @{
            Root                      = $script:Root
            SettingsPath              = '/shard-settings.psd1'
            EnsureModule              = { }
            TestPathExists            = { $true }
            LoadSettings              = { @{ Run = @{ Path = @('tests') } } }
            BuildConfiguration        = {
                param($Table)
                [pscustomobject]@{
                    Run          = @{ Path = @{ Value = $Table.Run.Path }; ExcludePath = @{ Value = @() }; PassThru = $true }
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
            InvokePester              = { param($Config) $captureTable['RunPath'] = $Config.Run.Path; $null }.GetNewClosure()
            CopyCoverage              = { $captureTable['CopyCoverage'] = $true }.GetNewClosure()
            ResolveCoveragePopulation = { [pscustomobject]@{ Source = 'config'; Paths = @() } }
            Logger                    = { param([string] $Message) [void] $Message }
            WriteShardFileList        = { param([string] $Path, [string] $Json) $captureTable['ListPath'] = $Path; $captureTable['ListJson'] = $Json }.GetNewClosure()
        }
    }
}

Describe 'Invoke-PoshQCTest shard parameters' {
    It 'TS01-SHARD-RUNPATH-SELECTED sets Run.Path to the full paths of this shard slice' {
        # Arrange: the default EnumerateTests seam returns FileSystemInfo items, so objects with FullName are used here.
        $capture = @{}
        $enumerated = @($script:TestPaths | ForEach-Object { [pscustomobject]@{ FullName = $_ } })
        $seams = & $script:NewSeams $capture $enumerated

        # Act
        Invoke-PoshQCTest @seams -ShardIndex 2 -ShardCount 2

        # Assert
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/shard-root/tests/t2.Tests.ps1,/shard-root/tests/t4.Tests.ps1'
        $capture.ContainsKey('ListJson') | Should -BeFalse -Because 'no ShardFileListPath was supplied'
    }

    It 'TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM passes the manifest JSON without selectedFullPath to the seam' {
        # Arrange: an injected EnumerateTests seam may return plain strings.
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams -ShardIndex 1 -ShardCount 3 -ShardFileListPath '/shard-root/artifacts/pester/shard-files.json'

        # Assert
        $capture['ListPath'] | Should -BeExactly '/shard-root/artifacts/pester/shard-files.json'
        $manifest = $capture['ListJson'] | ConvertFrom-Json
        $manifest.shardIndex | Should -Be 1
        $manifest.shardCount | Should -Be 3
        (@($manifest.all) -join ',') | Should -BeExactly 'tests/t1.Tests.ps1,tests/t2.Tests.ps1,tests/t3.Tests.ps1,tests/t4.Tests.ps1,tests/t5.Tests.ps1'
        (@($manifest.selected) -join ',') | Should -BeExactly 'tests/t1.Tests.ps1,tests/t4.Tests.ps1'
        @($manifest.PSObject.Properties.Name) | Should -Not -Contain 'selectedFullPath'
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/shard-root/tests/t1.Tests.ps1,/shard-root/tests/t4.Tests.ps1'
    }

    It 'TS03-NO-SHARD-RUNPATH-UNCHANGED leaves Run.Path and the seam untouched when ShardCount is 0' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act
        Invoke-PoshQCTest @seams -ShardFileListPath '/shard-root/artifacts/pester/shard-files.json'

        # Assert
        (@($capture['RunPath'].Value) -join ',') | Should -BeExactly 'tests' -Because 'the configured Run.Path is used unchanged'
        $capture.ContainsKey('ListJson') | Should -BeFalse -Because 'the file-list seam runs only on a sharded run'
    }

    It 'rejects a shard index outside 1..ShardCount before Pester runs' {
        # Arrange
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths

        # Act / Assert
        { Invoke-PoshQCTest @seams -ShardIndex 4 -ShardCount 3 } | Should -Throw '*ShardIndex must be between 1 and 3*'
        $capture.ContainsKey('RunPath') | Should -BeFalse
    }

    It 'TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON writes the manifest through Set-Content in the default WriteShardFileList seam' {
        # Arrange: Set-Content is mocked and Invoke-PoshQCTest is called inside the PoshQC module scope, so the mock
        # and the default seam belong to the same module instance in a full-suite run and no file is written.
        $capture = @{}
        $seams = & $script:NewSeams $capture $script:TestPaths
        $seams.Remove('WriteShardFileList')

        InModuleScope PoshQC -Parameters @{ Seams = $seams } {
            param([hashtable] $Seams)
            Mock -CommandName Set-Content -MockWith { }

            # Act
            Invoke-PoshQCTest @Seams -ShardIndex 2 -ShardCount 2 -ShardFileListPath '/shard-root/artifacts/pester/shard-files.json'

            # Assert
            Should -Invoke -CommandName Set-Content -Times 1 -Exactly -ParameterFilter {
                $LiteralPath -eq '/shard-root/artifacts/pester/shard-files.json' -and ([string] $Encoding -match '(?i)utf-?8') -and ((@((($Value -join "`n") | ConvertFrom-Json).selected) -join ',') -eq 'tests/t2.Tests.ps1,tests/t4.Tests.ps1')
            }
        }
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/shard-root/tests/t2.Tests.ps1,/shard-root/tests/t4.Tests.ps1'
    }

    It 'TS05-EMPTY-SHARD-SLICE-THROWS stops before Pester runs when the shard selects no test file' {
        # Arrange: two test files cannot fill three shards, so shard 3 selects none.
        $capture = @{}
        $seams = & $script:NewSeams $capture @($script:TestPaths[0], $script:TestPaths[1])

        # Act / Assert
        { Invoke-PoshQCTest @seams -ShardIndex 3 -ShardCount 3 -ShardFileListPath '/shard-root/artifacts/pester/shard-files.json' } | Should -Throw '*Shard 3 of 3 selects no test file*'
        $capture.ContainsKey('RunPath') | Should -BeFalse -Because 'Pester must not run with an empty Run.Path'
        $capture.ContainsKey('ListJson') | Should -BeFalse -Because 'no manifest is written for an empty shard'
    }

    It 'TS06-SHARD-WEIGHTED-BY-FILE-SIZE assigns the heaviest test files first to the least-loaded shard' {
        # Arrange: the injected EnumerateTests seam supplies in-memory sizes through a Length property, as FileInfo items do.
        $capture = @{}
        $sizes = @(400, 100, 300, 200)
        $enumerated = @(0..3 | ForEach-Object { [pscustomobject]@{ FullName = $script:TestPaths[$_]; Length = [long] $sizes[$_] } })
        $seams = & $script:NewSeams $capture $enumerated

        # Act
        Invoke-PoshQCTest @seams -ShardIndex 1 -ShardCount 2

        # Assert: t1 (400) and t2 (100) total 500, as do t3 (300) and t4 (200); assignment by position would give t1 and t3 (700).
        (@($capture['RunPath']) -join ',') | Should -BeExactly '/shard-root/tests/t1.Tests.ps1,/shard-root/tests/t2.Tests.ps1'
    }
}
