#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping tests for enforce-parallel-worktree-removal-gate.ps1 (issue #545).

.DESCRIPTION
    This gate fires on the same command as enforce-epic-worktree-removal-gate.ps1 and
    carried a byte-identical copy of that gate's raw-text scope filter and operand pattern,
    so it carried both directions of the issue #545 defect as well: a relocating spelling
    carrying a git global option was never gated, and the flag-before-path spelling captured
    the literal --force as the worktree path. [P8-T10] moves both call sites onto the same
    shared parser calls the epic gate now makes.

    This is a new sibling file. The existing suite,
    enforce-parallel-worktree-removal-gate.Tests.ps1, is not extended: its 45 cases are the
    unchanged-behaviour pins that [P8-T13] re-runs, including
    `allows git worktree remove --force when the matching record has merge_status merged`.

    Determinism: the decision-level cases mock the checkpoint read seam, so no case reads
    live orchestration state from disk. The operand case calls a pure string function that
    reads nothing. No temporary file is written and no process is run.
#>

Describe 'enforce-parallel-worktree-removal-gate trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-CommandEnvelope {
            <#
            .SYNOPSIS
                Builds a PreToolUse Bash envelope carrying one command string.
            #>
            param(
                [Parameter(Mandatory)]
                [AllowEmptyString()]
                [string] $Command
            )

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    Context 'operand resolution - the --force flag never becomes the path' {
        It 'resolves the operand when --force precedes the path' {
            # The AT-7 half this gate owns. The previous pattern returned the literal
            # --force, which matches no recorded worktree_path and falsely denies a
            # legitimate removal.
            Get-ParallelWorktreeRemovalCommandPath -CommandText 'git worktree remove --force /repo/worktrees/item-a-101' |
                Should -Be '/repo/worktrees/item-a-101'
        }
    }

    Context 'under-match removal - a relocating spelling is now in scope' {
        It 'brings git -C /repo/main worktree remove into scope' {
            # The checkpoint names a DIFFERENT worktree, so nothing authorizes removing
            # item-a-101 and an in-scope command must deny.
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":102,"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}'
            }
            $command = 'git -C /repo/main worktree remove /repo/worktrees/item-a-101'

            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^PARALLEL_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'over-match removal - a quoted mention is not an invocation' {
        It 'takes a quoted mention of the removal phrase out of scope' {
            # The seam is absent, so anything this gate classifies denies. An allow
            # therefore proves the command was never classified.
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
            $command = 'echo "git worktree remove /repo/worktrees/item-a-101" >> docs/runbook.md'

            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the echo segment mentions the phrase inside a quoted span and removes nothing'
        }
    }
}
