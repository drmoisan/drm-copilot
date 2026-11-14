#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsSchemaWalk.psm1.

.DESCRIPTION
    One case per keyword of the structural walk subset ($ref and its depth bound, type,
    required, properties with additionalProperties false, enum, const, items, minItems,
    maxItems, allOf, if/then/else, anyOf), plus keywords outside the subset and a non-object
    schema. The patternProperties cases run through Get-DocsSchemaStructuralFinding in
    DocsSchema.Tests.ps1. All schemas and instances are in memory.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchemaWalk.psm1') -Force -ErrorAction Stop

    function Invoke-TestWalk {
        param([System.Collections.IDictionary] $Schema, [AllowNull()] [object] $Instance)
        Get-DocsSchemaWalkFinding -Schema $Schema -Instance $Instance -RootSchema $Schema
    }
}

AfterAll {
    Remove-Module -Name DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsSchemaWalkFinding keyword subset' {
    It 'reports DOCS_SCHEMA_TOO_DEEP when $ref expansion exceeds 64 levels' {
        # Act
        $result = Invoke-TestWalk -Schema @{ '$ref' = '#' } -Instance 'x'

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_TOO_DEEP'
    }

    It 'resolves a local $ref and walks its target, and ignores an unresolvable ref' {
        # Arrange
        $schema = [ordered]@{ '$defs' = @{ s = @{ type = 'string' } }; properties = @{ a = @{ '$ref' = '#/$defs/s' }; b = @{ '$ref' = '#/$defs/missing' }; c = @{ '$ref' = 'other' } } }

        # Act
        $result = Invoke-TestWalk -Schema $schema -Instance ([ordered]@{ a = 1L; b = 1L; c = 1L })

        # Assert
        $result.Count | Should -Be 1
        $result[0].code | Should -BeExactly 'DOCS_SCHEMA_TYPE_MISMATCH'
        $result[0].pointer | Should -BeExactly '/a'
        $result[0].message | Should -Match "'a'"
    }

    It 'applies type as a string and as an array of names, with integer accepting Int64' {
        # Act and Assert
        (Invoke-TestWalk -Schema @{ type = 'integer' } -Instance 3L).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = 'number' } -Instance 3L).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = 'integer' } -Instance 2.0).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = 'integer' } -Instance 2.5).Count | Should -Be 1
        (Invoke-TestWalk -Schema @{ type = @('string', 'null') } -Instance $null).Count | Should -Be 0
        (Invoke-TestWalk -Schema @{ type = @('string', 'null') } -Instance $true)[0].code | Should -BeExactly 'DOCS_SCHEMA_TYPE_MISMATCH'
        (Invoke-TestWalk -Schema @{ type = 'array' } -Instance @{ }).Count | Should -Be 1
        (Invoke-TestWalk -Schema @{ type = 'object' } -Instance @('a', 'b')).Count | Should -Be 1
        (Invoke-TestWalk -Schema @{ type = 'string' } -Instance ([System.Guid]::Empty))[0].message | Should -Match 'unknown'
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
        (Get-DocsSchemaWalkFinding -Schema $true -Instance 1L -RootSchema @{ }).Count | Should -Be 0
    }

    It 'names the root field (root) and unescapes pointer segments in messages' {
        # Act
        $root = Invoke-TestWalk -Schema @{ type = 'string' } -Instance 1L
        $escaped = Get-DocsSchemaWalkFinding -Schema @{ type = 'string' } -Instance 1L -RootSchema @{ } -Pointer '/a~1b~0c'

        # Assert
        $root[0].message | Should -Match '\(root\)'
        $escaped[0].message | Should -Match "'a/b~c'"
    }
}
