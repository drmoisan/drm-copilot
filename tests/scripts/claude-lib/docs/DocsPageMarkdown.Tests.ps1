#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageMarkdown.psm1.

.DESCRIPTION
    Covers line splitting (CRLF, CR and BOM inputs built in memory), the fence rule (length,
    character, info string, indentation, unclosed fence), HTML-comment masking across lines and
    to the page end, code-span masking, ATX and setext headings and generated-block start-marker
    detection. Every input is an in-memory string; no file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageMarkdown.psm1') -Force -ErrorAction Stop

    function Get-TestModel {
        param([string[]] $Line)
        Get-DocsPageLineModel -Line $Line
    }

    $script:Marker = '<!-- docs:generated:start id=cli-command-' + ('a' * 64) + ' -->'
    $script:EndMarker = '<!-- docs:generated:end id=cli-command-' + ('a' * 64) + ' -->'
}

AfterAll {
    Remove-Module -Name DocsPageMarkdown -Force -ErrorAction SilentlyContinue
}

Describe 'Split-DocsPageLine' {
    It 'splits CRLF, LF and CR line endings' {
        # Act
        $lines = Split-DocsPageLine -Text "a`r`nb`nc`rd"

        # Assert
        $lines | Should -Be @('a', 'b', 'c', 'd')
    }

    It 'removes one leading byte order mark' {
        # Act
        $lines = Split-DocsPageLine -Text ([string][char]0xFEFF + "# T`nx")

        # Assert
        $lines[0] | Should -BeExactly '# T'
        $lines.Count | Should -Be 2
    }

    It 'returns one empty line for empty text and keeps a trailing empty line' {
        (Split-DocsPageLine -Text '').Count | Should -Be 1
        (Split-DocsPageLine -Text "a`n").Count | Should -Be 2
    }
}

Describe 'Get-DocsPageFenceLine and Test-DocsPageFenceClose' {
    It 'recognizes <Line> as a fence of <Character> x <Length> with info <Info>' -ForEach @(
        @{ Line = '```'; Character = '`'; Length = 3; Info = '' }
        @{ Line = '~~~~ powershell'; Character = '~'; Length = 4; Info = 'powershell' }
        @{ Line = '   ```json'; Character = '`'; Length = 3; Info = 'json' }
    ) {
        # Act
        $fence = Get-DocsPageFenceLine -Line $Line

        # Assert
        $fence.FenceCharacter | Should -BeExactly $Character
        $fence.FenceLength | Should -Be $Length
        $fence.Info | Should -BeExactly $Info
    }

    It 'returns $null for <Line>' -ForEach @(
        @{ Line = '``' }
        @{ Line = '    ```' }
        @{ Line = '``` a`b' }
        @{ Line = 'text' }
    ) {
        Get-DocsPageFenceLine -Line $Line | Should -BeNullOrEmpty
    }

    It 'closes only with the same character, at least the same length and no info string' {
        # Arrange
        $open = Get-DocsPageFenceLine -Line '````'

        # Assert
        Test-DocsPageFenceClose -Fence (Get-DocsPageFenceLine -Line '`````') -OpenFence $open | Should -BeTrue
        Test-DocsPageFenceClose -Fence (Get-DocsPageFenceLine -Line '```') -OpenFence $open | Should -BeFalse
        Test-DocsPageFenceClose -Fence (Get-DocsPageFenceLine -Line '~~~~') -OpenFence $open | Should -BeFalse
        Test-DocsPageFenceClose -Fence (Get-DocsPageFenceLine -Line '```` sh') -OpenFence $open | Should -BeFalse
    }
}

