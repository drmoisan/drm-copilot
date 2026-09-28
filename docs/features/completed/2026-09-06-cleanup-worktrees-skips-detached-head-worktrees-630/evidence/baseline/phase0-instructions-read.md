# Phase 0 — Policy Instructions Read (Issue #630)

Timestamp: 2026-09-07T11-00

Task: [P0-T1]

Feature: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630`

Branch: `bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2`

Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

Policy Order: the `policy-compliance-order` sequence named by [P0-T1], read in the order listed below before any repository file was modified.

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/tonality.md`
6. `.claude/rules/shell.md`
7. `.claude/rules/plan-acceptance-gates.md`

All seven paths are repository-relative to the worktree root named above.

## Provisions Governing This Feature

- `.claude/rules/shell.md` — the bash toolchain order is format, then check, then test; there is no bash type-check stage. Coverage is line-only via kcov, threshold >= 85%. No shell file may exceed 500 lines. Tests live in `tests/shell/*.bats`, must not create temporary files, and must use checked-in fixtures wired through the documented seams.
- `.claude/rules/general-unit-test.md` — temporary files in tests are prohibited; tests must be independent, isolated, deterministic, and located in a `tests/` tree that mirrors the production layout.
- `.claude/rules/quality-tiers.md` — line coverage >= 85% is uniform across tiers; no bash branch-coverage gate applies because kcov does not measure branch coverage.
- `.claude/rules/general-code-change.md` — 500-line file cap; fail-fast error handling; the mandatory toolchain loop restarts from stage 1 whenever a stage fails or rewrites a file.
- `.claude/rules/tonality.md` — professional, factual, neutral tone in all authored content, including these evidence artifacts.
- `.claude/rules/plan-acceptance-gates.md` — acceptance conditions must be falsifiable; gates G1 through G9 and the wrap-tolerant authoring guidance apply to the plan this artifact records execution of.

## Notes

No repository file was modified before this artifact was written.
