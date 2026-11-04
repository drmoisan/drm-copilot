#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsInventory.psm1 (issue #1022).

.DESCRIPTION
    Runs Invoke-DocsInventoryCommand against the 1020 in-memory command context with a fixed clock:
    exit 0 and 1 (blocking diagnostic, absent profile, invalid profile), exit 2 (unknown -Analyzer,
    an identifier with no selected element kind, an invalid -Revision, a non-relative -Profile),
    exit 3 (exceeded aggregate bound, read failure), the revision record, the -Write behavior
    (no WriteText call without it; one call with mode create or overwrite), the recording
    ReadBytes wrapper proving a non-template env-family file is never read, and the scan of the
    other seventeen new module texts for a Context reference.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsInventory.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ProfilePath = Get-DocsDefaultProfilePath
    $script:SnapshotPath = 'docs/documentation-estate/surface-inventory-snapshot.json'
    $script:Revision = '0123456789abcdef0123456789abcdef01234567'

    function Get-TestProfileText {
        param([string[]] $ElementKind, [string[]] $Analyzer)
        $starter = New-DocsStarterProfile -RepositoryId 'repo'
        $starter['surface_selection']['source_roots'] = @('src', 'config')
        if ($null -ne $ElementKind) { $starter['surface_selection']['element_kinds'] = $ElementKind }
        if ($null -ne $Analyzer) { $starter['surface_selection']['analyzers'] = $Analyzer }
        return ConvertTo-DocsJsonText -Value $starter -Indented
    }

    function Get-TestFile {
        param([string] $ProfileText = (Get-TestProfileText), [System.Collections.IDictionary] $Extra)
        $files = [ordered]@{
            $script:ProfilePath   = $ProfileText
            'src/app.py'          = "def main():`n    pass`n`nclass Thing:`n    pass`n"
            'src/pkg/__init__.py' = "from . import mod`n"
            'src/pkg/mod.py'      = "value = 1`n"
            'config/app.yaml'     = "name: MARKER_NAME`n"
            'config/.env.example' = "KEY=MARKER_KEY`n"
            'config/.env'         = "SECRET=MARKER_SECRET`n"
            'config/notes.md'     = "plain text`n"
        }
        if ($null -ne $Extra) { foreach ($key in $Extra.Keys) { $files[[string] $key] = $Extra[$key] } }
        return $files
    }

    function Get-TestRecordingContext {
        # Wraps the in-memory context: ReadBytes records every path it is asked for (and may be
        # replaced), ListFile may be replaced; the other members are the originals.
        param([object] $Context, [System.Collections.Generic.List[string]] $Log, [scriptblock] $ReadBytes, [scriptblock] $ListFile)
        $inner = $Context.ReadBytes
        $target = $Log
        $override = $ReadBytes
        $recording = {
            param($RelativePath)
            $target.Add([string] $RelativePath)
            if ($null -ne $override) { return , (& $override $RelativePath) }
            return , (& $inner $RelativePath)
        }.GetNewClosure()
        return [pscustomobject]@{
            RepositoryRoot = $Context.RepositoryRoot
            ReadText       = $Context.ReadText
            ReadBytes      = $recording
            TestFile       = $Context.TestFile
            ListFile       = $(if ($null -ne $ListFile) { $ListFile } else { $Context.ListFile })
            WriteText      = $Context.WriteText
            UtcNow         = $Context.UtcNow
            InvokeProcess  = $Context.InvokeProcess
        }
    }

    function Get-TestElementDeclaration {
        param([object] $Result, [string] $Kind)
        [string[]] $items = @($Result.Result.snapshot['elements'] | Where-Object { $_['kind'] -ceq $Kind } | ForEach-Object { [string] $_['declaration'] })
        [Array]::Sort($items, [System.StringComparer]::Ordinal)
        return ($items -join ',')
    }
}

