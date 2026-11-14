#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsTomlKeys.psm1 (issue #1022).

.DESCRIPTION
    Covers table and array-of-tables headers, dotted and quoted keys, every value extent
    (basic, literal, multi-line strings, arrays spanning lines with comments, inline tables,
    numbers, booleans, date-times), the TOML diagnostics with code, severity, blocking flag and
    effect, that marker values never appear in the output, console-script entries and
    CLI_CONSOLE_SCRIPT_UNSUPPORTED, with a seeded property test per exported function. Inputs
    are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsTomlKeys.psm1') -Force -ErrorAction Stop

    $script:Marker = 'MARKER_VALUE_7731'
    $script:Document = @(
        '# leading comment'
        'title = "MARKER_VALUE_7731"'
        'count = 42'
        'ratio = 1.5e3'
        'flag = true'
        'when = 2026-01-02T03:04:05Z'
        'literal = ''MARKER_VALUE_7731'''
        'multi = """'
        'MARKER_VALUE_7731'
        '"""'
        'items = ['
        '  "MARKER_VALUE_7731", # comment with ] bracket'
        '  2,'
        ']'
        'inline = { a = "MARKER_VALUE_7731", b = 1 }'
        ''
        '[tool.black]'
        'line-length = 88'
        '"quoted.key" = "MARKER_VALUE_7731"'
        'a.b.c = ''MARKER_VALUE_7731'''
        ''
        '# comment between tables'
        '[[tool.poetry.packages]]'
        'include = "MARKER_VALUE_7731"'
        '[[tool.poetry.packages]]'
        'include = "MARKER_VALUE_7731"'
        'extra = 1'
        ''
        '[project]'
        'name = "MARKER_VALUE_7731"'
    ) -join "`n"
}

