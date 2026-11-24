#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsProfileFamilies.psm1 (issue #1218).

.DESCRIPTION
    Covers the default documentation family set (values, order, key order, documentation root
    prefix, parameter validation) and each semantic rule of Test-DocsProfileFamilySemantic (F1
    to F5 and L1) at its exact code and pointer, with the boundaries the spec states. Profiles are
    in-memory ordered dictionaries; no file is read or written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfileFamilies.psm1') -Force -ErrorAction Stop

    function New-FamilyTestRecord {
        # Returns one documentation family record that passes every semantic rule of New-FamilyTestProfile.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string] $Id = 'security', [string] $Directory = 'docs/guide/security', [string] $Mode = 'explanation', [string[]] $Audience = @('maintainers'))
        [ordered]@{ id = $Id; directory = $Directory; diataxis_mode = $Mode; template = 'security'; audience = $Audience; review_interval_days = 90L; required = $true }
    }

    function New-FamilyTestProfile {
        # Returns a schema-shaped profile with one documentation root docs/guide and the given families and legacy exclusions.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([object[]] $Family = @(), [object[]] $Legacy = $null)
        $value = [ordered]@{
            audiences           = @([ordered]@{ id = 'maintainers'; description = 'People who change this repository.' }, [ordered]@{ id = 'operators'; description = 'People who run the product.' })
            documentation_roots = @([ordered]@{ id = 'guide'; path = 'docs/guide'; audience_ids = @('maintainers') })
            diataxis_policy     = [ordered]@{ modes = @('how-to', 'reference', 'explanation'); required_front_matter = @(); directory_modes = @() }
            required_families   = $Family
        }
        if ($null -ne $Legacy) { $value['legacy_exclusions'] = $Legacy }
        return $value
    }

    function Get-FamilyFindingKey {
        # Returns 'code pointer' for every finding, in order.
        param([object[]] $Finding)
        return [string[]] @(foreach ($item in $Finding) { "$($item.code) $($item.pointer)" })
    }

    $script:ExpectedDefault = @(
        , @('product-overview', 'explanation', 'product-overview', @('product-owners', 'end-users', 'maintainers'), 90)
        , @('getting-started', 'how-to', 'onboarding', @('end-users', 'maintainers', 'operators'), 90)
        , @('user-guides', 'how-to', 'how-to', @('end-users'), 90)
        , @('administration', 'how-to', 'how-to', @('operators'), 90)
        , @('security', 'explanation', 'security', @('security-reviewers'), 90)
        , @('operations', 'how-to', 'runbook', @('operators'), 90)
        , @('service-management', 'explanation', 'service-management', @('operators', 'product-owners'), 90)
        , @('architecture', 'explanation', 'architecture-overview', @('maintainers', 'security-reviewers'), 180)
        , @('adr', 'explanation', 'adr', @('maintainers'), 180)
        , @('reference', 'reference', 'api-reference', @('maintainers', 'operators'), 90)
    )
}

AfterAll {
    foreach ($name in 'New-FamilyTestRecord', 'New-FamilyTestProfile', 'Get-FamilyFindingKey') { Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue }
    Remove-Module -Name DocsProfileFamilies, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsDefaultFamilySet' {
    It 'returns the ten default documentation families of the spec table in order for docs/guide (AC15)' {
        # Act
        $families = Get-DocsDefaultFamilySet -DocumentationRoot 'docs/guide'

        # Assert
        $families.Count | Should -Be $script:ExpectedDefault.Count
        for ($index = 0; $index -lt $script:ExpectedDefault.Count; $index++) {
            $expected = $script:ExpectedDefault[$index]
            $family = $families[$index]
            $family['id'] | Should -BeExactly $expected[0]
            $family['directory'] | Should -BeExactly "docs/guide/$($expected[0])"
            $family['diataxis_mode'] | Should -BeExactly $expected[1]
            $family['template'] | Should -BeExactly $expected[2]
            @($family['audience']) | Should -BeExactly $expected[3]
            $family['review_interval_days'] | Should -Be $expected[4]
            $family['required'] | Should -BeOfType [bool]
            $family['required'] | Should -BeTrue
            $family.Contains('exclusion') | Should -BeFalse
        }
    }

    It 'orders the keys of every record as id, directory, diataxis_mode, template, audience, review_interval_days, required (AC15)' {
        # Arrange
        $expectedKeys = @('id', 'directory', 'diataxis_mode', 'template', 'audience', 'review_interval_days', 'required')

        # Act
        $families = Get-DocsDefaultFamilySet -DocumentationRoot 'docs/guide'

        # Assert
        foreach ($family in $families) {
            $keys = [string[]] @($family.Keys)
            $keys.Count | Should -Be $expectedKeys.Count
            for ($position = 0; $position -lt $expectedKeys.Count; $position++) {
                [string]::Equals($keys[$position], $expectedKeys[$position], [System.StringComparison]::Ordinal) | Should -BeTrue -Because "key $position of $($family['id']) is $($expectedKeys[$position])"
            }
        }
    }

    It 'places every directory beneath handbook/user when that root is given (US2)' {
        # Act
        $families = Get-DocsDefaultFamilySet -DocumentationRoot 'handbook/user'

        # Assert
        foreach ($family in $families) {
            $family['directory'] | Should -BeExactly "handbook/user/$($family['id'])"
        }
    }

    It 'throws for an empty documentation root' {
        { Get-DocsDefaultFamilySet -DocumentationRoot '' } | Should -Throw
    }

    It 'returns a new set on every call so a caller change does not leak' {
        # Arrange
        $first = Get-DocsDefaultFamilySet -DocumentationRoot 'docs/guide'
        $first[0]['id'] = 'changed'

        # Act
        $second = Get-DocsDefaultFamilySet -DocumentationRoot 'docs/guide'

        # Assert
        $second[0]['id'] | Should -BeExactly 'product-overview'
    }
}

