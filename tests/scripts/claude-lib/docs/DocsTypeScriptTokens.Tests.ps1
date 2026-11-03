#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsTypeScriptTokens.psm1 (non-JSX lexical states).

.DESCRIPTION
    Covers token kinds, decoded values, Dynamic, Line, EndLine and Depth per lexical state:
    BOM and hashbang, comments, strings with escapes and line continuation, nested template
    substitutions, regular expression versus division by the previous significant token, numeric
    forms, private names, Unicode escapes, decorators, and the lexical-error and bound
    diagnostics. Fixtures are in-memory strings; no file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptTokens.psm1') -Force -ErrorAction Stop

    function Get-TestToken {
        param([string] $Text, [switch] $Jsx)
        $result = ConvertTo-DocsTypeScriptToken -Text $Text -Jsx:$Jsx
        $result['Diagnostics'].Count | Should -Be 0
        , [object[]] $result['Tokens']
    }

    function Get-TestKindText {
        param([object[]] $Token)
        @($Token | ForEach-Object { "$($_['Kind']):$($_['Text'])" })
    }
}

AfterAll {
    Remove-Module -Name DocsTypeScriptTokens, DocsTypeScriptJsx -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertTo-DocsTypeScriptToken' {
    Context 'whitespace, BOM, hashbang and comments' {
        It 'skips a leading BOM, a line-1 hashbang and comments while counting lines' {
            # Arrange
            $text = [string][char]0xFEFF + "#!/usr/bin/env node`n// comment`n/* block`n spans */ const x = 1;`n"

            # Act
            $tokens = Get-TestToken -Text $text

            # Assert
            Get-TestKindText -Token $tokens | Should -Be @('keyword:const', 'identifier:x', 'punct:=', 'number:1', 'punct:;')
            $tokens[0]['Line'] | Should -Be 4
            $tokens[0]['Start'] | Should -Be 50
        }

        It 'returns no token and no diagnostic for empty text' {
            # Act
            $result = ConvertTo-DocsTypeScriptToken -Text ''

            # Assert
            $result['Tokens'].Count | Should -Be 0
            $result['Diagnostics'].Count | Should -Be 0
        }

        It 'reports an unterminated block comment as TS_LEXICAL_INVALID' {
            $result = ConvertTo-DocsTypeScriptToken -Text "a /* never closed"
            $result['Tokens'].Count | Should -Be 0
            $result['Diagnostics'].Count | Should -Be 1
            $result['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
        }
    }

    Context 'strings' {
        It 'decodes escapes, quote escapes, hex, unicode and a line continuation' {
            # Arrange
            $text = "'a\'b\\n' + `"x\n\t\x41B\u{1F600}y`" + 'line\`ncontinued'"

            # Act
            $tokens = Get-TestToken -Text $text

            # Assert
            $tokens[0]['Kind'] | Should -BeExactly 'string'
            $tokens[0]['Value'] | Should -BeExactly "a'b\n"
            $tokens[2]['Value'] | Should -BeExactly ("x`n`tAB" + [System.Char]::ConvertFromUtf32(0x1F600) + 'y')
            $tokens[4]['Value'] | Should -BeExactly 'linecontinued'
            $tokens[4]['Line'] | Should -Be 1
            $tokens[4]['EndLine'] | Should -Be 2
        }

        It 'reports a raw newline in an ordinary string as one TS_LEXICAL_INVALID with the line' {
            # Act
            $result = ConvertTo-DocsTypeScriptToken -Text "const a = 1;`nconst s = 'broken`nstring';"

            # Assert
            $result['Tokens'].Count | Should -Be 0
            $result['Diagnostics'].Count | Should -Be 1
            $result['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
            $result['Diagnostics'][0]['Line'] | Should -Be 2
        }
    }

    Context 'template literals' {
        It 'gives a literal template its cooked value and no Dynamic flag' {
            # Act
            $tokens = Get-TestToken -Text 'x = `a\tb$c \${d}`'

            # Assert: a lone `$` and an escaped `\$` do not begin a substitution.
            $tokens[2]['Kind'] | Should -BeExactly 'template'
            $tokens[2]['Dynamic'] | Should -BeFalse
            $tokens[2]['Value'] | Should -BeExactly "a`tb`$c `${d}"
        }

        It 'tracks nested substitutions, braces and templates inside a template and marks it Dynamic' {
            # Arrange
            $text = 'const t = `outer ${ { a: `inner ${b}` }.a } tail`; next'

            # Act
            $tokens = Get-TestToken -Text $text

            # Assert
            Get-TestKindText -Token $tokens | Should -Be @('keyword:const', 'identifier:t', 'punct:=', 'template:`outer ${ { a: `inner ${b}` }.a } tail`', 'punct:;', 'identifier:next')
            $tokens[3]['Dynamic'] | Should -BeTrue
            $tokens[3]['Value'] | Should -BeNullOrEmpty
            $tokens[3]['Depth'] | Should -Be 0
            $tokens[5]['Depth'] | Should -Be 0
        }

        It 'counts lines across a multi-line template and reports an unterminated template' {
            # Act
            $tokens = Get-TestToken -Text ('`${a}' + "`n" + 'b' + "`n" + '${c}` d')
            $result = ConvertTo-DocsTypeScriptToken -Text '`open ${x}'

            # Assert
            $tokens[0]['Line'] | Should -Be 1
            $tokens[0]['EndLine'] | Should -Be 3
            $tokens[1]['Line'] | Should -Be 3
            $result['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
        }
    }

    Context 'regular expressions versus division' {
        It 'reads a regex after return, ( and = and a division after ) and an identifier' {
            # Arrange
            $text = "return /a[/]b\/c/gi; f(/x/); y = /z/; (a) / b / c; n / 2"

            # Act
            $tokens = Get-TestToken -Text $text

            # Assert
            $tokens[1]['Kind'] | Should -BeExactly 'regex'
            $tokens[1]['Text'] | Should -BeExactly '/a[/]b\/c/gi'
            $tokens[5]['Kind'] | Should -BeExactly 'regex'
            $tokens[10]['Kind'] | Should -BeExactly 'regex'
            @($tokens | Where-Object { $_['Kind'] -ceq 'punct' -and $_['Text'] -ceq '/' }).Count | Should -Be 3
        }

        It 'reports an unterminated regex as TS_LEXICAL_INVALID' {
            (ConvertTo-DocsTypeScriptToken -Text 'x = /abc')['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
        }
    }

    Context 'numbers, identifiers, keywords and punctuators' {
        It 'reads numeric forms with separators, hex, octal, binary, exponent and BigInt' {
            Get-TestKindText -Token (Get-TestToken -Text '1_000 0xFF_FFn 0o17 0b1010 .5e-3 42n 3.') | Should -Be @('number:1_000', 'number:0xFF_FFn', 'number:0o17', 'number:0b1010', 'number:.5e-3', 'number:42n', 'number:3.')
        }

        It 'reads private names, unicode escapes, decorators and contextual words as identifiers' {
            Get-TestKindText -Token (Get-TestToken -Text '@dec class A { #p = 1; abc; async of type }') | Should -Be @('punct:@', 'identifier:dec', 'keyword:class', 'identifier:A', 'punct:{', 'identifier:#p', 'punct:=', 'number:1', 'punct:;', 'identifier:abc', 'punct:;', 'identifier:async', 'identifier:of', 'identifier:type', 'punct:}')
        }

        It 'reads multi-character punctuators by longest match and never merges generic closers' {
            Get-TestKindText -Token (Get-TestToken -Text 'a ??= b?.c ... d => e === f >>> g <<= h') | Should -Be @('identifier:a', 'punct:??=', 'identifier:b', 'punct:?.', 'identifier:c', 'punct:...', 'identifier:d', 'punct:=>', 'identifier:e', 'punct:===', 'identifier:f', 'punct:>', 'punct:>', 'punct:>', 'identifier:g', 'punct:<<=', 'identifier:h')
        }

        It 'records the bracket depth at each token with openers and closers sharing a depth' {
            # Act
            $tokens = Get-TestToken -Text 'f(a, [b, {c}])'

            # Assert
            @($tokens | ForEach-Object { $_['Depth'] }) | Should -Be @(0, 0, 1, 1, 1, 2, 2, 2, 3, 2, 1, 0)
        }

        It 'reports an unexpected character as TS_LEXICAL_INVALID' {
            (ConvertTo-DocsTypeScriptToken -Text ('a ' + [char]0xA7 + ' b'))['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
        }
    }

    Context 'JSX (-Jsx)' {
        It 'reads an element with attribute strings, an expression child, text with an apostrophe, nested and self-closing tags' {
            # Arrange
            $text = 'const v = <div className="a b" data-x={1 + 2}>don' + "'" + 't <b>{x}</b> <br /></div>;'

            # Act
            $tokens = Get-TestToken -Text $text -Jsx

            # Assert
            Get-TestKindText -Token $tokens | Should -Be @('keyword:const', 'identifier:v', 'punct:=', 'punct:<', 'identifier:div', 'identifier:className', 'punct:=', 'string:"a b"', 'identifier:data-x', 'punct:=', 'punct:{', 'number:1', 'punct:+', 'number:2', 'punct:}', 'punct:>', 'punct:<', 'identifier:b', 'punct:>', 'punct:{', 'identifier:x', 'punct:}', 'punct:</', 'identifier:b', 'punct:>', 'punct:<', 'identifier:br', 'punct:/>', 'punct:</', 'identifier:div', 'punct:>', 'punct:;')
            @($tokens | Where-Object { $_['Kind'] -ceq 'string' }).Count | Should -Be 1
            $tokens[7]['Value'] | Should -BeExactly 'a b'
            $tokens[31]['Depth'] | Should -Be 0
        }

        It 'tracks element depth, nested JSX inside an expression child, fragments and line numbers' {
            # Arrange
            $text = "const v = (`n  <>`n    {items.map(i => <li key={i}>{i}</li>)}`n  </>`n);"

            # Act
            $tokens = Get-TestToken -Text $text -Jsx

            # Assert
            $fragment = @($tokens | Where-Object { $_['Kind'] -ceq 'punct' -and $_['Text'] -ceq '<' })
            $fragment[0]['Line'] | Should -Be 2
            $fragment[0]['Depth'] | Should -Be 1
            $fragment[1]['Line'] | Should -Be 3
            $li = @($tokens | Where-Object { $_['Kind'] -ceq 'identifier' -and $_['Text'] -ceq 'li' })
            $li.Count | Should -Be 2
            $tokens[-1]['Text'] | Should -BeExactly ';'
            $tokens[-1]['Depth'] | Should -Be 0
            $tokens[-1]['Line'] | Should -Be 5
        }

        It 'treats a generic parameter list with a comma or extends as type parameters and a comparison as punctuation' {
            # Act
            $generic = Get-TestToken -Text 'const f = <T,>(x: T) => x; const g = <T extends U>(y: T) => y; const c = a < b' -Jsx

            # Assert
            @($generic | Where-Object { $_['Kind'] -ceq 'punct' -and $_['Text'] -ceq '<' }).Count | Should -Be 3
            @($generic | Where-Object { $_['Kind'] -ceq 'punct' -and $_['Text'] -ceq '</' }).Count | Should -Be 0
        }

        It 'does not enter the JSX state without -Jsx and reports an unterminated element with -Jsx' {
            (ConvertTo-DocsTypeScriptToken -Text 'const v = <div>text</div>;')['Diagnostics'].Count | Should -Be 1
            (ConvertTo-DocsTypeScriptToken -Text 'const v = <div>text' -Jsx)['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
            (ConvertTo-DocsTypeScriptToken -Text 'const v = <div className="open>' -Jsx)['Diagnostics'][0]['Code'] | Should -BeExactly 'TS_LEXICAL_INVALID'
            (ConvertTo-DocsTypeScriptToken -Text 'const v = <a><b><c/></b></a>' -Jsx -MaxDepth 1)['Diagnostics'][0]['Code'] | Should -BeExactly 'TOKEN_LIMIT'
        }
    }

    Context 'bounds' {
        It 'reports TOKEN_LIMIT for the token bound and names the depth bound for the depth bound' {
            # Act
            $tokenLimit = ConvertTo-DocsTypeScriptToken -Text 'a b c d' -MaxTokens 3
            $depthLimit = ConvertTo-DocsTypeScriptToken -Text 'f(((1)))' -MaxDepth 2

            # Assert
            $tokenLimit['Tokens'].Count | Should -Be 0
            $tokenLimit['Diagnostics'].Count | Should -Be 1
            $tokenLimit['Diagnostics'][0]['Code'] | Should -BeExactly 'TOKEN_LIMIT'
            $depthLimit['Tokens'].Count | Should -Be 0
            $depthLimit['Diagnostics'].Count | Should -Be 1
            $depthLimit['Diagnostics'][0]['Code'] | Should -BeExactly 'TOKEN_LIMIT'
            $depthLimit['Diagnostics'][0]['Message'] | Should -Match 'depth'
            $depthLimit['Diagnostics'][0]['Message'] | Should -Match '2'
        }

        It 'keeps a stream exactly at the bounds' {
            (ConvertTo-DocsTypeScriptToken -Text 'a b c' -MaxTokens 3)['Tokens'].Count | Should -Be 3
            (ConvertTo-DocsTypeScriptToken -Text 'f((1))' -MaxDepth 2)['Tokens'].Count | Should -Be 6
        }
    }
}