AfterAll {
    Remove-Module -Name DocsTomlKeys, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsTomlKey' {
    It 'returns every key path with its span and value type and never a value' {
        # Act
        $result = Get-DocsTomlKey -Text $script:Document

        # Assert
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'TOML_INLINE_TABLE_NOT_EXPANDED'
        $rows = @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['ValueType'] + '|' + $_['Span'][0] + '-' + $_['Span'][1] })
        $rows | Should -Be @(
            'title|string|2-2'
            'count|integer|3-3'
            'ratio|float|4-4'
            'flag|boolean|5-5'
            'when|datetime|6-6'
            'literal|string|7-7'
            'multi|string|8-10'
            'items|array|11-14'
            'inline|table|15-15'
            'tool.black|table|17-20'
            'tool.black.line-length|integer|18-18'
            'tool.black.quoted.key|string|19-19'
            'tool.black.a.b.c|string|20-20'
            'tool.poetry.packages|array|23-24'
            'tool.poetry.packages.[].include|string|24-24'
            'tool.poetry.packages.[].extra|integer|27-27'
            'project|table|29-30'
            'project.name|string|30-30'
        )
        $serialized = ($result.Keys | ForEach-Object { ($_.Keys | ForEach-Object { [string] $_[$_] }) -join ' ' }) -join ' '
        $serialized | Should -Not -Match $script:Marker
        (ConvertTo-Json -InputObject $result -Depth 6) | Should -Not -Match $script:Marker
    }

    It 'returns no keys and no diagnostics for the empty text' {
        $result = Get-DocsTomlKey -Text ''
        $result.Keys.Count | Should -Be 0
        $result.Diagnostics.Count | Should -Be 0
    }

    It 'reports TOML_INVALID as a blocking error with no keys for: <Case>' -TestCases @(
        @{ Case = 'an unterminated string'; Text = "a = 1`nb = `"open"; Line = 2 }
        @{ Case = 'an unterminated array'; Text = "a = [`n 1,`n"; Line = 1 }
        @{ Case = 'a malformed header'; Text = "[tool.black`nx = 1"; Line = 1 }
        @{ Case = 'a key without ='; Text = "a = 1`nb"; Line = 2 }
        @{ Case = 'a duplicate key'; Text = "a = 1`na = 2"; Line = 2 }
        @{ Case = 'a table redefinition'; Text = "[t]`nx = 1`n[t]`ny = 2"; Line = 3 }
        @{ Case = 'a multi-line inline table'; Text = "a = {`n b = 1 }"; Line = 1 }
        @{ Case = 'an unrecognized value'; Text = 'a = yes'; Line = 1 }
    ) {
        $result = Get-DocsTomlKey -Text $Text
        $result.Keys.Count | Should -Be 0
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'TOML_INVALID'
        $result.Diagnostics[0]['Severity'] | Should -BeExactly 'error'
        $result.Diagnostics[0]['Blocking'] | Should -BeTrue
        $result.Diagnostics[0]['Line'] | Should -Be $Line
    }

    It 'reports TOML_INLINE_TABLE_NOT_EXPANDED and emits the key as a table without inner keys' {
        $result = Get-DocsTomlKey -Text "x = { a = 1, b = { c = 2 } }`ny = 3"
        @($result.Keys | ForEach-Object { $_['Segment'] -join '.' }) | Should -Be @('x', 'y')
        $result.Keys[0]['ValueType'] | Should -BeExactly 'table'
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'TOML_INLINE_TABLE_NOT_EXPANDED'
        $result.Diagnostics[0]['Severity'] | Should -BeExactly 'warning'
        $result.Diagnostics[0]['Blocking'] | Should -BeFalse
        $result.Diagnostics[0]['Line'] | Should -Be 1
    }

    It 'reports TOML_KEY_ESCAPE_UNSUPPORTED and drops only that key' {
        $result = Get-DocsTomlKey -Text "`"a\tb`" = 1`nplain = 2`n[`"h\nx`"]`nz = 1"
        @($result.Keys | ForEach-Object { $_['Segment'] -join '.' }) | Should -Be @('plain')
        @($result.Diagnostics | ForEach-Object { $_['Code'] }) | Should -Be @('TOML_KEY_ESCAPE_UNSUPPORTED', 'TOML_KEY_ESCAPE_UNSUPPORTED', 'TOML_KEY_ESCAPE_UNSUPPORTED')
        $result.Diagnostics[0]['Blocking'] | Should -BeFalse
        $result.Diagnostics[0]['Severity'] | Should -BeExactly 'warning'
        @($result.Diagnostics | ForEach-Object { $_['Line'] }) | Should -Be @(1, 3, 4)
    }

    It 'accepts a repeated key path under separate array-of-tables elements and rejects a repeat inside one element' {
        $ok = Get-DocsTomlKey -Text "[[a]]`nx = 1`n[[a]]`nx = 2"
        $ok.Diagnostics.Count | Should -Be 0
        @($ok.Keys | ForEach-Object { $_['Segment'] -join '.' }) | Should -Be @('a', 'a.[].x')
        $bad = Get-DocsTomlKey -Text "[[a]]`nx = 1`nx = 2"
        $bad.Diagnostics[0]['Code'] | Should -BeExactly 'TOML_INVALID'
    }

    It 'property: Get-DocsTomlKey emits one key per generated entry with the generated value type and never the value' {
        $seed = 102250
        $random = [System.Random]::new($seed)
        $values = @(
            @{ Text = '"v-MARK"'; Type = 'string' }, @{ Text = "'v-MARK'"; Type = 'string' }, @{ Text = '17'; Type = 'integer' },
            @{ Text = '2.5'; Type = 'float' }, @{ Text = 'false'; Type = 'boolean' }, @{ Text = '1979-05-27'; Type = 'datetime' },
            @{ Text = "[`n  1,`n  2, # c`n]"; Type = 'array' }, @{ Text = "`"`"`"`nMARK`n`"`"`""; Type = 'string' }
        )
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(1, 8)
            $lines = [System.Collections.Generic.List[string]]::new()
            $expected = [System.Collections.Generic.List[string]]::new()
            if ($random.Next(2) -eq 0) { $lines.Add('[tool.x]'); $expected.Add('tool.x|table'); $prefix = 'tool.x.' } else { $prefix = '' }
            for ($i = 0; $i -lt $count; $i++) {
                $value = $values[$random.Next($values.Length)]
                $lines.Add("k$i = " + $value['Text'])
                $expected.Add($prefix + "k$i|" + $value['Type'])
            }
            $result = Get-DocsTomlKey -Text ($lines -join "`n")
            $result.Diagnostics.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['ValueType'] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
            (ConvertTo-Json -InputObject $result.Keys -Depth 4) | Should -Not -Match 'MARK' -Because "seed $seed, iteration $iteration"
        }
    }
}

