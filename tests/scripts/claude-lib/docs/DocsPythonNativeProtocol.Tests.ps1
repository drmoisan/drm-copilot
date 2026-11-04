#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPythonNativeProtocol.psm1 (issue #1031).

.DESCRIPTION
    Builds requests from in-memory captured inputs, validates canned helper responses and
    converts them to native elements. Get-TestOutcome applies the adapter rule for a helper
    stdout: a response that fails Test-DocsPythonNativeResponse, or whose conversion throws,
    is output-invalid. No process is started and no file is created.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSourceText.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPythonNativeProtocol.psm1') -Force -ErrorAction Stop
    $script:FixtureRoot = Join-Path -Path $PSScriptRoot -ChildPath 'fixtures'
    $script:AllIds = [string[]]@('python-architecture', 'python-cli', 'python-http', 'python-public-api')

    function ConvertTo-TestInput {
        param([string] $Path, [string] $Text)
        return New-DocsCapturedInput -Path $Path -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($Text))
    }

    function Get-TestInput {
        return [object[]]@(
            (ConvertTo-TestInput -Path 'src/pkg/b.py' -Text "import click`n@click.command()`ndef go():`n    pass`n"),
            (ConvertTo-TestInput -Path 'src/pkg/a.py' -Text ([string][char]0xFEFF + "x = 1`r`ny = 2`r`n")),
            (ConvertTo-TestInput -Path 'pyproject.toml' -Text "[project.scripts]`ntool = `"pkg.b:go`"`n"),
            (ConvertTo-TestInput -Path 'config/app.yaml' -Text "name: v`n")
        )
    }

    function Get-TestRequest {
        return New-DocsPythonNativeRequest -CapturedInput (Get-TestInput) -AnalyzerId $script:AllIds -SourceRoot @('src') -ConsoleScript (Get-DocsPythonNativeConsoleScript -CapturedInput (Get-TestInput))
    }

    function ConvertTo-TestResponseText {
        # Builds a canned response for the Get-TestInput request; Mutate edits the parsed object.
        param([scriptblock] $Mutate)
        $response = [ordered]@{
            files            = @(
                [ordered]@{
                    diagnostics = @([ordered]@{ analyzer_id = 'python-cli'; blocking = $false; code = 'CLI_DYNAMIC_REGISTRATION'; line = 2 })
                    facts       = @(
                        [ordered]@{ analyzer_id = 'python-public-api'; declaration = 'pkg.a.x'; kind = 'public-symbol'; line_end = 1; line_start = 1; name = 'x'; parent = $null; properties = [ordered]@{ basis = 'naming'; symbol_kind = 'variable' } },
                        [ordered]@{ analyzer_id = 'python-architecture'; declaration = 'pkg.a'; kind = 'architecture-component'; line_end = $null; line_start = $null; name = 'a'; parent = $null; properties = [ordered]@{ component_kind = 'module'; import_count = 0 } }
                    )
                    path        = 'src/pkg/a.py'
                    status      = 'ok'
                },
                [ordered]@{
                    diagnostics = @()
                    facts       = @(
                        [ordered]@{ analyzer_id = 'python-cli'; declaration = 'tool --x'; kind = 'cli-option'; line_end = 2; line_start = 2; name = '--x'; parent = [ordered]@{ declaration = 'tool'; kind = 'cli-command'; path = 'pyproject.toml' }; properties = [ordered]@{ framework = 'click'; has_default = $false; positional = $false } }
                    )
                    path        = 'src/pkg/b.py'
                    status      = 'ok'
                }
            )
            protocol_version = 1
        }
        if ($null -ne $Mutate) { & $Mutate $response }
        return ConvertTo-DocsCanonicalJson -Value $response
    }

    function Get-TestOutcome {
        # The adapter rule: an invalid response or a conversion that throws is output-invalid.
        param([string] $Stdout)
        $check = Test-DocsPythonNativeResponse -ResponseText $Stdout -Request (Get-TestRequest)
        if (-not $check.Valid) { return @{ Reason = 'output-invalid'; Native = $null } }
        try {
            return @{ Reason = $null; Native = (ConvertFrom-DocsPythonNativeResponse -Response $check.Response -CapturedInput (Get-TestInput)) }
        } catch {
            return @{ Reason = 'output-invalid'; Native = $null }
        }
    }
}

