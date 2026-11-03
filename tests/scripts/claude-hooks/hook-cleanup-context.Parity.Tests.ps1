#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Byte identity and literal pinning for the shared cleanup-context files (issue #1026).

.DESCRIPTION
    hook-cleanup-context.ps1 and enforce-orchestration-preimplementation-gate-cleanup.ps1 are
    byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors. The literals that
    hook-cleanup-context.ps1 restates are pinned equal to the CleanupWorktreeManifest.psm1
    constants, read from the imported module's scope, and to CLEANUP_WT_CONSOLIDATION_BRANCH,
    read from the text of cleanup_worktrees_actions_lib.sh. Only committed files located from
    $PSScriptRoot are read; no row writes a file or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    . (Join-Path $script:RepoRoot '.claude/hooks/hook-cleanup-context.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent' -Surface 'Claude'
    $script:ManifestModule = Get-Module -Name CleanupWorktreeManifest

    function Get-CleanupParityHash {
        param([Parameter(Mandatory)] [string] $RelativePath)
        return (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Algorithm SHA256).Hash
    }
}

Describe 'cleanup-context parity (issue #1026)' {
    It 'keeps the four copies of <Leaf> byte-identical' -ForEach @(
        @{ Leaf = 'hook-cleanup-context.ps1' }
        @{ Leaf = 'enforce-orchestration-preimplementation-gate-cleanup.ps1' }
    ) {
        # Arrange
        $copies = @(
            ".claude/hooks/$Leaf"
            ".codex/hooks/$Leaf"
            "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/$Leaf"
            "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/$Leaf"
        )

        # Act
        $hashes = @($copies | ForEach-Object { Get-CleanupParityHash -RelativePath $_ })

        # Assert
        $hashes.Count | Should -Be 4
        @($hashes | Select-Object -Unique).Count | Should -Be 1 -Because "every copy of $Leaf must equal .claude/hooks/$Leaf"
    }

    It 'restates the CleanupWorktreeManifest tool, schema version, and freshness bound' {
        # Arrange
        $tool = & $script:ManifestModule { $script:ExpectedManifestTool }
        $schemaVersion = & $script:ManifestModule { $script:ExpectedManifestSchemaVersion }
        $bound = & $script:ManifestModule { $script:ManifestFreshnessBound }
        $path = & $script:ManifestModule { $script:CleanupWorktreeManifestPath }

        # Assert
        $script:CleanupContextManifestTool | Should -BeExactly $tool
        $script:CleanupContextManifestSchemaVersion | Should -Be $schemaVersion
        [timespan]::FromHours($script:CleanupContextFreshnessHours) | Should -Be $bound
        $script:CleanupContextManifestRelativePath | Should -BeExactly $path
    }

    It 'restates CLEANUP_WT_CONSOLIDATION_BRANCH from the cleanup script library' {
        # Arrange
        $text = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh')
        $match = [regex]::Match($text, '(?m)^CLEANUP_WT_CONSOLIDATION_BRANCH="(?<branch>[^"]+)"')

        # Assert
        $match.Success | Should -BeTrue -Because 'the library assigns the consolidation branch on one line'
        $script:CleanupContextBranch | Should -BeExactly $match.Groups['branch'].Value
    }
}
