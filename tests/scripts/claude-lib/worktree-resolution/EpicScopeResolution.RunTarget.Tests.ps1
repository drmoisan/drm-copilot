#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Run-target location rows for the epic-scope resolver (issue #690).

.DESCRIPTION
    Resolve-EpicScopeCheckpoint locates the epic checkpoint through
    Resolve-WorktreeEpicTarget keyed on the matched branch rather than composing it from the
    session root. These rows drive the shipped run resolver over the live-root and
    checkpoint-text seams mocked in module scope 'WorktreeRunResolution', and mock the
    resolver-level seams inside 'EpicScopeResolution', so no row creates a file, reads a
    clock, starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form; the session root is the current location with forward
    slashes, returned by the live-root mock alongside the synthetic roots.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeResolution.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:IntegrationBranch = 'epic/sample-epic-integration'
    $script:EpicPath = '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'
    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","integration_branch":"epic/sample-epic-integration","features":[]}'

    function Set-RunTargetTopology {
        <#
            Registers the resolver-level seams in EpicScopeResolution and the live-root and
            checkpoint-text seams in WorktreeRunResolution. Epic maps a worktree root to its
            checkpoint text; a -Branch live-root query returns no worktree, so several
            matches stay unresolved.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Epic = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        $headBranchValue = $script:IntegrationBranch
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { $Path }
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $headBranchValue }.GetNewClosure()
        Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $false }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution {
            param([string] $Branch)
            if (-not [string]::IsNullOrEmpty($Branch)) { return , [string[]] @() }
            return , [string[]] $liveSet
        }.GetNewClosure()
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }
}

Describe 'Resolve-EpicScopeCheckpoint run-target location' {
    It 'N1 resolves a head-matched command leg to the epic checkpoint held only in another worktree' {
        # Arrange
        Set-RunTargetTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:ReadyEpicJson }

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:Session -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeTrue -Because "the only epic checkpoint recording the branch is at w-epic (reason: $($scope.Reason))"
        $scope.CheckpointPath | Should -Be $script:EpicPath
    }

    It 'N2 is not epic scope when no worktree records the branch' {
        # Arrange
        Set-RunTargetTopology -Live @($script:Session)

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:Session -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 0 -Exactly
    }

    It 'N3 is not epic scope with target-worktree-ambiguous when two unresolvable worktrees record the branch' {
        # Arrange
        Set-RunTargetTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') `
            -Epic @{ '/synthetic-worktrees/a' = $script:ReadyEpicJson; '/synthetic-worktrees/b' = $script:ReadyEpicJson }

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:Session -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'target-worktree-ambiguous'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 0 -Exactly
    }

    It 'N4 reads Get-EpicScopeCheckpointText exactly once with the resolved path' {
        # Arrange
        Set-RunTargetTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $script:ReadyEpicJson }

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text "gh pr create --head $($script:IntegrationBranch) --base main" -SessionRoot $script:Session

        # Assert
        $scope.IsEpicScope | Should -BeTrue
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $Path -eq $script:EpicPath }
    }
}
