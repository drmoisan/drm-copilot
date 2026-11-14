#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Link-map tests for .claude/lib/docs/DocsPageCheck.psm1.

.DESCRIPTION
    Invoke-DocsCheckCommand builds the private link map once per check run and hands it to
    Get-DocsPageCheckFinding, which still builds the map itself when no map is passed. Pages and
    the profile are in-memory texts served by the command context of Docs.TestSupport.psm1; the
    profile starts from the committed example profile and the schemas are the committed runtime
    schemas. These tests are kept apart from DocsPageCheck.Tests.ps1 to hold that file below the
    700-line advisory tier. No file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageCheck.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instances that DocsPageCheck imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    function New-TestLinkMapProfile {
        # Returns a parsed profile with one documentation root 'docs' and one declared audience.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param()
        $value = (ConvertFrom-DocsJsonText -Text (Get-DocsTestExampleText)['docs-profile']).Value
        $value['audiences'] = @([ordered]@{ id = 'developers'; description = 'People who change the code.' })
        $value['documentation_roots'] = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') })
        return $value
    }

    function New-TestLinkMapPage {
        # Returns page text with a complete explanation-mode front-matter block and the given body lines.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $Body)
        $lines = @('---', 'owner: "team-docs"', 'last_reviewed: "2026-10-30"', 'audience: ["developers"]', 'diataxis_mode: "explanation"', 'surface_refs: []', '---') + $Body
        return ($lines -join "`n") + "`n"
    }

    function New-TestLinkMapPageSet {
        # The two-page linked set: an entry page linking a guide that links back; GuideLine replaces the guide body.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param([string[]] $GuideLine = @('# Guide', 'Back to [the index](README.md).'))
        return [ordered]@{
            'docs/README.md' = New-TestLinkMapPage -Body @('# Documentation', '- [Guide](guide.md)')
            'docs/guide.md'  = New-TestLinkMapPage -Body $GuideLine
        }
    }

    function Get-TestRealLinkMap {
        # Builds the real link map inside the module scope, before any mock of the helper is registered.
        param([System.Collections.IDictionary] $PageText)
        InModuleScope -ModuleName DocsPageCheck -Parameters @{ PageText = $PageText } -ScriptBlock {
            param([System.Collections.IDictionary] $PageText)
            Get-DocsPageLinkMap -PageText $PageText
        }
    }
}

AfterAll {
    Remove-Module -Name DocsPageCheck, DocsPageOrphans, DocsPageDiataxis, DocsPageLinks, DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-DocsCheckCommand link map' {
    It 'builds the link map once per check run' {
        # Arrange
        $pageSet = New-TestLinkMapPageSet
        $decoded = [ordered]@{}
        foreach ($page in $pageSet.Keys) { $decoded[$page] = ConvertFrom-DocsPageBytes -Bytes ([System.Text.UTF8Encoding]::new($false).GetBytes($pageSet[$page])) -PagePath $page }
        $realMap = Get-TestRealLinkMap -PageText $decoded
        Mock -CommandName Get-DocsPageLinkMap -ModuleName DocsPageCheck -MockWith { $realMap }
        $files = @{ $script:ProfilePath = ConvertTo-DocsJsonText -Value (New-TestLinkMapProfile) -Indented }
        foreach ($page in $pageSet.Keys) { $files[$page] = $pageSet[$page] }
        $test = New-DocsTestContext -File $files

        # Act
        $result = Invoke-DocsCheckCommand -Argument ([ordered]@{}) -Context $test.Context

        # Assert
        Should -Invoke Get-DocsPageLinkMap -ModuleName DocsPageCheck -Times 1 -Exactly
        $result.ExitCode | Should -Be 0
        @($result.Findings).Count | Should -Be 0
        $result.Result.page_count | Should -Be 2
    }

    It 'returns the same findings with and without a precomputed map' {
        # Arrange
        $pageSet = New-TestLinkMapPageSet -GuideLine @('# Guide', 'Back to [the index](README.md).', '[x](missing.md)')
        $arguments = @{ PageText = $pageSet; Profile = (New-TestLinkMapProfile); ProfilePath = $script:ProfilePath; ComposedSchemaSet = $script:Composed; ExistingPath = [string[]] @() }
        $map = Get-TestRealLinkMap -PageText $pageSet

        # Act
        $without = Get-DocsPageCheckFinding @arguments
        $with = Get-DocsPageCheckFinding @arguments -LinkMap $map

        # Assert
        $expected = @($without.Findings | ForEach-Object { "$($_.code) $($_.artifact_path)" })
        $expected | Should -Contain 'DOCS_PAGE_LINK_BROKEN docs/guide.md'
        @($with.Findings | ForEach-Object { "$($_.code) $($_.artifact_path)" }) | Should -Be $expected
    }
}
