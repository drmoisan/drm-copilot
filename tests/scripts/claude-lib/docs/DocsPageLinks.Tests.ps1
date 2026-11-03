#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageLinks.psm1.

.DESCRIPTION
    Covers the slug rule, heading de-duplication, explicit anchors, inline, image and
    definition link forms, skipped targets, percent-decoding, root-relative, escaping and
    directory resolution, the four link and anchor finding codes, masked regions, self-links and
    a seeded property test of slug determinism and per-page anchor uniqueness. Every page is an
    in-memory string; no file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageLinks.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instance that DocsPageLinks imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageMarkdown.psm1') -ErrorAction Stop

    function Get-TestModel {
        param([string[]] $Line)
        Get-DocsPageLineModel -Line $Line
    }

    function Get-TestLinkFinding {
        # Checks the links of one in-memory page against an in-memory page map (path to lines).
        param([string] $PagePath, [hashtable] $Page, [string[]] $ExistingPath = @())
        $anchors = @{}
        foreach ($key in $Page.Keys) { $anchors[$key] = Get-DocsPageAnchor -LineModel (Get-TestModel -Line $Page[$key]) }
        $links = Get-DocsPageLink -LineModel (Get-TestModel -Line $Page[$PagePath])
        Get-DocsPageLinkFinding -PagePath $PagePath -Link $links -PageAnchor $anchors -PageSet ([string[]] @($Page.Keys)) -ExistingPath $ExistingPath
    }

    $script:Marker = '<!-- docs:generated:start id=cli-command-' + ('a' * 64) + ' -->'
    $script:EndMarker = '<!-- docs:generated:end id=cli-command-' + ('a' * 64) + ' -->'
}

AfterAll {
    Remove-Module -Name DocsPageLinks, DocsPageMarkdown, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPageSlug' {
    It 'slugs <Text> as <Expected>' -ForEach @(
        @{ Text = 'Getting Started'; Expected = 'getting-started' }
        @{ Text = 'Use [the guide](guide.md) now'; Expected = 'use-the-guide-now' }
        @{ Text = 'Logo ![alt text](logo.png)'; Expected = 'logo-alt-text' }
        @{ Text = 'Tagged <code>x</code> heading'; Expected = 'tagged-x-heading' }
        @{ Text = 'Ünïcode Größe'; Expected = 'ünïcode-größe' }
        @{ Text = 'What? Why! (Really.)'; Expected = 'what-why-really' }
        @{ Text = 'snake_case name'; Expected = 'snake_case-name' }
        @{ Text = 'two  spaces'; Expected = 'two--spaces' }
        @{ Text = 'Command `docs check`'; Expected = 'command-docs-check' }
        @{ Text = 'v1.2 - notes'; Expected = 'v12---notes' }
    ) {
        # Act and Assert
        Get-DocsPageSlug -HeadingText $Text | Should -BeExactly $Expected
    }

    It 'keeps combining marks and drops symbols by code point' {
        # Arrange: e followed by U+0301 combining acute, a U+1F600 emoji outside the BMP
        $text = 'Caf' + 'e' + [char]0x0301 + ' ' + [char]::ConvertFromUtf32(0x1F600)

        # Act and Assert
        Get-DocsPageSlug -HeadingText $text | Should -BeExactly ('cafe' + [char]0x0301 + '-')
    }

    It 'returns the empty string for heading text with no kept character' {
        Get-DocsPageSlug -HeadingText '!!!' | Should -BeExactly ''
    }
}

