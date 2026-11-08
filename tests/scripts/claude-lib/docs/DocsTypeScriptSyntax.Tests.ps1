#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsTypeScriptSyntax.psm1.

.DESCRIPTION
    Covers import bindings in every supported form, member-call chains over identifier, call and
    new receivers, object-literal members with computed and spread entries, array literals,
    function and arrow parameters, loop body ranges and relative module resolution against an
    in-memory captured path set. Fixtures are in-memory strings; no file is written and no
    process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTypeScriptSyntax.psm1') -Force -ErrorAction Stop

    function Get-TestToken {
        param([string] $Text)
        $result = ConvertTo-DocsTypeScriptToken -Text $Text
        $result['Diagnostics'].Count | Should -Be 0
        , [object[]] $result['Tokens']
    }

    function Find-TestIndex {
        param([object[]] $Token, [string] $Text, [int] $Occurrence = 1)
        $seen = 0
        for ($index = 0; $index -lt $Token.Count; $index++) {
            if ([string] $Token[$index]['Text'] -ceq $Text) { $seen++; if ($seen -eq $Occurrence) { return $index } }
        }
        return -1
    }
}

AfterAll {
    Remove-Module -Name DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsTypeScriptImport' {
    It 'binds default, namespace, named, aliased, type-only, equals-require and require forms' {
        # Arrange
        $text = @'
import express from 'express';
import * as yargs from 'yargs';
import { program, Command as Cmd, type Option } from 'commander';
import type { Shape } from './shape';
import './side-effect';
import legacy = require('legacy');
const fp = require('fastify-plugin');
const { Router, json: parse } = require('express');
function f() { const inner = require('x'); }
'@
        $tokens = Get-TestToken -Text $text

        # Act
        [object[]] $bindings = Get-DocsTypeScriptImport -Tokens $tokens

        # Assert
        @($bindings | ForEach-Object { "$($_['Local'])=$($_['Imported'])@$($_['Module'])" }) | Should -Be @(
            'express=default@express', 'yargs=*@yargs', 'program=program@commander', 'Cmd=Command@commander', 'Option=Option@commander',
            'Shape=Shape@./shape', 'legacy=*@legacy', 'fp=*@fastify-plugin', 'Router=Router@express', 'parse=json@express', 'inner=*@x')
        $bindings[0]['Line'] | Should -Be 1
    }

    It 'ignores dynamic import calls and declarations without require' {
        $tokens = Get-TestToken -Text "const m = import('./m');`nconst x = 1;`nlet { a } = obj;"
        [object[]] $bindings = Get-DocsTypeScriptImport -Tokens $tokens
        $bindings.Count | Should -Be 0
    }
}

Describe 'Get-DocsTypeScriptMemberChain' {
    It 'follows calls on an identifier receiver across lines and stops at a member without a call' {
        # Arrange
        $tokens = Get-TestToken -Text "app`n  .get('/a', h)`n  .post('/b')`n  .argv;"

        # Act
        $chain = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex 0

        # Assert
        $chain['ReceiverEnd'] | Should -Be 0
        @($chain['Call'] | ForEach-Object { $_['Name'] }) | Should -Be @('get', 'post')
        $chain['Call'][0]['Argument'].Count | Should -Be 2
        $chain['Call'][0]['Line'] | Should -Be 2
        $chain['Call'][1]['EndLine'] | Should -Be 3
        $tokens[$chain['EndIndex']]['Text'] | Should -Be ')'
    }

    It 'accepts call and new receivers with member paths and returns null otherwise' {
        $tokens = Get-TestToken -Text "yargs(hideBin(argv)).command('x'); new a.b.Command('t').name('n'); new Command; 'lit'.x()"
        $callChain = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex 0
        $tokens[$callChain['ReceiverEnd']]['Text'] | Should -Be ')'
        $callChain['Call'][0]['Name'] | Should -Be 'command'
        $newIndex = Find-TestIndex -Token $tokens -Text 'new'
        $newChain = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex $newIndex
        $newChain['Call'][0]['Name'] | Should -Be 'name'
        $bareNew = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex (Find-TestIndex -Token $tokens -Text 'new' -Occurrence 2)
        $tokens[$bareNew['ReceiverEnd']]['Text'] | Should -Be 'Command'
        $bareNew['Call'].Count | Should -Be 0
        Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex (Find-TestIndex -Token $tokens -Text "'lit'") | Should -BeNullOrEmpty
        Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex 999 | Should -BeNullOrEmpty
        Get-DocsTypeScriptMemberChain -Tokens (Get-TestToken -Text 'new 1') -StartIndex 0 | Should -BeNullOrEmpty
    }

    It 'stops at an unbalanced call' {
        $tokens = (ConvertTo-DocsTypeScriptToken -Text 'a.b(1')['Tokens']
        $chain = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex 0
        $chain['Call'].Count | Should -Be 0
        $chain['EndIndex'] | Should -Be 0
    }
}

