#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Family templates of docs-author-page: files, modes, sections, parity, manifests and skill table (issue #1222).

.DESCRIPTION
    The eight family templates and the extended architecture-overview template are read from the four
    skill roots. Front matter is parsed with ConvertFrom-DocsPageFrontMatter. Every assertion reads
    committed files or in-memory text; no test writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $set = Get-DocsAuthoringNamedSet
    $roots = Get-DocsAuthoringSkillRoot
    $family = $set.FamilyTemplateModes
    $script:ExpectedSection = [ordered]@{
        'product-overview'      = @('Problem and Purpose', 'Supported Use Cases', 'Audience and Roles', 'Deployment Options and Interfaces', 'Support Boundaries and Non-Goals', 'Known Limitations', 'Where to Go Next')
        'onboarding'            = @('Before You Begin', 'Steps', 'Expected Result', 'Verify', 'If Something Does Not Work', 'Related Reference')
        'runbook'               = @('Purpose', 'Trigger', 'Severity and Ownership', 'Preconditions', 'Diagnostics', 'Decision Points', 'Remediation', 'Validation', 'Evidence and Follow-up')
        'playbook'              = @('Purpose', 'Scenario Scope', 'Roles and Responsibilities', 'Activation Criteria', 'Communication Channels and Cadence', 'Coordination Steps', 'Runbooks Coordinated', 'Handoff', 'Closure and Postmortem Handoff', 'Related')
        'adr'                   = @('Status', 'Date', 'Context', 'Decision', 'Alternatives Considered', 'Consequences', 'Approvers')
        'security'              = @('Scope and Data Classification', 'Authentication and Authorization Model', 'Secrets Handling', 'Privileged Operations', 'Audit and Logging', 'Vulnerability Reporting', 'Control Mapping', 'Exceptions and Assumptions')
        'service-management'    = @('SLI, SLO and SLA', 'Change and Release Management', 'Incident Management')
        'alerts-catalog'        = @('Purpose', 'Catalog', 'Severity Scale', 'Related')
        'architecture-overview' = @('Components', 'Interactions', 'Data Flow', 'Trust Boundaries', 'Failure Domains', 'Boundaries and Constraints')
    }
    $script:ServiceSubsection = [ordered]@{
        'SLI, SLO and SLA'              = @('Service and User Journey', 'SLI Specifications', 'Measurement Sources', 'SLO Targets', 'Error-Budget Policy', 'SLA', 'Review Cadence')
        'Change and Release Management' = @('Change Classes', 'Review per Class', 'Release Procedure', 'Rollback per Class', 'Change Record', 'Freeze and Exceptions')
        'Incident Management'           = @('Severity Definitions', 'Incident Lifecycle', 'Roles', 'Communication Expectations', 'Postmortem Practice')
    }
    $modeOf = [ordered]@{ 'architecture-overview' = 'explanation' }
    foreach ($key in $family.Keys) { $modeOf[$key] = $family[$key] }
    $script:AllId = @($modeOf.Keys)
    $script:IdRow = @(foreach ($id in $modeOf.Keys) { @{ Id = $id; Mode = $modeOf[$id]; Expected = $script:ExpectedSection[$id] } })
    $script:FamilyRow = @($script:IdRow | Where-Object { $_.Id -ne 'architecture-overview' })
    $script:HowToRow = @($script:FamilyRow | Where-Object { $_.Mode -eq 'how-to' })
    $script:NonStepRow = @($script:IdRow | Where-Object { $_.Mode -in 'explanation', 'reference' })
    $script:RootRow = @(foreach ($row in $script:IdRow) { foreach ($key in $roots.Keys) { @{ Id = $row.Id; Root = $key; Path = "$($roots[$key])/docs-author-page/templates/$($row.Id).md" } } })
    $script:ManifestRow = @(foreach ($row in $script:FamilyRow) {
            foreach ($manifest in @(
                    @{ Manifest = 'claude-customizations/pack-manifests/core.json'; Prefix = '.claude/skills' },
                    @{ Manifest = 'codex-and-agents-customizations/pack-manifests/core.json'; Prefix = '.agents/skills' },
                    @{ Manifest = 'codex-and-agents-customizations/pack-manifests/shared.json'; Prefix = '.agents/skills' })) {
                @{ Id = $row.Id; Manifest = $manifest.Manifest; Entry = "$($manifest.Prefix)/docs-author-page/templates/$($row.Id).md" }
            }
        })
    $skillMode = [ordered]@{}
    foreach ($key in $set.TemplateModes.Keys) { $skillMode[$key] = $set.TemplateModes[$key] }
    foreach ($key in $modeOf.Keys) { $skillMode[$key] = $modeOf[$key] }
    $script:SkillRow = @(foreach ($key in $roots.Keys) { foreach ($id in $skillMode.Keys) { @{ Id = $id; Mode = $skillMode[$id]; Root = $key; Path = "$($roots[$key])/docs-author-page/SKILL.md" } } })
    $script:RelatedRow = @($script:IdRow)
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $script:DocsLibrary = Join-Path -Path $PSScriptRoot -ChildPath '../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:DocsLibrary -ChildPath 'DocsPageFrontMatter.psm1') -Force -ErrorAction Stop
    $script:TemplateDirectory = '.claude/skills/docs-author-page/templates'
    $script:BannedToken = @('drm-copilot', 'ALR-', 'Sev1', 'Sev2', 'Sev3', 'src/', 'tests/', 'docs/architecture/adr', 'review_due', 'SME input required', 'diataxis:')

    function Get-TemplateText {
        # Returns the text of one template from the Claude skill root.
        param([Parameter(Mandatory)] [string] $Id)
        return Read-DocsAuthoringText -RelativePath "$script:TemplateDirectory/$Id.md"
    }

    function Get-SectionTitle {
        # Returns the titles of the headings of one level, in order.
        param([Parameter(Mandatory)] [string] $Text, [int] $Level = 2)
        $pattern = '(?m)^#{' + $Level + '}[ \t]+(?<title>.+?)[ \t]*$'
        return @([regex]::Matches($Text, $pattern) | ForEach-Object { $_.Groups['title'].Value })
    }

    function Get-FileHashText {
        # Returns the SHA-256 of one repository-relative file as hexadecimal text.
        param([Parameter(Mandatory)] [string] $RelativePath)
        $bytes = [System.IO.File]::ReadAllBytes((Join-Path (Get-DocsAuthoringRepoRoot) $RelativePath))
        return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes))
    }
}

