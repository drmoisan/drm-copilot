#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsSchema.psm1.

.DESCRIPTION
    Covers the schema table and paths, the schema reader seam, in-memory composition (ref rewrite,
    local refs, root identity, the version 0.7 recursion-hazard step, conflicts and unresolved
    refs), artifact validation precedence between Test-Json and the structural walk, one case per
    walk keyword including patternProperties, error-record pointer extraction and the version
    floor. Schema and example texts come from the committed runtime files through
    Docs.TestSupport.psm1; every other input is in memory. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:SchemaText = Get-DocsTestSchemaText
    $script:ExampleText = Get-DocsTestExampleText
    $script:CommonText = $script:SchemaText['common']

    function ConvertTo-TestJson {
        param([AllowNull()] [object] $Value)
        ConvertTo-DocsJsonText -Value $Value
    }

    function Get-TestParsed {
        param([string] $Text)
        (ConvertFrom-DocsJsonText -Text $Text).Value
    }

    function ConvertTo-TestCommonText {
        # A minimal docs common text with the given definitions.
        param([System.Collections.IDictionary] $Definition)
        ConvertTo-TestJson -Value ([ordered]@{ '$schema' = 'https://json-schema.org/draft/2020-12/schema'; '$id' = 'urn:drm-copilot:docs:1.0.0:common'; '$defs' = $Definition })
    }

    function Invoke-TestWalk {
        param([System.Collections.IDictionary] $Schema, [AllowNull()] [object] $Instance)
        Get-DocsSchemaStructuralFinding -Schema $Schema -Instance $Instance -RootSchema $Schema
    }

    $script:ProfileComposed = Join-DocsSchemaText -SchemaText $script:SchemaText['docs-profile'] -CommonSchemaText $script:CommonText
}

