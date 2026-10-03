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
        Mock Resolve-ParallelWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
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

    Context 'issue #824 - wrapper-led removal classification' {
        BeforeEach {
            # The seam is absent, so any classified command denies.
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith { $null }
        }

        It 'A824-WT1 allows a wrapped git worktree list whose filter text carries removed' -Tag 'Issue824' {
            $command = 'pwsh -NoProfile -Command ''git worktree list --porcelain | Select-String -NotMatch "removed"'''

            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'removed is not the token remove, and list is not the remove subcommand'
        }

        It 'A824-WT2 still denies git worktree remove carried inside a bash -c argument' -Tag 'Issue824' {
            $command = 'bash -c "git worktree remove ../x"'

            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^PARALLEL_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'issue #824 addendum 1 - no authorizing record' {
        BeforeAll {
            $script:AddendumReproduction = @'
pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'
'@
        }

        BeforeEach {
            # The checkpoint names a DIFFERENT worktree, so nothing authorizes the removal
            # of item-a-101. The epic checkpoint is absent.
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":102,"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}'
            }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { $null }
        }

        It 'A824-WT3 allows the addendum reproduction even though raw containment matches it' -Tag 'Issue824' {
            # Arrange
            $command = $script:AddendumReproduction

            # Act
            $containment = Test-CommandLineRawContainment -RawText $command -CommandWord 'git' -SubcommandPath @('worktree', 'remove')
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            # Assert
            $containment | Should -BeTrue -Because 'the negative control: containment-based R2 would classify this text'
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'no token-bounded git worktree remove sequence occurs in the wrapped payload'
        }

        It 'A824-WT4-<Id> denies <Label> without an authorizing record' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'git worktree remove /repo/worktrees/item-a-101'; Command = 'git worktree remove /repo/worktrees/item-a-101' }
            @{ Id = 2; Label = 'git worktree remove --force /repo/worktrees/item-a-101'; Command = 'git worktree remove --force /repo/worktrees/item-a-101' }
            @{ Id = 3; Label = 'git -C /repo/main worktree remove /repo/worktrees/item-a-101'; Command = 'git -C /repo/main worktree remove /repo/worktrees/item-a-101' }
            @{ Id = 4; Label = 'pwsh -Command ''git worktree remove /repo/worktrees/item-a-101'''; Command = 'pwsh -Command ''git worktree remove /repo/worktrees/item-a-101''' }
            @{ Id = 5; Label = 'bash -c "git worktree remove /repo/worktrees/item-a-101"'; Command = 'bash -c "git worktree remove /repo/worktrees/item-a-101"' }
        ) {
            # Arrange: $Command comes from the -ForEach row.

            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^PARALLEL_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'A824-WT6 allows a wrapped removal that names no operand' -Tag 'Issue824' {
            # Arrange
            $command = 'pwsh -NoProfile -Command ''git worktree remove'''

            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a wrapped removal that names no operand removes nothing'
        }

        It 'A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove' -Tag 'Issue824' {
            # Arrange
            $command = 'pwsh -c ''Write-Host "$path worktree remove"'''

            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'an expansion in the command position needs a token-bounded git elsewhere in the raw text'
        }
    }

    Context 'issue #824 addendum 1 - authorizing record present' {
        BeforeEach {
            # The checkpoint authorizes the removal of item-a-101.
            Mock -CommandName Get-ParallelWorktreeRemovalGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":101,"worktree_path":"/repo/worktrees/item-a-101","merge_status":"merged"}]}'
            }
            Mock -CommandName Get-ParallelWorktreeRemovalGateEpicCheckpointContent -MockWith { $null }
        }

        It 'A824-WT5-<Id> allows <Label> with an authorizing record' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'git worktree remove /repo/worktrees/item-a-101'; Command = 'git worktree remove /repo/worktrees/item-a-101' }
            @{ Id = 2; Label = 'git worktree remove --force /repo/worktrees/item-a-101'; Command = 'git worktree remove --force /repo/worktrees/item-a-101' }
            @{ Id = 3; Label = 'git -C /repo/main worktree remove /repo/worktrees/item-a-101'; Command = 'git -C /repo/main worktree remove /repo/worktrees/item-a-101' }
            @{ Id = 4; Label = 'pwsh -Command ''git worktree remove /repo/worktrees/item-a-101'''; Command = 'pwsh -Command ''git worktree remove /repo/worktrees/item-a-101''' }
            @{ Id = 5; Label = 'bash -c "git worktree remove /repo/worktrees/item-a-101"'; Command = 'bash -c "git worktree remove /repo/worktrees/item-a-101"' }
        ) {
            # Arrange: $Command comes from the -ForEach row.

            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $Command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the checkpoint carries a merged record for the removed worktree'
        }

        It 'A824-WT7 denies an unbalanced wrapped removal even with an authorizing record' -Tag 'Issue824' {
            # Arrange
            $command = 'bash -c "git worktree remove /repo/worktrees/item-a-101'

            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an unbalanced segment stays fail-closed'
        }

        It 'A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record' -Tag 'Issue824' {
            # Arrange
            $command = 'bash -c ''a="worktree remove"; git $a /repo/worktrees/item-a-101'''

            # Act
            $decision = Invoke-ParallelWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an indeterminate operand keeps the structural path and is denied'
        }
    }
}