AfterAll {
    foreach ($name in 'Get-TemplateText', 'Get-SectionTitle', 'Get-FileHashText', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
    Remove-Module -Name DocsPageFrontMatter, DocsPageMetadata, DocsPageMarkdown, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'docs-author-page family templates' {
    It 'has the template file <Id> at <Root>' -ForEach $script:RootRow {
        # Assert
        Test-Path -LiteralPath (Join-Path (Get-DocsAuthoringRepoRoot) $Path) -PathType Leaf | Should -BeTrue
    }

    It 'keeps <Id> byte-identical at all four roots' -ForEach $script:IdRow {
        # Arrange
        $roots = Get-DocsAuthoringSkillRoot
        $hash = @(foreach ($key in $roots.Keys) { Get-FileHashText -RelativePath "$($roots[$key])/docs-author-page/templates/$Id.md" })

        # Assert
        @($hash | Select-Object -Unique).Count | Should -Be 1 -Because "the four copies of $Id must hash equal: $($hash -join ', ')"
    }

    It 'lists <Entry> exactly once in <Manifest>' -ForEach $script:ManifestRow {
        # Arrange
        $paths = @(Get-DocsPackManifestPath -RelativeManifest $Manifest)

        # Assert
        @($paths | Where-Object { $_ -ceq $Entry }).Count | Should -Be 1
    }

    It 'uses line feed endings only in <Path>' -ForEach $script:RootRow {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath $Path

        # Assert
        $text.Contains("`r") | Should -BeFalse
    }

    It 'gives <Id> five JSON-valued front-matter keys, surface_refs [] and the mode <Mode>' -ForEach $script:FamilyRow {
        # Arrange
        $text = Get-TemplateText -Id $Id

        # Act
        $parsed = ConvertFrom-DocsPageFrontMatter -Text $text -PagePath 'docs/guide/page.md'

        # Assert
        $parsed.Findings.Count | Should -Be 0 -Because 'the front matter parses with the page checker parser'
        @($parsed.Value.Keys | Sort-Object) | Should -Be @('audience', 'diataxis_mode', 'last_reviewed', 'owner', 'surface_refs')
        $parsed.Value['diataxis_mode'] | Should -BeExactly $Mode
        @($parsed.Value['surface_refs']).Count | Should -Be 0
        $text | Should -Match '(?m)^surface_refs: \[\]$'
        $text | Should -Match '(?m)^owner: "<owner-id>"$'
        $text | Should -Match '(?m)^last_reviewed: "<yyyy-mm-dd>"$'
        $text | Should -Match '(?m)^audience: \["<audience-id>"\]$'
    }

    It 'gives <Id> the mode <Mode> and the H2 sections of the specification in order' -ForEach $script:IdRow {
        # Arrange
        $text = Get-TemplateText -Id $Id

        # Assert
        $text | Should -Match ('(?m)^diataxis_mode: "' + $Mode + '"$')
        Get-SectionTitle -Text $text -Level 2 | Should -Be $Expected
    }

    It 'gives the how-to template <Id> a literal ordered-list line' -ForEach $script:HowToRow {
        # Arrange
        $body = (Get-TemplateText -Id $Id) -replace '(?s)<!--.*?-->', ''

        # Assert
        $body | Should -Match '(?m)^ {0,3}[0-9]{1,9}[.)] +\S'
    }

    It 'gives <Id> no How to or Step heading' -ForEach $script:NonStepRow {
        # Arrange
        $text = Get-TemplateText -Id $Id

        # Assert
        $text | Should -Not -Match '(?im)^#{1,6}[ \t]+(?:how to |step\s+[0-9]+\b)'
    }

    It 'gives alerts-catalog no generated marker' {
        # Arrange
        $text = Get-TemplateText -Id 'alerts-catalog'

        # Assert
        $text | Should -Not -Match 'docs:generated:start'
        $text | Should -Not -Match 'docs:generated:end'
    }

    It 'gives adr a leading naming note, no Review Date section and no repository directory' {
        # Arrange
        $text = Get-TemplateText -Id 'adr'
        $beforeFirstSection = ($text -split '(?m)^## ', 2)[0]

        # Assert
        $beforeFirstSection | Should -Match 'NNNN-short-slug\.md'
        (Get-SectionTitle -Text $text -Level 2) | Should -Not -Match 'Review Date'
        (Get-SectionTitle -Text $text -Level 1) | Should -Not -Match 'Review Date'
        $text | Should -Not -Match 'docs/'
        $text | Should -Not -Match 'src/'
    }

    It 'gives service-management the H3 subsections of each part and a leading keep-and-delete note' {
        # Arrange
        $text = Get-TemplateText -Id 'service-management'
        $parts = @($text -split '(?m)^## ')

        # Assert
        $parts[0] | Should -Match 'Keep the part'
        $parts[0] | Should -Match 'delete the other'
        $partIndex = 1
        foreach ($title in $script:ServiceSubsection.Keys) {
            (Get-SectionTitle -Text ('## ' + $parts[$partIndex]) -Level 3) | Should -Be $script:ServiceSubsection[$title] -Because "the part '$title' holds its subsections in order"
            $partIndex++
        }
    }

    It 'keeps domain-specific tokens out of <Id>' -ForEach $script:IdRow {
        # Arrange
        $text = Get-TemplateText -Id $Id

        # Act
        $hit = @($script:BannedToken | Where-Object { $text.Contains($_) })

        # Assert
        $hit.Count | Should -Be 0 -Because "banned tokens found: $($hit -join ', ')"
    }

    It 'gives every Related section of <Id> plain bullets and no Markdown link' -ForEach $script:RelatedRow {
        # Arrange
        $text = Get-TemplateText -Id $Id
        $sections = @($text -split '(?m)^## ' | Select-Object -Skip 1 | Where-Object { $_ -match '^Related' })

        # Assert
        foreach ($section in $sections) {
            $section.Contains('](') | Should -BeFalse
            $section | Should -Match '(?m)^- \S'
        }
    }

    It 'gives onboarding, playbook and alerts-catalog a Related section' {
        # Assert
        foreach ($id in 'onboarding', 'playbook', 'alerts-catalog') {
            @(Get-SectionTitle -Text (Get-TemplateText -Id $id) -Level 2 | Where-Object { $_ -like 'Related*' }).Count | Should -Be 1 -Because "$id carries one Related section"
        }
    }

    It 'lists <Id> with the mode <Mode> in a table row of the skill at <Path> [expect-fail]' -ForEach $script:SkillRow {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath $Path
        $pattern = '(?m)^\| \[' + [regex]::Escape($Id) + '\.md\]\(templates/' + [regex]::Escape($Id) + '\.md\) \| `' + [regex]::Escape($Mode) + '` \| \S.* \|$'

        # Assert
        $text | Should -Match $pattern
    }
}
