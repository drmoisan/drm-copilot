#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1 (typescript-exports).

.DESCRIPTION
    An in-memory fixture covering each classified export form yields one public-symbol per
    exported name with the module-path qualified declaration, symbol_kind, type_only, local_name,
    reexport_from and overloads; export * is expanded from a relative in-memory module and a
    re-export cycle stops with TS_REEXPORT_UNRESOLVED; the TS_EXPORT_PATTERN_UNSUPPORTED,
    TS_EXPORT_ASSIGNMENT, TS_AMBIENT_MODULE and TS_COMMONJS_EXPORT codes are emitted; .d.ts and
    .tsx inputs are selected. No file is written and no process is started.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.ScannerTestSupport.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerTypeScriptExports.psm1') -Force -ErrorAction Stop

    function Get-TestElement {
        param([object[]] $Element, [string] $Declaration)
        $found = @($Element | Where-Object { [string] $_['declaration'] -ceq $Declaration })
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
        param([hashtable] $Output)
        [string[]] $declarations = @($Output['Elements'] | ForEach-Object { [string] $_['declaration'] })
        [Array]::Sort($declarations, [System.StringComparer]::Ordinal)
        $declarations
    }

    $script:FormsText = @'
import { Thing } from './thing';
export function plain(a: string): void;
export function plain(a: number): void;
export function plain(a: any) {
  return a;
}
export async function fetchIt() {}
export function* gen() {}
@decorate()
@other
export class Widget extends Base {
  m() {}
}
export abstract class Shape {}
export const one = 1, two = {
  nested: true
};
export let three: number = 3;
export var four;
export const { a, b: bee } = obj;
export const [c, d] = pair;
export const { e = 1, ...rest } = obj;
export const [f, [g]] = deep;
export interface Props {
  x: number;
}
export type Alias = string |
  number;
export enum Color { Red, Green }
export const enum Flags { A = 1 }
export declare const declared: string;
export namespace NS {
  export function inner() {}
  export namespace Deep {
    export const leaf = 1;
  }
  const hidden = 2;
}
export default class {}
function localFn() {}
class LocalClass {}
const localConst = 1;
interface LocalIface {}
export { localFn, LocalClass as Renamed, localConst, LocalIface };
export type { Shape as ShapeType };
export { Thing, Thing as Alias2 } from './thing';
export type { Only } from './thing';
export * as ns from './thing';
export * from './star';
export * from 'some-package';
export * from './missing';
export = Widget;
declare module 'ambient' {
  export const inside: number;
}
declare global {
  interface Window { app: string; }
}
module.exports = localFn;
exports.named = localConst;
'@

    $script:StarText = @'
export const fromStar = 1;
export default function hidden() {}
export namespace StarNs { export const x = 1; }
export * from './second';
'@

    $script:SecondText = @'
export const fromSecond = 2;
export * from './star';
'@
}

