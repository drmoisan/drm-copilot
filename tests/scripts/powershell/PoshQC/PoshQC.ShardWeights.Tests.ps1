Set-StrictMode -Version Latest

# Unit tests for the measured shard weights in scripts/powershell/PoshQC/PoshQC.Shard.psm1 (issue #1048).
# Weights text is supplied in memory through the ReadWeightsText seam, FileInfo items name paths that are
# never opened, and test-file text comes from the ReadTestFileText seam, so no file is read or written.

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

    $script:Root = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'shard-weights-root'
    $script:NewItems = {
        param([string[]] $Names)
        @($Names | ForEach-Object { [System.IO.FileInfo]::new((Join-Path $script:Root "tests/$_")) })
    }
    # Every test file text is 10 bytes, so the size path gives equal weights unless a case says otherwise.
    $script:ReadTenBytes = { param([string] $Path) [void] $Path; 'x' * 10 }
    $script:WeightsJson = {
        param([hashtable] $Files)
        [ordered]@{ version = 1; unit = 'ms'; files = $Files } | ConvertTo-Json -Depth 4
    }
}

Describe 'Get-PoshQCShardTestFileWeight measured weights' {
    It 'SW01-LISTED-FILES-USE-MILLISECONDS weighs each listed file by its milliseconds' {
        # Arrange
        $items = & $script:NewItems @('a.Tests.ps1', 'b.Tests.ps1')
        $text = & $script:WeightsJson @{ 'tests/a.Tests.ps1' = 500; 'tests/b.Tests.ps1' = 1500 }
        $reader = { param([string] $RootPath) [void] $RootPath; $text }.GetNewClosure()

        # Act
        $weights = InModuleScope PoshQC -Parameters @{ Items = $items; Root = $script:Root; Reader = $reader; ReadText = $script:ReadTenBytes } {
            param([object[]] $Items, [string] $Root, [scriptblock] $Reader, [scriptblock] $ReadText)
            @(Get-PoshQCShardTestFileWeight -TestFile $Items -RootPath $Root -ReadWeightsText $Reader -ReadTestFileText $ReadText)
        }

        # Assert
        ($weights -join ',') | Should -BeExactly '500,1500'
    }

    It 'SW02-UNLISTED-FILE-USES-MEDIAN weighs a file without an entry by the median of the listed values' {
        # Arrange: listed values 100, 300 and 900 have the median 300.
        $items = & $script:NewItems @('a.Tests.ps1', 'b.Tests.ps1', 'new.Tests.ps1')
        $text = & $script:WeightsJson @{ 'tests/a.Tests.ps1' = 100; 'tests/b.Tests.ps1' = 900; 'tests/gone.Tests.ps1' = 300 }
        $reader = { param([string] $RootPath) [void] $RootPath; $text }.GetNewClosure()

        # Act
        $weights = InModuleScope PoshQC -Parameters @{ Items = $items; Root = $script:Root; Reader = $reader; ReadText = $script:ReadTenBytes } {
            param([object[]] $Items, [string] $Root, [scriptblock] $Reader, [scriptblock] $ReadText)
            @(Get-PoshQCShardTestFileWeight -TestFile $Items -RootPath $Root -ReadWeightsText $Reader -ReadTestFileText $ReadText)
        }

        # Assert
        ($weights -join ',') | Should -BeExactly '100,900,300'
    }

    It 'SW03-ABSENT-FILE-FALLS-BACK-TO-SIZE selects by object size when the root holds no weights file' {
        # Arrange: the root does not exist, so it holds no config/poshqc-shard-weights.json.
        $absentRoot = Join-Path ([System.IO.Path]::GetPathRoot($PSScriptRoot)) 'shard-weights-absent-root'
        $sizes = @(400, 100, 300, 200)
        $items = @(0..3 | ForEach-Object { [pscustomobject]@{ FullName = "$absentRoot/tests/t$_.Tests.ps1"; Length = [long] $sizes[$_] } })

        # Act
        $selected = InModuleScope PoshQC -Parameters @{ Items = $items; Root = $absentRoot } {
            param([object[]] $Items, [string] $Root)
            @(Select-PoshQCShardTestFile -RootPath $Root -TestFile $Items -ShardIndex 1 -ShardCount 2 -WriteShardFileList { })
        }

        # Assert: sizes 400 and 100 total 500, as do 300 and 200.
        ($selected -join ',') | Should -BeExactly "$absentRoot/tests/t0.Tests.ps1,$absentRoot/tests/t1.Tests.ps1"
    }

    It 'SW04-MALFORMED-FILE-THROWS rejects every malformed weights document with a message naming the file' {
        # Arrange: invalid JSON, a non-object document, wrong version, wrong unit, an empty files map, a
        # non-relative key, and a negative value.
        $items = & $script:NewItems @('a.Tests.ps1')
        $malformed = @(
            '{ not json',
            '[1, 2]',
            (& $script:WeightsJson @{ '/abs/tests/a.Tests.ps1' = 1 }),
            (& $script:WeightsJson @{ 'tests/a.Tests.ps1' = 1 }).Replace('"version": 1', '"version": 2'),
            (& $script:WeightsJson @{ 'tests/a.Tests.ps1' = 1 }).Replace('"ms"', '"s"'),
            (& $script:WeightsJson @{}),
            (& $script:WeightsJson @{ 'tests/a.Tests.ps1' = -5 })
        )

        # Act / Assert
        foreach ($text in $malformed) {
            $reader = { param([string] $RootPath) [void] $RootPath; $text }.GetNewClosure()
            {
                InModuleScope PoshQC -Parameters @{ Items = $items; Root = $script:Root; Reader = $reader; ReadText = $script:ReadTenBytes } {
                    param([object[]] $Items, [string] $Root, [scriptblock] $Reader, [scriptblock] $ReadText)
                    Get-PoshQCShardTestFileWeight -TestFile $Items -RootPath $Root -ReadWeightsText $Reader -ReadTestFileText $ReadText
                }
            } | Should -Throw '*poshqc-shard-weights.json*' -Because "the document '$text' is malformed"
        }
    }

    It 'SW05-NO-ROOT-KEEPS-SIZE-PATH weighs FileInfo items by text size when no root is supplied' {
        # Arrange
        $items = & $script:NewItems @('a.Tests.ps1', 'b.Tests.ps1')
        $texts = @{ 'a.Tests.ps1' = 'x' * 7; 'b.Tests.ps1' = 'y' * 3 }
        $readText = { param([string] $Path) $texts[[System.IO.Path]::GetFileName($Path)] }.GetNewClosure()

        # Act
        $weights = InModuleScope PoshQC -Parameters @{ Items = $items; ReadText = $readText } {
            param([object[]] $Items, [scriptblock] $ReadText)
            @(Get-PoshQCShardTestFileWeight -TestFile $Items -ReadTestFileText $ReadText)
        }

        # Assert
        ($weights -join ',') | Should -BeExactly '7,3'
    }

    It 'SW06-SELECT-PASSES-ROOT-AND-READER assigns shards by the measured weights read through the supplied reader' {
        # Arrange: by size every file is equal; by measured weight c alone balances a and b.
        $items = & $script:NewItems @('a.Tests.ps1', 'b.Tests.ps1', 'c.Tests.ps1')
        $text = & $script:WeightsJson @{ 'tests/a.Tests.ps1' = 100; 'tests/b.Tests.ps1' = 100; 'tests/c.Tests.ps1' = 200 }
        $reader = { param([string] $RootPath) [void] $RootPath; $text }.GetNewClosure()
        $paths = @($items | ForEach-Object { $_.FullName })

        # Act
        $selected = InModuleScope PoshQC -Parameters @{ Items = $items; Root = $script:Root; Reader = $reader } {
            param([object[]] $Items, [string] $Root, [scriptblock] $Reader)
            @(Select-PoshQCShardTestFile -RootPath $Root -TestFile $Items -ShardIndex 1 -ShardCount 2 -WriteShardFileList { } -ReadWeightsText $Reader)
        }

        # Assert: c (200) is assigned first to shard 1; a and b (100 each) fill shard 2.
        ($selected -join ',') | Should -BeExactly $paths[2]
    }

    It 'SW07-DEFAULT-READER-RETURNS-TEXT-OR-NULL reads config/poshqc-shard-weights.json under the root only when it exists' {
        # Arrange
        $items = & $script:NewItems @('a.Tests.ps1', 'b.Tests.ps1')
        $text = & $script:WeightsJson @{ 'tests/a.Tests.ps1' = 40; 'tests/b.Tests.ps1' = 60 }

        $result = InModuleScope PoshQC -Parameters @{ Items = $items; Root = $script:Root; Text = $text; ReadText = $script:ReadTenBytes } {
            param([object[]] $Items, [string] $Root, [string] $Text, [scriptblock] $ReadText)
            # The mock body is built from the literal text, because Pester rebinds a mock body to the module scope.
            Mock -CommandName Get-Content -MockWith ([scriptblock]::Create("'" + $Text.Replace("'", "''") + "'"))

            # Act: the weights file exists, then it does not.
            Mock -CommandName Test-Path -MockWith { $true }
            $present = @(Get-PoshQCShardTestFileWeight -TestFile $Items -RootPath $Root -ReadTestFileText $ReadText)
            Mock -CommandName Test-Path -MockWith { $false }
            $absent = @(Get-PoshQCShardTestFileWeight -TestFile $Items -RootPath $Root -ReadTestFileText $ReadText)

            Should -Invoke -CommandName Get-Content -Times 1 -Exactly -ParameterFilter { $Raw -and $LiteralPath -match 'config[\\/]poshqc-shard-weights\.json$' }
            [pscustomobject]@{ Present = $present -join ','; Absent = $absent -join ',' }
        }

        # Assert
        $result.Present | Should -BeExactly '40,60' -Because 'the default reader returns the text of an existing weights file'
        $result.Absent | Should -BeExactly '10,10' -Because 'the default reader returns null for an absent file, so the size path runs'
    }
}
