#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #539 - command-branch pathspec exemption for the Codex preimplementation gate.
#
# The existing Codex contract suite `legacy-codex-hook-contracts.Tests.ps1` is at 494 of
# its 500 permitted lines, so these scenarios land here rather than extending it.
#
# Codex decision-entry idiom: the Codex copy of
# `Invoke-OrchestrationPreimplementationGateDecision` accepts the MAPPED tool_input JSON
# directly (for example `{"command":"..."}`), not the outer PreToolUse envelope the
# Claude copy consumes. Every decision below therefore passes bare tool_input text
# through the pure seam with an explicitly not-ready checkpoint: no disk I/O, no child
# process, and no temporary file.
#
# Scenario obligations are identical to the Claude-side sibling suite
# `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`.
# The normative contract is the D4 fail-closed rule table in
# docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md.

Describe 'Codex enforce-orchestration-preimplementation-gate command exemption (issue #539)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest

        function ConvertTo-CodexExemptionToolInput {
            <#
                Builds the MAPPED tool_input JSON the Codex decision seam consumes. The
                command text is carried verbatim so a fixture can exercise quoting,
                chaining, and redirection exactly as the shell would present it.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{ command = $Command } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-CodexNotReadyCheckpointRaw {
            <#
                An explicitly NOT-ready checkpoint: route id empty and lifecycle
                readiness false, so `Test-OrchestrationReady` returns false and any
                allow decision must come from the command-branch exemption alone.
            #>
            param()

            return @{
                'issue-num'      = ''
                'feature-folder' = ''
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }

        function Get-CodexExemptionDecisionForCommand {
            <#
                Single act step for every case in this file: classify one command text
                against a not-ready checkpoint and return the decision object.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexExemptionToolInput -Command $Command) `
                -CheckpointRaw (ConvertTo-CodexNotReadyCheckpointRaw)
        }
    }

    Context 'issue #539 orchestration-tree staging exemption allow cases' {
        It 'allows staging an epic document under the epics tree' {
            # Arrange
            $command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'every operand resolves inside docs/features/epics/'
        }

        It 'allows staging a parallel manifest and its kickoff in one two-operand invocation' {
            # Arrange
            $command = 'git add docs/features/parallel/2026-08-24-sample-run/parallel.md docs/features/parallel/2026-08-24-sample-run/parallel-kickoff.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'both operands resolve inside docs/features/parallel/'
        }

        It 'allows a quoted operand under the active feature tree' {
            # Arrange
            $command = 'git add "docs/features/active/2026-08-24-sample-feature-539/plan.md"'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'balanced quotes are stripped before the prefix test'
        }

        It 'allows a backslash-spelled operand after separator normalization (D4 row 18)' {
            # Arrange
            $command = 'git add docs\features\active\2026-08-24-sample-feature-539\plan.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'backslashes normalize to forward slashes before the prefix test'
        }

        It 'allows staging a kickoff markdown file under the orchestration artifacts tree' {
            # Arrange
            $command = 'git add artifacts/orchestration/parallel-kickoff-2026-08-24-sample-run.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'artifacts/orchestration/ is a directory prefix in the exempt set'
        }

        It 'allows the pathspec-bearing integration form with a message option and a double-dash separator' {
            # Arrange
            $command = 'git commit -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'tokens after the double-dash separator are pathspecs and all are exempt'
        }

        It 'allows a chained two-segment line whose every segment is independently exempt' {
            # Arrange
            $command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md && git commit -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'each segment independently parses as an all-exempt invocation'
        }

        It 'allows staging a lifecycle record under the potential feature tree' {
            # Arrange
            $command = 'git add docs/features/potential/2026-08-24-sample-candidate.md'

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'docs/features/potential/ is in the five-tree exempt set'
        }
    }

    Context 'issue #539 mixed pathspec deny cases' {
        # One exempt operand paired with one production operand. The all-operands-exempt
        # invariant (D4 row 19) denies each pairing, and the deny reason must keep the
        # prefix and both phrases the pre-existing suites already assert.
        It 'denies an exempt operand paired with a <Extension> production operand' -ForEach @(
            @{ Extension = '.ps1'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md scripts/powershell/Sample.ps1' }
            @{ Extension = '.py'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md scripts/dev_tools/sample_module.py' }
            @{ Extension = '.ts'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md extensions/drm-copilot/src/lib/sample.ts' }
            @{ Extension = '.cs'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md src/TaskMaster.Domain/Sample.cs' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'route metadata'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'lifecycle readiness'
        }
    }

    Context 'issue #539 fail-closed rule table deny cases' {
        # At least one named case per D4 row 1 through 17 and row 19. Row 18 is the
        # backslash-normalization ALLOW case in the first context, so it is absent here
        # by design. Every fixture matches the unchanged trigger regex, so each case
        # asserts a deny the exemption must decline to grant - never an under-match of
        # the trigger itself.
        It 'denies <Label>' -ForEach @(
            @{ Label = 'D4 row 1 - bare staging with zero operands'; Command = 'git add' }
            @{ Label = 'D4 row 2a - the tree-wide short all flag'; Command = 'git add -A' }
            @{ Label = 'D4 row 2b - the tree-wide long all flag'; Command = 'git add --all' }
            @{ Label = 'D4 row 2c - the update short flag with an exempt operand'; Command = 'git add -u docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 2d - the update long flag'; Command = 'git add --update' }
            @{ Label = 'D4 row 2e - the no-all flag with an exempt operand'; Command = 'git add --no-all docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 3a - the dot whole-tree operand'; Command = 'git add .' }
            @{ Label = 'D4 row 3b - the colon-slash whole-tree operand'; Command = 'git add :/' }
            @{ Label = 'D4 row 4 - a pathless message-only integration invocation'; Command = 'git commit -m "epic scaffold"' }
            @{ Label = 'D4 row 5a - the content-widening short all option'; Command = 'git commit -a -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 5b - the content-widening long all option'; Command = 'git commit --all -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 5c - the include short option'; Command = 'git commit -i -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 5d - the include long option'; Command = 'git commit --include -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 5e - the interactive long option'; Command = 'git commit --interactive -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 5f - the patch short option'; Command = 'git commit -p -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 5g - the history-rewriting amend option'; Command = 'git commit --amend -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 6a - pathspecs supplied from a file'; Command = 'git add --pathspec-from-file=stage-list.txt' }
            @{ Label = 'D4 row 6b - the nul-delimited pathspec file option'; Command = 'git add --pathspec-file-nul --pathspec-from-file=stage-list.txt' }
            @{ Label = 'D4 row 7 - a double-dash separator with nothing after it'; Command = 'git add --' }
            @{ Label = 'D4 row 8 - an unmodeled dash-leading option before the separator'; Command = 'git add --sparse docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 9a - the exclude pathspec magic operand'; Command = 'git add ":(exclude)scripts/" docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 9b - the bang shorthand exclude operand'; Command = 'git add :!scripts/ docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 9c - the top pathspec magic operand'; Command = 'git add ":(top)docs/features/epics/2026-08-24-sample-epic/epic.md"' }
            @{ Label = 'D4 row 9d - the glob pathspec magic operand'; Command = 'git add ":(glob)docs/features/epics/2026-08-24-sample-epic/epic.md"' }
            @{ Label = 'D4 row 9e - the icase pathspec magic operand'; Command = 'git add ":(icase)docs/features/epics/2026-08-24-sample-epic/epic.md"' }
            @{ Label = 'D4 row 10 - a leading-dash operand with no preceding separator'; Command = 'git add -docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 11 - an unbalanced quote around an exempt operand'; Command = 'git add "docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 12a - a dollar-sign interpolation inside an operand'; Command = 'git add docs/features/epics/$slug/epic.md' }
            @{ Label = 'D4 row 12b - a backtick substitution inside an operand'; Command = 'git add docs/features/epics/`whoami`/epic.md' }
            @{ Label = 'D4 row 12c - an output redirection in the segment'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md > staged.txt' }
            @{ Label = 'D4 row 12d - an input redirection in the segment'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md < stage-list.txt' }
            @{ Label = 'D4 row 13a - a chained line whose second segment is not exempt'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md && poetry run pytest' }
            @{ Label = 'D4 row 13b - unsplittable text whose quote spans the chain operator'; Command = 'git add "docs/features/epics/2026-08-24-sample-epic/epic.md && git commit -m ok' }
            @{ Label = 'D4 row 14a - an environment-style prefix relocating the pathspec base'; Command = 'GIT_DIR=../other/.git git add docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 14b - a directory-relocating option before the subcommand'; Command = 'git -C ../other add docs/features/epics/2026-08-24-sample-epic/epic.md && git add docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 14c - a git-dir option before the subcommand'; Command = 'git --git-dir=../other/.git commit -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md && git add docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 14d - a work-tree option before the subcommand'; Command = 'git --work-tree=../other add docs/features/epics/2026-08-24-sample-epic/epic.md && git commit -m "epic scaffold" -- docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 15a - a glob whose literal prefix stops above the exempt trees'; Command = 'git add docs/features/*' }
            @{ Label = 'D4 row 15b - a glob whose wildcard occupies an ancestor segment'; Command = 'git add docs/*/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 15c - a glob carrying a parent-directory segment'; Command = 'git add docs/features/epics/../*.md' }
            @{ Label = 'D4 row 16a - an absolute operand in the leading-slash spelling'; Command = 'git add /docs/features/epics/2026-08-24-sample-epic/epic.md' }
            @{ Label = 'D4 row 16b - an absolute operand in the drive-letter spelling'; Command = 'git add C:\docs\features\epics\2026-08-24-sample-epic\epic.md' }
            @{ Label = 'D4 row 16c - an absolute operand in the UNC spelling'; Command = 'git add \\server\share\docs\features\epics\2026-08-24-sample-epic\epic.md' }
            @{ Label = 'D4 row 17 - a parent-directory segment inside an otherwise exempt operand'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/../2026-08-24-other-epic/epic.md' }
            @{ Label = 'D4 row 19 - a mixed operand set of one exempt and one production path'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md scripts/powershell/Sample.ps1' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the fail-closed rule table denies this form'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'issue #539 residual whole-command-text behaviour (D3 and D8)' {
        It 'denies a message-body payload that merely contains the staging literal' {
            # Arrange - a here-document body quoting the literal in prose. The trigger
            # regex is applied to the whole command text and is deliberately NOT
            # narrowed by this fix (D8), so the line still classifies as an
            # implementation command; D3 keeps that outcome a deny because the prose
            # does not parse as a complete recognized invocation.
            $command = @'
cat <<'NOTE' > docs/features/epics/2026-08-24-sample-epic/notes.md
Run git add docs/features/epics/2026-08-24-sample-epic/epic.md once the scaffold lands.
NOTE
'@

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'prose containing the literal never parses as a well-formed invocation'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }
}