Describe 'Get-DocsPageAnchor' {
    It 'de-duplicates heading slugs with -1, -2 and skips taken values' {
        # Arrange: the third heading's -1 suffix is already taken by the literal heading Intro 1
        $model = Get-TestModel -Line @('# Intro', '## Intro 1', '## Intro', '## Intro', 'Setext Intro', '============')

        # Act
        $anchors = Get-DocsPageAnchor -LineModel $model

        # Assert
        $anchors | Should -Be @('intro', 'intro-1', 'intro-2', 'intro-3', 'setext-intro')
    }

    It 'adds explicit a id and a name anchors outside masked regions' {
        # Arrange
        $model = Get-TestModel -Line @('<a id="first"></a>', 'text <A NAME=''second''>x</a>', '`<a id="code">`', '<!-- <a id="comment"> -->', '```', '<a id="fenced">', '```')

        # Act
        $anchors = Get-DocsPageAnchor -LineModel $model

        # Assert
        $anchors | Should -Be @('first', 'second')
    }

    It 'returns an empty list for a page without headings or anchors' {
        $anchors = Get-DocsPageAnchor -LineModel (Get-TestModel -Line @('plain text'))
        $anchors.Count | Should -Be 0
    }

    It 'returns unique anchors for a seeded heading list with the slug unchanged on recomputation' {
        # Arrange
        $seed = 20261030
        $random = [System.Random]::new($seed)
        $words = @('Alpha', 'Beta', 'beta', 'Gamma 1', 'Gamma', 'How', 'Ünit', '_x', 'a-b')
        for ($round = 0; $round -lt 25; $round++) {
            $lines = @(for ($n = 0; $n -lt $random.Next(1, 12); $n++) { '## ' + $words[$random.Next(0, $words.Count)] })
            $model = Get-TestModel -Line $lines

            # Act
            $first = Get-DocsPageAnchor -LineModel $model
            $second = Get-DocsPageAnchor -LineModel (Get-TestModel -Line $lines)

            # Assert (the seed is printed through -Because on failure)
            $first.Count | Should -Be $lines.Count -Because "seed $seed round $round"
            @($first | Select-Object -Unique).Count | Should -Be $first.Count -Because "seed $seed round $round"
            ($first -join '|') | Should -BeExactly ($second -join '|') -Because "seed $seed round $round"
            foreach ($line in $lines) { Get-DocsPageSlug -HeadingText $line.Substring(3) | Should -BeExactly (Get-DocsPageSlug -HeadingText $line.Substring(3)) -Because "seed $seed round $round" }
        }
    }
}

Describe 'Get-DocsPageLink' {
    It 'extracts inline, image and definition links with their lines' {
        # Arrange
        $model = Get-DocsPageLineModel -Line @('See [guide](guide.md "Title") and ![logo](<img/a b.png>).', '[ref]: <other.md#part>', '   [ref2]: ../up.md') -FirstLineNumber 5

        # Act
        $links = Get-DocsPageLink -LineModel $model

        # Assert
        @($links | ForEach-Object { "$($_.Line) $($_.Form) $($_.Target)" }) | Should -Be @('5 inline guide.md', '5 image img/a b.png', '6 definition other.md#part', '7 definition ../up.md')
    }

    It 'extracts an image nested in link text before the link' {
        $links = Get-DocsPageLink -LineModel (Get-TestModel -Line @('[![badge](badge.svg)](status.md)'))
        @($links | ForEach-Object { "$($_.Form) $($_.Target)" }) | Should -Be @('image badge.svg', 'inline status.md')
    }

    It 'keeps one level of parentheses in a destination' {
        $links = Get-DocsPageLink -LineModel (Get-TestModel -Line @('[x](page_(v2).md)'))
        $links[0].Target | Should -BeExactly 'page_(v2).md'
    }

    It 'produces no link from fences, comments, code spans and generated-block markers' {
        # Arrange
        $model = Get-TestModel -Line @($script:Marker, '<!-- [hidden](gone.md) -->', $script:EndMarker, '<!--', '# [x](in-comment.md)', '-->', '```', '[fenced](broken.md)', '# Heading', '1. step', '```', 'code `[x](span.md)` here')

        # Act
        $links = Get-DocsPageLink -LineModel $model

        # Assert
        $links.Count | Should -Be 0
    }
}

