#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsJsonSchemaKeys.psm1 (issue #1022).

.DESCRIPTION
    Covers member line spans, every schema walk form (root and nested properties, object-form
    items, allOf, anyOf, oneOf, local $ref to $defs and definitions), a $ref cycle, a remote
    $ref, a missing target, depth 17, each non-expanded keyword, that marker values in default,
    enum, const, examples and pattern never appear, with a seeded property test per exported
    function. Inputs are in-memory strings.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJsonSchemaKeys.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop

    $script:Marker = 'MARKER_VALUE_9913'
    $script:Schema = @(
        '{'
        '  "$schema": "https://json-schema.org/draft/2020-12/schema",'
        '  "type": "object",'
        '  "required": ["name", "tags"],'
        '  "properties": {'
        '    "name": {'
        '      "type": "string",'
        '      "default": "MARKER_VALUE_9913",'
        '      "pattern": "^MARKER_VALUE_9913$"'
        '    },'
        '    "mode": { "type": ["string", "null"], "enum": ["MARKER_VALUE_9913"] },'
        '    "limit": { "const": "MARKER_VALUE_9913", "examples": ["MARKER_VALUE_9913"] },'
        '    "tags": {'
        '      "type": "array",'
        '      "items": {'
        '        "type": "object",'
        '        "properties": { "label": { "type": "string" } }'
        '      }'
        '    },'
        '    "nested": {'
        '      "type": "object",'
        '      "properties": {'
        '        "inner": { "$ref": "#/$defs/leaf" }'
        '      }'
        '    },'
        '    "legacy": { "$ref": "#/definitions/old" },'
        '    "either": {'
        '      "anyOf": ['
        '        { "properties": { "a": { "type": "integer" } } },'
        '        { "properties": { "b": { "type": "boolean" } } }'
        '      ]'
        '    },'
        '    "all": { "allOf": [ { "properties": { "c": {} } } ] },'
        '    "one": { "oneOf": [ { "properties": { "d": { "type": "number" } } } ] }'
        '  },'
        '  "$defs": {'
        '    "leaf": { "type": "object", "required": ["deep"], "properties": { "deep": { "type": "string" } } }'
        '  },'
        '  "definitions": {'
        '    "old": { "properties": { "older": { "type": "string" } } }'
        '  }'
        '}'
    ) -join "`n"

    function Get-TestSchemaKey {
        param([string] $Text)
        $parsed = ConvertFrom-DocsJsonText -Text $Text
        $parsed.Findings.Count | Should -Be 0 -Because 'the fixture is valid JSON'
        return Get-DocsJsonSchemaKey -Value $parsed.Value -MemberSpan (Get-DocsJsonMemberSpan -Text $Text)
    }
}

AfterAll {
    Remove-Module -Name DocsJsonSchemaKeys, DocsSourceText, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsJsonMemberSpan' {
    It 'maps object members, array elements and the root to line spans' {
        # Arrange
        $text = "{`n  `"a`": 1,`n  `"b/c~`": {`n    `"d`": [`n      1,`n      {`"e`": true}`n    ]`n  },`n  `"f`": `"x\`"y`"`n}"

        # Act
        $spans = Get-DocsJsonMemberSpan -Text $text

        # Assert
        $spans[''] | Should -Be @(1, 10)
        $spans['/a'] | Should -Be @(2, 2)
        $spans['/b~1c~0'] | Should -Be @(3, 8)
        $spans['/b~1c~0/d'] | Should -Be @(4, 7)
        $spans['/b~1c~0/d/0'] | Should -Be @(5, 5)
        $spans['/b~1c~0/d/1'] | Should -Be @(6, 6)
        $spans['/b~1c~0/d/1/e'] | Should -Be @(6, 6)
        $spans['/f'] | Should -Be @(9, 9)
    }

    It 'normalizes CRLF and a BOM and spans a one-line document' {
        $spans = Get-DocsJsonMemberSpan -Text ([string][char]0xFEFF + "{`r`n`"a`": {}`r`n}")
        $spans['/a'] | Should -Be @(2, 2)
        (Get-DocsJsonMemberSpan -Text '{"a": [1, 2], "b": null}')['/b'] | Should -Be @(1, 1)
    }

    It 'property: Get-DocsJsonMemberSpan places each generated member on its written lines' {
        $seed = 102270
        $random = [System.Random]::new($seed)
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(1, 8)
            $lines = [System.Collections.Generic.List[string]]::new()
            $lines.Add('{')
            $expected = [System.Collections.Generic.List[object]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $start = $lines.Count + 1
                $height = $random.Next(0, 3)
                if ($height -eq 0) { $lines.Add("  `"k$i`": $i" + $(if ($i -lt $count - 1) { ',' } else { '' })) }
                else {
                    $lines.Add("  `"k$i`": {")
                    for ($j = 0; $j -lt $height; $j++) { $lines.Add("    `"n$j`": `"v`"" + $(if ($j -lt $height - 1) { ',' } else { '' })) }
                    $lines.Add('  }' + $(if ($i -lt $count - 1) { ',' } else { '' }))
                }
                $expected.Add(@{ Pointer = "/k$i"; Start = $start; End = $lines.Count })
            }
            $lines.Add('}')
            $spans = Get-DocsJsonMemberSpan -Text ($lines -join "`n")
            foreach ($entry in $expected) {
                $spans[$entry['Pointer']] | Should -Be @($entry['Start'], $entry['End']) -Because "seed $seed, iteration $iteration, $($entry['Pointer'])"
            }
        }
    }
}