Describe 'Get-DocsTomlScriptEntry' {
    It 'returns one-line string entries of the three script tables with their spans' {
        # Arrange
        $text = @(
            '[project]'
            'name = "x"'
            '[project.scripts]'
            'tool = "pkg.cli:main"'
            '"quoted-name" = "pkg.cli:other"'
            '[project.gui-scripts]'
            'gui = "pkg.gui:run"'
            '[tool.poetry.scripts]'
            'poet = ''pkg.cli:main'''
            '[tool.other]'
            'ignored = "pkg:x"'
        ) -join "`n"

        # Act
        $result = Get-DocsTomlScriptEntry -Text $text

        # Assert
        $result.Diagnostics.Count | Should -Be 0
        @($result.Entries | ForEach-Object { $_['Table'] + '|' + $_['Name'] + '|' + $_['Target'] + '|' + $_['Span'][0] }) | Should -Be @(
            'project.scripts|tool|pkg.cli:main|4'
            'project.scripts|quoted-name|pkg.cli:other|5'
            'project.gui-scripts|gui|pkg.gui:run|7'
            'tool.poetry.scripts|poet|pkg.cli:main|9'
        )
    }

    It 'reports CLI_CONSOLE_SCRIPT_UNSUPPORTED for a non-string, multi-line, dotted or escaped entry and keeps the others' {
        $text = @(
            '[project.scripts]'
            'ok = "pkg:main"'
            'multi = """'
            'pkg:main'
            '"""'
            'num = 1'
            'arr = ["pkg:main"]'
            'a.b = "pkg:main"'
            '"e\tx" = "pkg:main"'
        ) -join "`n"
        $result = Get-DocsTomlScriptEntry -Text $text
        @($result.Entries | ForEach-Object { $_['Name'] }) | Should -Be @('ok')
        $result.Diagnostics.Count | Should -Be 5
        foreach ($diagnostic in $result.Diagnostics) {
            $diagnostic['Code'] | Should -BeExactly 'CLI_CONSOLE_SCRIPT_UNSUPPORTED'
            $diagnostic['Severity'] | Should -BeExactly 'warning'
            $diagnostic['Blocking'] | Should -BeFalse
        }
        @($result.Diagnostics | ForEach-Object { $_['Line'] }) | Should -Be @(3, 6, 7, 8, 9)
    }

    It 'passes TOML_INVALID through with no entries' {
        $result = Get-DocsTomlScriptEntry -Text "[project.scripts]`nx = "
        $result.Entries.Count | Should -Be 0
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'TOML_INVALID'
    }

    It 'property: Get-DocsTomlScriptEntry returns the generated name and target of every entry' {
        $seed = 102251
        $random = [System.Random]::new($seed)
        $tables = @('project.scripts', 'project.gui-scripts', 'tool.poetry.scripts')
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $table = $tables[$random.Next($tables.Length)]
            $count = $random.Next(1, 6)
            $lines = [System.Collections.Generic.List[string]]::new()
            $lines.Add("[$table]")
            $expected = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $quote = if ($random.Next(2) -eq 0) { '"' } else { "'" }
                $lines.Add("name$i = ${quote}pkg.mod${i}:fn$i$quote")
                $expected.Add("$table|name$i|pkg.mod${i}:fn$i")
            }
            $result = Get-DocsTomlScriptEntry -Text ($lines -join "`n")
            $result.Diagnostics.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result.Entries | ForEach-Object { $_['Table'] + '|' + $_['Name'] + '|' + $_['Target'] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
        }
    }
}
