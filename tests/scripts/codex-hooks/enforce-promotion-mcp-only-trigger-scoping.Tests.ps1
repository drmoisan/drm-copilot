#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Codex promotion gate (issue #545).

.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1.
    The scenario set is identical; the idiom differs.

    Codex decision-entry idiom: the Codex copy of `Invoke-PromotionMcpOnlyDecision`
    accepts the MAPPED tool_input JSON directly (for example `{"command":"..."}`),
    not the outer PreToolUse envelope the Claude copy consumes.

    This file is NEW rather than an extension of
    `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, which is at 494
    of its 500 permitted lines and can absorb only the single-line
    `$script:SharedModuleNames` append that [P4-T9] already made.

    Case groups:

      1. The over-match allow case (1). A heredoc body whose JSON names promotion
         tools as receipt VALUES. `cat` is not a member of the wrapper carve-out
         set, so the body is masked and the names are mentions, not invocations.
      2. Deny preservation (4). A genuine promotion-script invocation, the adjacent
         `gh issue create` and `gh issue new` spellings, and the single-segment
         `gh api ... -X POST` write surface.
      3. Under-match deny cases (2). Relocating `gh` spellings in which a global
         option separates the command word from its subcommand (D10).
      4. The read-operation allow case (1). A relocating `gh issue list` stays
         ungated.

    The normative contract is the D2 behaviour contract, the D3 fail-closed table,
    and D10 in
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md.

    Determinism: every decision is driven through the pure seam with a literal
    tool_input string. No disk I/O, no child process, no live executable, and no
    temporary file.
#>

Describe 'Codex enforce-promotion-mcp-only trigger scoping (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-promotion-mcp-only.ps1'
        . $script:UnderTest

        function ConvertTo-CodexPromotionTriggerScopingToolInput {
            <#
                Builds the MAPPED tool_input JSON the Codex decision seam consumes.
                The command text is carried verbatim so a fixture can exercise
                quoting, chaining, and heredocs exactly as the shell would present
                them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{ command = $Command } | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-CodexPromotionTriggerScopingDecision {
            <#
                Single act step for every case in this file.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return Invoke-PromotionMcpOnlyDecision -ToolInputRaw (ConvertTo-CodexPromotionTriggerScopingToolInput -Command $Command)
        }

        # The same live reproduction command text the Claude sibling uses, so the two
        # runtimes are exercised on byte-identical input.
        $script:LiveReproductionCommand = @'
cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
{
  "issue-num": "545",
  "route_id": "epic",
  "delegation_receipts": {
    "promotion": {
      "new_potential_bug_entry": "completed",
      "potential_to_issue": "completed",
      "new_active_feature_folder": "completed"
    }
  }
}
JSON
'@
    }

    Context 'the over-match allow case - a receipt value is not an invocation' {
        It 'allows a heredoc whose JSON body names promotion tools as receipt values' {
            $command = $script:LiveReproductionCommand

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a heredoc body attached to a non-wrapper segment is masked, so the names are data'
        }
    }

    Context 'deny preservation - forms that deny today and must keep denying' {
        It 'denies a genuine promotion-script invocation' {
            $command = 'pwsh ./scripts/new-potential-entry.ps1 -ShortName foo'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyBlockedReason)
        }

        It 'denies the adjacent gh issue create spelling' {
            $command = 'gh issue create --title "x" --body "y"'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the adjacent spelling still matches the byte-unchanged expression'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'denies the adjacent gh issue new spelling' {
            $command = 'gh issue new --title "x"'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the adjacent spelling still matches the byte-unchanged expression'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'denies a single-segment gh api issues write with an explicit POST method' {
            $command = 'gh api repos/drmoisan/drm-copilot/issues -X POST'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an explicit POST against the issues endpoint is a write surface'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }
    }

    Context 'under-match deny cases - the relocating gh spellings' {
        It 'denies a relocating gh issue create carrying a repo global option' {
            # The --repo global option separates gh from its issue subcommand, so
            # the adjacency-requiring expression does not match and a raw issue
            # creation proceeds ungated today.
            $command = 'gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs --repo and reads issue create positionally'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'denies a relocating gh issue new carrying the short repo global option' {
            $command = 'gh -R drmoisan/drm-copilot issue new'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs -R and reads issue new positionally'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }
    }

    Context 'the read-operation allow case' {
        It 'allows a relocating gh issue list' {
            $command = 'gh --repo drmoisan/drm-copilot issue list'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a read operation is not an issue-creation subcommand'
        }
    }
}
