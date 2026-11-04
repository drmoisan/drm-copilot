#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsYamlKeys.psm1 (issue #1022).

.DESCRIPTION
    Covers every classified YAML construct (block mappings, sequences with mapping items, quoted
    keys, comments, block scalars, document markers, continuation lines, single-line flow
    collections), each YAML diagnostic row with its code, severity, blocking flag and effect,
    that marker values never appear in the output, and the comment-insertion invariance
    property. Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsYamlKeys.psm1') -Force -ErrorAction Stop

    $script:Marker = 'MARKER_VALUE_8842'
    $script:Document = @(
        '---'
        '# top comment'
        'name: MARKER_VALUE_8842'
        'count: 3'
        'ratio: 2.5'
        'enabled: true'
        'nothing: ~'
        '"quoted key": ''MARKER_VALUE_8842''   # trailing comment'
        'single-key: "MARKER_VALUE_8842"'
        'long: MARKER_VALUE_8842 first'
        '  MARKER_VALUE_8842 continued'
        'nested:'
        '  inner: MARKER_VALUE_8842'
        '  deeper:'
        '    leaf: 1'
        'list:'
        '  - MARKER_VALUE_8842'
        '  - name: MARKER_VALUE_8842'
        '    port: 80'
        '  - name: MARKER_VALUE_8842'
        'script: |'
        '  MARKER_VALUE_8842 line'
        ''
        '  more: MARKER_VALUE_8842'
        'folded: >-'
        '  MARKER_VALUE_8842'
        'flow: [MARKER_VALUE_8842, 2]'
        'empty: {}'
        '...'
    ) -join "`n"
}

