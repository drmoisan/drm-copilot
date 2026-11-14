#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Section-scoped workflow text of the documentation skills, agents and brief in every copy (issue #1173).

.DESCRIPTION
    Each row reads one committed copy, extracts one `## ` section, collapses whitespace runs to one
    space and checks a token with an ordinal Contains. Codex agent text is read through
    Get-DocsCodexEmbeddedText. Rows cover the B1 root inventory step and snapshot sentence, the B1
    brief sentence, and the B12 page-name restriction. No test writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $roots = Get-DocsAuthoringSkillRoot
    $script:WorkflowRows = @(foreach ($key in $roots.Keys) { @{ Copy = $key; Path = "$($roots[$key])/documentation-workflow/SKILL.md" } })
    $script:InventoryRows = @(foreach ($key in $roots.Keys) { @{ Copy = $key; Path = "$($roots[$key])/docs-inventory-surface/SKILL.md" } })
    $script:BriefRows = @(foreach ($key in $roots.Keys) { @{ Copy = $key; Path = "$($roots[$key])/execution-environment/SKILL.md" } })
    $pageWords = '`report`, `summary`, `findings` or `analysis`'
    $script:PageNameRows = @(
        foreach ($key in $roots.Keys) {
            @{ Copy = $key; Path = "$($roots[$key])/docs-plan-ia/SKILL.md"; Heading = 'Steps'; Codex = $false; Tokens = @($pageWords, 'root step', 'may be refused by the runtime') }
        }
        foreach ($key in $roots.Keys) {
            @{ Copy = $key; Path = "$($roots[$key])/docs-author-page/SKILL.md"; Heading = 'Steps'; Codex = $false; Tokens = @($pageWords, 'may be refused by the runtime', 'the root writes it') }
        }
        $agents = Get-DocsAuthoringAgentPath -Role 'docs-author'
        foreach ($key in $agents.Keys) {
            @{ Copy = $key; Path = $agents[$key]; Heading = 'Write Scope'; Codex = ($key -like 'Codex*'); Tokens = @($pageWords, 'may be refused by the runtime', 'the root writes it') }
        }
    )
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')

    function Get-DocsWorkflowSectionText {
        # Returns the whitespace-normalized body of one '## <Heading>' section, or $null when the section is absent.
        param([Parameter(Mandatory)] [string] $Text, [Parameter(Mandatory)] [string] $Heading)
        $match = [regex]::Match($Text, '(?ms)^## ' + [regex]::Escape($Heading) + '[ \t]*\r?\n(?<body>.*?)(?=^## |\z)')
        if (-not $match.Success) { return $null }
        return ($match.Groups['body'].Value -replace '\s+', ' ')
    }
}

AfterAll {
    foreach ($name in 'Get-DocsWorkflowSectionText', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'documentation workflow root inventory step (B1)' {
    It 'places the inventory -Write root step before the docs-inventory-surface link in <Path>' -ForEach $script:WorkflowRows {
        # Arrange
        $section = Get-DocsWorkflowSectionText -Text (Read-DocsAuthoringText -RelativePath $Path) -Heading 'Dispatch Order'

        # Act
        $step = if ($null -eq $section) { -1 } else { $section.IndexOf('inventory -Write', [System.StringComparison]::Ordinal) }
        $link = if ($null -eq $section) { -1 } else { $section.IndexOf('[docs-inventory-surface](../docs-inventory-surface/SKILL.md)', [System.StringComparison]::Ordinal) }

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Path has a ## Dispatch Order section"
        $step | Should -BeGreaterOrEqual 0 -Because "$Path names the root inventory -Write step"
        $link | Should -BeGreaterThan $step -Because "$Path places the root step before the docs-inventory-surface link"
    }

    It 'states that the root persists the snapshot in the Steps of <Path>' -ForEach $script:InventoryRows {
        # Arrange
        $section = Get-DocsWorkflowSectionText -Text (Read-DocsAuthoringText -RelativePath $Path) -Heading 'Steps'

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Path has a ## Steps section"
        $section.Contains('the root persists the snapshot', [System.StringComparison]::Ordinal) | Should -BeTrue -Because "$Path states that the root persists the snapshot"
    }
}

Describe 'execution-environment brief docs-snapshot sentence (B1)' {
    It 'states the docs-snapshot relative-form check in the Hook Execution Context of <Path>' -ForEach $script:BriefRows {
        # Arrange
        $section = Get-DocsWorkflowSectionText -Text (Read-DocsAuthoringText -RelativePath $Path) -Heading 'Hook Execution Context'

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Path has a ## Hook Execution Context section"
        $section.Contains('value for relative form only', [System.StringComparison]::Ordinal) | Should -BeTrue -Because "$Path states the docs-snapshot relative-form check"
    }
}

Describe 'runtime page-name restriction (B12)' {
    It 'states the page-name restriction in the <Heading> section of <Path>' -ForEach $script:PageNameRows {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath $Path
        if ($Codex) { $text = Get-DocsCodexEmbeddedText -Text $text }
        $section = Get-DocsWorkflowSectionText -Text $text -Heading $Heading

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Path has a ## $Heading section"
        foreach ($token in $Tokens) { $section.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "$Path states '$token'" }
    }
}