AfterAll {
    Remove-Module -Name DocsPythonNativeProtocol, DocsTomlKeys, DocsAnalyzerRegistry, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'New-DocsPythonNativeRequest' {
    It 'takes the .py inputs ordinally by path, strips one BOM, sorts the analyzers and fixes the limits' {
        $scripts = Get-DocsPythonNativeConsoleScript -CapturedInput (Get-TestInput)
        $request = New-DocsPythonNativeRequest -CapturedInput (Get-TestInput) -AnalyzerId @('python-http', 'python-cli') -SourceRoot @('src') -ConsoleScript $scripts
        @($request.Paths) | Should -Be @('src/pkg/a.py', 'src/pkg/b.py')
        @($request.AnalyzerId) | Should -Be @('python-cli', 'python-http')
        $request.LineCount['src/pkg/a.py'] | Should -Be 2
        $parsed = (ConvertFrom-DocsJsonText -Text $request.Text).Value
        $parsed['protocol_version'] | Should -Be 1
        $parsed['limits']['max_files'] | Should -Be 50000
        $parsed['limits']['max_file_bytes'] | Should -Be 1048576
        $parsed['files'][0]['text'] | Should -BeExactly "x = 1`r`ny = 2`r`n"
        @($parsed['source_roots']) | Should -Be @('src')
        $parsed['console_scripts'][0]['target'] | Should -BeExactly 'pkg.b:go'
    }

    It 'strips one leading U+FEFF from a captured text that still carries it' {
        $captured = @(@{ path = 'm.py'; text = ([string][char]0xFEFF + "x = 1`n") })
        $request = New-DocsPythonNativeRequest -CapturedInput $captured -AnalyzerId @('python-cli') -SourceRoot @('.') -ConsoleScript @()
        (ConvertFrom-DocsJsonText -Text $request.Text).Value['files'][0]['text'] | Should -BeExactly "x = 1`n"
    }

    It 'property: the request text is invariant under input order' {
        $baseline = (New-DocsPythonNativeRequest -CapturedInput (Get-TestInput) -AnalyzerId @('python-cli') -SourceRoot @('src') -ConsoleScript @()).Text
        $seed = 1031
        $random = [System.Random]::new($seed)
        for ($round = 0; $round -lt 10; $round++) {
            $shuffled = @(Get-TestInput | Sort-Object { $random.Next() })
            (New-DocsPythonNativeRequest -CapturedInput $shuffled -AnalyzerId @('python-cli') -SourceRoot @('src') -ConsoleScript @()).Text | Should -BeExactly $baseline -Because "seed $seed round $round"
        }
    }

    It 'maps the 1022 corpus pyproject.toml script tables to the 1031 corpus console_scripts' {
        $surface = (ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText((Join-Path $script:FixtureRoot 'python-surface-corpus.json'), [System.Text.UTF8Encoding]::new($false)))).Value
        $native = (ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText((Join-Path $script:FixtureRoot 'python-native-corpus.json'), [System.Text.UTF8Encoding]::new($false)))).Value
        $captured = @(ConvertTo-TestInput -Path 'pyproject.toml' -Text ([string] $surface['inputs']['pyproject.toml']))
        $scripts = Get-DocsPythonNativeConsoleScript -CapturedInput $captured
        (ConvertTo-DocsCanonicalJson -Value @($scripts)) | Should -BeExactly (ConvertTo-DocsCanonicalJson -Value @($native['console_scripts']))
    }
}