AfterAll {
    Remove-Module -Name DocsYamlKeys, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsYamlKey' {
    It 'returns every mapping key path with its span and value type and never a value' {
        # Act
        $result = Get-DocsYamlKey -Text $script:Document

        # Assert
        @($result.Diagnostics | ForEach-Object { $_['Code'] }) | Should -Be @('YAML_FLOW_COLLECTION_NOT_EXPANDED', 'YAML_FLOW_COLLECTION_NOT_EXPANDED')
        $rows = @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['ValueType'] + '|' + $_['Span'][0] + '-' + $_['Span'][1] })
        $rows | Should -Be @(
            'name|string|3-3'
            'count|integer|4-4'
            'ratio|number|5-5'
            'enabled|boolean|6-6'
            'nothing|null|7-7'
            'quoted key|string|8-8'
            'single-key|string|9-9'
            'long|string|10-11'
            'nested|object|12-15'
            'nested.inner|string|13-13'
            'nested.deeper|object|14-15'
            'nested.deeper.leaf|integer|15-15'
            'list|array|16-20'
            'list.[].name|string|18-18'
            'list.[].port|integer|19-19'
            'list.[].name|string|20-20'
            'script|string|21-24'
            'folded|string|25-26'
            'flow|array|27-27'
            'empty|object|28-28'
        )
        (ConvertTo-Json -InputObject $result -Depth 6) | Should -Not -Match $script:Marker
    }

    It 'returns no keys and no diagnostics for the empty text and a comment-only text' {
        (Get-DocsYamlKey -Text '').Keys.Count | Should -Be 0
        (Get-DocsYamlKey -Text "# only`n`n").Keys.Count | Should -Be 0
        (Get-DocsYamlKey -Text "# only`n`n").Diagnostics.Count | Should -Be 0
    }

    It 'reports <Code> (blocking <Blocking>) with no keys for: <Case>' -TestCases @(
        @{ Case = 'tab indentation'; Text = "a:`n`tb: 1"; Code = 'YAML_INVALID'; Blocking = $true; Line = 2 }
        @{ Case = 'a dedent to an unknown column'; Text = "a:`n    b: 1`n  c: 2"; Code = 'YAML_INVALID'; Blocking = $true; Line = 3 }
        @{ Case = 'an unterminated quoted scalar'; Text = "a: `"open`nb: 1"; Code = 'YAML_INVALID'; Blocking = $true; Line = 1 }
        @{ Case = 'a continuation line containing a mapping separator'; Text = "a: first`n  second: part"; Code = 'YAML_INVALID'; Blocking = $true; Line = 2 }
        @{ Case = 'a second document after content'; Text = "a: 1`n---`nb: 2"; Code = 'YAML_MULTI_DOCUMENT'; Blocking = $false; Line = 2 }
        @{ Case = 'content after the end marker'; Text = "a: 1`n...`nb: 2"; Code = 'YAML_MULTI_DOCUMENT'; Blocking = $false; Line = 3 }
        @{ Case = 'an anchor'; Text = "a: &x 1`nb: 2"; Code = 'YAML_ANCHOR_ALIAS'; Blocking = $false; Line = 1 }
        @{ Case = 'an alias'; Text = "a: 1`nb: *x"; Code = 'YAML_ANCHOR_ALIAS'; Blocking = $false; Line = 2 }
        @{ Case = 'a merge key'; Text = "a:`n  <<: *base"; Code = 'YAML_ANCHOR_ALIAS'; Blocking = $false; Line = 2 }
        @{ Case = 'a tag'; Text = "a: !!str 1"; Code = 'YAML_UNSUPPORTED'; Blocking = $false; Line = 1 }
        @{ Case = 'a complex key'; Text = "? a`n: 1"; Code = 'YAML_UNSUPPORTED'; Blocking = $false; Line = 1 }
        @{ Case = 'a directive'; Text = "%YAML 1.2`n---`na: 1"; Code = 'YAML_UNSUPPORTED'; Blocking = $false; Line = 1 }
        @{ Case = 'a flow collection spanning lines'; Text = "a: [1,`n  2]"; Code = 'YAML_UNSUPPORTED'; Blocking = $false; Line = 1 }
        @{ Case = 'a root sequence'; Text = "- a`n- b"; Code = 'YAML_ROOT_NOT_MAPPING'; Blocking = $false; Line = 1 }
        @{ Case = 'a root scalar'; Text = "just text"; Code = 'YAML_ROOT_NOT_MAPPING'; Blocking = $false; Line = 1 }
    ) {
        $result = Get-DocsYamlKey -Text $Text
        $result.Keys.Count | Should -Be 0
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly $Code
        $result.Diagnostics[0]['Blocking'] | Should -Be $Blocking
        $result.Diagnostics[0]['Severity'] | Should -BeExactly $(if ($Blocking) { 'error' } else { 'warning' })
        $result.Diagnostics[0]['Line'] | Should -Be $Line
    }

    It 'reports YAML_FLOW_COLLECTION_NOT_EXPANDED and emits the key with the collection type and no inner keys' {
        $result = Get-DocsYamlKey -Text "a: {x: 1, y: 2}`nb: [1, 2]`nc: 3"
        @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['ValueType'] }) | Should -Be @('a|object', 'b|array', 'c|integer')
        $result.Diagnostics.Count | Should -Be 2
        foreach ($diagnostic in $result.Diagnostics) {
            $diagnostic['Code'] | Should -BeExactly 'YAML_FLOW_COLLECTION_NOT_EXPANDED'
            $diagnostic['Severity'] | Should -BeExactly 'warning'
            $diagnostic['Blocking'] | Should -BeFalse
        }
        @($result.Diagnostics | ForEach-Object { $_['Line'] }) | Should -Be @(1, 2)
    }

    It 'reports YAML_KEY_ESCAPE_UNSUPPORTED and drops only the escaped double-quoted key' {
        $result = Get-DocsYamlKey -Text "`"a\tb`": 1`n'c\d': 2`nplain: 3"
        @($result.Keys | ForEach-Object { $_['Segment'] -join '.' }) | Should -Be @('c\d', 'plain')
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'YAML_KEY_ESCAPE_UNSUPPORTED'
        $result.Diagnostics[0]['Blocking'] | Should -BeFalse
        $result.Diagnostics[0]['Line'] | Should -Be 1
    }

    It 'accepts a document marker with a comment and keeps keys distinct by case' {
        $result = Get-DocsYamlKey -Text "--- # start`nApp: 1`napp: 2"
        $result.Diagnostics.Count | Should -Be 0
        @($result.Keys | ForEach-Object { $_['Segment'][0] }) | Should -Be @('App', 'app')
    }

    It 'property: Get-DocsYamlKey is invariant under comment insertion' {
        $seed = 102260
        $random = [System.Random]::new($seed)
        $base = @(
            'alpha: 1'
            'beta:'
            '  gamma: text'
            '  delta:'
            '    - item'
            '    - key: v'
            '      other: 2'
            'epsilon: "q"'
            'zeta: |'
            '  block'
            'eta: [1, 2]'
        )
        $reference = Get-DocsYamlKey -Text ($base -join "`n")
        $referenceRows = @($reference.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['ValueType'] })
        $referenceRows.Count | Should -Be 9
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $lines = [System.Collections.Generic.List[string]]::new()
            $insideBlock = $false
            foreach ($line in $base) {
                if (-not $insideBlock -and $random.Next(2) -eq 0) {
                    $indent = ' ' * $random.Next(0, 7)
                    $lines.Add($indent + '# inserted ' + $random.Next(1000))
                }
                if ($random.Next(3) -eq 0) { $lines.Add('') }
                $lines.Add($line)
                $insideBlock = $line.EndsWith('|')
            }
            $result = Get-DocsYamlKey -Text ($lines -join "`n")
            $result.Diagnostics.Count | Should -Be $reference.Diagnostics.Count -Because "seed $seed, iteration $iteration"
            @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['ValueType'] }) | Should -Be $referenceRows -Because "seed $seed, iteration $iteration"
        }
    }
}
