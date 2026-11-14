#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsCSharpSyntax.psm1.

.DESCRIPTION
    Covers token predicates, attribute sections (targets, dotted names, the Attribute suffix,
    arguments), modifiers, type text (dotted, generic, tuple, array, nullable), parameter lists
    with modifiers and defaults, type declarations (class, record, record struct, delegate,
    generics, primary constructors, base lists, bodies), member chains with generic calls,
    string lists, namespace ranges and parameter scopes. Fixtures are in-memory strings; no
    file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsCSharpTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsCSharpSyntax.psm1') -Force -ErrorAction Stop

    function Get-TestToken {
        param([string] $Text)
        $result = ConvertTo-DocsCSharpToken -Text $Text
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
    Remove-Module -Name DocsCSharpSyntax, DocsCSharpTokens, DocsScannerCommon, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Test-DocsCSharpToken and Test-DocsCSharpName' {
    It 'matches kind and text and recognizes identifiers and keywords as names' {
        $tokens = Get-TestToken -Text 'public int x = 1;'
        Test-DocsCSharpToken -Tokens $tokens -Index 0 -Kind 'keyword' -Text @('public') | Should -BeTrue
        Test-DocsCSharpToken -Tokens $tokens -Index 0 -Kind 'identifier' | Should -BeFalse
        Test-DocsCSharpToken -Tokens $tokens -Index 2 -Text @('y') | Should -BeFalse
        Test-DocsCSharpToken -Tokens $tokens -Index -1 | Should -BeFalse
        Test-DocsCSharpToken -Tokens $tokens -Index 99 | Should -BeFalse
        Test-DocsCSharpName -Tokens $tokens -Index 1 | Should -BeTrue
        Test-DocsCSharpName -Tokens $tokens -Index 2 | Should -BeTrue
        Test-DocsCSharpName -Tokens $tokens -Index 3 | Should -BeFalse
        Test-DocsCSharpName -Tokens $tokens -Index 99 | Should -BeFalse
    }
}

Describe 'Get-DocsCSharpAttributeSection' {
    It 'reads consecutive sections with targets, dotted names, the Attribute suffix and arguments' {
        # Arrange
        $tokens = Get-TestToken -Text '[return: Ns.HttpGetAttribute("x", Name = "n")] [Route("a"), ApiController] [Obsolete] public void M() {}'

        # Act
        $section = Get-DocsCSharpAttributeSection -Tokens $tokens -Index 0

        # Assert
        @($section['Attribute'] | ForEach-Object { "$($_['Name']):$($_['Argument'].Count)" }) | Should -Be @('HttpGet:2', 'Route:1', 'ApiController:0', 'Obsolete:0')
        $section['Attribute'][0]['Line'] | Should -Be 1
        $tokens[$section['EndIndex']]['Text'] | Should -Be 'public'
        (Get-DocsCSharpAttributeSection -Tokens $tokens -Index $section['EndIndex'])['Attribute'].Count | Should -Be 0
        (Get-DocsCSharpAttributeSection -Tokens (Get-TestToken -Text '[unterminated') -Index 0)['EndIndex'] | Should -Be 0
    }
}

Describe 'Get-DocsCSharpModifier' {
    It 'reads modifiers and stops at ref and file used as types' {
        $tokens = Get-TestToken -Text 'public static async partial ref struct S {} ref int r; file class F {} file x;'
        $first = Get-DocsCSharpModifier -Tokens $tokens -Index 0
        $first['Modifier'] | Should -Be @('public', 'static', 'async', 'partial', 'ref')
        $tokens[$first['EndIndex']]['Text'] | Should -Be 'struct'
        $refType = Get-DocsCSharpModifier -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'ref' -Occurrence 2)
        $refType['Modifier'].Count | Should -Be 0
        (Get-DocsCSharpModifier -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'file'))['Modifier'] | Should -Be @('file')
        (Get-DocsCSharpModifier -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'file' -Occurrence 2))['Modifier'] | Should -Be @('file')
    }
}

