Set-StrictMode -Version Latest

# Unit tests for scripts/powershell/PoshQC/PoshQC.Shard.psm1 (issue #953, FR-09).
# Every case uses in-memory arrays and objects only; no file is read or written.

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

    $script:Root = 'C:/repo'
    $script:Files = @(
        'C:/repo/tests/a.Tests.ps1',
        'C:\repo\tests\b.Tests.ps1',
        'c:/REPO/tests/c.Tests.ps1',
        'C:/repo/tests/d.Tests.ps1',
        'C:/repo/tests/e.Tests.ps1'
    )
    $script:NewManifestSet = {
        param([int] $Count)
        @(1..$Count | ForEach-Object { New-PoshQCShardManifest -RootPath $script:Root -TestFile $script:Files -ShardIndex $_ -ShardCount $Count })
    }
}

Describe 'Get-PoshQCShardSlice' {
    It 'SH01-SLICE-ROUND-ROBIN assigns equally weighted files round-robin in ordinal path order and returns them in input order' {
        # Arrange
        $files = @(0..9 | ForEach-Object { "f$_" })

        # Act
        $shard1 = @(Get-PoshQCShardSlice -TestFile $files -ShardIndex 1 -ShardCount 3)
        $shard2 = @(Get-PoshQCShardSlice -TestFile $files -ShardIndex 2 -ShardCount 3)
        $shard3 = @(Get-PoshQCShardSlice -TestFile $files -ShardIndex 3 -ShardCount 3)

        # Assert
        ($shard1 -join ',') | Should -BeExactly 'f0,f3,f6,f9' -Because 'shard 1 receives positions 0, 3, 6 and 9'
        ($shard2 -join ',') | Should -BeExactly 'f1,f4,f7'
        ($shard3 -join ',') | Should -BeExactly 'f2,f5,f8'
    }

    It 'SH02-SLICE-INVALID-INDEX-THROWS rejects index 0, index 4 of 3, and a shard count below 1' {
        # Arrange
        $files = @('a', 'b', 'c')

        # Act / Assert
        { Get-PoshQCShardSlice -TestFile $files -ShardIndex 0 -ShardCount 3 } | Should -Throw '*ShardIndex must be between 1 and 3*'
        { Get-PoshQCShardSlice -TestFile $files -ShardIndex 4 -ShardCount 3 } | Should -Throw '*ShardIndex must be between 1 and 3*'
        { Get-PoshQCShardSlice -TestFile $files -ShardIndex 1 -ShardCount 0 } | Should -Throw '*ShardCount must be at least 1*'
    }

    It 'SH10-SLICE-WEIGHTED-LPT assigns the heaviest file first to the shard with the least assigned weight' {
        # Arrange
        $files = @('t1', 't2', 't3', 't4', 't5', 't6')
        $weights = [long[]] @(4, 9, 3, 8, 5, 1)

        # Act
        $shard1 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 1 -ShardCount 3)
        $shard2 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 2 -ShardCount 3)
        $shard3 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 3 -ShardCount 3)

        # Assert: the loads are 9 + 1, 3 + 8, and 4 + 5; assignment by position would load 12, 14, and 4.
        ($shard1 -join ',') | Should -BeExactly 't2,t6'
        ($shard2 -join ',') | Should -BeExactly 't3,t4' -Because 'each slice keeps input order'
        ($shard3 -join ',') | Should -BeExactly 't1,t5'
        (@($shard1 + $shard2 + $shard3 | Sort-Object) -join ',') | Should -BeExactly 't1,t2,t3,t4,t5,t6' -Because 'every file is assigned to exactly one shard'
    }

    It 'SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER breaks weight ties by ordinal path order, not culture order' {
        # Arrange: the ordinal order is 'A', 'B', 'a'; a culture-aware sort would place 'a' before 'B'.
        $files = @('B', 'a', 'A')
        $weights = [long[]] @(5, 5, 5)

        # Act
        $shard1 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 1 -ShardCount 2)
        $shard2 = @(Get-PoshQCShardSlice -TestFile $files -Weight $weights -ShardIndex 2 -ShardCount 2)

        # Assert: 'A' goes to shard 1 and 'B' to shard 2; 'a' then goes to shard 1, the lower index among equal loads and file counts.
        ($shard1 -join ',') | Should -BeExactly 'a,A' -Because 'each slice keeps input order'
        ($shard2 -join ',') | Should -BeExactly 'B'
    }

    It 'SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS rejects a weight list whose length differs from the file list' {
        { Get-PoshQCShardSlice -TestFile @('a', 'b', 'c') -Weight @(1, 2) -ShardIndex 1 -ShardCount 2 } | Should -Throw '*Weight lists 2 values; TestFile lists 3 files*'
    }

    It 'SH13-SLICE-NEGATIVE-WEIGHT-THROWS rejects a negative weight and names the file (CR-18)' {
        { Get-PoshQCShardSlice -TestFile @('a', 'b', 'c') -Weight @(2, -1, 3) -ShardIndex 1 -ShardCount 2 } | Should -Throw "*Weight must not be negative; 'b' has weight -1*"
        (@(Get-PoshQCShardSlice -TestFile @('a', 'b') -Weight @(0, 0) -ShardIndex 1 -ShardCount 2) -join ',') | Should -BeExactly 'a' -Because 'a zero weight is valid'
    }
}

