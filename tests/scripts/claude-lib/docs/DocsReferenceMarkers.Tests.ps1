#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Example tests for DocsReferenceMarkers.psm1.

.DESCRIPTION
    Pins the marker line grammar, each marker and fence finding with its page line number, the
    fence-aware skipping of marker-like lines, and merge steps 2 to 5 with the blank-line layout
    of inserted blocks. Every input is an in-memory string array.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferenceMarkers.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsSurface.psm1') -Force -ErrorAction Stop

    $script:IdA = Get-DocsElementId -Kind 'cli-command' -Path 'src/a.py' -Declaration 'tool a'
    $script:IdB = Get-DocsElementId -Kind 'cli-command' -Path 'src/b.py' -Declaration 'tool b'
    $script:IdC = Get-DocsElementId -Kind 'cli-command' -Path 'src/c.py' -Declaration 'tool c'

    function Get-TestStart { param([string] $Id) return "<!-- docs:generated:start id=$Id -->" }
    function Get-TestEnd { param([string] $Id) return "<!-- docs:generated:end id=$Id -->" }

    function Get-TestBlock {
        # Returns the lines of one block as the generator writes it: start, blank, body, blank, end.
        param([string] $Id, [string[]] $Body = @('## Command `x`'))
        return [string[]] (@(Get-TestStart -Id $Id) + @('') + $Body + @('') + @(Get-TestEnd -Id $Id))
    }

    function Get-TestDesired {
        param([string] $Id, [string[]] $Body = @('## Command `x`'))
        return @{ ElementId = $Id; Line = $Body }
    }

    function Get-TestCode {
        param([AllowEmptyCollection()] [object[]] $Finding)
        return [string[]]@($Finding | ForEach-Object { [string] $_['code'] })
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReferenceMarkerLine' {
    It 'returns the exact start and end marker lines' {
        Get-DocsReferenceMarkerLine -ElementId $script:IdA -Position 'start' | Should -BeExactly (Get-TestStart -Id $script:IdA)
        Get-DocsReferenceMarkerLine -ElementId $script:IdA -Position 'end' | Should -BeExactly (Get-TestEnd -Id $script:IdA)
    }

    It 'throws for an identifier outside the element-id grammar' {
        { Get-DocsReferenceMarkerLine -ElementId 'cli-command-xyz' -Position 'start' } | Should -Throw '*not an element identifier*'
    }

    It 'rejects a position in another case' {
        { Get-DocsReferenceMarkerLine -ElementId $script:IdA -Position 'Start' } | Should -Throw
    }
}

Describe 'ConvertFrom-DocsReferenceMarkerLine' {
    It 'returns null for a line that is not marker-like' {
        ConvertFrom-DocsReferenceMarkerLine -Line '<!-- other comment -->' | Should -BeNullOrEmpty
    }

    It 'parses a start marker' {
        # Act
        $marker = ConvertFrom-DocsReferenceMarkerLine -Line (Get-TestStart -Id $script:IdA)

        # Assert
        $marker.Position | Should -BeExactly 'start'
        $marker.ElementId | Should -BeExactly $script:IdA
        $marker.Malformed | Should -BeFalse
    }

    It 'reports <Case> as malformed' -ForEach @(
        @{ Case = 'an indented marker'; Prefix = '  '; Suffix = '' }
        @{ Case = 'a marker with trailing text'; Prefix = ''; Suffix = ' extra' }
    ) {
        # Act
        $marker = ConvertFrom-DocsReferenceMarkerLine -Line ($Prefix + (Get-TestStart -Id $script:IdA) + $Suffix)

        # Assert
        $marker.Malformed | Should -BeTrue
        $marker.Position | Should -BeExactly 'start'
    }
}

