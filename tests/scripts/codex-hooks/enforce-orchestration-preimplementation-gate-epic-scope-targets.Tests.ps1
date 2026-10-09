#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Codex preimplementation gate epic-scope rows that resolve every segment and path target (issue #738).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision of the Codex gate with the mapped
    tool_input JSON. The four resolver seams Find-WorktreeResolutionRoot,
    Get-EpicScopeCheckpointText, Get-EpicScopeWorktreeHeadBranch, and
    Test-EpicScopeMergeInProgress are mocked by name: the session root maps to
    /synthetic-worktrees/epic-coordinator, /outside/ paths do not resolve, and any other
    /synthetic-worktrees/<name>/ path resolves to its first two segments. The Codex payload
    carries no workdir, so a segment without -C targets the session root (decision D4). Every
    row passes a not-ready single-feature checkpoint. The file creates no file and starts no
    child process.
#>

Describe 'Codex preimplementation gate epic-scope targets (issue #738)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"}]}'
        $script:NotReadySingleFeature = '{"issue-num":"738","route_id":"large","lifecycle_ready":false}'
        $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'

        function Set-CodexTargetSeam {
            <#
                Mock the four resolver seams with the shared fixture model; the checkpoint text
                is closed over by value.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([AllowNull()] [string] $CheckpointText)
            $text = $CheckpointText
            Mock Find-WorktreeResolutionRoot {
                if ($Path -like '/outside/*') { return $null }
                if ($Path -match '^(/synthetic-worktrees/[^/]+)') { return $Matches[1] }
                return '/synthetic-worktrees/epic-coordinator'
            }
            Mock Get-EpicScopeCheckpointText -MockWith ({ $text }.GetNewClosure())
            Mock Get-EpicScopeWorktreeHeadBranch {
                if ($WorktreeRoot -eq '/synthetic-worktrees/epic-other') { return 'feature/standalone-item' }
                return 'epic/sample-epic-integration'
            }
            Mock Test-EpicScopeMergeInProgress { $WorktreeRoot -ne '/synthetic-worktrees/epic-child' }
        }

        function Get-CodexTargetGateDecision {
            # Single act step: decide one mapped command against a not-ready checkpoint.
            param([Parameter(Mandatory)] [string] $Command)
            return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ command = $Command } | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It '<Name>' -ForEach @(
        @{ Name = 'denies a second segment that targets a different not-ready worktree'; Command = 'git add scripts/powershell/A.ps1 && git -C /synthetic-worktrees/epic-child add scripts/powershell/B.ps1'; Code = 'target-not-ready' }
        @{ Name = 'denies a relative -C selector in epic scope'; Command = 'git -C subdir add scripts/powershell/Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies an unresolvable -C selector in epic scope'; Command = 'git -C /outside/elsewhere add scripts/powershell/Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies a directory-changing segment in epic scope'; Command = 'cd /synthetic-worktrees/epic-child && git add scripts/powershell/Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies a wrapper-led git segment in epic scope'; Command = 'nohup git -C /synthetic-worktrees/epic-child add scripts/powershell/Sample.ps1'; Code = 'target-unresolvable' }
        @{ Name = 'denies a target outside the epic scope of the session root'; Command = 'git -C /synthetic-worktrees/epic-other add scripts/powershell/Sample.ps1'; Code = 'target-mixed' }
        @{ Name = 'denies an apply_patch absolute file marker into a not-ready epic worktree'; Command = "*** Begin Patch`n*** Update File: /synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1`n@@`n-old`n+new`n*** End Patch"; Code = 'target-not-ready' }
    ) {
        # Arrange
        Set-CodexTargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-CodexTargetGateDecision -Command $Command

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "$Name in epic scope"
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ') | Should -BeTrue -Because 'every epic-scope deny keeps the gate prefix'
        $reason.Contains($Code) | Should -BeTrue -Because "the deny names $Code"
    }

    It 'evaluates every value of a repeated -C selector' {
        # Arrange
        Set-CodexTargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-CodexTargetGateDecision -Command 'git -C /synthetic-worktrees/epic-integration -C /synthetic-worktrees/epic-child add scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'the second selector worktree has no merge in progress'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ') | Should -BeTrue -Because 'every epic-scope deny keeps the gate prefix'
        $reason.Contains('target-not-ready') | Should -BeTrue -Because 'the not-ready target is named'
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-integration' }
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-child' }
    }

    It 'allows when every target is epic scope and ready' {
        # Arrange
        Set-CodexTargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-CodexTargetGateDecision -Command 'git -C /synthetic-worktrees/epic-integration add scripts/powershell/A.ps1 && git -C /synthetic-worktrees/epic-coordinator add scripts/powershell/B.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'both targets are epic scope with a merge in progress'
    }

    It 'keeps the single-feature decision for <Label> outside epic scope' -ForEach @(
        @{ Label = 'a relative -C selector'; Command = 'git -C subdir add scripts/powershell/Sample.ps1' }
        @{ Label = 'a directory change'; Command = 'cd /synthetic-worktrees/epic-child && git add scripts/powershell/Sample.ps1' }
    ) {
        # Arrange
        Set-CodexTargetSeam -CheckpointText $null

        # Act
        $decision = Get-CodexTargetGateDecision -Command $Command

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'the not-ready single-feature checkpoint decides'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason -Because 'no epic checkpoint leaves the decision unchanged'
    }

    It 'resolves a segment without -C to the session root' {
        # Arrange
        Set-CodexTargetSeam -CheckpointText $script:ReadyEpicJson

        # Act
        $decision = Get-CodexTargetGateDecision -Command 'git add scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'the session root is epic scope with a merge in progress'
        Should -Invoke Get-EpicScopeWorktreeHeadBranch -Times 1 -Exactly -ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-coordinator' }
    }

    It 'denies an ambiguous epic target' {
        # Arrange
        Set-CodexTargetSeam -CheckpointText $script:ReadyEpicJson
        Mock Resolve-EpicScopeCheckpoint -ParameterFilter { $WorktreeSelector -eq '/synthetic-worktrees/epic-child' } {
            [pscustomobject]@{ IsEpicScope = $false; CheckpointPath = ''; Checkpoint = $null; WorktreeRoot = '/synthetic-worktrees/epic-child'; Branch = ''; MergeInProgress = $false; Reason = 'target-worktree-ambiguous' }
        }

        # Act
        $decision = Get-CodexTargetGateDecision -Command 'git -C /synthetic-worktrees/epic-child add scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'the selector target is ambiguous'
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ') | Should -BeTrue -Because 'every epic-scope deny keeps the gate prefix'
        $reason.Contains('target-ambiguous') | Should -BeTrue -Because 'the deny names target-ambiguous'
    }
}