Describe 'Test-DocsProfileFamilySemantic' {
    It 'returns no finding for a profile without required_families or legacy_exclusions' {
        # Arrange
        $value = New-FamilyTestProfile
        $value.Remove('required_families')

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value -ArtifactPath 'docs/documentation-estate/docs-profile.json'

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'returns no finding for the default documentation families with every audience declared' {
        # Arrange
        $value = New-FamilyTestProfile -Family (Get-DocsDefaultFamilySet -DocumentationRoot 'docs/guide') -Legacy @()
        $value['audiences'] = @(foreach ($id in 'maintainers', 'end-users', 'operators', 'security-reviewers', 'product-owners') { [ordered]@{ id = $id; description = 'Audience.' } })

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports F1 DOCS_PROFILE_FAMILY_DUPLICATE at /required_families/1/id for a repeated id (AC9)' {
        # Arrange
        $value = New-FamilyTestProfile -Family @((New-FamilyTestRecord), (New-FamilyTestRecord -Directory 'docs/guide/security-two'))

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        Get-FamilyFindingKey -Finding $findings | Should -BeExactly @('DOCS_PROFILE_FAMILY_DUPLICATE /required_families/1/id')
    }

    It 'does not report ids that differ only in case as duplicates (AC9)' {
        # Arrange (the schema rejects an uppercase id; the semantic rule still compares ordinally)
        $value = New-FamilyTestProfile -Family @((New-FamilyTestRecord), (New-FamilyTestRecord -Id 'Security' -Directory 'docs/guide/Security'))

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports F2 DOCS_PROFILE_FAMILY_DUPLICATE at /required_families/1/directory for a repeated directory (AC9)' {
        # Arrange
        $value = New-FamilyTestProfile -Family @((New-FamilyTestRecord), (New-FamilyTestRecord -Id 'security-two'))

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        Get-FamilyFindingKey -Finding $findings | Should -BeExactly @('DOCS_PROFILE_FAMILY_DUPLICATE /required_families/1/directory')
    }

    It 'reports F3 DOCS_PROFILE_AUDIENCE_UNKNOWN at /required_families/0/audience/1 for an undeclared audience (AC10)' {
        # Arrange
        $value = New-FamilyTestProfile -Family @(New-FamilyTestRecord -Audience @('maintainers', 'security-reviewers'))

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        Get-FamilyFindingKey -Finding $findings | Should -BeExactly @('DOCS_PROFILE_AUDIENCE_UNKNOWN /required_families/0/audience/1')
    }

    It 'reports F4 DOCS_PROFILE_MODE_NOT_IN_POLICY at /required_families/1/diataxis_mode for a mode outside diataxis_policy.modes (AC11)' {
        # Arrange
        $value = New-FamilyTestProfile -Family @((New-FamilyTestRecord), (New-FamilyTestRecord -Id 'tutorials' -Directory 'docs/guide/tutorials' -Mode 'tutorial'))

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        Get-FamilyFindingKey -Finding $findings | Should -BeExactly @('DOCS_PROFILE_MODE_NOT_IN_POLICY /required_families/1/diataxis_mode')
    }

    It 'accepts the family directory <Directory> under the root docs/guide (AC12)' -ForEach @(
        @{ Directory = 'docs/guide' }
        @{ Directory = 'docs/guide/security' }
    ) {
        # Arrange
        $value = New-FamilyTestProfile -Family @(New-FamilyTestRecord -Directory $Directory)

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports F5 DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT at /required_families/0/directory for <Directory> (AC12)' -ForEach @(
        @{ Directory = 'docs/guidebook/security' }
        @{ Directory = 'docs/security' }
        @{ Directory = 'Docs/guide/security' }
    ) {
        # Arrange
        $value = New-FamilyTestProfile -Family @(New-FamilyTestRecord -Directory $Directory)

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        Get-FamilyFindingKey -Finding $findings | Should -BeExactly @('DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT /required_families/0/directory')
    }

    It 'accepts a family directory nested under another family directory (AC12)' {
        # Arrange
        $value = New-FamilyTestProfile -Family @((New-FamilyTestRecord -Id 'operations' -Directory 'docs/guide/operations'), (New-FamilyTestRecord -Id 'alerts' -Directory 'docs/guide/operations/alerts'))

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports L1 DOCS_PROFILE_LEGACY_DUPLICATE at /legacy_exclusions/1/path for a repeated legacy path (AC13)' {
        # Arrange
        $entry = [ordered]@{ path = 'docs/debugging.md'; reason = 'Migrating.' }
        $value = New-FamilyTestProfile -Legacy @($entry, [ordered]@{ path = 'docs/debugging.md'; reason = 'Listed twice.' })

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        Get-FamilyFindingKey -Finding $findings | Should -BeExactly @('DOCS_PROFILE_LEGACY_DUPLICATE /legacy_exclusions/1/path')
    }

    It 'returns no finding for a legacy path outside every documentation root (AC13)' {
        # Arrange
        $value = New-FamilyTestProfile -Legacy @([ordered]@{ path = 'notes/old-page.md'; reason = 'Migrating.' })

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'returns no finding for an exclusion on a required documentation family (D11)' {
        # Arrange
        $record = New-FamilyTestRecord
        $record['exclusion'] = [ordered]@{ reason = 'No managed service is offered.'; recorded_at = '2026-11-23T00:00:00Z' }
        $value = New-FamilyTestProfile -Family @($record)

        # Act
        $findings = Test-DocsProfileFamilySemantic -Profile $value

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'gives every <Code> finding severity error, a message naming <Field>, a next action, and the artifact path (AC14)' -ForEach @(
        @{ Code = 'DOCS_PROFILE_FAMILY_DUPLICATE'; Field = 'id'; Family = { @((New-FamilyTestRecord), (New-FamilyTestRecord -Directory 'docs/guide/other')) }; Legacy = { $null } }
        @{ Code = 'DOCS_PROFILE_FAMILY_DUPLICATE'; Field = 'directory'; Family = { @((New-FamilyTestRecord), (New-FamilyTestRecord -Id 'other')) }; Legacy = { $null } }
        @{ Code = 'DOCS_PROFILE_AUDIENCE_UNKNOWN'; Field = 'audience'; Family = { @(New-FamilyTestRecord -Audience @('nobody')) }; Legacy = { $null } }
        @{ Code = 'DOCS_PROFILE_MODE_NOT_IN_POLICY'; Field = 'diataxis_mode'; Family = { @(New-FamilyTestRecord -Mode 'tutorial') }; Legacy = { $null } }
        @{ Code = 'DOCS_PROFILE_FAMILY_DIRECTORY_OUTSIDE_ROOT'; Field = 'directory'; Family = { @(New-FamilyTestRecord -Directory 'docs/security') }; Legacy = { $null } }
        @{ Code = 'DOCS_PROFILE_LEGACY_DUPLICATE'; Field = 'path'; Family = { @() }; Legacy = { @([ordered]@{ path = 'a.md'; reason = 'r' }, [ordered]@{ path = 'a.md'; reason = 'r' }) } }
    ) {
        # Arrange
        $value = New-FamilyTestProfile -Family (& $Family) -Legacy (& $Legacy)

        # Act
        $findings = @(Test-DocsProfileFamilySemantic -Profile $value -ArtifactPath 'docs/documentation-estate/docs-profile.json')

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly $Code
        $findings[0].severity | Should -BeExactly 'error'
        $findings[0].message.Contains("Field $Field ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the message names the field $Field"
        [string]::IsNullOrWhiteSpace($findings[0].next_action) | Should -BeFalse
        $findings[0].artifact_path | Should -BeExactly 'docs/documentation-estate/docs-profile.json'
    }
}
