#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the epic-scope resolver module (issue #663).

.DESCRIPTION
    Drives Resolve-EpicScopeCheckpoint and its read seams in
    .claude/lib/worktree-resolution/EpicScopeResolution.psm1. Every filesystem contact
    is mocked inside the module: the resolver-level seams (Find-WorktreeResolutionRoot,
    Get-EpicScopeCheckpointText, Get-EpicScopeWorktreeHeadBranch,
    Test-EpicScopeMergeInProgress) for the resolution cases, and the WorktreeResolution
    seams (Get-WorktreeResolutionGitEntryKind, Get-WorktreeResolutionGitFileText) for the
    seam cases. Only the synthetic roots /synthetic-worktrees/epic-coordinator and
    /synthetic-worktrees/epic-integration appear, so no host path is read or asserted.
    No test creates a file, reads live git state, or changes the working directory.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeResolution.psm1') -Force

    $script:CoordinatorRoot = '/synthetic-worktrees/epic-coordinator'
    $script:IntegrationRoot = '/synthetic-worktrees/epic-integration'
    $script:IntegrationBranch = 'epic/sample-epic-integration'
    $script:EpicCheckpointPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'
    $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'

    function Set-EpicScopeResolverMock {
        <#
            Registers the resolver-level seams: the worktree ascent echoes a synthetic
            path and maps anything else to the coordinator root, the checkpoint read
            returns the supplied text, and HEAD and MERGE_HEAD return the supplied values.
        #>
        param(
            [AllowNull()] [string] $CheckpointText,
            [AllowNull()] [string] $HeadBranch,
            [bool] $MergeInProgress = $false
        )

        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
            if ($Path -like '/synthetic-worktrees/*') { return $Path }
            return '/synthetic-worktrees/epic-coordinator'
        }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $CheckpointText }.GetNewClosure()
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $HeadBranch }.GetNewClosure()
        Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $MergeInProgress }.GetNewClosure()
    }
}

Describe 'Resolve-EpicScopeCheckpoint epic-scope matches' {
    It 'resolves epic scope when the --head branch equals integration_branch' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration --base main' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeTrue -Because 'the --head branch equals the epic integration_branch'
        $scope.Branch | Should -Be $script:IntegrationBranch
        $scope.WorktreeRoot | Should -Be $script:CoordinatorRoot
        $scope.Checkpoint.route_id | Should -Be 'epic'
        $scope.MergeInProgress | Should -BeFalse -Because 'head matching was not requested'
    }

    It 'resolves epic scope when a branch: label equals integration_branch' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text "Delegate the integration PR.`nbranch: epic/sample-epic-integration" -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeTrue -Because 'a branch: delegation label is a branch signal'
        $scope.Branch | Should -Be $script:IntegrationBranch
    }

    It 'resolves epic scope for a command leg whose -C selector worktree HEAD equals integration_branch' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $script:IntegrationBranch

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git -C /synthetic-worktrees/epic-integration add scripts/powershell/Sample.ps1' -SessionRoot $script:CoordinatorRoot -WorktreeSelector $script:IntegrationRoot -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeTrue -Because 'the selector worktree has the integration branch checked out'
        $scope.WorktreeRoot | Should -Be $script:IntegrationRoot
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-integration' }
    }

    It 'resolves epic scope for a command leg without a selector when the session-root HEAD equals integration_branch' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $script:IntegrationBranch

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:CoordinatorRoot -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeTrue -Because 'the session-root HEAD is the integration branch'
        $scope.WorktreeRoot | Should -Be $script:CoordinatorRoot
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-coordinator' }
    }

    It 'reports a merge in progress for a head-matched command leg when MERGE_HEAD exists' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $script:IntegrationBranch -MergeInProgress $true

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:CoordinatorRoot -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeTrue
        $scope.MergeInProgress | Should -BeTrue -Because 'the MERGE_HEAD probe reported a merge in the effective worktree'
        Should -Invoke Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-coordinator' }
    }
}

Describe 'Resolve-EpicScopeCheckpoint fail-closed non-matches' {
    It 'is not epic scope when the epic checkpoint is absent' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $null -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
    }

    It 'is not epic scope when the epic checkpoint is unparseable' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText '{"route_id": "epic",' -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeFalse -Because 'truncated JSON never throws out of the resolver'
        $scope.Reason | Should -Be 'epic-checkpoint-absent-or-unparseable'
    }

    It 'is not epic scope when route_id is not epic' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText ($script:ReadyEpicJson -replace '"route_id":"epic"', '"route_id":"parallel"') -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'route_id'
    }

    It 'is not epic scope when integration_branch is empty' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText ($script:ReadyEpicJson -replace '"integration_branch":"epic/sample-epic-integration"', '"integration_branch":""') -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'integration_branch'
    }

    It 'is not epic scope when the branch signal does not equal integration_branch' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head feature/standalone-item --base main' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'branch-mismatch'
    }

    It 'is not epic scope when the worktree HEAD does not equal integration_branch' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch 'feature/standalone-item'

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:CoordinatorRoot -MatchWorktreeHead

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'branch-mismatch'
        Should -Invoke Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -Times 0 -Exactly
    }

    It 'is not epic scope and reads no checkpoint when there is no branch signal and head matching is off' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $script:IntegrationBranch

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --base main' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'no-branch-signal'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 0 -Exactly
    }

    It 'is not epic scope when the session root is not inside a worktree' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $null
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution { $null }

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration' -SessionRoot '/synthetic-worktrees/epic-coordinator/no-marker'

        # Assert
        $scope.IsEpicScope | Should -BeFalse
        $scope.Reason | Should -Be 'session-root-unresolved'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 0 -Exactly
    }
}

