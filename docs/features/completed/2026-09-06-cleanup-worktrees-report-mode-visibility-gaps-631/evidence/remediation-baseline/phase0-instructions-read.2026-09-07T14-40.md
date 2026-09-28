# Phase 0 Policy-Read Evidence — Remediation Cycle (issue #631)

Timestamp: 2026-09-07T16-24

Plan: `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/remediation-plan.2026-09-07T14-40.md`
Branch: `bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2`
Work Mode: full-bug (`issue.md:12`)

Policy Order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/shell.md`

## Files read (in the order above)

- `CLAUDE.md` — read in full (P0-T1). Standing instructions: tone policy, policy-compliance
  reading order, path-scoped language rules under `.claude/rules/`, the four-layer runtime
  architecture, and the orchestration checkpoint path
  `artifacts/orchestration/orchestrator-state.json`.
- `.claude/rules/general-code-change.md` — read in full (P0-T2). Noted the **File Size Limit**
  section: no production code, test code, or reusable script file may exceed **500 lines**;
  Markdown documentation files are exempt. Also noted the mandatory seven-stage toolchain loop
  and its restart-from-step-1 rule.
- `.claude/rules/general-unit-test.md` — read in full (P0-T3). Noted:
  - **No temporary files in tests**: "Creation and use of temporary files in tests is strictly
    prohibited."
  - **`tests/` mirror-layout requirement**: test files must live in a `tests/` tree that mirrors
    the production source structure; colocation in the production source tree is not permitted.
  - **Coverage thresholds**: line coverage >= 85% across all tiers; branch coverage >= 75% only
    for languages whose coverage tooling measures branch coverage. bash (kcov) is exempt from the
    branch threshold because kcov does not measure branch coverage; the line threshold still
    applies to bash.
  - **Coverage Exclusion Policy**: no production file may be excluded from coverage measurement.
- `.claude/rules/shell.md` — read in full (P0-T4). Noted:
  - **Four-stage toolchain order**: `format` (shfmt write mode), `check` (shfmt diff +
    shellcheck), type-check not applicable for bash, `test` (bats) and `test --coverage`
    (bats under kcov), restarting from step 1 if any step fails or rewrites files.
  - **`SHELL_QC_<TOOL>_BIN` seam convention** for `shfmt`, `shellcheck`, `bats`, and `kcov`;
    an empty or nonexistent value is treated as missing. Coverage output directory is
    `SHELL_QC_KCOV_OUT_DIR` (default `artifacts/pester/kcov`).
  - **500-line cap restated for shell**: "No production, test, or reusable shell file may
    exceed 500 lines."
  - Tests live in `tests/shell/*.bats` and mirror `scripts/bash/`; tests must not create
    temporary files and must use checked-in fixtures and stub binaries wired through a
    `_BIN` seam.
  - Coverage prints the literal line `Bash coverage (lines): NN.N%`; kcov reports line
    coverage only.

## Notes

- No file was modified by this task.
- These reads were performed in the executing session before any code or test change in this
  remediation cycle.