Describe 'Get-DocsCSharpTypeText' {
    It 'spells dotted, generic, tuple, array, nullable and pointer types without whitespace' {
        $cases = @(
            @{ Text = 'int x'; Expected = 'int'; End = 'int' },
            @{ Text = 'global::System.Collections.Generic.List< Dictionary<string, int[]> > x'; Expected = 'global::System.Collections.Generic.List<Dictionary<string,int[]>>'; End = '>' },
            @{ Text = '(int a, string? b)? x'; Expected = '(inta,string?b)?'; End = '?' },
            @{ Text = 'int[,] x'; Expected = 'int[,]'; End = ']' },
            @{ Text = 'byte* p'; Expected = 'byte*'; End = '*' },
            @{ Text = 'Task<IActionResult> M'; Expected = 'Task<IActionResult>'; End = '>' }
        )
        foreach ($case in $cases) {
            $tokens = Get-TestToken -Text $case['Text']
            $type = Get-DocsCSharpTypeText -Tokens $tokens -Index 0
            $type['Text'] | Should -Be $case['Expected'] -Because $case['Text']
            $tokens[$type['EndIndex']]['Text'] | Should -Be $case['End'] -Because $case['Text']
        }
        Get-DocsCSharpTypeText -Tokens (Get-TestToken -Text '= 1') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeText -Tokens (Get-TestToken -Text 'List<int x') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeText -Tokens (Get-TestToken -Text 'List<int; }') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeText -Tokens (Get-TestToken -Text '(int a') -Index 0 | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsCSharpParameterList' {
    It 'reads modifiers, types, names, attributes and defaults, and tolerates an unreadable entry' {
        $tokens = Get-TestToken -Text '(this IEndpointRouteBuilder routes, [FromBody] ref int count = 3, params string[] rest, out var o, T, int)'
        $list = Get-DocsCSharpParameterList -Tokens $tokens -OpenIndex 0
        @($list['Parameter'] | ForEach-Object { "$($_['Modifier'])|$($_['Type'])|$($_['Name'])" }) | Should -Be @('this|IEndpointRouteBuilder|routes', 'ref|int|count', 'params|string[]|rest', 'out|var|o', '||T', '|int|')
        $tokens[$list['CloseIndex']]['Text'] | Should -Be ')'
        (Get-DocsCSharpParameterList -Tokens (Get-TestToken -Text '(int a') -OpenIndex 0)['CloseIndex'] | Should -Be -1
    }
}

Describe 'Get-DocsCSharpTypeDeclaration' {
    It 'reads classes with generics and bases, records with primary constructors, record structs, enums and delegates' {
        $tokens = Get-TestToken -Text 'class Repo<T, TKey> : Base<T>(1), IRepo where T : class { int x; } record Person(string Name, int Age) : Entity; record struct Point(int X); enum Color { Red } delegate int Op(int a); interface I { } struct S;'
        $repo = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index 0
        $repo['Kind'] | Should -Be 'class'
        $repo['Name'] | Should -Be 'Repo'
        $repo['TypeParameter'] | Should -Be '<T,TKey>'
        $repo['Base'] | Should -Be @('Base<T>', 'IRepo')
        $tokens[$repo['BodyOpen']]['Text'] | Should -Be '{'
        $tokens[$repo['BodyClose']]['Text'] | Should -Be '}'
        $tokens[$repo['HeaderEnd']]['Text'] | Should -Be 'class'
        $person = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'record')
        $person['Kind'] | Should -Be 'record'
        @($person['PositionalParameter'] | ForEach-Object { "$($_['Type']) $($_['Name'])" }) | Should -Be @('string Name', 'int Age')
        $person['Base'] | Should -Be @('Entity')
        $person['BodyOpen'] | Should -Be -1
        $tokens[$person['HeaderEnd']]['Text'] | Should -Be ';'
        $point = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'record' -Occurrence 2)
        $point['Kind'] | Should -Be 'record-struct'
        $point['Name'] | Should -Be 'Point'
        (Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'enum'))['Name'] | Should -Be 'Color'
        $op = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'delegate')
        $op['Kind'] | Should -Be 'delegate'
        $op['Name'] | Should -Be 'Op'
        $op['BodyOpen'] | Should -Be -1
        (Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'interface'))['Name'] | Should -Be 'I'
        (Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index (Find-TestIndex -Token $tokens -Text 'struct' -Occurrence 2))['Name'] | Should -Be 'S'
    }

    It 'returns null for a non-declaration, a missing name, an unbalanced body or an unreadable generic' {
        Get-DocsCSharpTypeDeclaration -Tokens (Get-TestToken -Text 'int x;') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeDeclaration -Tokens (Get-TestToken -Text 'class { }') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeDeclaration -Tokens (Get-TestToken -Text 'class A {') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeDeclaration -Tokens (Get-TestToken -Text 'class A<T {') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeDeclaration -Tokens (Get-TestToken -Text 'delegate = x;') -Index 0 | Should -BeNullOrEmpty
        Get-DocsCSharpTypeDeclaration -Tokens (Get-TestToken -Text '{ class A }') -Index 1 | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsCSharpMemberChain' {
    It 'follows calls with generic type arguments and stops at a member without a call' {
        $tokens = Get-TestToken -Text 'app.MapGroup("/a").MapHub<ChatHub>("/chat").Name; f(1).Run();'
        $chain = Get-DocsCSharpMemberChain -Tokens $tokens -StartIndex 0
        @($chain['Call'] | ForEach-Object { "$($_['Name'])$($_['TypeArgument']):$($_['Argument'].Count)" }) | Should -Be @('MapGroup:1', 'MapHub<ChatHub>:1')
        $tokens[$chain['EndIndex']]['Text'] | Should -Be ')'
        $callChain = Get-DocsCSharpMemberChain -Tokens $tokens -StartIndex (Find-TestIndex -Token $tokens -Text 'f')
        $tokens[$callChain['ReceiverEnd']]['Text'] | Should -Be ')'
        $callChain['Call'][0]['Name'] | Should -Be 'Run'
        Get-DocsCSharpMemberChain -Tokens $tokens -StartIndex 1 | Should -BeNullOrEmpty
        (Get-DocsCSharpMemberChain -Tokens (Get-TestToken -Text 'a.b<c(') -StartIndex 0)['Call'].Count | Should -Be 0
        (Get-DocsCSharpMemberChain -Tokens (Get-TestToken -Text 'a.b(') -StartIndex 0)['Call'].Count | Should -Be 0
        Get-DocsCSharpMemberChain -Tokens (Get-TestToken -Text 'a(') -StartIndex 0 | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsCSharpStringList' {
    It 'reads a literal, array initializers, collection initializers and collection expressions' {
        $tokens = Get-TestToken -Text '"one" new[] { "a", "b" } new string[] { "c" } new List<string> { "d" } ["e", "f"] new[] { x } { "g" } [] other'
        [object[]] $single = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = 0; End = 0 }
        $single | Should -Be @('one')
        $arrayOpen = Find-TestIndex -Token $tokens -Text 'new'
        [object[]] $array = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $arrayOpen; End = $arrayOpen + 7 }
        $array | Should -Be @('a', 'b')
        $typed = Find-TestIndex -Token $tokens -Text 'new' -Occurrence 2
        [object[]] $typedArray = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $typed; End = $typed + 6 }
        $typedArray | Should -Be @('c')
        $generic = Find-TestIndex -Token $tokens -Text 'new' -Occurrence 3
        [object[]] $genericList = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $generic; End = $generic + 7 }
        $genericList | Should -Be @('d')
        $collection = Find-TestIndex -Token $tokens -Text '[' -Occurrence 3
        [object[]] $collectionList = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $collection; End = $collection + 4 }
        $collectionList | Should -Be @('e', 'f')
        $dynamic = Find-TestIndex -Token $tokens -Text 'new' -Occurrence 4
        Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $dynamic; End = $dynamic + 5 } | Should -BeNullOrEmpty
        $bare = Find-TestIndex -Token $tokens -Text '{' -Occurrence 5
        [object[]] $bareList = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $bare; End = $bare + 2 }
        $bareList | Should -Be @('g')
        $emptyOpen = Find-TestIndex -Token $tokens -Text '[' -Occurrence 4
        [object[]] $emptyList = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $emptyOpen; End = $emptyOpen + 1 }
        $emptyList.Count | Should -Be 0
        Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $tokens.Count - 1; End = $tokens.Count - 1 } | Should -BeNullOrEmpty
        Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $arrayOpen; End = $arrayOpen + 6 } | Should -BeNullOrEmpty
        Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $arrayOpen + 1; End = $arrayOpen + 7 } | Should -BeNullOrEmpty
        [object[]] $bareInitializer = Get-DocsCSharpStringList -Tokens $tokens -Span @{ Start = $arrayOpen + 3; End = $arrayOpen + 7 }
        $bareInitializer | Should -Be @('a', 'b')
    }
}

