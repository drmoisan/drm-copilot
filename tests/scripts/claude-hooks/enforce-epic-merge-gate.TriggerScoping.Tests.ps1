#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping tests for .claude/hooks/enforce-epic-merge-gate.ps1 (issue #545).
.DESCRIPTION
    Pins the two behaviours the shared command-line parser gives this gate:

      1. The pull-request number is read from the segment that structurally invokes
         gh pr merge, in every spelling, rather than from the whole command line.
      2. A command that merely MENTIONS the gated phrase is out of scope, while a
         real invocation carrying a gh global option stays in scope.

    Determinism rules for this suite:
      - Every case drives a pure decision seam directly. No temporary file, no child
        process, and no live executable is used.
      - Every decision-level case mocks all three checkpoint read seams, so no case
        reads live orchestration state from disk. Without that, a case would pass or
        fail depending on whether an orchestration run happened to be in flight.
      - The extractor cases call a pure string function that reads nothing at all.
#>

Describe 'enforce-epic-merge-gate.ps1 trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-MergeGateEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command string in the PreToolUse envelope the hook reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

            return (@{ tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }
    }

    Context 'PR-number extraction comes from the matched segment only' {
        It 'returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag' {
            # The cd operand carries the four-digit token 2026. The deleted whole-line
            # digit scan returned 2026 and denied a correct, CI-green merge.
            $commandText = 'cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688'
            Get-EpicMergeGateCommandPrNumber -CommandText $commandText | Should -Be 688
        }

        It 'returns null for a bare gh pr merge --merge that names no PR number' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge' | Should -BeNullOrEmpty
        }

        It 'returns 410 for the positional spelling gh pr merge 410 --merge' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge 410 --merge' | Should -Be 410
        }

        It 'returns 410 for the equals-joined spelling gh pr merge --merge=410' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge=410' | Should -Be 410
        }
    }

    Context 'scope filter separates a mention from an invocation' {
        It 'allows a printf whose double-quoted text mentions the gated merge phrase' {
            # All three checkpoint seams return null, so an in-scope command would
            # necessarily deny. The allow therefore depends on the scope filter alone.
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $envelope = ConvertTo-MergeGateEnvelope -Command 'printf ''%s\n'' "run gh pr merge --merge 688 once CI is green" >> notes.md'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'keeps gh --repo drmoisan/drm-copilot pr merge --merge 688 in scope' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $envelope = ConvertTo-MergeGateEnvelope -Command 'gh --repo drmoisan/drm-copilot pr merge --merge 688'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'the false-allow direction of the whole-line PR-number defect' {
        # This context pins the UNAUTHORIZED-MERGE direction of the defect, which the
        # cd-prefixed case above does not exercise. That case uses a cd path component
        # matching no authorized item, so it only exercises the fail-closed direction.
        # Here the cd path component IS an authorized item number and the merge operand
        # is a DIFFERENT, unauthorized pull request. Before the fix the whole-line scan
        # returned the authorized 501, the parallel branch matched item 501 at ci_green,
        # and the gate permitted merging PR 777. Executed pre-change observation:
        # the extractor returned 501 and the decision was allow.
        BeforeAll {
            $script:FalseAllowCommand = 'cd /repo/worktrees/501 && gh pr merge --merge 777'
        }

        It 'takes the PR number from the merge operand 777, not from the authorized item number 501 in the cd path' {
            Get-EpicMergeGateCommandPrNumber -CommandText $script:FalseAllowCommand | Should -Be 777
        }

        It 'denies merging unauthorized PR 777 even though authorized item 501 appears earlier on the line' {
            # Item table: 501 is authorized (merge_status ci_green); 777 is NOT
            # authorized (merge_status pr_open). Only the parallel checkpoint is
            # populated, so the decision turns on which number the gate extracted.
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"item_id":"item-501","pr_number":501,"merge_status":"ci_green"},{"item_id":"item-777","pr_number":777,"merge_status":"pr_open"}]}'
            }

            $envelope = ConvertTo-MergeGateEnvelope -Command 'cd /repo/worktrees/501 && gh pr merge --merge 777'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'still allows merging the authorized PR 501 when 501 is the merge operand' {
            # Complement of the case above: the fix must not deny an authorized merge.
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"item_id":"item-501","pr_number":501,"merge_status":"ci_green"},{"item_id":"item-777","pr_number":777,"merge_status":"pr_open"}]}'
            }

            $envelope = ConvertTo-MergeGateEnvelope -Command 'cd /repo/worktrees/501 && gh pr merge --merge 501'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
