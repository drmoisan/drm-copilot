#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Page-checker acceptance of every docs-author-page template (issue #1222).

.DESCRIPTION
    Each committed template is read as text, its placeholder tokens are replaced in memory, and the
    rendered page runs through Get-DocsPageCheckFinding in a page set with a linking entry page.
    The template directory is enumerated at discovery, so a later template is covered without an
    edit. Two negative cases show that the test can fail. No file is written.
#>

BeforeDiscovery {
    $templateRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/docs-author-page/templates'
    $script:TemplateRow = @(Get-ChildItem -LiteralPath $templateRoot -Filter '*.md' -File | Sort-Object -Property Name | ForEach-Object {
            $text = [System.IO.File]::ReadAllText($_.FullName)
            $mode = [regex]::Match($text, '(?m)^diataxis_mode: "(?<mode>[a-z-]+)"$').Groups['mode'].Value
            @{ Name = $_.Name; Mode = $mode }
        })
    $script:HowToRow = @($script:TemplateRow | Where-Object { $_.Mode -eq 'how-to' })
    $script:ExplanationRow = @($script:TemplateRow | Where-Object { $_.Mode -eq 'explanation' })
}

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    $script:TemplateRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/skills/docs-author-page/templates'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageCheck.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instances that DocsPageCheck imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsSchema.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsJson.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:Substitution = [ordered]@{
        '<owner-id>'              = 'team-docs'
        '<review-due-yyyy-mm-dd>' = '2027-05-14'
        '<yyyy-mm-dd>'            = '2026-11-14'
        '<audience-id>'           = 'developers'
        '<element-id>'            = 'cli-command-' + ('0123456789abcdef' * 4)
    }

    function Get-RenderedTemplate {
        # Returns the committed template text with the placeholder tokens replaced in memory.
        param([Parameter(Mandatory)] [string] $Name)
        $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:TemplateRoot -ChildPath $Name))
        foreach ($placeholder in $script:Substitution.Keys) { $text = $text.Replace($placeholder, $script:Substitution[$placeholder]) }
        return $text
    }

    function Get-TemplateFinding {
        # Runs the page checker over one page placed under docs/guide/ and linked from docs/README.md.
        param([Parameter(Mandatory)] [string] $PageText)
        $value = (ConvertFrom-DocsJsonText -Text ([System.IO.File]::ReadAllText((Join-Path -Path $script:RepositoryRoot -ChildPath 'examples/docs/v1/docs-profile.example.json')))).Value
        $value['audiences'] = @([ordered]@{ id = 'developers'; description = 'People who change the code.' })
        $value['documentation_roots'] = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = @('developers') })
        $value['diataxis_policy']['modes'] = @('tutorial', 'how-to', 'reference', 'explanation')
        $value['diataxis_policy']['directory_modes'] = @([ordered]@{ path_or_glob = 'docs/reference'; mode = 'reference' })
        $entry = "---`nowner: `"team-docs`"`nlast_reviewed: `"2026-11-14`"`naudience: [`"developers`"]`ndiataxis_mode: `"explanation`"`nsurface_refs: []`n---`n# Documentation`n- [Page](guide/page.md)`n"
        $pages = [ordered]@{ 'docs/README.md' = $entry; 'docs/guide/page.md' = $PageText }
        $outcome = Get-DocsPageCheckFinding -PageText $pages -Profile $value -ProfilePath $script:ProfilePath -ComposedSchemaSet $script:Composed -ExistingPath @() -SelectedPath $null
        return @($outcome.Findings)
    }
}

AfterAll {
    foreach ($name in 'Get-RenderedTemplate', 'Get-TemplateFinding') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
    Remove-Module -Name DocsPageCheck, DocsPageOrphans, DocsPageDiataxis, DocsPageLinks, DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'docs-author-page templates and the page checker' {
    It 'enumerates the template directory at discovery' -TestCases @(@{ RowCount = $script:TemplateRow.Count }) {
        # Assert: eight pre-existing templates and eight family templates.
        $RowCount | Should -BeGreaterOrEqual 16
    }

    It 'accepts the rendered <Name> template with zero error findings' -ForEach $script:TemplateRow {
        # Arrange
        $page = Get-RenderedTemplate -Name $Name

        # Act
        $errors = @(Get-TemplateFinding -PageText $page | Where-Object { $_.severity -eq 'error' })

        # Assert
        $errors.Count | Should -Be 0 -Because (($errors | ForEach-Object { "$($_.code) $($_.artifact_path)$($_.pointer)" }) -join '; ')
    }

    It 'reports DOCS_PAGE_MODE_STEPS_MISSING for the how-to template <Name> without its ordered-list lines (negative case 1)' -ForEach $script:HowToRow {
        # Arrange
        $page = [regex]::Replace((Get-RenderedTemplate -Name $Name), '(?m)^ {0,3}[0-9]{1,9}[.)] +\S.*\n', '')

        # Act
        $codes = @(Get-TemplateFinding -PageText $page | ForEach-Object { $_.code })

        # Assert
        $codes | Should -Contain 'DOCS_PAGE_MODE_STEPS_MISSING'
    }

    It 'reports DOCS_PAGE_MODE_INSTRUCTION_HEADING for the explanation template <Name> with an added How to heading (negative case 2)' -ForEach $script:ExplanationRow {
        # Arrange
        $page = (Get-RenderedTemplate -Name $Name) + "`n## How to change the setting`n`nText.`n"

        # Act
        $codes = @(Get-TemplateFinding -PageText $page | ForEach-Object { $_.code })

        # Assert
        $codes | Should -Contain 'DOCS_PAGE_MODE_INSTRUCTION_HEADING'
    }
}
