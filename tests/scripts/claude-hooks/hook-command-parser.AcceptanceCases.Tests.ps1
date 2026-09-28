#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Acceptance cases AT-1 through AT-7 for issue #545, plus their paired negatives.

.DESCRIPTION
    Issue #545 records one defect class shared by the Bash-classifying hook family:
    classification by regex or substring match over raw command text, with no notion
    of where a command begins and no awareness of quoting. The class produces two
    opposite failures - an over-match that denies text merely MENTIONING a governed
    token, and an under-match that never classifies a governed command whose
    subcommand is not adjacent to its command name.

    Every case in this file is drawn from the Test Strategy table of
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md.
    They are deliberately kept in ONE file rather than split per hook, because AT-6
    is the deny-preservation pin: it passes today and it is the assertion that
    breaks if the issue #539 D8 fail-open objection is answered wrongly. Keeping it
    beside AT-1 through AT-5 and AT-7 makes a fail-open regression visible in one
    place.

    Expected state BEFORE the fix: AT-1, AT-2, AT-3, AT-4, AT-5, and AT-7 fail.
    AT-6 and all four paired negatives pass. Expected state AFTER the fix: all
    eleven pass.

    Determinism rules for this suite:
      - Every case drives a pure decision seam directly. No temporary file, no
        child process, and no live executable is used.
      - Every checkpoint fixture is a literal JSON string injected through a mocked
        read seam, so no test reads live orchestration state from disk. A
        decision-level case that left a checkpoint seam unmocked would pass or fail
        depending on whether an orchestration run happened to be in flight.
      - Helper-level cases (AT-2, AT-3, AT-5, AT-7 and the paired negatives) call
        pure string functions that read nothing at all, so they need no mock.
#>

