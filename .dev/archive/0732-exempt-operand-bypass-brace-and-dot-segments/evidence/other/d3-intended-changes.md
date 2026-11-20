# D3 intended changes to existing rows (issue #738, recorded under issue #732)

Timestamp: 2026-10-09T03-58
Task: [P3-T1]

This record is written before either section-5.6 row is edited ([P3-T4] and [P3-T5] run later).

## D3 rule that changes the outcome

When the session root resolves to epic scope and a `-C` selector names a worktree whose own HEAD is not the epic integration branch, the operation targets a worktree outside the governing epic scope. Under decision D3 the epic-scope decision denies it with reason code `target-mixed`, instead of falling back to the single-feature decision.

## Row 1 (Claude)

- File: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`
- Old `It` name: `epic scope ignores a text branch label and decides the -C selector worktree by its own HEAD`
- New `It` name: `epic scope denies a -C selector worktree outside the session-root epic scope as target-mixed (issue #738)`
- Old assertion: `$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason`
- New assertion: `$decision.hookSpecificOutput.permissionDecisionReason.Contains('target-mixed') | Should -BeTrue -Because 'the session root is epic scope and the selector worktree is not (D3)'`
- Merge-probe line (G3): `Should -Invoke Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -Times 0 -Exactly` gains `-ParameterFilter { $WorktreeRoot -eq '/synthetic-worktrees/epic-other' }`.
- D3 rule applied: session root epic scope with a non-epic `-C` target is `target-mixed`.

## Row 2 (Codex)

- File: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`
- Old `It` name: `a -C selector command whose selector HEAD differs returns the single-feature decision although the session-root HEAD matches`
- New `It` name: `a -C selector command whose selector HEAD differs is denied as target-mixed when the session-root HEAD matches (issue #738)`
- Old assertion: `$decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason`
- New assertion: `$decision.hookSpecificOutput.permissionDecisionReason.Contains('target-mixed') | Should -BeTrue -Because 'the session root is epic scope and the selector HEAD differs (D3)'`
- D3 rule applied: session root epic scope with a non-epic `-C` target is `target-mixed`.

## Pre-declared classification rule for later failing existing rows

A later failing existing row is a D3 intended change only when its input has an epic-scope candidate and either a non-epic target (mixed), a relative or dot-segment `-C`, an ambiguous target, or a readiness failure of a target other than the session root. Any other failing existing row is not a D3 intended change.

Output Summary: Two section-5.6 rows recorded (Claude EpicScope G1-G3, Codex epic-scope H1-H2), each changing from the single-feature decision to a `target-mixed` deny under D3, plus the pre-declared classification rule for later failing existing rows.
