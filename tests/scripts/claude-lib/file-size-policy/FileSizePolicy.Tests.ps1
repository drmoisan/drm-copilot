#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the pure file-size policy functions in FileSizePolicy.psm1 (issue #990).

.DESCRIPTION
    Drives the line counter, tier classifier, relative-path conversion, covered-path
    test, and single-entry ratchet comparison with the shared in-memory rows in
    FileSizePolicy.Cases.ps1. No row creates a file, starts a process, or reads the
    clock. The module is removed in AfterAll so no other suite inherits it.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'FileSizePolicy.Cases.ps1')
}

BeforeAll {
    $script:ModulePath = Join-Path $PSScriptRoot '../../../../.claude/lib/file-size-policy/FileSizePolicy.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
}

Describe 'Get-FileSizePolicyLimit' {
    It 'returns the 500 guidance, 700 advisory, and 800 hard limits' {
        # Act
        $limit = Get-FileSizePolicyLimit

        # Assert
        $limit.Guidance | Should -Be 500
        $limit.Advisory | Should -Be 700
        $limit.HardLimit | Should -Be 800
    }
}

Describe 'Get-FileSizeLogicalLineCount' {
    It 'counts <Name> as <Expected> lines' -ForEach $script:FileSizeLineCountCases {
        # Act
        $count = Get-FileSizeLogicalLineCount -Content $Content

        # Assert
        $count | Should -Be $Expected
    }

    It 'counts null content as zero lines' {
        Get-FileSizeLogicalLineCount -Content $null | Should -Be 0
    }

    It 'counts CRLF and LF text of the same lines identically' {
        # Arrange: 801 lines built in memory with each terminator.
        $lines = 1..801 | ForEach-Object { "line $_" }
        $lf = ($lines -join "`n") + "`n"
        $crlf = ($lines -join "`r`n") + "`r`n"

        # Act / Assert
        Get-FileSizeLogicalLineCount -Content $lf | Should -Be 801
        Get-FileSizeLogicalLineCount -Content $crlf | Should -Be 801
    }
}

Describe 'Get-FileSizeTier' {
    It 'classifies <LineCount> lines as <Expected>' -ForEach $script:FileSizeTierCases {
        Get-FileSizeTier -LineCount $LineCount | Should -Be $Expected
    }

    It 'rejects a negative line count' {
        { Get-FileSizeTier -LineCount -1 } | Should -Throw '*must be non-negative*'
    }
}

Describe 'Get-FileSizeExcludedSegment' {
    It 'includes the <Segment> directory name' -ForEach $script:FileSizeExcludedSegmentCases {
        Get-FileSizeExcludedSegment | Should -Contain $Segment
    }

    It 'returns exactly the fixture count' -ForEach @(@{ ExpectedCount = $script:FileSizeExcludedSegmentCases.Count }) {
        @(Get-FileSizeExcludedSegment).Count | Should -Be $ExpectedCount
    }

    It 'returns a fresh array on each call' {
        # Arrange
        $first = @(Get-FileSizeExcludedSegment)
        $expected = $first[0]

        # Act: mutate the first result, then request the list again.
        $first[0] = 'mutated'
        $second = @(Get-FileSizeExcludedSegment)

        # Assert
        $second[0] | Should -BeExactly $expected
    }

    It 'makes Test-FileSizeCoveredPath exclude every returned name' {
        # Arrange
        $names = @(Get-FileSizeExcludedSegment)

        # Act / Assert
        foreach ($name in $names) {
            Test-FileSizeCoveredPath -RelativePath "src/$name/tool.py" | Should -BeFalse -Because "'$name' is excluded"
        }
    }
}

Describe 'Test-FileSizeCoveredPath' {
    It 'reports <Path> as covered = <Expected>' -ForEach $script:FileSizeCoveredPathCases {
        Test-FileSizeCoveredPath -RelativePath $Path | Should -Be $Expected
    }

    It 'excludes a file under the <Segment> directory' -ForEach $script:FileSizeExcludedSegmentCases {
        # Arrange: the excluded name is a directory segment, nested and at the root.
        $nested = "src/$Segment/tool.py"
        $root = "$Segment/tool.py"

        # Act / Assert
        Test-FileSizeCoveredPath -RelativePath $nested | Should -BeFalse
        Test-FileSizeCoveredPath -RelativePath $root | Should -BeFalse
    }

    It 'reports a null path as not covered' {
        Test-FileSizeCoveredPath -RelativePath $null | Should -BeFalse
    }
}

Describe 'ConvertTo-FileSizeRelativePath' {
    It 'converts <Name>' -ForEach $script:FileSizeRelativePathCases {
        # Act
        $relative = ConvertTo-FileSizeRelativePath -Path $Path -RepositoryRoot $Root

        # Assert
        $relative | Should -Be $Expected
    }

    It 'returns null for a null path' {
        ConvertTo-FileSizeRelativePath -Path $null -RepositoryRoot '/repo' | Should -BeNullOrEmpty
    }
}

Describe 'Compare-FileSizeBaselineEntry' {
    It 'evaluates the ratchet row: <Name>' -ForEach $script:FileSizeBaselineCases {
        # Act
        $violation = Compare-FileSizeBaselineEntry -Path 'scripts/large.py' -CurrentSize $Current -BaselineSize $Baseline

        # Assert
        if ($null -eq $ExpectedRule) {
            $violation | Should -BeNullOrEmpty
        } else {
            $violation.Rule | Should -Be $ExpectedRule
            $violation.Path | Should -Be 'scripts/large.py'
            $violation.Message | Should -Match ([regex]::Escape('scripts/large.py'))
        }
    }

    It 'names the tightened size in the shrink message' {
        # Act
        $violation = Compare-FileSizeBaselineEntry -Path 'a.py' -CurrentSize 850 -BaselineSize 900

        # Assert: the message tells the author the value to record.
        $violation.Message | Should -Match 'tighten the entry to 850'
    }
}
