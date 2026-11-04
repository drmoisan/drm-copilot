#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsCSharpMember.psm1.

.DESCRIPTION
    Covers accessibility from modifiers (including implicit public for interface members),
    parameter-text spelling with ref, out, in and params, one member declaration of every
    kind (constructor, method, property, indexer, field, constant, event, operator, conversion
    operator), explicit interface implementations, unrecognized headers, body skipping and enum
    members with attributes and initializers. Fixtures are in-memory strings; no file is
    written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsCSharpTokens.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsCSharpMember.psm1') -Force -ErrorAction Stop

    function Get-TestToken {
        param([string] $Text)
        $result = ConvertTo-DocsCSharpToken -Text $Text
        $result['Diagnostics'].Count | Should -Be 0
        , [object[]] $result['Tokens']
    }

    function Get-TestMemberSummary {
        param([string] $Text, [string] $TypeName = 'T', [switch] $ImplicitPublic)
        $tokens = Get-TestToken -Text $Text
        $member = Get-DocsCSharpMember -Tokens $tokens -Index 0 -End ($tokens.Count - 1) -TypeName $TypeName -ImplicitPublic:$ImplicitPublic
        @{ Summary = @($member['Member'] | ForEach-Object { "$($_['Kind'])|$($_['Declaration'])|$($_['Name'])|$($_['Accessibility'])|$($_['Line'])-$($_['EndLine'])" }); NextText = $(if ($member['NextIndex'] -lt $tokens.Count) { [string] $tokens[$member['NextIndex']]['Text'] } else { '<end>' }); Unrecognized = $member['Unrecognized'] }
    }
}

AfterAll {
    Remove-Module -Name DocsCSharpMember, DocsCSharpSyntax, DocsCSharpTokens, DocsScannerCommon, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsCSharpAccessibility and ConvertTo-DocsCSharpParameterText' {
    It 'maps modifier lists to the public surface values and excludes the rest' {
        Get-DocsCSharpAccessibility -Modifier @('public', 'static') | Should -Be 'public'
        Get-DocsCSharpAccessibility -Modifier @('protected') | Should -Be 'protected'
        Get-DocsCSharpAccessibility -Modifier @('internal', 'protected') | Should -Be 'protected internal'
        Get-DocsCSharpAccessibility -Modifier @('private', 'protected') | Should -BeNullOrEmpty
        Get-DocsCSharpAccessibility -Modifier @('private') | Should -BeNullOrEmpty
        Get-DocsCSharpAccessibility -Modifier @('internal') | Should -BeNullOrEmpty
        Get-DocsCSharpAccessibility -Modifier @('file') | Should -BeNullOrEmpty
        Get-DocsCSharpAccessibility -Modifier @() | Should -BeNullOrEmpty
        Get-DocsCSharpAccessibility -Modifier @('static') -ImplicitPublic | Should -Be 'public'
        Get-DocsCSharpAccessibility -Modifier @('private') -ImplicitPublic | Should -BeNullOrEmpty
    }

    It 'spells parameter lists with modifiers kept and names dropped' {
        ConvertTo-DocsCSharpParameterText -Parameter @() | Should -Be '()'
        ConvertTo-DocsCSharpParameterText -Parameter @(@{ Modifier = $null; Type = 'int'; Name = 'a' }, @{ Modifier = 'ref'; Type = 'T'; Name = 'b' }, @{ Modifier = 'out'; Type = 'string'; Name = 'c' }, @{ Modifier = 'in'; Type = 'Point'; Name = 'd' }, @{ Modifier = 'params'; Type = 'int[]'; Name = 'e' }, @{ Modifier = 'this'; Type = 'X'; Name = 'f' }, @{ Modifier = $null; Type = $null; Name = 'T' }) | Should -Be '(int,ref T,out string,in Point,params int[],X,T)'
    }
}

