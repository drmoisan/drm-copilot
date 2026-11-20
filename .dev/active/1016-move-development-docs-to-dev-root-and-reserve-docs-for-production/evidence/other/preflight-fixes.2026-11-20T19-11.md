# Preflight Fixes — remediation cycle 1 plan, confirming preflight

Timestamp: 2026-11-20T19-11
Plan: .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/remediation-plan.2026-11-20T18-37.md
Signal: PREFLIGHT: ALL CLEAR
Validators: branch CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exit 0 after the fix.

## Fixes (task text only; no task added, removed or reordered)

1. [P1-T3] | typo | The sentence that began "compared with a `git -C <worktree> status --porcelain` capture" now begins with a capital letter.

## Design check notes (no defect)

- F1: [P1-T1] fail-before cases, [P1-T2] predicate and `scanRewrites` change, [P1-T3] post-apply dry run. A search of non-`.dev/` files changed since the 2026-11-20T16-11 check found moved-root tokens only in the two cleanup-target-unresolved hook test files that [P1-T3] adds as Stay rows.
- F2: [P1-T4] and [P1-T5], checked by line counts and literal occurrence counts.
- F3: [P0-T3] clean layout, [P1-T6] fail-before and fix, [P1-T7] static sweep, [P1-T8] dynamic sweep.