AfterAll {
    Remove-Module -Name DocsSchema, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsSchemaName and Get-DocsSchemaPath' {
    It 'lists the eight schema names in fixed order followed by the 1021 anchor in the module text' {
        # Arrange
        $expected = @('common', 'docs-profile', 'surface-inventory-snapshot', 'docs-coverage-ledger', 'docs-parity-matrix', 'docs-evidence-pin', 'docs-validation-receipt', 'docs-command-envelope')
        $moduleText = Get-Content -LiteralPath (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Raw

        # Act
        $names = Get-DocsSchemaName

        # Assert
        $names | Should -Be $expected
        $envelopeAt = $moduleText.IndexOf("'docs-command-envelope'`r", [System.StringComparison]::Ordinal)
        if ($envelopeAt -lt 0) { $envelopeAt = $moduleText.IndexOf("'docs-command-envelope'`n", [System.StringComparison]::Ordinal) }
        $anchorAt = $moduleText.IndexOf('# --- 1021: page-metadata ---', [System.StringComparison]::Ordinal)
        $envelopeAt | Should -BeGreaterThan 0
        $anchorAt | Should -BeGreaterThan $envelopeAt
    }

    It 'maps every schema name to one literal runtime path under schemas/v1' {
        # Act
        $paths = Get-DocsSchemaPath

        # Assert
        @($paths.Keys) | Should -Be (Get-DocsSchemaName)
        foreach ($name in $paths.Keys) {
            ($paths[$name] -replace '\\', '/') | Should -BeLike "*/.claude/lib/docs/schemas/v1/$name.schema.json"
        }
    }
}

Describe 'Read-DocsSchemaSet' {
    It 'reads every path through the ReadText seam' {
        # Arrange
        $seen = [System.Collections.Generic.List[string]]::new()
        $reader = { param($Path) $seen.Add([string] $Path); "text:$Path" }.GetNewClosure()

        # Act
        $set = Read-DocsSchemaSet -SchemaPath ([ordered]@{ a = 'p/a'; b = 'p/b' }) -ReadText $reader

        # Assert
        @($set.Keys) | Should -Be @('a', 'b')
        $set['b'] | Should -BeExactly 'text:p/b'
        $seen.Count | Should -Be 2
    }

    It 'reads the committed runtime schemas by default, equal to the committed text' {
        # Act
        $set = Read-DocsSchemaSet

        # Assert
        @($set.Keys) | Should -Be (Get-DocsSchemaName)
        $set['docs-profile'] | Should -BeExactly $script:SchemaText['docs-profile']
    }
}

Describe 'Join-DocsSchemaText' {
    It 'rewrites common URN refs and refs inside copied definitions to #/$defs/common.<name>' {
        # Arrange
        $value = $script:ProfileComposed.Value

        # Assert
        $script:ProfileComposed.Findings.Count | Should -Be 0
        $value['properties']['id']['$ref'] | Should -BeExactly '#/$defs/common.identifier'
        $value['$defs']['common.identifiers']['items']['$ref'] | Should -BeExactly '#/$defs/common.identifier'
        $script:ProfileComposed.Text | Should -Not -Match 'urn:drm-copilot:docs:1\.0\.0:common#'
    }

    It 'leaves target-local refs unchanged' {
        $script:ProfileComposed.Value['properties']['audiences']['items']['$ref'] | Should -BeExactly '#/$defs/audience'
    }

    It 'removes the root $id and keeps the root $schema' {
        $script:ProfileComposed.Value.Contains('$id') | Should -BeFalse
        $script:ProfileComposed.Value['$schema'] | Should -BeExactly 'https://json-schema.org/draft/2020-12/schema'
    }

    It 'replaces the self-referential common json-value with {} and keeps the extensions pattern ref to it' {
        # Arrange
        $defs = $script:ProfileComposed.Value['$defs']
        $patternSchema = @($defs['common.extensions']['patternProperties'].Values)[0]

        # Assert
        (ConvertTo-DocsCanonicalJson -Value $defs['common.json-value']) | Should -BeExactly "{}`n"
        $patternSchema['$ref'] | Should -BeExactly '#/$defs/common.json-value'
    }

    It 'reports DOCS_SCHEMA_RECURSIVE_DEF for a self-referential definition reached through items' {
        # Arrange
        $common = ConvertTo-TestCommonText -Definition ([ordered]@{ tree = [ordered]@{ type = 'array'; items = @{ '$ref' = '#/$defs/tree' } } })

        # Act
        $result = Join-DocsSchemaText -SchemaText '{"type":"object"}' -CommonSchemaText $common

        # Assert
        @($result.Findings).Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_SCHEMA_RECURSIVE_DEF'
        $result.Findings[0].pointer | Should -BeExactly '/$defs/tree'
        $result.Findings[0].message | Should -Match 'tree'
        $result.Value | Should -BeNullOrEmpty
    }

    It 'reports DOCS_SCHEMA_RECURSIVE_DEF for a definition whose root is a self reference' {
        # Arrange
        $common = ConvertTo-TestCommonText -Definition ([ordered]@{ self = @{ '$ref' = '#/$defs/self' } })

        # Act
        $result = Join-DocsSchemaText -SchemaText '{"type":"object"}' -CommonSchemaText $common

        # Assert
        @($result.Findings).Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_SCHEMA_RECURSIVE_DEF'
        $result.Findings[0].pointer | Should -BeExactly '/$defs/self'
    }

    It 'reports no finding for a definition that references a different definition' {
        # Arrange
        $common = ConvertTo-TestCommonText -Definition ([ordered]@{ leaf = @{ type = 'string' }; list = [ordered]@{ type = 'array'; items = @{ '$ref' = '#/$defs/leaf' } } })

        # Act
        $result = Join-DocsSchemaText -SchemaText '{"type":"object"}' -CommonSchemaText $common

        # Assert
        @($result.Findings).Count | Should -Be 0
        $result.Value['$defs']['common.list']['items']['$ref'] | Should -BeExactly '#/$defs/common.leaf'
    }

    It 'reports DOCS_SCHEMA_COMPOSITION_CONFLICT for a target $defs key beginning common.' {
        # Act
        $result = Join-DocsSchemaText -SchemaText '{"$defs":{"common.x":{"type":"string"}}}' -CommonSchemaText $script:CommonText

        # Assert
        @($result.Findings | ForEach-Object { $_.code }) | Should -Contain 'DOCS_SCHEMA_COMPOSITION_CONFLICT'
        @($result.Findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_COMPOSITION_CONFLICT' })[0].pointer | Should -BeExactly '/$defs/common.x'
    }

    It 'reports DOCS_SCHEMA_REF_UNRESOLVED for <Case> without calling Test-Json' -ForEach @(
        @{ Case = 'an unknown common name'; Ref = 'urn:drm-copilot:docs:1.0.0:common#/$defs/no-such-definition' }
        @{ Case = 'a foreign URN'; Ref = 'urn:drm-copilot:discovery:2.0.0:common#/$defs/identifier' }
        @{ Case = 'a file ref'; Ref = 'common.schema.json#/$defs/identifier' }
        @{ Case = 'an https ref'; Ref = 'https://example.invalid/common.schema.json#/$defs/identifier' }
    ) {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { $true }
        $schemaText = ConvertTo-TestJson -Value ([ordered]@{ type = 'object'; properties = [ordered]@{ a = @{ '$ref' = $Ref } } })

        # Act
        $result = Join-DocsSchemaText -SchemaText $schemaText -CommonSchemaText $script:CommonText

        # Assert
        @($result.Findings).Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_SCHEMA_REF_UNRESOLVED'
        $result.Findings[0].pointer | Should -BeExactly '/properties/a/$ref'
        Should -Invoke -CommandName Test-Json -ModuleName DocsSchema -Times 0 -Exactly
    }

    It 'reports DOCS_SCHEMA_REF_UNRESOLVED for an unknown name inside a copied definition' {
        # Arrange
        $common = ConvertTo-TestCommonText -Definition ([ordered]@{ list = [ordered]@{ type = 'array'; items = @{ '$ref' = '#/$defs/missing' } } })

        # Act
        $result = Join-DocsSchemaText -SchemaText '{"type":"object"}' -CommonSchemaText $common

        # Assert
        $result.Findings[0].code | Should -BeExactly 'DOCS_SCHEMA_REF_UNRESOLVED'
        $result.Findings[0].pointer | Should -BeExactly '/$defs/common.list/items/$ref'
    }

    It 'returns the parse finding for invalid schema text' {
        # Act
        $result = Join-DocsSchemaText -SchemaText '{' -CommonSchemaText $script:CommonText

        # Assert
        $result.Findings[0].code | Should -BeExactly 'DOCS_JSON_INVALID'
        $result.Text | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsComposedSchemaSet' {
    It 'composes every non-common schema of the committed set with no finding' {
        # Act
        $set = Get-DocsComposedSchemaSet -SchemaSet $script:SchemaText

        # Assert
        @($set.Findings).Count | Should -Be 0
        @($set.Schemas.Keys) | Should -Not -Contain 'common'
        $set.Schemas.Count | Should -Be ($script:SchemaText.Count - 1)
    }

    It 'returns the DOCS_SCHEMA_RECURSIVE_DEF finding once for a common text holding tree' {
        # Arrange
        $common = ConvertTo-TestCommonText -Definition ([ordered]@{ tree = [ordered]@{ type = 'array'; items = @{ '$ref' = '#/$defs/tree' } } })
        $schemaSet = [ordered]@{ common = $common; first = '{"type":"object"}'; second = '{"type":"array"}' }

        # Act
        $set = Get-DocsComposedSchemaSet -SchemaSet $schemaSet

        # Assert
        @($set.Findings).Count | Should -Be 1
        $set.Findings[0].code | Should -BeExactly 'DOCS_SCHEMA_RECURSIVE_DEF'
        $set.Findings[0].pointer | Should -BeExactly '/$defs/tree'
    }

    It 'throws when the schema set has no common schema' {
        { Get-DocsComposedSchemaSet -SchemaSet ([ordered]@{ first = '{}' }) } | Should -Throw -ExpectedMessage '*DOCS_SCHEMA_UNKNOWN_KIND*'
    }
}

Describe 'Test-DocsArtifactText' {
    BeforeAll {
        $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet $script:SchemaText).Schemas
        # An in-memory schema whose only constraint (pattern) lies outside the walk subset.
        $patternSchemaSet = [ordered]@{
            common  = ConvertTo-TestCommonText -Definition ([ordered]@{ leaf = @{ type = 'string' } })
            pattern = ConvertTo-TestJson -Value ([ordered]@{ type = 'object'; properties = [ordered]@{ name = [ordered]@{ type = 'string'; pattern = '^a' } } })
        }
        $script:PatternComposed = (Get-DocsComposedSchemaSet -SchemaSet $patternSchemaSet).Schemas
    }

    It 'accepts the committed docs-command-envelope example' {
        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $script:ExampleText['docs-command-envelope'] -ComposedSchemaSet $script:Composed

        # Assert
        $result.Count | Should -Be 0
    }

    It 'throws DOCS_SCHEMA_UNKNOWN_KIND for <Kind>' -ForEach @(@{ Kind = 'no-such-kind' }, @{ Kind = 'common' }) {
        { Test-DocsArtifactText -ArtifactKind $Kind -JsonText '{}' -ComposedSchemaSet $script:Composed } | Should -Throw -ExpectedMessage '*DOCS_SCHEMA_UNKNOWN_KIND*'
    }

    It 'returns the parse finding for invalid JSON text' {
        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'docs-profile' -JsonText '{"a":1,"a":2}' -ComposedSchemaSet $script:Composed -ArtifactPath 'docs/p.json'

        # Assert
        $result[0].code | Should -BeExactly 'DOCS_JSON_DUPLICATE_KEY'
        $result[0].artifact_path | Should -BeExactly 'docs/p.json'
    }

    It 'returns exactly one DOCS_SCHEMA_INVALID at pointer empty when Test-Json returns False with no ErrorRecord and the walk finds nothing' {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { $false }

        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'pattern' -JsonText '{"name":"b"}' -ComposedSchemaSet $script:PatternComposed

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_INVALID'
        $result[0].pointer | Should -BeExactly ''
        $result[0].message | Should -Match 'pattern'
    }

    It 'maps each Test-Json ErrorRecord to DOCS_SCHEMA_INVALID when the walk finds nothing' {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { Write-Error -Message "The value does not match at '/name'"; $false }

        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'pattern' -JsonText '{"name":"b"}' -ComposedSchemaSet $script:PatternComposed

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_INVALID'
        $result[0].pointer | Should -BeExactly '/name'
    }

    It 'maps a Test-Json exception to DOCS_SCHEMA_INVALID' {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { throw 'schema engine failure' }

        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'pattern' -JsonText '{"name":"a"}' -ComposedSchemaSet $script:PatternComposed

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_INVALID'
        $result[0].message | Should -Match 'schema engine failure'
    }

    It 'returns the walk findings when the walk reports an error, even when Test-Json returns True' {
        # Arrange
        Mock -CommandName Test-Json -ModuleName DocsSchema -MockWith { $true }

        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'pattern' -JsonText '{"name":5}' -ComposedSchemaSet $script:PatternComposed

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_TYPE_MISMATCH'
        $result[0].pointer | Should -BeExactly '/name'
    }

    It 'names a missing field inside a nested $ref target of the composed profile schema' {
        # Arrange
        $profileValue = Get-TestParsed -Text $script:ExampleText['docs-profile']
        $profileValue['surface_selection']['exclusions'][0].Remove('rationale')

        # Act
        $result = Test-DocsArtifactText -ArtifactKind 'docs-profile' -JsonText (ConvertTo-TestJson -Value $profileValue) -ComposedSchemaSet $script:Composed

        # Assert
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_REQUIRED_MISSING'
        $result[0].pointer | Should -BeExactly '/surface_selection/exclusions/0/rationale'
        $result[0].message | Should -Match 'rationale'
    }
}

Describe 'Get-DocsSchemaStructuralFinding keyword subset' {
    It 'reports DOCS_SCHEMA_TOO_DEEP when $ref expansion exceeds 64 levels' {
        # Act
        $result = Invoke-TestWalk -Schema @{ '$ref' = '#' } -Instance 'x'

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_TOO_DEEP'
    }

    It 'resolves a local $ref and walks its target' {
        # Arrange
        $schema = [ordered]@{ '$defs' = @{ s = @{ type = 'string' } }; properties = @{ a = @{ '$ref' = '#/$defs/s' } } }

        # Act
        $result = Invoke-TestWalk -Schema $schema -Instance @{ a = 1L }

        # Assert
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_TYPE_MISMATCH'
        $result[0].pointer | Should -BeExactly '/a'
        $result[0].message | Should -Match "'a'"
    }

    It 'applies type as a string and as an array of names, with integer accepting Int64' {
        # Act and Assert
        (Invoke-TestWalk -Schema @{ type = 'integer' } -Instance 3L).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = 'number' } -Instance 3L).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = 'integer' } -Instance 2.5).Count | Should -Be 1
        (Invoke-TestWalk -Schema @{ type = @('string', 'null') } -Instance $null).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = @('string', 'null') } -Instance $true)[0].code | Should -BeExactly 'DOCS_SCHEMA_TYPE_MISMATCH'
        (Invoke-TestWalk -Schema @{ type = 'array' } -Instance @{ }).Count | Should -Be 1
    }

    It 'reports each absent required name at its pointer' {
        # Act
        $result = Invoke-TestWalk -Schema @{ required = @('a', 'b') } -Instance @{ a = 1L }

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_REQUIRED_MISSING'
        $result[0].pointer | Should -BeExactly '/b'
    }

    It 'walks properties and reports unknown members under additionalProperties false' {
        # Arrange
        $schema = @{ additionalProperties = $false; properties = @{ a = @{ type = 'string' } } }

        # Act
        $result = Invoke-TestWalk -Schema $schema -Instance ([ordered]@{ a = 'x'; z = 1L })

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_PROPERTY_UNKNOWN'
        $result[0].pointer | Should -BeExactly '/z'
    }

    It 'reports enum and const violations with the allowed values' {
        # Act
        $enumResult = Invoke-TestWalk -Schema @{ enum = @('a', 'b') } -Instance 'c'
        $constResult = Invoke-TestWalk -Schema @{ const = 0L } -Instance 1L

        # Assert
        $enumResult[0].code | Should -BeExactly 'DOCS_SCHEMA_VALUE_NOT_ALLOWED'
        $enumResult[0].message | Should -Match '"a", "b"'
        $constResult[0].code | Should -BeExactly 'DOCS_SCHEMA_VALUE_NOT_ALLOWED'
        (Invoke-TestWalk -Schema @{ const = 0L } -Instance 0L).Count | Should -Be 0
    }

    It 'walks items at each index and checks minItems and maxItems' {
        # Act
        $itemResult = Invoke-TestWalk -Schema @{ items = @{ type = 'string' } } -Instance @('a', 1L)
        $tooFew = Invoke-TestWalk -Schema @{ minItems = 2 } -Instance @('a')
        $tooMany = Invoke-TestWalk -Schema @{ maxItems = 1 } -Instance @('a', 'b')

        # Assert
        $itemResult[0].pointer | Should -BeExactly '/1'
        $tooFew[0].code | Should -BeExactly 'DOCS_SCHEMA_ITEM_COUNT'
        $tooMany[0].code | Should -BeExactly 'DOCS_SCHEMA_ITEM_COUNT'
    }

    It 'walks every allOf member at the same location' {
        # Act
        $result = Invoke-TestWalk -Schema @{ allOf = @(@{ required = @('a') }, @{ required = @('b') }) } -Instance @{ }

        # Assert
        $result.Count | Should -Be 2
    }

    It 'walks then when if holds and else when it does not' {
        # Arrange
        $schema = @{ if = @{ properties = @{ k = @{ const = 'x' } } }; then = @{ required = @('t') }; else = @{ required = @('e') } }

        # Act
        $thenResult = Invoke-TestWalk -Schema $schema -Instance @{ k = 'x' }
        $elseResult = Invoke-TestWalk -Schema $schema -Instance @{ k = 'y' }

        # Assert
        $thenResult[0].pointer | Should -BeExactly '/t'
        $elseResult[0].pointer | Should -BeExactly '/e'
    }

    It 'reports DOCS_SCHEMA_NO_BRANCH_MATCH when no anyOf branch holds' {
        # Arrange
        $schema = @{ anyOf = @(@{ type = 'string' }, @{ type = 'null' }) }

        # Act and Assert
        (Invoke-TestWalk -Schema $schema -Instance $null).Count | Should -Be 0
        (Invoke-TestWalk -Schema $schema -Instance 1L)[0].code | Should -BeExactly 'DOCS_SCHEMA_NO_BRANCH_MATCH'
    }

    It 'ignores keywords outside the subset and a non-object schema' {
        (Invoke-TestWalk -Schema @{ pattern = '^a'; minimum = 5 } -Instance 'b').Count | Should -Be 0
        (Get-DocsSchemaStructuralFinding -Schema $true -Instance 1L -RootSchema @{ }).Count | Should -Be 0
    }
}

