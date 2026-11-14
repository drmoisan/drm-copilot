#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Contract tests for schemas/docs/v1/page-metadata.schema.json and its runtime copy.

.DESCRIPTION
    Reads the committed canonical and runtime schema files (read-only) and asserts their byte
    identity, the schema identity and root shape, the seven property names, the audience item
    pattern resolved through the composed docs common audience-id definition, the absence of
    discovery or file references, composition through Join-DocsSchemaText, and Test-Json results
    for a valid instance and for the audience item Dev_Ops. No file is written.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    Import-Module -Name (Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib/docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib/docs/DocsJson.psm1') -ErrorAction Stop

    $script:CanonicalPath = Join-Path -Path $script:RepositoryRoot -ChildPath 'schemas/docs/v1/page-metadata.schema.json'
    $script:RuntimePath = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib/docs/schemas/v1/page-metadata.schema.json'
    $script:SchemaText = ConvertFrom-DocsUtf8Bytes -Bytes ([System.IO.File]::ReadAllBytes($script:CanonicalPath))
    $script:CommonText = ConvertFrom-DocsUtf8Bytes -Bytes ([System.IO.File]::ReadAllBytes((Join-Path -Path $script:RepositoryRoot -ChildPath 'schemas/docs/v1/common.schema.json')))
    $script:Schema = (ConvertFrom-DocsJsonText -Text $script:SchemaText).Value
    $script:Composed = Join-DocsSchemaText -SchemaText $script:SchemaText -CommonSchemaText $script:CommonText
    $script:ElementId = 'cli-command-' + ('0123456789abcdef' * 4)

    function Get-TestRefValue {
        param([AllowNull()] [object] $Node)
        if ($Node -is [System.Collections.IDictionary]) {
            foreach ($key in @($Node.Keys)) {
                if ($key -ceq '$ref' -and $Node[$key] -is [string]) { $Node[$key] }
                Get-TestRefValue -Node $Node[$key]
            }
        } elseif ($Node -is [System.Collections.IList]) {
            foreach ($item in $Node) { Get-TestRefValue -Node $item }
        }
    }

    function Test-TestInstance {
        param([System.Collections.IDictionary] $Instance)
        [bool] (Test-Json -Json (ConvertTo-DocsJsonText -Value $Instance) -Schema $script:Composed.Text -ErrorAction SilentlyContinue)
    }

    function Get-TestInstance {
        [ordered]@{
            owner         = 'team-docs'
            last_reviewed = '2026-10-30'
            audience      = @('developers', 'operators')
            diataxis_mode = 'reference'
            surface_refs  = @($script:ElementId)
            title         = 'Command reference'
            extensions    = @{ 'vendor.note' = 'kept' }
        }
    }
}

AfterAll {
    Remove-Module -Name DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'page-metadata schema files' {
    It 'keeps the runtime copy byte-identical to the canonical schema' {
        # Act
        $canonical = Get-DocsBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:CanonicalPath))
        $runtime = Get-DocsBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:RuntimePath))

        # Assert
        $runtime | Should -BeExactly $canonical
    }

    It 'declares the docs identity, a closed object root and no required list' {
        $script:Schema['$schema'] | Should -BeExactly 'https://json-schema.org/draft/2020-12/schema'
        $script:Schema['$id'] | Should -BeExactly 'urn:drm-copilot:docs:1.0.0:page-metadata'
        $script:Schema['type'] | Should -BeExactly 'object'
        $script:Schema['additionalProperties'] | Should -BeFalse
        $script:Schema.Contains('required') | Should -BeFalse
    }

    It 'defines exactly the seven page-metadata properties and no artifact header' {
        # Arrange
        [string[]] $names = @($script:Schema['properties'].Keys)
        [Array]::Sort($names, [System.StringComparer]::Ordinal)

        # Assert
        $names | Should -Be @('audience', 'diataxis_mode', 'extensions', 'last_reviewed', 'owner', 'surface_refs', 'title')
    }

    It 'references only docs common definitions, never a discovery URN or a file' {
        # Act
        $refs = @(Get-TestRefValue -Node $script:Schema)

        # Assert
        $refs.Count | Should -BeGreaterThan 0
        foreach ($ref in $refs) { $ref.StartsWith('urn:drm-copilot:docs:1.0.0:common#/$defs/', [System.StringComparison]::Ordinal) | Should -BeTrue -Because "ref '$ref'" }
    }

    It 'makes audience a non-empty array of unique docs common audience-id items' {
        # Arrange
        $audience = $script:Schema['properties']['audience']

        # Assert
        $audience['type'] | Should -BeExactly 'array'
        $audience['minItems'] | Should -Be 1
        $audience['uniqueItems'] | Should -BeTrue
        $audience['items']['$ref'] | Should -BeExactly 'urn:drm-copilot:docs:1.0.0:common#/$defs/audience-id'
    }

    It 'resolves the composed audience item pattern to the guarded epic pattern of docs common audience-id' {
        # Arrange
        $itemRef = $script:Composed.Value['properties']['audience']['items']['$ref']

        # Assert
        $itemRef | Should -BeExactly '#/$defs/common.audience-id'
        $script:Composed.Value['$defs']['common.audience-id']['pattern'] | Should -BeExactly '^[a-z0-9][a-z0-9-]*$(?![\s\S])'
    }
}

Describe 'page-metadata composition and Test-Json' {
    It 'composes with docs common through Join-DocsSchemaText with no finding' {
        @($script:Composed.Findings).Count | Should -Be 0
        $script:Composed.Text | Should -Not -BeNullOrEmpty
    }

    It 'accepts a complete valid instance' {
        Test-TestInstance -Instance (Get-TestInstance) | Should -BeTrue
    }

    It 'accepts an instance with no field, because required fields are profile data' {
        Test-TestInstance -Instance ([ordered]@{}) | Should -BeTrue
    }

    It 'rejects <Case>' -ForEach @(
        @{ Case = 'the audience item Dev_Ops'; Field = 'audience'; Value = @('Dev_Ops') }
        @{ Case = 'an empty audience'; Field = 'audience'; Value = @() }
        @{ Case = 'a repeated audience'; Field = 'audience'; Value = @('developers', 'developers') }
        @{ Case = 'an unknown diataxis_mode'; Field = 'diataxis_mode'; Value = 'guide' }
        @{ Case = 'a non-date last_reviewed'; Field = 'last_reviewed'; Value = '30/10/2026' }
        @{ Case = 'an unknown property'; Field = 'reviewer'; Value = 'x' }
    ) {
        # Arrange
        $instance = Get-TestInstance
        $instance[$Field] = $Value

        # Act and assert
        Test-TestInstance -Instance $instance | Should -BeFalse
    }
}
