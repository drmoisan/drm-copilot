#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Integration tests for the -AnalysisMethod option of the inventory subcommand (issue #1031).

.DESCRIPTION
    Runs inventory end to end through Invoke-DocsCommandCli with the 1020 in-memory command
    context, a fixed clock and a test-local InvokeProcess scriptblock (S3, S4, S6, S11). The
    helper pack is present when the in-memory file map holds the helper path. No process is
    started and no file is created.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:HelperPath = '.claude/lib/docs/python/run_docs_python_native.py'
    $script:PythonIds = [string[]]@('python-architecture', 'python-cli', 'python-http', 'python-public-api')

    function Get-TestFile {
        param([bool] $Pack = $true)
        $starter = New-DocsStarterProfile -RepositoryId 'repo'
        $starter['surface_selection']['source_roots'] = @('src', 'config')
        $files = [ordered]@{
            (Get-DocsDefaultProfilePath) = (ConvertTo-DocsJsonText -Value $starter -Indented)
            'src/app.py'                 = "def main():`n    pass`n"
            'src/pkg/__init__.py'        = "from . import mod`n"
            'src/pkg/mod.py'             = "value = 1`n"
            'config/app.yaml'            = "name: x`n"
            'config/pyproject.toml'      = "[project.scripts]`ntool = `"app:main`"`n[tool.demo]`nkey = 1`n"
        }
        if ($Pack) { $files[$script:HelperPath] = '' }
        return $files
    }

    function Get-TestResponseText {
        $component = { param($Declaration, $Name, $Kind, $Edge) $properties = [ordered]@{ component_kind = $Kind; import_count = @($Edge).Count }; if (@($Edge).Count -gt 0) { $properties['import-0001'] = $Edge }; [ordered]@{ analyzer_id = 'python-architecture'; declaration = $Declaration; kind = 'architecture-component'; line_end = $null; line_start = $null; name = $Name; parent = $null; properties = $properties } }
        $symbol = { param($Declaration, $Name, $Kind) [ordered]@{ analyzer_id = 'python-public-api'; declaration = $Declaration; kind = 'public-symbol'; line_end = 1; line_start = 1; name = $Name; parent = $null; properties = [ordered]@{ basis = 'naming'; symbol_kind = $Kind } } }
        $files = @(
            [ordered]@{ diagnostics = @(); facts = @((& $component 'app' 'app' 'module' @()), (& $symbol 'app.main' 'main' 'function')); path = 'src/app.py'; status = 'ok' },
            [ordered]@{ diagnostics = @(); facts = @((& $component 'pkg' 'pkg' 'package' 'pkg.mod')); path = 'src/pkg/__init__.py'; status = 'ok' },
            [ordered]@{ diagnostics = @(); facts = @((& $component 'pkg.mod' 'mod' 'module' @()), (& $symbol 'pkg.mod.value' 'value' 'variable')); path = 'src/pkg/mod.py'; status = 'ok' }
        )
        return ConvertTo-DocsCanonicalJson -Value ([ordered]@{ files = $files; protocol_version = 1 })
    }

    function New-TestNativeContext {
        # Wraps the in-memory context; Invoke replaces InvokeProcess and records each call.
        param([bool] $Pack = $true, [scriptblock] $Invoke)
        $test = New-DocsTestContext -File (Get-TestFile -Pack $Pack)
        $calls = [System.Collections.Generic.List[string]]::new()
        $inner = $Invoke
        $recording = {
            param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds)
            $calls.Add([string] $FilePath)
            return (& $inner $FilePath)
        }.GetNewClosure()
        $base = $test.Context
        $context = [pscustomobject]@{
            RepositoryRoot = $base.RepositoryRoot; ReadText = $base.ReadText; ReadBytes = $base.ReadBytes; TestFile = $base.TestFile
            ListFile = $base.ListFile; WriteText = $base.WriteText; UtcNow = $base.UtcNow; InvokeProcess = $recording
        }
        return @{ Context = $context; Calls = $calls; WriteLog = $test.WriteLog }
    }

    function Invoke-TestCli {
        param([object] $Context, [string[]] $Arguments = @())
        $outcome = Invoke-DocsCommandCli -Command 'inventory' -CommandArgument $Arguments -Context $Context -Json
        (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $outcome.Stdout -ComposedSchemaSet $script:Composed).Count | Should -Be 0 -Because 'every -Json envelope validates'
        $envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value
        return @{ Outcome = $outcome; Envelope = $envelope; Codes = @($envelope['findings'] | ForEach-Object { [string] $_['code'] }) }
    }

    function Assert-TestSnapshot {
        param([System.Collections.IDictionary] $Snapshot, [string] $PythonMethod)
        (Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText (ConvertTo-DocsJsonText -Value $Snapshot -Indented) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
        foreach ($element in @($Snapshot['elements'])) {
            @('native', 'scanner') | Should -Contain ([string] $element['analysis_method'])
            $isPythonFile = ([string] $element['path']).EndsWith('.py', [System.StringComparison]::Ordinal)
            if (-not $isPythonFile -or [string] $element['analyzer_id'] -ceq 'config-files') { [string] $element['analysis_method'] | Should -BeExactly 'scanner' -Because "$($element['declaration'])" }
            elseif ($script:PythonIds -ccontains [string] $element['analyzer_id']) { [string] $element['analysis_method'] | Should -BeExactly $PythonMethod -Because "$($element['declaration'])" }
        }
    }

    $script:OkText = Get-TestResponseText
}