Describe 'Get-DocsCSharpNamespaceRange and Get-DocsCSharpNamespaceName' {
    It 'finds file-scoped and nested block namespaces and names the enclosing chain' {
        $tokens = Get-TestToken -Text "namespace Outer.Mid { namespace Inner { class A {} } class B {} }"
        [object[]] $ranges = Get-DocsCSharpNamespaceRange -Tokens $tokens
        @($ranges | ForEach-Object { $_['Name'] }) | Should -Be @('Outer.Mid', 'Inner')
        Get-DocsCSharpNamespaceName -Range $ranges -Index (Find-TestIndex -Token $tokens -Text 'A') | Should -Be 'Outer.Mid.Inner'
        Get-DocsCSharpNamespaceName -Range $ranges -Index (Find-TestIndex -Token $tokens -Text 'B') | Should -Be 'Outer.Mid'
        Get-DocsCSharpNamespaceName -Range $ranges -Index 0 | Should -Be ''
        $scoped = Get-TestToken -Text "namespace Scoped;`nclass C {}"
        [object[]] $scopedRanges = Get-DocsCSharpNamespaceRange -Tokens $scoped
        $scopedRanges.Count | Should -Be 1
        Get-DocsCSharpNamespaceName -Range $scopedRanges -Index ($scoped.Count - 1) | Should -Be 'Scoped'
        Get-DocsCSharpNamespaceName -Range $null -Index 0 | Should -Be ''
        [object[]] $none = Get-DocsCSharpNamespaceRange -Tokens (Get-TestToken -Text 'namespace ; namespace { }')
        $none.Count | Should -Be 0
    }
}

Describe 'Get-DocsCSharpParameterScope' {
    It 'scopes method, block-lambda, expression-lambda and single-parameter lambda names' {
        $tokens = Get-TestToken -Text 'static void M(this IEndpointRouteBuilder routes, int n = 2) { routes.Map(); } var f = (int a, string b) => { a.X(); }; var g = (x) => x.Y(), h = y => y.Z(); int q = 1;'
        [object[]] $scopes = Get-DocsCSharpParameterScope -Tokens $tokens
        @($scopes | ForEach-Object { "$($_['Name']):$($tokens[$_['Start']]['Text'])..$($tokens[$_['End']]['Text'])" }) | Should -Be @('routes:{..}', 'n:{..}', 'a:{..}', 'b:{..}', 'x:x..)', 'y:y..)')
        [object[]] $none = Get-DocsCSharpParameterScope -Tokens (Get-TestToken -Text 'f() { } () => 1')
        $none.Count | Should -Be 0
        [object[]] $openEnd = Get-DocsCSharpParameterScope -Tokens (Get-TestToken -Text 'x => x.Y()')
        $openEnd.Count | Should -Be 1
        $openEnd[0]['End'] | Should -Be 6
    }
}