Describe 'Resolve-DocsPageLinkTarget' {
    It 'skips <Target>' -ForEach @(
        @{ Target = '' }
        @{ Target = 'https://example.com/a.md' }
        @{ Target = 'mailto:someone' }
        @{ Target = 'C:relative' }
        @{ Target = '//cdn.example.com/x.md' }
    ) {
        (Resolve-DocsPageLinkTarget -PagePath 'docs/a/page.md' -Target $Target).Skip | Should -BeTrue
    }

    It 'resolves <Target> from docs/a/page.md to <Path> with fragment <Fragment>' -ForEach @(
        @{ Target = 'other.md'; Path = 'docs/a/other.md'; Fragment = $null }
        @{ Target = './sub/x.md#Part-1'; Path = 'docs/a/sub/x.md'; Fragment = 'Part-1' }
        @{ Target = '../b/y.md?raw=1#z'; Path = 'docs/b/y.md'; Fragment = 'z' }
        @{ Target = '/README.md'; Path = 'README.md'; Fragment = $null }
        @{ Target = 'my%20page.md#caf%C3%A9'; Path = 'docs/a/my page.md'; Fragment = 'café' }
        @{ Target = '#local'; Path = 'docs/a/page.md'; Fragment = 'local' }
        @{ Target = 'dir/'; Path = 'docs/a/dir'; Fragment = $null }
        @{ Target = 'x.md#'; Path = 'docs/a/x.md'; Fragment = $null }
        @{ Target = 'a\b.md'; Path = 'docs/a/a\b.md'; Fragment = $null }
        @{ Target = '../..'; Path = ''; Fragment = $null }
    ) {
        # Act
        $resolved = Resolve-DocsPageLinkTarget -PagePath 'docs/a/page.md' -Target $Target

        # Assert
        $resolved.Skip | Should -BeFalse
        $resolved.EscapesRepository | Should -BeFalse
        $resolved.Path | Should -BeExactly $Path
        $resolved.Fragment | Should -Be $Fragment
    }

    It 'reports EscapesRepository for a target above the root' {
        $resolved = Resolve-DocsPageLinkTarget -PagePath 'docs/page.md' -Target '../../outside.md'
        $resolved.EscapesRepository | Should -BeTrue
        $resolved.Path | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsPageExternalTarget' {
    It 'returns sorted distinct paths that are neither pages nor page directories' {
        # Arrange
        $pages = [string[]] @('docs/README.md', 'docs/guide/index.md', 'docs/api/x.md')
        $map = @{
            'docs/README.md'      = Get-DocsPageLink -LineModel (Get-TestModel -Line @('[a](img.png) [b](guide/) [c](api) [d](https://x.y) [e](img.png) [f](../../up.md)'))
            'docs/guide/index.md' = Get-DocsPageLink -LineModel (Get-TestModel -Line @('[g](../data.json) [h](../README.md) [i](/) [j](#top)'))
        }

        # Act
        $external = Get-DocsPageExternalTarget -PageLink $map -PagePath $pages

        # Assert
        $external | Should -Be @('docs/data.json', 'docs/img.png')
    }
}

Describe 'Get-DocsPageLinkFinding' {
    It 'resolves pages, README and index directories, page-directory prefixes and existing paths with no finding' {
        # Arrange
        $page = @{
            'docs/README.md'       = @('[a](guide/) [b](api) [c](tree) [d](img.png) [e](README.md) [f](/docs/guide/index.md)')
            'docs/guide/index.md'  = @('# Guide')
            'docs/api/README.md'   = @('# API')
            'docs/tree/deep/x.md'  = @('# X')
        }

        # Act
        $result = Get-TestLinkFinding -PagePath 'docs/README.md' -Page $page -ExistingPath @('docs/img.png')

        # Assert
        $result.Findings.Count | Should -Be 0
        $result.Edges | Should -Be @('docs/api/README.md', 'docs/guide/index.md')
    }

    It 'reports DOCS_PAGE_LINK_BROKEN with the resolved path in related_paths' {
        # Act
        $result = Get-TestLinkFinding -PagePath 'docs/a.md' -Page @{ 'docs/a.md' = @('x', 'see [m](missing.md#x)') }

        # Assert
        $result.Findings.Count | Should -Be 1
        $finding = $result.Findings[0]
        $finding.code | Should -BeExactly 'DOCS_PAGE_LINK_BROKEN'
        $finding.artifact_path | Should -BeExactly 'docs/a.md'
        $finding.pointer | Should -BeExactly ''
        $finding.severity | Should -BeExactly 'error'
        $finding.related_paths | Should -Be @('docs/missing.md')
        $finding.message | Should -BeExactly "line 2: link target 'missing.md#x' does not resolve to a page or an existing path"
    }

    It 'reports DOCS_PAGE_LINK_ESCAPES_REPOSITORY for a target above the root' {
        $result = Get-TestLinkFinding -PagePath 'docs/a.md' -Page @{ 'docs/a.md' = @('[up](../../x.md)') }
        @($result.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_LINK_ESCAPES_REPOSITORY')
        @($result.Findings[0].related_paths).Count | Should -Be 0
        $result.Findings[0].pointer | Should -BeExactly ''
    }

    It 'reports DOCS_PAGE_ANCHOR_MISSING for a same-page fragment and accepts existing anchors and self-links' {
        # Arrange
        $page = @{ 'docs/a.md' = @('# Top', '<a id="explicit"></a>', '[ok](#top) [ok2](#explicit) [self](a.md#top) [bad](#nowhere) [selfbad](./a.md#gone)') }

        # Act
        $result = Get-TestLinkFinding -PagePath 'docs/a.md' -Page $page

        # Assert
        @($result.Findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_ANCHOR_MISSING', 'DOCS_PAGE_ANCHOR_MISSING')
        $result.Findings[0].message | Should -BeExactly "line 3: anchor '#nowhere' is not a heading or explicit anchor of this page"
        $result.Edges.Count | Should -Be 0
    }

    It 'reports DOCS_PAGE_LINK_ANCHOR_MISSING with the target page in related_paths' {
        # Arrange
        $page = @{ 'docs/a.md' = @('[x](b.md#install) [y](b.md#missing)'); 'docs/b.md' = @('## Install') }

        # Act
        $result = Get-TestLinkFinding -PagePath 'docs/a.md' -Page $page

        # Assert
        $result.Findings.Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_PAGE_LINK_ANCHOR_MISSING'
        $result.Findings[0].related_paths | Should -Be @('docs/b.md')
        $result.Findings[0].message | Should -BeExactly "line 1: anchor '#missing' is not a heading or explicit anchor of 'docs/b.md'"
        $result.Edges | Should -Be @('docs/b.md')
    }

    It 'does not check fragments on non-page targets or on pages without an anchor list' {
        # Arrange
        $links = Get-DocsPageLink -LineModel (Get-TestModel -Line @('[f](data.json#k) [g](b.md#k)'))

        # Act
        $result = Get-DocsPageLinkFinding -PagePath 'docs/a.md' -Link $links -PageAnchor @{} -PageSet @('docs/a.md', 'docs/b.md') -ExistingPath @('docs/data.json')

        # Assert
        $result.Findings.Count | Should -Be 0
    }

    It 'produces no finding for links and anchors inside fences, comments and code spans' {
        # Arrange
        $page = @{ 'docs/a.md' = @($script:Marker, '<!-- [x](gone.md) [y](#nowhere) # Heading -->', $script:EndMarker, '```', '[broken](broken.md)', '# Fenced heading', '1. step', '```', '`[c](span.md#no)`') }

        # Act
        $result = Get-TestLinkFinding -PagePath 'docs/a.md' -Page $page

        # Assert
        $result.Findings.Count | Should -Be 0
        $result.Edges.Count | Should -Be 0
    }
}
