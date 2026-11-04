#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerConfigFiles.psm1 (issue #1022).

.DESCRIPTION
    Compares the config-files analyzer output with the config-files subset of the committed corpus
    tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json on every element field and
    every diagnostic; asserts each config-files diagnostic row (code, severity, blocking flag and
    effect, with site survival), the TOML exclusions, that no marker value appears in any element,
    the format selection, the env template names, the env-template scanner, and a seeded property
    test per exported function. The corpus is read in place; other inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerConfigFiles.psm1') -Force -ErrorAction Stop

    $script:CorpusPath = Join-Path -Path $PSScriptRoot -ChildPath 'fixtures/config-surface-corpus.json'
    $parsed = ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText($script:CorpusPath, [System.Text.UTF8Encoding]::new($false)))
    $parsed.Findings.Count | Should -Be 0 -Because 'the committed corpus parses'
    $script:Corpus = $parsed.Value
    $script:MarkerPrefix = [string] $script:Corpus['marker_prefix']

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
        # Returns the sorted declarations joined with ',' (a joined string compares as one value under Should).
        param([hashtable] $Output)
        [string[]] $items = @($Output['Elements'] | ForEach-Object { [string] $_['declaration'] })
        [Array]::Sort($items, [System.StringComparer]::Ordinal)
        return ($items -join ',')
    }

    function Get-TestProperty {
        param([System.Collections.IDictionary] $Element, [string] $Name)
        $match = @($Element['properties'] | Where-Object { [string] $_['name'] -ceq $Name })
        if ($match.Count -eq 0) { return 'absent' }
        return $match[0]['value']
    }

    function Invoke-TestAnalyzer {
        param([string] $Path, [string] $Text)
        return Invoke-DocsAnalyzerConfigFiles -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ $Path = $Text })) -Selection $null
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsYamlKeys, DocsTomlKeys, DocsSourceText, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerConfigFiles' {
    BeforeAll {
        $script:Captured = ConvertTo-TestCaptured -Source $script:Corpus['inputs']
        $script:Before = ConvertTo-DocsCanonicalJson -Value $script:Captured
        $script:Output = Invoke-DocsAnalyzerConfigFiles -CapturedInput $script:Captured -Selection $null
    }

    It 'matches the config-files subset of the corpus on every element field and every diagnostic' {
        Compare-TestCorpus -Output $script:Output -AnalyzerId 'config-files'
    }

    It 'records analysis_method scanner and no parent, carries key and shape names only, exports no marker value and does not mutate the captured inputs' {
        $script:Output['Elements'].Count | Should -BeGreaterThan 0
        foreach ($element in $script:Output['Elements']) {
            $element['analysis_method'] | Should -BeExactly 'scanner'
            $element['parent_id'] | Should -BeNullOrEmpty
            $element['kind'] | Should -BeExactly 'config-key'
            foreach ($property in $element['properties']) { @('format', 'value_type', 'schema_type', 'required', 'conditional') | Should -Contain $property['name'] }
        }
        (ConvertTo-DocsCanonicalJson -Value @{ Elements = $script:Output['Elements']; Diagnostics = $script:Output['Diagnostics'] }).Contains($script:MarkerPrefix) | Should -BeFalse -Because 'no configuration value is exported'
        (ConvertTo-DocsCanonicalJson -Value $script:Captured) | Should -BeExactly $script:Before
    }

    It 'excludes tool.poetry.scripts, the dependency subtrees, [project] and [build-system], and ignores plain JSON, non-template env files and other inputs' {
        $toml = "[project]`nname = `"p`"`n[build-system]`nrequires = []`n[tool.poetry]`nname = `"q`"`n[tool.poetry.scripts]`ncli = `"m:f`"`n[tool.poetry.dependencies]`npython = `"3`"`n[tool.poetry.dev-dependencies]`npytest = `"1`"`n[tool.poetry.group]`nkept = 1`n[tool.poetry.group.test.dependencies]`nhypothesis = `"1`"`n[tool.poetry.extras]`ndocs = []`n[tool.kept]`nvalue = 1`n"
        $output = Invoke-DocsAnalyzerConfigFiles -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'c/pyproject.toml' = $toml; 'c/plain.json' = '{"value": 1}'; 'c/.env' = "A=1`n"; 'c/.env.local' = "A=1`n"; 'c/app.env' = "A=1`n"; 'c/readme.txt' = "A=1`n"; 'c/mod.py' = "A = 1`n" })) -Selection $null
        Get-TestDeclaration -Output $output | Should -BeExactly 'tool.kept,tool.kept.value,tool.poetry,tool.poetry.group,tool.poetry.group.kept,tool.poetry.name'
        $output['Diagnostics'].Count | Should -Be 0
    }

    It 'reports each config-files diagnostic row with its code, severity, blocking flag and effect while other sites survive' {
        $cases = @(
            @{ Path = 'c/pyproject.toml'; Text = "[tool.x]`nkey = `n"; Code = 'TOML_INVALID'; Severity = 'error'; Blocking = $true; Declarations = @() }
            @{ Path = 'c/pyproject.toml'; Text = "[tool.x]`na = { b = 1 }`nc = 2`n"; Code = 'TOML_INLINE_TABLE_NOT_EXPANDED'; Severity = 'warning'; Blocking = $false; Declarations = @('tool.x', 'tool.x.a', 'tool.x.c') }
            @{ Path = 'c/pyproject.toml'; Text = "[tool.x]`n`"e\tk`" = 1`nc = 2`n"; Code = 'TOML_KEY_ESCAPE_UNSUPPORTED'; Severity = 'warning'; Blocking = $false; Declarations = @('tool.x', 'tool.x.c') }
            @{ Path = 'c/.env.example'; Text = "A=1`nnot a key`n9B=2`n"; Code = 'ENV_LINE_UNRECOGNIZED'; Severity = 'warning'; Blocking = $false; Declarations = @('A'); Message = '2 occurrence(s); first at line 2.' }
            @{ Path = 'c/.env.sample'; Text = "A=1`nB=`"open`nC=3`n"; Code = 'ENV_INVALID'; Severity = 'error'; Blocking = $true; Declarations = @() }
            @{ Path = 'c/.env.dist'; Text = "A=1`nA=2`nB=3`n"; Code = 'ENV_KEY_DUPLICATE'; Severity = 'warning'; Blocking = $false; Declarations = @('A', 'B') }
            @{ Path = 'c/x.schema.json'; Text = '{"properties": {'; Code = 'JSON_INVALID'; Severity = 'error'; Blocking = $true; Declarations = @() }
            @{ Path = 'c/x.schema.json'; Text = '{"properties": {"a": {"$ref": "#/$defs/nope"}, "b": {"type": "string"}}}'; Code = 'JSON_SCHEMA_REF_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Declarations = @('a', 'b') }
            @{ Path = 'c/x.schema.json'; Text = '{"properties": {"a": {"not": {"properties": {"hidden": {}}}}, "b": {}}}'; Code = 'JSON_SCHEMA_KEYWORD_NOT_EXPANDED'; Severity = 'warning'; Blocking = $false; Declarations = @('a', 'b') }
            @{ Path = 'c/a.yml'; Text = "a:`n`tb: 1`n"; Code = 'YAML_INVALID'; Severity = 'error'; Blocking = $true; Declarations = @() }
            @{ Path = 'c/a.yml'; Text = "a: 1`n---`nb: 2`n"; Code = 'YAML_MULTI_DOCUMENT'; Severity = 'warning'; Blocking = $false; Declarations = @() }
            @{ Path = 'c/a.yml'; Text = "a: &x 1`nb: 2`n"; Code = 'YAML_ANCHOR_ALIAS'; Severity = 'warning'; Blocking = $false; Declarations = @() }
            @{ Path = 'c/a.yml'; Text = "a: !!str 1`nb: 2`n"; Code = 'YAML_UNSUPPORTED'; Severity = 'warning'; Blocking = $false; Declarations = @() }
            @{ Path = 'c/a.yaml'; Text = "a: [1, 2]`nb: {c: 1}`nd: 2`n"; Code = 'YAML_FLOW_COLLECTION_NOT_EXPANDED'; Severity = 'warning'; Blocking = $false; Declarations = @('a', 'b', 'd') }
            @{ Path = 'c/a.yaml'; Text = "`"q\tk`": 1`nb: 2`n"; Code = 'YAML_KEY_ESCAPE_UNSUPPORTED'; Severity = 'warning'; Blocking = $false; Declarations = @('b') }
            @{ Path = 'c/a.yaml'; Text = "- a`n- b`n"; Code = 'YAML_ROOT_NOT_MAPPING'; Severity = 'warning'; Blocking = $false; Declarations = @() }
        )
        foreach ($case in $cases) {
            $output = Invoke-TestAnalyzer -Path $case.Path -Text $case.Text
            @($output['Diagnostics'] | ForEach-Object { $_['code'] }) | Should -Be @($case.Code) -Because "row $($case.Code)"
            $output['Diagnostics'][0]['severity'] | Should -BeExactly $case.Severity -Because "row $($case.Code)"
            $output['Diagnostics'][0]['blocking'] | Should -Be $case.Blocking -Because "row $($case.Code)"
            $output['Diagnostics'][0]['analyzer_id'] | Should -BeExactly 'config-files' -Because "row $($case.Code)"
            $output['Diagnostics'][0]['path'] | Should -BeExactly $case.Path -Because "row $($case.Code)"
            if ($case.ContainsKey('Message')) { $output['Diagnostics'][0]['message'] | Should -BeExactly $case.Message -Because "row $($case.Code)" }
            Get-TestDeclaration -Output $output | Should -BeExactly (@($case.Declarations) -join ',') -Because "row $($case.Code)"
        }
    }

    It 'emits an inline table and a flow collection with the container value type and an env duplicate keeps the first site' {
        $toml = Invoke-TestAnalyzer -Path 'c/pyproject.toml' -Text "[tool.x]`na = { b = 1 }`n"
        Get-TestProperty -Element @($toml['Elements'] | Where-Object { $_['declaration'] -ceq 'tool.x.a' })[0] -Name 'value_type' | Should -BeExactly 'table'
        $yaml = Invoke-TestAnalyzer -Path 'c/a.yaml' -Text "a: [1, 2]`nb: {c: 1}`n"
        Get-TestProperty -Element @($yaml['Elements'] | Where-Object { $_['declaration'] -ceq 'a' })[0] -Name 'value_type' | Should -BeExactly 'array'
        Get-TestProperty -Element @($yaml['Elements'] | Where-Object { $_['declaration'] -ceq 'b' })[0] -Name 'value_type' | Should -BeExactly 'object'
        $env = Invoke-TestAnalyzer -Path 'c/.env.example' -Text "A=1`nA=2`n"
        $env['Elements'][0]['line_range']['start'] | Should -Be 1
        Get-TestProperty -Element $env['Elements'][0] -Name 'format' | Should -BeExactly 'env'
    }

    It 'carries schema_type, required and conditional for JSON Schema keys and selects a .json input by its root $schema' {
        $output = Invoke-TestAnalyzer -Path 'c/s.json' -Text "{`n  `"`$schema`": `"https://json-schema.org/draft/2020-12/schema`",`n  `"required`": [`"a`"],`n  `"properties`": {`"a`": {`"type`": [`"string`", `"null`"]}, `"b`": {`"oneOf`": [{`"properties`": {`"c`": {}}}]}}`n}`n"
        Get-TestDeclaration -Output $output | Should -BeExactly 'a,b,b.c'
        $a = @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'a' })[0]
        Get-TestProperty -Element $a -Name 'schema_type' | Should -BeExactly 'multiple'
        Get-TestProperty -Element $a -Name 'required' | Should -BeTrue
        Get-TestProperty -Element $a -Name 'conditional' | Should -BeExactly 'absent'
        $c = @($output['Elements'] | Where-Object { $_['declaration'] -ceq 'b.c' })[0]
        Get-TestProperty -Element $c -Name 'conditional' | Should -BeTrue
        Get-TestProperty -Element $c -Name 'schema_type' | Should -BeExactly 'absent'
        Get-TestProperty -Element $c -Name 'format' | Should -BeExactly 'json-schema'
    }

    It 'reports CONFIG_KEY_LIMIT (blocking, no element) above 10,000 keys in one input and accepts a smaller input (in-test row)' {
        $above = ((1..10001 | ForEach-Object { "k${_}: $_" }) -join "`n") + "`n"
        $output = Invoke-DocsAnalyzerConfigFiles -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'c/big.yaml' = $above; 'c/small.yaml' = "a: 1`n" })) -Selection $null
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('CONFIG_KEY_LIMIT|c/big.yaml')
        $output['Diagnostics'][0]['severity'] | Should -BeExactly 'error'
        $output['Diagnostics'][0]['blocking'] | Should -BeTrue
        Get-TestDeclaration -Output $output | Should -BeExactly 'a'
        $within = ((1..120 | ForEach-Object { "k${_}: $_" }) -join "`n") + "`n"
        $accepted = Invoke-TestAnalyzer -Path 'c/ok.yaml' -Text $within
        $accepted['Elements'].Count | Should -Be 120
        $accepted['Diagnostics'].Count | Should -Be 0
    }

    It 'rejects a Selection that is not null or a dictionary and skips an input whose text is null' {
        { Invoke-DocsAnalyzerConfigFiles -CapturedInput @() -Selection 'text' } | Should -Throw -ExpectedMessage 'DOCS_ANALYZER_SELECTION_INVALID*'
        $output = Invoke-DocsAnalyzerConfigFiles -CapturedInput @(@{ path = 'c/a.yaml'; text = $null; sha256 = ''; size = 0L; diagnostic = $null }) -Selection @{ source_roots = @('c') }
        $output['Elements'].Count | Should -Be 0
        $output['Diagnostics'].Count | Should -Be 0
    }

    It 'property: Invoke-DocsAnalyzerConfigFiles output is byte-identical under permuted input order' {
        $seed = 102240
        $random = [System.Random]::new($seed)
        $baseline = ConvertTo-DocsCanonicalJson -Value @{ Elements = @($script:Output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $script:Output['Diagnostics'] }
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $permuted = @($script:Captured | Sort-Object -Property @{ Expression = { $random.Next() } })
            $output = Invoke-DocsAnalyzerConfigFiles -CapturedInput $permuted -Selection $null
            (ConvertTo-DocsCanonicalJson -Value @{ Elements = @($output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $output['Diagnostics'] }) | Should -BeExactly $baseline -Because "seed $seed, iteration $iteration"
        }
    }

    Context 'registration' {
        It 'registers the five 1022 scanner rows in the committed registry and Test-DocsAnalyzerRegistration returns no finding' {
            $registration = Get-DocsAnalyzerRegistration
            (Test-DocsAnalyzerRegistration -Registration $registration).Count | Should -Be 0
            $expected = @{ 'config-files' = 'Invoke-DocsAnalyzerConfigFiles'; 'python-architecture' = 'Invoke-DocsAnalyzerPythonArchitecture'; 'python-cli' = 'Invoke-DocsAnalyzerPythonCli'; 'python-http' = 'Invoke-DocsAnalyzerPythonHttp'; 'python-public-api' = 'Invoke-DocsAnalyzerPythonApi' }
            foreach ($id in @($expected.Keys | Sort-Object)) {
                $rows = @($registration | Where-Object { [string] $_.Id -ceq $id })
                $rows.Count | Should -Be 1 -Because "identifier $id"
                $rows[0].AnalysisMethod | Should -BeExactly 'scanner' -Because "identifier $id"
                $rows[0].Version | Should -BeExactly '1.0.0' -Because "identifier $id"
                $rows[0].Function | Should -BeExactly $expected[$id] -Because "identifier $id"
                Test-Path -LiteralPath $rows[0].Module | Should -BeTrue -Because "identifier $id"
            }
            $configRow = @($registration | Where-Object { [string] $_.Id -ceq 'config-files' })[0]
            @($configRow.ElementKinds) | Should -Be @('config-key')
        }
    }
}

Describe 'Get-DocsConfigFileFormat' {
    It 'selects toml by basename, env for the template names, json-schema by basename or root $schema, yaml for .yaml and .yml, and null otherwise' {
        Get-DocsConfigFileFormat -Path 'a/pyproject.toml' | Should -BeExactly 'toml'
        Get-DocsConfigFileFormat -Path 'a/other.toml' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/.env.example' | Should -BeExactly 'env'
        Get-DocsConfigFileFormat -Path 'a/.env' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.schema.json' -Text '{' | Should -BeExactly 'json-schema'
        Get-DocsConfigFileFormat -Path 'a/x.json' -Text '{"$schema": "https://json-schema.org/draft/2020-12/schema"}' | Should -BeExactly 'json-schema'
        Get-DocsConfigFileFormat -Path 'a/x.json' -Text '{"$schema": "https://example.org/schema"}' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.json' -Text '{"value": 1}' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.json' -Text '[1]' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.json' -Text '{' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.json' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.yaml' | Should -BeExactly 'yaml'
        Get-DocsConfigFileFormat -Path 'a/x.yml' | Should -BeExactly 'yaml'
        Get-DocsConfigFileFormat -Path 'a/x.YAML' | Should -BeNullOrEmpty
        Get-DocsConfigFileFormat -Path 'a/x.py' | Should -BeNullOrEmpty
    }

    It 'property: Get-DocsConfigFileFormat depends on the basename and the root $schema only' {
        $seed = 102241
        $random = [System.Random]::new($seed)
        $table = @(
            @{ Name = 'pyproject.toml'; Format = 'toml' }, @{ Name = '.env.example'; Format = 'env' }, @{ Name = '.env.dist'; Format = 'env' }, @{ Name = '.env'; Format = $null },
            @{ Name = 'a.schema.json'; Format = 'json-schema' }, @{ Name = 'a.yaml'; Format = 'yaml' }, @{ Name = 'a.yml'; Format = 'yaml' }, @{ Name = 'a.txt'; Format = $null }, @{ Name = 'a.py'; Format = $null }
        )
        for ($iteration = 0; $iteration -lt 80; $iteration++) {
            $directory = (@(1..$random.Next(0, 4) | ForEach-Object { 'd' + $random.Next(0, 5) }) + @('')) -join '/'
            if ($random.Next(3) -eq 0) {
                $isSchema = $random.Next(2) -eq 0
                $text = if ($isSchema) { '{"$schema": "https://json-schema.org/x"}' } else { '{"name": "json-schema.org"}' }
                $expected = if ($isSchema) { 'json-schema' } else { $null }
                Get-DocsConfigFileFormat -Path ($directory + 'file' + $random.Next(0, 9) + '.json') -Text $text | Should -Be $expected -Because "seed $seed, iteration $iteration"
            } else {
                $row = $table[$random.Next($table.Count)]
                Get-DocsConfigFileFormat -Path ($directory + $row.Name) -Text 'x: 1' | Should -Be $row.Format -Because "seed $seed, iteration $iteration, $($row.Name)"
            }
        }
    }
}

Describe 'Test-DocsEnvTemplatePath' {
    It 'accepts only the four template names, case-sensitively, in any directory' {
        foreach ($name in @('.env.example', '.env.sample', '.env.template', '.env.dist')) { Test-DocsEnvTemplatePath -Path "a/b/$name" | Should -BeTrue -Because $name }
        foreach ($name in @('.env', '.env.local', 'app.env', '.ENV.EXAMPLE', 'env.example', '.env.example.bak')) { Test-DocsEnvTemplatePath -Path "a/$name" | Should -BeFalse -Because $name }
        Test-DocsEnvTemplatePath -Path '' | Should -BeFalse
        Test-DocsEnvTemplatePath -Path $null | Should -BeFalse
    }

    It 'property: Test-DocsEnvTemplatePath accepts exactly the four template names under any directory' {
        $seed = 102242
        $random = [System.Random]::new($seed)
        $templates = @('.env.example', '.env.sample', '.env.template', '.env.dist')
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $directory = (@(1..$random.Next(0, 4) | ForEach-Object { 'p' + $random.Next(0, 5) }) + @('')) -join '/'
            switch ($random.Next(4)) {
                0 { $name = $templates[$random.Next(4)]; $expected = $true }
                1 { $name = '.env'; $expected = $false }
                2 { $name = '.env.' + 'v' + $random.Next(0, 100); $expected = $false }
                default { $name = 'n' + $random.Next(0, 100) + '.env'; $expected = $false }
            }
            Test-DocsEnvTemplatePath -Path ($directory + $name) | Should -Be $expected -Because "seed $seed, iteration $iteration, $name"
        }
    }
}

Describe 'Get-DocsEnvTemplateKey' {
    It 'reads the export prefix, quoted and multi-line values, empty values, blank and comment lines with line spans and never a value' {
        $result = Get-DocsEnvTemplateKey -Text "# c`n`n  export A = `"v`"`nB='x`ny`nz'`nC=`n  # indented comment`nD=plain value`n"
        @($result['Keys'] | ForEach-Object { $_['Name'] + ':' + $_['Span'][0] + '-' + $_['Span'][1] }) | Should -Be @('A:3-3', 'B:4-6', 'C:7-7', 'D:9-9')
        $result['Diagnostics'].Count | Should -Be 0
        foreach ($key in $result['Keys']) { @($key.Keys | Sort-Object) | Should -Be @('Name', 'Span') }
        $empty = Get-DocsEnvTemplateKey -Text ''
        $empty['Keys'].Count | Should -Be 0
        $empty['Diagnostics'].Count | Should -Be 0
    }

    It 'property: Get-DocsEnvTemplateKey returns every generated key once in order with its span and no value' {
        $seed = 102243
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 60; $iteration++) {
            $lines = [System.Collections.Generic.List[string]]::new()
            $expected = [System.Collections.Generic.List[string]]::new()
            $values = [System.Collections.Generic.List[string]]::new()
            $count = $random.Next(0, 10)
            for ($i = 0; $i -lt $count; $i++) {
                $name = 'KEY_' + $i
                $value = 'VALUE_' + $random.Next(0, 1000)
                $values.Add($value)
                $start = $lines.Count + 1
                switch ($random.Next(5)) {
                    0 { $lines.Add('# ' + $value); $lines.Add("$name=$value") ; $start++ }
                    1 { $lines.Add("export $name=`"$value`"") }
                    2 { $lines.Add("$name='$value"); $lines.Add("more $value'") }
                    3 { $lines.Add(''); $lines.Add("$name="); $start++ }
                    default { $lines.Add("$name=$value") }
                }
                $expected.Add($name + ':' + $start + '-' + $lines.Count)
            }
            $result = Get-DocsEnvTemplateKey -Text (($lines -join "`n") + "`n")
            @($result['Keys'] | ForEach-Object { $_['Name'] + ':' + $_['Span'][0] + '-' + $_['Span'][1] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
            $result['Diagnostics'].Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $rendered = ConvertTo-DocsCanonicalJson -Value @($result['Keys'])
            foreach ($value in $values) { $rendered.Contains($value) | Should -BeFalse -Because "seed $seed, iteration $iteration, value $value" }
        }
    }
}
