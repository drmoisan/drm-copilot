#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the epic-authorization branch of the
    enforce-parallel-worktree-removal-gate.ps1 PreToolUse hook (issue #688).

.DESCRIPTION
    Split from enforce-parallel-worktree-removal-gate.Tests.ps1 to keep both files
    under the repository's 500-line cap for test code.

    Both checkpoint read seams are mocked in every test:
    Get-ParallelWorktreeRemovalGateCheckpointContent for the parallel checkpoint and
    Get-ParallelWorktreeRemovalGateEpicCheckpointContent for the epic checkpoint. No
    test reads real orchestration state and no test writes a temporary file, so the
    suite is deterministic regardless of live orchestration state.

    Deny assertions use -BeLike with a trailing wildcard so the required
    PARALLEL_WORKTREE_REMOVAL_BLOCKED token is verified as a prefix.
#>

Describe 'enforce-parallel-worktree-removal-gate.ps1 epic authorization' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
        . $script:UnderTest
    }

    Context 'epic authorization branch (issue #688)' {
        # Before this branch existed, every case below denied: the parallel checkpoint has no
        # record for an epic child, so the gate fell through even though
        # enforce-epic-worktree-removal-gate.ps1 authorized the same call from the epic
        # checkpoint's features[] record. Both gates run on one Bash call, so that deny won.

        It 'allows when an epic features[] record matches and merge_status is merged' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":669,"worktree_path":"/repo/worktrees/agent-epic-child","merge_status":"merged"}]}'
            }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the epic record merge_status is worktree_removed' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":669,"worktree_path":"/repo/worktrees/agent-epic-child","merge_status":"worktree_removed"}]}'
            }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when a parallel checkpoint exists but does not cover the target' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":669,"worktree_path":"/repo/worktrees/agent-epic-child","merge_status":"merged"}]}'
            }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'normalizes backslash paths in an epic features[] record' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"C:\\repo\\worktrees\\agent-epic-child","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove C:/repo/worktrees/agent-epic-child"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when the epic record merge_status is not terminal' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":669,"worktree_path":"/repo/worktrees/agent-epic-child","merge_status":"in_progress"}]}'
            }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }

        It 'denies when the epic record has no merge_status field' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":669,"worktree_path":"/repo/worktrees/agent-epic-child"}]}'
            }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }

        It 'denies when the epic checkpoint covers a different worktree' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":670,"worktree_path":"/repo/worktrees/agent-other","merge_status":"merged"}]}'
            }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }

        It 'denies fail-closed when the epic checkpoint is unparseable' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { '{ broken json' }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }

        It 'denies fail-closed when the epic checkpoint is absent' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { $null }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }

        It 'denies when the epic checkpoint has no features array' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { '{"items":[]}' }
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree remove /repo/worktrees/agent-epic-child"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }

        It 'still denies an unmerged parallel item even when an epic record exists for another path' {
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"in_progress"}]}'
            }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith {
                '{"features":[{"issue_num":669,"worktree_path":"/repo/worktrees/agent-epic-child","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/item-a-101"}}'
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'
        }
    }
}