AfterAll {
    Remove-Module -Name DocsInventory, DocsAnalyzerPythonNative, DocsPythonNativeProtocol, DocsInventorySnapshot, DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsYamlKeys, DocsTomlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonApi, DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsProfile, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'inventory -AnalysisMethod' {
    It 'uses the native analyzers when the helper answers, with scanner elements for config-files and non-.py inputs' {
        $ok = $script:OkText
        $test = New-TestNativeContext -Invoke { param($FilePath) @{ ExitCode = 0; Stdout = $ok; Stderr = ''; TimedOut = $false } }.GetNewClosure()
        $run = Invoke-TestCli -Context $test.Context
        $run.Outcome.ExitCode | Should -Be 0
        $run.Codes | Should -BeNullOrEmpty
        @($test.Calls) | Should -Be @('python3')
        $snapshot = $run.Envelope['result']['snapshot']
        Assert-TestSnapshot -Snapshot $snapshot -PythonMethod 'native'
        @($snapshot['analyzers'] | ForEach-Object { $_['id'] + ':' + $_['analysis_method'] }) | Should -Contain 'python-cli:native'
        @($snapshot['diagnostics'] | Where-Object { $_['code'] -ceq 'PYTHON_NATIVE_UNAVAILABLE' }).Count | Should -Be 0
    }

    It 'is silent with the pack absent: exit 0, scanner elements, no added diagnostic and zero InvokeProcess calls (S3)' {
        $test = New-TestNativeContext -Pack $false -Invoke { param($FilePath) throw 'never called' }
        $run = Invoke-TestCli -Context $test.Context
        $run.Outcome.ExitCode | Should -Be 0
        $run.Codes | Should -BeNullOrEmpty
        $test.Calls.Count | Should -Be 0
        Assert-TestSnapshot -Snapshot $run.Envelope['result']['snapshot'] -PythonMethod 'scanner'
        @($run.Envelope['result']['snapshot']['diagnostics'] | Where-Object { $_['code'] -ceq 'PYTHON_NATIVE_UNAVAILABLE' }).Count | Should -Be 0
    }

    It 'falls back to the scanner under auto with one PYTHON_NATIVE_UNAVAILABLE diagnostic naming <Reason> (S4)' -ForEach @(
        @{ Reason = 'interpreter-not-found'; Invoke = { param($FilePath) throw "DOCS_PROCESS_START_FAILED: the process '$FilePath' could not be started: missing" } }
        @{ Reason = 'version-below-floor'; Invoke = { param($FilePath) @{ ExitCode = 4; Stdout = ''; Stderr = ''; TimedOut = $false } } }
        @{ Reason = 'timeout'; Invoke = { param($FilePath) @{ ExitCode = $null; Stdout = ''; Stderr = ''; TimedOut = $true } } }
        @{ Reason = 'exit-nonzero'; Invoke = { param($FilePath) @{ ExitCode = 1; Stdout = ''; Stderr = ''; TimedOut = $false } } }
        @{ Reason = 'start-error'; Invoke = { param($FilePath) throw 'access denied' } }
        @{ Reason = 'output-invalid'; Invoke = { param($FilePath) @{ ExitCode = 0; Stdout = '{}'; Stderr = ''; TimedOut = $false } } }
    ) {
        $test = New-TestNativeContext -Invoke $Invoke
        $run = Invoke-TestCli -Context $test.Context
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Envelope['findings'] | Where-Object { $_['severity'] -ceq 'error' }).Count | Should -Be 0
        $snapshot = $run.Envelope['result']['snapshot']
        Assert-TestSnapshot -Snapshot $snapshot -PythonMethod 'scanner'
        $unavailable = @($snapshot['diagnostics'] | Where-Object { $_['code'] -ceq 'PYTHON_NATIVE_UNAVAILABLE' })
        $unavailable.Count | Should -Be 1
        $unavailable[0]['severity'] | Should -BeExactly 'information'
        $unavailable[0]['analyzer_id'] | Should -BeExactly 'docs-inventory'
        $unavailable[0]['path'] | Should -BeNullOrEmpty
        $unavailable[0]['message'].Contains($Reason) | Should -BeTrue
    }

    It 'exits 3 under native with one DOCS_PYTHON_NATIVE_UNAVAILABLE finding and no WriteText call' {
        $test = New-TestNativeContext -Pack $false -Invoke { param($FilePath) throw 'never called' }
        $run = Invoke-TestCli -Context $test.Context -Arguments @('-AnalysisMethod', 'native', '-Write')
        $run.Outcome.ExitCode | Should -Be 3
        $run.Codes | Should -Be @('DOCS_PYTHON_NATIVE_UNAVAILABLE')
        $test.WriteLog.Count | Should -Be 0
    }

    It 'makes zero InvokeProcess calls under scanner' {
        $test = New-TestNativeContext -Invoke { param($FilePath) throw 'never called' }
        $run = Invoke-TestCli -Context $test.Context -Arguments @('-AnalysisMethod', 'scanner')
        $run.Outcome.ExitCode | Should -Be 0
        $test.Calls.Count | Should -Be 0
        Assert-TestSnapshot -Snapshot $run.Envelope['result']['snapshot'] -PythonMethod 'scanner'
    }

    It 'exits 2 with DOCS_CLI_ARGUMENTS for an unknown -AnalysisMethod value (S6)' {
        $test = New-TestNativeContext -Invoke { param($FilePath) throw 'never called' }
        $run = Invoke-TestCli -Context $test.Context -Arguments @('-AnalysisMethod', 'fast')
        $run.Outcome.ExitCode | Should -Be 2
        $run.Codes | Should -Be @('DOCS_CLI_ARGUMENTS')
        $test.Calls.Count | Should -Be 0
    }
}
