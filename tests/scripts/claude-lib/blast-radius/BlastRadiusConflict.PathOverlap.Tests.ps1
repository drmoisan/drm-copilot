<#
.SYNOPSIS
    Parity and minimum-tracking tests for the record-form path overlap.

.DESCRIPTION
    Issue #776 rewrote Get-SmallestPathOverlap to decide each pair inline over
    precomputed records instead of calling Test-EntryOverlap per pair. This file
    is the parity guard for that rewrite: every row asserts that the inline
    decision and Test-EntryOverlap agree in both argument orders. It also covers
    the running ordinal minimum and the non-exported ConvertTo-PathOverlapRecord
    helper. Each It targets a single behavior with Arrange-Act-Assert structure.
    The tests invoke no external process and create no temporary files.
#>

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius. Resolve-Path
    # normalizes the separators so Pester's code-coverage breakpoints bind to the
    # same on-disk path the run settings name.
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    $conflictPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusConflict.psm1").Path
    $globPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusGlob.psm1").Path
    # The facade re-imports its siblings with -Force, which replaces an existing
    # module instance, so it is imported first and the conflict module second.
    # The glob module is imported last because neither earlier module re-exports
    # Test-EntryOverlap, and no later -Force sibling import can then replace it.
    Import-Module $facadePath -Force
    Import-Module $conflictPath -Force
    Import-Module $globPath -Force
}

Describe 'Get-SmallestPathOverlap record-form parity (issue #776)' {
    It 'returns <Expected> for <EntryA> against <EntryB> in both argument orders' -ForEach @(
        @{ EntryA = 'a/1.py'; EntryB = 'a/1.py'; Expected = $true }
        @{ EntryA = 'a/1.py'; EntryB = 'a/2.py'; Expected = $false }
        @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/dev_tools/a.py'; Expected = $true }
        @{ EntryA = 'scripts/**'; EntryB = 'scripts/dev_tools/a.py'; Expected = $true }
        @{ EntryA = 'tests/**'; EntryB = 'scripts/a.py'; Expected = $false }
        @{ EntryA = 'scripts/*/a.py'; EntryB = 'scripts/dev_tools/*.py'; Expected = $true }
        @{ EntryA = 'scripts/*.py'; EntryB = 'tests/*.py'; Expected = $false }
        @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/dev_toolsX/a.py'; Expected = $false }
        @{ EntryA = 'docs/features/active/alpha'; EntryB = 'docs/features/active/beta/**'; Expected = $false }
        @{ EntryA = 'scripts/dev_tools/'; EntryB = 'scripts/dev_tools/a.py'; Expected = $true }
        @{ EntryA = 'a//*'; EntryB = 'a//'; Expected = $true }
        @{ EntryA = 'scripts/dev_tools'; EntryB = 'scripts/*/a.py'; Expected = $true }
        @{ EntryA = ''; EntryB = 'a/b.py'; Expected = $false }
    ) {
        # Arrange: the row supplies the pair and the expected verdict.
        $pathA = @($EntryA)
        $pathB = @($EntryB)

        # Act: evaluate the inline decision and the reference relation, both ways.
        $inlineForward = $null -ne (Get-SmallestPathOverlap -PathA $pathA -PathB $pathB)
        $inlineReverse = $null -ne (Get-SmallestPathOverlap -PathA $pathB -PathB $pathA)
        $relationForward = Test-EntryOverlap -EntryA $EntryA -EntryB $EntryB
        $relationReverse = Test-EntryOverlap -EntryA $EntryB -EntryB $EntryA

        # Assert: all four agree with the expected verdict.
        $inlineForward | Should -Be $Expected
        $inlineReverse | Should -Be $Expected
        $relationForward | Should -Be $Expected
        $relationReverse | Should -Be $Expected
    }
}

