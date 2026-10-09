#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Delimiter, TokenText, and heredoc-module coverage for hook-command-scanner.ps1 (issue #824, T-SCAN).

.DESCRIPTION
    Issue #824 adds two properties to every segment record Read-CommandLineSegment returns:
    Delimiter, the separator that ended the segment ('' at end of text), and TokenText, the
    segment text with heredoc bodies blanked and quoted spans intact. The two-character
    operators '&&' and '||' are consumed whole. The heredoc readers move to
    hook-command-heredoc.ps1, which the scanner dot-sources.

    Every row runs against the Claude and the Codex copy. Each case is a pure string case:
    no temporary file, no child process, no live executable, and no disk read beyond
    dot-sourcing the file under test. Fixtures are single-quoted so '$(' and backticks reach
    the scanner literally; multi-line fixtures are joined on a line feed.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
}

Describe 'hook-command-scanner delimiter capture, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot "$HookRoot/hook-command-scanner.ps1")

        function Get-SegmentDelimiterList {
            <# Return the Delimiter of each segment record, in source order. #>
            param([Parameter(Mandatory)][string] $CommandText)
            return @(@(Read-CommandLineSegment -CommandText $CommandText) | ForEach-Object { $_.Delimiter })
        }
    }

    It 'SC-01 records ; for the first segment and the empty string at end of text' -Tag 'Issue824' {
        $delimiters = Get-SegmentDelimiterList -CommandText 'a; b'

        $delimiters.Count | Should -Be 2
        $delimiters[0] | Should -Be ';'
        $delimiters[1] | Should -Be ''
    }

    It 'SC-02 consumes && whole, producing exactly two records' -Tag 'Issue824' {
        $segments = @(Read-CommandLineSegment -CommandText 'a && b')

        $segments.Count | Should -Be 2 -Because 'the second ampersand does not open a segment of its own'
        $segments[0].Delimiter | Should -Be '&&'
        $segments[1].Delimiter | Should -Be ''
    }

    It 'SC-03 consumes || whole' -Tag 'Issue824' {
        $delimiters = Get-SegmentDelimiterList -CommandText 'a || b'

        $delimiters.Count | Should -Be 2
        $delimiters[0] | Should -Be '||'
    }

    It 'SC-04 records a single pipe' -Tag 'Issue824' {
        (Get-SegmentDelimiterList -CommandText 'a | b')[0] | Should -Be '|'
    }

    It 'SC-05 records a single ampersand' -Tag 'Issue824' {
        (Get-SegmentDelimiterList -CommandText 'a & b')[0] | Should -Be '&'
    }

    It 'SC-06 records a line feed' -Tag 'Issue824' {
        (Get-SegmentDelimiterList -CommandText ("a`nb"))[0] | Should -Be "`n"
    }

    It 'SC-07 records the closing parenthesis for a subshell body' -Tag 'Issue824' {
        $segments = @(Read-CommandLineSegment -CommandText '(a)')

        $segments.Count | Should -Be 1
        $segments[0].RawText | Should -Be 'a'
        $segments[0].Delimiter | Should -Be ')'
    }

    It 'SC-08 records ; inside a brace group' -Tag 'Issue824' {
        $segments = @(Read-CommandLineSegment -CommandText '{ a; }')

        $segments.Count | Should -Be 1
        $segments[0].Delimiter | Should -Be ';'
    }

    It 'SC-09 records the substitution opener and its closing parenthesis' -Tag 'Issue824' {
        $delimiters = Get-SegmentDelimiterList -CommandText 'x $(a)'

        $delimiters.Count | Should -Be 2
        $delimiters[0] | Should -Be '$('
        $delimiters[1] | Should -Be ')'
    }

    It 'SC-10 records a backtick' -Tag 'Issue824' {
        $delimiters = Get-SegmentDelimiterList -CommandText 'x `a`'

        $delimiters.Count | Should -Be 2
        $delimiters[0] | Should -Be '`'
        $delimiters[1] | Should -Be '`'
    }

    It 'SC-11 records the empty string for a single segment' -Tag 'Issue824' {
        # The @() keeps a one-element result an array; a bare return would unroll it.
        $delimiters = @(Get-SegmentDelimiterList -CommandText 'a')

        $delimiters.Count | Should -Be 1
        $delimiters[0] | Should -Be ''
    }

    It 'SC-12 blanks a heredoc body in TokenText and keeps it in RawText' -Tag 'Issue824' {
        $command = @('cat <<''EOF''', 'body', 'EOF') -join "`n"

        $segments = @(Read-CommandLineSegment -CommandText $command)

        $segments.Count | Should -Be 1
        $segments[0].TokenText | Should -Not -Match 'body'
        $segments[0].RawText | Should -Match 'body'
    }

    It 'SC-13 resolves both heredoc readers from hook-command-heredoc.ps1 after dot-sourcing only the scanner' -Tag 'Issue824' {
        $header = Get-Command -Name 'Read-CommandLineHeredocHeader' -CommandType Function
        $body = Get-Command -Name 'Read-CommandLineHeredocBody' -CommandType Function

        Split-Path -Leaf $header.ScriptBlock.File | Should -Be 'hook-command-heredoc.ps1'
        Split-Path -Leaf $body.ScriptBlock.File | Should -Be 'hook-command-heredoc.ps1'
    }
}
