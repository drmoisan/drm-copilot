#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsAnalyzerPythonNative.psm1 (issue #1031): interpreter
    start and result classification.

.DESCRIPTION
    Every context is in memory: TestFile is a test-local scriptblock and InvokeProcess a
    test-local scriptblock that records each call and returns a canned
    @{ ExitCode; Stdout; Stderr; TimedOut } or throws DOCS_PROCESS_START_FAILED. No process is
    started, no real time is waited and no file is created.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonNativeProtocol.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonNative.psm1') -Force -ErrorAction Stop
    $script:HelperPath = '.claude/lib/docs/python/run_docs_python_native.py'
    $script:AllIds = [string[]]@('python-architecture', 'python-cli', 'python-http', 'python-public-api')

    function ConvertTo-TestInput {
        param([string] $Path, [string] $Text)
        return New-DocsCapturedInput -Path $Path -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($Text))
    }

    function Get-TestInput {
        return [object[]]@(
            (ConvertTo-TestInput -Path 'src/pkg/a.py' -Text "def f():`n    pass`n"),
            (ConvertTo-TestInput -Path 'src/pkg/b.py' -Text "def g():`n    print `"x`"`n"),
            (ConvertTo-TestInput -Path 'pyproject.toml' -Text "[project.scripts]`ntool = `"pkg.a:f`"`n[tool.demo]`nkey = 1`n")
        )
    }

    function Get-TestResponseText {
        # The helper response for Get-TestInput: a.py parses, b.py (Python 2 print) does not.
        $response = [ordered]@{
            files            = @(
                [ordered]@{
                    diagnostics = @()
                    facts       = @(
                        [ordered]@{ analyzer_id = 'python-architecture'; declaration = 'pkg.a'; kind = 'architecture-component'; line_end = $null; line_start = $null; name = 'a'; parent = $null; properties = [ordered]@{ component_kind = 'module'; import_count = 0 } },
                        [ordered]@{ analyzer_id = 'python-public-api'; declaration = 'pkg.a.f'; kind = 'public-symbol'; line_end = 1; line_start = 1; name = 'f'; parent = $null; properties = [ordered]@{ basis = 'naming'; symbol_kind = 'function' } }
                    )
                    path        = 'src/pkg/a.py'
                    status      = 'ok'
                },
                [ordered]@{ diagnostics = @(); facts = @(); path = 'src/pkg/b.py'; status = 'parse-error' }
            )
            protocol_version = 1
        }
        return ConvertTo-DocsCanonicalJson -Value $response
    }

    function Get-TestContext {
        # Result maps a candidate to a result hashtable or to the string 'start-failed' / 'throw'.
        param([bool] $PackPresent = $true, [System.Collections.IDictionary] $Result = @{})
        $calls = [System.Collections.Generic.List[object]]::new()
        $tests = [System.Collections.Generic.List[string]]::new()
        $present = $PackPresent
        $results = $Result
        $context = [pscustomobject]@{
            TestFile      = { param($RelativePath) $tests.Add([string] $RelativePath); return $present }.GetNewClosure()
            InvokeProcess = {
                param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds)
                $calls.Add([pscustomobject]@{ FilePath = $FilePath; ArgumentList = @($ArgumentList); StdinText = $StdinText; TimeoutSeconds = $TimeoutSeconds })
                $outcome = if ($results.Contains([string] $FilePath)) { $results[[string] $FilePath] } else { 'start-failed' }
                if ($outcome -is [string] -and $outcome -ceq 'start-failed') { throw "DOCS_PROCESS_START_FAILED: the process '$FilePath' could not be started: not found" }
                if ($outcome -is [string] -and $outcome -ceq 'throw') { throw 'unexpected seam failure' }
                return $outcome
            }.GetNewClosure()
        }
        return @{ Context = $context; Calls = $calls; Tests = $tests }
    }

    function Invoke-TestResult {
        param([object] $Context, [string] $Method = 'auto', [object[]] $CapturedInput = (Get-TestInput))
        return Get-DocsPythonNativeResult -CapturedInput $CapturedInput -AnalyzerId $script:AllIds -SourceRoot @('src') -AnalysisMethod $Method -Context $Context
    }

    # Non-forcing, so the suite's own import survives; -Global, so Get-Command inside the
    # registry module resolves the analyzer function when the runner hosts the test in a module.
    $script:NonForcingImport = { param($Path) Import-Module -Name $Path -Global -ErrorAction Stop }

    function Get-TestNativeRow {
        # Get-DocsAnalyzerRegistration returns a comma-wrapped array: assign it first, never pipe it directly.
        $registration = Get-DocsAnalyzerRegistration
        $native = foreach ($pair in @(@('python-architecture', 'Architecture'), @('python-cli', 'Cli'), @('python-http', 'Http'), @('python-public-api', 'Api'))) {
            $scanner = @($registration | Where-Object { $_.Id -ceq $pair[0] -and $_.AnalysisMethod -ceq 'scanner' })[0]
            [pscustomobject]@{ Id = $pair[0]; Version = '1.0.0'; AnalysisMethod = 'native'; ElementKinds = $scanner.ElementKinds; Module = (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerPythonNative.psm1'); Function = "Invoke-DocsAnalyzerPythonNative$($pair[1])" }
        }
        $scannerRows = @($registration | Where-Object { $_.AnalysisMethod -ceq 'scanner' })
        return , [object[]](@($scannerRows) + @($native))
    }

    function Invoke-TestInventory {
        param([object] $Context, [string] $Method = 'auto', [object[]] $CapturedInput = (Get-TestInput))
        $selection = @{}
        $selection['source_roots'] = @('src')
        $selection['element_kinds'] = @(Get-DocsElementKind)
        return Invoke-DocsPythonNativeInventory -Registration (Get-TestNativeRow) -CapturedInput $CapturedInput -Selection $selection -AnalyzerId $script:AllIds -SourceRoot @('src') -AnalysisMethod $Method -Context $Context -ImportModule $script:NonForcingImport
    }

    $script:Ok = @{ ExitCode = 0; Stdout = (Get-TestResponseText); Stderr = ''; TimedOut = $false }
}

AfterAll {
    Remove-Module -Name DocsAnalyzerPythonNative, DocsPythonNativeProtocol, DocsTomlKeys, DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsYamlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonApi, DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsAnalyzerRegistry, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsPythonNativeInterpreter' {
    It 'passes -I -B -X utf8 before the helper path, -3 first for py, the request and a 120-second bound' {
        $test = Get-TestContext -Result @{ python3 = 'start-failed'; python = 'start-failed'; py = 'start-failed' }
        $result = Invoke-TestResult -Context $test.Context
        $result.Reason | Should -BeExactly 'interpreter-not-found'
        @($test.Calls | ForEach-Object { $_.FilePath }) | Should -Be @('python3', 'python', 'py')
        @($test.Calls[0].ArgumentList) | Should -Be @('-I', '-B', '-X', 'utf8', $script:HelperPath)
        @($test.Calls[1].ArgumentList) | Should -Be @('-I', '-B', '-X', 'utf8', $script:HelperPath)
        @($test.Calls[2].ArgumentList) | Should -Be @('-3', '-I', '-B', '-X', 'utf8', $script:HelperPath)
        foreach ($call in $test.Calls) { $call.TimeoutSeconds | Should -Be 120 }
        $request = New-DocsPythonNativeRequest -CapturedInput (Get-TestInput) -AnalyzerId $script:AllIds -SourceRoot @('src') -ConsoleScript (Get-DocsPythonNativeConsoleScript -CapturedInput (Get-TestInput))
        foreach ($call in $test.Calls) { $call.StdinText | Should -BeExactly $request.Text }
    }

    It 'rejects a candidate outside python3, python and py' {
        { Invoke-DocsPythonNativeInterpreter -Candidate 'python2' -InvokeProcess { 'never' } -StdinText '' -TimeoutSeconds 1 } | Should -Throw -ExpectedMessage 'DOCS_PYTHON_NATIVE_CANDIDATE_INVALID*'
    }
}

Describe 'Get-DocsPythonNativeResult' {
    It 'reports pack-absent silently with zero InvokeProcess calls' {
        $test = Get-TestContext -PackPresent $false
        $result = Invoke-TestResult -Context $test.Context
        $result.Available | Should -BeFalse
        $result.Reason | Should -BeExactly 'pack-absent'
        $result.Diagnostic | Should -BeNullOrEmpty
        $result.Finding | Should -BeNullOrEmpty
        $test.Calls.Count | Should -Be 0
        @($test.Tests) | Should -Be @($script:HelperPath)
    }

    It 'gives the <Reason> token with one information diagnostic' -ForEach @(
        @{ Reason = 'interpreter-not-found'; Results = @{} }
        @{ Reason = 'version-below-floor'; Results = @{ python3 = @{ ExitCode = 4; Stdout = ''; Stderr = ''; TimedOut = $false } } }
        @{ Reason = 'timeout'; Results = @{ python3 = @{ ExitCode = $null; Stdout = ''; Stderr = ''; TimedOut = $true } } }
        @{ Reason = 'exit-nonzero'; Results = @{ python3 = @{ ExitCode = 3; Stdout = ''; Stderr = ''; TimedOut = $false } } }
        @{ Reason = 'start-error'; Results = @{ python3 = 'throw' } }
        @{ Reason = 'output-invalid'; Results = @{ python3 = @{ ExitCode = 0; Stdout = 'not json'; Stderr = ''; TimedOut = $false } } }
    ) {
        $test = Get-TestContext -Result $Results
        $result = Invoke-TestResult -Context $test.Context
        $result.Available | Should -BeFalse
        $result.Reason | Should -BeExactly $Reason
        $result.Diagnostic['code'] | Should -BeExactly 'PYTHON_NATIVE_UNAVAILABLE'
        $result.Diagnostic['severity'] | Should -BeExactly 'information'
        $result.Diagnostic['blocking'] | Should -BeFalse
        $result.Diagnostic['analyzer_id'] | Should -BeExactly 'docs-inventory'
        $result.Diagnostic['path'] | Should -BeNullOrEmpty
        $result.Diagnostic['message'].Contains($Reason) | Should -BeTrue
        $result.Finding | Should -BeNullOrEmpty
    }

    It 'gives output-invalid when a valid-looking response fails the 1020 conversion' {
        $text = (Get-TestResponseText).Replace('"pkg.a.f"', '" pkg.a.f"')
        $result = Invoke-TestResult -Context (Get-TestContext -Result @{ python3 = @{ ExitCode = 0; Stdout = $text; Stderr = ''; TimedOut = $false } }).Context
        $result.Reason | Should -BeExactly 'output-invalid'
    }

    It 'treats a non-dictionary seam result as start-error' {
        $result = Invoke-TestResult -Context (Get-TestContext -Result @{ python3 = 'unexpected text' }).Context
        $result.Reason | Should -BeExactly 'start-error'
    }

    It 'uses the second candidate when the first fails' {
        $test = Get-TestContext -Result @{ python3 = @{ ExitCode = 3; Stdout = ''; Stderr = ''; TimedOut = $false }; python = $script:Ok }
        $result = Invoke-TestResult -Context $test.Context
        $result.Available | Should -BeTrue
        $result.Diagnostic | Should -BeNullOrEmpty
        @($test.Calls | ForEach-Object { $_.FilePath }) | Should -Be @('python3', 'python')
        @($result.Native.ParseFailed) | Should -Be @('src/pkg/b.py')
    }

    It 'returns the DOCS_PYTHON_NATIVE_UNAVAILABLE finding under native, including pack-absent' {
        $absent = Invoke-TestResult -Context (Get-TestContext -PackPresent $false).Context -Method 'native'
        $absent.Finding['code'] | Should -BeExactly 'DOCS_PYTHON_NATIVE_UNAVAILABLE'
        $absent.Diagnostic | Should -BeNullOrEmpty
        $failed = Invoke-TestResult -Context (Get-TestContext).Context -Method 'native'
        $failed.Finding['code'] | Should -BeExactly 'DOCS_PYTHON_NATIVE_UNAVAILABLE'
        $failed.Finding['message'].Contains('interpreter-not-found') | Should -BeTrue
    }

    It 'makes zero TestFile and InvokeProcess calls under scanner and without .py inputs' {
        $test = Get-TestContext -Result @{ python3 = $script:Ok }
        (Invoke-TestResult -Context $test.Context -Method 'scanner').Available | Should -BeFalse
        (Invoke-TestResult -Context $test.Context -CapturedInput @(ConvertTo-TestInput -Path 'pyproject.toml' -Text "a = 1`n")).Available | Should -BeFalse
        (Get-DocsPythonNativeResult -CapturedInput (Get-TestInput) -AnalyzerId @() -SourceRoot @('src') -AnalysisMethod 'auto' -Context $test.Context).Available | Should -BeFalse
        $test.Calls.Count | Should -Be 0
        $test.Tests.Count | Should -Be 0
    }
}

Describe 'Native analyzer functions' {
    It 'return the selection output of their identifier and an empty result otherwise' {
        $selection = @{ python_native = @{ 'python-cli' = @{ Elements = @('e'); Diagnostics = @('d') } } }
        (Invoke-DocsAnalyzerPythonNativeCli -CapturedInput @() -Selection $selection).Elements | Should -Be @('e')
        (Invoke-DocsAnalyzerPythonNativeCli -CapturedInput @() -Selection $selection).Diagnostics | Should -Be @('d')
        (Invoke-DocsAnalyzerPythonNativeHttp -CapturedInput @() -Selection $selection).Elements.Count | Should -Be 0
        (Invoke-DocsAnalyzerPythonNativeApi -CapturedInput @() -Selection @{}).Elements.Count | Should -Be 0
        (Invoke-DocsAnalyzerPythonNativeArchitecture -CapturedInput @() -Selection $null).Diagnostics.Count | Should -Be 0
        (Invoke-DocsAnalyzerPythonNativeArchitecture -CapturedInput @() -Selection @{ python_native = 'x' }).Elements.Count | Should -Be 0
    }
}

Describe 'Invoke-DocsPythonNativeInventory' {
    It 'keeps scanner elements for a parse-failed file and native elements for the others (S5)' {
        $test = Get-TestContext -Result @{ python3 = $script:Ok }
        $result = Invoke-TestInventory -Context $test.Context
        $result.Finding | Should -BeNullOrEmpty
        @($result.Rows | ForEach-Object { "$($_.Id):$($_.AnalysisMethod)" }) | Should -Be @('python-architecture:native', 'python-architecture:scanner', 'python-cli:native', 'python-cli:scanner', 'python-http:native', 'python-http:scanner', 'python-public-api:native', 'python-public-api:scanner')
        $elements = @($result.Outputs | ForEach-Object { $_.Elements })
        @($elements | Where-Object { $_['path'] -ceq 'src/pkg/a.py' } | ForEach-Object { $_['analysis_method'] } | Sort-Object -Unique) | Should -Be @('native')
        @($elements | Where-Object { $_['path'] -ceq 'src/pkg/b.py' } | ForEach-Object { $_['declaration'] } | Sort-Object) | Should -Be @('pkg.b', 'pkg.b.g')
        @($elements | Where-Object { $_['path'] -ceq 'src/pkg/b.py' } | ForEach-Object { $_['analysis_method'] } | Sort-Object -Unique) | Should -Be @('scanner')
    }

    It 'records scanner for pyproject.toml elements and for config-files, which has no native row' {
        $result = Invoke-TestInventory -Context (Get-TestContext -Result @{ python3 = $script:Ok }).Context
        $pyproject = @($result.Outputs | ForEach-Object { $_.Elements } | Where-Object { $_['path'] -ceq 'pyproject.toml' })
        $pyproject.Count | Should -BeGreaterThan 0
        @($pyproject | ForEach-Object { $_['analysis_method'] } | Sort-Object -Unique) | Should -Be @('scanner')
        $selection = Select-DocsAnalyzerRegistration -Registration (Get-TestNativeRow) -ElementKind @('config-key') -AnalyzerId @('config-files') -NativeAvailable @('config-files')
        @($selection.Rows | ForEach-Object { $_.AnalysisMethod }) | Should -Be @('scanner')
    }

    It 'falls back to the scanner rows with the diagnostic when the helper is unavailable, and returns the finding under native' {
        $test = Get-TestContext -Result @{ python3 = @{ ExitCode = 4; Stdout = ''; Stderr = ''; TimedOut = $false } }
        $result = Invoke-TestInventory -Context $test.Context
        @($result.Rows | ForEach-Object { $_.AnalysisMethod } | Sort-Object -Unique) | Should -Be @('scanner')
        @($result.Diagnostics | ForEach-Object { $_['code'] }) | Should -Be @('PYTHON_NATIVE_UNAVAILABLE')
        $native = Invoke-TestInventory -Context $test.Context -Method 'native'
        $native.Finding['code'] | Should -BeExactly 'DOCS_PYTHON_NATIVE_UNAVAILABLE'
        $native.Rows.Count | Should -Be 0
        (Invoke-DocsPythonNativeInventory -Registration (Get-TestNativeRow) -CapturedInput @() -Selection @{} -AnalyzerId @() -SourceRoot @() -AnalysisMethod 'auto' -Context $test.Context).Rows.Count | Should -Be 0
    }

    It 'returns the analyzer-contract finding when a native row output is rejected' {
        # The python-public-api native row declares http-route only, so its public-symbol output is outside the registration.
        $rows = Get-TestNativeRow
        $broken = [object[]]@($rows | ForEach-Object {
                if ($_.AnalysisMethod -ceq 'native' -and $_.Id -ceq 'python-public-api') { [pscustomobject]@{ Id = $_.Id; Version = $_.Version; AnalysisMethod = 'native'; ElementKinds = @('http-route'); Module = $_.Module; Function = $_.Function } } else { $_ }
            })
        $selection = @{}
        $selection['source_roots'] = @('src')
        $selection['element_kinds'] = @(Get-DocsElementKind)
        $context = (Get-TestContext -Result @{ python3 = $script:Ok }).Context
        $result = Invoke-DocsPythonNativeInventory -Registration $broken -CapturedInput (Get-TestInput) -Selection $selection -AnalyzerId $script:AllIds -SourceRoot @('src') -AnalysisMethod 'auto' -Context $context -ImportModule $script:NonForcingImport
        $result.Finding['code'] | Should -BeExactly 'DOCS_ANALYZER_OUTPUT_INVALID'
        $result.Rows.Count | Should -Be 0
    }

    It 'property: output is identical under a seeded permutation of the captured inputs' {
        $baseline = ConvertTo-DocsCanonicalJson -Value @((Invoke-TestInventory -Context (Get-TestContext -Result @{ python3 = $script:Ok }).Context).Outputs)
        $seed = 1031
        $random = [System.Random]::new($seed)
        for ($round = 0; $round -lt 5; $round++) {
            $shuffled = @(Get-TestInput | Sort-Object { $random.Next() })
            $outputs = (Invoke-TestInventory -Context (Get-TestContext -Result @{ python3 = $script:Ok }).Context -CapturedInput $shuffled).Outputs
            ConvertTo-DocsCanonicalJson -Value @($outputs) | Should -BeExactly $baseline -Because "seed $seed round $round"
        }
    }
}
