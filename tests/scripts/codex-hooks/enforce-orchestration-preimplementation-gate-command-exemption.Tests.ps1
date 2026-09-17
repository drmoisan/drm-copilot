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
            # Arrange - a here-document body quoting the literal in prose.
            #
            # SUPERSEDED BY ISSUE #545. Issue #539 D8 deliberately declined to narrow
            # the trigger, so this line classified as an implementation command and
            # was denied. Issue #545 narrows WHAT TEXT the byte-unchanged trigger
            # patterns are evaluated against: a heredoc body attached to a
            # NON-wrapper segment is masked, because the shell consumes it as data
            # and never executes it. `cat` is not a member of the wrapper carve-out
            # set, so this body is a mention rather than an invocation and the
            # expected decision reverses from deny to allow.
            #
            # This is the single intended assertion reversal on the Codex side, and
            # it mirrors the Claude-side reversal in
            # tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1.
            # The deny direction is preserved wherever the heredoc feeds a wrapper;
            # the sibling case below pins that.
            $command = @'
cat <<'NOTE' > docs/features/epics/2026-08-24-sample-epic/notes.md
Run git add docs/features/epics/2026-08-24-sample-epic/epic.md once the scaffold lands.
NOTE
'@

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'issue #545 masks a heredoc body attached to a non-wrapper segment, so the prose is data'
        }

        It 'denies the same heredoc body when it feeds a shell wrapper instead of a file' {
            # The paired deny case for the reversal above, and the reason the
            # reversal is not a fail-open change. The body is identical; only its
            # destination differs. `bash` IS a member of the wrapper carve-out set,
            # so this segment scans raw, the body stays visible to the trigger, and
            # the staging command it carries is genuinely executed.
            $command = @'
bash <<'NOTE'
git add docs/features/epics/2026-08-24-sample-epic/epic.md
NOTE
'@

            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a heredoc feeding a wrapper is executed, so the carve-out keeps it on raw text'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'issue #671 worktree selector allow cases' {
        # LACS (issue #671): one lexically absolute `-C <value>` selector may sit between
        # the command name and the subcommand. The selector is absent from D4 rows 1-13
        # and 15-19, so every other constraint still applies to the operands. Labels are
        # byte-identical to the Claude-side sibling suite.
        It 'allows <Label>' -ForEach @(
            @{ Label = 'issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand'; Command = 'git -C C:/repo/wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand'; Command = 'git -C /repo/wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS allow 3 - backslash-spelled absolute selector normalized before the rooting test'; Command = 'git -C C:\repo\wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS allow 4 - absolute selector on the message-bearing commit form'; Command = 'git -C C:/repo/wt commit -m "epic scaffold" -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector'; Command = 'git -C C:/repo/wt add -- docs/features/active/x/spec.md && git -C C:/repo/wt commit -m "epic scaffold" -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root'; Command = 'git -C C:/repo/wt-sibling add -- docs/features/active/y/spec.md' }
            @{ Label = 'issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree'; Command = 'git -C C:/elsewhere add -- docs/features/active/x/spec.md' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a lexically absolute selector with exempt operands is exempt under LACS'
        }
    }

    Context 'issue #671 worktree selector deny cases' {
        # One deny row per LACS condition L1 through L8, plus the must-not-regress rows.
        # Only the decision is asserted; the Write-Debug diagnostic text is not contractual.
        It 'denies <Label>' -ForEach @(
            @{ Label = 'issue #671 LACS L1a - attached selector spelling'; Command = 'git -CC:/repo/wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L1b - config-injection selector'; Command = 'git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L2 - repeated selector'; Command = 'git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L3a - selector with no subcommand after the value'; Command = 'git -C C:/repo/wt && git add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L3b - subcommand not immediately after the selector value'; Command = 'git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L4a - bare relative selector'; Command = 'git -C subdir add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L4b - UNC selector'; Command = 'git -C //server/share/wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L5a - parent-directory segment in the selector'; Command = 'git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L5b - current-directory segment in the selector'; Command = 'git -C C:/repo/./wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L6 - wildcard in the selector'; Command = 'git -C C:/repo/wt-? add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L7 - stray colon in the selector'; Command = 'git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS L8 - empty selector value'; Command = 'git -C "" add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 selector followed by an unmodelled subcommand'; Command = 'git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 selector with a non-exempt pathspec operand'; Command = 'git -C C:/repo/wt add -- scripts/powershell/Sample.ps1' }
            @{ Label = 'issue #671 selector with the tree-wide all flag'; Command = 'git -C C:/repo/wt add -A' }
            @{ Label = 'issue #671 selector with an absolute pathspec operand'; Command = 'git -C C:/repo/wt add -- C:/repo/wt/docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 selector with an output redirection'; Command = 'git -C C:/repo/wt add -- docs/features/active/x/spec.md > staged.txt' }
            @{ Label = 'issue #671 cd chain into the target worktree'; Command = 'cd C:/repo/wt && git add -- docs/features/active/x/spec.md' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'LACS withholds the exemption from an undecidable selector or a non-exempt segment'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'issue #671 empty-token fail-closed cases' {
        # Remediation R1 (issue #671): an empty quoted token is an ordinary token to the
        # classifier. It is never an exempt operand, and after -m it is the message value.
        It 'allows <Label>' -ForEach @(
            @{ Label = 'issue #671 empty commit message beside an exempt operand'; Command = 'git commit -m "" -- docs/features/active/x/spec.md' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'an empty message value is not a pathspec and every operand is exempt'
        }

        It 'denies <Label>' -ForEach @(
            @{ Label = 'issue #671 empty token beside a non-exempt operand'; Command = 'git add "" -- src/foo.ps1' }
            @{ Label = 'issue #671 empty token after the separator beside a non-exempt operand'; Command = 'git add -- "" scripts/powershell/Sample.ps1' }
            @{ Label = 'issue #671 trailing empty token after a non-exempt operand'; Command = 'git add -- src/foo.ts ""' }
            @{ Label = 'issue #671 empty commit message beside a non-exempt operand'; Command = 'git commit -m "" -- src/foo.ts' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an empty token never makes a non-exempt operand exempt'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'issue #671 selector predicate and fail-closed guard' {
        # Direct calls to the helpers the gate dot-sources in BeforeAll. The predicate checks
        # only that a non-option token follows the selector value; the caller rejects any
        # subcommand other than add or commit, which accept 3 pins.
        It 'accepts <Label>' -ForEach @(
            @{ Label = 'issue #671 predicate accept 1 - drive-letter selector followed by add'; Token = @('git', '-C', 'C:/repo/wt', 'add', '--', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate accept 2 - rooted selector followed by commit'; Token = @('git', '-C', '/repo/wt', 'commit', '-m', 'msg', '--', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate accept 3 - non-option token after the value is left to the caller'; Token = @('git', '-C', 'C:/repo/wt', 'status') }
        ) {
            # Act
            $result = Test-ExemptOrchestrationSelector -Token $Token

            # Assert
            $result | Should -BeTrue -Because 'the selector satisfies LACS L1 through L8'
        }

        It 'rejects <Label>' -ForEach @(
            @{ Label = 'issue #671 predicate L1a - single token segment'; Token = @('git') }
            @{ Label = 'issue #671 predicate L1b - option other than the selector at index 1'; Token = @('git', '-c', 'core.worktree=C:/repo/wt', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L2 - repeated selector'; Token = @('git', '-C', 'C:/repo/wt', '-C', 'C:/repo/other', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L3a - no token after the selector value'; Token = @('git', '-C', 'C:/repo/wt') }
            @{ Label = 'issue #671 predicate L3b - option token after the selector value'; Token = @('git', '-C', 'C:/repo/wt', '--no-pager', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L4a - relative selector'; Token = @('git', '-C', 'subdir', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L4b - UNC selector'; Token = @('git', '-C', '//server/share/wt', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L5a - parent-directory segment'; Token = @('git', '-C', 'C:/repo/wt/../other', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L5b - current-directory segment'; Token = @('git', '-C', 'C:/repo/./wt', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L6 - wildcard'; Token = @('git', '-C', 'C:/repo/wt-?', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L7 - stray colon'; Token = @('git', '-C', 'C:/repo/wt:branch', 'add', 'docs/features/active/x/spec.md') }
            @{ Label = 'issue #671 predicate L8 - empty selector value'; Token = @('git', '-C', '', 'add', 'docs/features/active/x/spec.md') }
        ) {
            # Act
            $result = Test-ExemptOrchestrationSelector -Token $Token

            # Assert
            $result | Should -BeFalse -Because 'the selector violates the LACS condition named in the label'
        }

        It 'returns false when segment classification raises an error' {
            # Arrange
            Mock Test-ExemptOrchestrationSegmentToken { throw 'simulated segment classification failure' }

            # Act
            $result = Test-ExemptOrchestrationStagingCommand -CommandText 'git add -- docs/features/active/x/spec.md'

            # Assert
            $result | Should -BeFalse -Because 'an error while classifying a segment is a parse ambiguity and answers false'
            Should -Invoke Test-ExemptOrchestrationSegmentToken -Times 1 -Exactly
        }
    }
}
