#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonSyntax.psm1 (issue #1022).

.DESCRIPTION
    Covers logical lines (indent with tabs and form feed, continuation, brackets, ';' splitting,
    PYTHON_INDENTATION_INVALID), enclosing blocks (loops, comprehensions, def and class,
    same-line bodies), literal string values, dotted chains, comma splitting and call reading
    (positional, keyword, star, list and dynamic arguments), each with a seeded property test.
    Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonSyntax.psm1') -Force -ErrorAction Stop

    function Get-TestLine {
        param([string] $Text)
        $lexed = Get-DocsPythonToken -Text $Text
        $lexed.Diagnostics.Count | Should -Be 0 -Because 'the fixture lexes cleanly'
        return Get-DocsPythonLogicalLine -Token $lexed.Tokens
    }

    function Get-TestTokenList {
        param([string] $Text)
        return (Get-TestLine -Text $Text).Lines[0]['Tokens']
    }
}

AfterAll {
    Remove-Module -Name DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPythonLogicalLine' {
    It 'groups physical lines into logical lines with indent, spans and levels' {
        # Arrange
        $text = "import os  # comment`n`nif x:`n`tfoo(1,`n      2)  # inside`n`ta = 1; b = 2`n" + [char]0x0C + "c = \`n  3`n"

        # Act
        $result = Get-TestLine -Text $text
        $lines = $result.Lines

        # Assert
        $result.Diagnostics.Count | Should -Be 0
        $lines.Count | Should -Be 6
        @($lines | ForEach-Object { $_['StartLine'] }) | Should -Be @(1, 3, 4, 6, 6, 7)
        @($lines | ForEach-Object { $_['EndLine'] }) | Should -Be @(1, 3, 5, 6, 6, 8)
        @($lines | ForEach-Object { $_['Indent'] }) | Should -Be @(0, 0, 8, 8, 8, 0)
        @($lines[2]['Tokens'] | ForEach-Object { $_['Text'] }) | Should -Be @('foo', '(', '1', ',', '2', ')')
        @($lines[2]['Tokens'] | ForEach-Object { $_['Level'] }) | Should -Be @(0, 0, 1, 1, 1, 0)
        @($lines[3]['Tokens'] | ForEach-Object { $_['Text'] }) | Should -Be @('a', '=', '1')
        @($lines[5]['Tokens'] | ForEach-Object { $_['Text'] }) | Should -Be @('c', '=', '3')
        @($lines | ForEach-Object { $_['Index'] }) | Should -Be @(0, 1, 2, 3, 4, 5)
    }

    It 'does not mutate the lexer tokens' {
        $lexed = Get-DocsPythonToken -Text "f(1)"
        [void] (Get-DocsPythonLogicalLine -Token $lexed.Tokens)
        $lexed.Tokens[0].ContainsKey('Level') | Should -BeFalse
    }

    It 'reports PYTHON_INDENTATION_INVALID as a blocking error for a dedent to an unknown column' {
        # Arrange
        $lexed = Get-DocsPythonToken -Text "if a:`n        b = 1`n    c = 2`nd = 3"

        # Act
        $result = Get-DocsPythonLogicalLine -Token $lexed.Tokens

        # Assert
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'PYTHON_INDENTATION_INVALID'
        $result.Diagnostics[0]['Severity'] | Should -BeExactly 'error'
        $result.Diagnostics[0]['Blocking'] | Should -BeTrue
        $result.Diagnostics[0]['Line'] | Should -Be 3
        $result.Lines.Count | Should -Be 4
    }

    It 'accepts a dedent to an earlier column and ignores indentation inside brackets' {
        $result = Get-TestLine -Text "if a:`n    if b:`n        c = [1,`n  2]`n    d = 1`ne = 2"
        $result.Diagnostics.Count | Should -Be 0
        $result.Lines.Count | Should -Be 5
    }

    It 'property: Get-DocsPythonLogicalLine yields one logical line per non-blank statement with the written indent' {
        $seed = 102230
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(1, 12)
            $builder = [System.Text.StringBuilder]::new()
            $expectedIndent = [System.Collections.Generic.List[int]]::new()
            $indent = 0
            for ($i = 0; $i -lt $count; $i++) {
                if ($random.Next(3) -eq 0) { [void] $builder.Append("`n") }
                if ($random.Next(4) -eq 0) { [void] $builder.Append("# note`n") }
                $delta = $random.Next(-1, 2)
                $indent = [math]::Max(0, $indent + $delta)
                $expectedIndent.Add($indent * 4)
                [void] $builder.Append(' ' * ($indent * 4)).Append("x$i = (1,`n 2)`n")
            }
            $because = "seed $seed, iteration $iteration"
            $lexed = Get-DocsPythonToken -Text $builder.ToString()
            $result = Get-DocsPythonLogicalLine -Token $lexed.Tokens
            $result.Lines.Count | Should -Be $count -Because $because
            @($result.Lines | ForEach-Object { $_['Indent'] }) | Should -Be $expectedIndent.ToArray() -Because $because
            foreach ($line in $result.Lines) { $line['EndLine'] | Should -Be ($line['StartLine'] + 1) -Because $because }
        }
    }
}

