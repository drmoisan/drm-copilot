#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Regression rows pinning the existing merge-gate branches around the green-CI branch (issue #997).

.DESCRIPTION
    Each row asserts an outcome that held before issue #997 and must still hold after it: branch 1
    (epic child), the parallel allow-branch, the session-bound standalone authorization record
    (issue #670), the docs-only branch (issue #927), and the unedited
    Test-ChildCheckpointAllowsEpicMerge. Every decision row also asserts that the live-head seam
    is never called, behind an existence guard so the rows pass before the sibling exists. No row
    starts a process, runs git or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate existing branches around the green-CI branch (issue #997)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $itemRootValue = Join-Path '/synthetic-worktrees' 'item-997'
        $sessionRootValue = Join-Path '/synthetic-worktrees' 'session-997'
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item SessionRoot (issue #997)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #997)' } }
        $script:LiveHeadSeamExists = [bool](Get-Command Get-EpicMergeGateLivePrHeadSha -ErrorAction SilentlyContinue)
        if ($script:LiveHeadSeamExists) { Mock Get-EpicMergeGateLivePrHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' } }

        function Invoke-RegressionDecision {
            <#
            .SYNOPSIS
                Run the gate decision for one command with session id session-997.
            #>
            param([Parameter(Mandatory)][string] $Command)

            $envelope = @{ session_id = 'session-997'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
            return Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
        }

        function Assert-NoLiveHeadCall {
            <#
            .SYNOPSIS
                Assert the live-head seam was not called, when the seam exists.
            #>
            if ($script:LiveHeadSeamExists) { Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly -Scope It }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'branch 1 still allows epic_mode true with step9_status passed' {
        # Arrange
        Mock Get-ChildOrchestratorCheckpointContent { '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42}}' }

        # Act
        $decision = Invoke-RegressionDecision -Command 'gh pr merge 42 --merge'

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Assert-NoLiveHeadCall
    }

    It 'the parallel allow-branch still allows a ci_green item' {
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'item NoTarget (issue #997)' } }
        Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -eq 'parallel' } -MockWith { [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = '/synthetic-worktrees/parallel-997'; ReasonCode = $null; Detail = 'parallel OtherWorktree (issue #997)' } }
        Mock Get-ParallelOrchestratorCheckpointContent { '{"route_id":"parallel","items":[{"pr_number":42,"merge_status":"ci_green"}]}' }
        $decision = Invoke-RegressionDecision -Command 'gh pr merge 42 --merge'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Assert-NoLiveHeadCall
    }

    It 'a matching session-bound standalone_merge_authorizations record still allows a non-green checkpoint' {
        Mock Get-ChildOrchestratorCheckpointContent { '{"step9_status":"pending","standalone_merge_authorizations":[{"pr_number":42,"pr_url":"https://github.com/drmoisan/drm-copilot/pull/42","issue_num":997,"branch_name":"bug/standalone-orchestration-merge-on-green-997","authorized_by":"orchestrator","authorized_at":"2026-10-29T12:00:00Z","session_id":"session-997","basis":"Regression fixture for issue #997."}]}' }
        $decision = Invoke-RegressionDecision -Command 'gh pr merge 42 --merge'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Assert-NoLiveHeadCall
    }

    It 'the docs-only branch still allows when no checkpoint records the PR' {
        # The docs-only exemption requires an existing session directory, as in the DocsOnly suite.
        $existingRoot = $PSScriptRoot
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $existingRoot }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'item NoTarget (issue #997)' } }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
        Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = "docs/a.md`0" } }
        $decision = Invoke-RegressionDecision -Command 'gh pr merge 42 --merge'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
        Assert-NoLiveHeadCall
    }

    It 'Test-ChildCheckpointAllowsEpicMerge still returns false for epic_mode false' {
        $checkpoint = ConvertFrom-EpicMergeGateJson -Raw '{"epic_mode":false,"step9_status":"passed","ci_gate":{"conclusion":"success"}}'
        Test-ChildCheckpointAllowsEpicMerge -Checkpoint $checkpoint | Should -BeFalse
    }
}