Describe 'New-PoshQCShardManifest' {
    It 'SH03-MANIFEST-RELATIVE-PATHS strips the root case-insensitively and keeps the full slice paths' {
        # Act
        $manifest = New-PoshQCShardManifest -RootPath 'C:\repo\' -TestFile $script:Files -ShardIndex 2 -ShardCount 2

        # Assert
        $manifest.shardIndex | Should -Be 2
        $manifest.shardCount | Should -Be 2
        ($manifest.all -join ',') | Should -BeExactly 'tests/a.Tests.ps1,tests/b.Tests.ps1,tests/c.Tests.ps1,tests/d.Tests.ps1,tests/e.Tests.ps1'
        ($manifest.selected -join ',') | Should -BeExactly 'tests/b.Tests.ps1,tests/d.Tests.ps1'
        ($manifest.selectedFullPath -join ',') | Should -BeExactly 'C:\repo\tests\b.Tests.ps1,C:/repo/tests/d.Tests.ps1' -Because 'selectedFullPath is the slice as given'
    }

    It 'keeps the forward-slash form of a path outside the root' {
        # Act
        $manifest = New-PoshQCShardManifest -RootPath 'C:/repo' -TestFile @('D:\other\x.Tests.ps1') -ShardIndex 1 -ShardCount 1

        # Assert
        @($manifest.all) | Should -Be @('D:/other/x.Tests.ps1')
    }
}

Describe 'Test-PoshQCShardCompleteness' {
    It 'SH04-COMPLETENESS-PASS returns true for a complete, disjoint set of manifests, including JSON round trips' {
        # Arrange
        $manifests = & $script:NewManifestSet 3
        $roundTripped = @($manifests | ForEach-Object { $_ | Select-Object -Property shardIndex, shardCount, all, selected | ConvertTo-Json -Depth 4 | ConvertFrom-Json })

        # Act / Assert
        Test-PoshQCShardCompleteness -ShardManifest $manifests | Should -BeTrue
        Test-PoshQCShardCompleteness -ShardManifest ($roundTripped | Sort-Object -Property shardIndex -Descending) | Should -BeTrue
    }

    It 'SH05-COMPLETENESS-MISSING-FILE-THROWS when a manifest is absent or a selection drops a file' {
        # Arrange
        $manifests = & $script:NewManifestSet 3
        $dropped = & $script:NewManifestSet 3
        $dropped[1].selected = @($dropped[1].selected | Select-Object -Skip 1)

        # Act / Assert
        { Test-PoshQCShardCompleteness -ShardManifest @($manifests[0], $manifests[1]) } | Should -Throw '*declares shardCount 3*'
        { Test-PoshQCShardCompleteness -ShardManifest @($manifests[0], $manifests[2]) } | Should -Throw '*not exactly 1..2*'
        { Test-PoshQCShardCompleteness -ShardManifest $dropped } | Should -Throw '*do not cover every test file*'
    }

    It 'SH06-COMPLETENESS-OVERLAP-THROWS when two shards select the same file or an index repeats' {
        # Arrange
        $overlap = & $script:NewManifestSet 2
        $overlap[1].selected = @($overlap[1].selected) + @($overlap[0].selected[0])
        $repeated = & $script:NewManifestSet 2
        $repeated[1].shardIndex = 1

        # Act / Assert
        { Test-PoshQCShardCompleteness -ShardManifest $overlap } | Should -Throw '*selected by more than one shard*'
        { Test-PoshQCShardCompleteness -ShardManifest $repeated } | Should -Throw '*not exactly 1..2*'
    }

    It 'SH07-COMPLETENESS-DIVERGENT-ALL-THROWS when one shard reports a different all list' {
        # Arrange
        $manifests = & $script:NewManifestSet 2
        $manifests[1].all = @($manifests[1].all) + @('tests/extra.Tests.ps1')

        # Act / Assert
        { Test-PoshQCShardCompleteness -ShardManifest $manifests } | Should -Throw "*'all' list that differs*"
    }
}

