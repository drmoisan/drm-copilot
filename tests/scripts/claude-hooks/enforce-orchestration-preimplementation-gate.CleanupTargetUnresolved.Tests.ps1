#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unresolved-target denial of the Claude cleanup consolidation command leg (issue #1016).

.DESCRIPTION
    Get-OrchestrationCleanupConsolidationCommandResult in
    .claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1 denies, with an empty
    deny suffix, a command whose every segment has the cleanup shape when the command target
    resolver cannot resolve a target. The rows drive that branch with a relative session root,
    which the resolver rejects with the session-root-not-absolute rule before any worktree
    listing or checkpoint read. No row creates a file, starts a process, reads a clock, or
    touches the network.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    # The parallel records leg calls these from hook scope, where the module-scoped baseline mocks do not reach.
    Mock Get-EpicScopeWorktreeHeadBranch { $null }
    Mock Get-WorktreeRunCheckpointText { $null }
    $script:Command = 'git -C /synthetic-worktrees/documentationandmemories add -- docs/research/y.md'
    $script:RelativeRoot = 'synthetic/relative-session'
}

Describe 'Claude cleanup consolidation command leg: unresolved target (issue #1016)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'resolves no target for a cleanup-shaped command under a relative session root' {
        # Arrange
        $command = $script:Command

        # Act
        $target = Get-OrchestrationCommandTarget -Command $command -SessionRoot $script:RelativeRoot

        # Assert
        $target.Resolved | Should -BeFalse -Because 'a relative session root is not resolvable'
        $target.Detail | Should -BeLike 'session-root-not-absolute:*'
    }

    It 'denies the command with an empty deny suffix when the target is unresolved' {
        # Arrange
        Mock Get-OrchestrationGateWorktreeList { throw 'the listing must not be read for an unresolved target' }

        # Act
        $result = Get-OrchestrationCleanupConsolidationCommandResult -Command $script:Command -SessionRoot $script:RelativeRoot

        # Assert
        $result.Allowed | Should -BeFalse
        $result.DenySuffix | Should -Be ''
        Should -Invoke Get-OrchestrationGateWorktreeList -Times 0 -Exactly
    }
}