Describe 'Resolve-EpicScopeCheckpoint checkpoint path composition' {
    It 'returns an absolute checkpoint path composed from the session worktree root' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $null

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text 'gh pr create --head epic/sample-epic-integration' -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.CheckpointPath | Should -Be $script:EpicCheckpointPath
        $scope.CheckpointPath | Should -Match '^/' -Because 'the path is composed from the resolved absolute root (issue #673 invariant)'
        (Get-EpicScopeCheckpointRelativePath) | Should -Be 'artifacts/orchestration/epic-orchestrator-state.json'
    }

    It 'never takes the checkpoint path from text that names another epic checkpoint' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $null
        $text = 'gh pr create --head epic/sample-epic-integration --body-file /synthetic-worktrees/epic-integration/artifacts/orchestration/epic-orchestrator-state.json'

        # Act
        $scope = Resolve-EpicScopeCheckpoint -Text $text -SessionRoot $script:CoordinatorRoot

        # Assert
        $scope.CheckpointPath | Should -Be $script:EpicCheckpointPath -Because 'no checkpoint path is ever read from command or prompt text'
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 0 -Exactly -ParameterFilter { $Path -like '/synthetic-worktrees/epic-integration/*' }
    }

    It 'reads the epic checkpoint through the seam exactly once per resolution' {
        # Arrange
        Set-EpicScopeResolverMock -CheckpointText $script:ReadyEpicJson -HeadBranch $script:IntegrationBranch -MergeInProgress $true

        # Act
        $null = Resolve-EpicScopeCheckpoint -Text 'git add scripts/powershell/Sample.ps1' -SessionRoot $script:CoordinatorRoot -MatchWorktreeHead

        # Assert
        Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json' }
    }
}

Describe 'EpicScopeResolution read seams' {
    It 'returns null checkpoint text when the checkpoint file is absent' {
        # Arrange
        Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution { 'None' }
        Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { 'unexpected' }

        # Act
        $text = Get-EpicScopeCheckpointText -Path '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'

        # Assert
        $text | Should -BeNullOrEmpty
        Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 0 -Exactly
    }

    It 'reads the HEAD branch of a linked worktree through its gitdir file' {
        # Arrange: a linked worktree's .git is a file whose gitdir line names the admin directory.
        Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution {
            if ($Path -eq '/synthetic-worktrees/epic-integration/.git') { return 'File' }
            return 'None'
        }
        Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution {
            switch ($Path) {
                '/synthetic-worktrees/epic-integration/.git' { return "gitdir: /synthetic-worktrees/epic-coordinator/.git/worktrees/epic-integration`n" }
                '/synthetic-worktrees/epic-coordinator/.git/worktrees/epic-integration/HEAD' { return "ref: refs/heads/epic/sample-epic-integration`n" }
            }
            return $null
        }

        # Act
        $branch = Get-EpicScopeWorktreeHeadBranch -WorktreeRoot $script:IntegrationRoot

        # Assert
        $branch | Should -Be $script:IntegrationBranch
    }

    It 'reads the HEAD branch of a main checkout through its git directory' {
        # Arrange: a main checkout's .git is a directory holding HEAD.
        Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution {
            if ($Path -eq '/synthetic-worktrees/epic-coordinator/.git') { return 'Directory' }
            return 'None'
        }
        Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution {
            if ($Path -eq '/synthetic-worktrees/epic-coordinator/.git/HEAD') { return "ref: refs/heads/main`n" }
            return $null
        }

        # Act
        $branch = Get-EpicScopeWorktreeHeadBranch -WorktreeRoot $script:CoordinatorRoot

        # Assert
        $branch | Should -Be 'main'
    }

    It 'returns no HEAD branch for a detached HEAD' {
        # Arrange
        Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution { 'Directory' }
        Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { "d754f83f714b087e404577cb7a1b02f48d2023bb`n" }

        # Act
        $branch = Get-EpicScopeWorktreeHeadBranch -WorktreeRoot $script:CoordinatorRoot

        # Assert
        $branch | Should -BeNullOrEmpty -Because 'a detached HEAD names no branch'
    }

    It 'probes MERGE_HEAD in the worktree git directory' {
        # Arrange: a relative gitdir target is joined to the worktree root.
        Mock Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution {
            switch ($Path) {
                '/synthetic-worktrees/epic-integration/.git' { return 'File' }
                '/synthetic-worktrees/epic-integration/admin/MERGE_HEAD' { return 'File' }
            }
            return 'None'
        }
        Mock Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution { "gitdir: admin`n" }

        # Act
        $inProgress = Test-EpicScopeMergeInProgress -WorktreeRoot $script:IntegrationRoot
        $noGitDirectory = Test-EpicScopeMergeInProgress -WorktreeRoot '/synthetic-worktrees/epic-coordinator'

        # Assert
        $inProgress | Should -BeTrue -Because 'MERGE_HEAD exists in the linked worktree admin directory'
        $noGitDirectory | Should -BeFalse -Because 'a root without a .git entry has no merge state'
        Should -Invoke Get-WorktreeResolutionGitEntryKind -ModuleName EpicScopeResolution -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/epic-integration/admin/MERGE_HEAD' }
    }
}
