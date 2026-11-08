#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Codex preimplementation gate post-fan-in allowance rows (issue #1136).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision of
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 with the mapped Codex
    tool_input JSON for the writes the epic orchestrator and pr-author make on the epic
    integration branch after fan-in: the pr-author body and receipt (path and apply_patch
    legs) and the epic status document commit (command leg). The epic checkpoint is fan-in
    complete and no merge is in progress, so the readiness predicate fails with
    'merge-in-progress' and only the allowlisted operations are admitted.

    The fixtures follow enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1: the
    resolver seams Find-WorktreeResolutionRoot, Get-EpicScopeCheckpointText,
    Get-EpicScopeWorktreeHeadBranch, and Test-EpicScopeMergeInProgress are mocked by name, the
    ascent maps the session root and any path under /synthetic-worktrees/epic-coordinator to
    that root, and the staged index is read through the mocked
    Get-OrchestrationGateStagedIndex seam. Every gate call passes -CheckpointRaw. No row creates
    a file or changes the working directory.
#>

Describe 'Codex preimplementation gate post-fan-in allowance (issue #1136)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:FanInEpicJson = '{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}]}'
        $script:NotReadySingleFeature = '{"issue-num":"1136","route_id":"large","lifecycle_ready":false}'
        $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
        $script:StatusDoc = 'docs/features/epics/sample-epic/epic-status.md'
        $script:ReceiptPatch = "*** Begin Patch`n*** Add File: artifacts/pr_body_7.receipt.json`n+{}`n*** End Patch"

        function Set-EpicScopeSeam {
            <#
                Mock the four resolver seams for one test. Value bodies close over local
                copies; the ascent body is plain so it sees the bound -Path argument.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param(
                [AllowNull()] [object] $CheckpointText,
                [string] $HeadBranch = 'epic/sample-epic-integration'
            )
            $text = $CheckpointText
            $head = $HeadBranch
            Mock Find-WorktreeResolutionRoot {
                if ($Path -like '/synthetic-worktrees/epic-coordinator*') { return '/synthetic-worktrees/epic-coordinator' }
                if ($Path -like '/synthetic-worktrees/*') { return $Path }
                return '/synthetic-worktrees/epic-coordinator'
            }
            Mock Get-EpicScopeCheckpointText -MockWith ({ $text }.GetNewClosure())
            Mock Get-EpicScopeWorktreeHeadBranch -MockWith ({ $head }.GetNewClosure())
            Mock Test-EpicScopeMergeInProgress -MockWith { $false }
        }

        function Set-StagedIndexSeam {
            # Mock the staged-index read to return exactly the status document.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param()
            $text = $script:StatusDoc + [char]0
            Mock Get-OrchestrationGateStagedIndex -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $text } }.GetNewClosure())
        }

        function Get-FanInFixtureText {
            # Return the epic checkpoint text of one fixture kind.
            param([Parameter(Mandatory)] [string] $Kind)
            $checkpoint = $script:FanInEpicJson | ConvertFrom-Json
            switch ($Kind) {
                'fan-in' { }
                'pr-open' { $checkpoint.features[1].merge_status = 'pr_open' }
                'blank-manifest' { $checkpoint.epic_manifest_path = '' }
                default { throw "Unknown fixture kind '$Kind'." }
            }
            return ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'allows' {
        It 'allows <Case>' -ForEach @(
            @{ Case = 'a receipt Write with a relative path'; ToolInput = @{ file_path = 'artifacts/pr_body_7.receipt.json' } }
            @{ Case = 'a receipt Write with an absolute path into the integration worktree'; ToolInput = @{ file_path = '/synthetic-worktrees/epic-coordinator/artifacts/pr_body_7.receipt.json' } }
            @{ Case = 'a Write of artifacts/pr_body_7.md'; ToolInput = @{ file_path = 'artifacts/pr_body_7.md' } }
            @{ Case = 'an apply_patch adding artifacts/pr_body_7.receipt.json'; ToolInput = 'receipt-patch' }
            @{ Case = 'git add of the status doc'; ToolInput = @{ command = 'git add docs/features/epics/sample-epic/epic-status.md' } }
            @{ Case = 'a pathless git commit -m with the staged index exactly the status doc'; ToolInput = @{ command = 'git commit -m status' } }
            @{ Case = 'git -C with the integration root and commit -m with the staged index exactly the status doc'; ToolInput = @{ command = 'git -C /synthetic-worktrees/epic-coordinator commit -m status' } }
            @{ Case = 'git commit -F with no pathspec and the staged index exactly the status doc'; ToolInput = @{ command = 'git commit -F /scratch/msg.txt' } }
            @{ Case = 'git commit -F with the status doc pathspec'; ToolInput = @{ command = 'git commit -F /scratch/msg.txt -- docs/features/epics/sample-epic/epic-status.md' } }
        ) {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson
            Set-StagedIndexSeam
            $mapped = if ($ToolInput -eq 'receipt-patch') { @{ command = $script:ReceiptPatch } } else { $ToolInput }

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ($mapped | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "$Case is a sanctioned post-fan-in write (decision reason: $reason)"
        }
    }

    Context 'denies' {
        It 'denies a receipt Write when a feature is not merged and names merge-in-progress' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FanInFixtureText -Kind 'pr-open')

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ file_path = 'artifacts/pr_body_7.receipt.json' } | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.Contains("'merge-in-progress'") | Should -BeTrue
        }

        It 'denies a Write of a production path outside the allowlist and names merge-in-progress' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ file_path = 'scripts/powershell/Sample.ps1' } | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason.Contains("'merge-in-progress'") | Should -BeTrue
        }

        It 'returns the unchanged single-feature deny for a receipt Write when HEAD is not the integration_branch' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText $script:FanInEpicJson -HeadBranch 'feature/standalone-item'

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ file_path = 'artifacts/pr_body_7.receipt.json' } | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
        }

        It 'denies a receipt Write when the readiness failure is epic_manifest_path rather than merge-in-progress' {
            # Arrange: fan-in complete with slug sample-epic, but a blank epic_manifest_path.
            Set-EpicScopeSeam -CheckpointText (Get-FanInFixtureText -Kind 'blank-manifest')

            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ file_path = 'artifacts/pr_body_7.receipt.json' } | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature

            # Assert: the allowance applies only to the exact merge-in-progress failure.
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason.Contains("'epic_manifest_path'") | Should -BeTrue
            $reason.Contains("'merge-in-progress'") | Should -BeFalse
        }
    }
}