Describe 'hook-command-parser acceptance cases (issue #545)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path

        # Dot-sourcing each hook stops at its own entry-point guard, so only the
        # function definitions are imported. Verified before this suite was
        # written: the five hooks below declare 76 functions between them with
        # zero name collisions, so importing all five into one scope cannot make a
        # Mock ambiguous.
        . (Join-Path $script:HookRoot 'enforce-epic-worktree-removal-gate.ps1')
        . (Join-Path $script:HookRoot 'enforce-parallel-worktree-removal-gate.ps1')
        . (Join-Path $script:HookRoot 'enforce-epic-merge-gate.ps1')
        . (Join-Path $script:HookRoot 'enforce-promotion-mcp-only.ps1')
        . (Join-Path $script:HookRoot 'enforce-orchestration-preimplementation-gate.ps1')

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

    Context 'AT-1 - the mandatory latent-bypass case' {
        It 'AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record' {
            # Arrange: the checkpoint names a DIFFERENT worktree, so nothing
            # authorizes the removal of item-a-101. Both read seams are mocked so
            # the case cannot consult live orchestration state.
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}'
            }
            Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { $null }

            # The -C /repo/main global option separates 'git' from 'worktree
            # remove'. The current scope filter requires adjacency, so it does not
            # match and the gate returns allow: an unauthorized destructive removal
            # proceeds with no checkpoint check at all.
            $envelope = ConvertTo-CommandEnvelope -Command 'git -C /repo/main worktree remove /repo/worktrees/item-a-101'

            # Act
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $envelope

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'AT-2 - the issue #591 operand mis-parse' {
        It 'AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag' {
            # Arrange: the directory operand contains the four-digit token 2026.
            # The current unanchored branch rescans the WHOLE command text for a
            # digit run, and the backslash before 2026 does not satisfy the
            # (?<![-\w]) lookbehind, so 2026 is returned as the pull-request number
            # and a correct, CI-green merge is denied.
            $commandText = 'cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688'

            # Act + Assert: the number must come from the MATCHED segment only.
            Get-EpicMergeGateCommandPrNumber -CommandText $commandText | Should -Be 688
        }
    }

    Context 'AT-3 - the promotion-hook over-match on receipt values' {
        It 'AT-3 allows a heredoc whose JSON body names promotion tools as receipt values' {
            # Arrange: a checkpoint write. The orchestrator-state schema REQUIRES
            # the promotion tool names to appear as values of required_mcp_tools,
            # so the write and the gate are individually reasonable and jointly
            # unsatisfiable today. Nothing on this line executes a promotion tool.
            $commandText = @'
cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
{
  "route_id": "epic",
  "required_mcp_tools": [
    "new_potential_bug_entry",
    "potential_to_issue",
    "new_active_feature_folder"
  ]
}
JSON
'@

            # Act + Assert: a token inside a heredoc body is a mention, never an
            # invocation, so the reason must be $null.
            Get-PromotionBypassReason -CommandText $commandText | Should -BeNullOrEmpty
        }
    }

    Context 'AT-4 - the merge-gate over-match on quoted prose' {
        It 'AT-4 allows a printf whose double-quoted text mentions the gated merge phrase' {
            # Arrange: all three checkpoint seams are mocked to $null, so if the
            # command were in scope the gate would necessarily deny. That makes the
            # allow assertion depend on the scope filter alone.
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            # printf writes text to a file. No pull request is merged.
            $envelope = ConvertTo-CommandEnvelope -Command 'printf ''%s\n'' "run gh pr merge --merge 688 once CI is green" >> notes.md'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'AT-5 - the promotion-hook gh relocation bypass' {
        It 'AT-5 blocks a relocating gh issue create spelling that carries a repo global option' {
            # Arrange: the --repo global option separates gh from its issue
            # subcommand, so the adjacency-requiring expression does not match and
            # a raw issue creation proceeds ungated today.
            $commandText = 'gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"'

            # Act
            $reason = Get-PromotionBypassReason -CommandText $commandText

            # Assert: the gh-issue reason, not the legacy promotion-script reason.
            $reason | Should -Not -BeNullOrEmpty
            $reason | Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }
    }

    Context 'AT-6 - the wrapper deny pin' {
        It 'AT-6 still classifies a pwsh -Command wrapper carrying a test invocation' {
            # This case PASSES today and must keep passing. A wrapper's quoted
            # argument is a nested command line, so it must stay visible to the
            # trigger patterns. If this case ever fails, the masking model has been
            # applied to a wrapper-led segment and the issue #539 D8 fail-open
            # objection has been answered wrongly.
            Test-ImplementationCommand -Command 'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"' |
                Should -BeTrue
        }
    }

    Context 'AT-7 - the cross-runtime operand divergence' {
        It 'AT-7 resolves the worktree path when the force flag precedes it, in both removal gates' {
            # Arrange: the flag-BEFORE-path spelling. Both Claude extractors
            # capture the literal --force as the worktree path today, which matches
            # no checkpoint record and falsely denies a legitimate removal. The
            # Codex copy of the epic gate already handles this spelling, so the two
            # runtimes have silently diverged.
            $commandText = 'git worktree remove --force /repo/worktrees/item-a-101'

            # Act + Assert: both gates must resolve the same path.
            Get-ParallelWorktreeRemovalCommandPath -CommandText $commandText |
                Should -Be '/repo/worktrees/item-a-101'
            Get-EpicWorktreeRemovalCommandPath -CommandText $commandText |
                Should -Be '/repo/worktrees/item-a-101'
        }
    }

    Context 'paired negatives that must hold alongside the acceptance cases' {
        It 'paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null' {
            # Issue #591 constraint 1. Downstream logic treats a missing explicit
            # pull-request number as a fail-closed condition, so this must be
            # $null, never 0 and never an empty string.
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge' | Should -BeNullOrEmpty
        }

        It 'paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410' {
            # Issue #591 constraint 2. The anchored spelling must not regress while
            # the unanchored branch is replaced.
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge 410 --merge' | Should -Be 410
        }

        It 'paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason' {
            # The over-match removal must not weaken the denial of a real
            # invocation. This is an execution, not a mention.
            $reason = Get-PromotionBypassReason -CommandText 'pwsh ./scripts/new-potential-entry.ps1 -ShortName foo'
            $reason | Should -Not -BeNullOrEmpty
            $reason | Should -Be (Get-PromotionMcpOnlyBlockedReason)
        }

        It 'paired negative for AT-5: a relocating gh issue list spelling still returns $null' {
            # The structural gh classifier must match the issue-creation
            # subcommands only. A read operation stays ungated.
            Get-PromotionBypassReason -CommandText 'gh --repo drmoisan/drm-copilot issue list' | Should -BeNullOrEmpty
        }
    }
}
