#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerPythonApi.psm1 (issue #1022).

.DESCRIPTION
    Compares the python-public-api analyzer output with the python-public-api subset of the
    committed corpus tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json on every
    element field and every diagnostic; asserts each literal __all__ form, the naming rule, the
    exclusions of _-prefixed modules and names and of imported names, each PUBLIC_API_* effect,
    and a seeded property test per exported function. The corpus is read in place; other inputs
    are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonBindings.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonApi.psm1') -Force -ErrorAction Stop

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

    function Get-TestLine {
        param([string] $Text)
        $frontEnd = Get-DocsPythonFrontEnd -Text $Text
        $frontEnd['Blocked'] | Should -BeFalse -Because 'the fixture passes the front-end'
        return $frontEnd
    }

    function Get-TestSymbol {
        param([hashtable] $Output)
        [string[]] $items = @($Output['Elements'] | ForEach-Object { [string] $_['name'] + ':' + (@($_['properties'] | Where-Object { $_['name'] -ceq 'symbol_kind' })[0]['value']) + ':' + (@($_['properties'] | Where-Object { $_['name'] -ceq 'basis' })[0]['value']) + ':' + $_['line_range']['start'] })
        [Array]::Sort($items, [System.StringComparer]::Ordinal)
        return $items
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerPythonApi, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerPythonApi' {
    BeforeAll {
        $script:Captured = ConvertTo-TestCaptured -Source $script:Corpus['inputs']
        $script:Before = ConvertTo-DocsCanonicalJson -Value $script:Captured
        $script:Output = Invoke-DocsAnalyzerPythonApi -CapturedInput $script:Captured -Selection $script:Selection
    }

    It 'matches the python-public-api subset of the corpus on every element field and every diagnostic' {
        Compare-TestCorpus -Output $script:Output -AnalyzerId 'python-public-api'
    }

    It 'records analysis_method scanner and no parent on every element and does not mutate the captured inputs' {
        foreach ($element in $script:Output['Elements']) { $element['analysis_method'] | Should -BeExactly 'scanner'; $element['parent_id'] | Should -BeNullOrEmpty }
        (ConvertTo-DocsCanonicalJson -Value $script:Captured) | Should -BeExactly $script:Before
    }

    It 'reads every literal __all__ form with basis all, keeps an unresolved name and reports a top-level star import' {
        $output = Invoke-DocsAnalyzerPythonApi -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/m.py' = "from os import *`nimport sys`n__all__ = ['first', 'sys']`n__all__ += ['second']`n__all__.extend(['third', 'first'])`n__all__.append('ghost')`ndef first():`n    pass`nclass second:`n    pass`nthird = 3`n_hidden = 4`n" })) -Selection @{ source_roots = @('src') }
        Get-TestSymbol -Output $output | Should -Be @('first:function:all:7', 'ghost:unresolved:all:6', 'second:class:all:9', 'sys:import:all:2', 'third:variable:all:11')
        @($output['Diagnostics'] | ForEach-Object { $_['code'] } | Sort-Object) | Should -Be @('PUBLIC_API_NAME_UNRESOLVED', 'PUBLIC_API_STAR_IMPORT')
        foreach ($diagnostic in $output['Diagnostics']) { $diagnostic['blocking'] | Should -BeFalse; $diagnostic['severity'] | Should -BeExactly 'warning' }
    }

    It 'applies the naming rule without __all__: top-level definitions and targets in branch bodies, excluding imports and _-prefixed names' {
        $output = Invoke-DocsAnalyzerPythonApi -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/n.py' = "import os`nfrom x import y as z`nif os.name == 'nt':`n    flag = 1`nelif other:`n    flag = 2`nelse:`n    flag = 3`ntry:`n    maybe = 1`nexcept Exception:`n    maybe = 2`nfinally:`n    done = True`nwith open(f) as g:`n    inner = 1`nfor i in x:`n    looped = 1`na = b = 3`ntyped: int`nannotated: int = 1`n@dec`nasync def af():`n    pass`nclass K:`n    member = 1`ndef _private():`n    pass`n_value = 1`n" })) -Selection @{ source_roots = @('src') }
        Get-TestSymbol -Output $output | Should -Be @('K:class:naming:25', 'a:variable:naming:19', 'af:async-function:naming:22', 'annotated:variable:naming:21', 'b:variable:naming:19', 'done:variable:naming:14', 'flag:variable:naming:4', 'maybe:variable:naming:10', 'typed:variable:naming:20')
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + ':' + $_['message'] }) | Should -Be @('PUBLIC_API_CONDITIONAL_DEFINITION:3 occurrence(s); first at line 6.')
        @($output['Elements'] | Where-Object { $_['name'] -ceq 'flag' })[0]['line_range']['end'] | Should -Be 4
    }

    It 'falls back to the naming rule with PUBLIC_API_DYNAMIC_ALL for every dynamic __all__ form without removing elements' {
        foreach ($form in @("__all__ = ['a'] + ['b']", "__all__ = [n for n in x]", "__all__ = list(x)", "__all__ = [*base]", "__all__ = ['a', name]", "if x:`n    __all__ = ['a']", "__all__ = ['a']`ndef _f():`n    __all__.append('b')")) {
            $output = Invoke-DocsAnalyzerPythonApi -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/d.py' = "from q import *`n$form`ndef a():`n    pass`ndef b():`n    pass`n" })) -Selection @{ source_roots = @('src') }
            @((Get-TestSymbol -Output $output) -replace ':[0-9]+$', '') | Should -Be @('a:function:naming', 'b:function:naming') -Because "form $form"
            @($output['Diagnostics'] | ForEach-Object { $_['code'] }) | Should -Be @('PUBLIC_API_DYNAMIC_ALL') -Because "form $form"
        }
    }

    It 'reports PUBLIC_API_UNPACKING_TARGET without elements for the unpacked names and PYTHON_IDENTIFIER_NON_ASCII without an element while other names survive' {
        $name = 'caf' + [char]0xE9
        $output = Invoke-DocsAnalyzerPythonApi -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/u.py' = "(x, y) = (1, 2)`nm, n = 1, 2`n[p, q] = r`nkept = 1`ndef $name():`n    pass`nclass ${name}K:`n    pass`n" })) -Selection @{ source_roots = @('src') }
        Get-TestSymbol -Output $output | Should -Be @('kept:variable:naming:4')
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + ':' + $_['message'] }) | Should -Be @('PUBLIC_API_UNPACKING_TARGET:3 occurrence(s); first at line 1.', 'PYTHON_IDENTIFIER_NON_ASCII:2 occurrence(s); first at line 5.')
    }

    It 'reports PUBLIC_API_MODULE_NOT_IMPORTABLE for an invalid segment, yields nothing for a _-prefixed segment and skips paths outside every source root' {
        $output = Invoke-DocsAnalyzerPythonApi -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/bad-name.py' = "v = 1`n"; 'src/_private/mod.py' = "v = 1`n"; 'src/pkg/_hidden.py' = "v = 1`n"; 'other/mod.py' = "v = 1`n"; 'src/pkg/__init__.py' = "v = 1`n" })) -Selection @{ source_roots = @('src') }
        Get-TestSymbol -Output $output | Should -Be @('v:variable:naming:1')
        $output['Elements'][0]['declaration'] | Should -BeExactly 'pkg.v'
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('PUBLIC_API_MODULE_NOT_IMPORTABLE|src/bad-name.py')
    }

    It 'property: Invoke-DocsAnalyzerPythonApi output is byte-identical under permuted input order' {
        $seed = 102290
        $random = [System.Random]::new($seed)
        $baseline = ConvertTo-DocsCanonicalJson -Value @{ Elements = @($script:Output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $script:Output['Diagnostics'] }
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $permuted = @($script:Captured | Sort-Object -Property @{ Expression = { $random.Next() } })
            $output = Invoke-DocsAnalyzerPythonApi -CapturedInput $permuted -Selection $script:Selection
            (ConvertTo-DocsCanonicalJson -Value @{ Elements = @($output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $output['Diagnostics'] }) | Should -BeExactly $baseline -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsPublicApiAllName' {
    It 'returns Found false without __all__, the tuple and annotated forms, and the string site lines' {
        (Get-DocsPublicApiAllName -Line (Get-TestLine -Text "x = 1`n")['Lines'])['Found'] | Should -BeFalse
        $result = Get-DocsPublicApiAllName -Line (Get-TestLine -Text "__all__: list[str] = (`n    'alpha',`n    'beta',`n)`n__all__ = ['gamma']`n__all__ += ('delta',)`n")['Lines']
        $result['Found'] | Should -BeTrue
        $result['Dynamic'] | Should -BeFalse
        $result['Name'] | Should -Be @('gamma', 'delta')
        $result['Site']['delta']['Line'] | Should -Be 6
    }

    It 'property: Get-DocsPublicApiAllName final list equals the replayed literal operations' {
        $seed = 102291
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $expected = [System.Collections.Generic.List[string]]::new()
            $lines = [System.Collections.Generic.List[string]]::new()
            $operations = $random.Next(1, 6)
            for ($i = 0; $i -lt $operations; $i++) {
                $names = @(1..$random.Next(1, 4) | ForEach-Object { 'n' + $random.Next(0, 8) })
                $literal = '[' + (($names | ForEach-Object { "'$_'" }) -join ', ') + ']'
                switch ($random.Next(4)) {
                    0 { $lines.Add("__all__ = $literal"); $expected.Clear() }
                    1 { $lines.Add("__all__ += $literal") }
                    2 { $lines.Add("__all__.extend($literal)") }
                    default { $names = @($names[0]); $lines.Add("__all__.append('$($names[0])')") }
                }
                foreach ($name in $names) { if (-not $expected.Contains($name)) { $expected.Add($name) } }
            }
            $result = Get-DocsPublicApiAllName -Line (Get-TestLine -Text (($lines -join "`n") + "`n"))['Lines']
            $result['Dynamic'] | Should -BeFalse -Because "seed $seed, iteration $iteration"
            @($result['Name']) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsPublicApiBinding' {
    It 'spans a decorated def from its topmost decorator and an import from its statement, and marks branch bindings' {
        $frontEnd = Get-TestLine -Text "@a`n@b(1)`ndef f():`n    pass`nfrom m import (`n    x,`n    y as z,`n)`nif c:`n    w = 1`n"
        $result = Get-DocsPublicApiBinding -Line $frontEnd['Lines'] -Import $frontEnd['Import']
        $result['Binding']['f']['Span'] | Should -Be @(1, 3)
        $result['Binding']['x']['Span'] | Should -Be @(5, 8)
        $result['Binding']['z']['Kind'] | Should -BeExactly 'import'
        $result['Binding']['w']['Branch'] | Should -BeTrue
        $result['Binding']['f']['Branch'] | Should -BeFalse
        $result['Diagnostics'].Count | Should -Be 0
    }

    It 'property: Get-DocsPublicApiBinding binds every generated top-level name once with its kind' {
        $seed = 102292
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $count = $random.Next(0, 8)
            $lines = [System.Collections.Generic.List[string]]::new()
            $expected = @{}
            for ($i = 0; $i -lt $count; $i++) {
                $name = 'name' + $i
                switch ($random.Next(5)) {
                    0 { $lines.Add("def ${name}():"); $lines.Add('    pass'); $expected[$name] = 'function' }
                    1 { $lines.Add("async def ${name}():"); $lines.Add('    pass'); $expected[$name] = 'async-function' }
                    2 { $lines.Add("class ${name}:"); $lines.Add('    pass'); $expected[$name] = 'class' }
                    3 { $lines.Add("${name} = $i"); $expected[$name] = 'variable' }
                    default { $lines.Add("import ${name}"); $expected[$name] = 'import' }
                }
            }
            $frontEnd = Get-TestLine -Text (($lines -join "`n") + "`n")
            $result = Get-DocsPublicApiBinding -Line $frontEnd['Lines'] -Import $frontEnd['Import']
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $result['Binding'].Count | Should -Be $count -Because "seed $seed, iteration $iteration"
            foreach ($name in $expected.Keys) { $result['Binding'][$name]['Kind'] | Should -BeExactly $expected[$name] -Because "seed $seed, iteration $iteration, $name" }
        }
    }
}
