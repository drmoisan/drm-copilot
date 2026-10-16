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
    It 'SH01-SLICE-ROUND-ROBIN assigns positions i where i % ShardCount equals ShardIndex - 1, in input order' {
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
