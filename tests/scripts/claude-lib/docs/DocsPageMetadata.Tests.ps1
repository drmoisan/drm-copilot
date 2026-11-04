#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageMetadata.psm1.

.DESCRIPTION
    Covers the constraint evaluator (pattern, minLength and uniqueItems through local references,
    properties, patternProperties, items and allOf), the calendar check, the last_reviewed and
    audience value checks read from the composed page-metadata schema, the mapping of schema
    findings to per-field page codes and the field finding factory. Schema texts come from the
    committed runtime files through Docs.TestSupport.psm1; every other input is in memory. No
    file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageMetadata.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Root = (ConvertFrom-DocsJsonText -Text '{"$defs":{"short":{"type":"string","minLength":3}},"properties":{"code":{"$ref":"#/$defs/short"},"tags":{"type":"array","uniqueItems":true,"items":{"pattern":"^[a-z]+$"}},"wrapped":{"allOf":[{"minLength":2}]},"bag":{"patternProperties":{"^x":{"minLength":2}}}}}').Value
    $script:PageSchema = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas['page-metadata'].Value

    function Get-TestFinding {
        param([string] $Code, [string] $Pointer, [string] $Message = 'detail')
        [ordered]@{ code = $Code; severity = 'error'; artifact_path = 'docs/page.md'; pointer = $Pointer; related_ids = @(); related_paths = @(); message = $Message; next_action = 'x' }
    }
}