Describe 'Get-DocsTypeScriptObjectMember' {
    It 'returns literal, string, numeric, computed, spread, shorthand and method keys' {
        # Arrange
        $tokens = Get-TestToken -Text "({ a: 1, 'b-c': { d: 2 }, 3: x, [k]: 4, ...rest, short, m() {} })"
        $open = Find-TestIndex -Token $tokens -Text '{'

        # Act
        [object[]] $members = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex $open

        # Assert
        @($members | ForEach-Object { [string] $_['Key'] }) | Should -Be @('a', 'b-c', '3', '', '', 'short', 'm')
        $members[3]['Computed'] | Should -BeTrue
        $tokens[$members[3]['ValueStart']]['Text'] | Should -Be '4'
        $members[4]['Spread'] | Should -BeTrue
        $members[4]['ValueStart'] | Should -Be -1
        $tokens[$members[1]['ValueStart']]['Text'] | Should -Be '{'
        $members[5]['ValueStart'] | Should -Be $members[5]['KeyIndex']
        $tokens[$members[6]['ValueStart']]['Text'] | Should -Be '('
        [object[]] $none = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex 0
        $none.Count | Should -Be 0
    }
}

Describe 'Get-DocsTypeScriptArrayLiteral' {
    It 'decodes an array of literals and rejects non-literal members and non-arrays' {
        $tokens = Get-TestToken -Text "['a', 'b' + 'c'] ['d', e] [] 'x'"
        [string[]] $decoded = Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span @{ Start = 0; End = 6 }
        $decoded | Should -Be @('a', 'bc')
        Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span @{ Start = 7; End = 11 } | Should -BeNullOrEmpty
        [string[]] $emptyArray = Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span @{ Start = 12; End = 13 }
        $emptyArray.Count | Should -Be 0
        Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span @{ Start = 14; End = 14 } | Should -BeNullOrEmpty
        Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span @{ Start = 0; End = 5 } | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsTypeScriptFunctionParameter' {
    It 'reads the first parameter and body of arrow and function expressions' {
        $cases = @(
            @{ Text = '(y) => y.option()'; Parameter = 'y'; BodyText = 'y' },
            @{ Text = 'async (y: Argv, z) => { return y; }'; Parameter = 'y'; BodyText = '{' },
            @{ Text = 'y => y'; Parameter = 'y'; BodyText = 'y' },
            @{ Text = '(y): Argv => y'; Parameter = 'y'; BodyText = 'y' },
            @{ Text = 'function* (y) { }'; Parameter = 'y'; BodyText = '{' },
            @{ Text = 'async function named(y) { }'; Parameter = 'y'; BodyText = '{' },
            @{ Text = '() => 1'; Parameter = $null; BodyText = '1' },
            @{ Text = '({ a }) => a'; Parameter = $null; BodyText = 'a' }
        )
        foreach ($case in $cases) {
            $tokens = Get-TestToken -Text $case['Text']
            $result = Get-DocsTypeScriptFunctionParameter -Tokens $tokens -Span @{ Start = 0; End = $tokens.Count - 1 }
            $result | Should -Not -BeNullOrEmpty -Because $case['Text']
            $result['Parameter'] | Should -Be $case['Parameter'] -Because $case['Text']
            $tokens[$result['BodyStart']]['Text'] | Should -Be $case['BodyText'] -Because $case['Text']
            $result['BodyEnd'] | Should -Be ($tokens.Count - 1)
        }
    }

    It 'returns null for a non-function span' {
        foreach ($text in @('(a + b)', '{ a: 1 }', 'f(x)', 'function 1', '(a) { }')) {
            $tokens = Get-TestToken -Text $text
            Get-DocsTypeScriptFunctionParameter -Tokens $tokens -Span @{ Start = 0; End = $tokens.Count - 1 } | Should -BeNullOrEmpty -Because $text
        }
    }
}

Describe 'Get-DocsTypeScriptLoopRange and Test-DocsTypeScriptInRange' {
    It 'finds brace-delimited for, for await, while and do bodies' {
        # Arrange
        $text = "for (const a of b) { x(); }`nfor await (const c of d) { y(); }`nwhile (e) { z(); }`ndo { w(); } while (f);`nfor (;;) v();`nif (g) { u(); }"
        $tokens = Get-TestToken -Text $text

        # Act
        [object[]] $ranges = Get-DocsTypeScriptLoopRange -Tokens $tokens

        # Assert
        $ranges.Count | Should -Be 4
        @($ranges | ForEach-Object { $tokens[$_['Start'] + 1]['Text'] }) | Should -Be @('x', 'y', 'z', 'w')
        Test-DocsTypeScriptInRange -Range $ranges -Index (Find-TestIndex -Token $tokens -Text 'x') | Should -BeTrue
        Test-DocsTypeScriptInRange -Range $ranges -Index (Find-TestIndex -Token $tokens -Text 'v') | Should -BeFalse
        Test-DocsTypeScriptInRange -Range $ranges -Index (Find-TestIndex -Token $tokens -Text 'u') | Should -BeFalse
        Test-DocsTypeScriptInRange -Range @() -Index 0 | Should -BeFalse
        Test-DocsTypeScriptInRange -Range $null -Index 0 | Should -BeFalse
    }
}

Describe 'Resolve-DocsTypeScriptRelativeModule' {
    It 'resolves relative specifiers against the captured set in candidate order' {
        $captured = [string[]]@('src/a/x.ts', 'src/a/y.tsx', 'src/b/index.ts', 'src/c.mts', 'src/d.cts', 'src/e.d.ts', 'src/a/z.ts', 'src/a/z.tsx', 'lib/root.ts')
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier './x' -CapturedPath $captured | Should -Be 'src/a/x.ts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier './y' -CapturedPath $captured | Should -Be 'src/a/y.tsx'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier '../b' -CapturedPath $captured | Should -Be 'src/b/index.ts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier '../c.mjs' -CapturedPath $captured | Should -Be 'src/c.mts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier '../d.cjs' -CapturedPath $captured | Should -Be 'src/d.cts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier '../e' -CapturedPath $captured | Should -Be 'src/e.d.ts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier './z.js' -CapturedPath $captured | Should -Be 'src/a/z.ts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier './x.ts' -CapturedPath $captured | Should -Be 'src/a/x.ts'
        Resolve-DocsTypeScriptRelativeModule -FromPath 'main.ts' -Specifier './lib/root' -CapturedPath $captured | Should -Be 'lib/root.ts'
    }

    It 'returns null for package specifiers, escapes above the root and missing files' {
        $captured = [string[]]@('src/a/x.ts')
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier 'express' -CapturedPath $captured | Should -BeNullOrEmpty
        Resolve-DocsTypeScriptRelativeModule -FromPath 'main.ts' -Specifier '../up' -CapturedPath $captured | Should -BeNullOrEmpty
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier './missing' -CapturedPath $captured | Should -BeNullOrEmpty
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier '.' -CapturedPath $captured | Should -BeNullOrEmpty
        Resolve-DocsTypeScriptRelativeModule -FromPath 'src/a/main.ts' -Specifier './x.jsx' -CapturedPath $captured | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsTypeScriptStatementEnd' {
    It 'ends at a semicolon, a block followed by a semicolon or a new line, a declaration on a new line, a depth drop, or the last token' {
        $tokens = [object[]] (ConvertTo-DocsTypeScriptToken -Text "a = 1;`nb = () => { x; };`nc = () => { y; }`nd = 2`n{ e = 3 } f")['Tokens']
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index 0)]['Text'] | Should -Be ';'
        $endB = Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index 4
        $tokens[$endB]['Text'] | Should -Be ';'
        $tokens[$endB - 1]['Text'] | Should -Be '}'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index ($endB + 1))]['Text'] | Should -Be '}'
        $dIndex = $endB + 10
        $tokens[$dIndex]['Text'] | Should -Be 'd'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index $dIndex)]['Text'] | Should -Be 'f'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index ($dIndex + 4))]['Text'] | Should -Be '3'
        $asi = [object[]] (ConvertTo-DocsTypeScriptToken -Text "export type T = A |`n  B`nexport const x = 1`ntype U = 2`n@dec`nclass C {}`nasync fn()`ndeclare const z: 1")['Tokens']
        $tokens = $asi
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index 0)]['Text'] | Should -Be 'B'
        $xIndex = 7
        $tokens[$xIndex]['Text'] | Should -Be 'export'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index $xIndex)]['Text'] | Should -Be '1'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index ($xIndex + 5))]['Text'] | Should -Be '2'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index ($xIndex + 9))]['Text'] | Should -Be 'dec'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index ($xIndex + 11))]['Text'] | Should -Be '}'
        $tokens[(Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index ($xIndex + 15))]['Text'] | Should -Be ')'
    }
}

