#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerPythonCli.psm1 (issue #1022).

.DESCRIPTION
    Compares the python-cli analyzer output with the python-cli subset of the committed corpus
    tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json on every element field and
    every diagnostic (code, path, analyzer_id); asserts that every cli-option parent is a
    cli-command, the console-script root of an attached tree, attached: false, input
    non-mutation, the root-name order and the element candidate shape, each exported function
    with a seeded property test. The corpus is read in place; other inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonCli.psm1') -Force -ErrorAction Stop

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
}

AfterAll {
    Remove-Module -Name DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsTomlKeys, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsAnalyzerPythonCli' {
    BeforeAll {
        $script:Captured = ConvertTo-TestCaptured -Source $script:Corpus['inputs']
        $script:Before = ConvertTo-DocsCanonicalJson -Value $script:Captured
        $script:Output = Invoke-DocsAnalyzerPythonCli -CapturedInput $script:Captured -Selection $script:Selection
    }

    It 'matches the python-cli subset of the corpus on every element field and every diagnostic' {
        Compare-TestCorpus -Output $script:Output -AnalyzerId 'python-cli'
    }

    It 'gives every cli-option a cli-command parent and records analysis_method scanner on every element' {
        $commands = @{}
        foreach ($element in $script:Output['Elements']) { if ([string] $element['kind'] -ceq 'cli-command') { $commands[[string] $element['element_id']] = $true } }
        foreach ($element in $script:Output['Elements']) {
            $element['analysis_method'] | Should -BeExactly 'scanner'
            if ([string] $element['kind'] -ceq 'cli-option') { $commands.ContainsKey([string] $element['parent_id']) | Should -BeTrue -Because "option $($element['declaration']) has a command parent" }
        }
    }

    It 'makes the console script the root of an attached tree and emits the attached root only once' {
        $byDeclaration = @{}
        foreach ($element in $script:Output['Elements']) { $byDeclaration[[string] $element['path'] + '|' + [string] $element['declaration']] = $element }
        $tool = $byDeclaration['pyproject.toml|tool']
        @($tool['properties'] | Where-Object { $_['name'] -ceq 'attached' })[0]['value'] | Should -BeTrue
        $run = $byDeclaration['src/pkg/_cli_argparse.py|tool run']
        $run['parent_id'] | Should -BeExactly $tool['element_id']
        @($script:Output['Elements'] | Where-Object { [string] $_['declaration'] -ceq 'argtool' }).Count | Should -Be 0
        @($script:Output['Elements'] | Where-Object { [string] $_['declaration'] -ceq 'typ' }).Count | Should -Be 0
        $byDeclaration['src/pkg/_cli_typer.py|typ-script sub']['parent_id'] | Should -BeExactly $byDeclaration['pyproject.toml|typ-script']['element_id']
    }

    It 'records attached: false for a missing module, a non-root attribute and an absent attribute, and never exports the target' {
        foreach ($name in 'missing', 'gui', 'poet') {
            $element = @($script:Output['Elements'] | Where-Object { [string] $_['declaration'] -ceq $name })[0]
            @($element['properties'] | Where-Object { $_['name'] -ceq 'attached' })[0]['value'] | Should -BeFalse -Because "$name is not attached"
            @($element['properties'] | Where-Object { [string] $_['value'] -clike '*:*' }).Count | Should -Be 0
        }
        (ConvertTo-DocsCanonicalJson -Value $script:Output['Elements']) | Should -Not -Match 'nowhere'
    }

    It 'does not mutate the captured inputs' {
        (ConvertTo-DocsCanonicalJson -Value $script:Captured) | Should -BeExactly $script:Before
    }

    It 'removes the elements of a file with a blocking front-end diagnostic and keeps the other files' {
        $output = Invoke-DocsAnalyzerPythonCli -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'a.py' = "import click`n@click.command(name='a')`ndef a():`n    pass`nx = 'open"; 'b.py' = "import click`n@click.command(name='b')`ndef b():`n    pass`n" })) -Selection $null
        @($output['Elements'] | ForEach-Object { $_['declaration'] }) | Should -Be @('b')
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('PYTHON_LEXER_UNTERMINATED|a.py')
        $output['Diagnostics'][0]['blocking'] | Should -BeTrue
        $output['Diagnostics'][0]['analyzer_id'] | Should -BeExactly 'python-cli'
    }

    It 'names an unattached root without a literal by its module dotted name and reports a duplicate declaration once' {
        $output = Invoke-DocsAnalyzerPythonCli -CapturedInput (ConvertTo-TestCaptured -Source ([ordered]@{ 'src/tool/cli.py' = "import click`n@click.command()`ndef one():`n    pass`n@click.command()`ndef two():`n    pass`n" })) -Selection @{ source_roots = @('src') }
        @($output['Elements'] | ForEach-Object { $_['declaration'] }) | Should -Be @('tool.cli')
        @($output['Elements'][0]['properties'] | Where-Object { $_['name'] -ceq 'name_source' })[0]['value'] | Should -BeExactly 'module'
        @($output['Diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['analyzer_id'] }) | Should -Be @('DUPLICATE_DECLARATION|docs-inventory')
    }

    It 'ignores captured inputs whose text is null and non-Python paths' {
        $captured = @((New-DocsCapturedInput -Path 'big.py' -Bytes ([System.Text.Encoding]::UTF8.GetBytes('x = 1')) -MaxBytes 2), (New-DocsCapturedInput -Path 'notes.txt' -Bytes ([System.Text.Encoding]::UTF8.GetBytes('import click'))))
        $output = Invoke-DocsAnalyzerPythonCli -CapturedInput $captured -Selection $null
        $output['Elements'].Count | Should -Be 0
        $output['Diagnostics'].Count | Should -Be 0
    }

    It 'property: Invoke-DocsAnalyzerPythonCli output is byte-identical under permuted input order' {
        $seed = 102260
        $random = [System.Random]::new($seed)
        $baseline = ConvertTo-DocsCanonicalJson -Value @{ Elements = @($script:Output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $script:Output['Diagnostics'] }
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $permuted = @($script:Captured | Sort-Object -Property @{ Expression = { $random.Next() } })
            $output = Invoke-DocsAnalyzerPythonCli -CapturedInput $permuted -Selection $script:Selection
            (ConvertTo-DocsCanonicalJson -Value @{ Elements = @($output['Elements'] | Sort-Object -Property @{ Expression = { $_['element_id'] } }); Diagnostics = $output['Diagnostics'] }) | Should -BeExactly $baseline -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Resolve-DocsCliRootName' {
    It 'applies the order console-script, literal, module and returns $null without any name' {
        (Resolve-DocsCliRootName -Site @{ Name = 'lit' } -ScriptName 'script' -ModuleName 'pkg.mod')['Name'] | Should -BeExactly 'script'
        (Resolve-DocsCliRootName -Site @{ Name = 'lit' } -ScriptName 'script' -ModuleName 'pkg.mod')['Source'] | Should -BeExactly 'console-script'
        (Resolve-DocsCliRootName -Site @{ Name = 'lit' } -ModuleName 'pkg.mod')['Source'] | Should -BeExactly 'literal'
        (Resolve-DocsCliRootName -Site @{ Name = $null } -ModuleName 'pkg.mod')['Name'] | Should -BeExactly 'pkg.mod'
        (Resolve-DocsCliRootName -Site @{ Name = $null } -ModuleName 'pkg.mod')['Source'] | Should -BeExactly 'module'
        Resolve-DocsCliRootName -Site @{ Name = $null } -ModuleName $null | Should -BeNullOrEmpty
    }

    It 'property: Resolve-DocsCliRootName picks the first present name in the fixed order' {
        $seed = 102261
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $script = if ($random.Next(2) -eq 0) { 's' + $random.Next(100) } else { $null }
            $literal = if ($random.Next(2) -eq 0) { 'l' + $random.Next(100) } else { $null }
            $module = if ($random.Next(2) -eq 0) { 'm' + $random.Next(100) } else { $null }
            $result = Resolve-DocsCliRootName -Site @{ Name = $literal } -ScriptName $script -ModuleName $module
            $expected = if ($null -ne $script) { @($script, 'console-script') } elseif ($null -ne $literal) { @($literal, 'literal') } elseif ($null -ne $module) { @($module, 'module') } else { $null }
            if ($null -eq $expected) { $result | Should -BeNullOrEmpty -Because "seed $seed, iteration $iteration" }
            else { @($result['Name'], $result['Source']) | Should -Be $expected -Because "seed $seed, iteration $iteration" }
        }
    }
}

Describe 'ConvertTo-DocsCliElement' {
    It 'builds a candidate whose parameters produce the expected element through New-DocsSurfaceElement' {
        $site = @{ Kind = 'option'; Name = '--x'; Span = @(2, 3); Line = 2 }
        $parent = Get-DocsElementId -Kind 'cli-command' -Path 'a.py' -Declaration 'root'
        $candidate = ConvertTo-DocsCliElement -Site $site -Declaration 'root --x' -Path 'a.py' -SourceText "a`nb`nc`n" -ParentId $parent -Property @{ framework = 'click' }
        $candidate['Line'] | Should -Be 2
        $candidate['Parameter']['Kind'] | Should -BeExactly 'cli-option'
        $candidate['Parameter']['LineRange'] | Should -Be @(2, 3)
        $splat = $candidate['Parameter']
        $element = New-DocsSurfaceElement @splat
        $element['name'] | Should -BeExactly '--x'
        $element['parent_id'] | Should -BeExactly $parent
        $element['source_sha256'] | Should -BeExactly (Get-DocsDeclarationSha256 -Text "a`nb`nc`n" -LineRange @(2, 3))
        $command = ConvertTo-DocsCliElement -Site @{ Kind = 'command'; Span = @(1, 1); Line = 1 } -Declaration 'root sub' -Path 'a.py' -SourceText 'x' -ParentId $null -Property @{}
        $command['Parameter']['Kind'] | Should -BeExactly 'cli-command'
        $command['Parameter']['Name'] | Should -BeExactly 'sub'
        $command['Parameter']['ParentId'] | Should -BeNullOrEmpty
    }

    It 'property: ConvertTo-DocsCliElement line range equals the site span and the name is the last declaration segment' {
        $seed = 102262
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $start = $random.Next(1, 50)
            $end = $start + $random.Next(0, 5)
            $segments = @(1..$random.Next(1, 4) | ForEach-Object { 'seg' + $random.Next(100) })
            $candidate = ConvertTo-DocsCliElement -Site @{ Kind = 'command'; Span = @($start, $end); Line = $start } -Declaration ($segments -join ' ') -Path 'a.py' -SourceText 'x' -ParentId $null -Property @{}
            $candidate['Parameter']['LineRange'] | Should -Be @($start, $end) -Because "seed $seed, iteration $iteration"
            $candidate['Parameter']['Name'] | Should -BeExactly $segments[-1] -Because "seed $seed, iteration $iteration"
        }
    }
}
