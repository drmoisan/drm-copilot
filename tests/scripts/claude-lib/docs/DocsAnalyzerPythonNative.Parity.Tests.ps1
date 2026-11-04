#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-language parity tests for the issue #1031 native analyzers (S1, S12).

.DESCRIPTION
    A canned helper response is built from the 1022 corpus .py rows of the four Python
    identifiers plus the 1031 native_only_elements, converted with
    ConvertFrom-DocsPythonNativeResponse and run through 1020 Invoke-DocsAnalyzer with
    in-memory native rows and the non-forcing -ImportModule seam. Every shared row must carry
    the corpus element_id and source_sha256, which also equal the 1022 scanner output for the
    same inputs. The scanner must report native_input_scanner_diagnostics for the native
    inputs, and the two new module texts must contain no digest or canonical-JSON primitive.
    The three corpus files that no supported interpreter parses (lex_indent, lex_unclassified,
    lex_unterminated) are reported as parse-error in the canned response.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonNativeProtocol.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonNative.psm1') -Force -ErrorAction Stop
    # Non-forcing, so the suite's own import survives; -Global, so Get-Command inside the
    # registry module resolves the analyzer function when the runner hosts the test in a module.
    $script:NonForcingImport = { param($Path) Import-Module -Name $Path -Global -ErrorAction Stop }
    $script:Ids = [string[]]@('python-architecture', 'python-cli', 'python-http', 'python-public-api')
    $script:Unparsed = [string[]]@('src/pkg/lex_indent.py', 'src/pkg/lex_unclassified.py', 'src/pkg/lex_unterminated.py')

    function Read-TestFixture {
        param([string] $Name)
        $parsed = ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText((Join-Path -Path $PSScriptRoot -ChildPath "fixtures/$Name"), [System.Text.UTF8Encoding]::new($false)))
        $parsed.Findings.Count | Should -Be 0 -Because "the committed fixture $Name parses"
        return $parsed.Value
    }

    $script:Surface = Read-TestFixture -Name 'python-surface-corpus.json'
    $script:Native = Read-TestFixture -Name 'python-native-corpus.json'
    $script:Roots = [string[]]@(@($script:Surface['source_roots']) + @($script:Native['native_source_roots']))
    $sources = [ordered]@{}
    foreach ($key in $script:Surface['inputs'].Keys) { $sources[[string] $key] = $script:Surface['inputs'][$key] }
    foreach ($key in $script:Native['native_inputs'].Keys) { $sources[[string] $key] = $script:Native['native_inputs'][$key] }
    $script:Captured = [object[]]@(foreach ($key in $sources.Keys) { New-DocsCapturedInput -Path ([string] $key) -Bytes ([System.Text.Encoding]::UTF8.GetBytes([string] $sources[$key])) })
    $script:Selection = @{}
    $script:Selection['source_roots'] = $script:Roots

    function ConvertTo-TestFact {
        param([System.Collections.IDictionary] $Row)
        $properties = [ordered]@{}
        foreach ($property in @($Row['properties'])) { $properties[[string] $property['name']] = $property['value'] }
        $parent = $null
        if ($null -ne $Row['parent_declaration']) { $parent = [ordered]@{ declaration = $Row['parent_declaration']; kind = 'cli-command'; path = $Row['parent_path'] } }
        $range = $Row['line_range']
        return [ordered]@{
            analyzer_id = $Row['analyzer_id']; declaration = $Row['declaration']; kind = $Row['kind']; name = $Row['name']; parent = $parent; properties = $properties
            line_end    = $(if ($null -eq $range) { $null } else { $range['end'] }); line_start = $(if ($null -eq $range) { $null } else { $range['start'] })
        }
    }

    function Get-TestResponseText {
        $facts = @{}
        foreach ($row in @(@($script:Surface['expected_elements']) + @($script:Native['native_only_elements']))) {
            $path = [string] $row['path']
            if (-not $path.EndsWith('.py', [System.StringComparison]::Ordinal) -or $script:Ids -cnotcontains [string] $row['analyzer_id']) { continue }
            if (-not $facts.ContainsKey($path)) { $facts[$path] = [System.Collections.Generic.List[object]]::new() }
            $facts[$path].Add((ConvertTo-TestFact -Row $row))
        }
        $request = New-DocsPythonNativeRequest -CapturedInput $script:Captured -AnalyzerId $script:Ids -SourceRoot $script:Roots -ConsoleScript @($script:Native['console_scripts'])
        $files = foreach ($path in $request.Paths) {
            $status = if ($script:Unparsed -ccontains $path) { 'parse-error' } else { 'ok' }
            [ordered]@{ diagnostics = @(); facts = [object[]]@(if ($facts.ContainsKey($path)) { $facts[$path] }); path = $path; status = $status }
        }
        return @{ Text = (ConvertTo-DocsCanonicalJson -Value ([ordered]@{ files = @($files); protocol_version = 1 })); Request = $request }
    }

    function Get-TestNativeRow {
        param([string] $Id)
        $suffix = @{ 'python-architecture' = 'Architecture'; 'python-cli' = 'Cli'; 'python-http' = 'Http'; 'python-public-api' = 'Api' }[$Id]
        # Get-DocsAnalyzerRegistration returns a comma-wrapped array: assign it first, never pipe it directly.
        $registration = Get-DocsAnalyzerRegistration
        $scanner = @($registration | Where-Object { $_.Id -ceq $Id -and $_.AnalysisMethod -ceq 'scanner' })[0]
        return [pscustomobject]@{ Id = $Id; Version = '1.0.0'; AnalysisMethod = 'native'; ElementKinds = $scanner.ElementKinds; Module = (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonNative.psm1'); Function = "Invoke-DocsAnalyzerPythonNative$suffix" }
    }

    $canned = Get-TestResponseText
    $check = Test-DocsPythonNativeResponse -ResponseText $canned.Text -Request $canned.Request
    $check.Valid | Should -BeTrue -Because $check.Problem
    $converted = ConvertFrom-DocsPythonNativeResponse -Response $check.Response -CapturedInput $script:Captured
    $script:NativeSelection = @{}
    $script:NativeSelection['source_roots'] = $script:Roots
    $script:NativeSelection['python_native'] = $converted.Output
    $script:NativeOutput = @{}
    $script:ScannerOutput = @{}
    $registry = Get-DocsAnalyzerRegistration
    foreach ($id in $script:Ids) {
        $script:NativeOutput[$id] = Invoke-DocsAnalyzer -Registration (Get-TestNativeRow -Id $id) -CapturedInput $script:Captured -Selection $script:NativeSelection -ImportModule $script:NonForcingImport
        $scannerRow = @($registry | Where-Object { $_.Id -ceq $id -and $_.AnalysisMethod -ceq 'scanner' })[0]
        $script:ScannerOutput[$id] = Invoke-DocsAnalyzer -Registration $scannerRow -CapturedInput $script:Captured -Selection $script:Selection -ImportModule $script:NonForcingImport
    }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerPythonNative, DocsPythonNativeProtocol, DocsTomlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonApi, DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsAnalyzerRegistry, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Native and scanner parity over the shared corpus' {
    It 'gives every shared <Id> row the corpus element_id and source_sha256, equal to the scanner output' -ForEach @(
        @{ Id = 'python-architecture' }, @{ Id = 'python-cli' }, @{ Id = 'python-http' }, @{ Id = 'python-public-api' }
    ) {
        $native = $script:NativeOutput[$Id]
        $scanner = $script:ScannerOutput[$Id]
        @($native.Findings).Count | Should -Be 0
        @($scanner.Findings).Count | Should -Be 0
        $nativeById = @{}
        foreach ($element in $native.Elements) { $nativeById[[string] $element['element_id']] = $element }
        $scannerById = @{}
        foreach ($element in $scanner.Elements) { $scannerById[[string] $element['element_id']] = $element }
        $shared = @($script:Surface['expected_elements'] | Where-Object { [string] $_['analyzer_id'] -ceq $Id -and ([string] $_['path']).EndsWith('.py', [System.StringComparison]::Ordinal) })
        $shared.Count | Should -BeGreaterThan 0
        foreach ($row in $shared) {
            $key = [string] $row['element_id']
            $nativeById.ContainsKey($key) | Should -BeTrue -Because "native emits $($row['declaration'])"
            $nativeById[$key]['source_sha256'] | Should -BeExactly ([string] $row['source_sha256']) -Because "native digest of $($row['declaration'])"
            $nativeById[$key]['parent_id'] | Should -Be $row['parent_id'] -Because "native parent of $($row['declaration'])"
            $scannerById[$key]['source_sha256'] | Should -BeExactly $nativeById[$key]['source_sha256'] -Because "scanner digest of $($row['declaration'])"
        }
        @($native.Elements | ForEach-Object { $_['analysis_method'] } | Sort-Object -Unique) | Should -Be @('native')
        $native.Elements.Count | Should -Be ($shared.Count + @($script:Native['native_only_elements'] | Where-Object { [string] $_['analyzer_id'] -ceq $Id }).Count)
    }

    It 'reports native_input_scanner_diagnostics for the native inputs through the scanner' {
        $expected = @($script:Native['native_input_scanner_diagnostics'] | ForEach-Object { [string] $_['analyzer_id'] + '|' + [string] $_['code'] + '|' + [string] $_['path'] } | Sort-Object)
        $actual = @(foreach ($id in $script:Ids) {
                $script:ScannerOutput[$id].Diagnostics | Where-Object { ([string] $_['path']).StartsWith('native/', [System.StringComparison]::Ordinal) } | ForEach-Object { [string] $_['analyzer_id'] + '|' + [string] $_['code'] + '|' + [string] $_['path'] }
            }) | Sort-Object
        @($actual) | Should -Be $expected
    }

    It 'keeps the two new module texts free of digest and canonical-JSON primitives' {
        foreach ($leaf in 'DocsAnalyzerPythonNative.psm1', 'DocsPythonNativeProtocol.psm1') {
            $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:LibraryRoot -ChildPath "docs/$leaf"), [System.Text.UTF8Encoding]::new($false))
            foreach ($token in 'Get-DocsDeclarationSha256', 'Get-DocsDeclarationDigest', 'Security.Cryptography', 'HashAlgorithm', 'ConvertTo-DiscoveryCanonicalJson') {
                $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeFalse -Because "$leaf must not contain $token"
            }
        }
    }
}
