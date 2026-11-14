#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsInventorySnapshot.psm1 (issue #1022).

.DESCRIPTION
    Builds the fixture snapshot over both committed corpora (read in place) through the registered
    analyzers and asserts that it validates against surface-inventory-snapshot, that inputs[] carry
    the whole-file digest and size of the fixture bytes, that over-bound and undecodable inputs
    (the two 1020 capture rows, built in test code) have no inputs entry and no element, the
    selection rules (source roots, exclusions, env withholding with ENV_FILE_NOT_CAPTURED), the
    aggregate bounds, the snapshot facts, and a seeded property test per exported function.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsFinding.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsAnalyzerRegistry.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsInventorySnapshot.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:Clock = [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
    # Get-DocsAnalyzerRegistration returns a comma-wrapped array: assign it first, never pipe it directly.
    # The committed registry also holds the issue #1031 native rows; this suite builds from the scanner rows.
    $registration = Get-DocsAnalyzerRegistration
    $script:Registry = [object[]]@($registration | Where-Object { [string] $_.AnalysisMethod -ceq 'scanner' })

    function Read-TestCorpus {
        param([string] $Name)
        $parsed = ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText((Join-Path -Path $PSScriptRoot -ChildPath "fixtures/$Name"), [System.Text.UTF8Encoding]::new($false)))
        $parsed.Findings.Count | Should -Be 0 -Because "the committed corpus $Name parses"
        return $parsed.Value
    }
    $script:PythonCorpus = Read-TestCorpus -Name 'python-surface-corpus.json'
    $script:ConfigCorpus = Read-TestCorpus -Name 'config-surface-corpus.json'
    $script:Inputs = [ordered]@{}
    foreach ($key in $script:PythonCorpus['inputs'].Keys) { $script:Inputs[[string] $key] = [string] $script:PythonCorpus['inputs'][$key] }
    foreach ($key in $script:ConfigCorpus['inputs'].Keys) { $script:Inputs[[string] $key] = [string] $script:ConfigCorpus['inputs'][$key] }

    function Get-TestProfile {
        param([string[]] $SourceRoot = @('src', 'config'), [string[]] $ElementKind)
        $starter = New-DocsStarterProfile -RepositoryId 'corpus'
        $starter['surface_selection']['source_roots'] = $SourceRoot
        if ($null -ne $ElementKind) { $starter['surface_selection']['element_kinds'] = $ElementKind }
        $check = ConvertFrom-DocsProfileText -Text (ConvertTo-DocsJsonText -Value $starter -Indented) -ArtifactPath 'p.json' -ComposedSchemaSet $script:Composed
        $check.Ok | Should -BeTrue -Because 'the test profile is valid'
        return $check.Profile
    }

    function Get-TestRegistryRow {
        param([string] $Id)
        return , [object[]]@($script:Registry | Where-Object { [string] $_.Id -ceq $Id })
    }

    function ConvertTo-TestCaptured {
        param([System.Collections.IDictionary] $Source, [string[]] $Skip = @())
        $captured = [System.Collections.Generic.List[object]]::new()
        foreach ($key in $Source.Keys) {
            if ($Skip -ccontains [string] $key) { continue }
            $captured.Add((New-DocsCapturedInput -Path ([string] $key) -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes([string] $Source[$key]))))
        }
        return , $captured.ToArray()
    }

    function Invoke-TestAnalyzerSet {
        param([object[]] $Captured, [System.Collections.IDictionary] $TestProfile, [object[]] $Registration = $script:Registry)
        $outputs = [System.Collections.Generic.List[object]]::new()
        foreach ($row in $Registration) {
            $result = Invoke-DocsAnalyzer -Registration $row -CapturedInput $Captured -Selection $TestProfile['surface_selection']
            $result.Findings.Count | Should -Be 0 -Because "analyzer $($row.Id) output is accepted"
            $outputs.Add(@{ Elements = $result.Elements; Diagnostics = $result.Diagnostics })
        }
        return , $outputs.ToArray()
    }

    function Get-TestSnapshotFinding {
        param([System.Collections.IDictionary] $Snapshot)
        $findings = Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText (ConvertTo-DocsJsonText -Value $Snapshot -Indented) -ComposedSchemaSet $script:Composed
        return @($findings | Where-Object { $null -ne $_ } | ForEach-Object { [string] $_['severity'] + ' ' + [string] $_['code'] + ' ' + [string] $_['pointer'] + ': ' + [string] $_['message'] })
    }

    function ConvertTo-TestElementText {
        param([System.Collections.IDictionary] $Element)
        $range = if ($null -eq $Element['line_range']) { 'null' } else { [string] $Element['line_range']['start'] + '-' + [string] $Element['line_range']['end'] }
        $properties = @($Element['properties'] | ForEach-Object { [string] $_['name'] + '=' + $(if ($null -eq $_['value']) { 'null' } else { [string] $_['value'] }) }) -join ';'
        return (@($Element['kind'], $Element['path'], $Element['declaration'], $Element['name'], [string] $Element['parent_id'], $range, $Element['source_sha256'], $properties, $Element['analyzer_id'], $Element['analysis_method']) -join '|')
    }

    function ConvertTo-TestDiagnosticKey {
        param([object[]] $Diagnostic)
        [string[]] $keys = @($Diagnostic | ForEach-Object { [string] $_['code'] + '|' + [string] $_['path'] + '|' + [string] $_['analyzer_id'] })
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        return ($keys -join "`n")
    }

    function Test-TestOrdinalOrder {
        param([string[]] $Value)
        [string[]] $sorted = [string[]] $Value.Clone()
        [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
        return (($Value -join "`n") -ceq ($sorted -join "`n"))
    }
}

