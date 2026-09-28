# P6-T16 — AC-13 golden check (expected outputs unchanged)

Timestamp: 2026-09-27T02-16
Task: [P6-T16]
Working directory: repository worktree root
Effective BASE_SHA: `92d78897371cc5c4f301c8cc2238adeb3fff2fea` (DEV-1: replaces the plan literal `0658f6945aa833c6960dc5bf8a43635fc346991f`; see P0-T1).

Command: `git status --porcelain -- tests/fixtures/cleanup_worktrees/expected/`
EXIT_CODE: 0
Output: empty.

## CI `ok` lines for `tests/shell/test_cleanup_worktrees_dirt_regression.bats` (P6-T11 run 36287146354)

The suite declares 12 `@test` blocks; each name was matched against the CI log and all 12 report `ok`:

```
ok 329 report mode output for merged_with_worktree is byte-identical to the checked-in expected output
ok 330 report mode output for merged_no_worktree is byte-identical to the checked-in expected output
ok 331 report mode output for unmerged is byte-identical to the checked-in expected output
ok 332 report mode output for content_neutral is byte-identical to the checked-in expected output
ok 333 report mode output for residual_on_main is byte-identical to the checked-in expected output
ok 334 report mode output for residual_unique_doc is byte-identical to the checked-in expected output
ok 335 report mode output for current_exclusion is byte-identical to the checked-in expected output
ok 336 report mode output for main_divergence is byte-identical to the checked-in expected output
ok 337 apply mode without --clear-disposable over dirty_worktree is byte-identical
ok 338 apply mode without --clear-disposable over dirty_worktree_status_error is byte-identical
ok 339 report mode over a worktree with zero status entries emits no DIRTFILE or DIRTSUM record
ok 340 report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record
```

## Golden diff (gate)

Command: `git diff --exit-code 92d78897371cc5c4f301c8cc2238adeb3fff2fea HEAD -- tests/fixtures/cleanup_worktrees/expected/`
EXIT_CODE: 0

Output Summary:
- Golden diff exits 0 with empty output; porcelain status is empty.
- All 12 dirt_regression tests report `ok` in the P6-T11 CI run.
- Result: PASS (AC-13 evidence condition met).
