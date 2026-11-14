#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Byte identity of the shared docs-estate hook files (issue #1169).

.DESCRIPTION
    hook-docs-estate-context.ps1 and enforce-orchestration-preimplementation-gate-docs.ps1 are
    byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors, following the
    hook-cleanup-context.Parity.Tests.ps1 precedent. Only committed files located from
    $PSScriptRoot are hashed; no row writes a file or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

    function Get-DocsEstateParityHash {
        param([Parameter(Mandatory)] [string] $RelativePath)
        return (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Algorithm SHA256).Hash
    }
}

Describe 'docs-estate hook parity (issue #1169)' {
    It 'keeps the four copies of <Leaf> byte-identical' -ForEach @(
        @{ Leaf = 'hook-docs-estate-context.ps1' }
        @{ Leaf = 'enforce-orchestration-preimplementation-gate-docs.ps1' }
    ) {
        # Arrange
        $copies = @(
            ".claude/hooks/$Leaf"
            ".codex/hooks/$Leaf"
            "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/$Leaf"
            "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/$Leaf"
        )

        # Act
        $hashes = @($copies | ForEach-Object { Get-DocsEstateParityHash -RelativePath $_ })

        # Assert
        $hashes.Count | Should -Be 4
        @($hashes | Select-Object -Unique).Count | Should -Be 1 -Because "every copy of $Leaf must equal .claude/hooks/$Leaf"
    }

    It 'keeps hook-docs-estate-context.ps1 free of imports and dot-sources' {
        # Arrange
        $path = Join-Path $script:RepoRoot '.claude/hooks/hook-docs-estate-context.ps1'
        $tokens = $null
        $parseErrors = $null

        # Act
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)
        $loads = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and ($node.GetCommandName() -eq 'Import-Module' -or $node.InvocationOperator -eq 'Dot') }, $true))

        # Assert
        @($parseErrors) | Should -BeNullOrEmpty
        $loads | Should -BeNullOrEmpty
    }
}
