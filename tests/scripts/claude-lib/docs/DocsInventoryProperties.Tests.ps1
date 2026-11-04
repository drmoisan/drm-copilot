#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Seeded property tests over the inventory snapshot of issue #1022.

.DESCRIPTION
    Every property test uses [System.Random]::new($seed) and carries the seed in its failure
    message. The snapshot is built through Invoke-DocsInventoryCommand against the 1020 in-memory
    context with a fixed clock over both committed corpora (read in place). Covered: byte identity
    under permuted ListFile order and repeated builds; element_id and analysis_method invariants;
    source_sha256 against 1020 Get-DocsDeclarationSha256 with edits inside and outside line_range,
    line-ending variants and the whole-file architecture-component digest; marker values in every
    configuration value position never reaching the snapshot text; the 1,048,575 / 1,048,576 /
    1,048,577-byte size bound (the over-bound case is an IN_TEST_ROWS row); an unclassifiable
    Python input; case-distinct names with ordinal order under a culture whose collation differs;
    and the CORPUS_CODES census with the 1020 diagnostic code grammar.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSourceText.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerConfigFiles.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsInventory.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ProfilePath = Get-DocsDefaultProfilePath
    $script:CodePattern = '^[A-Z][A-Z0-9_]*$(?![\s\S])'

    function Read-TestCorpus {
        param([string] $Name)
        $parsed = ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText((Join-Path -Path $PSScriptRoot -ChildPath "fixtures/$Name"), [System.Text.UTF8Encoding]::new($false)))
        $parsed.Findings.Count | Should -Be 0 -Because "the committed corpus $Name parses"
        return $parsed.Value
    }
    $script:PythonCorpus = Read-TestCorpus -Name 'python-surface-corpus.json'
    $script:ConfigCorpus = Read-TestCorpus -Name 'config-surface-corpus.json'

    function Get-TestProfileText {
        param([string[]] $SourceRoot = @('src', 'config'), [string[]] $ElementKind)
        $starter = New-DocsStarterProfile -RepositoryId 'corpus'
        $starter['surface_selection']['source_roots'] = $SourceRoot
        if ($null -ne $ElementKind) { $starter['surface_selection']['element_kinds'] = $ElementKind }
        return ConvertTo-DocsJsonText -Value $starter -Indented
    }

    function Get-TestCorpusFile {
        $files = [ordered]@{ $script:ProfilePath = (Get-TestProfileText) }
        foreach ($key in $script:PythonCorpus['inputs'].Keys) { $files[[string] $key] = [string] $script:PythonCorpus['inputs'][$key] }
        foreach ($key in $script:ConfigCorpus['inputs'].Keys) { $files[[string] $key] = [string] $script:ConfigCorpus['inputs'][$key] }
        return $files
    }

    function Get-TestPermutedContext {
        # Wraps the in-memory context so that ListFile returns its paths in a seeded random order.
        param([object] $Context, [System.Random] $Random)
        $inner = $Context.ListFile
        $generator = $Random
        $listFile = {
            param($RelativeRoot)
            $paths = & $inner $RelativeRoot
            return , [string[]]@(@($paths) | Sort-Object -Property @{ Expression = { $generator.Next() } })
        }.GetNewClosure()
        return [pscustomobject]@{
            RepositoryRoot = $Context.RepositoryRoot
            ReadText       = $Context.ReadText
            ReadBytes      = $Context.ReadBytes
            TestFile       = $Context.TestFile
            ListFile       = $listFile
            WriteText      = $Context.WriteText
            UtcNow         = $Context.UtcNow
            InvokeProcess  = $Context.InvokeProcess
        }
    }

    function Invoke-TestInventory {
        param([System.Collections.IDictionary] $File, [hashtable] $Argument = @{}, [object] $Context)
        if ($null -eq $Context) { $Context = (New-DocsTestContext -File $File).Context }
        $result = Invoke-DocsInventoryCommand -Argument $Argument -Context $Context
        return @{ Result = $result; Snapshot = $result.Result.snapshot; Text = (ConvertTo-DocsJsonText -Value $result.Result.snapshot -Indented) }
    }

    function Get-TestLineRange {
        param([System.Collections.IDictionary] $Element)
        if ($null -eq $Element['line_range']) { return $null }
        return [int[]]@([int] $Element['line_range']['start'], [int] $Element['line_range']['end'])
    }
}

