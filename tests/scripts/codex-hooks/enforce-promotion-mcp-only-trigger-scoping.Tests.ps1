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

        # The issue #824 reproduction: a wrapper-led segment whose raw text carries gh
        # (inside "through"), issue, and new (inside "New-Object") as substrings only.
        $script:Issue824Reproduction = @'
pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'
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

    Context 'issue #824 - token-aware classification of wrapper-led segments' {
        It 'P824-A1 allows the issue 824 reproduction command' -Tag 'Issue824' {
            # Arrange: the raw text carries gh, issue, and new only as substrings.
            $command = $script:Issue824Reproduction

            # Act
            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'no token-bounded gh issue new sequence occurs in the wrapped payload'
        }

        It 'P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence' -Tag 'Issue824' {
            $command = 'pwsh -NoProfile -Command ''Write-Output "through"; "issue"; New-Object Text.StringBuilder'''

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the words occur, but never as a gh issue new or gh issue create sequence'
        }

        It 'P824-A3 allows gh --repo o/r issue list' -Tag 'Issue824' {
            $command = 'gh --repo o/r issue list'

            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'list is not an issue-creation subcommand'
        }

        It 'P824-D<Id> denies <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'gh issue create --title x'; Command = 'gh issue create --title x' }
            @{ Id = 2; Label = 'gh issue new --title x'; Command = 'gh issue new --title x' }
            @{ Id = 3; Label = 'GH  Issue  Create'; Command = 'GH  Issue  Create' }
            @{ Id = 4; Label = 'pwsh -NoProfile -Command ''gh issue create --title x'''; Command = 'pwsh -NoProfile -Command ''gh issue create --title x''' }
            @{ Id = 5; Label = 'pwsh -c "& gh issue new"'; Command = 'pwsh -c "& gh issue new"' }
            @{ Id = 6; Label = 'bash -c "gh issue create"'; Command = 'bash -c "gh issue create"' }
            @{ Id = 7; Label = 'gh api repos/o/r/issues -X POST'; Command = 'gh api repos/o/r/issues -X POST' }
            @{ Id = 8; Label = 'bash -c "gh -R o/r issue create"'; Command = 'bash -c "gh -R o/r issue create"' }
            @{ Id = 9; Label = 'bash -c ''x=create; gh issue $x'''; Command = 'bash -c ''x=create; gh issue $x''' }
            @{ Id = 10; Label = 'bash -c ''c=gh; $c issue create'''; Command = 'bash -c ''c=gh; $c issue create''' }
            @{ Id = 11; Label = 'the unbalanced segment echo unterminated'; Command = 'echo "unterminated' }
        ) {
            # Arrange: $Command comes from the -ForEach row.

            # Act
            $decision = Get-CodexPromotionTriggerScopingDecision -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a genuine or unresolvable gh issue creation must stay gated'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }
    }

    Context 'issue #824 cycle 1 - wrapped bypass forms and command-position expansions' {
        It 'P824-D<Id> denies <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 12; Label = 'bash -c ''cmd="issue create"; gh $cmd'''; Command = 'bash -c ''cmd="issue create"; gh $cmd''' }
            @{ Id = 13; Label = 'pwsh -c ''$a = "issue","create"; gh @a'''; Command = 'pwsh -c ''$a = "issue","create"; gh @a''' }
            @{ Id = 14; Label = 'bash -c ''args=(issue create); gh "${args[@]}"'''; Command = 'bash -c ''args=(issue create); gh "${args[@]}"''' }
            @{ Id = 15; Label = 'bash -c with a backslash-newline between issue and create'; Command = ('bash -c "gh issue \' + "`n" + 'create"') }
        ) {
            # Arrange: $Command comes from the -ForEach row.

            # Act
            $decision = Get-CodexPromotionTriggerScopingDecision -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a literal gh whose subcommand words reach it through an expansion or a line continuation must stay gated'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }

        It 'P824-A4 allows a wrapped Write-Output whose expansion precedes issue create' -Tag 'Issue824' {
            # Arrange: no token-bounded gh occurs anywhere in the wrapped payload.
            $command = 'pwsh -c ''Write-Output "$prefix issue create"'''

            # Act
            $decision = Get-CodexPromotionTriggerScopingDecision -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'an expansion in the command position needs a token-bounded gh elsewhere in the raw text'
        }
    }
}
