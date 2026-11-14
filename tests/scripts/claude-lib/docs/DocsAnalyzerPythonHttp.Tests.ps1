#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerPythonHttp.psm1 (issue #1022).

.DESCRIPTION
    Compares the python-http analyzer output with the python-http subset of the committed corpus
    tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json on every element field and
    every diagnostic; asserts the declaration GET <dynamic>/items/{item_id} with prefix_resolved
    false and HTTP_PREFIX_DYNAMIC, one element per method, FastAPI and Flask template
    composition, include depth and cycle handling, cross-input mount resolution, and a seeded
    property test per exported function. The corpus is read in place; other inputs are
    in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonHttp.psm1') -Force -ErrorAction Stop

    $script:CorpusPath = Join-Path -Path $PSScriptRoot -ChildPath 'fixtures/python-surface-corpus.json'
    $parsed = ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText($script:CorpusPath, [System.Text.UTF8Encoding]::new($false)))
    $parsed.Findings.Count | Should -Be 0 -Because 'the committed corpus parses'
    $script:Corpus = $parsed.Value
    $script:Selection = @{ source_roots = [string[]]@($script:Corpus['source_roots']) }

    function ConvertTo-TestCaptured {
        param([System.Collections.IDictionary] $Source)
        $captured = [System.Collections.Generic.List[object]]::new()
        foreach ($key in $Source.Keys) { $captured.Add((New-DocsCapturedInput -Path ([string] $key) -Bytes ([System.Text.Encoding]::UTF8.GetBytes([string] $Source[$key])))) }
        return , $captured.ToArray()
    }

    function ConvertTo-TestElementText {
        param([System.Collections.IDictionary] $Element)
        $range = if ($null -eq $Element['line_range']) { 'null' } else { [string] $Element['line_range']['start'] + '-' + [string] $Element['line_range']['end'] }
        $properties = @($Element['properties'] | ForEach-Object { [string] $_['name'] + '=' + $(if ($null -eq $_['value']) { 'null' } else { [string] $_['value'] }) }) -join ';'
        return (@($Element['kind'], $Element['path'], $Element['declaration'], $Element['name'], [string] $Element['parent_id'], $range, $Element['source_sha256'], $properties, $Element['analyzer_id'], $Element['analysis_method']) -join '|')
    }

    function Compare-TestCorpus {
        param([hashtable] $Output, [string] $AnalyzerId)
        $expected = @{}
        foreach ($element in $script:Corpus['expected_elements']) { if ([string] $element['analyzer_id'] -ceq $AnalyzerId) { $expected[[string] $element['element_id']] = ConvertTo-TestElementText -Element $element } }
        $actual = @{}
        foreach ($element in $Output['Elements']) { $actual[[string] $element['element_id']] = ConvertTo-TestElementText -Element $element }
        $missing = @($expected.Keys | Where-Object { -not $actual.ContainsKey($_) } | ForEach-Object { $expected[$_] })
        $extra = @($actual.Keys | Where-Object { -not $expected.ContainsKey($_) } | ForEach-Object { $actual[$_] })
        $different = @($expected.Keys | Where-Object { $actual.ContainsKey($_) -and $actual[$_] -cne $expected[$_] } | ForEach-Object { 'expected ' + $expected[$_] + ' actual ' + $actual[$_] })
        $missing | Should -BeNullOrEmpty -Because 'every expected element is emitted'
        $extra | Should -BeNullOrEmpty -Because 'no unexpected element is emitted'
        $different | Should -BeNullOrEmpty -Because 'every element field matches the corpus'
        $actual.Count | Should -Be $expected.Count
        $expectedDiagnostics = @($script:Corpus['expected_diagnostics'] | Where-Object { [string] $_['analyzer_id'] -ceq $AnalyzerId } | ForEach-Object { [string] $_['code'] + '|' + [string] $_['path'] + '|' + [string] $_['analyzer_id'] } | Sort-Object)
        $actualDiagnostics = @($Output['Diagnostics'] | ForEach-Object { [string] $_['code'] + '|' + [string] $_['path'] + '|' + [string] $_['analyzer_id'] } | Sort-Object)
        $actualDiagnostics | Should -Be $expectedDiagnostics
    }

    function Get-TestDeclaration {
        param([hashtable] $Output)
        return @($Output['Elements'] | ForEach-Object { [string] $_['declaration'] } | Sort-Object)
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerPythonHttp' {
    BeforeAll {
        $script:Captured = ConvertTo-TestCaptured -Source $script:Corpus['inputs']
        $script:Before = ConvertTo-DocsCanonicalJson -Value $script:Captured
        $script:Output = Invoke-DocsAnalyzerPythonHttp -CapturedInput $script:Captured -Selection $script:Selection
    }

    It 'matches the python-http subset of the corpus on every element field and every diagnostic' {
        Compare-TestCorpus -Output $script:Output -AnalyzerId 'python-http'
    }

    It 'renders an unresolvable router prefix as the literal dynamic segment with prefix_resolved false and HTTP_PREFIX_DYNAMIC' {
        $dynamic = @($script:Output['Elements'] | Where-Object { [string] $_['declaration'] -ceq 'GET <dynamic>/items/{item_id}' })
        $dynamic.Count | Should -Be 1
        @($dynamic[0]['properties'] | Where-Object { $_['name'] -ceq 'prefix_resolved' })[0]['value'] | Should -BeFalse
        @($dynamic[0]['properties'] | Where-Object { $_['name'] -ceq 'mounted' })[0]['value'] | Should -BeTrue
        @($script:Output['Diagnostics'] | Where-Object { $_['code'] -ceq 'HTTP_PREFIX_DYNAMIC' -and $_['path'] -ceq 'src/pkg/_http_fastapi.py' }).Count | Should -Be 1
    }

    It 'emits one element per distinct method with the same line range and records analysis_method scanner' {
        $ping = @($script:Output['Elements'] | Where-Object { [string] $_['name'] -ceq 'ping' })
        @($ping | ForEach-Object { $_['declaration'] } | Sort-Object) | Should -Be @('GET /ping', 'POST /ping')
        $ping[0]['line_range']['start'] | Should -Be $ping[1]['line_range']['start']
        foreach ($element in $script:Output['Elements']) { $element['analysis_method'] | Should -BeExactly 'scanner'; $element['parent_id'] | Should -BeNullOrEmpty }
    }

    It 'does not mutate the captured inputs' {
        (ConvertTo-DocsCanonicalJson -Value $script:Captured) | Should -BeExactly $script:Before
    }

    It 'composes nested FastAPI includes outermost first, keeps a never-included router with mounted false, and resolves from pkg.mod import router across inputs' {
        $output = Invoke-DocsAnalyzerPythonHttp -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{
                    'src/app/main.py'   = "from fastapi import FastAPI, APIRouter`nfrom app.routes import leaf`napp = FastAPI()`nmid = APIRouter(prefix='/mid')`nmid.include_router(leaf, prefix='/in')`napp.include_router(mid, prefix='/top')`norphan = APIRouter(prefix='/o')`n@orphan.get('/x')`ndef ox():`n    pass`n"
                    'src/app/routes.py' = "from fastapi import APIRouter`nleaf = APIRouter(prefix='/leaf')`n@leaf.get('/item')`ndef item():`n    pass`n"
                })) -Selection @{ source_roots = @('src') }
        Get-TestDeclaration -Output $output | Should -Be @('GET /o/x', 'GET /top/mid/in/leaf/item')
        $bare = Invoke-DocsAnalyzerPythonHttp -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'b.py' = "from fastapi import FastAPI, APIRouter`napp = FastAPI()`nr = APIRouter()`n@r.get('/bare')`ndef bare():`n    pass`napp.include_router(r)`n" })) -Selection $null
        Get-TestDeclaration -Output $bare | Should -Be @('GET /bare')
        $leaf = @($output['Elements'] | Where-Object { $_['path'] -ceq 'src/app/routes.py' })[0]
        @($leaf['properties'] | Where-Object { $_['name'] -ceq 'mounted' })[0]['value'] | Should -BeTrue
        $orphan = @($output['Elements'] | Where-Object { $_['name'] -ceq 'ox' })[0]
        @($orphan['properties'] | Where-Object { $_['name'] -ceq 'mounted' })[0]['value'] | Should -BeFalse
        $output['Diagnostics'].Count | Should -Be 0
    }

    It 'replaces a blueprint prefix with the register_blueprint url_prefix and joins Flask templates without a double slash' {
        $output = Invoke-DocsAnalyzerPythonHttp -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'a.py' = "from flask import Flask, Blueprint`napp = Flask(__name__)`nbp = Blueprint('bp', __name__, url_prefix='/bp/')`n@bp.route('/x/')`ndef x():`n    pass`n@bp.route('')`ndef y():`n    pass`napp.register_blueprint(bp)`napp.register_blueprint(bp, url_prefix='/v2')`n" })) -Selection $null
        Get-TestDeclaration -Output $output | Should -Be @('GET /bp/', 'GET /bp/x/', 'GET /v2/', 'GET /v2/x/')
    }

    It 'reports HTTP_INCLUDE_UNRESOLVED for an include cycle and for a depth above 16 with routes keeping their own prefix and mounted false' {
        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add('from fastapi import FastAPI, APIRouter')
        $lines.Add('app = FastAPI()')
        for ($i = 0; $i -le 18; $i++) { $lines.Add("r$i = APIRouter(prefix='/p$i')") }
        for ($i = 1; $i -le 18; $i++) { $lines.Add("r$i.include_router(r$($i - 1))") }
        $lines.Add('app.include_router(r18)')
        $lines.Add("@r0.get('/deep')")
        $lines.Add('def deep():')
        $lines.Add('    pass')
        $lines.Add("@r17.get('/near')")
        $lines.Add('def near():')
        $lines.Add('    pass')
        $lines.Add("a = APIRouter(prefix='/a')")
        $lines.Add("b = APIRouter(prefix='/b')")
        $lines.Add('a.include_router(b)')
        $lines.Add('b.include_router(a)')
        $lines.Add("@a.get('/cycle')")
        $lines.Add('def cycle():')
        $lines.Add('    pass')
        $output = Invoke-DocsAnalyzerPythonHttp -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'deep.py' = ($lines -join "`n") })) -Selection $null
        Get-TestDeclaration -Output $output | Should -Be @('GET /a/cycle', 'GET /p0/deep', 'GET /p18/p17/near')
        foreach ($name in 'deep', 'cycle') { @(@($output['Elements'] | Where-Object { $_['name'] -ceq $name })[0]['properties'] | Where-Object { $_['name'] -ceq 'mounted' })[0]['value'] | Should -BeFalse -Because "$name is unresolved" }
        @($output['Diagnostics'] | ForEach-Object { $_['code'] }) | Should -Be @('HTTP_INCLUDE_UNRESOLVED')
        $output['Diagnostics'][0]['blocking'] | Should -BeFalse
    }

    It 'reports HTTP_MOUNT_UNRESOLVED for a child that resolves to no tracked receiver in any input' {
        $output = Invoke-DocsAnalyzerPythonHttp -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/pkg/a.py' = "from fastapi import FastAPI`nfrom b import router`nfrom . import c`napp = FastAPI()`napp.include_router(router)`napp.include_router(c.router)`napp.include_router(app)`n"; 'src/pkg/c.py' = "x = 1`n"; 'src/pkg/__init__.py' = '' })) -Selection @{ source_roots = @('src') }
        $output['Elements'].Count | Should -Be 0
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('HTTP_MOUNT_UNRESOLVED|src/pkg/a.py')
        $output['Diagnostics'][0]['message'] | Should -Match '^3 occurrence'
    }

    It 'property: Invoke-DocsAnalyzerPythonHttp output is byte-identical under permuted input order' {
        $seed = 102280
        $random = [System.Random]::new($seed)
        $baseline = ConvertTo-DocsCanonicalJson -Value @{ Elements = @($script:Output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $script:Output['Diagnostics'] }
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $permuted = @($script:Captured | Sort-Object -Property @{ Expression = { $random.Next() } })
            $output = Invoke-DocsAnalyzerPythonHttp -CapturedInput $permuted -Selection $script:Selection
            (ConvertTo-DocsCanonicalJson -Value @{ Elements = @($output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $output['Diagnostics'] }) | Should -BeExactly $baseline -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Resolve-DocsHttpTemplate' {
    It 'concatenates FastAPI prefixes verbatim and joins Flask prefixes with a single slash' {
        Resolve-DocsHttpTemplate -Framework 'fastapi' -Prefix @('/v2', '/items') -Path '/' | Should -BeExactly '/v2/items/'
        Resolve-DocsHttpTemplate -Framework 'fastapi' -Prefix @() -Path '/x' | Should -BeExactly '/x'
        Resolve-DocsHttpTemplate -Framework 'fastapi' -Prefix @('<dynamic>') -Path '/items/{item_id}' | Should -BeExactly '<dynamic>/items/{item_id}'
        Resolve-DocsHttpTemplate -Framework 'flask' -Prefix @('/other/') -Path '/items' | Should -BeExactly '/other/items'
        Resolve-DocsHttpTemplate -Framework 'flask' -Prefix @('/a/', '/b/') -Path 'c' | Should -BeExactly '/a/b/c'
        Resolve-DocsHttpTemplate -Framework 'flask' -Prefix @('') -Path '/plain' | Should -BeExactly '/plain'
        Resolve-DocsHttpTemplate -Framework 'flask' -Prefix @('/bp') -Path '' | Should -BeExactly '/bp/'
    }

    It 'property: Resolve-DocsHttpTemplate FastAPI templates equal the joined prefixes plus the path and Flask templates carry no double slash' {
        $seed = 102281
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(0, 4)
            $prefixes = @(if ($count -gt 0) { 1..$count | ForEach-Object { '/' + 'p' + $random.Next(100) + $(if ($random.Next(2) -eq 0) { '/' } else { '' }) } })
            $path = '/' + 'r' + $random.Next(100)
            Resolve-DocsHttpTemplate -Framework 'fastapi' -Prefix $prefixes -Path $path | Should -BeExactly (($prefixes -join '') + $path) -Because "seed $seed, iteration $iteration"
            $flask = Resolve-DocsHttpTemplate -Framework 'flask' -Prefix $prefixes -Path $path
            $flask | Should -Not -Match '//' -Because "seed $seed, iteration $iteration"
            $flask.EndsWith($path, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "seed $seed, iteration $iteration"
        }
    }
}
