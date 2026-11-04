#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageOrphans.psm1.

.DESCRIPTION
    Covers entry-page selection (README.md before index.md, none), breadth-first reachability
    with cycles, nested roots, DOCS_PAGE_ORPHAN findings, entry pages never being orphans, and a
    seeded property test: the orphan result is unchanged under permutation of the page listing
    and of edge insertion order. Every input is an in-memory array or map.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageOrphans.psm1') -Force -ErrorAction Stop

    function Get-TestOrphanPath {
        param([string[]] $PageSet, [string[]] $EntryPage, [System.Collections.IDictionary] $Edge)
        $reachable = Get-DocsPageReachable -EntryPage $EntryPage -Edge $Edge
        $findings = Get-DocsPageOrphanFinding -PageSet $PageSet -Reachable $reachable
        @($findings | ForEach-Object { $_.artifact_path })
    }
}

AfterAll {
    Remove-Module -Name DocsPageOrphans, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPageEntryPage' {
    It 'prefers README.md over index.md' {
        Get-DocsPageEntryPage -RootPath 'docs' -PageSet @('docs/index.md', 'docs/README.md') | Should -BeExactly 'docs/README.md'
    }

    It 'falls back to index.md and accepts a trailing slash on the root' {
        Get-DocsPageEntryPage -RootPath 'docs/' -PageSet @('docs/index.md', 'docs/a.md') | Should -BeExactly 'docs/index.md'
    }

    It 'returns $null when the root has neither page, including a nested README only' {
        Get-DocsPageEntryPage -RootPath 'docs' -PageSet @('docs/sub/README.md', 'docs/readme.md') | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsPageReachable' {
    It 'walks breadth-first, terminates on cycles and returns the sorted reachable set' {
        # Arrange
        $edge = @{ 'docs/README.md' = @('docs/b.md', 'docs/a.md'); 'docs/a.md' = @('docs/README.md', 'docs/c.md'); 'docs/c.md' = @('docs/a.md'); 'docs/x.md' = @('docs/y.md') }

        # Act
        $reachable = Get-DocsPageReachable -EntryPage @('docs/README.md') -Edge $edge

        # Assert
        $reachable | Should -Be @('docs/README.md', 'docs/a.md', 'docs/b.md', 'docs/c.md')
    }

    It 'returns an empty set without entry pages' {
        $reachable = Get-DocsPageReachable -EntryPage @() -Edge @{ 'a.md' = @('b.md') }
        $reachable.Count | Should -Be 0
    }
}

Describe 'Get-DocsPageOrphanFinding' {
    It 'reports DOCS_PAGE_ORPHAN for each unreachable page with the page as artifact_path' {
        # Act
        $findings = Get-DocsPageOrphanFinding -PageSet @('docs/README.md', 'docs/lost.md', 'docs/a.md') -Reachable @('docs/README.md', 'docs/a.md')

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_ORPHAN'
        $findings[0].artifact_path | Should -BeExactly 'docs/lost.md'
        $findings[0].pointer | Should -BeExactly ''
        $findings[0].severity | Should -BeExactly 'error'
        $findings[0].message | Should -BeExactly 'page is not reachable from any documentation-root entry page'
    }

    It 'never reports an entry page, even one that nothing links to' {
        Get-TestOrphanPath -PageSet @('docs/README.md', 'docs/api/index.md') -EntryPage @('docs/README.md', 'docs/api/index.md') -Edge @{} | Should -Be @()
    }

    It 'reaches pages of a nested root from its own entry page and reports pages that only a non-page links to' {
        # Arrange
        $pages = @('docs/README.md', 'docs/api/README.md', 'docs/api/x.md', 'docs/z.md')
        $edge = @{ 'docs/api/README.md' = @('docs/api/x.md'); 'notes/outside.md' = @('docs/z.md') }

        # Act and Assert
        Get-TestOrphanPath -PageSet $pages -EntryPage @('docs/README.md', 'docs/api/README.md') -Edge $edge | Should -Be @('docs/z.md')
    }

    It 'returns the same orphans under seeded permutation of the page listing and of edge insertion order' {
        # Arrange
        $seed = 1021
        $random = [System.Random]::new($seed)
        $pages = @('docs/README.md', 'docs/a.md', 'docs/b.md', 'docs/c.md', 'docs/d.md', 'docs/e.md', 'docs/api/index.md', 'docs/api/f.md')
        $edges = @(@('docs/README.md', 'docs/a.md'), @('docs/a.md', 'docs/b.md'), @('docs/b.md', 'docs/a.md'), @('docs/api/index.md', 'docs/api/f.md'), @('docs/d.md', 'docs/e.md'), @('docs/a.md', 'docs/c.md'))
        $entries = @('docs/README.md', 'docs/api/index.md')
        $expected = (Get-TestOrphanPath -PageSet $pages -EntryPage $entries -Edge @{ 'docs/README.md' = @('docs/a.md'); 'docs/a.md' = @('docs/b.md', 'docs/c.md'); 'docs/b.md' = @('docs/a.md'); 'docs/api/index.md' = @('docs/api/f.md'); 'docs/d.md' = @('docs/e.md') }) -join '|'

        for ($round = 0; $round -lt 25; $round++) {
            $pageOrder = @($pages | Sort-Object { $random.Next() })
            $edge = [ordered]@{}
            foreach ($pair in @($edges | Sort-Object { $random.Next() })) {
                if (-not $edge.Contains($pair[0])) { $edge[$pair[0]] = [System.Collections.Generic.List[string]]::new() }
                $edge[$pair[0]].Add($pair[1])
            }
            $sorted = [string[]] $pageOrder
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)

            # Act
            $reachable = Get-DocsPageReachable -EntryPage @($entries | Sort-Object { $random.Next() }) -Edge $edge
            $actual = (@(Get-DocsPageOrphanFinding -PageSet $sorted -Reachable $reachable) | ForEach-Object { $_.artifact_path }) -join '|'

            # Assert (the seed is printed through -Because on failure)
            $actual | Should -BeExactly $expected -Because "seed $seed round $round"
            $expected | Should -BeExactly 'docs/d.md|docs/e.md'
        }
    }
}
