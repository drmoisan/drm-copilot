#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping tests for enforce-epic-worktree-removal-gate.ps1 (issue #545).

.DESCRIPTION
    The gate used to decide scope by matching the raw command text against
    '\bgit\s+worktree\s+remove\b' and to extract its operand with
    '\bgit\s+worktree\s+remove\s+(?<path>\S+)'. Both produced defects of the issue #545
    class: a relocating spelling carrying a git global option between 'git' and 'worktree'
    was never gated at all, and the flag-before-path spelling captured the literal --force
    as the worktree path, which matches no checkpoint record and falsely denies a
    legitimate removal.

    This is a new sibling file. The existing suite,
    enforce-epic-worktree-removal-gate.Tests.ps1, is not extended: its 46 cases are the
    unchanged-behaviour pins that [P8-T4] re-runs.

    Determinism: every decision-level case mocks BOTH checkpoint read seams, so no case
    reads live orchestration state from disk. The operand cases call a pure string function
    that reads nothing. No temporary file is written and no process is run.
#>

Describe 'enforce-epic-worktree-removal-gate trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-CleanupWorktreeManifestContent -ModuleName CleanupWorktreeManifest { $null }
        Mock Get-EpicWorktreeGateCheckpointContent { $null }
        Mock Get-EpicWorktreeGateParallelCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

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
        Mock Resolve-EpicWorktreeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'under-match removal - a relocating spelling is now in scope' {
        BeforeEach {
            # The epic checkpoint names a DIFFERENT worktree, so nothing authorizes the
            # removal of item-a-101. The parallel checkpoint is absent.
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}'
            }
            Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { $null }
        }

        It 'denies git -C /repo/main worktree remove against a checkpoint with no authorizing record' {
            $command = 'git -C /repo/main worktree remove /repo/worktrees/item-a-101'

            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'operand resolution - the --force flag never becomes the path' {
        It 'resolves the operand when --force precedes the path' {
            (Resolve-CommandLineInvocationTarget -CommandText 'git worktree remove --force /repo/worktrees/item-a-101' -CommandWord 'git' -SubcommandPath @('worktree', 'remove')).Targets |
                Should -Be @('/repo/worktrees/item-a-101')
        }

        It 'resolves the same operand when --force follows the path' {
            (Resolve-CommandLineInvocationTarget -CommandText 'git worktree remove /repo/worktrees/item-a-101 --force' -CommandWord 'git' -SubcommandPath @('worktree', 'remove')).Targets |
                Should -Be @('/repo/worktrees/item-a-101')
        }
    }

    Context 'over-match removal and scope narrowing' {
        BeforeEach {
            # Both seams are absent, so anything this gate classifies denies. An allow
            # therefore proves the command was never classified.
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { $null }
        }

        It 'allows a command whose quoted text merely mentions the removal phrase' {
            $command = 'echo "git worktree remove /repo/worktrees/item-a-101" >> docs/runbook.md'

            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the echo segment mentions the phrase inside a quoted span and removes nothing'
        }

        It 'keeps git worktree list out of scope' {
            $command = 'git worktree list --porcelain'

            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw (ConvertTo-CommandEnvelope -Command $command)

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'list is not the remove subcommand'
        }
    }
}