Describe 'Get-SmallestPathOverlap minimum tracking (issue #776)' {
    It 'returns null when the first collection is empty' {
        # Arrange: an empty first collection.
        $pathB = @('a/1.py')

        # Act: compute the smallest overlap.
        $detail = Get-SmallestPathOverlap -PathA @() -PathB $pathB

        # Assert: no pair exists, so nothing overlaps.
        $detail | Should -BeNullOrEmpty
    }

    It 'returns null when the second collection is empty' {
        # Arrange: an empty second collection.
        $pathA = @('a/1.py')

        # Act: compute the smallest overlap.
        $detail = Get-SmallestPathOverlap -PathA $pathA -PathB @()

        # Assert: no pair exists, so nothing overlaps.
        $detail | Should -BeNullOrEmpty
    }

    It 'returns null when no pair overlaps' {
        # Arrange: a concrete path outside the glob's subtree.
        $pathA = @('scripts/a.py')
        $pathB = @('tests/**')

        # Act: compute the smallest overlap.
        $detail = Get-SmallestPathOverlap -PathA $pathA -PathB $pathB

        # Assert: the disjoint pair yields no detail.
        $null -eq $detail | Should -BeTrue
    }

    It 'returns the ordinally smallest detail rather than the culture smallest' {
        # Arrange: upper-case B sorts before lower-case a only under ordinal order.
        $path = @('B/x.py', 'a/x.py')

        # Act: compute the smallest overlap of the collection with itself.
        $detail = Get-SmallestPathOverlap -PathA $path -PathB $path

        # Assert: the ordinal minimum is reported.
        $detail | Should -BeExactly 'B/x.py ~ B/x.py'
    }

    It 'returns the same detail in both argument orders for a mixed glob and concrete collection' {
        # Arrange: two mixed collections with one glob-to-concrete overlap.
        $pathA = @('tests/b.ps1', 'scripts/**')
        $pathB = @('scripts/dev_tools/a.py', 'tests/b.ps1')

        # Act: compute the smallest overlap in both argument orders.
        $forward = Get-SmallestPathOverlap -PathA $pathA -PathB $pathB
        $reverse = Get-SmallestPathOverlap -PathA $pathB -PathB $pathA

        # Assert: the detail is symmetric and is the ordinal minimum.
        $forward | Should -BeExactly 'scripts/** ~ scripts/dev_tools/a.py'
        $reverse | Should -BeExactly 'scripts/** ~ scripts/dev_tools/a.py'
    }

    It 'orders a glob and its trailing-slash concrete match inside the detail' {
        # Arrange: a glob whose match is a trailing-slash concrete entry.
        $pathA = @('a//*')
        $pathB = @('a//')

        # Act: compute the smallest overlap.
        $detail = Get-SmallestPathOverlap -PathA $pathA -PathB $pathB

        # Assert: the shorter concrete entry sorts first ordinally.
        $detail | Should -BeExactly 'a// ~ a//*'
    }
}

Describe 'ConvertTo-PathOverlapRecord (issue #776)' {
    It 'classifies a glob entry and records its literal prefix' {
        InModuleScope BlastRadiusConflict {
            # Arrange: a subtree glob.
            $entry = 'scripts/**'

            # Act: build its record.
            $record = @(ConvertTo-PathOverlapRecord -Entry @($entry))

            # Assert: one glob record carrying the literal prefix.
            $record.Count | Should -Be 1
            $record[0].IsGlob | Should -BeTrue
            $record[0].Prefix | Should -BeExactly 'scripts/'
        }
    }

    It 'records the anchored directory form of a concrete entry with a trailing separator' {
        InModuleScope BlastRadiusConflict {
            # Arrange: a concrete directory entry that already ends with a separator.
            $entry = 'scripts/dev_tools/'

            # Act: build its record.
            $record = @(ConvertTo-PathOverlapRecord -Entry @($entry))

            # Assert: one concrete record with exactly one trailing separator.
            $record.Count | Should -Be 1
            $record[0].IsGlob | Should -BeFalse
            $record[0].Directory | Should -BeExactly 'scripts/dev_tools/'
        }
    }
}