Describe 'Test-DocsPythonNativeResponse and ConvertFrom-DocsPythonNativeResponse' {
    It 'accepts the canned response and builds native elements, parents, diagnostics and the parse-failed list' {
        $outcome = Get-TestOutcome -Stdout (ConvertTo-TestResponseText)
        $outcome.Reason | Should -BeNullOrEmpty
        $output = $outcome.Native.Output
        $api = @($output['python-public-api'].Elements)
        $api.Count | Should -Be 1
        $api[0]['analysis_method'] | Should -BeExactly 'native'
        $api[0]['line_range']['start'] | Should -Be 1
        $api[0]['source_sha256'] | Should -BeExactly (Get-DocsDeclarationSha256 -Text "x = 1`r`ny = 2`r`n" -LineRange @(1, 1))
        @($output['python-architecture'].Elements)[0]['line_range'] | Should -BeNullOrEmpty
        $option = @($output['python-cli'].Elements)[0]
        $option['parent_id'] | Should -BeExactly (Get-DocsElementId -Kind 'cli-command' -Path 'pyproject.toml' -Declaration 'tool')
        @($outcome.Native.ParseFailed).Count | Should -Be 0
    }

    It 'passes a helper diagnostic code through unchanged' {
        $outcome = Get-TestOutcome -Stdout (ConvertTo-TestResponseText)
        @($outcome.Native.Output['python-cli'].Diagnostics | ForEach-Object { $_['code'] }) | Should -Be @('CLI_DYNAMIC_REGISTRATION')
        @($outcome.Native.Output['python-cli'].Diagnostics)[0]['severity'] | Should -BeExactly 'warning'
    }

    It 'lists a parse-error file in ParseFailed and maps a blocking diagnostic to error' {
        $text = ConvertTo-TestResponseText -Mutate { param($r) $r['files'][1]['status'] = 'parse-error'; $r['files'][1]['facts'] = @(); $r['files'][0]['diagnostics'][0]['blocking'] = $true }
        $outcome = Get-TestOutcome -Stdout $text
        @($outcome.Native.ParseFailed) | Should -Be @('src/pkg/b.py')
        @($outcome.Native.Output['python-cli'].Diagnostics)[0]['severity'] | Should -BeExactly 'error'
    }

    It 'gives output-invalid for the S4 output defect: <Name>' -ForEach @(
        @{ Name = 'malformed JSON'; Mutate = $null; Raw = '{"files": [' }
        @{ Name = 'unknown top-level key'; Mutate = { param($r) $r['extra'] = 1 }; Raw = $null }
        @{ Name = 'unknown fact key'; Mutate = { param($r) $r['files'][0]['facts'][0]['extra'] = 1 }; Raw = $null }
        @{ Name = 'unknown kind'; Mutate = { param($r) $r['files'][0]['facts'][0]['kind'] = 'http-route' }; Raw = $null }
        @{ Name = 'out-of-range line'; Mutate = { param($r) $r['files'][0]['facts'][0]['line_end'] = 3 }; Raw = $null }
        @{ Name = 'line start above end'; Mutate = { param($r) $r['files'][0]['facts'][0]['line_start'] = 2 }; Raw = $null }
        @{ Name = 'architecture line bounds'; Mutate = { param($r) $r['files'][0]['facts'][1]['line_start'] = 1; $r['files'][0]['facts'][1]['line_end'] = 1 }; Raw = $null }
        @{ Name = 'invalid declaration'; Mutate = { param($r) $r['files'][0]['facts'][0]['declaration'] = ' pkg.a.x' }; Raw = $null }
        @{ Name = 'lower-case diagnostic code'; Mutate = { param($r) $r['files'][0]['diagnostics'][0]['code'] = 'cli_dynamic' }; Raw = $null }
        @{ Name = 'diagnostic analyzer outside the request'; Mutate = { param($r) $r['files'][0]['diagnostics'][0]['analyzer_id'] = 'config-files' }; Raw = $null }
        @{ Name = 'path not in the request'; Mutate = { param($r) $r['files'][1]['path'] = 'src/pkg/c.py' }; Raw = $null }
        @{ Name = 'missing path'; Mutate = { param($r) $r['files'] = @($r['files'][0]) }; Raw = $null }
        @{ Name = 'wrong protocol version'; Mutate = { param($r) $r['protocol_version'] = 2 }; Raw = $null }
        @{ Name = 'invalid status'; Mutate = { param($r) $r['files'][0]['status'] = 'skipped' }; Raw = $null }
        @{ Name = 'facts on a parse-error file'; Mutate = { param($r) $r['files'][0]['status'] = 'parse-error' }; Raw = $null }
        @{ Name = 'bad parent'; Mutate = { param($r) $r['files'][1]['facts'][0]['parent']['kind'] = 'http-route' }; Raw = $null }
        @{ Name = 'non-object properties'; Mutate = { param($r) $r['files'][0]['facts'][0]['properties'] = 'x' }; Raw = $null }
        @{ Name = 'oversized output'; Mutate = $null; Raw = ('x' * 67108865) }
    ) {
        $stdout = if ($null -ne $Raw) { $Raw } else { ConvertTo-TestResponseText -Mutate $Mutate }
        (Get-TestOutcome -Stdout $stdout).Reason | Should -BeExactly 'output-invalid' -Because $Name
    }

    It 'returns Problem text for an empty response and the registry kinds per identifier' {
        $check = Test-DocsPythonNativeResponse -ResponseText '' -Request (Get-TestRequest)
        $check.Valid | Should -BeFalse
        $check.Problem | Should -Not -BeNullOrEmpty
        # The function returns a comma-wrapped array: assign it first, never wrap it in @().
        $kinds = Get-DocsPythonNativeKind -AnalyzerId 'python-cli'
        $kinds | Should -Be @('cli-command', 'cli-option')
        (Get-DocsPythonNativeKind -AnalyzerId 'not-registered').Count | Should -Be 0
    }
}