Describe 'Test-PoshQCShardTestCount' {
    It 'SH08-TESTCOUNT-MISMATCH-THROWS when the shard counts do not sum to the discovery count' {
        { Test-PoshQCShardTestCount -ShardTestCount @(10, 20, 30) -DiscoveryCount 61 } | Should -Throw '*sum to 60*found 61*'
        { Test-PoshQCShardTestCount -ShardTestCount @() -DiscoveryCount 1 } | Should -Throw '*sum to 0*'
    }

    It 'SH09-TESTCOUNT-MATCH-PASSES when the shard counts sum to the discovery count' {
        Test-PoshQCShardTestCount -ShardTestCount @(10, 20, 30) -DiscoveryCount 60 | Should -BeTrue
        Test-PoshQCShardTestCount -ShardTestCount @() -DiscoveryCount 0 | Should -BeTrue
    }
}

Describe 'Get-PoshQCShardTestFileWeight and Select-PoshQCShardTestFile weights' {
    It 'SH14-WEIGHT-IGNORES-LINE-ENDINGS weights a FileInfo item by the UTF-8 size of its text with CRLF counted as LF (CR-19)' {
        # Arrange: in-memory texts only; the FileInfo items name paths that are never opened.
        $texts = @{ 'a.Tests.ps1' = ("x`n" * 10); 'b.Tests.ps1' = (('y' * 24) + "`n") }
        $readLf = { param([string] $Path) $texts[[System.IO.Path]::GetFileName($Path)] }.GetNewClosure()
        $readCrLf = { param([string] $Path) $texts[[System.IO.Path]::GetFileName($Path)].Replace("`n", "`r`n") }.GetNewClosure()

        InModuleScope PoshQC -Parameters @{ LfReader = $readLf; CrLfReader = $readCrLf } {
            param([scriptblock] $LfReader, [scriptblock] $CrLfReader)
            $items = @([System.IO.FileInfo]::new('/shard-root/tests/a.Tests.ps1'), [System.IO.FileInfo]::new('/shard-root/tests/b.Tests.ps1'))

            # Act
            $lfWeights = @(Get-PoshQCShardTestFileWeight -TestFile $items -ReadTestFileText $LfReader)
            $crLfWeights = @(Get-PoshQCShardTestFileWeight -TestFile $items -ReadTestFileText $CrLfReader)
            $otherWeights = @(Get-PoshQCShardTestFileWeight -TestFile @('/shard-root/tests/c.Tests.ps1', [pscustomobject]@{ FullName = '/shard-root/tests/d.Tests.ps1'; Length = [long] 7 }))

            # Assert: raw CRLF sizes (30 and 26) would make a heavier than b; the normalized sizes keep b heavier.
            ($lfWeights -join ',') | Should -BeExactly '20,25'
            ($crLfWeights -join ',') | Should -BeExactly '20,25' -Because 'a CRLF checkout must compute the same weights as an LF checkout'
            ($otherWeights -join ',') | Should -BeExactly '1,7' -Because 'a path string weighs 1 and another object weighs its Length property'
        }
    }

    It 'SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT reads FileInfo items through the default reader and gives shard 1 the heavier file (CR-19)' {
        # Arrange: two checked-in module files are read; nothing is written.
        $moduleRoot = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC'
        $items = @(Get-Item -LiteralPath (Join-Path $moduleRoot 'PoshQC.Shard.psm1'), (Join-Path $moduleRoot 'PoshQC.CoverageMerge.psm1'))

        InModuleScope PoshQC -Parameters @{ Items = $items } {
            param([object[]] $Items)
            $readCrLf = { param([string] $Path) [System.IO.File]::ReadAllText($Path) -replace "`r?`n", "`r`n" }

            # Act
            $defaultWeights = @(Get-PoshQCShardTestFileWeight -TestFile $Items)
            $crLfWeights = @(Get-PoshQCShardTestFileWeight -TestFile $Items -ReadTestFileText $readCrLf)
            $selected = @(Select-PoshQCShardTestFile -RootPath '/shard-root' -TestFile $Items -ShardIndex 1 -ShardCount 2 -WriteShardFileList { })

            # Assert
            ($defaultWeights -join ',') | Should -BeExactly ($crLfWeights -join ',') -Because 'the default reader and a CRLF copy of the same text give equal weights'
            $defaultWeights[0] | Should -Not -Be $defaultWeights[1] -Because 'the two module files differ in size'
            $heavier = if ($defaultWeights[0] -gt $defaultWeights[1]) { $Items[0].FullName } else { $Items[1].FullName }
            ($selected -join ',') | Should -BeExactly $heavier -Because 'shard 1 receives the heaviest file first'
        }
    }
}
