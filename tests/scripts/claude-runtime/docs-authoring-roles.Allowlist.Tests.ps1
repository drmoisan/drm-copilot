#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tool allowlists of the four documentation roles on every host (issue #1037).

.DESCRIPTION
    Reads the committed Claude, Copilot and Codex agent files and their bundle copies and compares
    their native and MCP tool lists with the role table. No test writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $script:RoleRows = @((Get-DocsAuthoringNamedSet).Roles | ForEach-Object { @{ Role = $_ } })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'DocsAuthoringRoles.Helpers.ps1')
    $script:Set = Get-DocsAuthoringNamedSet
    $script:WriteClass = @('Write', 'Edit', 'MultiEdit', 'NotebookEdit', 'Bash')

    function Get-RoleToolSet {
        # Returns the native and MCP tools of one role on one host, with MCP names reduced to the bare tool name.
        param([string] $Role, [ValidateSet('Claude', 'Copilot', 'Codex')] [string] $HostName)
        $paths = Get-DocsAuthoringAgentPath -Role $Role
        $text = Read-DocsAuthoringText -RelativePath $paths[$HostName]
        if ($HostName -eq 'Codex') { $text = Get-DocsCodexEmbeddedText -Text $text }
        $tools = @(Get-DocsFrontMatterList -Text $text -Key 'tools')
        $mcpPrefix = if ($HostName -eq 'Copilot') { 'drmcopilotextension/' } else { 'mcp__drm-copilot__' }
        return @{
            All    = $tools
            Native = @($tools | Where-Object { -not $_.StartsWith($mcpPrefix) })
            Mcp    = @($tools | Where-Object { $_.StartsWith($mcpPrefix) } | ForEach-Object { $_.Substring($mcpPrefix.Length) })
        }
    }
}

AfterAll {
    foreach ($name in 'Get-RoleToolSet', 'Get-DocsAuthoringRepoRoot', 'Read-DocsAuthoringText', 'Get-DocsAuthoringNamedSet', 'Get-DocsAuthoringAgentPath', 'Get-DocsAuthoringSkillRoot', 'Get-DocsFrontMatterList', 'Get-DocsCodexEmbeddedText', 'Get-DocsCommandRowOption', 'Get-DocsMcpToolNameDefinition', 'Get-DocsPackManifestPath') {
        Remove-Item -LiteralPath "function:$name" -ErrorAction SilentlyContinue
    }
}

Describe 'documentation role tool allowlists' {
    It 'excludes Write-class and Bash tools from the read-only roles' {
        # Arrange
        $readOnly = @($script:Set.Roles | Where-Object { $_ -ne 'docs-author' })

        # Act
        $held = foreach ($role in $readOnly) { foreach ($tool in (Get-RoleToolSet -Role $role -HostName 'Claude').Native) { if ($script:WriteClass -contains $tool) { "$role holds $tool" } } }

        # Assert
        $readOnly.Count | Should -Be 3
        @($held) | Should -BeNullOrEmpty
    }

    It 'gives <Role> exactly the native Claude tools of the role table' -ForEach $script:RoleRows {
        # Act
        $native = (Get-RoleToolSet -Role $Role -HostName 'Claude').Native

        # Assert
        @($native | Sort-Object) | Should -Be @($script:Set.RoleTable[$Role].Native | Sort-Object)
    }

    It 'gives docs-author bare Write and Edit and no Bash' {
        # Act
        $native = (Get-RoleToolSet -Role 'docs-author' -HostName 'Claude').Native

        # Assert
        $native | Should -Contain 'Write'
        $native | Should -Contain 'Edit'
        $native | Should -Not -Contain 'Bash'
    }

    It 'keeps the Copilot tools of <Role> free of execute and, for read-only roles, of edit items' -ForEach $script:RoleRows {
        # Act
        $tools = (Get-RoleToolSet -Role $Role -HostName 'Copilot').All

        # Assert
        @($tools | Where-Object { $_ -like 'execute*' }) | Should -BeNullOrEmpty
        if ($Role -ne 'docs-author') { @($tools | Where-Object { $_ -like 'edit/*' }) | Should -BeNullOrEmpty }
        else { @($tools | Where-Object { $_ -like 'edit/*' } | Sort-Object) | Should -Be @('edit/createFile', 'edit/editFiles') }
    }

    It 'keeps the Codex embedded tools of <Role> equal to the Claude tools' -ForEach $script:RoleRows {
        # Act
        $codex = (Get-RoleToolSet -Role $Role -HostName 'Codex').All
        $claude = (Get-RoleToolSet -Role $Role -HostName 'Claude').All

        # Assert
        $codex | Should -Be $claude
    }

    It 'keeps every copy of <Role> free of path-scoped entries, disallowedTools and memory' -ForEach $script:RoleRows {
        # Arrange
        $paths = Get-DocsAuthoringAgentPath -Role $Role

        # Act
        $offences = foreach ($path in $paths.Values) {
            $text = Read-DocsAuthoringText -RelativePath $path
            foreach ($token in 'Write(', 'Edit(', 'disallowedTools', 'memory:') { if ($text.Contains($token)) { "$path contains $token" } }
        }

        # Assert
        @($offences) | Should -BeNullOrEmpty
    }

    It 'keeps the MCP tools of <Role> equal to the role table on every host' -ForEach $script:RoleRows {
        # Arrange
        $expected = @($script:Set.RoleTable[$Role].Mcp | Sort-Object)

        # Act / Assert
        foreach ($hostName in 'Claude', 'Copilot', 'Codex') {
            @((Get-RoleToolSet -Role $Role -HostName $hostName).Mcp | Sort-Object) | Should -Be $expected -Because "$Role on $hostName"
        }
    }

    It 'preloads the skills of the role table in the Claude copy of <Role>' -ForEach $script:RoleRows {
        # Act
        $skills = Get-DocsFrontMatterList -Text (Read-DocsAuthoringText -RelativePath (Get-DocsAuthoringAgentPath -Role $Role).Claude) -Key 'skills'

        # Assert
        @($skills) | Should -Be @($script:Set.RoleTable[$Role].Skills)
    }

    It 'holds update_docs_ledger only in docs-reconciler' {
        # Act
        $holders = foreach ($role in $script:Set.Roles) { foreach ($hostName in 'Claude', 'Copilot', 'Codex') { if ((Get-RoleToolSet -Role $role -HostName $hostName).Mcp -contains 'update_docs_ledger') { $role } } }

        # Assert
        @($holders | Sort-Object -Unique) | Should -Be @('docs-reconciler')
        @($holders).Count | Should -Be 3
    }

    It 'gives every docs MCP tool to at least one role' {
        # Act
        $held = @(foreach ($role in $script:Set.Roles) { (Get-RoleToolSet -Role $role -HostName 'Claude').Mcp }) | Sort-Object -Unique

        # Assert
        foreach ($tool in $script:Set.McpTools) { $held | Should -Contain $tool }
    }
}
