# Fail-Before Exception Dossier — Cycle 3, Issue #396

Timestamp: 2026-07-22T21-42

This dossier records the cycle-3 fixed sites for which a pre-fix failing test run is
structurally impossible to construct, per Design Decision 10 and
`evidence-and-timestamp-conventions`. The 13 constructible fail-before observations are
captured by the deliberate red CI dispatch (P2-T12); this dossier covers the remaining
sites where a fail-before run cannot be constructed.

## Entry (a): classify_branch line 364 minus-present cherry re-invocation (P3-T6)

WhyFailingRunImpossible: The recording stub keys both `git cherry main <branch>`
invocations identically (`cherry.<branch>`). Any hard-failure cherry fixture therefore
fails the FIRST invocation, inside `classify_cherry_equivalent`, which is already guarded
(cycle 2) and returns `CHERRY_ERROR` before control ever reaches the second invocation at
lib line 364. There is no scenario in which the second invocation observes a git failure
that the first did not already catch, so no pre-fix test can exercise the fail-open at
line 364 in isolation.

Alternative proof: The P3-T6 refactor deletes the second `git cherry` invocation entirely
and derives `minus_present` from the `MINUS_PRESENT` token embedded in the already-captured
cherry verdict, making the fail-open instance structurally impossible rather than merely
guarded. The P4-T1 re-grep (recorded in the P5-T7 summary) confirms exactly one
`cleanup_wt_git cherry` invocation remains in the file. The existing
`residual_unique_doc` (HAS_UNIQUE_RESIDUALS) and `unmerged` (NOT_MERGED) scenarios pin the
minus-present-driven state classification across the refactor (verified in the P5 green run).

## Entry (b): reverify_delete_eligible (line 185) and remove_worktree_safe (line 216) conversions (P3-T12)

WhyFailingRunImpossible: Both sites are already fail-closed before the conversion.
`reverify_delete_eligible` gates on a state-token allowlist (`MERGED_CLEAN |
MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT`); any hard-failure classification produces
`ANCESTRY_ERROR`, which is outside the allowlist and already yields `BLOCKED-REVERIFY` /
return 1. `remove_worktree_safe`'s `status --porcelain` read is diagnostic-only and runs
only after the worktree removal has already failed and is being reported; the function
already emits `BLOCKED-DIRTY` / return 1 regardless of the status read's exit code. No
pre-fix test can observe a wrong (fail-open) outcome at either site, so a fail-before run
would be indistinguishable from the pass-after run.

Alternative proof: The conversions are behavior-preserving on the failure direction; they
remove the `< <(...)` process-substitution idiom over a git-backed producer without
changing the fail-closed result. Regression guards (16) `reverify_delete_eligible` →
`BLOCKED-REVERIFY`/status 1 under `worktree_list_error` and (17) `remove_worktree_safe` →
`BLOCKED-DIRTY`/status 1 under `dirty_worktree_status_error` in
`test_cleanup_worktrees_hard_failures.bats` pin the fail-closed behavior across the
conversion (green in both the fail-before and pass-after CI runs).

## Negative-claim audit block (for this dossier's own "no constructible failing run" claim)

SearchScope: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/regression-testing/` and the feature root `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/`.
SearchPatterns: `fail-before-exception.*.md`, `cycle3-hard-failure.fail-before.*.md`.
SearchResult: `fail-before-exception.2026-07-22T21-16.md` (this dossier); `cycle3-hard-failure.fail-before.2026-07-22T21-16.md` (written by P2-T12, the constructible fail-before run for the other 13 sites). The three sites documented here have no constructible failing run by the structural arguments above; the alternative proofs (P3-T6 structural removal + P4-T1 re-grep; regression guards 16 and 17) substitute for a failing observation.

Output Summary: Three sites (minus-present cherry re-invocation at lib line 364; the
reverify_delete_eligible and remove_worktree_safe idiom conversions) have no constructible
pre-fix failing run. Structural reasons and alternative proofs are recorded for each. The
other 13 fixed sites are covered by the constructible fail-before run in P2-T12.