Describe 'ConvertFrom-DocsReferenceBody' {
    It 'splits prose and block segments that reconstruct the input' {
        # Arrange
        $lines = [string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA) + @('', 'outro'))

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 0

        # Assert
        $result.Finding.Count | Should -Be 0
        @($result.Segment | ForEach-Object { $_.Kind }) | Should -Be @('prose', 'block', 'prose')
        $result.Segment[1].ElementId | Should -BeExactly $script:IdA
        $result.Segment[1].Start | Should -Be 2
        $result.Segment[1].End | Should -Be 6
        $result.Segment[1].Line | Should -Be @('', '## Command `x`', '')
        $result.Segment[2].Start | Should -Be 7
    }

    It 'reports REFERENCE_MARKER_MALFORMED for <Case> with the page line number including the offset' -ForEach @(
        @{ Case = 'indentation'; Text = ' <!-- docs:generated:start id=IDA -->' }
        @{ Case = 'trailing text'; Text = '<!-- docs:generated:end id=IDA --> tail' }
        @{ Case = 'an identifier outside the grammar'; Text = '<!-- docs:generated:start id=cli-command-123 -->' }
    ) {
        # Arrange
        $lines = [string[]]@('prose', $Text.Replace('IDA', $script:IdA))

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 6

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_MARKER_MALFORMED')
        $result.Finding[0]['severity'] | Should -BeExactly 'error'
        $result.Finding[0]['message'] | Should -Match '^line 8: '
        $result.Finding[0]['artifact_path'] | Should -BeExactly 'docs/reference/cli-reference.md'
    }

    It 'reports REFERENCE_MARKER_DUPLICATE for a repeated block identifier' {
        # Arrange
        $lines = [string[]] ((Get-TestBlock -Id $script:IdA) + @('') + (Get-TestBlock -Id $script:IdA))

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 0

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_MARKER_DUPLICATE')
        $result.Finding[0]['message'] | Should -Match '^line 7: '
        $result.Finding[0]['related_ids'] | Should -Be @($script:IdA)
    }

    It 'reports REFERENCE_MARKER_UNBALANCED for <Case>' -ForEach @(
        @{ Case = 'an end marker without an open block'; Shape = 'end-only'; LineNumber = 2 }
        @{ Case = 'a start marker while a block is open'; Shape = 'nested'; LineNumber = 3 }
        @{ Case = 'a start marker never closed'; Shape = 'unclosed'; LineNumber = 2 }
    ) {
        # Arrange
        $lines = switch ($Shape) {
            'end-only' { [string[]]@('prose', (Get-TestEnd -Id $script:IdA)) }
            'nested' { [string[]]@((Get-TestStart -Id $script:IdA), '', (Get-TestStart -Id $script:IdB), '', (Get-TestEnd -Id $script:IdA)) }
            default { [string[]]@('prose', (Get-TestStart -Id $script:IdA), 'body') }
        }

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 0

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_MARKER_UNBALANCED')
        $result.Finding[0]['message'] | Should -Match "^line ${LineNumber}: "
    }

    It 'reports REFERENCE_MARKER_MISMATCH for an end marker naming another block' {
        # Arrange
        $lines = [string[]]@((Get-TestStart -Id $script:IdA), '', (Get-TestEnd -Id $script:IdB))

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 0

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_MARKER_MISMATCH')
        $result.Finding[0]['message'] | Should -Match '^line 3: '
    }

    It 'reports REFERENCE_FENCE_UNCLOSED with the line of the opening fence' {
        # Act
        $result = ConvertFrom-DocsReferenceBody -Line ([string[]]@('prose', '~~~~text', 'code', '~~~')) -PagePath 'docs/reference/cli-reference.md' -LineOffset 4

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_FENCE_UNCLOSED')
        $result.Finding[0]['message'] | Should -Match '^line 6: '
    }

    It 'ignores marker-like lines inside a <Case> fence' -ForEach @(
        @{ Case = 'backtick'; Fence = '```' }
        @{ Case = 'tilde'; Fence = '~~~~' }
    ) {
        # Arrange
        $lines = [string[]]@('prose', ($Fence + 'text'), (Get-TestStart -Id $script:IdA), '<!-- docs:generated:end id=broken -->', $Fence, 'after')

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 0

        # Assert
        $result.Finding.Count | Should -Be 0
        @($result.Segment | ForEach-Object { $_.Kind }) | Should -Be @('prose')
    }

    It 'does not interpret fence lines inside an open generated block' {
        # Arrange
        $lines = [string[]]@((Get-TestStart -Id $script:IdA), '```', (Get-TestEnd -Id $script:IdA), 'after')

        # Act
        $result = ConvertFrom-DocsReferenceBody -Line $lines -PagePath 'docs/reference/cli-reference.md' -LineOffset 0

        # Assert
        $result.Finding.Count | Should -Be 0
        @($result.Segment | ForEach-Object { $_.Kind }) | Should -Be @('block', 'prose')
    }
}

