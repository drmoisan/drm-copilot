#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonTokens.psm1 (issue #1022).

.DESCRIPTION
    Covers every token class (raw strings with an escaped quote, triple-quoted strings across
    lines, nested f-string fields, keywords), every lexer diagnostic with its code, severity and
    blocking flag, the token limit (built in test code: 262,145 NAME tokens below 1,048,576
    bytes) and the span-reconstruction property. Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonTokens.psm1') -Force -ErrorAction Stop

    function Get-TestToken {
        param([string] $Text, [string] $Type)
        $result = Get-DocsPythonToken -Text $Text
        $result.Diagnostics.Count | Should -Be 0 -Because "the input '$Text' lexes cleanly"
        if ($Type) { return @($result.Tokens | Where-Object { $_['Type'] -ceq $Type }) }
        return @($result.Tokens | Where-Object { $_['Type'] -cne 'WHITESPACE' })
    }

    function Get-TestDiagnostic {
        param([string] $Text)
        $result = Get-DocsPythonToken -Text $Text
        $result.Diagnostics.Count | Should -Be 1 -Because "the input '$Text' yields one diagnostic"
        return $result.Diagnostics[0]
    }
}

AfterAll {
    Remove-Module -Name DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPythonToken token classes' {
    It 'classifies names, keywords, numbers, operators, comments, newlines and continuations' {
        # Arrange / Act
        $tokens = Get-TestToken -Text "def f(a, b=1):  # c`n    return a**2 \`n        + 0x1F`nDef = .5j"

        # Assert
        @($tokens | ForEach-Object { $_['Type'] }) | Should -Be @('NAME', 'NAME', 'OP', 'NAME', 'OP', 'NAME', 'OP', 'NUMBER', 'OP', 'OP', 'COMMENT', 'NEWLINE', 'NAME', 'NAME', 'OP', 'NUMBER', 'CONTINUATION', 'OP', 'NUMBER', 'NEWLINE', 'NAME', 'OP', 'NUMBER')
        $tokens[0]['IsKeyword'] | Should -BeTrue
        $tokens[1]['IsKeyword'] | Should -BeFalse
        $tokens[12]['Text'] | Should -BeExactly 'return'
        $tokens[12]['IsKeyword'] | Should -BeTrue
        $tokens[14]['Text'] | Should -BeExactly '**'
        $tokens[17]['Line'] | Should -Be 3
        $tokens[17]['Column'] | Should -Be 8
        $tokens[20]['Text'] | Should -BeExactly 'Def'
        $tokens[20]['IsKeyword'] | Should -BeFalse
        $tokens[22]['Text'] | Should -BeExactly '.5j'
        $tokens[10]['Text'] | Should -BeExactly '# c'
    }

    It 'records the bracket depth on brackets and newlines' {
        $tokens = Get-TestToken -Text "x = f(a,`n [1, {2: 3}])`ny"
        @($tokens | Where-Object { $_['Type'] -ceq 'OP' -and $_['Text'] -cin @('(', '[', '{', '}', ']', ')') } | ForEach-Object { $_['Depth'] }) | Should -Be @(1, 2, 3, 2, 1, 0)
        @($tokens | Where-Object { $_['Type'] -ceq 'NEWLINE' } | ForEach-Object { $_['Depth'] }) | Should -Be @(1, 0)
    }

    It 'classifies string prefixes, raw strings with an escaped quote, triple-quoted strings across lines and nested f-string fields: <Case>' -TestCases @(
        @{ Case = 'plain'; Text = "x = 'a'"; Prefix = ''; IsTriple = $false; HasEscape = $false; IsBytes = $false; IsFormat = $false; IsRaw = $false; EndLine = 1 }
        @{ Case = 'escaped'; Text = 'x = "a\"b"'; Prefix = ''; IsTriple = $false; HasEscape = $true; IsBytes = $false; IsFormat = $false; IsRaw = $false; EndLine = 1 }
        @{ Case = 'raw with escaped quote'; Text = "x = r'a\'b'"; Prefix = 'r'; IsTriple = $false; HasEscape = $true; IsBytes = $false; IsFormat = $false; IsRaw = $true; EndLine = 1 }
        @{ Case = 'bytes'; Text = "x = Rb'a'"; Prefix = 'Rb'; IsTriple = $false; HasEscape = $false; IsBytes = $true; IsFormat = $false; IsRaw = $true; EndLine = 1 }
        @{ Case = 'triple across lines'; Text = "x = '''a`nb'c'''`ny = 1"; Prefix = ''; IsTriple = $true; HasEscape = $false; IsBytes = $false; IsFormat = $false; IsRaw = $false; EndLine = 2 }
        @{ Case = 'f-string with nested fields'; Text = 'x = f"{a[''k'']} {b:{w}} {{literal}}"'; Prefix = 'f'; IsTriple = $false; HasEscape = $false; IsBytes = $false; IsFormat = $true; IsRaw = $false; EndLine = 1 }
        @{ Case = 'unicode prefix'; Text = "x = u'a'"; Prefix = 'u'; IsTriple = $false; HasEscape = $false; IsBytes = $false; IsFormat = $false; IsRaw = $false; EndLine = 1 }
    ) {
        $string = @(Get-TestToken -Text $Text -Type 'STRING')
        $string.Count | Should -Be 1
        $string[0]['Prefix'] | Should -BeExactly $Prefix
        $string[0]['IsTriple'] | Should -Be $IsTriple
        $string[0]['HasEscape'] | Should -Be $HasEscape
        $string[0]['IsBytes'] | Should -Be $IsBytes
        $string[0]['IsFormat'] | Should -Be $IsFormat
        $string[0]['IsRaw'] | Should -Be $IsRaw
        $string[0]['EndLine'] | Should -Be $EndLine
        $string[0]['Line'] | Should -Be 1
    }

    It 'keeps a string-looking prefix without a quote as a NAME and a comment-looking hash inside a string' {
        $tokens = Get-TestToken -Text "rb = 1; s = 'a # b'"
        $tokens[0]['Type'] | Should -BeExactly 'NAME'
        @($tokens | Where-Object { $_['Type'] -ceq 'COMMENT' }).Count | Should -Be 0
        @($tokens | Where-Object { $_['Type'] -ceq 'STRING' })[0]['Text'] | Should -BeExactly "'a # b'"
    }

    It 'lexes a 1,048,576-byte single comment line as one COMMENT token' {
        $text = '#' + ('x' * 1048575)
        $tokens = @(Get-TestToken -Text $text)
        $tokens.Count | Should -Be 1
        $tokens[0]['Type'] | Should -BeExactly 'COMMENT'
        $tokens[0]['Text'].Length | Should -Be 1048576
    }

    It 'normalizes CRLF, CR and a BOM before tokenizing' {
        $tokens = Get-TestToken -Text ([string][char]0xFEFF + "a`r`nb`rc")
        @($tokens | ForEach-Object { $_['Text'] }) | Should -Be @('a', "`n", 'b', "`n", 'c')
        @($tokens | ForEach-Object { $_['Line'] }) | Should -Be @(1, 1, 2, 2, 3)
    }

    It 'continues with the correct tokens and columns after a string token' {
        # Act
        $tokens = Get-TestToken -Text "a = 'b' + c`nd"

        # Assert
        @($tokens | ForEach-Object { $_['Text'] }) | Should -Be @('a', '=', "'b'", '+', 'c', "`n", 'd')
        @($tokens | ForEach-Object { $_['Column'] }) | Should -Be @(0, 2, 4, 8, 10, 11, 0)
        @($tokens | ForEach-Object { $_['Line'] }) | Should -Be @(1, 1, 1, 1, 1, 1, 2)
    }

    It 'passes the whole source to a .NET method only at the restart after a string token' {
        # Arrange: per-call cost grows with argument length on an AMSI-enabled host, so a per-token or
        # per-character call with the whole source makes tokenizing quadratic there. The syntax tree pins it.
        $modulePath = Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonTokens.psm1'
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($modulePath, [ref] $null, [ref] $null)

        # Act
        $calls = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                    @($node.Arguments | Where-Object {
                            $_ -is [System.Management.Automation.Language.VariableExpressionAst] -and
                            $_.VariablePath.UserPath -in @('source', 'Text')
                        }).Count -gt 0
                }, $true))

        # Assert
        $calls.Count | Should -Be 1
        $calls[0].Member.Value | Should -BeExactly 'Match'
    }

    It 'returns no token and no diagnostic for the empty text' {
        $result = Get-DocsPythonToken -Text ''
        $result.Tokens.Count | Should -Be 0
        $result.Diagnostics.Count | Should -Be 0
    }
}

