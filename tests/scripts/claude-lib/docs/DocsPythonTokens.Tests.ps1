#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonTokens.psm1 (issue #1022).

.DESCRIPTION
    Covers every token class (raw strings with an escaped quote, triple-quoted strings across
    lines, nested f-string fields, keywords), every lexer diagnostic with its code, severity and
    blocking flag, the token limit (built in test code: 262,145 NAME tokens below 1,048,576
    bytes) and the span-reconstruction property. Inputs are in-memory strings. The structural
    scaling guard reads the module syntax tree to pin the bounded lexing window and its Match
    argument, and the window-boundary cases cover tokens and diagnostics across window ends.
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

Describe 'Get-DocsPythonToken structural scaling guard' {
    BeforeAll {
        $script:GuardModulePath = Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonTokens.psm1'
        $parseErrors = $null
        $script:GuardAst = [System.Management.Automation.Language.Parser]::ParseFile($script:GuardModulePath, [ref] $null, [ref] $parseErrors)
        $script:GuardParseErrorCount = @($parseErrors).Count
    }

    It 'passes no source text variable to a .NET method inside a loop' {
        # Arrange: per-call cost grows with argument length, so the syntax tree pins the argument shape rather than a time.
        $script:GuardParseErrorCount | Should -Be 0

        # Act
        $loopCalls = @($script:GuardAst.FindAll({
                    param($node)
                    if ($node -isnot [System.Management.Automation.Language.InvokeMemberExpressionAst]) { return $false }
                    for ($ancestor = $node.Parent; $null -ne $ancestor; $ancestor = $ancestor.Parent) {
                        if ($ancestor -is [System.Management.Automation.Language.LoopStatementAst]) { return $true }
                    }
                    return $false
                }, $true))
        $offending = @($loopCalls | Where-Object {
                @($_.Arguments | Where-Object {
                        $_ -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        $_.VariablePath.UserPath -in @('sourceText', 'Text')
                    }).Count -gt 0
            })

        # Assert
        $loopCalls.Count | Should -BeGreaterThan 0 -Because 'the guard must inspect at least one loop member call'
        @($offending | ForEach-Object { $_.Extent.Text }) | Should -BeNullOrEmpty -Because 'a call in a loop must not receive the source text as an argument'
    }

    It 'assigns the lexing window only from a Substring of the source text' {
        # Arrange
        $script:GuardParseErrorCount | Should -Be 0
        $function = $script:GuardAst.Find({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Get-DocsPythonToken'
            }, $true)
        $function | Should -Not -BeNullOrEmpty

        # Act
        $assignments = @($function.FindAll({
                    param($node)
                    if ($node -isnot [System.Management.Automation.Language.AssignmentStatementAst]) { return $false }
                    # A cast on the left side, stacked or not, must not hide the assignment from the rule below.
                    $left = $node.Left
                    while ($left -is [System.Management.Automation.Language.AttributedExpressionAst]) { $left = $left.Child }
                    return $left -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $left.VariablePath.UserPath -eq 'source'
                }, $true))
        $offending = @($assignments | Where-Object {
                $right = $_.Right
                if ($right -is [System.Management.Automation.Language.PipelineAst]) { $right = $right.GetPureExpression() }
                if ($right -is [System.Management.Automation.Language.CommandExpressionAst]) { $right = $right.Expression }
                if (-not ($right -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                        $right.Member.Value -ceq 'Substring' -and
                        $right.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        $right.Expression.VariablePath.UserPath -eq 'sourceText')) { return $true }
                # The bound: exactly two arguments, the second [math]::Min($windowSize, ...), so the window never grows unbounded.
                $arguments = @($right.Arguments | Where-Object { $null -ne $_ })
                if ($arguments.Count -ne 2) { return $true }
                $length = $arguments[1]
                $bounded = $length -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                $length.Member.Value -ceq 'Min' -and
                $length.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                $length.Expression.TypeName.Name -eq 'math' -and
                @($length.Arguments | Where-Object { $null -ne $_ }).Count -gt 0 -and
                $length.Arguments[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $length.Arguments[0].VariablePath.UserPath -ceq 'windowSize'
                return -not $bounded
            })

        # Assert
        $assignments.Count | Should -BeGreaterThan 0 -Because 'the function must assign the lexing window'
        @($offending | ForEach-Object { $_.Extent.Text }) | Should -BeNullOrEmpty -Because 'the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...)'
    }

    It 'passes only the lexing window to Match inside the token loop' {
        # Arrange
        $script:GuardParseErrorCount | Should -Be 0
        $function = $script:GuardAst.Find({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Get-DocsPythonToken'
            }, $true)
        $function | Should -Not -BeNullOrEmpty
        $loops = @($function.Body.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.WhileStatementAst] -and
                    $node.Parent -is [System.Management.Automation.Language.NamedBlockAst] -and
                    $node.Parent.Parent -eq $function.Body
                }, $false))
        $loops.Count | Should -Be 1 -Because 'the token loop is the single while statement in the function body'

        # Act
        $matchCalls = @($loops[0].FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $node.Member.Value -ceq 'Match'
                }, $true))
        $offending = @($matchCalls | Where-Object {
                $first = @($_.Arguments | Where-Object { $null -ne $_ }) | Select-Object -First 1
                -not ($first -is [System.Management.Automation.Language.VariableExpressionAst] -and $first.VariablePath.UserPath -ceq 'source')
            })

        # Assert
        $matchCalls.Count | Should -BeGreaterThan 0 -Because 'the token loop must call Match'
        @($offending | ForEach-Object { $_.Extent.Text }) | Should -BeNullOrEmpty -Because 'Match inside the token loop must receive the bounded window $source as its first argument'
    }
}

