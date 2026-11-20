# Phase 0 — Policy Instructions Read

Timestamp: 2026-09-07T20-48
Task: [P0-T1]
Issue: #632
Work Mode: full-bug
Branch: bug/cleanup-worktrees-dirt-classifier-632-r2

Policy Order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/tonality.md`

Command: `wc -l CLAUDE.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/shell.md .claude/rules/quality-tiers.md .claude/rules/plan-acceptance-gates.md .claude/rules/tonality.md`
EXIT_CODE: 0

## Files read, in the required order

- `CLAUDE.md` — 56 lines. Repository tone policy, policy-compliance reading order, four-layer runtime architecture.
- `.claude/rules/general-code-change.md` — 80 lines. Design principles, mandatory seven-stage toolchain loop, 500-line file-size limit, error handling, I/O boundaries.
- `.claude/rules/general-unit-test.md` — 105 lines. Five core test properties, coverage thresholds, coverage exclusion policy, scenario completeness, prohibition on temporary files in tests, test file location.
- `.claude/rules/shell.md` — 93 lines. Bash toolchain order (shfmt, shellcheck, bats, kcov), native invocation under WSL on Windows, discovery contract, kcov line-coverage-only reporting, 500-line cap, tests under `tests/shell/*.bats` with checked-in fixtures.
- `.claude/rules/quality-tiers.md` — 51 lines. T1-T4 tier system, uniform line coverage >= 85%, PowerShell and bash exempt from the branch-coverage threshold because their tooling does not measure it.
- `.claude/rules/plan-acceptance-gates.md` — 257 lines. Acceptance-gate rules G1 through G9, attribution window, graceful degradation, severity decisions.
- `.claude/rules/tonality.md` — 80 lines. Professional tone requirement; prohibitions on humor, hyperbole, and decorative metaphor; evidence-first wording.

Output Summary: All seven policy files were read in the stated order and their line counts recorded. Total 722 lines. No policy file was modified.

## Constraints extracted that bind this execution

- No production, test, or reusable shell file may exceed 500 lines (`.claude/rules/shell.md`, `.claude/rules/general-code-change.md`).
- Tests live in `tests/shell/*.bats`, must not create temporary files, and must use checked-in fixtures under `tests/fixtures/` (`.claude/rules/shell.md`, `.claude/rules/general-unit-test.md`).
- kcov reports line coverage only; the uniform >= 85% line threshold applies and no bash branch-coverage gate exists (`.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`).
- Quote all expansions; keep scripts shellcheck-clean; use shfmt default formatting with tab indentation (`.claude/rules/shell.md`).
- Both directions of every classification decision are pinned in tests, per the delegation's primary quality obligation.