AfterAll {
    Remove-Module -Name DocsInventory, DocsInventorySnapshot, DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsYamlKeys, DocsTomlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonApi, DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsProfile, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Inventory snapshot properties over both corpora' {
    BeforeAll {
        $script:Files = Get-TestCorpusFile
        $script:Baseline = Invoke-TestInventory -File $script:Files
        $script:Baseline.Result.ExitCode | Should -Be 1 -Because 'both corpora carry blocking diagnostics by design'
    }

    It 'property: the snapshot text is byte-identical under permuted ListFile order and repeated builds with a fixed clock' {
        $seed = 102260
        $random = [System.Random]::new($seed)
        $repeat = Invoke-TestInventory -File $script:Files
        $repeat.Text | Should -BeExactly $script:Baseline.Text -Because "seed $seed, repeated build"
        for ($iteration = 0; $iteration -lt 2; $iteration++) {
            $context = Get-TestPermutedContext -Context (New-DocsTestContext -File $script:Files).Context -Random $random
            $permuted = Invoke-TestInventory -File $script:Files -Context $context
            $permuted.Text | Should -BeExactly $script:Baseline.Text -Because "seed $seed, iteration $iteration"
        }
        $script:Baseline.Snapshot['elements'].Count | Should -BeGreaterThan 100
    }

    It 'property: every element_id equals Get-DocsElementId of its kind, path and declaration and every element records analysis_method scanner' {
        $seed = 102261
        $random = [System.Random]::new($seed)
        $elements = @($script:Baseline.Snapshot['elements'] | Sort-Object -Property @{ Expression = { $random.Next() } })
        $elements.Count | Should -BeGreaterThan 100
        foreach ($element in $elements) {
            $element['element_id'] | Should -BeExactly (Get-DocsElementId -Kind $element['kind'] -Path $element['path'] -Declaration $element['declaration']) -Because "seed $seed, $($element['declaration'])"
            $element['analysis_method'] | Should -BeExactly 'scanner' -Because "seed $seed, $($element['declaration'])"
        }
    }

    It 'property: every source_sha256 equals Get-DocsDeclarationSha256 over the captured text and line_range; an edit inside the range changes it, an edit outside or a line-ending variant does not, and an architecture-component changes for an edit anywhere' {
        $seed = 102262
        $random = [System.Random]::new($seed)
        foreach ($element in $script:Baseline.Snapshot['elements']) {
            $text = [string] $script:Files[[string] $element['path']]
            $range = Get-TestLineRange -Element $element
            $element['source_sha256'] | Should -BeExactly (Get-DocsDeclarationSha256 -Text $text -LineRange $range) -Because "seed $seed, $($element['declaration'])"
            if ($element['kind'] -ceq 'architecture-component') { $range | Should -BeNullOrEmpty -Because "seed $seed, $($element['declaration'])" }
        }
        $sample = @($script:Baseline.Snapshot['elements'] | Sort-Object -Property @{ Expression = { $random.Next() } } | Select-Object -First 40)
        foreach ($element in $sample) {
            $text = [string] $script:Files[[string] $element['path']]
            $range = Get-TestLineRange -Element $element
            [string[]] $sourceLines = ConvertTo-DocsSourceLine -Text $text
            $lines = [System.Collections.Generic.List[string]]::new($sourceLines)
            $because = "seed $seed, $($element['kind']) $($element['declaration']) range $(if ($null -eq $range) { 'null' } else { $range -join '-' })"
            $digest = [string] $element['source_sha256']
            $withinLines = if ($null -eq $range) { @(1..$lines.Count) } else { @($range[0]..$range[1]) }
            $inside = $withinLines[$random.Next($withinLines.Count)]
            $edited = [System.Collections.Generic.List[string]]::new($lines)
            $edited[$inside - 1] = $edited[$inside - 1] + ' # edited'
            (Get-DocsDeclarationSha256 -Text (($edited -join "`n") + "`n") -LineRange $range) | Should -Not -BeExactly $digest -Because "$because, edit inside at line $inside"
            if ($null -ne $range) {
                $outsideLines = @(1..$lines.Count | Where-Object { $_ -lt $range[0] -or $_ -gt $range[1] })
                if ($outsideLines.Count -gt 0) {
                    $outside = $outsideLines[$random.Next($outsideLines.Count)]
                    $edited = [System.Collections.Generic.List[string]]::new($lines)
                    $edited[$outside - 1] = $edited[$outside - 1] + ' # edited'
                    (Get-DocsDeclarationSha256 -Text (($edited -join "`n") + "`n") -LineRange $range) | Should -BeExactly $digest -Because "$because, edit outside at line $outside"
                }
            }
            $crlf = ($lines -join "`r`n") + "`r`n"
            $cr = ($lines -join "`r") + "`r"
            $lf = ($lines -join "`n")
            (Get-DocsDeclarationSha256 -Text $crlf -LineRange $range) | Should -BeExactly $digest -Because "$because, CRLF variant"
            (Get-DocsDeclarationSha256 -Text $cr -LineRange $range) | Should -BeExactly $digest -Because "$because, CR variant"
            if ($lines[$lines.Count - 1].Length -gt 0) { (Get-DocsDeclarationSha256 -Text $lf -LineRange $range) | Should -BeExactly $digest -Because "$because, no trailing newline" }
            (Get-DocsDeclarationSha256 -Text ([string][char]0xFEFF + $lf + "`n") -LineRange $range) | Should -BeExactly $digest -Because "$because, BOM variant"
        }
        # The analyzer path (through the registry, because Invoke-DocsAnalyzer re-imports the analyzer
        # module with -Force): an edit inside a key's range changes the emitted element digest, an edit outside does not.
        $registry = Get-DocsAnalyzerRegistration
        $configRow = @($registry | Where-Object { [string] $_.Id -ceq 'config-files' })[0]
        $analyze = { param($Text) Invoke-DocsAnalyzer -Registration $configRow -CapturedInput @(New-DocsCapturedInput -Path 'config/app.yaml' -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($Text))) -Selection $null }
        $original = & $analyze "database:`n  host: MARKER_HOST`n  port: 5432`nnote: |`n  MARKER_BLOCK`n"
        $insideEdit = & $analyze "database:`n  host: MARKER_OTHER`n  port: 5432`nnote: |`n  MARKER_BLOCK`n"
        $outsideEdit = & $analyze "database:`n  host: MARKER_HOST`n  port: 5432`nnote: |`n  MARKER_CHANGED`n"
        $hostOf = { param($Output) @($Output.Elements | Where-Object { $_['declaration'] -ceq 'database.host' })[0] }
        (& $hostOf $insideEdit)['source_sha256'] | Should -Not -BeExactly (& $hostOf $original)['source_sha256'] -Because "seed $seed, analyzer edit inside"
        (& $hostOf $outsideEdit)['source_sha256'] | Should -BeExactly (& $hostOf $original)['source_sha256'] -Because "seed $seed, analyzer edit outside"
        (& $hostOf $insideEdit)['element_id'] | Should -BeExactly (& $hostOf $original)['element_id'] -Because "seed $seed, the identifier ignores the digest"
    }

    It 'property: marker values in every TOML, template env, JSON Schema and YAML value position never appear in the snapshot text and element properties carry only key and shape names' {
        $seed = 102263
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $markers = [System.Collections.Generic.List[string]]::new()
            $next = { $value = 'MK' + $random.Next(100000, 999999) + 'Z'; $markers.Add($value); return $value }
            $files = [ordered]@{
                $script:ProfilePath     = (Get-TestProfileText -SourceRoot @('config') -ElementKind @('config-key'))
                'config/pyproject.toml' = "[project]`nname = `"$(& $next)`"`n[tool.black]`nline-length = 88`ntarget = [`"$(& $next)`"]`n[tool.poetry]`nname = `"$(& $next)`"`n[tool.ruff]`nselect = [`"$(& $next)`", `"$(& $next)`"]`ninline = { nested = `"$(& $next)`" }`n[[tool.mypy.overrides]]`nmodule = `"$(& $next)`"`n"
                'config/.env.example'   = "# $(& $next)`nexport KEY=`"$(& $next)`"`nPLAIN=$(& $next)`nMULTI='first $(& $next)`nsecond $(& $next)'`nEMPTY=`n"
                'config/.env'           = "SECRET=$(& $next)`n"
                'config/s.schema.json'  = "{`n  `"type`": `"object`",`n  `"required`": [`"name`"],`n  `"properties`": {`n    `"name`": {`"type`": `"string`", `"default`": `"$(& $next)`", `"pattern`": `"$(& $next)`", `"description`": `"$(& $next)`"},`n    `"mode`": {`"enum`": [`"$(& $next)`"], `"const`": `"$(& $next)`", `"examples`": [`"$(& $next)`"]},`n    `"nested`": {`"type`": `"object`", `"properties`": {`"flag`": {`"type`": `"boolean`", `"default`": `"$(& $next)`"}}}`n  }`n}`n"
                'config/app.yaml'       = "database:`n  host: $(& $next)`n  port: 5432`nfeatures:`n  - $(& $next)`n  - name: $(& $next)`n    enabled: true`nflow: [$(& $next)]`nnote: |`n  $(& $next)`nquoted: `"$(& $next)`"`n"
            }
            $run = Invoke-TestInventory -File $files
            $run.Result.ExitCode | Should -Be 0 -Because "seed $seed, iteration $iteration"
            $run.Snapshot['elements'].Count | Should -BeGreaterThan 15 -Because "seed $seed, iteration $iteration"
            $markers.Count | Should -BeGreaterThan 20
            foreach ($marker in $markers) { $run.Text.Contains($marker) | Should -BeFalse -Because "seed $seed, iteration $iteration, marker $marker" }
            foreach ($element in $run.Snapshot['elements']) {
                foreach ($property in $element['properties']) { @('format', 'value_type', 'schema_type', 'required', 'conditional') | Should -Contain $property['name'] -Because "seed $seed, iteration $iteration, $($element['declaration'])" }
            }
            @($run.Snapshot['diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] } | Sort-Object) | Should -Be @('ENV_FILE_NOT_CAPTURED|config/.env', 'TOML_INLINE_TABLE_NOT_EXPANDED|config/pyproject.toml', 'YAML_FLOW_COLLECTION_NOT_EXPANDED|config/app.yaml') -Because "seed $seed, iteration $iteration"
        }
    }

    It 'property: inputs of 1,048,575 and 1,048,576 bytes are accepted and 1,048,577 bytes yields the over-bound code with no element and no inputs entry' {
        $seed = 102264
        $random = [System.Random]::new($seed)
        foreach ($size in @(1048575, 1048576, 1048577)) {
            $filler = [string][char] (97 + $random.Next(26))
            $comment = '# ' + [string]::new($filler, $size - 3) + "`n"
            [System.Text.UTF8Encoding]::new($false).GetByteCount($comment) | Should -Be $size
            $files = [ordered]@{ $script:ProfilePath = (Get-TestProfileText -SourceRoot @('src') -ElementKind @('public-symbol')); 'src/big.py' = $comment; 'src/ok.py' = "value = 1`n" }
            $run = Invoke-TestInventory -File $files -Argument @{ Analyzer = [string[]]@('python-public-api') }
            $because = "seed $seed, size $size, filler $filler"
            $run.Result.ExitCode | Should -Be 0 -Because $because
            $inputs = @($run.Snapshot['inputs'] | ForEach-Object { $_['path'] })
            $elementPaths = @($run.Snapshot['elements'] | ForEach-Object { $_['path'] })
            $codes = @($run.Snapshot['diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] })
            if ($size -le 1048576) {
                $inputs | Should -Be @('src/big.py', 'src/ok.py') -Because $because
                @($run.Snapshot['inputs'] | Where-Object { $_['path'] -ceq 'src/big.py' })[0]['size'] | Should -Be $size -Because $because
                $codes | Should -BeNullOrEmpty -Because $because
            } else {
                $inputs | Should -Be @('src/ok.py') -Because $because
                $codes | Should -Be @('DOCS_INPUT_TOO_LARGE|src/big.py') -Because $because
                $run.Snapshot['diagnostics'][0]['blocking'] | Should -BeFalse -Because $because
                $run.Snapshot['diagnostics'][0]['analyzer_id'] | Should -BeExactly 'docs-capture' -Because $because
            }
            $elementPaths | Should -Be @('src/ok.py') -Because $because
        }
    }

    It 'property: an unclassifiable Python input yields PYTHON_LEXER_UNCLASSIFIED with no element from that file while another file keeps its elements' {
        $seed = 102265
        $random = [System.Random]::new($seed)
        foreach ($iteration in 0..2) {
            $character = @('$', '?', '`')[$random.Next(3)]
            $files = [ordered]@{ $script:ProfilePath = (Get-TestProfileText -SourceRoot @('src') -ElementKind @('public-symbol')); 'src/bad.py' = "def kept():`n    pass`nvalue = $character`n"; 'src/ok.py' = "other = 1`n" }
            $run = Invoke-TestInventory -File $files -Argument @{ Analyzer = [string[]]@('python-public-api') }
            $because = "seed $seed, iteration $iteration, character $character"
            $run.Result.ExitCode | Should -Be 1 -Because $because
            @($run.Snapshot['diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] + '|' + $_['blocking'] }) | Should -Be @('PYTHON_LEXER_UNCLASSIFIED|src/bad.py|True') -Because $because
            @($run.Snapshot['elements'] | ForEach-Object { $_['path'] }) | Should -Be @('src/ok.py') -Because $because
            @($run.Result.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_INVENTORY_BLOCKING_DIAGNOSTIC') -Because $because
        }
    }
}

Describe 'Ordinal ordering under a differing culture' {
    BeforeAll {
        $script:OriginalCulture = [System.Globalization.CultureInfo]::CurrentCulture
        $script:OriginalUiCulture = [System.Globalization.CultureInfo]::CurrentUICulture
    }

    AfterAll {
        [System.Globalization.CultureInfo]::CurrentCulture = $script:OriginalCulture
        [System.Globalization.CultureInfo]::CurrentUICulture = $script:OriginalUiCulture
    }

    It 'property: App and app stay distinct and the element, input and diagnostic order equals ordinal order with CurrentCulture set to a culture whose collation differs' {
        $seed = 102266
        $random = [System.Random]::new($seed)
        $culture = [System.Globalization.CultureInfo]::GetCultureInfo(@('da-DK', 'sv-SE', 'tr-TR')[$random.Next(3)])
        [System.Globalization.CultureInfo]::CurrentCulture = $culture
        [string[]] $cultureSorted = @('src/B.py', 'src/a.py')
        [Array]::Sort($cultureSorted, [System.StringComparer]::CurrentCulture)
        $cultureSorted | Should -Be @('src/a.py', 'src/B.py') -Because "seed $seed, $($culture.Name) sorts case-insensitively unlike ordinal"
        for ($iteration = 0; $iteration -lt 3; $iteration++) {
            $suffix = [string] $random.Next(0, 1000)
            $files = [ordered]@{
                $script:ProfilePath = (Get-TestProfileText -SourceRoot @('src') -ElementKind @('public-symbol', 'architecture-component'))
                'src/a.py'          = "class App$suffix`:`n    pass`n`ndef app$suffix():`n    pass`n`nAPP = 1`n"
                'src/B.py'          = "value = `$`n"
                'src/i.py'          = "I = 1`ni = 2`n"
            }
            $run = Invoke-TestInventory -File $files
            $because = "seed $seed, iteration $iteration, culture $($culture.Name)"
            [string[]] $declarations = @($run.Snapshot['elements'] | Where-Object { $_['kind'] -ceq 'public-symbol' } | ForEach-Object { [string] $_['declaration'] })
            [Array]::Sort($declarations, [System.StringComparer]::Ordinal)
            ($declarations -join ',') | Should -BeExactly "a.APP,a.App$suffix,a.app$suffix,i.I,i.i" -Because $because
            @($run.Snapshot['elements'] | Where-Object { $_['declaration'] -cmatch '^a\.[Aa]pp[0-9]+$' }).Count | Should -Be 2 -Because "$because, App and app are distinct elements"
            [string[]] $ids = @($run.Snapshot['elements'] | ForEach-Object { [string] $_['element_id'] })
            [string[]] $ordinal = [string[]] $ids.Clone()
            [Array]::Sort($ordinal, [System.StringComparer]::Ordinal)
            ($ids -join ',') | Should -BeExactly ($ordinal -join ',') -Because "$because, elements"
            @($run.Snapshot['inputs'] | ForEach-Object { $_['path'] }) | Should -Be @('src/B.py', 'src/a.py', 'src/i.py') -Because "$because, inputs in ordinal order"
            [string[]] $diagnosticIds = @($run.Snapshot['diagnostics'] | ForEach-Object { [string] $_['id'] })
            [string[]] $ordinalDiagnostics = [string[]] $diagnosticIds.Clone()
            [Array]::Sort($ordinalDiagnostics, [System.StringComparer]::Ordinal)
            ($diagnosticIds -join ',') | Should -BeExactly ($ordinalDiagnostics -join ',') -Because "$because, diagnostics"
            [System.Globalization.CultureInfo]::CurrentCulture.Name | Should -BeExactly $culture.Name -Because "$because, the culture stays set during the run"
        }
    }
}

Describe 'Corpus census' {
    It 'every CORPUS_CODES code has at least one python corpus expected_diagnostics entry, every expected code in both corpora matches the 1020 grammar, and the four IN_TEST_ROWS are proven in test code' {
        # IN_TEST_ROWS (no corpus entry, proven by inputs built in test code): DOCS_INPUT_TOO_LARGE and
        # DOCS_INPUT_NOT_UTF8 (the two 1020 capture rows; [P4-T3] DocsInventorySnapshot.Tests.ps1 and
        # [P4-T6] this suite), PYTHON_TOKEN_LIMIT ([P1-T2] DocsPythonTokens.Tests.ps1) and
        # ARCHITECTURE_EDGE_LIMIT ([P3-T8] DocsAnalyzerArchitecture.Tests.ps1).
        $corpusCodes = @(
            'PYTHON_ENCODING_UNSUPPORTED', 'PYTHON_LEXER_UNTERMINATED', 'PYTHON_LEXER_UNCLASSIFIED', 'PYTHON_INDENTATION_INVALID', 'PYTHON_IDENTIFIER_NON_ASCII', 'PYTHON_IMPORT_STAR_FRAMEWORK', 'PYTHON_IMPORT_NESTED_FRAMEWORK', 'PYTHON_BINDING_AMBIGUOUS',
            'CLI_DYNAMIC_REGISTRATION', 'CLI_REGISTRATION_IN_LOOP', 'CLI_UNBOUND_REGISTRATION', 'CLI_PARENTS_UNRESOLVED', 'CLI_CUSTOM_CLASS', 'CLI_DECORATOR_INDIRECT', 'CLI_TYPER_PARAMETER_UNRESOLVED', 'CLI_CONSOLE_SCRIPT_UNSUPPORTED',
            'HTTP_DYNAMIC_ROUTE', 'HTTP_PREFIX_DYNAMIC', 'HTTP_ROUTE_IN_LOOP', 'HTTP_MOUNT_UNRESOLVED', 'HTTP_UNBOUND_ROUTE', 'HTTP_METHOD_VIEW_UNRESOLVED', 'HTTP_INCLUDE_UNRESOLVED',
            'PUBLIC_API_DYNAMIC_ALL', 'PUBLIC_API_NAME_UNRESOLVED', 'PUBLIC_API_STAR_IMPORT', 'PUBLIC_API_CONDITIONAL_DEFINITION', 'PUBLIC_API_UNPACKING_TARGET', 'PUBLIC_API_MODULE_NOT_IMPORTABLE',
            'ARCHITECTURE_DYNAMIC_IMPORT', 'ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED', 'ARCHITECTURE_MODULE_NAME_INVALID'
        )
        $inTestRows = @('DOCS_INPUT_TOO_LARGE', 'DOCS_INPUT_NOT_UTF8', 'PYTHON_TOKEN_LIMIT', 'ARCHITECTURE_EDGE_LIMIT')
        $corpusCodes.Count | Should -Be 32
        $pythonCodes = @($script:PythonCorpus['expected_diagnostics'] | ForEach-Object { [string] $_['code'] })
        foreach ($code in $corpusCodes) {
            $code | Should -Match $script:CodePattern
            @($pythonCodes | Where-Object { $_ -ceq $code }).Count | Should -BeGreaterThan 0 -Because "code $code has a corpus entry"
            $inTestRows | Should -Not -Contain $code
        }
        foreach ($code in $inTestRows) { @($pythonCodes | Where-Object { $_ -ceq $code }).Count | Should -Be 0 -Because "in-test row $code has no corpus entry" }
        foreach ($entry in @($script:PythonCorpus['expected_diagnostics']) + @($script:ConfigCorpus['expected_diagnostics'])) {
            [string] $entry['code'] | Should -Match $script:CodePattern -Because "$($entry['code']) at $($entry['path'])"
        }
    }
}
