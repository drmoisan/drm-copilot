#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #671 and issue #663 worktree-selector and quote-aware cases for the Codex
# preimplementation gate. These Contexts moved unchanged from
# enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
# (issue #935, I-3), which had reached the 500-line limit.
#
# Codex decision-entry idiom: the Codex copy of
# `Invoke-OrchestrationPreimplementationGateDecision` accepts the MAPPED tool_input JSON
# directly (for example `{"command":"..."}`), not the outer PreToolUse envelope the
# Claude copy consumes. Every decision below therefore passes bare tool_input text
# through the pure seam with an explicitly not-ready checkpoint: no disk I/O, no child
# process, and no temporary file.

Describe 'Codex enforce-orchestration-preimplementation-gate command exemption (issue #539)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'
        # Issue #707 (D10): the epic-scope read is mocked so local epic state cannot change a decision.
        Mock Get-EpicScopeCheckpointText { $null }
        . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1')
    }
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'issue #671 worktree selector allow cases' {
        # LACS (issue #671): one lexically absolute `-C <value>` selector may sit between
        # the command name and the subcommand. The selector is absent from D4 rows 1-13
        # and 15-19, so every other constraint still applies to the operands. Labels are
        # byte-identical to the Claude-side sibling suite.
        It 'allows <Label>' -ForEach @(
            @{ Label = 'issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand'; Command = 'git -C C:/repo/wt add -- docs/features/active/x/spec.md' }
            @{ Label = 'issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand'; Command = 'git -C /repo/wt add -- docs/features/active/x/spec.md' }
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
            @{ Label = 'issue #732 LACS allow 3 reversed - backslash-spelled absolute selector'; Command = 'git -C C:\repo\wt add -- docs/features/active/x/spec.md' }
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

    Context 'issue #663 quote-aware angle brackets' {
        # D4 row 12 as narrowed by issue #663, against the byte-identical .codex/hooks helpers
        # copy: `<` and `>` are redirections only outside a quoted span. `$` and backtick stay
        # unresolvable in any quote state, the single-quoted `'\''` apostrophe idiom stays
        # denied, and a pathless commit stays denied (D4 row 4).
        It 'issue #663 exempts <Label>' -ForEach @(
            @{ Label = 'a double-quoted message carrying a Co-Authored-By trailer and an apostrophe'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic-status.md && git commit -m "docs(epic): refresh status, it''s current. Co-Authored-By: Claude <noreply@anthropic.com>" -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
            @{ Label = 'a single-quoted message carrying angle brackets'; Command = 'git commit -m ''Co-Authored-By: Claude <noreply@anthropic.com>'' -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'angle brackets inside a quoted span are literal text, not redirections'
        }

        It 'issue #663 denies <Label>' -ForEach @(
            @{ Label = 'the single-quoted apostrophe idiom'; Command = 'git commit -m ''it''\''''s done <noreply@anthropic.com>'' -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
            @{ Label = 'a command substitution inside a double-quoted message'; Command = 'git commit -m "status $(date) <a@b.c>" -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
            @{ Label = 'a variable expansion inside a double-quoted message'; Command = 'git commit -m "status $USER <a@b.c>" -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
            @{ Label = 'a backtick substitution inside a double-quoted message'; Command = 'git commit -m "status `whoami` <a@b.c>" -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
            @{ Label = 'a pathless commit whose message carries angle brackets'; Command = 'git commit -m "Co-Authored-By: Claude <noreply@anthropic.com>"' }
            @{ Label = 'an unquoted output redirection after a quoted message carrying angle brackets'; Command = 'git commit -m ''Co-Authored-By: Claude <noreply@anthropic.com>'' -- docs/features/epics/2026-08-24-sample-epic/epic-status.md > out.txt' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'interpolation, an unbalanced idiom, a pathless commit, or an unquoted redirection keeps the line unresolvable'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'issue #663 remediation escaped quotes (CR-1, CR-3)' {
        # Backslash escapes are not modelled: a backslash before any quote character, or anywhere
        # inside a double-quoted span, can move a span boundary the scan cannot see (fail closed).
        It 'issue #663 remediation denies <Label>' -ForEach @(
            @{ Label = 'an escaped double quote hiding an output redirection (CR-1)'; Command = 'git add docs/features/active/x/a.md && git commit -m "a\"" > src/prod.ts "\"" docs/features/active/x/a.md' }
            @{ Label = 'an escaped double quote hiding an output redirection after a semicolon (CR-1)'; Command = 'git add docs/features/active/x/a.md ; git commit -m "a\"" > src/prod.ts "\"" docs/features/active/x/a.md' }
            @{ Label = 'an escaped double quote hiding chain operators (CR-3)'; Command = 'git commit -m "x\"" ; touch src/prod.ts ; "\"" -- docs/features/active/x/a.md' }
            @{ Label = 'an unquoted escaped double quote opening a scan-only span'; Command = 'git commit -m x\" > src/prod.ts \" -- docs/features/active/x/a.md' }
            @{ Label = 'an unquoted escaped single quote opening a scan-only span'; Command = 'git commit -m x\'' > src/prod.ts \'' -- docs/features/active/x/a.md' }
            @{ Label = 'a backslash inside a double-quoted message'; Command = 'git commit -m "path a\b" -- docs/features/active/x/a.md' }
        ) {
            # Act
            $decision = Get-CodexExemptionDecisionForCommand -Command $Command

            # Assert
            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an unmodelled backslash escape makes the quoted-span boundaries unknown'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }
}