Describe 'Get-DocsPythonToken window boundaries' {
    BeforeAll {
        function Get-TestPaddedInput {
            # Builds whitespace at exactly $Offset characters, as 40-character lines plus a remainder, so the piece
            # never follows a token at offset zero. The suffix keeps the first window from being the final one.
            param([string] $Piece, [int] $Offset)
            $lineCount = [math]::Floor($Offset / 41)
            $padding = (((' ' * 40) + "`n") * $lineCount) + (' ' * ($Offset - ($lineCount * 41)))
            return @{
                Text   = $padding + $Piece + "`n" + (' ' * 1200) + 'z'
                Line   = $lineCount + 1
                Column = $Offset - ($lineCount * 41)
            }
        }
    }

    It 'keeps the token at each padded offset across the window end: <Case>' -TestCases @(
        @{ Case = 'hex number'; Piece = '0x1F'; Type = 'NUMBER' }
        @{ Case = 'negative exponent'; Piece = '1e-5'; Type = 'NUMBER' }
        @{ Case = 'float with positive exponent'; Piece = '1.5e+3'; Type = 'NUMBER' }
        @{ Case = 'three-character operator'; Piece = '**='; Type = 'OP' }
        @{ Case = 'ellipsis'; Piece = '...'; Type = 'OP' }
        @{ Case = 'triple-quoted string'; Piece = "'''a'''"; Type = 'STRING' }
        @{ Case = 'raw bytes string'; Piece = "rb'x'"; Type = 'STRING' }
        @{ Case = 'f-string'; Piece = 'f"{a}"'; Type = 'STRING' }
        @{ Case = 'comment'; Piece = '# c'; Type = 'COMMENT' }
        @{ Case = 'backslash continuation'; Piece = "\`n"; Type = 'CONTINUATION' }
        @{ Case = '40-character name'; Piece = 'n' * 40; Type = 'NAME' }
        @{ Case = 'long number with exponent'; Piece = '123456789012e-5'; Type = 'NUMBER' }
    ) {
        foreach ($offset in 1010..1026) {
            # Arrange
            $sample = Get-TestPaddedInput -Piece $Piece -Offset $offset
            $because = "piece '$Case' at offset $offset"
            $pieceNewlines = $Piece.Split("`n").Count - 1

            # Act
            $result = Get-DocsPythonToken -Text $sample['Text']

            # Assert
            $result.Diagnostics.Count | Should -Be 0 -Because $because
            $significant = @($result.Tokens | Where-Object { $_['Type'] -cne 'WHITESPACE' -and $_['Type'] -cne 'NEWLINE' })
            $significant.Count | Should -Be 2 -Because $because
            $significant[0]['Type'] | Should -BeExactly $Type -Because $because
            $significant[0]['Text'] | Should -BeExactly $Piece -Because $because
            $significant[0]['Column'] | Should -Be $sample['Column'] -Because $because
            $significant[0]['Line'] | Should -Be $sample['Line'] -Because $because
            $significant[1]['Text'] | Should -BeExactly 'z' -Because $because
            $significant[1]['Line'] | Should -Be ($sample['Line'] + $pieceNewlines + 1) -Because $because
            $significant[1]['Column'] | Should -Be 1200 -Because $because
        }
    }

    It 'property: long inputs reconstruct their spans and lines' {
        # Arrange
        $seed = 101910
        $random = [System.Random]::new($seed)
        $pieces = @('def', 'f', '(', ')', ':', ' ', "`n", '    ', '1.5', '0x1f', "'s'", '"q\"r"', "r'\\d'", 'f"{a}"', ('"""m' + "`n" + 'l"""'), "# c`n", '+=', '->', '@', '[', ']', '{', '}', ',', ([string][char]0xE6), 'b"x"', 'x_1', ('\' + "`n"))

        for ($iteration = 0; $iteration -lt 20; $iteration++) {
            $builder = [System.Text.StringBuilder]::new()
            $depth = 0
            while ($builder.Length -lt 3000) {
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
            $wrongLines = [System.Collections.Generic.List[string]]::new()
            foreach ($token in $result.Tokens) {
                if ($token['Line'] -ne $line) { $wrongLines.Add("token '$($token['Text'])' at line $($token['Line']), expected $line") }
                foreach ($character in $token['Text'].ToCharArray()) { if ($character -eq "`n") { $line++ } }
            }
            @($wrongLines) | Should -BeNullOrEmpty -Because $because
        }
    }

    It 'keeps the following token correct when a string ends at the window end' {
        foreach ($closingOffset in 1015, 1016, 1023, 1024) {
            # Arrange: the closing quote sits at the stated offset, and the suffix keeps later windows in play.
            $body = 's' * ($closingOffset - 5)
            $string = "'" + $body + "'"
            $sample = "a = $string + w`n" + (' ' * 1200) + 'z'
            $because = "closing quote at offset $closingOffset"

            # Act
            $tokens = @(Get-TestToken -Text $sample)

            # Assert
            @($tokens | ForEach-Object { $_['Type'] }) | Should -Be @('NAME', 'OP', 'STRING', 'OP', 'NAME', 'NEWLINE', 'NAME') -Because $because
            $tokens[2]['Text'] | Should -BeExactly $string -Because $because
            $tokens[2]['Column'] | Should -Be 4 -Because $because
            $tokens[3]['Column'] | Should -Be ($closingOffset + 2) -Because $because
            $tokens[4]['Text'] | Should -BeExactly 'w' -Because $because
            $tokens[4]['Column'] | Should -Be ($closingOffset + 4) -Because $because
            $tokens[4]['Line'] | Should -Be 1 -Because $because
            $tokens[6]['Text'] | Should -BeExactly 'z' -Because $because
            $tokens[6]['Line'] | Should -Be 2 -Because $because
            $tokens[6]['Column'] | Should -Be 1200 -Because $because
        }
    }

    It 'keeps Line, Column and EndLine after a triple-quoted string longer than one window' {
        # Arrange
        $string = "'''" + ("line`n" * 500) + "'''"
        $sample = "x = $string + w`ny = 1"

        # Act
        $tokens = @(Get-TestToken -Text $sample)

        # Assert
        $tokens[2]['Type'] | Should -BeExactly 'STRING'
        $tokens[2]['Text'] | Should -BeExactly $string
        $tokens[2]['Line'] | Should -Be 1
        $tokens[2]['Column'] | Should -Be 4
        $tokens[2]['EndLine'] | Should -Be 501
        $tokens[3]['Line'] | Should -Be 501
        $tokens[3]['Column'] | Should -Be 4
        $tokens[4]['Text'] | Should -BeExactly 'w'
        $tokens[4]['Column'] | Should -Be 6
        $tokens[6]['Text'] | Should -BeExactly 'y'
        $tokens[6]['Line'] | Should -Be 502
        $tokens[6]['Column'] | Should -Be 0
        $tokens[7]['Column'] | Should -Be 2
    }

    It 'lexes a token longer than two windows: <Case>' -TestCases @(
        @{ Case = 'NAME at offset zero'; Prefix = ''; Piece = 'n' * 3000; Type = 'NAME'; Index = 0; Column = 0 }
        @{ Case = 'NAME after an earlier token'; Prefix = 'a '; Piece = 'n' * 3000; Type = 'NAME'; Index = 1; Column = 2 }
        @{ Case = 'COMMENT at offset zero'; Prefix = ''; Piece = '#' + ('x' * 2999); Type = 'COMMENT'; Index = 0; Column = 0 }
        @{ Case = 'COMMENT after an earlier token'; Prefix = 'a '; Piece = '#' + ('x' * 2999); Type = 'COMMENT'; Index = 1; Column = 2 }
    ) {
        # Arrange: the following tokens extend past the doubled window, so the size resets after the long token.
        $sample = $Prefix + $Piece + "`n" + (((' ' * 40) + "`n") * 60) + 'z'

        # Act
        $tokens = @(Get-TestToken -Text $sample)

        # Assert
        $tokens[$Index]['Type'] | Should -BeExactly $Type
        $tokens[$Index]['Text'] | Should -BeExactly $Piece
        $tokens[$Index]['Column'] | Should -Be $Column
        $tokens[$Index]['Line'] | Should -Be 1
        $tokens[-1]['Text'] | Should -BeExactly 'z'
        $tokens[-1]['Line'] | Should -Be 62
        $tokens[-1]['Column'] | Should -Be 0
    }

    It 'reports diagnostics with the right Line past the first window: <Case>' -TestCases @(
        @{ Case = 'an unclassified character'; Tail = 'c = a ? b'; Code = 'PYTHON_LEXER_UNCLASSIFIED'; Line = 301 }
        @{ Case = 'an unterminated string'; Tail = "x = 'abc`ny = 1"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 301 }
        @{ Case = 'an unclosed bracket'; Tail = "x = f(1,`n2"; Code = 'PYTHON_LEXER_UNTERMINATED'; Line = 302 }
    ) {
        # Arrange: 300 lines of 6 characters place the tail at offset 1800, past the first 1,024-character window.
        $sample = ("a = 1`n" * 300) + $Tail

        # Act
        $diagnostic = Get-TestDiagnostic -Text $sample

        # Assert
        $diagnostic['Code'] | Should -BeExactly $Code
        $diagnostic['Severity'] | Should -BeExactly 'error'
        $diagnostic['Blocking'] | Should -BeTrue
        $diagnostic['Line'] | Should -Be $Line
    }
}
