#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Profile schema tests for the review cadence members of issue #1220.

.DESCRIPTION
    Loads in-memory profiles through ConvertFrom-DocsProfileText: review_due is accepted in
    diataxis_policy.required_front_matter, and completion_gates.docs_complete.block_overdue_review
    is an optional boolean. No file is read or written apart from the committed schemas.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfile.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    function Invoke-TestProfile {
        # Loads a profile document through ConvertFrom-DocsProfileText.
        param([System.Collections.IDictionary] $Document)
        ConvertFrom-DocsProfileText -Text (ConvertTo-DocsJsonText -Value $Document) -ArtifactPath $script:ProfilePath -ComposedSchemaSet $script:Composed
    }
}

AfterAll {
    Remove-Item -LiteralPath 'function:Invoke-TestProfile' -ErrorAction SilentlyContinue
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'docs profile review cadence members' {
    It 'loads a profile that lists review_due in diataxis_policy.required_front_matter with no finding' {
        # Arrange
        $document = New-DocsStarterProfile
        $document['diataxis_policy']['required_front_matter'] = @('owner', 'last_reviewed', 'review_due', 'audience', 'diataxis_mode', 'surface_refs')

        # Act
        $result = Invoke-TestProfile -Document $document

        # Assert
        @($result.Findings).Count | Should -Be 0 -Because (@($result.Findings | ForEach-Object { "$($_['code']) $($_['pointer'])" }) -join '; ')
        $result.Profile | Should -Not -BeNullOrEmpty
    }

    It 'loads a profile whose block_overdue_review is <Case> with no finding' -ForEach @(
        @{ Case = 'absent'; Absent = $true; Value = $null }
        @{ Case = 'false'; Absent = $false; Value = $false }
        @{ Case = 'true'; Absent = $false; Value = $true }
    ) {
        # Arrange
        $document = New-DocsStarterProfile
        if (-not $Absent) { $document['completion_gates']['docs_complete']['block_overdue_review'] = $Value }

        # Act
        $result = Invoke-TestProfile -Document $document

        # Assert
        @($result.Findings).Count | Should -Be 0 -Because (@($result.Findings | ForEach-Object { "$($_['code']) $($_['pointer'])" }) -join '; ')
        $result.Profile | Should -Not -BeNullOrEmpty
    }

    It 'rejects a string block_overdue_review with a schema finding and a $null profile' {
        # Arrange
        $document = New-DocsStarterProfile
        $document['completion_gates']['docs_complete']['block_overdue_review'] = 'true'

        # Act
        $result = Invoke-TestProfile -Document $document

        # Assert
        $result.Profile | Should -BeNullOrEmpty
        @($result.Findings).Count | Should -BeGreaterThan 0
        @($result.Findings | Where-Object { ([string] $_['pointer']).StartsWith('/completion_gates/docs_complete', [System.StringComparison]::Ordinal) }).Count | Should -BeGreaterThan 0
    }
}
