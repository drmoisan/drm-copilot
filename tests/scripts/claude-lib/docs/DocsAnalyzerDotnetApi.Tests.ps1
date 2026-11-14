#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerDotnetApi.psm1 (dotnet-public-api).

.DESCRIPTION
    In-memory C# fixtures yield the expected public-symbol elements for public types
    (file-scoped and block namespaces, nested types by effective accessibility, generics with
    source-spelled type parameters, a partial type split across two in-memory paths) and members
    (overloads with distinct declarations, constructors, indexers, operators and conversion
    operators, events, constants, enum members, positional record parameters), the accessibility
    values, no element for internal, private, private protected, file and explicit interface
    implementations, and the DUPLICATE_DECLARATION, CSHARP_DECLARATION_UNRECOGNIZED and
    CSHARP_CONDITIONAL_COMPILATION codes. No file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerDotnetApi.psm1') -Force -ErrorAction Stop

    function Get-TestElement {
        param([object[]] $Element, [string] $Declaration, [string] $Path)
        $found = @($Element | Where-Object { [string] $_['declaration'] -ceq $Declaration -and ([string]::IsNullOrEmpty($Path) -or [string] $_['path'] -ceq $Path) })
        $found.Count | Should -Be 1 -Because "exactly one element '$Declaration' is expected"
        $found[0]
    }

    function Get-TestProperty {
        param([System.Collections.IDictionary] $Element, [string] $Name)
        $found = @($Element['properties'] | Where-Object { [string] $_['name'] -ceq $Name })
        if ($found.Count -eq 0) { return $null }
        $found[0]['value']
    }

    function Get-TestDiagnostic {
        param([object[]] $Diagnostic, [string] $Code)
        $found = @($Diagnostic | Where-Object { [string] $_['code'] -ceq $Code })
        $found.Count | Should -Be 1 -Because "exactly one '$Code' diagnostic is expected"
        $found[0]
    }

    function Get-TestDeclaration {
        param([hashtable] $Output, [string] $Path)
        [string[]] $declarations = @($Output['Elements'] | Where-Object { [string]::IsNullOrEmpty($Path) -or [string] $_['path'] -ceq $Path } | ForEach-Object { [string] $_['declaration'] })
        [Array]::Sort($declarations, [System.StringComparer]::Ordinal)
        $declarations
    }

    $script:LibraryText = @'
using System;

namespace Acme.Data;

[Serializable]
public class Repository<T> : IRepository<T> where T : class
{
    public const int MaxItems = 100;
    public static readonly string Tag = "repo", Alt;
    protected int count;
    internal int hidden;
    private int secret;
    private protected int both;
    public event EventHandler<T> Changed;

    public Repository() { }
    public Repository(int capacity) : this() { }
    static Repository() { }

    public T Find<TKey>(TKey key) => default;
    public T Find(int id, out string name) { name = null; return default; }
    public void Add(params T[] items) { }
    protected virtual void OnChanged() { }
    protected internal async System.Threading.Tasks.Task<int> CountAsync() => 0;
    public string Name { get; set; } = "n";
    public T this[int index] => default;
    public T this[string key, int slot] { get => default; }
    void IRepository<T>.Clear() { }
    int IRepository<T>.this[int i] => 0;
    public static Repository<T> operator +(Repository<T> a, Repository<T> b) => a;
    public static implicit operator int(Repository<T> r) => 0;
    public static explicit operator Repository<T>(int count) => null;

    public class Nested
    {
        public int Depth { get; }
        private class Hidden { public int X; }
    }
    internal class Internal { public int Y; }
}

public record Person(string Name, int Age) : Entity
{
    public string Display => Name;
}

public readonly record struct Point(int X, int Y);
public struct Size { public int Width; }
public interface IRepository<T>
{
    void Clear();
    T this[int i] { get; }
    static abstract int Version { get; }
}
public enum Color { Red, [Obsolete] Green = 2, Blue }
public delegate int Op(int a, int b);
internal class Helper { public int Z; }
file class Local { public int W; }
class Plain { public int V; }
'@

    $script:BlockText = @'
namespace Outer
{
    namespace Inner
    {
        public partial class Widget
        {
            public void First() { }
        }
    }
    public static class Util
    {
        public static int Twice(int x) => x * 2;
        public static int Twice(long x) => (int) x;
        public broken = 1;
    }
}
'@

    $script:PartialText = @'