AfterAll {
    Remove-Module -Name DocsInventory, DocsAnalyzerPythonNative, DocsPythonNativeProtocol, DocsInventorySnapshot, DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsYamlKeys, DocsTomlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonApi, DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsProfile, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsInventoryCommand' {
    It 'exits 0 with a dry-run snapshot, no finding, no WriteText call, revision null and the fixed clock' {
        $test = New-DocsTestContext -File (Get-TestFile)
        $result = Invoke-DocsInventoryCommand -Argument @{} -Context $test.Context
        $result.ExitCode | Should -Be 0
        $result.Command | Should -BeExactly 'inventory'
        $result.Findings.Count | Should -Be 0
        $result.Result.snapshot_path | Should -BeExactly $script:SnapshotPath
        $result.Result.written | Should -BeFalse
        $test.WriteLog.Count | Should -Be 0
        $snapshot = $result.Result.snapshot
        $snapshot['revision'] | Should -BeNullOrEmpty
        $snapshot['captured_at'] | Should -BeExactly '2026-01-01T00:00:00Z'
        $snapshot['repository'] | Should -BeExactly 'repo'
        @($snapshot['analyzers'] | ForEach-Object { $_['id'] }) | Should -Be @('config-files', 'python-architecture', 'python-cli', 'python-http', 'python-public-api')
        Get-TestElementDeclaration -Result $result -Kind 'architecture-component' | Should -BeExactly 'app,pkg,pkg.mod'
        Get-TestElementDeclaration -Result $result -Kind 'public-symbol' | Should -BeExactly 'app.Thing,app.main,pkg.mod.value'
        Get-TestElementDeclaration -Result $result -Kind 'config-key' | Should -BeExactly 'KEY,name'
        @($snapshot['inputs'] | ForEach-Object { $_['path'] }) | Should -Be @('config/.env.example', 'config/app.yaml', 'config/notes.md', 'src/app.py', 'src/pkg/__init__.py', 'src/pkg/mod.py')
        @($snapshot['diagnostics'] | ForEach-Object { $_['code'] + '|' + $_['path'] }) | Should -Be @('ENV_FILE_NOT_CAPTURED|config/.env')
        (Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText (ConvertTo-DocsJsonText -Value $snapshot -Indented) -ComposedSchemaSet $script:Composed).Count | Should -Be 0
        $result.Line.Count | Should -Be 1
        (ConvertTo-DocsCanonicalJson -Value $snapshot).Contains('MARKER_') | Should -BeFalse
    }

    It 'exits 1 with one DOCS_INVENTORY_BLOCKING_DIAGNOSTIC finding per blocking diagnostic, related_paths its path, and still returns the snapshot' {
        $test = New-DocsTestContext -File (Get-TestFile -Extra @{ 'config/bad.yml' = "a:`n`tb: 1`n" })
        $result = Invoke-DocsInventoryCommand -Argument @{} -Context $test.Context
        $result.ExitCode | Should -Be 1
        $result.Findings.Count | Should -Be 1
        $result.Findings[0]['code'] | Should -BeExactly 'DOCS_INVENTORY_BLOCKING_DIAGNOSTIC'
        $result.Findings[0]['severity'] | Should -BeExactly 'error'
        @($result.Findings[0]['related_paths']) | Should -Be @('config/bad.yml')
        $result.Findings[0]['message'].Contains('MARKER') | Should -BeFalse
        $result.Result.snapshot['diagnostics'].Count | Should -Be 2
        @($result.Result.snapshot['diagnostics'] | Where-Object { $_['blocking'] } | ForEach-Object { $_['code'] }) | Should -Be @('YAML_INVALID')
        $result.Result.written | Should -BeFalse
    }

    It 'exits 1 with DOCS_PROFILE_MISSING for an absent profile and with the profile findings for an invalid profile, without a snapshot' {
        $missing = Invoke-DocsInventoryCommand -Argument @{} -Context (New-DocsTestContext -File @{ 'src/app.py' = "x = 1`n" }).Context
        $missing.ExitCode | Should -Be 1
        $missing.Result | Should -BeNullOrEmpty
        @($missing.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_PROFILE_MISSING')
        $missing.Findings[0]['artifact_path'] | Should -BeExactly $script:ProfilePath
        $invalid = Invoke-DocsInventoryCommand -Argument @{} -Context (New-DocsTestContext -File (Get-TestFile -ProfileText '{"id": "a"}')).Context
        $invalid.ExitCode | Should -Be 1
        $invalid.Result | Should -BeNullOrEmpty
        $invalid.Findings.Count | Should -BeGreaterThan 0
        foreach ($finding in $invalid.Findings) { $finding['severity'] | Should -BeExactly 'error' }
        $unknown = Invoke-DocsInventoryCommand -Argument @{} -Context (New-DocsTestContext -File (Get-TestFile -ProfileText (Get-TestProfileText -Analyzer @('ghost')))).Context
        $unknown.ExitCode | Should -Be 1
        @($unknown.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_ANALYZER_UNKNOWN')
    }

    It 'exits 2 with one DOCS_CLI_ARGUMENTS finding naming the value and result null for an unknown -Analyzer, an identifier with no selected kind, an invalid -Revision and a non-relative -Profile' {
        $cases = @(
            @{ Argument = @{ Analyzer = [string[]]@('not-registered') }; Named = 'not-registered'; ProfileText = (Get-TestProfileText) }
            @{ Argument = @{ Analyzer = [string[]]@('config-files', 'python-cli') }; Named = 'python-cli'; ProfileText = (Get-TestProfileText -ElementKind @('config-key')) }
            @{ Argument = @{ Revision = 'abc' }; Named = 'abc'; ProfileText = (Get-TestProfileText) }
            @{ Argument = @{ Profile = 'C:/abs.json' }; Named = 'C:/abs.json'; ProfileText = (Get-TestProfileText) }
            @{ Argument = @{ Profile = '/abs.json' }; Named = '/abs.json'; ProfileText = (Get-TestProfileText) }
        )
        foreach ($case in $cases) {
            $test = New-DocsTestContext -File (Get-TestFile -ProfileText $case.ProfileText)
            $result = Invoke-DocsInventoryCommand -Argument $case.Argument -Context $test.Context
            $result.ExitCode | Should -Be 2 -Because $case.Named
            $result.Result | Should -BeNullOrEmpty -Because $case.Named
            $result.Findings.Count | Should -Be 1 -Because $case.Named
            $result.Findings[0]['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS' -Because $case.Named
            $result.Findings[0]['message'].Contains($case.Named) | Should -BeTrue -Because $case.Named
            $test.WriteLog.Count | Should -Be 0
        }
    }

    It 'exits 3 with one DOCS_CLI_RUNTIME finding and result null for an exceeded aggregate bound and for a read failure' {
        $log = [System.Collections.Generic.List[string]]::new()
        $test = New-DocsTestContext -File (Get-TestFile)
        $huge = Get-TestRecordingContext -Context $test.Context -Log $log -ReadBytes { return , [byte[]]::new(268435457) }
        $bound = Invoke-DocsInventoryCommand -Argument @{} -Context $huge
        $bound.ExitCode | Should -Be 3
        $bound.Result | Should -BeNullOrEmpty
        @($bound.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_CLI_RUNTIME')
        $bound.Findings[0]['message'] | Should -BeLike '*268435457*'
        $log.Count | Should -Be 1 -Because 'the byte bound stops the run at the first over-bound read'
        $failing = Get-TestRecordingContext -Context $test.Context -Log $log -ReadBytes { param($RelativePath) throw "disk error reading $RelativePath" }
        $failure = Invoke-DocsInventoryCommand -Argument @{} -Context $failing
        $failure.ExitCode | Should -Be 3
        $failure.Result | Should -BeNullOrEmpty
        @($failure.Findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_CLI_RUNTIME')
        $failure.Findings[0]['message'] | Should -BeLike '*disk error*'
        $test.WriteLog.Count | Should -Be 0
    }

    It 'records a full -Revision, writes nothing without -Write, and with -Write makes one WriteText call with mode create when absent and overwrite when present' {
        $test = New-DocsTestContext -File (Get-TestFile)
        $dry = Invoke-DocsInventoryCommand -Argument @{ Revision = $script:Revision } -Context $test.Context
        $dry.ExitCode | Should -Be 0
        $dry.Result.snapshot['revision'] | Should -BeExactly $script:Revision
        $test.WriteLog.Count | Should -Be 0
        $first = Invoke-DocsInventoryCommand -Argument @{ Revision = $script:Revision; Write = $true } -Context $test.Context
        $first.ExitCode | Should -Be 0
        $first.Result.written | Should -BeTrue
        $test.WriteLog.Count | Should -Be 1
        $test.WriteLog[0].RelativePath | Should -BeExactly $script:SnapshotPath
        $test.WriteLog[0].Mode | Should -BeExactly 'create'
        $test.WriteLog[0].Text | Should -BeExactly (ConvertTo-DocsJsonText -Value $first.Result.snapshot -Indented)
        (Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText $test.WriteLog[0].Text -ComposedSchemaSet $script:Composed).Count | Should -Be 0
        $second = Invoke-DocsInventoryCommand -Argument @{ Revision = $script:Revision; Write = $true } -Context $test.Context
        $second.ExitCode | Should -Be 0
        $test.WriteLog.Count | Should -Be 2
        $test.WriteLog[1].Mode | Should -BeExactly 'overwrite'
        $test.WriteLog[1].Text | Should -BeExactly $test.WriteLog[0].Text -Because 'identical bytes, profile, revision, selection and clock give identical text'
        $second.Result.snapshot['id'] | Should -BeExactly $first.Result.snapshot['id']
    }

    It 'never passes a non-template env-family file to ReadBytes (recording wrapper), gives it no inputs entry and no element, and reports ENV_FILE_NOT_CAPTURED naming it' {
        $log = [System.Collections.Generic.List[string]]::new()
        $test = New-DocsTestContext -File (Get-TestFile -Extra @{ 'config/.env.local' = "L=MARKER_L`n"; 'src/app.env' = "A=MARKER_A`n"; 'config/.env.dist' = "D=MARKER_D`n" })
        $result = Invoke-DocsInventoryCommand -Argument @{ Analyzer = [string[]]@('config-files') } -Context (Get-TestRecordingContext -Context $test.Context -Log $log)
        $result.ExitCode | Should -Be 0
        [string[]] $read = @($log | Sort-Object)
        $read | Should -Be @('config/.env.dist', 'config/.env.example', 'config/app.yaml', 'config/notes.md', 'src/app.py', 'src/pkg/__init__.py', 'src/pkg/mod.py')
        foreach ($withheld in @('config/.env', 'config/.env.local', 'src/app.env')) {
            $log | Should -Not -Contain $withheld
            @($result.Result.snapshot['inputs'] | ForEach-Object { $_['path'] }) | Should -Not -Contain $withheld
            @($result.Result.snapshot['elements'] | ForEach-Object { $_['path'] }) | Should -Not -Contain $withheld
        }
        $withheldDiagnostics = @($result.Result.snapshot['diagnostics'] | Where-Object { $_['code'] -ceq 'ENV_FILE_NOT_CAPTURED' })
        @($withheldDiagnostics | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('config/.env', 'config/.env.local', 'src/app.env')
        foreach ($diagnostic in $withheldDiagnostics) { $diagnostic['severity'] | Should -BeExactly 'warning'; $diagnostic['blocking'] | Should -BeFalse; $diagnostic['analyzer_id'] | Should -BeExactly 'docs-inventory' }
        Get-TestElementDeclaration -Result $result -Kind 'config-key' | Should -BeExactly 'D,KEY,name'
        @($result.Result.snapshot['analyzers'] | ForEach-Object { $_['id'] }) | Should -Be @('config-files')
        (ConvertTo-DocsCanonicalJson -Value $result.Result.snapshot).Contains('MARKER_') | Should -BeFalse
    }

    It 'is the only 1022 module that references the command context: the other seventeen new module texts contain no Context token' {
        $others = @('DocsSourceText', 'DocsPythonTokens', 'DocsPythonSyntax', 'DocsPythonBindings', 'DocsTomlKeys', 'DocsYamlKeys', 'DocsJsonSchemaKeys', 'DocsPythonCliArgparse', 'DocsPythonCliClick', 'DocsPythonCliTyper', 'DocsAnalyzerPythonCli', 'DocsPythonHttpSites', 'DocsAnalyzerPythonHttp', 'DocsAnalyzerPythonApi', 'DocsAnalyzerArchitecture', 'DocsAnalyzerConfigFiles', 'DocsInventorySnapshot')
        $others.Count | Should -Be 17
        foreach ($module in $others) {
            $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:LibraryRoot -ChildPath "docs/$module.psm1"), [System.Text.UTF8Encoding]::new($false))
            ($text -cmatch 'Context') | Should -BeFalse -Because "$module.psm1 must not reference the command context"
        }
        $self = [System.IO.File]::ReadAllText((Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsInventory.psm1'), [System.Text.UTF8Encoding]::new($false))
        ($self -cmatch 'Context\.ReadBytes') | Should -BeTrue
    }

    Context 'through Invoke-DocsCommandCli' {
        BeforeAll {
            . (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/Invoke-DocsCommand.ps1')

            function Invoke-TestCli {
                # Runs the inventory subcommand with -Json through the entry script's CLI function and
                # validates the envelope against docs-command-envelope (validity only, never message text).
                param([object] $Context, [string[]] $Arguments = @())
                $outcome = Invoke-DocsCommandCli -Command 'inventory' -CommandArgument $Arguments -Context $Context -Json
                (Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $outcome.Stdout -ComposedSchemaSet $script:Composed).Count | Should -Be 0 -Because 'every exit path envelope validates'
                $envelope = ConvertFrom-DocsJsonText -Text $outcome.Stdout
                $envelope.Findings.Count | Should -Be 0
                $envelope.Value['command'] | Should -BeExactly 'inventory'
                $envelope.Value['exit_code'] | Should -Be $outcome.ExitCode
                $envelope.Value['ok'] | Should -Be ($outcome.ExitCode -eq 0)
                return @{ Outcome = $outcome; Envelope = $envelope.Value; Codes = @($envelope.Value['findings'] | ForEach-Object { [string] $_['code'] }) }
            }
        }

        It 'registers the inventory row with its options and Test-DocsCommandTable returns no finding' {
            $table = Get-DocsCommandTable
            (Test-DocsCommandTable -Table $table).Count | Should -Be 0
            $rows = @($table | Where-Object { [string] $_.Name -ceq 'inventory' })
            $rows.Count | Should -Be 1
            $rows[0].Function | Should -BeExactly 'Invoke-DocsInventoryCommand'
            Test-Path -LiteralPath $rows[0].Module | Should -BeTrue
            @($rows[0].Option.Keys | Sort-Object) | Should -Be @('AnalysisMethod', 'Analyzer', 'Profile', 'Revision', 'Write')
            $rows[0].Option['Analyzer'] | Should -BeExactly 'multi'
            $rows[0].Option['Write'] | Should -BeExactly 'switch'
        }

        It 'exits 0 and 1 (blocking diagnostic, absent profile, invalid profile) with a valid envelope' {
            $ok = Invoke-TestCli -Context (New-DocsTestContext -File (Get-TestFile)).Context
            $ok.Outcome.ExitCode | Should -Be 0
            $ok.Codes | Should -BeNullOrEmpty
            $ok.Envelope['result']['written'] | Should -BeFalse
            $ok.Envelope['result']['snapshot']['captured_at'] | Should -BeExactly '2026-01-01T00:00:00Z'
            $blocking = Invoke-TestCli -Context (New-DocsTestContext -File (Get-TestFile -Extra @{ 'config/bad.yml' = "a:`n`tb: 1`n" })).Context
            $blocking.Outcome.ExitCode | Should -Be 1
            $blocking.Codes | Should -Be @('DOCS_INVENTORY_BLOCKING_DIAGNOSTIC')
            $blocking.Envelope['result']['snapshot']['elements'].Count | Should -BeGreaterThan 0
            $missing = Invoke-TestCli -Context (New-DocsTestContext -File (Get-TestFile)).Context -Arguments @('-Profile', 'missing.json')
            $missing.Outcome.ExitCode | Should -Be 1
            $missing.Codes | Should -Be @('DOCS_PROFILE_MISSING')
            $missing.Envelope['result'] | Should -BeNullOrEmpty
            $invalid = Invoke-TestCli -Context (New-DocsTestContext -File (Get-TestFile -ProfileText '{"id": "a"}')).Context
            $invalid.Outcome.ExitCode | Should -Be 1
            $invalid.Codes.Count | Should -BeGreaterThan 0
            $invalid.Envelope['result'] | Should -BeNullOrEmpty
        }

        It 'exits 2 for an unknown -Analyzer, an identifier with no selected kind, an invalid -Revision and a non-relative -Profile with result null and a valid envelope' {
            $cases = @(
                @{ Arguments = @('-Analyzer', 'not-registered'); ProfileText = (Get-TestProfileText) }
                @{ Arguments = @('-Analyzer', 'config-files', '-Analyzer', 'python-cli'); ProfileText = (Get-TestProfileText -ElementKind @('config-key')) }
                @{ Arguments = @('-Revision', 'abc'); ProfileText = (Get-TestProfileText) }
                @{ Arguments = @('-Profile', 'C:/abs.json'); ProfileText = (Get-TestProfileText) }
            )
            foreach ($case in $cases) {
                $run = Invoke-TestCli -Context (New-DocsTestContext -File (Get-TestFile -ProfileText $case.ProfileText)).Context -Arguments $case.Arguments
                $run.Outcome.ExitCode | Should -Be 2 -Because ($case.Arguments -join ' ')
                $run.Codes | Should -Be @('DOCS_CLI_ARGUMENTS') -Because ($case.Arguments -join ' ')
                $run.Envelope['result'] | Should -BeNullOrEmpty -Because ($case.Arguments -join ' ')
            }
        }

        It 'exits 3 for an exceeded aggregate bound and a read failure with result null, one stderr line and a valid envelope' {
            $log = [System.Collections.Generic.List[string]]::new()
            $test = New-DocsTestContext -File (Get-TestFile)
            $bound = Invoke-TestCli -Context (Get-TestRecordingContext -Context $test.Context -Log $log -ReadBytes { return , [byte[]]::new(268435457) })
            $bound.Outcome.ExitCode | Should -Be 3
            $bound.Codes | Should -Be @('DOCS_CLI_RUNTIME')
            $bound.Envelope['result'] | Should -BeNullOrEmpty
            $bound.Outcome.Stderr | Should -BeExactly "Invoke-DocsCommand.ps1: exit 3 (DOCS_CLI_RUNTIME)`n"
            $failure = Invoke-TestCli -Context (Get-TestRecordingContext -Context $test.Context -Log $log -ReadBytes { throw 'disk error' })
            $failure.Outcome.ExitCode | Should -Be 3
            $failure.Codes | Should -Be @('DOCS_CLI_RUNTIME')
            $failure.Envelope['result'] | Should -BeNullOrEmpty
        }

        It 'records -Revision and performs the -Write create and overwrite calls through the CLI' {
            $test = New-DocsTestContext -File (Get-TestFile)
            $first = Invoke-TestCli -Context $test.Context -Arguments @('-Revision', $script:Revision, '-Write')
            $first.Outcome.ExitCode | Should -Be 0
            $first.Envelope['result']['snapshot']['revision'] | Should -BeExactly $script:Revision
            $first.Envelope['result']['written'] | Should -BeTrue
            $test.WriteLog.Count | Should -Be 1
            $test.WriteLog[0].Mode | Should -BeExactly 'create'
            $test.WriteLog[0].RelativePath | Should -BeExactly $script:SnapshotPath
            $second = Invoke-TestCli -Context $test.Context -Arguments @('-Revision', $script:Revision, '-Write')
            $second.Outcome.ExitCode | Should -Be 0
            $test.WriteLog.Count | Should -Be 2
            $test.WriteLog[1].Mode | Should -BeExactly 'overwrite'
            $dry = Invoke-TestCli -Context $test.Context
            $dry.Outcome.ExitCode | Should -Be 0
            $test.WriteLog.Count | Should -Be 2
        }
    }
}