Describe 'Get-DocsPageLineModel' {
    Context 'fences' {
        It 'marks open, body and close lines and leaves Masked empty' {
            # Act
            $model = Get-TestModel -Line @('```', '[x](missing.md)', '~~~', '```', 'after')

            # Assert
            @($model | ForEach-Object { $_.Kind }) | Should -Be @('fence-open', 'fence-body', 'fence-body', 'fence-close', 'text')
            @($model[0..3] | Where-Object { $_.Masked -ne '' }).Count | Should -Be 0
        }

        It 'runs an unclosed fence to the end of the page' {
            # Act
            $model = Get-TestModel -Line @('~~~', '# heading', '1. step')

            # Assert
            $model[1].Kind | Should -BeExactly 'fence-body'
            $model[2].Kind | Should -BeExactly 'fence-body'
        }
    }

    Context 'comments and code spans' {
        It 'masks a comment across lines and scans text after it' {
            # Act
            $model = Get-TestModel -Line @('<!-- start', '[x](a.md)', 'end --> [y](b.md)')

            # Assert
            $model[0].Kind | Should -BeExactly 'comment'
            $model[1].Kind | Should -BeExactly 'comment'
            $model[1].Masked | Should -BeExactly ''
            $model[2].Kind | Should -BeExactly 'text'
            $model[2].Masked | Should -Not -Match 'end'
            $model[2].Masked | Should -Match '\[y\]\(b\.md\)'
        }

        It 'runs an unclosed comment to the end of the page' {
            # Act
            $model = Get-TestModel -Line @('text <!-- open', '# not a heading', '```')

            # Assert
            $model[0].Kind | Should -BeExactly 'text'
            $model[1].Kind | Should -BeExactly 'comment'
            $model[2].Kind | Should -BeExactly 'comment'
        }

        It 'masks code-span contents in Masked and keeps them in CommentMasked' {
            # Act
            $model = Get-TestModel -Line @('see `[x](y.md)` and ``a ` b``')

            # Assert
            $model[0].Masked | Should -Not -Match '\[x\]'
            $model[0].Masked.Length | Should -Be $model[0].Text.Length
            $model[0].CommentMasked | Should -Match '\[x\]\(y\.md\)'
        }

        It 'treats an unmatched backtick run as literal text' {
            (Get-TestModel -Line @('a ` [x](y.md)'))[0].Masked | Should -Match '\[x\]\(y\.md\)'
        }
    }

    Context 'headings' {
        It 'reads ATX heading <Line> as level <Level> with text <Expected>' -ForEach @(
            @{ Line = '# Title'; Level = 1; Expected = 'Title' }
            @{ Line = '### Title ###'; Level = 3; Expected = 'Title' }
            @{ Line = '  ## Use `x` here'; Level = 2; Expected = 'Use `x` here' }
            @{ Line = '#'; Level = 1; Expected = '' }
            @{ Line = '# ##'; Level = 1; Expected = '' }
        ) {
            # Act
            $record = (Get-TestModel -Line @($Line))[0]

            # Assert
            $record.Kind | Should -BeExactly 'heading'
            $record.HeadingLevel | Should -Be $Level
            $record.HeadingText | Should -BeExactly $Expected
        }

        It 'does not read <Line> as a heading' -ForEach @(
            @{ Line = '#hashtag' }
            @{ Line = '####### seven' }
            @{ Line = '    # indented' }
        ) {
            (Get-TestModel -Line @($Line))[0].Kind | Should -BeExactly 'text'
        }

        It 'promotes the text line above a setext underline' {
            # Act
            $model = Get-TestModel -Line @('Title', '=====', '', 'Sub', '---', '', '---')

            # Assert
            $model[0].Kind | Should -BeExactly 'heading'
            $model[0].HeadingLevel | Should -Be 1
            $model[0].HeadingText | Should -BeExactly 'Title'
            $model[1].Kind | Should -BeExactly 'setext-underline'
            $model[3].HeadingLevel | Should -Be 2
            $model[6].Kind | Should -BeExactly 'text'
        }

        It 'keeps page line numbers from FirstLineNumber' {
            # Act
            $model = Get-DocsPageLineModel -Line @('a', 'b') -FirstLineNumber 5

            # Assert
            $model[0].Number | Should -Be 5
            $model[1].Number | Should -Be 6
        }

        It 'returns an empty model for an empty line list' {
            # Act (the function returns its array as one object, so assign it directly)
            $model = Get-DocsPageLineModel -Line @()

            # Assert
            $model.Count | Should -Be 0
        }

        It 'marks whitespace-only lines blank' {
            (Get-TestModel -Line @('   '))[0].Kind | Should -BeExactly 'blank'
        }
    }

    Context 'generated-block markers' {
        It 'sets HasGeneratedStartMarker for a start marker line only' {
            # Act
            $model = Get-TestModel -Line @($script:Marker, 'body', $script:EndMarker, '```', $script:Marker, '```')

            # Assert
            $model[0].HasGeneratedStartMarker | Should -BeTrue
            $model[0].Kind | Should -BeExactly 'comment'
            $model[2].HasGeneratedStartMarker | Should -BeFalse
            $model[4].HasGeneratedStartMarker | Should -BeFalse
        }

        It 'masks markers, other comments and fences on one page so no region keeps link, heading or list text' {
            # Arrange
            $page = @(
                '# Real'
                $script:Marker
                '<!-- [broken](gone.md) ## Heading-shaped -->'
                $script:EndMarker
                '```'
                '[broken](gone.md)'
                '## Fenced heading'
                '1. fenced step'
                '```'
            )

            # Act
            $model = Get-TestModel -Line $page

            # Assert
            @($model[1..8] | ForEach-Object { $_.Kind }) | Should -Be @('comment', 'comment', 'comment', 'fence-open', 'fence-body', 'fence-body', 'fence-body', 'fence-close')
            @($model[1..8] | Where-Object { $_.Masked -ne '' }).Count | Should -Be 0
            @($model | Where-Object { $_.Kind -eq 'heading' }).Count | Should -Be 1
        }
    }
}