Describe 'Merge-DocsReferenceBlock' {
    It 'updates a changed block in place and keeps an equal block unchanged' {
        # Arrange
        $lines = [string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA -Body @('old')) + @('', 'middle', '') + (Get-TestBlock -Id $script:IdB -Body @('same')) + @('', 'outro'))
        $desired = @((Get-TestDesired -Id $script:IdA -Body @('new', 'lines')), (Get-TestDesired -Id $script:IdB -Body @('same')))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired $desired -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be ([string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA -Body @('new', 'lines')) + @('', 'middle', '') + (Get-TestBlock -Id $script:IdB -Body @('same')) + @('', 'outro')))
        $result.Updated | Should -Be @($script:IdA)
        $result.Unchanged | Should -Be @($script:IdB)
        $result.Added.Count | Should -Be 0
        $result.Removed.Count | Should -Be 0
        $result.Edit.Count | Should -Be 1
        $result.Edit[0].BeforeStart | Should -Be 3
        $result.Edit[0].BeforeCount | Should -Be 3
        $result.Edit[0].AfterStart | Should -Be 3
        $result.Edit[0].AfterCount | Should -Be 4
    }

    It 'removes an undesired block with its following blank line and reports REFERENCE_BLOCK_REMOVED' {
        # Arrange
        $lines = [string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA) + @('', 'outro'))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired @() -PagePath 'docs/reference/cli-reference.md' -LineOffset 5

        # Assert
        $result.Line | Should -Be @('intro', '', 'outro')
        $result.Removed | Should -Be @($script:IdA)
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_BLOCK_REMOVED')
        $result.Finding[0]['severity'] | Should -BeExactly 'info'
        $result.Finding[0]['related_ids'] | Should -Be @($script:IdA)
        $result.Finding[0]['message'] | Should -Match '^line 8: '
    }

    It 'keeps the following line when the line before a removed block is not blank' {
        # Arrange
        $lines = [string[]] (@('intro') + (Get-TestBlock -Id $script:IdA) + @('', 'outro'))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired @() -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be @('intro', '', 'outro')
    }

    It 'removes a block that starts the body together with its following blank line' {
        # Arrange
        $lines = [string[]] ((Get-TestBlock -Id $script:IdA) + @('', 'outro'))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired @() -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be @('outro')
    }

    It 'inserts a new block after the end marker of the nearest preceding present member as blank line plus block' {
        # Arrange
        $lines = [string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA) + @('', 'outro'))
        $desired = @((Get-TestDesired -Id $script:IdA), (Get-TestDesired -Id $script:IdB -Body @('b')))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired $desired -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be ([string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA) + @('') + (Get-TestBlock -Id $script:IdB -Body @('b')) + @('', 'outro')))
        $result.Added | Should -Be @($script:IdB)
    }

    It 'inserts a new block before the start marker of the nearest following present member as block plus blank line' {
        # Arrange
        $lines = [string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdB) + @('', 'outro'))
        $desired = @((Get-TestDesired -Id $script:IdA -Body @('a')), (Get-TestDesired -Id $script:IdB))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired $desired -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be ([string[]] (@('intro', '') + (Get-TestBlock -Id $script:IdA -Body @('a')) + @('') + (Get-TestBlock -Id $script:IdB) + @('', 'outro')))
    }

    It 'appends new blocks at the end after removing trailing blank lines, separated by one blank line' {
        # Arrange
        $lines = [string[]]@('# Title', '', 'prose', '', '')
        $desired = @((Get-TestDesired -Id $script:IdA -Body @('a')), (Get-TestDesired -Id $script:IdB -Body @('b')))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired $desired -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be ([string[]] (@('# Title', '', 'prose', '') + (Get-TestBlock -Id $script:IdA -Body @('a')) + @('') + (Get-TestBlock -Id $script:IdB -Body @('b'))))
        $result.Added | Should -Be (@($script:IdA, $script:IdB) | Sort-Object -CaseSensitive)
    }

    It 'appends a block to an empty body without a leading blank line' {
        # Act
        $result = Merge-DocsReferenceBlock -Line @() -Desired @(Get-TestDesired -Id $script:IdC -Body @('c')) -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be (Get-TestBlock -Id $script:IdC -Body @('c'))
        $result.Edit.Count | Should -Be 1
        $result.Edit[0].BeforeCount | Should -Be 0
        $result.Edit[0].AfterCount | Should -Be 5
    }

    It 'keeps existing block order and removes only trailing blank lines' {
        # Arrange
        $lines = [string[]] ((Get-TestBlock -Id $script:IdB) + @('') + (Get-TestBlock -Id $script:IdA) + @('', ''))
        $desired = @((Get-TestDesired -Id $script:IdA), (Get-TestDesired -Id $script:IdB))

        # Act
        $result = Merge-DocsReferenceBlock -Line $lines -Desired $desired -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -Be ([string[]] ((Get-TestBlock -Id $script:IdB) + @('') + (Get-TestBlock -Id $script:IdA)))
        $result.Unchanged | Should -Be (@($script:IdA, $script:IdB) | Sort-Object -CaseSensitive)
        $result.Edit.Count | Should -Be 1
        $result.Edit[0].BeforeStart | Should -Be 11
        $result.Edit[0].BeforeCount | Should -Be 2
        $result.Edit[0].AfterCount | Should -Be 0
    }

    It 'returns no lines and the parse findings for a malformed body' {
        # Act
        $result = Merge-DocsReferenceBlock -Line ([string[]]@((Get-TestStart -Id $script:IdA))) -Desired @() -PagePath 'docs/reference/cli-reference.md'

        # Assert
        $result.Line | Should -BeNullOrEmpty
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_MARKER_UNBALANCED')
        $result.Edit.Count | Should -Be 0
    }

    It 'throws when a desired identifier is listed twice' {
        { Merge-DocsReferenceBlock -Line @() -Desired @((Get-TestDesired -Id $script:IdA), (Get-TestDesired -Id $script:IdA)) -PagePath 'docs/reference/cli-reference.md' } | Should -Throw '*listed twice*'
    }
}