Describe 'Get-DocsPythonEnclosingBlock' {
    BeforeAll {
        $script:BlockText = @(
            'import a'
            'for i in x:'
            '    while y:'
            '        f(i)'
            'def g():'
            '    class C:'
            '        h()'
            '    if z:'
            '        k()'
            'try:'
            '    m()'
            'except E:'
            '    n()'
            'for q in r: p(q)'
            'items = [f(v) for v in w]'
            'other = g(1, [x for x in y])'
            'if t:'
            '    try:'
            '        u()'
            '    finally:'
            '        import s'
        ) -join "`n"
        $script:BlockLines = (Get-TestLine -Text $script:BlockText).Lines
    }

    It 'returns the enclosing kinds, loop, def and class flags: line <Index>' -TestCases @(
        @{ Index = 0; Kinds = @(); InLoop = $false; InDef = $false; InClass = $false; TopLevelOnly = $true }
        @{ Index = 3; Kinds = @('for', 'while'); InLoop = $true; InDef = $false; InClass = $false; TopLevelOnly = $false }
        @{ Index = 6; Kinds = @('def', 'class'); InLoop = $false; InDef = $true; InClass = $true; TopLevelOnly = $false }
        @{ Index = 8; Kinds = @('def', 'if'); InLoop = $false; InDef = $true; InClass = $false; TopLevelOnly = $false }
        @{ Index = 10; Kinds = @('try'); InLoop = $false; InDef = $false; InClass = $false; TopLevelOnly = $true }
        @{ Index = 12; Kinds = @('except'); InLoop = $false; InDef = $false; InClass = $false; TopLevelOnly = $true }
        @{ Index = 20; Kinds = @('if', 'finally'); InLoop = $false; InDef = $false; InClass = $false; TopLevelOnly = $true }
    ) {
        $block = Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index $Index
        $block['Kinds'] | Should -Be $Kinds
        $block['InLoop'] | Should -Be $InLoop
        $block['InDef'] | Should -Be $InDef
        $block['InClass'] | Should -Be $InClass
        $block['TopLevelOnly'] | Should -Be $TopLevelOnly
    }

    It 'treats a same-line loop body as inside the loop only after the colon' {
        $tokens = $script:BlockLines[13]['Tokens']
        $call = [array]::FindIndex($tokens, [Predicate[object]] { param($t) $t['Text'] -ceq 'p' })
        (Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index 13 -TokenIndex $call)['InLoop'] | Should -BeTrue
        (Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index 13 -TokenIndex 1)['InLoop'] | Should -BeFalse
    }

    It 'detects a comprehension around the site token and not outside its bracket group' {
        $tokens = $script:BlockLines[15]['Tokens']
        $inner = [array]::FindIndex($tokens, [Predicate[object]] { param($t) $t['Text'] -ceq 'x' })
        (Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index 15 -TokenIndex $inner)['InComprehension'] | Should -BeTrue
        (Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index 15 -TokenIndex 0)['InComprehension'] | Should -BeFalse
        (Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index 14)['InComprehension'] | Should -BeTrue
        (Get-DocsPythonEnclosingBlock -Line $script:BlockLines -Index 3)['InComprehension'] | Should -BeFalse
    }

    It 'property: Get-DocsPythonEnclosingBlock reports the nesting chain of generated blocks' {
        $seed = 102231
        $random = [System.Random]::new($seed)
        $openers = @('for i in x:', 'while y:', 'def f():', 'class C:', 'if z:', 'try:', 'with w:')
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $depth = $random.Next(0, 6)
            $chosen = @(if ($depth -gt 0) { 1..$depth | ForEach-Object { $openers[$random.Next($openers.Length)] } })
            $builder = [System.Text.StringBuilder]::new()
            for ($i = 0; $i -lt $depth; $i++) { [void] $builder.Append('    ' * $i).Append($chosen[$i]).Append("`n") }
            [void] $builder.Append('    ' * $depth).Append("site()`n")
            $lines = (Get-TestLine -Text $builder.ToString()).Lines
            $block = Get-DocsPythonEnclosingBlock -Line $lines -Index ($lines.Count - 1)
            $expected = @($chosen | ForEach-Object { ($_ -split ' ')[0].TrimEnd(':') })
            $block['Kinds'] | Should -Be $expected -Because "seed $seed, iteration $iteration"
            $block['InLoop'] | Should -Be (($expected -ccontains 'for') -or ($expected -ccontains 'while')) -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'ConvertFrom-DocsPythonStringToken' {
    It 'returns the literal for <Case> and $null for dynamic forms' -TestCases @(
        @{ Case = 'plain'; Text = "'abc'"; Expected = 'abc' }
        @{ Case = 'double'; Text = '"a b"'; Expected = 'a b' }
        @{ Case = 'raw with backslash'; Text = "r'\d+'"; Expected = '\d+' }
        @{ Case = 'triple'; Text = "'''x`ny'''"; Expected = "x`ny" }
        @{ Case = 'concatenation'; Text = "'a' 'b'"; Expected = 'ab' }
        @{ Case = 'escaped non-raw'; Text = "'a\nb'"; Expected = $null }
        @{ Case = 'bytes'; Text = "b'a'"; Expected = $null }
        @{ Case = 'f-string'; Text = 'f"{a}"'; Expected = $null }
        @{ Case = 'concatenation with an f-string part'; Text = "'a' f'{b}'"; Expected = $null }
        @{ Case = 'unicode prefix'; Text = "u'a'"; Expected = 'a' }
    ) {
        $tokens = @((Get-DocsPythonToken -Text $Text).Tokens | Where-Object { $_['Type'] -ceq 'STRING' })
        if ($null -eq $Expected) { ConvertFrom-DocsPythonStringToken -Token $tokens | Should -BeNullOrEmpty }
        else { ConvertFrom-DocsPythonStringToken -Token $tokens | Should -BeExactly $Expected }
    }

    It 'returns $null for a non-string token and for no token' {
        $tokens = @((Get-DocsPythonToken -Text 'name').Tokens)
        ConvertFrom-DocsPythonStringToken -Token $tokens | Should -BeNullOrEmpty
        ConvertFrom-DocsPythonStringToken -Token @() | Should -BeNullOrEmpty
    }

    It 'property: ConvertFrom-DocsPythonStringToken returns the body of a quoted escape-free string' {
        $seed = 102232
        $random = [System.Random]::new($seed)
        $alphabet = 'abc XYZ_-/{}0'
        for ($iteration = 0; $iteration -lt 200; $iteration++) {
            $body = -join @(1..($random.Next(0, 10)) | ForEach-Object { $alphabet[$random.Next($alphabet.Length)] })
            $quote = @("'", '"', "'''", '"""')[$random.Next(4)]
            $prefix = @('', 'r', 'R', 'u')[$random.Next(4)]
            $tokens = @((Get-DocsPythonToken -Text ($prefix + $quote + $body + $quote)).Tokens)
            ConvertFrom-DocsPythonStringToken -Token $tokens | Should -BeExactly $body -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Read-DocsPythonDottedChain and Split-DocsPythonTokenList' {
    It 'reads a dotted chain and stops at a non-name' {
        $tokens = Get-TestTokenList -Text 'a.b.c(x)'
        $chain = Read-DocsPythonDottedChain -Token $tokens -Index 0
        $chain['Text'] | Should -BeExactly 'a.b.c'
        $chain['Parts'] | Should -Be @('a', 'b', 'c')
        $chain['End'] | Should -Be 5
        Read-DocsPythonDottedChain -Token $tokens -Index 5 | Should -BeNullOrEmpty
    }

    It 'splits at commas of the given level only and drops empty slices' {
        $tokens = Get-TestTokenList -Text 'f(a, g(b, c), [d, e],)'
        $pieces = Split-DocsPythonTokenList -Token $tokens -Start 2 -End ($tokens.Count - 1) -Level 1
        $pieces.Count | Should -Be 3
        @($pieces | ForEach-Object { (@($_ | ForEach-Object { $_['Text'] })) -join '' }) | Should -Be @('a', 'g(b,c)', '[d,e]')
    }

    It 'property: Read-DocsPythonDottedChain joins the generated parts with dots' {
        $seed = 102233
        $random = [System.Random]::new($seed)
        $names = @('a', 'B', 'c1', '_d')
        for ($iteration = 0; $iteration -lt 150; $iteration++) {
            $parts = @(1..($random.Next(1, 6)) | ForEach-Object { $names[$random.Next($names.Length)] })
            $tokens = Get-TestTokenList -Text (($parts -join '.') + ' = 1')
            $chain = Read-DocsPythonDottedChain -Token $tokens -Index 0
            $chain['Text'] | Should -BeExactly ($parts -join '.') -Because "seed $seed, iteration $iteration"
            $chain['End'] | Should -Be ($parts.Count * 2 - 1) -Because "seed $seed, iteration $iteration"
        }
    }

    It 'property: Split-DocsPythonTokenList returns one slice per generated argument' {
        $seed = 102234
        $random = [System.Random]::new($seed)
        $arguments = @('1', 'x', '(1, 2)', '[a, b]', '"s"', 'f(1, g(2))')
        for ($iteration = 0; $iteration -lt 150; $iteration++) {
            $chosen = @(1..($random.Next(1, 7)) | ForEach-Object { $arguments[$random.Next($arguments.Length)] })
            $tokens = Get-TestTokenList -Text ('h(' + ($chosen -join ', ') + ')')
            $pieces = Split-DocsPythonTokenList -Token $tokens -Start 2 -End ($tokens.Count - 1) -Level 1
            $pieces.Count | Should -Be $chosen.Count -Because "seed $seed, iteration $iteration"
            for ($i = 0; $i -lt $chosen.Count; $i++) {
                ((@($pieces[$i] | ForEach-Object { $_['Text'] })) -join '') | Should -BeExactly $chosen[$i].Replace(' ', '') -Because "seed $seed, iteration $iteration"
            }
        }
    }
}

Describe 'Read-DocsPythonCall' {
    It 'reads callee, positional, keyword, star, list and dynamic arguments' {
        # Arrange
        $tokens = Get-TestTokenList -Text "p = parser.add_argument('--x', '-y' 'z', *rest, help=f'{h}', action=store, choices=['a', 'b'], n=3, cls=Foo(1), t=(1, 2))"

        # Act
        $call = Read-DocsPythonCall -Token $tokens -Index 2

        # Assert
        $call['Callee'] | Should -BeExactly 'parser.add_argument'
        $call['CalleeParts'] | Should -Be @('parser', 'add_argument')
        $call['Positional'].Count | Should -Be 3
        $call['Positional'][0]['Kind'] | Should -BeExactly 'string'
        $call['Positional'][0]['Value'] | Should -BeExactly '--x'
        $call['Positional'][1]['Value'] | Should -BeExactly '-yz'
        $call['Positional'][2]['Kind'] | Should -BeExactly 'star'
        $call['HasStar'] | Should -BeTrue
        $call['Keyword']['help']['Kind'] | Should -BeExactly 'string'
        $call['Keyword']['help']['Value'] | Should -BeNullOrEmpty
        $call['Keyword']['action']['Kind'] | Should -BeExactly 'name'
        $call['Keyword']['action']['Value'] | Should -BeExactly 'store'
        $call['Keyword']['choices']['Kind'] | Should -BeExactly 'list'
        $call['Keyword']['choices']['Items'] | Should -Be @('a', 'b')
        $call['Keyword']['n']['Kind'] | Should -BeExactly 'number'
        $call['Keyword']['cls']['Kind'] | Should -BeExactly 'call'
        $call['Keyword']['cls']['Value'] | Should -BeExactly 'Foo'
        $call['Keyword']['t']['Kind'] | Should -BeExactly 'tuple'
        $call['Keyword'].ContainsKey('Help') | Should -BeFalse
        $call['CloseIndex'] | Should -Be ($tokens.Count - 1)
        $call['StartLine'] | Should -Be 1
    }

    It 'returns $null when the index is not a call and keeps attribute and other kinds' {
        $tokens = Get-TestTokenList -Text 'x = a.b + 1'
        Read-DocsPythonCall -Token $tokens -Index 2 | Should -BeNullOrEmpty
        Read-DocsPythonCall -Token $tokens -Index 1 | Should -BeNullOrEmpty
        $call = Read-DocsPythonCall -Token (Get-TestTokenList -Text 'f(a.b, 1 + 2, [x, "y"])') -Index 0
        $call['Positional'][0]['Kind'] | Should -BeExactly 'attribute'
        $call['Positional'][0]['Value'] | Should -BeExactly 'a.b'
        $call['Positional'][1]['Kind'] | Should -BeExactly 'other'
        $call['Positional'][2]['Kind'] | Should -BeExactly 'list'
        $call['Positional'][2]['Items'] | Should -BeNullOrEmpty
    }

    It 'records the span of a call that continues across lines' {
        $tokens = Get-TestTokenList -Text "f(`n    1,`n    key=2,`n)"
        $call = Read-DocsPythonCall -Token $tokens -Index 0
        $call['StartLine'] | Should -Be 1
        $call['EndLine'] | Should -Be 4
        $call['Keyword']['key']['StartLine'] | Should -Be 3
    }

    It 'property: Read-DocsPythonCall recovers the generated positional and keyword arguments' {
        $seed = 102235
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 150; $iteration++) {
            $positionalCount = $random.Next(0, 4)
            $keywordCount = $random.Next(0, 4)
            $positional = @(if ($positionalCount -gt 0) { 1..$positionalCount | ForEach-Object { "'p$_'" } })
            $keyword = @(if ($keywordCount -gt 0) { 1..$keywordCount | ForEach-Object { "k$_='v$_'" } })
            $text = 'obj.method(' + (@($positional + $keyword) -join ', ') + ')'
            $call = Read-DocsPythonCall -Token (Get-TestTokenList -Text $text) -Index 0
            $call['Positional'].Count | Should -Be $positionalCount -Because "seed $seed, iteration $iteration"
            $call['Keyword'].Count | Should -Be $keywordCount -Because "seed $seed, iteration $iteration"
            for ($i = 1; $i -le $positionalCount; $i++) { $call['Positional'][$i - 1]['Value'] | Should -BeExactly "p$i" -Because "seed $seed, iteration $iteration" }
            for ($i = 1; $i -le $keywordCount; $i++) { $call['Keyword']["k$i"]['Value'] | Should -BeExactly "v$i" -Because "seed $seed, iteration $iteration" }
        }
    }
}
