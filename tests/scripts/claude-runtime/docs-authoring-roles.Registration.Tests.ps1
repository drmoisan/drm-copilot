#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Hook registration and docs_operations routing of the documentation roles (issue #1037).

.DESCRIPTION
    Reads both committed settings copies and the three committed routing copies. No test writes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $script:Set = Get-DocsAuthoringNamedSet
    $script:SettingsCopies = @('.claude/settings.json', 'extensions/drm-copilot/resources/claude-customizations/.claude/settings.json')
    $script:RoutingCopies = @('config/orchestration-routing.json', 'extensions/drm-copilot/resources/config/orchestration-routing.json', 'extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json')
    $script:StopMatcher = 'docs-architect|docs-author|docs-reconciler|docs-coverage-reviewer'
    $script:StopCommand = 'pwsh -NoProfile -File .claude/hooks/validate-docs-role-output.ps1'
    $script:WriteMatcher = 'Write|Edit|MultiEdit|NotebookEdit|Bash'
    $script:WriteCommand = 'pwsh -NoProfile -File .claude/hooks/enforce-docs-role-write-scope.ps1'

    function Get-HookGroupCount {
        # Counts the groups of one hook event whose matcher and single command equal the given values.
        param($Settings, [string] $HookEvent, [string] $Matcher, [string] $Command)
        return @($Settings.hooks.$HookEvent | Where-Object { $_.matcher -ceq $Matcher -and @($_.hooks).Count -eq 1 -and $_.hooks[0].command -ceq $Command }).Count
    }
}

AfterAll {
    foreach ($name in 'Get-HookGroupCount', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'documentation role hook registration' {
    It 'registers exactly one SubagentStop group for the docs roles in <Path>' -ForEach @(
        @{ Path = '.claude/settings.json' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/settings.json' }
    ) {
        # Act
        $settings = Read-DocsAuthoringText -RelativePath $Path | ConvertFrom-Json

        # Assert
        Get-HookGroupCount -Settings $settings -HookEvent 'SubagentStop' -Matcher $script:StopMatcher -Command $script:StopCommand | Should -Be 1
    }

    It 'registers exactly one PreToolUse write-scope group in <Path>' -ForEach @(
        @{ Path = '.claude/settings.json' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/settings.json' }
    ) {
        # Act
        $settings = Read-DocsAuthoringText -RelativePath $Path | ConvertFrom-Json

        # Assert
        Get-HookGroupCount -Settings $settings -HookEvent 'PreToolUse' -Matcher $script:WriteMatcher -Command $script:WriteCommand | Should -Be 1
    }

    It 'keeps the two settings copies byte-identical' {
        # Act
        $hashes = @($script:SettingsCopies | ForEach-Object { (Get-FileHash -LiteralPath (Join-Path (Get-DocsAuthoringRepoRoot) $_) -Algorithm SHA256).Hash } | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 1
    }
}

Describe 'docs_operations routing block' {
    BeforeAll {
        $script:Operations = (Read-DocsAuthoringText -RelativePath 'config/orchestration-routing.json' | ConvertFrom-Json -AsHashtable)['docs_operations']
    }

    It 'maps exactly the eight docs skills' {
        # Assert
        @($script:Operations.Keys | Sort-Object) | Should -Be @($script:Set.Skills | Sort-Object)
    }

    It 'maps <Skill> to its logical agent and MCP tools' -ForEach @(
        @{ Skill = 'documentation-workflow' }, @{ Skill = 'docs-init' }, @{ Skill = 'docs-inventory-surface' }, @{ Skill = 'docs-plan-ia' }
        @{ Skill = 'docs-author-page' }, @{ Skill = 'docs-reconcile-behavior' }, @{ Skill = 'docs-review-coverage' }, @{ Skill = 'docs-validate' }
    ) {
        # Arrange
        $expected = $script:Set.SkillTable[$Skill]

        # Act
        $entry = $script:Operations[$Skill]

        # Assert
        $entry['logical_agent'] | Should -Be $expected.Agent
        @($entry['mcp_tools']) | Should -Be @($expected.Mcp)
    }

    It 'lists for each role-run skill only tools that the role Claude agent holds' {
        # Act
        $missing = foreach ($skill in $script:Operations.Keys) {
            $agent = $script:Operations[$skill]['logical_agent']
            if ($agent -eq 'root') { if (@($script:Operations[$skill]['mcp_tools']).Count -gt 0) { "$skill is root but lists tools" }; continue }
            $text = Read-DocsAuthoringText -RelativePath (Get-DocsAuthoringAgentPath -Role $agent).Claude
            $held = @(Get-DocsFrontMatterList -Text $text -Key 'tools')
            foreach ($tool in @($script:Operations[$skill]['mcp_tools'])) { if ($held -notcontains "mcp__drm-copilot__$tool") { "$skill lists $tool, which $agent does not hold" } }
        }

        # Assert
        @($missing) | Should -BeNullOrEmpty
    }

    It 'keeps the three routing copies byte-identical' {
        # Act
        $hashes = @($script:RoutingCopies | ForEach-Object { (Get-FileHash -LiteralPath (Join-Path (Get-DocsAuthoringRepoRoot) $_) -Algorithm SHA256).Hash } | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 1
    }

    It 'carries the docs_operations block in <Path>' -ForEach @(
        @{ Path = 'config/orchestration-routing.json' }
        @{ Path = 'extensions/drm-copilot/resources/config/orchestration-routing.json' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json' }
    ) {
        # Act
        $document = Read-DocsAuthoringText -RelativePath $Path | ConvertFrom-Json -AsHashtable

        # Assert
        $document.ContainsKey('docs_operations') | Should -BeTrue
    }
}