Describe 'Get-DocsPythonToken diagnostics' {
    It 'reports <Code> as a blocking error for: <Case>' -TestCases @(
        @{ Case = 'a coding cookie naming latin-1 on line 2'; Text = "#!/usr/bin/env python`n# -*- coding: latin-1 -*-`nx = 1"; Code = 'PYTHON_ENCODING_UNSUPPORTED'; Line = 2 }
        @{ Case = 'an unterminated single-quoted string'; Text = "x = 'abc`ny = 1"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 1 }
        @{ Case = 'an unterminated triple-quoted string'; Text = "x = '''abc`ny = 1"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 1 }
        @{ Case = 'an unterminated raw string whose backslash protects the quote'; Text = "x = r'abc\'"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 1 }
        @{ Case = 'an unclosed bracket'; Text = "x = f(1,`n2"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 2 }
        @{ Case = 'a closing bracket without an opener'; Text = "x = 1)"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 1 }
        @{ Case = 'a backslash continuation at end of input'; Text = "x = 1 + \"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 1 }
        @{ Case = 'a dollar sign outside strings and comments'; Text = "x = `$y"; Code = 'PYTHON_LEXER_UNCLASSIFIED'; Line = 1 }
        @{ Case = 'a backtick'; Text = "x = ``y``"; Code = 'PYTHON_LEXER_UNCLASSIFIED'; Line = 1 }
        @{ Case = 'a question mark on line 3'; Text = "a = 1`nb = 2`nc = a ? b"; Code = 'PYTHON_LEXER_UNCLASSIFIED'; Line = 3 }
        @{ Case = 'bracket depth above 64'; Text = 'x = ' + ('(' * 65) + '1' + (')' * 65); Code = 'PYTHON_LEXER_UNCLASSIFIED'; Line = 1 }
        @{ Case = 'f-string fields nested more than two levels'; Text = 'x = f"{f"{f"{a}"}"}"'; Code = 'PYTHON_LEXER_UNCLASSIFIED'; Line = 1 }
    ) {
        $diagnostic = Get-TestDiagnostic -Text $Text
        $diagnostic['Code'] | Should -BeExactly $Code
        $diagnostic['Severity'] | Should -BeExactly 'error'
        $diagnostic['Blocking'] | Should -BeTrue
        $diagnostic['Line'] | Should -Be $Line
    }

    It 'accepts a utf-8 cookie in any spelling, bracket depth 64 and f-string fields nested two levels' {
        (Get-DocsPythonToken -Text "# coding=UTF_8`nx = 1").Diagnostics.Count | Should -Be 0
        (Get-DocsPythonToken -Text "# vim: set fileencoding=utf8 :`nx = 1").Diagnostics.Count | Should -Be 0
        (Get-DocsPythonToken -Text ('x = ' + ('(' * 64) + '1' + (')' * 64))).Diagnostics.Count | Should -Be 0
        (Get-DocsPythonToken -Text 'x = f"{f"{a}"}"').Diagnostics.Count | Should -Be 0
    }

    It 'reports PYTHON_LEXER_UNCLASSIFIED for a character reached by continuing from a name and from a string' {
        # Act
        $afterName = Get-TestDiagnostic -Text 'a ?'
        $afterString = Get-TestDiagnostic -Text "'a' ?"

        # Assert
        $afterName['Code'] | Should -BeExactly 'PYTHON_LEXER_UNCLASSIFIED'
        $afterString['Code'] | Should -BeExactly 'PYTHON_LEXER_UNCLASSIFIED'
    }

    It 'ignores a coding cookie on line 3 and a hash inside a string' {
        (Get-DocsPythonToken -Text "a = 1`nb = 2`n# coding: latin-1").Diagnostics.Count | Should -Be 0
        (Get-DocsPythonToken -Text "s = '# coding: latin-1'").Diagnostics.Count | Should -Be 0
    }

    It 'reports PYTHON_TOKEN_LIMIT above 262,144 tokens and accepts exactly 262,144 (built in test code, below 1,048,576 bytes)' {
        # Arrange: NAME tokens separated by one space; whitespace is not counted.
        $accepted = [string]::Join(' ', [System.Linq.Enumerable]::Repeat('a', 262144))
        $exceeded = $accepted + ' a'
        $exceeded.Length | Should -BeLessThan 1048576

        # Act
        $ok = Get-DocsPythonToken -Text $accepted
        $limit = Get-DocsPythonToken -Text $exceeded

        # Assert
        $ok.Diagnostics.Count | Should -Be 0
        @($ok.Tokens | Where-Object { $_['Type'] -ceq 'NAME' }).Count | Should -Be 262144
        $limit.Diagnostics.Count | Should -Be 1
        $limit.Diagnostics[0]['Code'] | Should -BeExactly 'PYTHON_TOKEN_LIMIT'
        $limit.Diagnostics[0]['Severity'] | Should -BeExactly 'error'
        $limit.Diagnostics[0]['Blocking'] | Should -BeTrue
    }
}

Describe 'Get-DocsPythonToken properties' {
    It 'property: Get-DocsPythonToken spans reconstruct the input text' {
        # Arrange
        $seed = 102210
        $random = [System.Random]::new($seed)
        $pieces = @('def', 'f', '(', ')', ':', ' ', "`n", '    ', '1.5', '0x1f', "'s'", '"q\"r"', "r'\\d'", 'f"{a}"', ('"""m' + "`n" + 'l"""'), "# c`n", '+=', '->', '@', '[', ']', '{', '}', ',', ([string][char]0xE6), 'b"x"', 'x_1', ('\' + "`n"))

        for ($iteration = 0; $iteration -lt 200; $iteration++) {
            $count = $random.Next(1, 25)
            $builder = [System.Text.StringBuilder]::new()
            $depth = 0
            for ($i = 0; $i -lt $count; $i++) {
                $piece = $pieces[$random.Next($pieces.Length)]
                if ($piece -in @(')', ']', '}')) { if ($depth -eq 0) { continue } $depth-- }
                if ($piece -in @('(', '[', '{')) { $depth++ }
                [void] $builder.Append($piece)
            }
            for ($i = 0; $i -lt $depth; $i++) { [void] $builder.Append(')') }
            $text = $builder.ToString()
            if ($text.EndsWith('\' + "`n")) { $text += 'z' }
            $because = "seed $seed, iteration $iteration"

            # Act
            $result = Get-DocsPythonToken -Text $text

            # Assert
            $result.Diagnostics.Count | Should -Be 0 -Because $because
            $expected = $text
            if ($expected.EndsWith("`n")) { $expected = $expected.Substring(0, $expected.Length - 1) }
            (-join @($result.Tokens | ForEach-Object { $_['Text'] })) | Should -BeExactly $expected -Because $because
            $line = 1
            foreach ($token in $result.Tokens) {
                $token['Line'] | Should -Be $line -Because "$because, token '$($token['Text'])'"
                foreach ($character in $token['Text'].ToCharArray()) { if ($character -eq "`n") { $line++ } }
            }
        }
    }
}
