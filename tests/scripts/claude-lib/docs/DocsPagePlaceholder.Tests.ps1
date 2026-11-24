#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPagePlaceholder.psm1, the placeholder counter of the
    documentation library (issue #1219).

.DESCRIPTION
    Covers Measure-DocsPagePlaceholder over separators, line wraps, casing, the excluded regions
    (front matter, backtick and tilde fences, inline code spans, HTML comments), an unterminated
    front matter block and CRLF input; Get-DocsPlaceholderReport over the page filter, strict UTF-8
    decoding, totals and ordering; ConvertTo-DocsPlaceholderReportLine; and the export surface.
    Every page is an in-memory string or byte array read through an in-memory scriptblock; CRLF
    input is built in memory. No file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    $script:Module = Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPagePlaceholder.psm1') -Force -PassThru -ErrorAction Stop
    $script:Utf8 = [System.Text.UTF8Encoding]::new($false)

    function Get-TestReader {
        # Returns a ReadBytes scriptblock over an in-memory map of page path to text or bytes, recording each read path in Log.
        param([System.Collections.IDictionary] $Page, [System.Collections.Generic.List[string]] $Log)
        $encoding = $script:Utf8
        $pages = $Page
        $calls = $Log
        return {
            param([string] $Path)
            $calls.Add($Path)
            $value = $pages[$Path]
            if ($value -is [byte[]]) { return , $value }
            return , $encoding.GetBytes([string] $value)
        }.GetNewClosure()
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Measure-DocsPagePlaceholder' {
    It 'counts <Expected> for <Case>' -ForEach @(
        @{ Case = 'a page without the token'; Expected = 0; Text = "# Title`n`nNo marker on this page.`n" }
        @{ Case = 'one occurrence'; Expected = 1; Text = "# Title`n`nSME input required`n" }
        @{ Case = 'three occurrences'; Expected = 3; Text = "# Title`n`nSME input required`n`nSME input required here.`n`nAlso SME input required.`n" }
        @{ Case = 'two occurrences on one line'; Expected = 2; Text = "SME input required and SME input required`n" }
        @{ Case = 'words separated by one tab each'; Expected = 1; Text = "SME`tinput`trequired`n" }
        @{ Case = 'words separated by three and two spaces'; Expected = 1; Text = "SME   input  required`n" }
        @{ Case = 'a space-and-tab mix between words'; Expected = 1; Text = "SME `t input`t required`n" }
    ) {
        # Act
        $count = Measure-DocsPagePlaceholder -Text $Text -PagePath 'docs/page.md'

        # Assert
        $count | Should -BeOfType [long]
        $count | Should -Be $Expected
    }

    It 'counts a token wrapped across one line break' {
        # Act
        $count = Measure-DocsPagePlaceholder -Text "# Title`n`nAsk for SME input`n  required before release.`n" -PagePath 'docs/page.md'

        # Assert
        $count | Should -Be 1
    }

    It 'counts 0 for words separated by a blank line' {
        # Act
        $count = Measure-DocsPagePlaceholder -Text "Ask for SME input`n`nrequired before release.`n" -PagePath 'docs/page.md'

        # Assert
        $count | Should -Be 0
    }

    It 'counts 0 for <Case> casing' -ForEach @(
        @{ Case = 'sme input required (lowercase)'; Text = "sme input required`n" }
        @{ Case = 'SME Input Required (title case)'; Text = "SME Input Required`n" }
    ) {
        Measure-DocsPagePlaceholder -Text $Text -PagePath 'docs/page.md' | Should -Be 0
    }

    It 'counts 0 inside <Region>' -ForEach @(
        @{ Region = 'front matter'; Text = "---`ntitle: SME input required`n---`n# Body`n" }
        @{ Region = 'a backtick fence'; Text = "# Body`n`n``````text`nSME input required`n```````n" }
        @{ Region = 'a tilde fence'; Text = "# Body`n`n~~~`nSME input required`n~~~`n" }
        @{ Region = 'an inline code span'; Text = "Write ``SME input required`` to mark a section.`n" }
        @{ Region = 'an HTML comment'; Text = "<!-- SME input required -->`nBody text.`n" }
    ) {
        Measure-DocsPagePlaceholder -Text $Text -PagePath 'docs/page.md' | Should -Be 0
    }

    It 'counts an unterminated front matter page' {
        # Act: without a closing line the whole page is the body.
        $count = Measure-DocsPagePlaceholder -Text "---`ntitle: draft`nSME input required`n" -PagePath 'docs/page.md'

        # Assert
        $count | Should -Be 1
    }

    It 'counts the body after a terminated front matter block' {
        # Act
        $count = Measure-DocsPagePlaceholder -Text "---`ntitle: draft`n---`nSME input required`n" -PagePath 'docs/page.md'
        $empty = Measure-DocsPagePlaceholder -Text "---`ntitle: SME input required`n---" -PagePath 'docs/page.md'

        # Assert
        $count | Should -Be 1
        $empty | Should -Be 0
    }

    It 'gives the same count for CRLF and LF' {
        # Arrange: the CRLF form is built in memory because committed fixtures are normalized to LF.
        $lf = "---`ntitle: draft`n---`n# Body`n`nSME input`nrequired`n`nSME input required`n"
        $crlf = $lf.Replace("`n", "`r`n")

        # Act
        $lfCount = Measure-DocsPagePlaceholder -Text $lf -PagePath 'docs/page.md'
        $crlfCount = Measure-DocsPagePlaceholder -Text $crlf -PagePath 'docs/page.md'

        # Assert
        $crlf.Contains("`r`n") | Should -BeTrue
        $lfCount | Should -Be 2
        $crlfCount | Should -Be $lfCount
    }
}

Describe 'Get-DocsPlaceholderReport' {
    It 'skips a non-Markdown page' {
        # Arrange
        $log = [System.Collections.Generic.List[string]]::new()
        $reader = Get-TestReader -Page @{ 'docs/notes.txt' = 'SME input required'; 'docs/page.md' = "SME input required`n" } -Log $log

        # Act
        $report = Get-DocsPlaceholderReport -PagePath @('docs/notes.txt', 'docs/page.md') -ReadBytes $reader

        # Assert
        $report['total'] | Should -Be 1
        @($report['pages']).Count | Should -Be 1
        $report['pages'][0]['page_path'] | Should -BeExactly 'docs/page.md'
        @($log) | Should -Be @('docs/page.md')
    }

    It 'skips a page that is not valid UTF-8' {
        # Arrange: 0xC3 0x28 is an invalid two-byte sequence.
        $log = [System.Collections.Generic.List[string]]::new()
        $bad = [byte[]] @(0x53, 0x4D, 0x45, 0x20, 0xC3, 0x28)
        $reader = Get-TestReader -Page @{ 'docs/bad.md' = $bad; 'docs/good.md' = "SME input required`n" } -Log $log

        # Act
        $report = Get-DocsPlaceholderReport -PagePath @('docs/bad.md', 'docs/good.md') -ReadBytes $reader

        # Assert
        @($log) | Should -Be @('docs/bad.md', 'docs/good.md')
        $report['total'] | Should -Be 1
        @($report['pages'] | ForEach-Object { $_['page_path'] }) | Should -Be @('docs/good.md')
    }

    It 'sums total and omits zero-count pages' {
        # Arrange
        $log = [System.Collections.Generic.List[string]]::new()
        $reader = Get-TestReader -Page @{ 'docs/a.md' = "SME input required`n"; 'docs/b.md' = "# None`n"; 'docs/c.md' = "SME input required`nSME input`nrequired`n" } -Log $log

        # Act
        $report = Get-DocsPlaceholderReport -PagePath @('docs/a.md', 'docs/b.md', 'docs/c.md') -ReadBytes $reader

        # Assert
        @($report.Keys) | Should -Be @('token', 'total', 'pages')
        $report['token'] | Should -BeExactly 'SME input required'
        $report['total'] | Should -Be 3
        @($report['pages'] | ForEach-Object { $_['page_path'] }) | Should -Be @('docs/a.md', 'docs/c.md')
        @($report['pages'] | ForEach-Object { $_['count'] }) | Should -Be @(1, 2)
        @($report['pages'][0].Keys) | Should -Be @('page_path', 'count')
    }

    It 'returns a zero total and no pages for an empty page set' {
        # Act
        $report = Get-DocsPlaceholderReport -PagePath @() -ReadBytes { param([string] $Path) throw "unexpected read of $Path" }

        # Assert
        $report['total'] | Should -Be 0
        @($report['pages']).Count | Should -Be 0
    }

    It 'orders pages ordinally by page_path' {
        # Arrange
        $log = [System.Collections.Generic.List[string]]::new()
        $page = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
        foreach ($path in 'docs/b.md', 'docs/B.md', 'docs/a.md') { $page[$path] = 'SME input required' }
        $reader = Get-TestReader -Page $page -Log $log

        # Act
        $report = Get-DocsPlaceholderReport -PagePath @('docs/b.md', 'docs/a.md', 'docs/B.md') -ReadBytes $reader

        # Assert
        @($report['pages'] | ForEach-Object { $_['page_path'] }) | Should -Be @('docs/B.md', 'docs/a.md', 'docs/b.md')
    }
}

Describe 'ConvertTo-DocsPlaceholderReportLine' {
    It 'renders the summary line and one line per page' {
        # Arrange
        $report = [ordered]@{
            token = 'SME input required'
            total = [long] 3
            pages = @([ordered]@{ page_path = 'docs/guides/Alpha.md'; count = [long] 1 }, [ordered]@{ page_path = 'docs/guides/Setup.md'; count = [long] 2 })
        }

        # Act
        $lines = ConvertTo-DocsPlaceholderReportLine -Report $report
        $emptyLines = ConvertTo-DocsPlaceholderReportLine -Report ([ordered]@{ token = 'SME input required'; total = [long] 0; pages = @() })

        # Assert
        $lines | Should -Be @('placeholders: token="SME input required" total=3 pages=2', 'placeholder docs/guides/Alpha.md count=1', 'placeholder docs/guides/Setup.md count=2')
        @($emptyLines) | Should -Be @('placeholders: token="SME input required" total=0 pages=0')
    }
}

Describe 'DocsPagePlaceholder module surface' {
    It 'returns the token literal' {
        Get-DocsPlaceholderToken | Should -BeExactly 'SME input required'
    }

    It 'exports exactly Get-DocsPlaceholderToken, Measure-DocsPagePlaceholder, Get-DocsPlaceholderReport and ConvertTo-DocsPlaceholderReportLine' {
        # Act
        $exported = @($script:Module.ExportedFunctions.Keys | Sort-Object)

        # Assert
        $exported | Should -Be @('ConvertTo-DocsPlaceholderReportLine', 'Get-DocsPlaceholderReport', 'Get-DocsPlaceholderToken', 'Measure-DocsPagePlaceholder')
    }
}
