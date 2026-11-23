#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Schema-layer tests for the documentation family and legacy exclusion members of the docs profile (issue #1218).

.DESCRIPTION
    Each case builds an in-memory profile from the committed example profile, adds one
    documentation family and one legacy exclusion that satisfy the semantic rules (the family
    directory lies under the first documentation root, its audience is the first declared audience,
    and its mode is listed in diataxis_policy.modes), applies one mutation, and validates the text
    through ConvertFrom-DocsProfileText. The schema layer reports DOCS_SCHEMA_* codes; the
    semantic layer does not run on a schema-invalid profile. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ExampleProfile = (Get-DocsTestExampleText)['docs-profile']

    function Get-FamilyTestProfile {
        # Returns the example profile with one valid documentation family and one valid legacy exclusion.
        $value = (ConvertFrom-DocsJsonText -Text $script:ExampleProfile).Value
        $root = [string] $value['documentation_roots'][0]['path']
        $value['required_families'] = @(
            [ordered]@{
                id                   = 'security'
                directory            = "$root/security"
                diataxis_mode        = [string] $value['diataxis_policy']['modes'][1]
                template             = 'security'
                audience             = @([string] $value['audiences'][0]['id'])
                review_interval_days = 90L
                required             = $true
            }
        )
        $value['legacy_exclusions'] = @([ordered]@{ path = 'docs/debugging.md'; reason = 'The page is migrated to the security family.' })
        return $value
    }

    function Invoke-FamilyTestProfile {
        param([Parameter(Mandatory)] [object] $Value)
        $text = if ($Value -is [string]) { $Value } else { ConvertTo-DocsJsonText -Value $Value }
        ConvertFrom-DocsProfileText -Text $text -ArtifactPath 'docs/documentation-estate/docs-profile.json' -ComposedSchemaSet $script:Composed
    }
}

