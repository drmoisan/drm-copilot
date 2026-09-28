# Phase 0 Policy Read Record — remediation cycle 1 (issue #630)

Timestamp: 2026-09-07T15-00
Task: [P0-T1]
Plan: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/remediation-plan.2026-09-07T12-45.md`

Policy Order: the `policy-compliance-order` sequence, extended by the plan with the two
domain-specific rule files that govern this cycle (`shell.md`) and the plan-acceptance-gate rules
(`plan-acceptance-gates.md`).

## Files read, in order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/tonality.md`
6. `.claude/rules/shell.md`
7. `.claude/rules/plan-acceptance-gates.md`

All seven files were read in full before any file in the tree was modified.

## Constraints carried into execution

- No production-code change. The only edit under `scripts/` is operator text inside the `usage()`
  heredoc of `scripts/bash/cleanup-worktrees.sh`; heredoc body lines are data, not statements.
- The 500-line cap applies to every `.sh` and `.bats` file
  (`.claude/rules/shell.md`, `.claude/rules/general-code-change.md`).
- No temporary files, no `mktemp`, no `$BATS_TMPDIR`, no `git init` in any test
  (`.claude/rules/general-unit-test.md`).
- Bash toolchain order is format, lint, test; there is no type-check stage
  (`.claude/rules/shell.md`).
- kcov measures line coverage only; no bash branch-coverage figure is reported
  (`.claude/rules/quality-tiers.md`, `.claude/rules/shell.md`).
- No file is excluded from the kcov denominator (`.claude/rules/general-unit-test.md`,
  Coverage Exclusion Policy).
- Tone is professional, factual, and neutral (`.claude/rules/tonality.md`).

Output Summary: all seven policy files read in the stated order; no policy file was modified.
