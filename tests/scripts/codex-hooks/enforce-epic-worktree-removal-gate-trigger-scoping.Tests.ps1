#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Codex epic worktree-removal gate (issue #545).

.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1.
    The scenario set and the `It` names are identical; the idiom differs.

    Codex decision-entry idiom: `Invoke-CodexWorktreeRemovalDecision` takes the FULL Codex
    stdin payload (`cwd`, `tool_name`, `tool_input.command`) plus the epic checkpoint text as
    a parameter, and returns `$null` for allow rather than an allow decision object. The
    Claude copy consumes a PreToolUse envelope and returns an explicit allow.

    One case is a preservation pin rather than a regression: the Codex pattern already
    handled the leading `--force` spelling through its optional `(?:\s+--force)?` group,
    which is the divergence AT-7 records against the two Claude extractors. That behaviour
    must survive the move onto the shared parser, so `resolves the operand when --force
    precedes the path` asserts it here for the same reason it asserts a fix on the Claude
    side.

    This file is NEW rather than an extension of
    tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, which is at 494 of its
    500 permitted lines.

    Determinism: every case drives the pure decision seam or a pure string function with
    literal fixtures, and the checkpoint arrives as a parameter rather than from disk. No
    disk I/O, no child process, no temporary file.
#>

Describe 'Codex enforce-epic-worktree-removal-gate trigger scoping (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'
        . $script:UnderTest

        $script:TargetPath = Join-Path $script:RepoRoot 'worktrees/item-a-101'
        $script:OtherPath = Join-Path $script:RepoRoot 'worktrees/item-b-102'

        # A checkpoint naming a DIFFERENT worktree, so nothing authorizes removing the target.
        $script:UnrelatedCheckpoint = @{
            features = @(
                @{ worktree_path = $script:OtherPath; merge_status = 'merged' }
            )
        } | ConvertTo-Json -Compress -Depth 4

        function ConvertTo-CodexWorktreeTriggerScopingPayload {
            <#
                Builds the full Codex stdin payload the decision seam consumes. The command
                text is carried verbatim so a fixture can exercise quoting and relocation
                exactly as the shell would present them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    cwd        = $script:RepoRoot
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }
    }

    Context 'under-match removal - a relocating spelling is now in scope' {
        It 'denies git -C /repo/main worktree remove against a checkpoint with no authorizing record' {
            $command = 'git -C "' + $script:RepoRoot + '" worktree remove "' + $script:TargetPath + '"'

            $decision = Invoke-CodexWorktreeRemovalDecision `
                -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) `
                -EpicCheckpointRaw $script:UnrelatedCheckpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'operand resolution - the --force flag never becomes the path' {
        It 'resolves the operand when --force precedes the path' {
            # Preservation pin. The previous pattern's optional (?:\s+--force)? group already
            # handled this spelling; the shared parser must not lose it.
            Get-CodexWorktreeRemovalPath -Command ('git worktree remove --force "' + $script:TargetPath + '"') |
                Should -Be $script:TargetPath
        }

        It 'resolves the same operand when --force follows the path' {
            Get-CodexWorktreeRemovalPath -Command ('git worktree remove "' + $script:TargetPath + '" --force') |
                Should -Be $script:TargetPath
        }
    }

    Context 'over-match removal and scope narrowing' {
        It 'allows a command whose quoted text merely mentions the removal phrase' {
            $command = 'echo "git worktree remove ' + $script:TargetPath + '" >> docs/runbook.md'

            Invoke-CodexWorktreeRemovalDecision `
                -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command $command) `
                -EpicCheckpointRaw $script:UnrelatedCheckpoint |
                Should -BeNullOrEmpty -Because 'the echo segment mentions the phrase and removes nothing'
        }

        It 'keeps git worktree list out of scope' {
            Invoke-CodexWorktreeRemovalDecision `
                -PayloadRaw (ConvertTo-CodexWorktreeTriggerScopingPayload -Command 'git worktree list --porcelain') `
                -EpicCheckpointRaw $script:UnrelatedCheckpoint |
                Should -BeNullOrEmpty -Because 'list is not the remove subcommand'
        }
    }
}