AfterAll {
    Remove-Module -Name DocsPageMetadata, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsPageConstraintFinding' {
    It 'reports DOCS_SCHEMA_TOO_SHORT through a local reference' {
        # Act
        $findings = Get-DocsPageConstraintFinding -Schema $script:Root -Instance @{ code = 'AB' } -RootSchema $script:Root -PagePath 'docs/page.md'

        # Assert
        @($findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_SCHEMA_TOO_SHORT')
        $findings[0].pointer | Should -BeExactly '/code'
        $findings[0].artifact_path | Should -BeExactly 'docs/page.md'
    }

    It 'reports pattern, uniqueness, allOf and patternProperties failures at the instance pointer' {
        # Arrange
        $instance = [ordered]@{ tags = @('ok', 'Bad', 'ok'); wrapped = 'a'; bag = @{ xa = 'b'; other = 'c' } }

        # Act
        $findings = Get-DocsPageConstraintFinding -Schema $script:Root -Instance $instance -RootSchema $script:Root -PagePath 'docs/page.md'

        # Assert
        @($findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_PATTERN_MISMATCH' -and $_.pointer -eq '/tags/1' }).Count | Should -Be 1
        @($findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_ITEMS_NOT_UNIQUE' -and $_.pointer -eq '/tags/2' }).Count | Should -Be 1
        @($findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_TOO_SHORT' -and $_.pointer -eq '/wrapped' }).Count | Should -Be 1
        @($findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_TOO_SHORT' -and $_.pointer -eq '/bag/xa' }).Count | Should -Be 1
        $findings.Count | Should -Be 4
    }

    It 'leaves values of another JSON type to the structural walk' {
        # Act
        $findings = Get-DocsPageConstraintFinding -Schema $script:Root -Instance @{ code = 5; tags = 'x' } -RootSchema $script:Root -PagePath 'docs/page.md'

        # Assert
        $findings.Count | Should -Be 0
    }

    It 'returns nothing for a non-object schema node or an unresolvable reference' {
        # Act
        $boolean = Get-DocsPageConstraintFinding -Schema $true -Instance 'x' -RootSchema $script:Root -PagePath 'docs/page.md'
        $absent = Get-DocsPageConstraintFinding -Schema @{ '$ref' = '#/$defs/absent' } -Instance 'x' -RootSchema $script:Root -PagePath 'docs/page.md'
        $foreign = Get-DocsPageConstraintFinding -Schema @{ '$ref' = 'urn:other#/x' } -Instance 'x' -RootSchema $script:Root -PagePath 'docs/page.md'

        # Assert
        $boolean.Count | Should -Be 0
        $absent.Count | Should -Be 0
        $foreign.Count | Should -Be 0
    }

    It 'reads the audience item pattern from the composed page-metadata schema' {
        # Act
        $findings = Get-DocsPageConstraintFinding -Schema $script:PageSchema -Instance @{ audience = @('ok', 'Dev_Ops') } -RootSchema $script:PageSchema -PagePath 'docs/page.md'

        # Assert
        @($findings | ForEach-Object { "$($_.code) $($_.pointer)" }) | Should -Be @('DOCS_SCHEMA_PATTERN_MISMATCH /audience/1')
    }
}

Describe 'Test-DocsPageReviewDate' {
    It 'returns <Expected> for <Value>' -ForEach @(
        @{ Value = '2026-10-30'; Expected = $true }
        @{ Value = '2028-02-29'; Expected = $true }
        @{ Value = '2026-02-29'; Expected = $false }
        @{ Value = '2026-02-30'; Expected = $false }
        @{ Value = '2026-13-01'; Expected = $false }
        @{ Value = ''; Expected = $false }
    ) {
        Test-DocsPageReviewDate -Value $Value | Should -Be $Expected
    }
}

Describe 'Get-DocsPageValueFinding' {
    It 'reports a pattern-valid date that is not a calendar date, with the field line' {
        # Act
        $findings = Get-DocsPageValueFinding -FrontMatter @{ last_reviewed = '2026-02-30' } -Schema $script:PageSchema -PagePath 'docs/page.md' -AudienceId @() -FieldLine @{ last_reviewed = 4 }

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE'
        $findings[0].message | Should -Match '^line 4: '
    }

    It 'leaves a pattern-invalid or non-string last_reviewed to the schema findings' {
        # Act
        $text = Get-DocsPageValueFinding -FrontMatter @{ last_reviewed = '2026-2-30' } -Schema $script:PageSchema -PagePath 'docs/page.md' -AudienceId @()
        $number = Get-DocsPageValueFinding -FrontMatter @{ last_reviewed = 5 } -Schema $script:PageSchema -PagePath 'docs/page.md' -AudienceId @()

        # Assert
        $text.Count | Should -Be 0
        $number.Count | Should -Be 0
    }

    It 'reports each valid undeclared audience at its index and skips invalid items' {
        # Act
        $findings = Get-DocsPageValueFinding -FrontMatter @{ audience = @('dev', 'qa', 'Bad_Id', 5, 'ops') } -Schema $script:PageSchema -PagePath 'docs/page.md' -AudienceId @('dev')

        # Assert
        @($findings | ForEach-Object { "$($_.code) $($_.pointer)" }) | Should -Be @('DOCS_PAGE_AUDIENCE_UNDECLARED /audience/1', 'DOCS_PAGE_AUDIENCE_UNDECLARED /audience/4')
    }

    It 'returns nothing when the schema declares neither pattern' {
        # Act
        $findings = Get-DocsPageValueFinding -FrontMatter @{ last_reviewed = '2026-02-30'; audience = @('qa') } -Schema @{ properties = @{} } -PagePath 'docs/page.md' -AudienceId @()

        # Assert
        $findings.Count | Should -Be 0
    }
}

Describe 'ConvertTo-DocsPageFieldFinding' {
    It 'maps an unknown top-level property to DOCS_PAGE_FIELD_UNKNOWN with its line' {
        # Act
        $result = ConvertTo-DocsPageFieldFinding -Finding @(Get-TestFinding -Code 'DOCS_SCHEMA_PROPERTY_UNKNOWN' -Pointer '/reviewer') -PagePath 'docs/page.md' -FieldLine @{ reviewer = 7 }

        # Assert
        $result.SchemaInvalid | Should -BeFalse
        $result.Findings[0].code | Should -BeExactly 'DOCS_PAGE_FIELD_UNKNOWN'
        $result.Findings[0].message | Should -BeExactly "line 7: front matter field 'reviewer' is not defined by page-metadata"
    }

    It 'maps <Pointer> to <Code>' -ForEach @(
        @{ Pointer = '/owner'; Code = 'DOCS_PAGE_OWNER_INVALID' }
        @{ Pointer = '/last_reviewed'; Code = 'DOCS_PAGE_LAST_REVIEWED_INVALID' }
        @{ Pointer = '/audience/2'; Code = 'DOCS_PAGE_AUDIENCE_INVALID' }
        @{ Pointer = '/diataxis_mode'; Code = 'DOCS_PAGE_MODE_INVALID' }
        @{ Pointer = '/surface_refs/0'; Code = 'DOCS_PAGE_SURFACE_REFS_INVALID' }
        @{ Pointer = '/title'; Code = 'DOCS_PAGE_TITLE_INVALID' }
        @{ Pointer = '/extensions/note'; Code = 'DOCS_PAGE_EXTENSIONS_INVALID' }
    ) {
        # Act
        $result = ConvertTo-DocsPageFieldFinding -Finding @(Get-TestFinding -Code 'DOCS_SCHEMA_TYPE_MISMATCH' -Pointer $Pointer) -PagePath 'docs/page.md'

        # Assert
        $result.Findings[0].code | Should -BeExactly $Code
        $result.Findings[0].pointer | Should -BeExactly $Pointer
        $result.Findings[0].message | Should -Match "^front matter field '"
    }

    It 'keeps a message that already names the field' {
        # Act
        $result = ConvertTo-DocsPageFieldFinding -Finding @(Get-TestFinding -Code 'DOCS_SCHEMA_TOO_SHORT' -Pointer '/title' -Message "front matter field 'title' value is short") -PagePath 'docs/page.md'

        # Assert
        $result.Findings[0].message | Should -BeExactly "front matter field 'title' value is short"
    }

    It 'marks DOCS_SCHEMA_INVALID and findings outside the fields as schema-invalid and skips null entries' {
        # Act
        $result = ConvertTo-DocsPageFieldFinding -Finding @($null, (Get-TestFinding -Code 'DOCS_SCHEMA_INVALID' -Pointer ''), (Get-TestFinding -Code 'DOCS_SCHEMA_TYPE_MISMATCH' -Pointer '')) -PagePath 'docs/page.md'

        # Assert
        $result.SchemaInvalid | Should -BeTrue
        $result.Findings.Count | Should -Be 0
    }
}

Describe 'New-DocsPageFieldFinding' {
    It 'builds an error finding with the fixed next action and no line prefix without FieldLine' {
        # Act
        $finding = New-DocsPageFieldFinding -Code 'DOCS_PAGE_FIELD_MISSING' -Pointer '/owner' -Message 'm' -PagePath 'docs/page.md'

        # Assert
        $finding.severity | Should -BeExactly 'error'
        $finding.message | Should -BeExactly 'm'
        $finding.next_action | Should -Not -BeNullOrEmpty
    }
}
