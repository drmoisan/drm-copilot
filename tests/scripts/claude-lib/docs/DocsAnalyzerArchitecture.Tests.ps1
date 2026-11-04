#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerArchitecture.psm1 (issue #1022).

.DESCRIPTION
    Compares the python-architecture analyzer output with the python-architecture subset of the
    committed corpus tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json on every
    element field and every diagnostic; asserts relative-import resolution, edge ordering, the
    1000-edge limit (ARCHITECTURE_EDGE_LIMIT, an in-test row proven with 1001 generated input
    modules), that no external-dependency component is emitted, that every component has
    line_range null and the whole-file declaration digest of 1020 Get-DocsDeclarationSha256, that
    an edit anywhere in a module changes its digest, and a seeded property test per exported
    function. The corpus is read in place; other inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerArchitecture.psm1') -Force -ErrorAction Stop

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

    function Get-TestEdge {
        param([System.Collections.IDictionary] $Element)
        [string[]] $names = @($Element['properties'] | Where-Object { ([string] $_['name']).StartsWith('import-') } | ForEach-Object { [string] $_['name'] })
        [Array]::Sort($names, [System.StringComparer]::Ordinal)
        $byName = @{}
        foreach ($property in $Element['properties']) { $byName[[string] $property['name']] = $property['value'] }
        return @($names | ForEach-Object { [string] $byName[$_] })
    }

    function Get-TestStatement {
        param([string] $Text)
        $frontEnd = Get-DocsPythonFrontEnd -Text $Text
        $frontEnd['Blocked'] | Should -BeFalse -Because 'the fixture passes the front-end'
        return $frontEnd['Import']['Statements']
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerArchitecture, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerPythonArchitecture' {
    BeforeAll {
        $script:Captured = ConvertTo-TestCaptured -Source $script:Corpus['inputs']
        $script:Before = ConvertTo-DocsCanonicalJson -Value $script:Captured
        $script:Output = Invoke-DocsAnalyzerPythonArchitecture -CapturedInput $script:Captured -Selection $script:Selection
    }

    It 'matches the python-architecture subset of the corpus on every element field and every diagnostic' {
        Compare-TestCorpus -Output $script:Output -AnalyzerId 'python-architecture'
    }

    It 'gives every component line_range null and the whole-file declaration digest of Get-DocsDeclarationSha256 without a range' {
        $script:Output['Elements'].Count | Should -BeGreaterThan 0
        foreach ($element in $script:Output['Elements']) {
            $element['line_range'] | Should -BeNullOrEmpty -Because "$($element['declaration']) has no span"
            $element['source_sha256'] | Should -BeExactly (Get-DocsDeclarationSha256 -Text $script:Corpus['inputs'][[string] $element['path']]) -Because "$($element['declaration']) carries the whole-file digest"
            $element['analysis_method'] | Should -BeExactly 'scanner'
            $element['parent_id'] | Should -BeNullOrEmpty
        }
        (ConvertTo-DocsCanonicalJson -Value $script:Captured) | Should -BeExactly $script:Before
    }

    It 'changes a component digest for an edit anywhere in the module text, including a line outside every import statement' {
        $original = "import os`nfrom . import util`n`nVALUE = 1`n"
        $edited = "import os`nfrom . import util`n`nVALUE = 2`n"
        $before = (Invoke-DocsAnalyzerPythonArchitecture -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/p/__init__.py' = ''; 'src/p/util.py' = "x = 1`n"; 'src/p/m.py' = $original })) -Selection @{ source_roots = @('src') })['Elements']
        $after = (Invoke-DocsAnalyzerPythonArchitecture -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/p/__init__.py' = ''; 'src/p/util.py' = "x = 1`n"; 'src/p/m.py' = $edited })) -Selection @{ source_roots = @('src') })['Elements']
        $m1 = @($before | Where-Object { $_['declaration'] -ceq 'p.m' })[0]
        $m2 = @($after | Where-Object { $_['declaration'] -ceq 'p.m' })[0]
        $m1['element_id'] | Should -BeExactly $m2['element_id']
        $m1['source_sha256'] | Should -Not -BeExactly $m2['source_sha256']
        Get-TestEdge -Element $m1 | Should -Be @('p.util')
        @($before | Where-Object { $_['declaration'] -ceq 'p.util' })[0]['source_sha256'] | Should -BeExactly @($after | Where-Object { $_['declaration'] -ceq 'p.util' })[0]['source_sha256']
    }

    It 'resolves relative imports against the package, orders edges ordinally, and emits no external-dependency or namespace component' {
        $output = Invoke-DocsAnalyzerPythonArchitecture -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{
                    'src/pkg/__init__.py'     = "from . import zeta`n"
                    'src/pkg/zeta.py'         = "import os`n"
                    'src/pkg/sub/__init__.py' = ''
                    'src/pkg/sub/leaf.py'     = "from .. import zeta`nfrom ..zeta import thing`nfrom . import sibling`nfrom ...beyond import x`nimport pkg.sub.sibling as s`nimport requests`nfrom pkg import Alpha, zeta as z`n"
                    'src/pkg/sub/sibling.py'  = "if True:`n    import pkg.zeta`n"
                    'src/ns/mod.py'           = "from . import other`n"
                    'src/top.py'              = "import pkg`n"
                })) -Selection @{ source_roots = @('src') }
        @($output['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object) | Should -Be @('ns.mod', 'pkg', 'pkg.sub', 'pkg.sub.leaf', 'pkg.sub.sibling', 'pkg.zeta', 'top')
        $leaf = @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'pkg.sub.leaf' })[0]
        Get-TestEdge -Element $leaf | Should -Be @('pkg', 'pkg.sub.sibling', 'pkg.zeta')
        @($leaf['properties'] | Where-Object { $_['name'] -ceq 'import_count' })[0]['value'] | Should -Be 3
        @($leaf['properties'] | Where-Object { $_['name'] -ceq 'component_kind' })[0]['value'] | Should -BeExactly 'module'
        @(@($output['Elements'] | Where-Object { $_['declaration'] -ceq 'pkg' })[0]['properties'] | Where-Object { $_['name'] -ceq 'component_kind' })[0]['value'] | Should -BeExactly 'package'
        Get-TestEdge -Element @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'pkg.sub.sibling' })[0] | Should -Be @('pkg.zeta')
        Get-TestEdge -Element @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'top' })[0] | Should -Be @('pkg')
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED|src/pkg/sub/leaf.py')
        (Get-TestEdge -Element @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'ns.mod' })[0]).Count | Should -Be 0
        (ConvertTo-DocsCanonicalJson -Value $output['Elements']) | Should -Not -Match 'requests'
    }

    It 'reports ARCHITECTURE_DYNAMIC_IMPORT and ARCHITECTURE_MODULE_NAME_INVALID and keeps the other components' {
        $output = Invoke-DocsAnalyzerPythonArchitecture -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/a.py' = "import importlib`nfrom importlib import import_module as im`nimport importlib.util`ndef load(n):`n    importlib.import_module(n)`n    im(n)`n    __import__(n)`n    importlib.util.spec_from_file_location(n, n)`n"; 'src/bad-name.py' = "x = 1`n"; 'src/fine.py' = "x = 1`n" })) -Selection @{ source_roots = @('src') }
        @($output['Elements'] | ForEach-Object { $_['declaration'] } | Sort-Object) | Should -Be @('a', 'fine')
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] + '|' + $_['message'] }) | Should -Be @('ARCHITECTURE_DYNAMIC_IMPORT|src/a.py|4 occurrence(s); first at line 5.', 'ARCHITECTURE_MODULE_NAME_INVALID|src/bad-name.py|1 occurrence(s); first at line 1.')
        foreach ($diagnostic in $output['Diagnostics']) { $diagnostic['blocking'] | Should -BeFalse; $diagnostic['severity'] | Should -BeExactly 'warning' }
    }

    It 'applies ARCHITECTURE_EDGE_LIMIT above 1000 edges keeping import_count only and accepts 1000 edges' {
        $source = [ordered]@{ 'src/p/__init__.py' = '' }
        $full = [System.Collections.Generic.List[string]]::new()
        $bounded = [System.Collections.Generic.List[string]]::new()
        for ($index = 1; $index -le 1001; $index++) {
            $name = 'm' + $index.ToString('0000')
            $source['src/p/' + $name + '.py'] = "x = $index`n"
            $full.Add("import p.$name")
            if ($index -le 1000) { $bounded.Add("import p.$name") }
        }
        $source['src/p/over.py'] = ($full -join "`n") + "`n"
        $source['src/p/limit.py'] = ($bounded -join "`n") + "`n"
        $output = Invoke-DocsAnalyzerPythonArchitecture -CapturedInput (ConvertTo-TestCaptured -Source $source) -Selection @{ source_roots = @('src') }
        $over = @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'p.over' })[0]
        @($over['properties'] | Where-Object { $_['name'] -ceq 'import_count' })[0]['value'] | Should -Be 1001
        (Get-TestEdge -Element $over).Count | Should -Be 0
        $limit = @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'p.limit' })[0]
        @($limit['properties'] | Where-Object { $_['name'] -ceq 'import_count' })[0]['value'] | Should -Be 1000
        $edges = Get-TestEdge -Element $limit
        $edges.Count | Should -Be 1000
        $edges[0] | Should -BeExactly 'p.m0001'
        $edges[999] | Should -BeExactly 'p.m1000'
        @($limit['properties'] | Where-Object { $_['name'] -ceq 'import-1000' }).Count | Should -Be 1
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('ARCHITECTURE_EDGE_LIMIT|src/p/over.py')
        $output['Diagnostics'][0]['blocking'] | Should -BeFalse
        $output['Elements'].Count | Should -Be 1004
    }

    It 'property: Invoke-DocsAnalyzerPythonArchitecture output is byte-identical under permuted input order' {
        $seed = 102300
        $random = [System.Random]::new($seed)
        $baseline = ConvertTo-DocsCanonicalJson -Value @{ Elements = @($script:Output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $script:Output['Diagnostics'] }
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $permuted = @($script:Captured | Sort-Object -Property @{ Expression = { $random.Next() } })
            $output = Invoke-DocsAnalyzerPythonArchitecture -CapturedInput $permuted -Selection $script:Selection
            (ConvertTo-DocsCanonicalJson -Value @{ Elements = @($output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $output['Diagnostics'] }) | Should -BeExactly $baseline -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsPythonImportEdge' {
    It 'matches the longest known prefix, resolves relative levels, drops self-edges and reports unresolvable relative imports' {
        $statements = Get-TestStatement -Text "import a.b.c`nimport a.b.c.d`nfrom a import b`nfrom a.b import c as cc, zz`nfrom . import m`nfrom .m import f`nfrom .. import q`nfrom ...far import g`nimport self_mod`nfrom x import *`n"
        $result = Get-DocsPythonImportEdge -Statement $statements -Module 'pkg.self_mod' -Package 'pkg' -Known @('a', 'a.b', 'a.b.c', 'pkg', 'pkg.m', 'pkg.self_mod', 'x')
        $result['Edge'] | Should -Be @('a.b', 'a.b.c', 'pkg.m', 'x')
        @($result['Diagnostics'] | ForEach-Object { $_['Code'] + ':' + $_['Line'] }) | Should -Be @('ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED:7', 'ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED:8')
        $outside = Get-DocsPythonImportEdge -Statement (Get-TestStatement -Text "from . import m`n") -Module 'top' -Package '' -Known @('top', 'm')
        $outside['Edge'].Count | Should -Be 0
        $outside['Diagnostics'][0]['Code'] | Should -BeExactly 'ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED'
    }

    It 'property: Get-DocsPythonImportEdge edges equal the longest-prefix resolution of generated imports' {
        $seed = 102301
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $known = [System.Collections.Generic.List[string]]::new()
            $known.Add('root')
            $count = $random.Next(1, 6)
            for ($i = 0; $i -lt $count; $i++) { $known.Add('root.k' + $i) }
            $lines = [System.Collections.Generic.List[string]]::new()
            $expected = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            $imports = $random.Next(0, 8)
            for ($i = 0; $i -lt $imports; $i++) {
                $target = 'root.k' + $random.Next(0, $count + 2)
                $deeper = $target + '.leaf' + $random.Next(10)
                $lines.Add($(if ($random.Next(2) -eq 0) { "import $deeper" } else { "from $target import leaf$($random.Next(10))" }))
                [void] $expected.Add($(if ($known.Contains($target)) { $target } else { 'root' }))
            }
            [object[]] $statements = @(if ($lines.Count -gt 0) { Get-TestStatement -Text (($lines -join "`n") + "`n") })
            $result = Get-DocsPythonImportEdge -Statement $statements -Module 'other' -Package '' -Known $known.ToArray()
            [string[]] $sorted = @($expected)
            [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
            if ($sorted.Count -eq 0) { @($result['Edge']).Count | Should -Be 0 -Because "seed $seed, iteration $iteration" }
            else { @($result['Edge']) | Should -Be $sorted -Because "seed $seed, iteration $iteration" }
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
        }
    }
}