AfterAll {
    Remove-Module -Name DocsAnalyzerTypeScriptExports, DocsTypeScriptSyntax, DocsTypeScriptTokens, DocsScannerCommon, Docs.ScannerTestSupport, DocsAnalyzerRegistry, DocsSurface, DocsJson, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerTypeScriptExports' {
    Context 'classified export forms' {
        BeforeAll {
            $script:Output = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput @(
                (New-DocsTestCapturedInput -Path 'src/lib/forms.ts' -Text $script:FormsText),
                (New-DocsTestCapturedInput -Path 'src/lib/star.ts' -Text $script:StarText),
                (New-DocsTestCapturedInput -Path 'src/lib/second.ts' -Text $script:SecondText)
            ) -Selection @{ source_roots = @('src') }
            $script:Element = @($script:Output['Elements'])
            $script:Diagnostic = @($script:Output['Diagnostics'])
        }

        It 'emits functions with merged overloads, async and generator kinds, and classes with decorator ranges' {
            $plain = Get-TestElement -Element $script:Element -Declaration 'lib/forms.plain'
            $plain['kind'] | Should -Be 'public-symbol'
            $plain['name'] | Should -Be 'plain'
            $plain['analyzer_id'] | Should -Be 'typescript-exports'
            $plain['analysis_method'] | Should -Be 'scanner'
            Get-TestProperty -Element $plain -Name 'symbol_kind' | Should -Be 'function'
            Get-TestProperty -Element $plain -Name 'overloads' | Should -Be 2
            $plain['line_range']['start'] | Should -Be 2
            $plain['line_range']['end'] | Should -Be 2
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.fetchIt') -Name 'symbol_kind' | Should -Be 'async-function'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.gen') -Name 'symbol_kind' | Should -Be 'generator'
            $widget = Get-TestElement -Element $script:Element -Declaration 'lib/forms.Widget'
            Get-TestProperty -Element $widget -Name 'symbol_kind' | Should -Be 'class'
            Get-TestProperty -Element $widget -Name 'overloads' | Should -BeNullOrEmpty
            $widget['line_range']['start'] | Should -Be 9
            $widget['line_range']['end'] | Should -Be 11
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.Shape') -Name 'symbol_kind' | Should -Be 'abstract-class'
        }

        It 'emits variables from simple declarators and simple patterns with initializer-start ranges' {
            $one = Get-TestElement -Element $script:Element -Declaration 'lib/forms.one'
            Get-TestProperty -Element $one -Name 'symbol_kind' | Should -Be 'variable'
            $one['line_range']['start'] | Should -Be 15
            $one['line_range']['end'] | Should -Be 15
            $two = Get-TestElement -Element $script:Element -Declaration 'lib/forms.two'
            $two['line_range']['end'] | Should -Be 15
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.three')['line_range']['end'] | Should -Be 18
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.four')['line_range']['end'] | Should -Be 19
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.a')['line_range']['start'] | Should -Be 20
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.bee')['name'] | Should -Be 'bee'
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.c')['line_range']['end'] | Should -Be 21
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.d')['line_range']['end'] | Should -Be 21
            @($script:Element | Where-Object { [string] $_['declaration'] -cin @('lib/forms.e', 'lib/forms.rest', 'lib/forms.f', 'lib/forms.g') }).Count | Should -Be 0
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.declared') -Name 'symbol_kind' | Should -Be 'variable'
        }

        It 'emits interfaces, type aliases, enums and namespaces with whole-construct ranges and nested names' {
            $props = Get-TestElement -Element $script:Element -Declaration 'lib/forms.Props'
            Get-TestProperty -Element $props -Name 'symbol_kind' | Should -Be 'interface'
            $props['line_range']['start'] | Should -Be 24
            $props['line_range']['end'] | Should -Be 26
            $alias = Get-TestElement -Element $script:Element -Declaration 'lib/forms.Alias'
            Get-TestProperty -Element $alias -Name 'symbol_kind' | Should -Be 'type'
            $alias['line_range']['end'] | Should -Be 28
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.Color') -Name 'symbol_kind' | Should -Be 'enum'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.Flags') -Name 'symbol_kind' | Should -Be 'enum'
            $ns = Get-TestElement -Element $script:Element -Declaration 'lib/forms.NS'
            Get-TestProperty -Element $ns -Name 'symbol_kind' | Should -Be 'namespace'
            $ns['line_range']['start'] | Should -Be 32
            $ns['line_range']['end'] | Should -Be 38
            $inner = Get-TestElement -Element $script:Element -Declaration 'lib/forms.NS.inner'
            $inner['name'] | Should -Be 'inner'
            Get-TestProperty -Element $inner -Name 'symbol_kind' | Should -Be 'function'
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.NS.Deep.leaf')['line_range']['start'] | Should -Be 35
            @($script:Element | Where-Object { [string] $_['declaration'] -clike '*hidden*' }).Count | Should -Be 0
        }

        It 'emits default, local export clauses with resolved kinds and aliases, type-only and re-export forms' {
            $default = Get-TestElement -Element $script:Element -Declaration 'lib/forms.default'
            Get-TestProperty -Element $default -Name 'symbol_kind' | Should -Be 'class'
            Get-TestProperty -Element $default -Name 'local_name' | Should -BeNullOrEmpty
            $default['line_range']['start'] | Should -Be 39
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.localFn') -Name 'symbol_kind' | Should -Be 'function'
            $renamed = Get-TestElement -Element $script:Element -Declaration 'lib/forms.Renamed'
            Get-TestProperty -Element $renamed -Name 'symbol_kind' | Should -Be 'class'
            Get-TestProperty -Element $renamed -Name 'local_name' | Should -Be 'LocalClass'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.localConst') -Name 'symbol_kind' | Should -Be 'variable'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.LocalIface') -Name 'symbol_kind' | Should -Be 'interface'
            $shapeType = Get-TestElement -Element $script:Element -Declaration 'lib/forms.ShapeType'
            Get-TestProperty -Element $shapeType -Name 'type_only' | Should -BeTrue
            Get-TestProperty -Element $shapeType -Name 'local_name' | Should -Be 'Shape'
            $thing = Get-TestElement -Element $script:Element -Declaration 'lib/forms.Thing'
            Get-TestProperty -Element $thing -Name 'symbol_kind' | Should -Be 'reexport'
            Get-TestProperty -Element $thing -Name 'reexport_from' | Should -Be './thing'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.Alias2') -Name 'local_name' | Should -Be 'Thing'
            $only = Get-TestElement -Element $script:Element -Declaration 'lib/forms.Only'
            Get-TestProperty -Element $only -Name 'type_only' | Should -BeTrue
            Get-TestProperty -Element $only -Name 'reexport_from' | Should -Be './thing'
            $namespaceReexport = Get-TestElement -Element $script:Element -Declaration 'lib/forms.ns'
            Get-TestProperty -Element $namespaceReexport -Name 'symbol_kind' | Should -Be 'reexport'
            Get-TestProperty -Element $namespaceReexport -Name 'reexport_from' | Should -Be './thing'
        }

        It 'expands export * from a captured relative module, stops at the cycle, and reports unresolvable specifiers' {
            $fromStar = Get-TestElement -Element $script:Element -Declaration 'lib/forms.fromStar'
            Get-TestProperty -Element $fromStar -Name 'symbol_kind' | Should -Be 'reexport'
            Get-TestProperty -Element $fromStar -Name 'reexport_from' | Should -Be './star'
            $fromStar['line_range']['start'] | Should -Be 49
            (Get-TestElement -Element $script:Element -Declaration 'lib/forms.fromSecond')['path'] | Should -Be 'src/lib/forms.ts'
            Get-TestProperty -Element (Get-TestElement -Element $script:Element -Declaration 'lib/forms.StarNs') -Name 'reexport_from' | Should -Be './star'
            @($script:Element | Where-Object { [string] $_['declaration'] -cin @('lib/forms.hidden', 'lib/forms.StarNs.x') }).Count | Should -Be 0
            (Get-TestElement -Element $script:Element -Declaration 'lib/star.fromSecond')['path'] | Should -Be 'src/lib/star.ts'
            (Get-TestElement -Element $script:Element -Declaration 'lib/second.fromStar')['path'] | Should -Be 'src/lib/second.ts'
            @($script:Element | Where-Object { [string] $_['declaration'] -ceq 'lib/second.fromSecond' }).Count | Should -Be 1
            $formsUnresolved = @($script:Diagnostic | Where-Object { [string] $_['code'] -ceq 'TS_REEXPORT_UNRESOLVED' -and [string] $_['path'] -ceq 'src/lib/forms.ts' })
            $formsUnresolved.Count | Should -Be 1
            $formsUnresolved[0]['message'] | Should -Match '3 occurrence'
            $formsUnresolved[0]['message'] | Should -Match 'line 49'
            $formsUnresolved[0]['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'public-symbol'
            $starCycle = @($script:Diagnostic | Where-Object { [string] $_['code'] -ceq 'TS_REEXPORT_UNRESOLVED' -and [string] $_['path'] -ceq 'src/lib/star.ts' })
            $starCycle.Count | Should -Be 1
            $starCycle[0]['message'] | Should -Match '1 occurrence'
            $starCycle[0]['message'] | Should -Match 'line 4'
            @($script:Diagnostic | Where-Object { [string] $_['code'] -ceq 'TS_REEXPORT_UNRESOLVED' -and [string] $_['path'] -ceq 'src/lib/second.ts' }).Count | Should -Be 1
        }

        It 'reports unsupported patterns, export assignment, ambient modules and CommonJS exports with the marker' {
            $pattern = Get-TestDiagnostic -Diagnostic $script:Diagnostic -Code 'TS_EXPORT_PATTERN_UNSUPPORTED'
            $pattern['message'] | Should -Match '2 occurrence'
            $pattern['message'] | Should -Match 'line 22'
            $pattern['severity'] | Should -Be 'warning'
            $pattern['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'public-symbol'
            $assignment = Get-TestDiagnostic -Diagnostic $script:Diagnostic -Code 'TS_EXPORT_ASSIGNMENT'
            $assignment['message'] | Should -Match 'line 52'
            $assigned = @($script:Element | Where-Object { [string] $_['declaration'] -ceq 'lib/forms.default' -and (Get-TestProperty -Element $_ -Name 'export_form') -ceq 'assignment' })
            $assigned.Count | Should -Be 0
            $duplicate = Get-TestDiagnostic -Diagnostic $script:Diagnostic -Code 'DUPLICATE_DECLARATION'
            $duplicate['message'] | Should -Match 'line 52'
            $duplicate['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            $ambient = Get-TestDiagnostic -Diagnostic $script:Diagnostic -Code 'TS_AMBIENT_MODULE'
            $ambient['message'] | Should -Match '2 occurrence'
            $ambient['message'] | Should -Match 'line 53'
            @($script:Element | Where-Object { [string] $_['declaration'] -clike '*inside*' }).Count | Should -Be 0
            $commonJs = Get-TestDiagnostic -Diagnostic $script:Diagnostic -Code 'TS_COMMONJS_EXPORT'
            $commonJs['message'] | Should -Match '2 occurrence'
            $commonJs['message'] | Should -Match 'line 59'
            $script:Diagnostic.Count | Should -Be 8
        }

        It 'orders elements by element_id and qualifies declarations by the module path' {
            [string[]] $ids = @($script:Element | ForEach-Object { [string] $_['element_id'] })
            [string[]] $sortedIds = [string[]] $ids.Clone()
            [Array]::Sort($sortedIds, [System.StringComparer]::Ordinal)
            $ids | Should -Be $sortedIds
            @($script:Element | Where-Object { [string] $_['path'] -ceq 'src/lib/forms.ts' } | ForEach-Object { ([string] $_['declaration']).StartsWith('lib/forms.') } | Where-Object { -not $_ }).Count | Should -Be 0
            $script:Element.Count | Should -Be 43
        }
    }

    Context 'export assignment element, selection, bounds and duplicates' {
        It 'emits the default element with export_form assignment and a local name for export =' {
            $output = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput @(New-DocsTestCapturedInput -Path 'legacy.ts' -Text "class Api {}`nexport = Api;") -Selection $null
            $default = Get-TestElement -Element @($output['Elements']) -Declaration 'legacy.default'
            Get-TestProperty -Element $default -Name 'export_form' | Should -Be 'assignment'
            Get-TestProperty -Element $default -Name 'local_name' | Should -Be 'Api'
            Get-TestProperty -Element $default -Name 'symbol_kind' | Should -Be 'variable'
            $default['line_range']['start'] | Should -Be 2
            (Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'TS_EXPORT_ASSIGNMENT')['extensions']['docs.precision-limit']['element_kind'] | Should -Be 'public-symbol'
        }

        It 'selects .d.ts, .tsx, .mts and .cts inputs and tokenizes .tsx with the JSX state' {
            $inputs = @(
                (New-DocsTestCapturedInput -Path 'types.d.ts' -Text "export declare function fn(a: string): void;`nexport declare function fn(a: number): void;`ndeclare const hidden: number;`nexport { hidden };"),
                (New-DocsTestCapturedInput -Path 'view.tsx' -Text "export const View = () => <div className='x'>it's text</div>;`nexport default View;"),
                (New-DocsTestCapturedInput -Path 'm.mts' -Text "export const m = 1;"),
                (New-DocsTestCapturedInput -Path 'c.cts' -Text "export const c = 1;"),
                (New-DocsTestCapturedInput -Path 'skip.js' -Text "export const js = 1;")
            )
            $output = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput $inputs -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('c.c', 'm.m', 'types.d.fn', 'types.d.hidden', 'view.View', 'view.default')
            $fn = Get-TestElement -Element @($output['Elements']) -Declaration 'types.d.fn'
            Get-TestProperty -Element $fn -Name 'overloads' | Should -Be 2
            Get-TestProperty -Element (Get-TestElement -Element @($output['Elements']) -Declaration 'types.d.hidden') -Name 'symbol_kind' | Should -Be 'variable'
            $viewDefault = Get-TestElement -Element @($output['Elements']) -Declaration 'view.default'
            Get-TestProperty -Element $viewDefault -Name 'local_name' | Should -Be 'View'
            Get-TestProperty -Element $viewDefault -Name 'symbol_kind' | Should -Be 'variable'
            $output['Diagnostics'].Count | Should -Be 0
        }

        It 'returns no element and no diagnostic for an empty input set, an empty file and a file without exports' {
            $empty = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput @() -Selection $null
            $empty['Elements'].Count | Should -Be 0
            $empty['Diagnostics'].Count | Should -Be 0
            $plain = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput @((New-DocsTestCapturedInput -Path 'x.ts' -Text ''), (New-DocsTestCapturedInput -Path 'y.ts' -Text "const a = 1;`nfunction f() { return a; }")) -Selection $null
            $plain['Elements'].Count | Should -Be 0
            $plain['Diagnostics'].Count | Should -Be 0
        }

        It 'reports oversize, undecodable and lexically invalid inputs as blocking and keeps other files' {
            $inputs = @(
                (New-DocsTestOversizeInput -Path 'big.ts'),
                (New-DocsTestUndecodableInput -Path 'bad.ts'),
                (New-DocsTestCapturedInput -Path 'lex.ts' -Text "export const s = 'unterminated"),
                (New-DocsTestCapturedInput -Path 'ok.ts' -Text "export const fine = 1;")
            )
            $output = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput $inputs -Selection $null
            Get-TestDeclaration -Output $output | Should -Be @('ok.fine')
            foreach ($code in @('INPUT_OVER_BOUND', 'INPUT_UNDECODABLE', 'TS_LEXICAL_INVALID')) {
                $diagnostic = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code $code
                $diagnostic['blocking'] | Should -BeTrue
                $diagnostic['extensions'].Contains('docs.precision-limit') | Should -BeFalse
            }
            $output['Diagnostics'].Count | Should -Be 3
        }

        It 'reports a name exported twice as DUPLICATE_DECLARATION keeping the first site' {
            $output = Invoke-DocsAnalyzerTypeScriptExports -CapturedInput @(New-DocsTestCapturedInput -Path 'dup.ts' -Text "export const a = 1;`nexport { a };") -Selection $null
            (Get-TestElement -Element @($output['Elements']) -Declaration 'dup.a')['line_range']['start'] | Should -Be 1
            $duplicate = Get-TestDiagnostic -Diagnostic @($output['Diagnostics']) -Code 'DUPLICATE_DECLARATION'
            $duplicate['message'] | Should -Match 'line 2'
            $duplicate['blocking'] | Should -BeFalse
        }

        It 'throws for a null captured-input list' {
            { Invoke-DocsAnalyzerTypeScriptExports -CapturedInput $null -Selection $null } | Should -Throw
        }
    }
}