Describe 'Get-DocsJsonSchemaKey' {
    It 'walks properties, items, combiners and local refs and never reads a value' {
        # Act
        $result = Get-TestSchemaKey -Text $script:Schema

        # Assert
        $result.Diagnostics.Count | Should -Be 0
        $rows = @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $(if ($null -eq $_['SchemaType']) { '-' } else { $_['SchemaType'] }) + '|' + $_['Required'] + '|' + $_['Conditional'] + '|' + $_['Span'][0] + '-' + $_['Span'][1] })
        $rows | Should -Be @(
            'all|-|False|False|33-33'
            'all.c|-|False|False|33-33'
            'either|-|False|False|27-32'
            'either.a|integer|False|True|29-29'
            'either.b|boolean|False|True|30-30'
            'legacy|-|False|False|26-26'
            'legacy.older|string|False|False|40-40'
            'limit|-|False|False|12-12'
            'mode|multiple|False|False|11-11'
            'name|string|True|False|6-10'
            'nested|object|False|False|20-25'
            'nested.inner|-|False|False|23-23'
            'nested.inner.deep|string|True|False|37-37'
            'one|-|False|False|34-34'
            'one.d|number|False|True|34-34'
            'tags|array|True|False|13-19'
            'tags.[].label|string|False|False|17-17'
        )
        (ConvertTo-Json -InputObject $result -Depth 6) | Should -Not -Match $script:Marker
    }

    It 'returns nothing for a null value or a schema without properties' {
        (Get-DocsJsonSchemaKey -Value $null -MemberSpan $null).Keys.Count | Should -Be 0
        (Get-TestSchemaKey -Text '{"type": "string"}').Keys.Count | Should -Be 0
    }

    It 'reports JSON_SCHEMA_REF_UNRESOLVED for <Case> and keeps the other keys' -TestCases @(
        @{ Case = 'a remote $ref'; Text = "{`n`"properties`": {`n`"a`": { `"`$ref`": `"https://example.test/s.json`" },`n`"b`": {}`n}`n}"; Line = 3 }
        @{ Case = 'a missing target'; Text = "{`n`"properties`": {`n`"a`": { `"`$ref`": `"#/`$defs/nope`" },`n`"b`": {}`n}`n}"; Line = 3 }
        @{ Case = 'a cycle'; Text = "{`n`"properties`": { `"a`": { `"`$ref`": `"#/`$defs/x`" }, `"b`": {} },`n`"`$defs`": { `"x`": { `"properties`": { `"c`": { `"`$ref`": `"#/`$defs/x`" } } } }`n}"; Line = 3 }
    ) {
        $result = Get-TestSchemaKey -Text $Text
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'JSON_SCHEMA_REF_UNRESOLVED'
        $result.Diagnostics[0]['Severity'] | Should -BeExactly 'warning'
        $result.Diagnostics[0]['Blocking'] | Should -BeFalse
        $result.Diagnostics[0]['Line'] | Should -Be $Line
        @($result.Keys | ForEach-Object { $_['Segment'][0] }) | Should -Contain 'b'
        @($result.Keys | ForEach-Object { $_['Segment'][0] }) | Should -Contain 'a'
    }

    It 'stops at depth 17 with JSON_SCHEMA_REF_UNRESOLVED and walks depth 16' {
        $deep = '{"type": "string"}'
        for ($level = 17; $level -ge 1; $level--) { $deep = "{`"properties`": {`"p$level`": $deep}}" }
        $result = Get-TestSchemaKey -Text $deep
        $result.Keys.Count | Should -Be 16
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'JSON_SCHEMA_REF_UNRESOLVED'
        $shallow = '{"type": "string"}'
        for ($level = 16; $level -ge 1; $level--) { $shallow = "{`"properties`": {`"p$level`": $shallow}}" }
        (Get-TestSchemaKey -Text $shallow).Diagnostics.Count | Should -Be 0
    }

    It 'reports JSON_SCHEMA_KEYWORD_NOT_EXPANDED for <Keyword> and does not enumerate keys beneath it' -TestCases @(
        @{ Keyword = 'if'; Fragment = '"if": { "properties": { "h": {} } }' }
        @{ Keyword = 'then'; Fragment = '"then": { "properties": { "h": {} } }' }
        @{ Keyword = 'else'; Fragment = '"else": { "properties": { "h": {} } }' }
        @{ Keyword = 'not'; Fragment = '"not": { "properties": { "h": {} } }' }
        @{ Keyword = 'patternProperties'; Fragment = '"patternProperties": { "^x": { "properties": { "h": {} } } }' }
        @{ Keyword = 'additionalProperties'; Fragment = '"additionalProperties": { "properties": { "h": {} } }' }
        @{ Keyword = 'dependentSchemas'; Fragment = '"dependentSchemas": { "a": { "properties": { "h": {} } } }' }
        @{ Keyword = 'prefixItems'; Fragment = '"prefixItems": [ { "properties": { "h": {} } } ]' }
        @{ Keyword = 'unevaluatedProperties'; Fragment = '"unevaluatedProperties": { "properties": { "h": {} } }' }
    ) {
        $result = Get-TestSchemaKey -Text "{`n`"properties`": { `"a`": {} },`n$Fragment`n}"
        @($result.Keys | ForEach-Object { $_['Segment'] -join '.' }) | Should -Be @('a')
        $result.Diagnostics.Count | Should -Be 1
        $result.Diagnostics[0]['Code'] | Should -BeExactly 'JSON_SCHEMA_KEYWORD_NOT_EXPANDED'
        $result.Diagnostics[0]['Blocking'] | Should -BeFalse
        $result.Diagnostics[0]['Line'] | Should -Be 3
    }

    It 'treats a boolean additionalProperties as expanded' {
        (Get-TestSchemaKey -Text '{"properties": {"a": {}}, "additionalProperties": false}').Diagnostics.Count | Should -Be 0
    }

    It 'property: Get-DocsJsonSchemaKey emits every generated property path once with its type and required flag' {
        $seed = 102271
        $random = [System.Random]::new($seed)
        $types = @('string', 'integer', 'object', 'boolean')
        for ($iteration = 0; $iteration -lt 100; $iteration++) {
            $count = $random.Next(1, 6)
            $expected = [System.Collections.Generic.List[string]]::new()
            $members = [System.Collections.Generic.List[string]]::new()
            $required = [System.Collections.Generic.List[string]]::new()
            for ($i = 0; $i -lt $count; $i++) {
                $type = $types[$random.Next($types.Length)]
                $isRequired = $random.Next(2) -eq 0
                if ($isRequired) { $required.Add("`"k$i`"") }
                if ($type -ceq 'object') {
                    $members.Add("`"k$i`": {`"type`": `"object`", `"properties`": {`"child`": {`"type`": `"string`", `"default`": `"MARK`"}}}")
                    $expected.Add("k$i|object|$isRequired")
                    $expected.Add("k$i.child|string|False")
                } else {
                    $members.Add("`"k$i`": {`"type`": `"$type`", `"enum`": [`"MARK`"]}")
                    $expected.Add("k$i|$type|$isRequired")
                }
            }
            $text = '{"required": [' + ($required -join ', ') + '], "properties": {' + ($members -join ', ') + '}}'
            $result = Get-TestSchemaKey -Text $text
            $result.Diagnostics.Count | Should -Be 0 -Because "seed $seed, iteration $iteration"
            @($result.Keys | ForEach-Object { ($_['Segment'] -join '.') + '|' + $_['SchemaType'] + '|' + $_['Required'] }) | Should -Be $expected.ToArray() -Because "seed $seed, iteration $iteration"
            (ConvertTo-Json -InputObject $result.Keys -Depth 4) | Should -Not -Match 'MARK' -Because "seed $seed, iteration $iteration"
        }
    }
}