AfterAll {
    Remove-Module -Name DocsInventorySnapshot, DocsAnalyzerConfigFiles, DocsJsonSchemaKeys, DocsYamlKeys, DocsTomlKeys, DocsAnalyzerArchitecture, DocsAnalyzerPythonApi, DocsAnalyzerPythonHttp, DocsPythonHttpSites, DocsAnalyzerPythonCli, DocsPythonCliTyper, DocsPythonCliClick, DocsPythonCliArgparse, DocsPythonBindings, DocsPythonSyntax, DocsPythonTokens, DocsSourceText, DocsProfile, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'New-DocsInventorySnapshot over both corpora' {
    BeforeAll {
        $script:TestProfile = Get-TestProfile
        $script:Selection = Get-DocsInventorySelection -Path ([string[]]@($script:Inputs.Keys)) -SourceRoot ([string[]]@($script:TestProfile['surface_selection']['source_roots'])) -Exclusion $script:TestProfile['surface_selection']['exclusions']
        # The python corpus pyproject.toml sits at the repository root, outside both source roots, so the
        # builder receives every corpus input except the three withheld env files (42 captured inputs).
        $script:Captured = ConvertTo-TestCaptured -Source $script:Inputs -Skip $script:Selection.Withheld
        $script:Outputs = Invoke-TestAnalyzerSet -Captured $script:Captured -TestProfile $script:TestProfile
        $script:Snapshot = New-DocsInventorySnapshot -Profile $script:TestProfile -Revision $null -Registration $script:Registry -CapturedInput $script:Captured -AnalyzerOutput $script:Outputs -Diagnostic $script:Selection.Diagnostics -CapturedAt $script:Clock
    }

    It 'validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields' {
        Get-TestSnapshotFinding -Snapshot $script:Snapshot | Should -BeNullOrEmpty
        $script:Snapshot['$schema'] | Should -BeExactly 'urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot'
        $script:Snapshot['artifact_kind'] | Should -BeExactly 'surface-inventory-snapshot'
        $script:Snapshot['repository'] | Should -BeExactly 'corpus'
        $script:Snapshot['revision'] | Should -BeNullOrEmpty
        $script:Snapshot['captured_at'] | Should -BeExactly '2026-01-01T00:00:00Z'
        $script:Snapshot['profile_sha256'] | Should -BeExactly (Get-DocsSha256Hex -Text (ConvertTo-DocsCanonicalJson -Value $script:TestProfile))
        # Membership only: the committed registry also carries later children's rows (spec C6).
        [string[]] $analyzerEntries = @($script:Snapshot['analyzers'] | ForEach-Object { $_['id'] + ':' + $_['analysis_method'] + ':' + $_['version'] })
        foreach ($entry in @('config-files:scanner:1.0.0', 'python-architecture:scanner:1.0.0', 'python-cli:scanner:1.0.0', 'python-http:scanner:1.0.0', 'python-public-api:scanner:1.0.0')) {
            $analyzerEntries -ccontains $entry | Should -BeTrue -Because "the snapshot lists the 1022 analyzer entry '$entry'"
        }
        Test-TestOrdinalOrder -Value @($script:Snapshot['analyzers'] | ForEach-Object { [string] $_['id'] }) | Should -BeTrue -Because 'analyzers are sorted by id'
    }

    It 'contains every expected element of both corpora with identical fields plus the one cross-corpus console-script element, sorted by element_id' {
        $expected = @{}
        foreach ($element in @($script:PythonCorpus['expected_elements']) + @($script:ConfigCorpus['expected_elements'])) { $expected[[string] $element['element_id']] = ConvertTo-TestElementText -Element $element }
        $actual = @{}
        foreach ($element in $script:Snapshot['elements']) { $actual[[string] $element['element_id']] = ConvertTo-TestElementText -Element $element }
        @($expected.Keys | Where-Object { -not $actual.ContainsKey($_) } | ForEach-Object { $expected[$_] }) | Should -BeNullOrEmpty -Because 'every expected element is in the snapshot'
        @($expected.Keys | Where-Object { $actual.ContainsKey($_) -and $actual[$_] -cne $expected[$_] } | ForEach-Object { 'expected ' + $expected[$_] + ' actual ' + $actual[$_] }) | Should -BeNullOrEmpty -Because 'every element field matches the corpus'
        [string[]] $extraKeys = @($actual.Keys | Where-Object { -not $expected.ContainsKey($_) })
        $extraKeys.Count | Should -Be 1
        ($actual[$extraKeys[0]].Split('|')[0..2] -join '|') | Should -BeExactly 'cli-command|config/pyproject.toml|cli' -Because 'python-cli reads the console-script table of the config corpus pyproject.toml'
        $script:Snapshot['elements'].Count | Should -Be ($expected.Count + 1)
        Test-TestOrdinalOrder -Value @($script:Snapshot['elements'] | ForEach-Object { [string] $_['element_id'] }) | Should -BeTrue -Because 'elements are sorted by element_id'
        foreach ($element in $script:Snapshot['elements']) { $element['analysis_method'] | Should -BeExactly 'scanner' }
    }

    It 'contains every expected diagnostic of both corpora (including the three ENV_FILE_NOT_CAPTURED entries) plus the one cross-corpus TOML_INVALID, sorted by id' {
        $expectedKeys = (ConvertTo-TestDiagnosticKey -Diagnostic (@($script:PythonCorpus['expected_diagnostics']) + @($script:ConfigCorpus['expected_diagnostics']) + @(@{ code = 'TOML_INVALID'; path = 'config/other/pyproject.toml'; analyzer_id = 'python-cli' })))
        ConvertTo-TestDiagnosticKey -Diagnostic $script:Snapshot['diagnostics'] | Should -BeExactly $expectedKeys
        $withheld = @($script:Snapshot['diagnostics'] | Where-Object { $_['code'] -ceq 'ENV_FILE_NOT_CAPTURED' })
        @($withheld | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('config/.env', 'config/.env.local', 'config/app.env')
        foreach ($diagnostic in $withheld) { $diagnostic['severity'] | Should -BeExactly 'warning'; $diagnostic['blocking'] | Should -BeFalse; $diagnostic['analyzer_id'] | Should -BeExactly 'docs-inventory' }
        Test-TestOrdinalOrder -Value @($script:Snapshot['diagnostics'] | ForEach-Object { [string] $_['id'] }) | Should -BeTrue -Because 'diagnostics are sorted by id'
    }

    It 'records inputs[].sha256 equal to the SHA-256 of the fixture bytes with size equal to their length, sorted by path, and no withheld path' {
        $script:Snapshot['inputs'].Count | Should -Be $script:Captured.Count
        [string[]] $paths = @($script:Snapshot['inputs'] | ForEach-Object { [string] $_['path'] })
        Test-TestOrdinalOrder -Value $paths | Should -BeTrue -Because 'inputs are sorted by path'
        foreach ($entry in $script:Snapshot['inputs']) {
            $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes([string] $script:Inputs[[string] $entry['path']])
            $entry['sha256'] | Should -BeExactly (Get-DocsBytesSha256Hex -Bytes $bytes) -Because $entry['path']
            $entry['size'] | Should -Be $bytes.Length -Because $entry['path']
        }
        foreach ($path in $script:Selection.Withheld) { $paths | Should -Not -Contain $path }
        foreach ($element in $script:Snapshot['elements']) { $paths | Should -Contain $element['path'] }
    }

    It 'gives an over-bound input and an undecodable input (the two 1020 capture rows, built in test code) no inputs entry and no element while a 1,048,576-byte input is accepted' {
        $testProfile = Get-TestProfile -SourceRoot @('src') -ElementKind @('public-symbol')
        $overBound = [System.Text.UTF8Encoding]::new($false).GetBytes('#' + [string]::new('a', 1048576))
        $overBound.Length | Should -Be 1048577
        $atBound = [System.Text.UTF8Encoding]::new($false).GetBytes('#' + [string]::new('b', 1048575))
        $atBound.Length | Should -Be 1048576
        $captured = @(
            (New-DocsCapturedInput -Path 'src/big.py' -Bytes $overBound -MaxBytes 1048576),
            (New-DocsCapturedInput -Path 'src/edge.py' -Bytes $atBound -MaxBytes 1048576),
            (New-DocsCapturedInput -Path 'src/bad.py' -Bytes ([byte[]]@(0x78, 0x20, 0x3D, 0x20, 0xFF, 0xFE, 0x0A)) -MaxBytes 1048576),
            (New-DocsCapturedInput -Path 'src/ok.py' -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes("value = 1`n")) -MaxBytes 1048576)
        )
        $row = Get-TestRegistryRow -Id 'python-public-api'
        $outputs = Invoke-TestAnalyzerSet -Captured $captured -TestProfile $testProfile -Registration $row
        $snapshot = New-DocsInventorySnapshot -Profile $testProfile -Revision ('a' * 40) -Registration $row -CapturedInput $captured -AnalyzerOutput $outputs -CapturedAt $script:Clock
        Get-TestSnapshotFinding -Snapshot $snapshot | Should -BeNullOrEmpty
        @($snapshot['inputs'] | ForEach-Object { $_['path'] }) | Should -Be @('src/edge.py', 'src/ok.py')
        @($snapshot['elements'] | ForEach-Object { $_['path'] }) | Should -Be @('src/ok.py')
        $captureDiagnostics = @($snapshot['diagnostics'] | Where-Object { $_['analyzer_id'] -ceq 'docs-capture' } | ForEach-Object { $_['code'] + '|' + $_['path'] + '|' + $_['severity'] + '|' + $_['blocking'] })
        $captureDiagnostics | Should -Be @('DOCS_INPUT_NOT_UTF8|src/bad.py|warning|False', 'DOCS_INPUT_TOO_LARGE|src/big.py|warning|False')
        $snapshot['revision'] | Should -BeExactly ('a' * 40)
    }

    It 'filters elements to surface_selection.element_kinds, drops a repeated element_id with DUPLICATE_DECLARATION, de-duplicates diagnostics by id and excludes captured_at from the id' {
        $testProfile = Get-TestProfile -ElementKind @('config-key')
        $configOnly = ConvertTo-TestCaptured -Source $script:ConfigCorpus['inputs'] -Skip $script:Selection.Withheld
        $row = Get-TestRegistryRow -Id 'config-files'
        $outputs = Invoke-TestAnalyzerSet -Captured $configOnly -TestProfile $testProfile -Registration $row
        $duplicate = @{ Elements = @($outputs[0]['Elements'][0]); Diagnostics = @($outputs[0]['Diagnostics'][0]) }
        $foreignKind = @{ Elements = @($script:Snapshot['elements'] | Where-Object { $_['kind'] -ceq 'http-route' }); Diagnostics = @() }
        $first = New-DocsInventorySnapshot -Profile $testProfile -Revision $null -Registration $row -CapturedInput $configOnly -AnalyzerOutput (@($outputs) + @($duplicate, $foreignKind)) -Diagnostic (@($script:Selection.Diagnostics) + @($script:Selection.Diagnostics[0])) -CapturedAt $script:Clock
        $second = New-DocsInventorySnapshot -Profile $testProfile -Revision $null -Registration $row -CapturedInput $configOnly -AnalyzerOutput $outputs -Diagnostic $script:Selection.Diagnostics -CapturedAt $script:Clock.AddDays(1)
        Get-TestSnapshotFinding -Snapshot $first | Should -BeNullOrEmpty
        @($first['elements'] | ForEach-Object { $_['kind'] } | Sort-Object -Unique) | Should -Be @('config-key')
        $first['elements'].Count | Should -Be $script:ConfigCorpus['expected_elements'].Count
        $duplicateDiagnostics = @($first['diagnostics'] | Where-Object { $_['code'] -ceq 'DUPLICATE_DECLARATION' })
        $duplicateDiagnostics.Count | Should -Be 1
        $duplicateDiagnostics[0]['analyzer_id'] | Should -BeExactly 'docs-inventory'
        $duplicateDiagnostics[0]['severity'] | Should -BeExactly 'warning'
        $duplicateDiagnostics[0]['path'] | Should -BeExactly $outputs[0]['Elements'][0]['path']
        @($first['diagnostics'] | Where-Object { $_['code'] -ceq 'ENV_FILE_NOT_CAPTURED' }).Count | Should -Be 3
        $second['elements'].Count | Should -Be $first['elements'].Count
        $second['id'] | Should -BeExactly $first['id'] -Because 'the id excludes captured_at'
        $second['captured_at'] | Should -BeExactly '2026-01-02T00:00:00Z'
        $first['id'] | Should -Not -BeExactly $script:Snapshot['id'] -Because 'the profile and inputs differ'
    }

    It 'property: New-DocsInventorySnapshot is byte-identical under permuted inputs and analyzer outputs' {
        $seed = 102250
        $random = [System.Random]::new($seed)
        $baseline = ConvertTo-DocsCanonicalJson -Value $script:Snapshot
        for ($iteration = 0; $iteration -lt 4; $iteration++) {
            $captured = @($script:Captured | Sort-Object -Property @{ Expression = { $random.Next() } })
            $outputs = @($script:Outputs | Sort-Object -Property @{ Expression = { $random.Next() } } | ForEach-Object { @{ Elements = @($_['Elements'] | Sort-Object -Property @{ Expression = { $random.Next() } }); Diagnostics = @($_['Diagnostics'] | Sort-Object -Property @{ Expression = { $random.Next() } }) } })
            $diagnostics = @($script:Selection.Diagnostics | Sort-Object -Property @{ Expression = { $random.Next() } })
            $registration = @($script:Registry | Sort-Object -Property @{ Expression = { $random.Next() } })
            $snapshot = New-DocsInventorySnapshot -Profile $script:TestProfile -Revision $null -Registration $registration -CapturedInput $captured -AnalyzerOutput $outputs -Diagnostic $diagnostics -CapturedAt $script:Clock
            (ConvertTo-DocsCanonicalJson -Value $snapshot) | Should -BeExactly $baseline -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsInventorySelection' {
    It 'applies source roots, exclusions (exact, prefix, glob, dictionary entries) and env withholding, and sorts the result' {
        $paths = @('src/b.py', 'src/a.py', 'src/vendor/x.py', 'src/skip.py', 'src/notes.md', 'src/deep/notes.md', 'config/.env', 'config/.env.local', 'config/app.env', 'config/.env.example', 'config/.env.dist', 'other/c.py', 'pyproject.toml', '', 'src/.env')
        $exclusions = @(@{ path_or_glob = 'src/skip.py'; rationale = 'r' }, 'src/vendor', @{ path_or_glob = '**/*.md' })
        $result = Get-DocsInventorySelection -Path $paths -SourceRoot @('src', 'config/') -Exclusion $exclusions
        $result.Paths | Should -Be @('config/.env.dist', 'config/.env.example', 'src/a.py', 'src/b.py')
        $result.Withheld | Should -Be @('config/.env', 'config/.env.local', 'config/app.env', 'src/.env')
        @($result.Diagnostics | ForEach-Object { $_['code'] + '|' + $_['path'] + '|' + $_['analyzer_id'] + '|' + $_['severity'] + '|' + $_['blocking'] }) | Should -Be @('ENV_FILE_NOT_CAPTURED|config/.env|docs-inventory|warning|False', 'ENV_FILE_NOT_CAPTURED|config/.env.local|docs-inventory|warning|False', 'ENV_FILE_NOT_CAPTURED|config/app.env|docs-inventory|warning|False', 'ENV_FILE_NOT_CAPTURED|src/.env|docs-inventory|warning|False')
        foreach ($diagnostic in $result.Diagnostics) { $diagnostic['message'].Contains('MARKER') | Should -BeFalse }
        $dot = Get-DocsInventorySelection -Path @('pyproject.toml', 'other/c.py', 'z/.env') -SourceRoot @('.') -Exclusion $null
        $dot.Paths | Should -Be @('other/c.py', 'pyproject.toml')
        $dot.Withheld | Should -Be @('z/.env')
        $empty = Get-DocsInventorySelection -Path $null -SourceRoot @('src') -Exclusion @()
        $empty.Paths.Count | Should -Be 0
        $empty.Diagnostics.Count | Should -Be 0
    }

    It 'property: Get-DocsInventorySelection selects exactly the paths that pass the root, exclusion and env predicates in any order' {
        $seed = 102251
        $random = [System.Random]::new($seed)
        $exclusions = @('src/skip.py', 'src/vendor', @{ path_or_glob = 'config/*.md' })
        for ($iteration = 0; $iteration -lt 40; $iteration++) {
            $count = $random.Next(0, 25)
            $paths = [System.Collections.Generic.List[string]]::new()
            $expectedSelected = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
            $expectedWithheld = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
            for ($i = 0; $i -lt $count; $i++) {
                $directory = @('src', 'config', 'other', 'src/vendor', 'src/pkg')[$random.Next(5)]
                $name = @('a.py', 'skip.py', '.env', '.env.local', 'x.env', '.env.example', 'n.md', 'c.yaml')[$random.Next(8)]
                $path = $directory + '/' + $name
                $paths.Add($path)
                $underRoot = $path.StartsWith('src/') -or $path.StartsWith('config/')
                $excluded = ($path -ceq 'src/skip.py') -or $path.StartsWith('src/vendor/') -or ($path -cmatch '^config/[^/]*\.md$')
                $envFamily = ($name -ceq '.env') -or $name.StartsWith('.env.') -or $name.EndsWith('.env')
                $template = $name -ceq '.env.example'
                if (-not $underRoot -or $excluded) { continue }
                if ($envFamily -and -not $template) { [void] $expectedWithheld.Add($path) } else { [void] $expectedSelected.Add($path) }
            }
            $shuffled = @($paths | Sort-Object -Property @{ Expression = { $random.Next() } })
            $result = Get-DocsInventorySelection -Path ([string[]] $shuffled) -SourceRoot @('src', 'config') -Exclusion $exclusions
            ($result.Paths -join ',') | Should -BeExactly (@($expectedSelected) -join ',') -Because "seed $seed, iteration $iteration"
            ($result.Withheld -join ',') | Should -BeExactly (@($expectedWithheld) -join ',') -Because "seed $seed, iteration $iteration"
            (@($result.Diagnostics | ForEach-Object { $_['path'] }) -join ',') | Should -BeExactly (@($expectedWithheld) -join ',') -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsInventoryBoundFinding' {
    It 'returns null within both bounds and one DOCS_CLI_RUNTIME error finding above either bound, naming no path' {
        Get-DocsInventoryBoundFinding -InputCount 50000 -TotalBytes 268435456 | Should -BeNullOrEmpty
        $count = Get-DocsInventoryBoundFinding -InputCount 50001 -TotalBytes 0
        $count['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
        $count['severity'] | Should -BeExactly 'error'
        $count['message'] | Should -BeLike '*50001*'
        $bytes = Get-DocsInventoryBoundFinding -InputCount 0 -TotalBytes 268435457
        $bytes['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
        $bytes['message'] | Should -BeLike '*268435457*'
        $bytes['artifact_path'] | Should -BeNullOrEmpty
    }

    It 'property: Get-DocsInventoryBoundFinding returns a finding exactly when a bound is exceeded' {
        $seed = 102252
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = [long] (50000 + $random.Next(-3, 4))
            $bytes = [long] (268435456 + $random.Next(-3, 4))
            $expected = ($count -gt 50000) -or ($bytes -gt 268435456)
            $finding = Get-DocsInventoryBoundFinding -InputCount $count -TotalBytes $bytes
            ($null -ne $finding) | Should -Be $expected -Because "seed $seed, iteration $iteration, count $count, bytes $bytes"
        }
    }
}