AfterAll {
    foreach ($name in 'Get-FamilyTestProfile', 'Invoke-FamilyTestProfile') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
    Remove-Module -Name DocsProfile, DocsProfileFamilies, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'docs profile without documentation families (AC3, AC4)' {
    It 'accepts the unmodified example profile text with no finding' {
        # Act
        $result = Invoke-FamilyTestProfile -Value $script:ExampleProfile

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
    }

    It 'accepts a profile that omits required_families and legacy_exclusions with no finding' {
        # Arrange
        $value = Get-FamilyTestProfile
        $value.Remove('required_families')
        $value.Remove('legacy_exclusions')

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
        $result.Profile.Contains('required_families') | Should -BeFalse
    }

    It 'accepts empty required_families and legacy_exclusions arrays with no finding' {
        # Arrange
        $value = Get-FamilyTestProfile
        $value['required_families'] = @()
        $value['legacy_exclusions'] = @()

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
    }

    It 'accepts the valid family and legacy exclusion fixture with no finding' {
        # Act
        $result = Invoke-FamilyTestProfile -Value (Get-FamilyTestProfile)

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
        @($result.Profile['required_families']).Count | Should -Be 1
    }
}

Describe 'documentation family schema rejections (AC5, AC6, AC7, AC8)' {
    It 'reports DOCS_SCHEMA_REQUIRED_MISSING at /required_families/0/<Field> when the family omits <Field>' -ForEach @(
        @{ Field = 'id' }
        @{ Field = 'directory' }
        @{ Field = 'diataxis_mode' }
        @{ Field = 'template' }
        @{ Field = 'audience' }
        @{ Field = 'review_interval_days' }
        @{ Field = 'required' }
    ) {
        # Arrange
        $value = Get-FamilyTestProfile
        $value['required_families'][0].Remove($Field)

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeFalse
        $result.Profile | Should -BeNullOrEmpty
        @($result.Findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_REQUIRED_MISSING' -and $_.pointer -eq "/required_families/0/$Field" }).Count | Should -Be 1
    }

    It 'reports <Code> at <Pointer> for <Case>' -ForEach @(
        @{ Case = 'an unknown key in a family'; Code = 'DOCS_SCHEMA_PROPERTY_UNKNOWN'; Pointer = '/required_families/0/owner'; Mutate = { param($p) $p['required_families'][0]['owner'] = 'docs-team' } }
        @{ Case = 'an unknown key in an exclusion'; Code = 'DOCS_SCHEMA_PROPERTY_UNKNOWN'; Pointer = '/required_families/0/exclusion/by'; Mutate = { param($p) $p['required_families'][0]['exclusion'] = [ordered]@{ reason = 'Not offered.'; recorded_at = '2026-11-23T00:00:00Z'; by = 'owner' } } }
        @{ Case = 'an unknown key in a legacy record'; Code = 'DOCS_SCHEMA_PROPERTY_UNKNOWN'; Pointer = '/legacy_exclusions/0/owner'; Mutate = { param($p) $p['legacy_exclusions'][0]['owner'] = 'docs-team' } }
        @{ Case = 'required as a string'; Code = 'DOCS_SCHEMA_TYPE_MISMATCH'; Pointer = '/required_families/0/required'; Mutate = { param($p) $p['required_families'][0]['required'] = 'yes' } }
        @{ Case = 'review_interval_days as a string'; Code = 'DOCS_SCHEMA_TYPE_MISMATCH'; Pointer = '/required_families/0/review_interval_days'; Mutate = { param($p) $p['required_families'][0]['review_interval_days'] = '90' } }
        @{ Case = 'review_interval_days as a non-integer number'; Code = 'DOCS_SCHEMA_TYPE_MISMATCH'; Pointer = '/required_families/0/review_interval_days'; Mutate = { param($p) $p['required_families'][0]['review_interval_days'] = [double] 1.5 } }
        @{ Case = 'required_families as an object'; Code = 'DOCS_SCHEMA_TYPE_MISMATCH'; Pointer = '/required_families'; Mutate = { param($p) $p['required_families'] = [ordered]@{} } }
        @{ Case = 'a diataxis_mode outside the enum'; Code = 'DOCS_SCHEMA_VALUE_NOT_ALLOWED'; Pointer = '/required_families/0/diataxis_mode'; Mutate = { param($p) $p['required_families'][0]['diataxis_mode'] = 'guide' } }
        @{ Case = 'an empty audience'; Code = 'DOCS_SCHEMA_ITEM_COUNT'; Pointer = '/required_families/0/audience'; Mutate = { param($p) $p['required_families'][0]['audience'] = @() } }
        @{ Case = 'an exclusion without reason'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING'; Pointer = '/required_families/0/exclusion/reason'; Mutate = { param($p) $p['required_families'][0]['exclusion'] = [ordered]@{ recorded_at = '2026-11-23T00:00:00Z' } } }
        @{ Case = 'an exclusion without recorded_at'; Code = 'DOCS_SCHEMA_REQUIRED_MISSING'; Pointer = '/required_families/0/exclusion/recorded_at'; Mutate = { param($p) $p['required_families'][0]['exclusion'] = [ordered]@{ reason = 'No managed service is offered.' } } }
    ) {
        # Arrange
        $value = Get-FamilyTestProfile
        & $Mutate $value

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeFalse
        $result.Profile | Should -BeNullOrEmpty
        @($result.Findings | Where-Object { $_.code -eq $Code -and $_.pointer -eq $Pointer }).Count | Should -Be 1 -Because "$Case is reported as $Code at $Pointer"
    }

    It 'reports DOCS_SCHEMA_INVALID for <Case>' -ForEach @(
        @{ Case = 'review_interval_days of 0'; Mutate = { param($p) $p['required_families'][0]['review_interval_days'] = 0L } }
        @{ Case = 'a negative review_interval_days'; Mutate = { param($p) $p['required_families'][0]['review_interval_days'] = -1L } }
        @{ Case = 'recorded_at without the UTC Z form'; Mutate = { param($p) $p['required_families'][0]['exclusion'] = [ordered]@{ reason = 'Not offered.'; recorded_at = '2026-11-23T00:00:00+00:00' } } }
        @{ Case = 'an empty reason'; Mutate = { param($p) $p['legacy_exclusions'][0]['reason'] = '' } }
        @{ Case = 'a whitespace-only reason'; Mutate = { param($p) $p['required_families'][0]['exclusion'] = [ordered]@{ reason = '   '; recorded_at = '2026-11-23T00:00:00Z' } } }
        @{ Case = 'a legacy path with a .. segment'; Mutate = { param($p) $p['legacy_exclusions'][0]['path'] = 'docs/../debugging.md' } }
        @{ Case = 'a legacy path with a glob character'; Mutate = { param($p) $p['legacy_exclusions'][0]['path'] = 'docs/legacy/*.md' } }
        @{ Case = 'a family directory with a leading /'; Mutate = { param($p) $p['required_families'][0]['directory'] = '/docs/security' } }
        @{ Case = 'a family directory with a backslash'; Mutate = { param($p) $p['required_families'][0]['directory'] = 'docs\security' } }
        @{ Case = 'an uppercase family id'; Mutate = { param($p) $p['required_families'][0]['id'] = 'Security' } }
        @{ Case = 'a template id with a space'; Mutate = { param($p) $p['required_families'][0]['template'] = 'How To' } }
        @{ Case = 'a duplicate audience entry'; Mutate = { param($p) $p['required_families'][0]['audience'] = @('maintainers', 'maintainers') } }
    ) {
        # Arrange
        $value = Get-FamilyTestProfile
        & $Mutate $value

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeFalse
        $result.Profile | Should -BeNullOrEmpty
        @($result.Findings | Where-Object { $_.code -eq 'DOCS_SCHEMA_INVALID' }).Count | Should -BeGreaterThan 0 -Because "$Case is reported as DOCS_SCHEMA_INVALID"
    }

    It 'accepts review_interval_days of 1' {
        # Arrange
        $value = Get-FamilyTestProfile
        $value['required_families'][0]['review_interval_days'] = 1L

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
    }

    It 'accepts a well-formed exclusion with required set to <Required>' -ForEach @(
        @{ Required = $true }
        @{ Required = $false }
    ) {
        # Arrange
        $value = Get-FamilyTestProfile
        $value['required_families'][0]['required'] = $Required
        $value['required_families'][0]['exclusion'] = [ordered]@{ reason = 'No managed service is offered.'; recorded_at = '2026-11-23T00:00:00Z' }

        # Act
        $result = Invoke-FamilyTestProfile -Value $value

        # Assert
        $result.Ok | Should -BeTrue
        $result.Findings.Count | Should -Be 0
        $result.Profile['required_families'][0]['exclusion']['recorded_at'] | Should -BeExactly '2026-11-23T00:00:00Z'
    }
}