Describe 'Get-DocsSchemaStructuralFinding patternProperties' {
    BeforeAll {
        $script:ExtensionsSchema = $script:ProfileComposed.Value['$defs']['common.extensions']
        $script:ProfileRoot = $script:ProfileComposed.Value
    }

    It 'accepts a non-empty extensions object with the member vendor.note' {
        # Act
        $result = Get-DocsSchemaStructuralFinding -Schema $script:ExtensionsSchema -Instance @{ 'vendor.note' = 'x' } -RootSchema $script:ProfileRoot -Pointer '/extensions'

        # Assert
        $result.Count | Should -Be 0
    }

    It 'reports the member note at /extensions/note as unknown' {
        # Act
        $result = Get-DocsSchemaStructuralFinding -Schema $script:ExtensionsSchema -Instance @{ note = 'x' } -RootSchema $script:ProfileRoot -Pointer '/extensions'

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_PROPERTY_UNKNOWN'
        $result[0].pointer | Should -BeExactly '/extensions/note'
    }

    It 'walks a member matching both a properties name and a pattern with both subschemas' {
        # Arrange
        $schema = @{ additionalProperties = $false; properties = @{ 'a.b' = @{ type = 'string' } }; patternProperties = @{ '^a\.' = @{ enum = @('x') } } }

        # Act
        $result = Invoke-TestWalk -Schema $schema -Instance @{ 'a.b' = 5L }

        # Assert
        @($result | ForEach-Object { $_.code }) | Should -Contain 'DOCS_SCHEMA_TYPE_MISMATCH'
        @($result | ForEach-Object { $_.code }) | Should -Contain 'DOCS_SCHEMA_VALUE_NOT_ALLOWED'
        @($result | ForEach-Object { $_.pointer } | Select-Object -Unique) | Should -Be @('/a.b')
    }
}

