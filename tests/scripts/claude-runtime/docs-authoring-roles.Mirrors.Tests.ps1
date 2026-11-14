#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Mirror set, bundle byte-identity and pack-manifest membership of the documentation roles, skills,
    templates and hooks (issue #1037).

.DESCRIPTION
    Compares SHA-256 hashes of committed files and reads the two pack manifests. No test writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $set = Get-DocsAuthoringNamedSet
    $script:RoleRows = @($set.Roles | ForEach-Object { @{ Role = $_ } })
    $script:SkillRows = @($set.Skills | ForEach-Object { @{ Skill = $_ } })
    $script:TemplateRows = @($set.Templates | ForEach-Object { @{ Template = $_ } })
    $script:HookRows = @('docs-role-contract.ps1', 'validate-docs-role-output.ps1', 'enforce-docs-role-write-scope.ps1' | ForEach-Object { @{ Hook = $_ } })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $script:Set = Get-DocsAuthoringNamedSet
    $script:Roots = Get-DocsAuthoringSkillRoot
    $script:ClaudeManifest = Get-DocsPackManifestPath -RelativeManifest 'claude-customizations/pack-manifests/core.json'
    $script:CodexManifest = Get-DocsPackManifestPath -RelativeManifest 'codex-and-agents-customizations/pack-manifests/core.json'

    function Get-RepoFileHash {
        # Returns the SHA-256 of one repository-relative file, or $null when it does not exist.
        param([string] $RelativePath)
        $path = Join-Path (Get-DocsAuthoringRepoRoot) $RelativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
        return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    }
}

AfterAll {
    foreach ($name in 'Get-RepoFileHash', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'documentation mirror set' {
    It 'places <Role> at all six agent locations with byte-identical bundle copies' -ForEach $script:RoleRows {
        # Arrange
        $paths = Get-DocsAuthoringAgentPath -Role $Role

        # Act
        $hashes = @{}
        foreach ($key in $paths.Keys) { $hashes[$key] = Get-RepoFileHash -RelativePath $paths[$key] }

        # Assert
        foreach ($key in $paths.Keys) { $hashes[$key] | Should -Not -BeNullOrEmpty -Because $paths[$key] }
        $hashes['CopilotBundle'] | Should -Be $hashes['Copilot']
        $hashes['ClaudeBundle'] | Should -Be $hashes['Claude']
        $hashes['CodexBundle'] | Should -Be $hashes['Codex']
    }

    It 'places <Skill> at all six skill locations with byte-identical bundle copies' -ForEach $script:SkillRows {
        # Act
        $hashes = @{}
        foreach ($key in $script:Roots.Keys) { $hashes[$key] = Get-RepoFileHash -RelativePath "$($script:Roots[$key])/$Skill/SKILL.md" }

        # Assert
        foreach ($key in $script:Roots.Keys) { $hashes[$key] | Should -Not -BeNullOrEmpty -Because "$key copy of $Skill" }
        $hashes['ClaudeBundle'] | Should -Be $hashes['Claude']
        $hashes['CopilotBundle'] | Should -Be $hashes['Copilot']
        $hashes['CodexBundle'] | Should -Be $hashes['Codex']
    }

    It 'keeps the <Template> template byte-identical at all six skill locations' -ForEach $script:TemplateRows {
        # Act
        $hashes = @(foreach ($key in $script:Roots.Keys) { Get-RepoFileHash -RelativePath "$($script:Roots[$key])/docs-author-page/templates/$Template.md" })

        # Assert
        $hashes | Should -Not -Contain $null
        @($hashes | Sort-Object -Unique).Count | Should -Be 1
    }

    It 'keeps the <Hook> bundle copy byte-identical' -ForEach $script:HookRows {
        # Act
        $source = Get-RepoFileHash -RelativePath ".claude/hooks/$Hook"
        $copy = Get-RepoFileHash -RelativePath "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/$Hook"

        # Assert
        $source | Should -Not -BeNullOrEmpty
        $copy | Should -Be $source
    }

    It 'lists every Claude file of the feature exactly once in the Claude core manifest' {
        # Arrange
        $expected = @(
            $script:Set.Roles | ForEach-Object { ".claude/agents/$_.md" }
            $script:Set.Skills | ForEach-Object { ".claude/skills/$_/SKILL.md" }
            $script:Set.Templates | ForEach-Object { ".claude/skills/docs-author-page/templates/$_.md" }
            'docs-role-contract.ps1', 'validate-docs-role-output.ps1', 'enforce-docs-role-write-scope.ps1' | ForEach-Object { ".claude/hooks/$_" }
        )

        # Act
        $counts = foreach ($path in $expected) { '{0}={1}' -f $path, @($script:ClaudeManifest | Where-Object { $_ -ceq $path }).Count }

        # Assert
        $expected.Count | Should -Be 23
        @($counts | Where-Object { -not $_.EndsWith('=1') }) | Should -BeNullOrEmpty
    }

    It 'lists every Codex and .agents file of the feature exactly once in the Codex core manifest' {
        # Arrange
        $expected = @(
            $script:Set.Roles | ForEach-Object { ".codex/agents/$_.toml" }
            $script:Set.Skills | ForEach-Object { ".agents/skills/$_/SKILL.md" }
            $script:Set.Templates | ForEach-Object { ".agents/skills/docs-author-page/templates/$_.md" }
        )

        # Act
        $counts = foreach ($path in $expected) { '{0}={1}' -f $path, @($script:CodexManifest | Where-Object { $_ -ceq $path }).Count }

        # Assert
        $expected.Count | Should -Be 20
        @($counts | Where-Object { -not $_.EndsWith('=1') }) | Should -BeNullOrEmpty
    }
}
