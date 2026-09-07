#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Rule-by-rule coverage of the D2 Piece 1 and Piece 2 command scanner (issue #545).

.DESCRIPTION
    Drives .codex/hooks/hook-command-scanner.ps1 directly. Every case in this file is a
    pure string case: no temporary file, no child process, no live executable, no clock,
    and no disk read beyond dot-sourcing the file under test.

    The rule inventory asserted here is the one named by spec D2 Piece 1 and Piece 2 in
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md:
    every segment delimiter, quoted-span masking, the tokenizer property that acceptance
    case AT-10 depends on, all seven heredoc rules, the CommandWord determination, the
    IsWrapperLed / HasLiveSubstitution / Unbalanced flags, the three ordered ScanText
    clauses, and exact membership of the wrapper carve-out set.

    Command text is written in PowerShell single-quoted strings wherever possible, so a
    '$(' or a backtick in the fixture reaches the scanner literally rather than being
    consumed by PowerShell's own parser. Multi-line fixtures are composed with a -join on
    a newline for the same reason.
#>

Describe 'hook-command-scanner, Codex copy (issue #545 D2 Piece 1 and Piece 2)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks").Path
        . (Join-Path $script:HookRoot 'hook-command-scanner.ps1')

        function Get-SegmentList {
            <#
            .SYNOPSIS
                Scan one command text and return the segment records as a plain array.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $Text)
            return @(Read-CommandLineSegment -CommandText $Text)
        }
    }

    Context 'empty input' {
        It 'returns an empty array for null input' {
            (Get-SegmentList -Text $null).Count | Should -Be 0
        }

        It 'returns an empty array for empty input' {
            (Get-SegmentList -Text '').Count | Should -Be 0
        }

        It 'returns an empty array for whitespace-only input' {
            (Get-SegmentList -Text "   `t  ").Count | Should -Be 0
        }
    }

    Context 'segment delimiters' {
        It 'splits on a semicolon' {
            $segments = Get-SegmentList -Text 'git status; git log'
            $segments.Count | Should -Be 2
            $segments[0].RawText.Trim() | Should -Be 'git status'
            $segments[1].RawText.Trim() | Should -Be 'git log'
        }

        It 'splits on an ampersand' {
            $segments = Get-SegmentList -Text 'git status && git log'
            $segments.Count | Should -Be 2
            $segments[1].RawText.Trim() | Should -Be 'git log'
        }

        It 'splits on a pipe' {
            $segments = Get-SegmentList -Text 'npm --version | grep lint'
            $segments.Count | Should -Be 2
            $segments[1].RawText.Trim() | Should -Be 'grep lint'
        }

        It 'splits on a newline' {
            $segments = Get-SegmentList -Text (@('git status', 'git log') -join "`n")
            $segments.Count | Should -Be 2
            $segments[1].RawText.Trim() | Should -Be 'git log'
        }

        It 'treats the subshell opener and closer as delimiters' {
            $segments = Get-SegmentList -Text '(git add .)'
            $segments.Count | Should -Be 1
            $segments[0].RawText.Trim() | Should -Be 'git add .'
        }

        It 'treats the group opener and closer as delimiters' {
            $segments = Get-SegmentList -Text '{ git add . ; }'
            $segments.Count | Should -Be 1
            $segments[0].RawText.Trim() | Should -Be 'git add .'
        }

        It 'treats the substitution opener as a delimiter' {
            $segments = Get-SegmentList -Text 'echo $(git add .)'
            $segments.Count | Should -Be 2
            $segments[0].RawText.Trim() | Should -Be 'echo'
            $segments[1].RawText.Trim() | Should -Be 'git add .'
        }

        It 'treats the backtick as a delimiter' {
            $segments = Get-SegmentList -Text 'echo `git add .`'
            $segments.Count | Should -Be 2
            $segments[1].RawText.Trim() | Should -Be 'git add .'
        }
    }

    Context 'quoted-span masking' {
        It 'masks a single-quoted span' {
            $segments = Get-SegmentList -Text "git commit -m 'git add .'"
            $segments.Count | Should -Be 1
            $segments[0].RawText | Should -BeLike '*git add*'
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
        }

        It 'masks a double-quoted span' {
            $segments = Get-SegmentList -Text 'git commit -m "git add ."'
            $segments.Count | Should -Be 1
            $segments[0].RawText | Should -BeLike '*git add*'
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
        }

        It 'preserves nothing of the masked content, so mask length equals span length' {
            $segments = Get-SegmentList -Text 'echo "abc"'
            $segments[0].MaskedText | Should -Be 'echo      '
        }
    }

    Context 'tokenizer' {
        It 'yields one token per double-quoted span with the delimiting quotes removed' {
            $segments = Get-SegmentList -Text 'git commit -m "rm -rf temp"'
            $segments[0].Tokens.Count | Should -Be 4
            $segments[0].Tokens[3] | Should -Be 'rm -rf temp'
        }

        It 'produces no adjacent token pair equal to the recursive-remove literal' {
            # The tokenizer property acceptance case AT-10 depends on: a quoted commit
            # message can never present 'rm -rf' as two adjacent tokens, because the whole
            # quoted span collapses into one token.
            $segments = Get-SegmentList -Text 'git commit -m "rm -rf temp"'
            $tokens = $segments[0].Tokens
            $pairs = @(
                for ($i = 0; $i -lt $tokens.Count - 1; $i++) { "$($tokens[$i]) $($tokens[$i + 1])" }
            )
            $pairs | Should -Not -Contain 'rm -rf'
        }

        It 'keeps a quoted span attached to the token it sits in' {
            $segments = Get-SegmentList -Text 'git commit -m"one two"'
            $segments[0].Tokens.Count | Should -Be 3
            $segments[0].Tokens[2] | Should -Be '-mone two'
        }

        It 'emits an empty token for an empty quoted string' {
            $segments = Get-SegmentList -Text 'echo ""'
            $segments[0].Tokens.Count | Should -Be 2
            $segments[0].Tokens[1] | Should -Be ''
        }

        It 'collapses runs of whitespace between tokens' {
            $segments = Get-SegmentList -Text "git   add`t`t."
            $segments[0].Tokens.Count | Should -Be 3
            $segments[0].Tokens[1] | Should -Be 'add'
        }
    }

    Context 'heredoc rules' {
        It 'masks the body of a plain heredoc' {
            $text = @('cat <<EOF', 'git add .', 'EOF', 'git status') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments.Count | Should -Be 2
            $segments[0].RawText | Should -BeLike '*git add*'
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
            $segments[1].RawText.Trim() | Should -Be 'git status'
        }

        It 'masks the body of a tab-stripping heredoc whose terminator is tab-indented' {
            $text = @('cat <<-EOF', "`tgit add .", "`tEOF", 'git status') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments.Count | Should -Be 2
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
            $segments[1].RawText.Trim() | Should -Be 'git status'
        }

        It 'masks the body of a heredoc whose delimiter is quoted' {
            $text = @("cat <<'NOTE'", 'git add .', 'NOTE', 'git status') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments.Count | Should -Be 2
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
            $segments[1].RawText.Trim() | Should -Be 'git status'
        }

        It 'consumes multiple pending heredocs on one physical line in order' {
            $text = @('cat <<ALPHA <<BETA', 'git add .', 'ALPHA', 'git commit -a', 'BETA', 'git status') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments.Count | Should -Be 2
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
            $segments[0].MaskedText | Should -Not -BeLike '*git commit*'
            $segments[1].RawText.Trim() | Should -Be 'git status'
        }

        It 'masks an unterminated heredoc body to end of text and reports it unbalanced' {
            $text = @('cat <<EOF', 'git add .', 'still going') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments.Count | Should -Be 1
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
            $segments[0].MaskedText | Should -Not -BeLike '*still going*'
            $segments[0].Unbalanced | Should -BeTrue
        }

        It 'does not treat a three-angle here-string as a heredoc' {
            $text = @("cat <<<'git add .'", 'git status') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments.Count | Should -Be 2
            $segments[0].Unbalanced | Should -BeFalse
            $segments[0].MaskedText | Should -BeLike '*<<<*'
            $segments[0].MaskedText | Should -Not -BeLike '*git add*'
            $segments[1].RawText.Trim() | Should -Be 'git status'
        }

        It 'forces a raw scan when the heredoc delimiter is produced by expansion' {
            $text = @('cat <<$VAR', 'git add .', 'EOF') -join "`n"
            $segments = Get-SegmentList -Text $text
            $segments[0].Unbalanced | Should -BeTrue
            $segments[0].ScanText | Should -Be $segments[0].RawText
        }
    }

    Context 'CommandWord determination' {
        It 'returns the first token when there is no env-assignment prefix' {
            $segments = Get-SegmentList -Text 'git add .'
            $segments[0].CommandWord | Should -Be 'git'
        }

        It 'skips VAR=value env-assignment prefixes' {
            $segments = Get-SegmentList -Text 'FOO=bar BAZ=qux git add .'
            $segments[0].CommandWord | Should -Be 'git'
        }

        It 'returns the empty string when the segment carries only assignments' {
            $segments = Get-SegmentList -Text 'FOO=bar'
            $segments[0].CommandWord | Should -Be ''
        }
    }

    Context 'segment flags' {
        It 'sets IsWrapperLed for a wrapper-led segment' {
            $segments = Get-SegmentList -Text "bash -c 'git add .'"
            $segments[0].CommandWord | Should -Be 'bash'
            $segments[0].IsWrapperLed | Should -BeTrue
        }

        It 'clears IsWrapperLed for a non-wrapper segment' {
            $segments = Get-SegmentList -Text 'git add .'
            $segments[0].IsWrapperLed | Should -BeFalse
        }

        It 'sets HasLiveSubstitution for a dollar-paren inside a double-quoted span' {
            $segments = Get-SegmentList -Text 'echo "value $(date)"'
            $segments[0].HasLiveSubstitution | Should -BeTrue
        }

        It 'sets HasLiveSubstitution for a backtick inside a double-quoted span' {
            $segments = Get-SegmentList -Text 'echo "value `date`"'
            $segments[0].HasLiveSubstitution | Should -BeTrue
        }

        It 'clears HasLiveSubstitution for an inert double-quoted span' {
            $segments = Get-SegmentList -Text 'echo "value"'
            $segments[0].HasLiveSubstitution | Should -BeFalse
        }

        It 'sets Unbalanced for an unterminated quote span' {
            $segments = Get-SegmentList -Text 'git commit -m "unterminated'
            $segments[0].Unbalanced | Should -BeTrue
        }

        It 'clears Unbalanced for a balanced segment' {
            $segments = Get-SegmentList -Text 'git commit -m "balanced"'
            $segments[0].Unbalanced | Should -BeFalse
        }
    }

    Context 'ScanText clause order' {
        It 'clause 1 selects RawText for an unbalanced or live-substitution segment' {
            $unbalanced = (Get-SegmentList -Text 'git commit -m "unterminated')[0]
            $unbalanced.ScanText | Should -Be $unbalanced.RawText

            $live = (Get-SegmentList -Text 'echo "value $(date)"')[0]
            $live.ScanText | Should -Be $live.RawText
        }

        It 'clause 1 outranks clause 3, so a masked-eligible segment still scans raw' {
            $segment = (Get-SegmentList -Text 'echo "git add . $(date)"')[0]
            $segment.IsWrapperLed | Should -BeFalse
            $segment.ScanText | Should -BeLike '*git add*'
        }

        It 'clause 2 selects RawText for a wrapper-led segment' {
            $segment = (Get-SegmentList -Text "bash -c 'git add .'")[0]
            $segment.ScanText | Should -Be $segment.RawText
            $segment.ScanText | Should -BeLike '*git add*'
        }

        It 'clause 3 selects MaskedText for every other segment' {
            $segment = (Get-SegmentList -Text "git commit -m 'git add .'")[0]
            $segment.ScanText | Should -Be $segment.MaskedText
            $segment.ScanText | Should -Not -BeLike '*git add*'
        }
    }

    Context 'wrapper carve-out set' {
        It 'exposes exactly the fourteen members named by D2 Piece 2' {
            $expected = @(
                'bash', 'command', 'dash', 'env', 'eval', 'ksh', 'nohup',
                'powershell', 'pwsh', 'sh', 'time', 'timeout', 'xargs', 'zsh'
            )
            $actual = @(Get-CommandLineWrapperName) | Sort-Object
            $actual.Count | Should -Be 14
            ($actual -join ',') | Should -Be ($expected -join ',')
        }
    }
}
