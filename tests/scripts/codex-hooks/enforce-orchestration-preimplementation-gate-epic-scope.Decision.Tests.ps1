#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Codex epic-scope decision tail rows (issue #903 remediation RI-2).

.DESCRIPTION
    The suite dot-sources .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
    directly (which loads its epic-resolution and targets siblings) and mocks
    Resolve-EpicScopeCheckpoint so the session-root scope is an in-memory epic scope. The gate
    file is not loaded, so the suite defines in-memory stand-ins for the two gate decision
    constructors Get-OrchestrationPreimplementationGateBlockDecision and
    Get-OrchestrationPreimplementationGateAllowDecision. Each row uses a relative path leg, so
    the only target is the session root. No row creates a file or starts a process.

    Coverage attribution note (issue #936). ES-D1 executes lines 206 and 207 of
    .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1, and ES-D2
    executes lines 206 and 209. ES-D1 makes the exact-reason assertion: its deny decision is
    built only by the stand-in block constructor, which only line 207 calls. A full-run CI
    coverage report can still show lines 183, 190, 191, 206, 207, and 209 of that function
    with ci="0"; other Codex suites reach lines 183, 190, and 191. The likely cause is
    Pester 5.x breakpoint mode: each line breakpoint binds to the first compiled instance of
    a script, and a later recompilation of the unchanged file leaves later executions of
    those lines unattributed. A coverage run scoped to tests/scripts/codex-hooks attributes
    lines 206 and 207; the #936 evidence records both results.
#>

Describe 'Codex epic-scope decision tail (issue #903)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Get-CheckpointContent -ErrorAction SilentlyContinue) { Mock Get-CheckpointContent { $null } }
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:ReadyEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}'
        $script:CheckpointPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'

        function Get-OrchestrationPreimplementationGateBlockDecision {
            # In-memory stand-in for the gate's block decision constructor.
            param([Parameter(Mandatory)] [string] $Reason)
            return [ordered]@{
                hookSpecificOutput = [ordered]@{
                    hookEventName            = 'PreToolUse'
                    permissionDecision       = 'deny'
                    permissionDecisionReason = $Reason
                }
            }
        }

        function Get-OrchestrationPreimplementationGateAllowDecision {
            # In-memory stand-in for the gate's allow decision constructor.
            return [ordered]@{
                hookSpecificOutput = [ordered]@{
                    hookEventName      = 'PreToolUse'
                    permissionDecision = 'allow'
                }
            }
        }

        function Set-DecisionScope {
            <#
                Mock Resolve-EpicScopeCheckpoint for one test with a ready epic scope whose
                merge-in-progress flag is the argument.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([bool] $MergeInProgress)
            $scope = [pscustomobject]@{
                IsEpicScope     = $true
                CheckpointPath  = $script:CheckpointPath
                Checkpoint      = ($script:ReadyEpicJson | ConvertFrom-Json)
                WorktreeRoot    = '/synthetic-worktrees/epic-coordinator'
                Branch          = 'epic/sample-epic-integration'
                MergeInProgress = $MergeInProgress
                Reason          = 'epic-scope'
            }
            Mock Resolve-EpicScopeCheckpoint -MockWith ({ $scope }.GetNewClosure())
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    It 'ES-D1 denies a path leg whose session-root epic scope has no merge in progress' {
        # Arrange
        Set-DecisionScope -MergeInProgress $false

        # Act
        $decision = Get-OrchestrationEpicScopeDecision -Command '' -FilePath 'scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because 'a ready epic scope without a merge in progress denies a production path (D2)'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly "PREIMPLEMENTATION_GATE_BLOCKED: this epic-scope operation was evaluated against /synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json, and the failed readiness predicate is 'merge-in-progress'. Implementation operations in epic scope require that checkpoint to satisfy every readiness predicate, and a production path may be staged or edited only while a merge is in progress."
        Should -Invoke Resolve-EpicScopeCheckpoint -Times 1 -Exactly
    }

    It 'ES-D2 allows a path leg whose session-root epic scope has a merge in progress' {
        # Arrange
        Set-DecisionScope -MergeInProgress $true

        # Act
        $decision = Get-OrchestrationEpicScopeDecision -Command '' -FilePath 'scripts/powershell/Sample.ps1'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because 'a ready epic scope with a merge in progress admits a production path (D2)'
    }
}
