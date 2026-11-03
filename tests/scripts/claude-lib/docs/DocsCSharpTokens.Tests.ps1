#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsCSharpTokens.psm1.

.DESCRIPTION
    Covers comments, directive lines and HasConditional, character literals, regular, verbatim,
    interpolated and raw strings with the u8 suffix, verbatim and escaped identifiers, contextual
    keywords, generic closers, depth, and the lexical-error and bound diagnostics. Fixtures are
    in-memory strings; no file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsCSharpTokens.psm1') -Force -ErrorAction Stop

    function Get-TestResult {
        param([string] $Text)
        $result = ConvertTo-DocsCSharpToken -Text $Text
        $result['Diagnostics'].Count | Should -Be 0
        $result
    }

    function Get-TestKindText {
        param([object[]] $Token)
        @($Token | ForEach-Object { "$($_['Kind']):$($_['Text'])" })
    }
}

AfterAll {
    Remove-Module -Name DocsCSharpTokens -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-DocsCSharpToken' {
    Context 'comments and directives' {
        It 'produces no token for //, /// and /* */ comments and keeps line numbers' {
            # Act
            $tokens = (Get-TestResult -Text "// a`n/// <summary>x</summary>`n/* b`n c */ int x;")['Tokens']

            # Assert
            Get-TestKindText -Token $tokens | Should -Be @('keyword:int', 'identifier:x', 'punct:;')
            $tokens[0]['Line'] | Should -Be 4
        }

        It 'produces no token for a directive line and sets HasConditional only for #if' {
            # Act
            $conditional = Get-TestResult -Text "#if DEBUG`nint a;`n#else`nint b;`n#endif`n  #region R`nint c;`n#endregion"
            $plain = Get-TestResult -Text "#nullable enable`nint a; // #if not a directive"

            # Assert
            $conditional['HasConditional'] | Should -BeTrue
            Get-TestKindText -Token $conditional['Tokens'] | Should -Be @('keyword:int', 'identifier:a', 'punct:;', 'keyword:int', 'identifier:b', 'punct:;', 'keyword:int', 'identifier:c', 'punct:;')
            $plain['HasConditional'] | Should -BeFalse
            $plain['Tokens'].Count | Should -Be 3
        }

        It 'reports an unterminated block comment' {
            (ConvertTo-DocsCSharpToken -Text 'x /* open')['Diagnostics'][0]['Code'] | Should -BeExactly 'CSHARP_LEXICAL_INVALID'
        }
    }

    Context 'character and string literals' {
        It 'decodes character literals and regular strings with escapes' {
            # Act
            $tokens = (Get-TestResult -Text "'a' '\n' '\x41' `"q\`"r\\t\u0041\U0001F600`"")['Tokens']

            # Assert
            @($tokens | ForEach-Object { $_['Kind'] }) | Should -Be @('string', 'string', 'string', 'string')
            $tokens[0]['Value'] | Should -BeExactly 'a'
            $tokens[1]['Value'] | Should -BeExactly "`n"
            $tokens[2]['Value'] | Should -BeExactly 'A'
            $tokens[3]['Value'] | Should -BeExactly ('q"r\tA' + [System.Char]::ConvertFromUtf32(0x1F600))
            $tokens[3]['Text'] | Should -BeExactly "`"q\`"r\\t\u0041\U0001F600`""
        }

        It 'decodes a verbatim string with doubled quotes across lines' {
            # Act
            $tokens = (Get-TestResult -Text "@`"C:\x `"`"q`"`"`nnext`" ;")['Tokens']

            # Assert
            $tokens[0]['Value'] | Should -BeExactly "C:\x `"q`"`nnext"
            $tokens[0]['Dynamic'] | Should -BeFalse
            $tokens[0]['EndLine'] | Should -Be 2
            $tokens[1]['Line'] | Should -Be 2
        }

        It 'decodes interpolated strings: {{ escapes, holes with nested strings mark Dynamic, verbatim forms' {
            # Act
            $tokens = (Get-TestResult -Text '$"a{{b}}" $"x{y:N2}z{(c ? "}" : ")")}" $@"p{{q}}" @$"r{s}""t"')['Tokens']

            # Assert
            $tokens[0]['Value'] | Should -BeExactly 'a{b}'
            $tokens[0]['Dynamic'] | Should -BeFalse
            $tokens[1]['Dynamic'] | Should -BeTrue
            $tokens[1]['Value'] | Should -BeNullOrEmpty
            $tokens[1]['Text'] | Should -BeExactly '$"x{y:N2}z{(c ? "}" : ")")}"'
            $tokens[2]['Value'] | Should -BeExactly 'p{q}'
            $tokens[3]['Dynamic'] | Should -BeTrue
            $tokens[3]['Text'] | Should -BeExactly '@$"r{s}""t"'
            $tokens.Count | Should -Be 4
        }

        It 'decodes raw strings by quote-run length and marks $$ raw strings by brace width' {
            # Act
            $tokens = (Get-TestResult -Text ('"""a "" b""" """"has """ inside"""" $$"""x {{y}} {z}""" $"""p{q}""" """' + "`n" + ' multi' + "`n" + ' """'))['Tokens']

            # Assert
            $tokens[0]['Value'] | Should -BeExactly 'a "" b'
            $tokens[1]['Value'] | Should -BeExactly 'has """ inside'
            $tokens[2]['Dynamic'] | Should -BeTrue
            $tokens[3]['Dynamic'] | Should -BeTrue
            $tokens[4]['Value'] | Should -BeNullOrEmpty
            $tokens[4]['Dynamic'] | Should -BeFalse
            $tokens[4]['EndLine'] | Should -Be 3
            $tokens.Count | Should -Be 5
        }

        It 'keeps the u8 suffix in the text and leaves the value unchanged' {
            # Act
            $tokens = (Get-TestResult -Text '"ab"u8 @"c"u8')['Tokens']

            # Assert
            $tokens[0]['Text'] | Should -BeExactly '"ab"u8'
            $tokens[0]['Value'] | Should -BeExactly 'ab'
            $tokens[1]['Text'] | Should -BeExactly '@"c"u8'
        }

        It 'reports an unterminated string, an unterminated raw string and an unterminated character literal' {
            (ConvertTo-DocsCSharpToken -Text "var s = `"open`nnext`";")['Diagnostics'][0]['Code'] | Should -BeExactly 'CSHARP_LEXICAL_INVALID'
            (ConvertTo-DocsCSharpToken -Text '"""never')['Diagnostics'][0]['Code'] | Should -BeExactly 'CSHARP_LEXICAL_INVALID'
            (ConvertTo-DocsCSharpToken -Text "'ab'")['Diagnostics'][0]['Code'] | Should -BeExactly 'CSHARP_LEXICAL_INVALID'
            (ConvertTo-DocsCSharpToken -Text '$"open {x')['Diagnostics'].Count | Should -Be 1
        }
    }

    Context 'identifiers, keywords, numbers and punctuators' {
        It 'reads verbatim and escaped identifiers with a decoded Value and the preserved Text' {
            # Act
            $tokens = (Get-TestResult -Text '@class \u0061bc record partial required file var async')['Tokens']

            # Assert
            Get-TestKindText -Token $tokens | Should -Be @('identifier:@class', 'identifier:\u0061bc', 'identifier:record', 'identifier:partial', 'identifier:required', 'identifier:file', 'identifier:var', 'identifier:async')
            $tokens[0]['Value'] | Should -BeExactly 'class'
            $tokens[1]['Value'] | Should -BeExactly 'abc'
        }

        It 'reads keywords and numbers with suffixes and separators' {
            Get-TestKindText -Token (Get-TestResult -Text 'public static int x = 1_000UL + 0xFF + 0b10 + 1.5e3f + .25m;')['Tokens'] | Should -Be @('keyword:public', 'keyword:static', 'keyword:int', 'identifier:x', 'punct:=', 'number:1_000UL', 'punct:+', 'number:0xFF', 'punct:+', 'number:0b10', 'punct:+', 'number:1.5e3f', 'punct:+', 'number:.25m', 'punct:;')
        }

        It 'reads punctuators by longest match and keeps generic closers as single tokens' {
            Get-TestKindText -Token (Get-TestResult -Text 'List<List<int>> a ??= b?.c; x => y; p->q; 1..2; a::b; i <<= 2')['Tokens'] | Should -Be @('identifier:List', 'punct:<', 'identifier:List', 'punct:<', 'keyword:int', 'punct:>', 'punct:>', 'identifier:a', 'punct:??=', 'identifier:b', 'punct:?.', 'identifier:c', 'punct:;', 'identifier:x', 'punct:=>', 'identifier:y', 'punct:;', 'identifier:p', 'punct:->', 'identifier:q', 'punct:;', 'number:1', 'punct:..', 'number:2', 'punct:;', 'identifier:a', 'punct:::', 'identifier:b', 'punct:;', 'identifier:i', 'punct:<<=', 'number:2')
        }

        It 'records bracket depth and reports an unexpected character' {
            @((Get-TestResult -Text 'f(a[b{c}])')['Tokens'] | ForEach-Object { $_['Depth'] }) | Should -Be @(0, 0, 1, 1, 2, 2, 3, 2, 1, 0)
            (ConvertTo-DocsCSharpToken -Text 'a ` b')['Diagnostics'][0]['Code'] | Should -BeExactly 'CSHARP_LEXICAL_INVALID'
        }
    }

    Context 'bounds' {
        It 'reports one TOKEN_LIMIT each for the token bound and the depth bound' {
            # Act
            $tokenLimit = ConvertTo-DocsCSharpToken -Text 'a b c d' -MaxTokens 3
            $depthLimit = ConvertTo-DocsCSharpToken -Text 'f(((1)))' -MaxDepth 2

            # Assert
            $tokenLimit['Tokens'].Count | Should -Be 0
            $tokenLimit['Diagnostics'].Count | Should -Be 1
            $tokenLimit['Diagnostics'][0]['Code'] | Should -BeExactly 'TOKEN_LIMIT'
            $depthLimit['Diagnostics'].Count | Should -Be 1
            $depthLimit['Diagnostics'][0]['Code'] | Should -BeExactly 'TOKEN_LIMIT'
            $depthLimit['Diagnostics'][0]['Message'] | Should -Match 'depth'
        }

        It 'returns no token and no diagnostic for empty text and keeps HasConditional false' {
            # Act
            $result = ConvertTo-DocsCSharpToken -Text ''

            # Assert
            $result['Tokens'].Count | Should -Be 0
            $result['Diagnostics'].Count | Should -Be 0
            $result['HasConditional'] | Should -BeFalse
        }
    }
}
