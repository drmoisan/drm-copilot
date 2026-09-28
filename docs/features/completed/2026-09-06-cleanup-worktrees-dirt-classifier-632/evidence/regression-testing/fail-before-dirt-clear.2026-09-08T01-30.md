# P3-T5 [expect-fail] — clearing suite before the library and the call sites exist

Timestamp: 2026-09-08T01-30
Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Commit under test: `aa0d619d9e3b4c7e3ecca027fb4978541f265407`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Tree state at capture: `scripts/bash/cleanup_worktrees_dirt_lib.sh` does not exist and the
`delete_candidate` clearing hook of P5-T5 is not yet wired.

Route: the bash toolchain is denied to the delegated `atomic-executor`, so the orchestrator
executed this gate from its own context per EA-4 and returned the measurement. The plan's
`wsl -d Ubuntu -- bash -lc` form against the preparation worktree is not used, per EA-1.
The full run record is `expect-fail-gates.2026-09-08T02-05.md` in this same folder.

Output Summary: 10 of the 11 tests reported `not ok`, which satisfies the acceptance
condition of at least ten. The cause is the absence of
`scripts/bash/cleanup_worktrees_dirt_lib.sh`, so `clear_disposable_dirt` and
`classify_worktree_dirt` are undefined and the clearing hook does not exist at the
`delete_candidate` call site.

## The ten tests that reported `not ok`, named

1. `dirt_clear_all_disposable: the clearing sequence is reset then clean then worktree remove`
2. `dirt_clear_all_disposable: the clear result record reports OK`
3. `dirt_clear_all_disposable: no force flag and no ignored-file flag reaches git`
4. `dirt_mixed_unique_blocks: a UNIQUE verdict refuses the clear`
5. `dirt_mixed_unique_blocks: a refused clear runs no reset, no clean, and no second worktree remove`
6. `dirt_classifier_read_error: a fail-closed UNIQUE refuses the clear`
7. `dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal`
8. `dirt_clear_reverify_order: the post-clear re-verification cherry probe follows the reset and precedes the removal retry`
10. `dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index`
11. `dirt_staged_tree_is_commit: the cached diff-index probe runs and every status read suppresses optional locks`

## The one test that reported `ok`, and why that is correct

`ok 9 reverify_delete_eligible refuses a non-eligible branch under the unmerged fixture`

Test 9 drives the pre-existing `reverify_delete_eligible` directly against the existing
`unmerged` fixture. It exercises no new code, so it is expected to pass both before and
after the implementation. The plan predicted this pass explicitly and set the acceptance
threshold at ten of eleven for that reason.

Tests 5, 7, 10 and 11 are absence-shaped by name and each carries a positive control, so
none of them passed vacuously in this pre-library state. That is recorded in
`../qa-gates/absence-assertion-audit.2026-09-08T01-30.md`.

The pass-after counterpart is P5-T9.
