#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Claude promotion gate (issue #545).

.DESCRIPTION
    Issue #545 changes WHAT TEXT the four byte-unchanged forbidden-token literals and
    the two byte-unchanged `gh` expressions in `Get-PromotionBypassReason` are
    evaluated against, and adds a structural `gh` classifier for the relocating
    spellings.

    Case groups:

      1. The over-match allow case (1). A heredoc body whose JSON names promotion
         tools as receipt VALUES. This is the live reproduction recorded at
         docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/other/live-reproduction-promotion-hook-overmatch.2026-09-06T23-35.md,
         in which a checkpoint write was denied with PROMOTION_MCP_ONLY_BLOCKED
         although no promotion script was invoked. `cat` is not a member of the
         wrapper carve-out set, so the body is masked and the names are mentions.
      2. Deny preservation (4). Forms that deny today and must keep denying: a
         genuine promotion-script invocation, the adjacent `gh issue create` and
         `gh issue new` spellings, and the single-segment `gh api ... -X POST`
         write surface.
      3. Under-match deny cases (2). Relocating `gh` spellings in which a global
         option separates the command word from its subcommand. They pass by
         non-match today, which is the latent bypass D10 records.
      4. The read-operation allow case (1). The structural classifier must match
         the issue-creation subcommands only, so a relocating `gh issue list`
         stays ungated.

    The normative contract is the D2 behaviour contract, the D3 fail-closed table,
    and D10 in
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md.

    Determinism: every decision is driven through the pure seam
    `Invoke-PromotionMcpOnlyDecision` with a literal envelope string. The seam reads
    no file, starts no process, reads no clock, and creates no temporary file.
#>

Describe 'enforce-promotion-mcp-only.ps1 trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-promotion-mcp-only.ps1").Path
        . $script:UnderTest

        function ConvertTo-PromotionTriggerScopingPayload {
            <#
                Builds the Bash PreToolUse envelope the Claude promotion gate reads.
                The command text is carried verbatim so a fixture can exercise
                quoting, chaining, and heredocs exactly as the shell would present
                them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function Get-PromotionTriggerScopingDecision {
            <#
                Single act step for every case in this file.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return Invoke-PromotionMcpOnlyDecision -ToolInputRaw (ConvertTo-PromotionTriggerScopingPayload -Command $Command)
        }

        # The live reproduction command text. Kept in one variable so the [P6-T10]
        # replay and this suite exercise byte-identical input.
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
            # The live reproduction. The orchestrator-state schema requires these
            # names as values under delegation_receipts.promotion, so the write and
            # the gate were individually reasonable and jointly unsatisfiable while
            # the body was scanned as command text. Nothing here executes a
            # promotion tool.
            $command = $script:LiveReproductionCommand

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a heredoc body attached to a non-wrapper segment is masked, so the names are data'
        }
    }

    Context 'deny preservation - forms that deny today and must keep denying' {
        It 'denies a genuine promotion-script invocation' {
            # An execution, not a mention. `pwsh` is a member of the wrapper
            # carve-out set, so this segment scans raw and the script name stays
            # visible to the forbidden-token scan.
            $command = 'pwsh ./scripts/new-potential-entry.ps1 -ShortName foo'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyBlockedReason)
        }

        It 'denies the adjacent gh issue create spelling' {
            $command = 'gh issue create --title "x" --body "y"'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the adjacent spelling still matches the byte-unchanged expression'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'denies the adjacent gh issue new spelling' {
            $command = 'gh issue new --title "x"'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the adjacent spelling still matches the byte-unchanged expression'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'denies a single-segment gh api issues write with an explicit POST method' {
            # The lookahead expression is unchanged; only the text it is evaluated
            # against changed. This command is one segment, so per-segment
            # evaluation and whole-command evaluation coincide here.
            $command = 'gh api repos/drmoisan/drm-copilot/issues -X POST'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

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
            # creation proceeds ungated today. This is acceptance case AT-5.
            $command = 'gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs --repo and reads issue create positionally'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'denies a relocating gh issue new carrying the short repo global option' {
            $command = 'gh -R drmoisan/drm-copilot issue new'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs -R and reads issue new positionally'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }
    }

    Context 'the read-operation allow case' {
        It 'allows a relocating gh issue list' {
            # The structural classifier must match the issue-creation subcommands
            # only. `list` is not `create` and not `new`, so the scan of that
            # segment terminates without a match and the read stays ungated.
            $command = 'gh --repo drmoisan/drm-copilot issue list'

            $decision = Get-PromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a read operation is not an issue-creation subcommand'
        }
    }
}