Describe 'Get-DocsTypeScriptBindingList' {
    It 'reads export-clause bindings with as, colon and string names' {
        $tokens = Get-TestToken -Text "{ a, b as c, type d, e: f, g as 'h i', 'j k' as l, 1 }"
        [object[]] $pairs = Get-DocsTypeScriptBindingList -Tokens $tokens -OpenIndex 0
        @($pairs | ForEach-Object { "$($_['Imported'])>$($_['Local']):$($_['TypeOnly'])" }) | Should -Be @('a>a:False', 'b>c:False', 'd>d:True', 'e>f:False', 'g>h i:False', 'j k>l:False')
    }
}

Describe 'Test-DocsTypeScriptToken, Test-DocsTypeScriptName and Test-DocsTypeScriptStatementStart' {
    It 'matches kind and text and recognizes statement starts' {
        $tokens = Get-TestToken -Text "a;`nb c; { d } e"
        Test-DocsTypeScriptToken -Tokens $tokens -Index 0 -Kind 'identifier' -Text @('a') | Should -BeTrue
        Test-DocsTypeScriptToken -Tokens $tokens -Index 0 -Kind 'keyword' | Should -BeFalse
        Test-DocsTypeScriptToken -Tokens $tokens -Index 0 -Text @('z') | Should -BeFalse
        Test-DocsTypeScriptToken -Tokens $tokens -Index -1 | Should -BeFalse
        Test-DocsTypeScriptToken -Tokens $tokens -Index 99 | Should -BeFalse
        Test-DocsTypeScriptName -Tokens $tokens -Index 1 | Should -BeFalse
        Test-DocsTypeScriptName -Tokens $tokens -Index 99 | Should -BeFalse
        Test-DocsTypeScriptStatementStart -Tokens $tokens -Index 0 | Should -BeTrue
        Test-DocsTypeScriptStatementStart -Tokens $tokens -Index 2 | Should -BeTrue
        Test-DocsTypeScriptStatementStart -Tokens $tokens -Index 3 | Should -BeFalse
        Test-DocsTypeScriptStatementStart -Tokens $tokens -Index 6 | Should -BeTrue
        Test-DocsTypeScriptStatementStart -Tokens $tokens -Index 8 | Should -BeTrue
    }
}