Describe 'ConvertFrom-DocsSchemaErrorRecord' {
    It 'extracts the final pointer of the message' {
        # Arrange
        $record = [System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Required properties are missing at '/a/b'"), 'X', 'InvalidData', $null)

        # Act
        $finding = ConvertFrom-DocsSchemaErrorRecord -ErrorRecord $record -ArtifactPath 'docs/a.json'

        # Assert
        $finding.code | Should -BeExactly 'DOCS_SCHEMA_INVALID'
        $finding.pointer | Should -BeExactly '/a/b'
        $finding.artifact_path | Should -BeExactly 'docs/a.json'
    }

    It 'uses an empty pointer when the message carries none' {
        # Arrange
        $record = [System.Management.Automation.ErrorRecord]::new([System.Exception]::new('Schema failure'), 'X', 'InvalidData', $null)

        # Act and Assert
        (ConvertFrom-DocsSchemaErrorRecord -ErrorRecord $record).pointer | Should -BeExactly ''
    }
}

Describe 'Get-DocsRuntimeVersionError' {
    It 'returns the fail-closed message below 7.4' {
        Get-DocsRuntimeVersionError -PowerShellVersion ([version] '7.3') | Should -Match '7\.4'
    }

    It 'returns null at 7.4 and on the current host' {
        Get-DocsRuntimeVersionError -PowerShellVersion ([version] '7.4') | Should -BeNullOrEmpty
        Get-DocsRuntimeVersionError | Should -BeNullOrEmpty
    }
}
