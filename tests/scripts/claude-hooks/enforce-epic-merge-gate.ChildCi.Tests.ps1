#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Epic-child CI verification rows for the Claude merge gate's branch 1 (issue #1130).

.DESCRIPTION
    Branch 1 of Invoke-EpicMergeGateDecision allows an epic-child merge only when the existing child
    predicates hold and Get-EpicMergeGateChildCiDecision verifies a green CI run on the live head of
    the child pull request. The decision rows drive Invoke-EpicMergeGateDecision with mocked
    checkpoint-content and resolution seams. No row starts a process, runs git or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate epic-child CI verification (issue #1130)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
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

        $itemRootValue = Join-Path '/synthetic-worktrees' 'item-1130'
        $sessionRootValue = Join-Path '/synthetic-worktrees' 'session-1130'
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item SessionRoot (issue #1130)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1130)' } }
        Mock Get-EpicMergeGateLivePrHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }

        function Invoke-ChildCiDecision {
            <#
            .SYNOPSIS
                Run the gate decision for one command with session id session-1130.
            #>
            param([Parameter(Mandatory)][string] $Command)

            $envelope = @{ session_id = 'session-1130'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
            return Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
        }
    }

    Context 'regression: epic child with no CI record' {
        It 'CHILD-CI-NO-CI-GATE denies gh pr merge 42 --merge for an epic child with step9_status passed and no ci_gate' {
            # Arrange: the checkpoint satisfies every pre-#1130 branch-1 predicate but records no CI run.
            Mock Get-ChildOrchestratorCheckpointContent { '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42}}' }

            # Act
            $decision = Invoke-ChildCiDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "an epic child needs a verified CI run (observed decision: $($decision.hookSpecificOutput.permissionDecision); reason: $reason)"
            $reason | Should -Match 'EPIC_CHILD_CI_NOT_VERIFIED'
        }
    }
}
