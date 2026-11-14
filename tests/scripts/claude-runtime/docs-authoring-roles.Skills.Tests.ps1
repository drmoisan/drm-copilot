#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tool and subcommand references of the eight documentation skills in all six copies (issue #1037).

.DESCRIPTION
    Membership checks: every docs MCP tool a skill names is one of the six docs tools and is defined in
    extensions/drm-copilot/src/repo-automation-tool-names.ts, and every -Command <name> with its
    options is a row of the committed Invoke-DocsCommand.ps1 dispatch table. No test writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $set = Get-DocsAuthoringNamedSet
    $roots = Get-DocsAuthoringSkillRoot
    $script:SkillCopyRows = @(foreach ($key in $roots.Keys) { foreach ($skill in $set.Skills) { @{ Copy = $key; Path = "$($roots[$key])/$skill/SKILL.md" } } })
    $script:HostCopyRows = @($script:SkillCopyRows | Where-Object { $_.Copy -notlike 'Claude*' })
    $script:DocsInitCopyRows = @($script:SkillCopyRows | Where-Object { $_.Path -like '*/docs-init/SKILL.md' })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $script:Set = Get-DocsAuthoringNamedSet
    $script:Defined = Get-DocsMcpToolNameDefinition
    $script:Rows = Get-DocsCommandRowOption
    $script:GlobalOptions = @('Json', 'Help', 'RepositoryRoot')
}

AfterAll {
    foreach ($name in 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'documentation skill references' {
    It 'contains the nine required dispatch rows and six defined docs tools' {
        # Assert
        foreach ($row in 'init', 'validate-profile', 'check', 'inventory', 'coverage', 'update-ledger', 'validate', 'generate-reference', 'surface-delta') { $script:Rows.Keys | Should -Contain $row }
        $script:Rows.Count | Should -BeGreaterOrEqual 9
        foreach ($tool in $script:Set.McpTools) { $script:Defined | Should -Contain $tool }
    }

    It 'references only docs MCP tools defined by 1036 in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath $Path

        # Act
        $named = @(
            [regex]::Matches($text, 'mcp__drm-copilot__(?<name>[a-z_]+)') | ForEach-Object { $_.Groups['name'].Value }
            [regex]::Matches($text, 'drmcopilotextension/(?<name>[a-z_]+)') | ForEach-Object { $_.Groups['name'].Value }
            [regex]::Matches($text, '`(?<name>[a-z]+_docs_[a-z_]+)`') | ForEach-Object { $_.Groups['name'].Value }
        ) | Sort-Object -Unique
        $foreign = @($named | Where-Object { $script:Set.McpTools -notcontains $_ -or $script:Defined -notcontains $_ })

        # Assert
        $foreign | Should -BeNullOrEmpty
    }

    It 'references only dispatch-table subcommands and options in <Path>' -ForEach $script:SkillCopyRows {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath $Path

        # Act
        $offences = foreach ($line in ($text -split "`r?`n")) {
            $match = [regex]::Match($line, '-Command\s+(?<name>[A-Za-z-]+)(?<rest>.*)$')
            if (-not $match.Success) { continue }
            $name = $match.Groups['name'].Value
            if (-not $script:Rows.ContainsKey($name)) { "unknown subcommand $name"; continue }
            foreach ($option in [regex]::Matches($match.Groups['rest'].Value, '(?<=\s)-(?<option>[A-Za-z]+)\b')) {
                $optionName = $option.Groups['option'].Value
                if ($script:Rows[$name] -notcontains $optionName -and $script:GlobalOptions -notcontains $optionName) { "$name does not accept -$optionName" }
            }
        }

        # Assert
        @($offences) | Should -BeNullOrEmpty
    }

    It 'keeps <Path> free of .claude/ text and states the push-down prerequisite' -ForEach $script:HostCopyRows {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath $Path

        # Act
        $section = [regex]::Match($text, '(?ms)^## Prerequisites[ \t]*\r?\n(?<body>.*?)(?=^## |\z)')

        # Assert
        $text.Contains('.claude/') | Should -BeFalse
        $section.Success | Should -BeTrue
        $section.Groups['body'].Value | Should -Match 'docs helper library'
        $section.Groups['body'].Value | Should -Match 'push-down'
        $section.Groups['body'].Value | Should -Match 'PowerShell 7\.4'
    }

    It 'states the linter locations, the --config usage, and the workflow-path policy note in <Path> (issue #1169)' -ForEach $script:DocsInitCopyRows {
        # Arrange
        $text = (Read-DocsAuthoringText -RelativePath $Path) -replace '\s+', ' '
        $tokens = @('--config docs/documentation-estate/.vale.ini', 'VALE_CONFIG_PATH', 'docs/documentation-estate/.markdownlint.json', 'No workflow step runs Vale or markdownlint', 'policy-level control')

        # Assert
        foreach ($token in $tokens) { $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "docs-init states '$token'" }
    }

    It 'lists the seven skills in dispatch order in documentation-workflow' {
        # Arrange
        $text = Read-DocsAuthoringText -RelativePath '.claude/skills/documentation-workflow/SKILL.md'
        $order = @('docs-init', 'docs-inventory-surface', 'docs-plan-ia', 'docs-author-page', 'docs-reconcile-behavior', 'docs-review-coverage', 'docs-validate')

        # Act
        $positions = @($order | ForEach-Object { $text.IndexOf("[$_](../$_/SKILL.md)", [System.StringComparison]::Ordinal) })

        # Assert
        $positions | Should -Not -Contain -1
        $positions | Should -Be @($positions | Sort-Object)
    }
}