Describe 'Get-DocsCSharpMember' {
    It 'reads each member kind with its declaration, name, accessibility and lines' {
        $cases = @(
            @{ Text = "public T() { }"; Expected = 'constructor|T()|T|public|1-1'; Next = '<end>' },
            @{ Text = "public T(int a, string b) : base(a) { } int tail;"; Expected = 'constructor|T(int,string)|T|public|1-1'; Next = 'int' },
            @{ Text = "[Obsolete]`npublic static T Find<TKey>(TKey key) where TKey : class`n{ return null; } next"; Expected = 'method|Find<TKey>(TKey)|Find|public|1-3'; Next = 'next' },
            @{ Text = "protected abstract void M(ref int a, out string b, params object[] c);"; Expected = 'method|M(ref int,out string,params object[])|M|protected|1-1'; Next = '<end>' },
            @{ Text = "public string Name { get; set; } = `"x`"; int tail;"; Expected = 'property|Name|Name|public|1-1'; Next = 'int' },
            @{ Text = "public int Count => 1; int tail;"; Expected = 'property|Count|Count|public|1-1'; Next = 'int' },
            @{ Text = "public T this[int i, string k] => default;"; Expected = 'indexer|this[int,string]|this|public|1-1'; Next = '<end>' },
            @{ Text = "public int A = 1, B, C = f(2, 3);"; Expected = @('field|A|A|public|1-1', 'field|B|B|public|1-1', 'field|C|C|public|1-1'); Next = '<end>' },
            @{ Text = "public const int Max = 10;"; Expected = 'constant|Max|Max|public|1-1'; Next = '<end>' },
            @{ Text = "public event EventHandler<int> Changed, Other;"; Expected = @('event|Changed|Changed|public|1-1', 'event|Other|Other|public|1-1'); Next = '<end>' },
            @{ Text = "public event Action E { add { } remove { } } int tail;"; Expected = 'event|E|E|public|1-1'; Next = 'int' },
            @{ Text = "public static T operator +(T a, T b) => a;"; Expected = 'operator|operator+(T,T)|operator+|public|1-1'; Next = '<end>' },
            @{ Text = "public static bool operator ==(T a, T b) => true;"; Expected = 'operator|operator==(T,T)|operator==|public|1-1'; Next = '<end>' },
            @{ Text = "public static implicit operator int(T r) => 0;"; Expected = 'operator|implicit operator int(T)|implicit operator int|public|1-1'; Next = '<end>' },
            @{ Text = "public static explicit operator List<int>(T r) { return null; }"; Expected = 'operator|explicit operator List<int>(T)|explicit operator List<int>|public|1-1'; Next = '<end>' },
            @{ Text = "private int secret;"; Expected = 'field|secret|secret||1-1'; Next = '<end>' },
            @{ Text = "protected internal async Task<int> CountAsync() => 0;"; Expected = 'method|CountAsync()|CountAsync|protected internal|1-1'; Next = '<end>' }
        )
        foreach ($case in $cases) {
            $result = Get-TestMemberSummary -Text $case['Text']
            $result['Unrecognized'] | Should -BeFalse -Because $case['Text']
            $result['Summary'] | Should -Be $case['Expected'] -Because $case['Text']
            $result['NextText'] | Should -Be $case['Next'] -Because $case['Text']
        }
    }

    It 'marks interface members public, skips explicit interface implementations and reports unrecognized headers' {
        $interfaceMember = Get-TestMemberSummary -Text 'void Clear();' -ImplicitPublic
        $interfaceMember['Summary'] | Should -Be @('method|Clear()|Clear|public|1-1')
        $explicit = Get-TestMemberSummary -Text 'void IRepo<T>.Clear() { } int tail;'
        $explicit['Summary'].Count | Should -Be 0
        $explicit['Unrecognized'] | Should -BeFalse
        $explicit['NextText'] | Should -Be 'int'
        foreach ($text in @('public broken( = 1;', 'public', 'public event = 3;', 'public static implicit operator { }', 'public static int operator', 'public int Name<T { }', 'public = 1;', 'public int 5;')) {
            $result = Get-TestMemberSummary -Text $text
            $result['Unrecognized'] | Should -BeTrue -Because $text
            $result['Summary'].Count | Should -Be 0 -Because $text
        }
        $noEnd = Get-TestMemberSummary -Text 'public int A'
        $noEnd['Unrecognized'] | Should -BeTrue
        $noEnd['NextText'] | Should -Be '<end>'
        $openBlock = Get-TestMemberSummary -Text 'public void M() {'
        $openBlock['Summary'] | Should -Be @('method|M()|M|public|1-1')
        $openBlock['NextText'] | Should -Be '<end>'
    }
}

Describe 'Get-DocsCSharpEnumMember' {
    It 'reads enum members with attributes and initializers' {
        $tokens = Get-TestToken -Text 'Red, [Obsolete("x")] Green = 2, Blue = Red | Green, Last,'
        [object[]] $members = Get-DocsCSharpEnumMember -Tokens $tokens -Start 0 -End ($tokens.Count - 1)
        @($members | ForEach-Object { "$($_['Name'])@$($_['Line'])" }) | Should -Be @('Red@1', 'Green@1', 'Blue@1', 'Last@1')
        [object[]] $none = Get-DocsCSharpEnumMember -Tokens $tokens -Start 5 -End 4
        $none.Count | Should -Be 0
    }
}
