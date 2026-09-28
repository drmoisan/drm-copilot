#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Codex epic merge gate (issue #545).

.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1.

    Codex decision-entry idiom: `Invoke-CodexEpicMergeDecision` takes the FULL Codex stdin
    payload (`tool_name`, `tool_input.command`) plus the child and epic checkpoint texts as
    parameters, and returns `$null` for allow rather than an allow decision object. The
    Claude copy consumes a PreToolUse envelope and returns an explicit allow.

    One asymmetry is deliberate and is pinned here. The Codex copy has never carried the
    Claude copy's unanchored whole-text digit scan, and this change does not give it one.
    Its `cd`-prefixed case therefore records an ACQUISITION of correct behaviour rather than
    a repair: before this change the copy returned $null for the flag-led spelling, because
    its only pattern required the number to follow `merge` positionally.

    This file is NEW rather than an extension of
    tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1, which is at 494 of its
    500 permitted lines.

    Determinism: every case drives the pure decision seam or a pure string function with
    literal fixtures, and both checkpoints arrive as parameters rather than from disk. No
    disk I/O, no child process, no temporary file.
#>

Describe 'Codex enforce-epic-merge-gate trigger scoping (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1'
        . $script:UnderTest

        function ConvertTo-CodexMergeTriggerScopingPayload {
            <#
                Builds the full Codex stdin payload the decision seam consumes. The command
                text is carried verbatim so a fixture can exercise quoting and relocation
                exactly as the shell would present them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 4)
        }
    }

    Context 'PR-number resolution comes from the matched segment only' {
        It 'resolves 410 for the positional spelling gh pr merge 410 --merge' {
            Get-CodexMergeCommandPrNumber -Command 'gh pr merge 410 --merge' | Should -Be 410
        }

        It 'resolves 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag' {
            # The cd operand carries the four-digit token 2026. It is not an operand of the
            # merge segment, so it cannot be mistaken for a pull-request number.
            $commandText = 'cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688'
            Get-CodexMergeCommandPrNumber -Command $commandText | Should -Be 688
        }

        It 'returns null for a bare gh pr merge --merge that names no PR number' {
            Get-CodexMergeCommandPrNumber -Command 'gh pr merge --merge' | Should -BeNullOrEmpty
        }
    }

    Context 'scope filter separates a mention from an invocation' {
        It 'allows a quoted mention of the gated merge phrase' {
            # Both checkpoints are empty, so an in-scope command would necessarily deny.
            # The allow therefore depends on the scope filter alone.
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command 'printf ''%s\n'' "run gh pr merge --merge 688 once CI is green" >> notes.md'
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''
            $decision | Should -BeNullOrEmpty
        }

        It 'keeps a real gh pr merge --merge invocation in scope and denies it without a checkpoint' {
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command 'gh pr merge 410 --merge'
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''
            $decision | Should -Not -BeNullOrEmpty
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'R-2.a wrapper-led segments stay in scope' {
        # Every case in this context drives the pure decision seam with both checkpoint
        # texts supplied as empty parameters, so no case reads live orchestration state
        # from disk. An in-scope command therefore necessarily denies, and each
        # assertion turns on the scope filter alone.
        It 'R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument' {
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command 'bash -c "gh pr merge --merge 688"'
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''
            $decision | Should -Not -BeNullOrEmpty
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'R2a-X2 still allows a commit message quoting the merge phrase and the merge flag' {
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command 'git commit -m "gh pr merge --merge 688"'
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''
            $decision | Should -BeNullOrEmpty
        }
    }
}