namespace Outer.Inner
{
    public partial class Widget
    {
        public void Second() { }
    }
}
'@
}

AfterAll {
    Remove-Module -Name DocsAnalyzerDotnetApi, DocsCSharpMember, DocsCSharpSyntax, DocsCSharpTokens, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerDotnetApi' {
    Context 'public types and members' {
        BeforeAll {
            $script:Output = Invoke-DocsAnalyzerDotnetApi -CapturedInput @(New-DocsTestCapturedInput -Path 'src/Library.cs' -Text $script:LibraryText) -Selection $null
            $script:Element = @($script:Output['Elements'])
        }

        It 'emits public types in a file-scoped namespace with generics, nested types by effective accessibility, and type ranges' {
            $repo = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>'
            $repo['kind'] | Should -Be 'public-symbol'
            $repo['name'] | Should -Be 'Repository'
            $repo['parent_id'] | Should -BeNullOrEmpty
            $repo['analyzer_id'] | Should -Be 'dotnet-public-api'
            $repo['analysis_method'] | Should -Be 'scanner'
            Get-TestProperty -Element $repo -Name 'symbol_kind' | Should -Be 'class'
            Get-TestProperty -Element $repo -Name 'accessibility' | Should -Be 'public'
            Get-TestProperty -Element $repo -Name 'partial_parts' | Should -BeNullOrEmpty
            $repo['line_range']['start'] | Should -Be 5
            $repo['line_range']['end'] | Should -Be 7
            $nested = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Nested'
            Get-TestProperty -Element $nested -Name 'symbol_kind' | Should -Be 'class'
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Nested.Depth')['parent_id'] | Should -Be $nested['element_id']
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Person') -Name 'symbol_kind' | Should -Be 'record'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Point') -Name 'symbol_kind' | Should -Be 'record'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Size') -Name 'symbol_kind' | Should -Be 'struct'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.IRepository<T>') -Name 'symbol_kind' | Should -Be 'interface'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Color') -Name 'symbol_kind' | Should -Be 'enum'
            $op = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Op'
            Get-TestProperty -Element $op -Name 'symbol_kind' | Should -Be 'delegate'
            $op['line_range']['start'] | Should -Be 56
            $op['line_range']['end'] | Should -Be 56
            @($script:Element | Where-Object { [string] $_['declaration'] -clike '*Hidden*' -or [string] $_['declaration'] -clike '*Internal*' -or [string] $_['declaration'] -clike '*Helper*' -or [string] $_['declaration'] -clike '*Local*' -or [string] $_['declaration'] -clike '*Plain*' }).Count | Should -Be 0
        }

        It 'emits overloads, constructors, indexers, operators, conversion operators, events, constants and fields with distinct declarations' {
            $repo = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>'
            $generic = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Find<TKey>(TKey)'
            $generic['name'] | Should -Be 'Find'
            $generic['parent_id'] | Should -Be $repo['element_id']
            Get-TestProperty -Element $generic -Name 'symbol_kind' | Should -Be 'method'
            Get-TestProperty -Element $generic -Name 'accessibility' | Should -Be 'public'
            $generic['line_range']['start'] | Should -Be 20
            $generic['line_range']['end'] | Should -Be 20
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Find(int,out string)')['line_range']['end'] | Should -Be 21
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Add(params T[])')['name'] | Should -Be 'Add'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Repository()') -Name 'symbol_kind' | Should -Be 'constructor'
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Repository(int)')['name'] | Should -Be 'Repository'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.this[int]') -Name 'symbol_kind' | Should -Be 'indexer'
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.this[string,int]')['name'] | Should -Be 'this'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.operator+(Repository<T>,Repository<T>)') -Name 'symbol_kind' | Should -Be 'operator'
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.implicit operator int(Repository<T>)')['name'] | Should -Be 'implicit operator int'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.explicit operator Repository<T>(int)') -Name 'symbol_kind' | Should -Be 'operator'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Changed') -Name 'symbol_kind' | Should -Be 'event'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.MaxItems') -Name 'symbol_kind' | Should -Be 'constant'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Tag') -Name 'symbol_kind' | Should -Be 'field'
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Alt')['line_range']['start'] | Should -Be 9
            $name = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.Name'
            Get-TestProperty -Element $name -Name 'symbol_kind' | Should -Be 'property'
            $name['line_range']['end'] | Should -Be 25
        }

        It 'records protected and protected internal accessibility, interface members, enum members and positional record parameters, and excludes the rest' {
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.count') -Name 'accessibility' | Should -Be 'protected'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.OnChanged()') -Name 'accessibility' | Should -Be 'protected'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Repository<T>.CountAsync()') -Name 'accessibility' | Should -Be 'protected internal'
            @($script:Element | Where-Object { [string] $_['declaration'] -cin @('Acme.Data.Repository<T>.hidden', 'Acme.Data.Repository<T>.secret', 'Acme.Data.Repository<T>.both', 'Acme.Data.Repository<T>.Clear()', 'Acme.Data.Repository<T>.IRepository<T>.Clear()') }).Count | Should -Be 0
            @($script:Element | Where-Object { [string] $_['declaration'] -clike 'Acme.Data.Repository<T>.*' -and [string] $_['name'] -ceq 'Repository' }).Count | Should -Be 2
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.IRepository<T>.Clear()') -Name 'accessibility' | Should -Be 'public'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.IRepository<T>.this[int]') -Name 'symbol_kind' | Should -Be 'indexer'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.IRepository<T>.Version') -Name 'symbol_kind' | Should -Be 'property'
            $green = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Color.Green'
            Get-TestProperty -Element $green -Name 'symbol_kind' | Should -Be 'enum-member'
            $green['line_range']['start'] | Should -Be 55
            Get-TestDeclaration -Output $script:Output | Where-Object { $_ -clike 'Acme.Data.Color*' } | Should -Be @('Acme.Data.Color', 'Acme.Data.Color.Blue', 'Acme.Data.Color.Green', 'Acme.Data.Color.Red')
            $personName = Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Person.Name'
            Get-TestProperty -Element $personName -Name 'symbol_kind' | Should -Be 'property'
            $personName['line_range']['start'] | Should -Be 42
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Person.Display')['name'] | Should -Be 'Display'
            Get-TestDeclaration -Output $script:Output | Where-Object { $_ -clike 'Acme.Data.Point*' } | Should -Be @('Acme.Data.Point', 'Acme.Data.Point.X', 'Acme.Data.Point.Y')
            @($script:Element | Where-Object { [string] $_['declaration'] -clike 'Acme.Data.Op.*' }).Count | Should -Be 0
            (Get-TestElement -Element $script:Element -Declaration 'Acme.Data.Size.Width')['name'] | Should -Be 'Width'
            $script:Output['Diagnostics'].Count | Should -Be 0
            [string[]] $ids = @($script:Element | ForEach-Object { [string] $_['element_id'] })
            [string[]] $sortedIds = [string[]] $ids.Clone()
            [Array]::Sort($sortedIds, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sortedIds
        }
    }

    Context 'block namespaces, partial types and diagnostics' {
        BeforeAll {
            $script:PartialOutput = Invoke-DocsAnalyzerDotnetApi -CapturedInput @(
                (New-DocsTestCapturedInput -Path 'src/b/Widget.Second.cs' -Text $script:PartialText),
                (New-DocsTestCapturedInput -Path 'src/a/Widget.First.cs' -Text $script:BlockText)
            ) -Selection $null
            $script:PartialElement = @($script:PartialOutput['Elements'])
        }

        It 'qualifies nested block namespaces, emits one partial type element at the ordinally first path and members in their own files' {
            $widget = Get-TestElement -Element $script:PartialElement -Declaration 'Outer.Inner.Widget'
            $widget['path'] | Should -Be 'src/a/Widget.First.cs'
            Get-TestProperty -Element $widget -Name 'partial_parts' | Should -Be 2
            $widget['line_range']['start'] | Should -Be 5
            $widget['line_range']['end'] | Should -Be 6
            $first = Get-TestElement -Element $script:PartialElement -Declaration 'Outer.Inner.Widget.First()'
            $first['path'] | Should -Be 'src/a/Widget.First.cs'
            $first['parent_id'] | Should -Be $widget['element_id']
            $second = Get-TestElement -Element $script:PartialElement -Declaration 'Outer.Inner.Widget.Second()'
            $second['path'] | Should -Be 'src/b/Widget.Second.cs'
            $second['parent_id'] | Should -Be $widget['element_id']
            Get-TestDeclaration -Output $script:PartialOutput -Path 'src/b/Widget.Second.cs' | Should -Be @('Outer.Inner.Widget.Second()')
            (Get-TestElement -Element $script:PartialElement -Declaration 'Outer.Util.Twice(int)')['name'] | Should -Be 'Twice'
            (Get-TestElement -Element $script:PartialElement -Declaration 'Outer.Util.Twice(long)')['line_range']['start'] | Should -Be 13
        }

        It 'reports a declaration it cannot delimit as CSHARP_DECLARATION_UNRECOGNIZED with the marker and no element' {
            $unrecognized = Get-TestDiagnostic -Diagnostic @($script:PartialOutput['Diagnostics']) -Code 'CSHARP_DECLARATION_UNRECOGNIZED'
            $unrecognized['path'] | Should -Be 'src/a/Widget.First.cs'
            $unrecognized['message'] | Should -Match 'line 14'
            $unrecognized['severity'] | Should -Be 'warning'
            $unrecognized['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'public-symbol'
            @($script:PartialElement | Where-Object { [string] $_['declaration'] -clike '*broken*' }).Count | Should -Be 0
            $script:PartialOutput['Diagnostics'].Count | Should -Be 1
        }

        It 'scans both #if branches, reports CSHARP_CONDITIONAL_COMPILATION and the repeated member as DUPLICATE_DECLARATION' {
            $text = "namespace N;`npublic class C`n{`n#if DEBUG`n    public int A;`n#else`n    public int A;`n#endif`n}"
            $output = Invoke-DocsAnalyzerDotnetApi -CapturedInput @(New-DocsTestCapturedInput -Path 'cond.cs' -Text $text) -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('N.C', 'N.C.A')
            (Get-TestElement -Element @($output['Elements']) -Declaration 'N.C.A')['line_range']['start'] | Should -Be 5
            $conditional = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'CSHARP_CONDITIONAL_COMPILATION'
            $conditional['message'] | Should -Match 'line 4'
            $conditional['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'public-symbol'
            $duplicate = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'DUPLICATE_DECLARATION'
            $duplicate['message'] | Should -Match 'line 7'
            $duplicate['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            $output['Diagnostics'].Count | Should -Be 2
        }
    }

    Context 'selection, bounds and empty inputs' {
        It 'selects only .cs inputs and returns nothing for an empty set, an empty file and a file without public types' {
            $empty = Invoke-DocsAnalyzerDotnetApi -CapturedInput @() -Selection $null
            $empty['Elements'].Count | Should -Be 0
            $empty['Diagnostics'].Count | Should -Be 0
            $plain = Invoke-DocsAnalyzerDotnetApi -CapturedInput @((New-DocsTestCapturedInput -Path 'x.cs' -Text ''), (New-DocsTestCapturedInput -Path 'y.cs' -Text "internal class S { public int A; }"), (New-DocsTestCapturedInput -Path 'z.ts' -Text 'export class T {}')) -Selection @{ source_roots = @('src') }
            $plain['Elements'].Count | Should -Be 0
            $plain['Diagnostics'].Count | Should -Be 0
        }

        It 'reports oversize, undecodable and lexically invalid inputs as blocking and keeps other files' {
            $inputs = @(
                (New-DocsTestOversizeInput -Path 'big.cs'),
                (New-DocsTestUndecodableInput -Path 'bad.cs'),
                (New-DocsTestCapturedInput -Path 'lex.cs' -Text "public class L { } var s = `"unterminated"),
                (New-DocsTestCapturedInput -Path 'ok.cs' -Text "public class Fine { }")
            )
            $output = Invoke-DocsAnalyzerDotnetApi -CapturedInput $inputs -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('Fine')
            foreach ($code in @('INPUT_OVER_BOUND', 'INPUT_UNDECODABLE', 'CSHARP_LEXICAL_INVALID')) {
                $diagnostic = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code $code
                $diagnostic['blocking'] | Should -BeTrue
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            $output['Diagnostics'].Count | Should -Be 3
        }

        It 'throws for a null captured-input list' {
            { Invoke-DocsAnalyzerDotnetApi -CapturedInput $null -Selection $null } | Should -Throw
        }
    }
}
