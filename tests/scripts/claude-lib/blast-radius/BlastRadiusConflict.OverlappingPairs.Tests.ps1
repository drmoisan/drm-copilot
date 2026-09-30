<#
.SYNOPSIS
    Order, empty-input, case, and parity tests for Get-OverlappingPathPair.

.DESCRIPTION
    Issue #776 added Get-OverlappingPathPair so the conflict relation and the
    scheduling cost share one indexed overlap enumeration. These tests pin its
    contract: empty inputs yield no pair, pairs come out in nested-loop order
    (outer over PathA, inner over PathB, input order) with the PathA entry first,
    each of the four glob/concrete cases yields its pair, and the full output
    equals a nested Test-EntryOverlap loop, including one pair per occurrence of a
    repeated entry. Each It follows Arrange-Act-Assert. The tests invoke no
    external process and create no temporary files.
#>

BeforeAll {
    # Resolve the modules four levels up: blast-radius -> claude-lib -> scripts ->
    # tests -> repo root, then into .claude/lib/blast-radius.
    $facadePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadius.psm1").Path
    $conflictPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusConflict.psm1").Path
    $globPath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/blast-radius/BlastRadiusGlob.psm1").Path
    # The facade re-imports its siblings with -Force, so it is imported first and
    # the conflict module second. The glob module is imported last so no later
    # -Force sibling import replaces the Test-EntryOverlap reference relation.
    Import-Module $facadePath -Force
    Import-Module $conflictPath -Force
    Import-Module $globPath -Force

    # Format returned pairs as EntryA|EntryB strings, preserving order.
    function Format-OverlapPairList {
        param([object[]] $Pair = @())
        return @($Pair | ForEach-Object { '{0}|{1}' -f $_['EntryA'], $_['EntryB'] })
    }

    # The parity matrix: concrete, trailing-separator, empty, root, glob, and
    # sibling-prefix entries, ending with a repeat of an earlier entry (17 entries).
    function Get-OverlapPairMatrix {
        return @('', '/', 'a', 'a/', 'a/1.py', 'a/1.py/', 'a//', 'a//*', 'x/y', 'x/y/z.md', 'x/**', 'x/*/z.md',
            'scripts/dev_tools', 'scripts/dev_toolsX/a.py', 'docs/features/active/alpha', 'docs/features/active/beta/**', 'a/1.py')
    }
}

Describe 'Get-OverlappingPathPair (issue #776)' {
    It 'returns no pair when the first collection is empty' {
        # Arrange: an empty first collection.
        $pathB = @('a/1.py', 'a/**')

        # Act: enumerate the overlapping pairs.
        $pair = @(Get-OverlappingPathPair -PathA @() -PathB $pathB)

        # Assert: nothing overlaps.
        $pair.Count | Should -Be 0
    }

    It 'returns no pair when the second collection is empty' {
        # Arrange: an empty second collection.
        $pathA = @('a/1.py', 'a/**')

        # Act: enumerate the overlapping pairs.
        $pair = @(Get-OverlappingPathPair -PathA $pathA -PathB @())

        # Assert: nothing overlaps.
        $pair.Count | Should -Be 0
    }

    It 'emits pairs outer over PathA and inner over PathB in input order' {
        # Arrange: collections whose input order is not ordinal order.
        $pathA = @('z/1.py', 'a/1.py')
        $pathB = @('z/1.py', 'a/**', 'a/1.py')

        # Act: enumerate and format the pairs.
        $actual = @(Format-OverlapPairList -Pair @(Get-OverlappingPathPair -PathA $pathA -PathB $pathB))

        # Assert: nested-loop order, not value order.
        $actual.Count | Should -Be 3
        ($actual -join "`n") | Should -BeExactly (@('z/1.py|z/1.py', 'a/1.py|a/**', 'a/1.py|a/1.py') -join "`n")
    }

    It 'keeps the PathA entry first in each pair' {
        # Arrange: a glob and a concrete entry it matches.
        $glob = @('src/**')
        $concrete = @('src/a.py')

        # Act: enumerate in both argument orders.
        $forward = @(Format-OverlapPairList -Pair @(Get-OverlappingPathPair -PathA $glob -PathB $concrete))
        $swapped = @(Format-OverlapPairList -Pair @(Get-OverlappingPathPair -PathA $concrete -PathB $glob))

        # Assert: EntryA always comes from PathA.
        ($forward -join "`n") | Should -BeExactly 'src/**|src/a.py'
        ($swapped -join "`n") | Should -BeExactly 'src/a.py|src/**'
    }

    It 'returns exactly one pair for the <Case> case' -ForEach @(
        @{ Case = 'concrete-concrete'; EntryA = 'a/1.py'; EntryB = 'a/1.py' }
        @{ Case = 'glob-concrete'; EntryA = 'scripts/**'; EntryB = 'scripts/a.py' }
        @{ Case = 'concrete-glob'; EntryA = 'scripts/a.py'; EntryB = 'scripts/**' }
        @{ Case = 'glob-glob'; EntryA = 'scripts/*/a.py'; EntryB = 'scripts/dev_tools/*.py' }
    ) {
        # Arrange: one entry on each side.
        $pathA = @($EntryA)
        $pathB = @($EntryB)

        # Act: enumerate and format the pairs.
        $actual = @(Format-OverlapPairList -Pair @(Get-OverlappingPathPair -PathA $pathA -PathB $pathB))

        # Assert: the single overlapping pair, PathA entry first.
        $actual.Count | Should -Be 1
        $actual[0] | Should -BeExactly "$EntryA|$EntryB"
    }

    It 'matches a nested Test-EntryOverlap loop exactly with <Orientation> input' -ForEach @(
        @{ Orientation = 'forward'; ReverseA = $false }
        @{ Orientation = 'reversed'; ReverseA = $true }
    ) {
        # Arrange: MATRIX on one side and MATRIX reversed on the other, and the
        # expected list from a nested reference loop over PathA then PathB.
        $matrix = [string[]](Get-OverlapPairMatrix)
        $reversed = [string[]](Get-OverlapPairMatrix)
        [array]::Reverse($reversed)
        $pathA = if ($ReverseA) { $reversed } else { $matrix }
        $pathB = if ($ReverseA) { $matrix } else { $reversed }
        $expected = [System.Collections.Generic.List[string]]::new()
        foreach ($entryA in $pathA) {
            foreach ($entryB in $pathB) {
                if (Test-EntryOverlap -EntryA $entryA -EntryB $entryB) { $expected.Add("$entryA|$entryB") }
            }
        }

        # Act: enumerate and format the pairs.
        $actual = @(Format-OverlapPairList -Pair @(Get-OverlappingPathPair -PathA $pathA -PathB $pathB))

        # Assert: the same pairs in the same order, and one pair per occurrence of
        # the repeated entry (2 occurrences in PathA x 2 in PathB), counted by
        # exact ordinal string equality.
        $pathA.Count | Should -Be 17
        $actual.Count | Should -Be $expected.Count
        ($actual -join "`n") | Should -BeExactly ($expected -join "`n")
        $duplicate = @($actual | Where-Object { [string]::Equals($_, 'a/1.py|a/1.py', [System.StringComparison]::Ordinal) })
        $duplicate.Count | Should -Be 4
    }
}
