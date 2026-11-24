#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Front matter and body rules of the docs-author-page templates in all four skill locations (issues #1037, #1220).

.DESCRIPTION
    Each template's front matter is parsed line by line with every value parsed as JSON. The template
    set is the union of the Templates and FamilyTemplateModes members of Get-DocsAuthoringNamedSet
    (issue #1220), so the family templates of issue #1222 carry the same front-matter rules. No test
    writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $set = Get-DocsAuthoringNamedSet
    $roots = Get-DocsAuthoringSkillRoot
    $modeOf = [ordered]@{}
    foreach ($template in $set.Templates) { $modeOf[$template] = $set.TemplateModes[$template] }
    foreach ($template in $set.FamilyTemplateModes.Keys) { $modeOf[$template] = $set.FamilyTemplateModes[$template] }
    $script:TemplateRows = @(foreach ($key in $roots.Keys) {
            foreach ($template in $modeOf.Keys) { @{ Template = $template; Mode = $modeOf[$template]; Path = "$($roots[$key])/docs-author-page/templates/$template.md" } }
        })
    # Issue #1220: the body rules stay on the eight Templates members; the family body rules are pinned in
    # docs-authoring-roles.FamilyTemplates.Tests.ps1 (alerts-catalog is a reference template without a generated marker).
    $script:BodyRuleRows = @($script:TemplateRows | Where-Object { $set.Templates -contains $_.Template })
    $script:SkillRows = @(foreach ($key in $roots.Keys) { @{ Path = "$($roots[$key])/docs-author-page/SKILL.md" } })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    # Issue #1173 (B4): the page front-matter checker runs over each substituted template.
    $script:DocsLibrary = Join-Path -Path $PSScriptRoot -ChildPath '../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:DocsLibrary -ChildPath 'DocsPageFrontMatter.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the DocsSchema instance that DocsPageFrontMatter imported.
    Import-Module -Name (Join-Path -Path $script:DocsLibrary -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../claude-lib/docs/Docs.TestSupport.psm1') -Force -ErrorAction Stop
    $script:ComposedSchema = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:Substitution = [ordered]@{
        '<owner-id>'              = 'team-docs'
        '<review-due-yyyy-mm-dd>' = '2027-05-14'
        '<yyyy-mm-dd>'            = '2026-11-14'
        '<audience-id>'           = 'developers'
        '<element-id>'            = 'cli-command-' + ('0123456789abcdef' * 4)
    }
    $set = Get-DocsAuthoringNamedSet
    $script:TemplateName = @(@($set.Templates) + @($set.FamilyTemplateModes.Keys))

    function Get-TemplatePart {
        # Splits a template into its front-matter lines and its body.
        param([string] $Text)
        $lines = @(($Text -replace "`r`n", "`n") -split "`n")
        $end = [array]::IndexOf($lines, '---', 1)
        return @{ FrontMatter = @($lines[1..($end - 1)]); Body = (@($lines[($end + 1)..($lines.Count - 1)]) -join "`n"); StartsWithFence = $lines[0] -eq '---' }
    }
}

AfterAll {
    foreach ($name in 'Get-TemplatePart', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
    Remove-Module -Name DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'docs-author-page templates' {
    It 'covers every template file at the four skill roots' -TestCases @(@{ RowCount = $script:TemplateRows.Count }) {
        # Arrange: the expected count is the four skill roots times the .md files of the template folder.
        $roots = Get-DocsAuthoringSkillRoot
        $folder = Join-Path (Get-DocsAuthoringRepoRoot) '.agents/skills/docs-author-page/templates'
        [string[]] $listed = @(Get-ChildItem -LiteralPath $folder -Filter '*.md' -File | ForEach-Object { $_.BaseName } | Sort-Object)

        # Assert
        $RowCount | Should -Be ($roots.Count * $listed.Count)
        @($script:TemplateName | Sort-Object) | Should -Be $listed -Because 'the Templates and FamilyTemplateModes union equals the template folder listing'
    }

    It 'gives <Path> the six front-matter fields with JSON values, review_due after last_reviewed and diataxis_mode <Mode>' -ForEach $script:TemplateRows {
        # Arrange
        $part = Get-TemplatePart -Text (Read-DocsAuthoringText -RelativePath $Path)

        # Act
        $fields = @{}
        $keys = [System.Collections.Generic.List[string]]::new()
        foreach ($line in $part.FrontMatter) {
            $match = [regex]::Match($line, '^(?<key>[a-z_]+): (?<value>.+)$')
            $match.Success | Should -BeTrue -Because "front-matter line '$line'"
            $keys.Add($match.Groups['key'].Value)
            $fields[$match.Groups['key'].Value] = ConvertFrom-Json -InputObject $match.Groups['value'].Value -NoEnumerate
        }

        # Assert
        $part.StartsWithFence | Should -BeTrue
        @($fields.Keys | Sort-Object) | Should -Be @('audience', 'diataxis_mode', 'last_reviewed', 'owner', 'review_due', 'surface_refs')
        $keys[$keys.IndexOf('last_reviewed') + 1] | Should -BeExactly 'review_due' -Because 'review_due is on the line directly after last_reviewed'
        $fields['diataxis_mode'] | Should -BeExactly $Mode
    }

    It 'passes the page front-matter checker with no DOCS_PAGE_AUDIENCE_INVALID and no DOCS_PAGE_REVIEW_DUE_ code after placeholder substitution in <Path> (issues #1173, #1220)' -ForEach $script:TemplateRows {
        # Arrange: substitute the front-matter placeholders in memory.
        $text = Read-DocsAuthoringText -RelativePath $Path
        foreach ($placeholder in $script:Substitution.Keys) { $text = $text.Replace($placeholder, $script:Substitution[$placeholder]) }
        $parsed = ConvertFrom-DocsPageFrontMatter -Text $text -PagePath 'docs/guide/page.md'

        # Act
        $findings = @(Test-DocsPageFrontMatter -FrontMatter $parsed.Value -PagePath 'docs/guide/page.md' -ComposedSchemaSet $script:ComposedSchema -RequiredField @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs') -AudienceId @('developers') -FieldLine $parsed.FieldLine)
        $codes = @($findings | ForEach-Object { $_.code })

        # Assert
        $parsed.Findings.Count | Should -Be 0 -Because "the substituted front matter of $Path parses"
        $codes | Should -Not -Contain 'DOCS_PAGE_AUDIENCE_INVALID' -Because ($codes -join ', ')
        @($codes | Where-Object { $_ -like 'DOCS_PAGE_REVIEW_DUE_*' }).Count | Should -Be 0 -Because ($codes -join ', ')
    }

    It 'gives <Path> the body rules of the <Mode> mode' -ForEach $script:BodyRuleRows {
        # Arrange
        $body = (Get-TemplatePart -Text (Read-DocsAuthoringText -RelativePath $Path)).Body

        # Act
        $hasStep = [regex]::IsMatch($body, '(?m)^ {0,3}[0-9]{1,9}[.)] +\S')
        $instructionalHeading = [regex]::IsMatch($body, '(?im)^#{1,6}[ \t]+(?:how to |step\s+[0-9]+\b)')
        $starts = [regex]::Matches($body, '(?m)^<!-- docs:generated:start id=\S+ -->[ \t]*$').Count
        $ends = [regex]::Matches($body, '(?m)^<!-- docs:generated:end id=\S+ -->[ \t]*$').Count

        # Assert
        if ($Mode -in 'tutorial', 'how-to') { $hasStep | Should -BeTrue } else { $instructionalHeading | Should -BeFalse }
        if ($Mode -eq 'reference') { $starts | Should -Be 1; $ends | Should -Be 1 } else { $starts + $ends | Should -Be 0 }
    }

    It 'names review_due and review_interval_days in step 1 of <Path> (issue #1220)' -ForEach $script:SkillRows {
        # Arrange
        $text = (Read-DocsAuthoringText -RelativePath $Path) -replace "`r`n", "`n"

        # Act
        $step = [regex]::Match($text, '(?ms)^## Steps\n\n(?<step>1\. .*?)(?=^2\. )').Groups['step'].Value

        # Assert
        $step | Should -Not -BeNullOrEmpty -Because 'step 1 of ## Steps is present'
        $step | Should -Match 'review_due'
        $step | Should -Match 'review_interval_days'
    }
}
