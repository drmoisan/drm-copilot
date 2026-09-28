# P5-T9 — clearing and non-mutation suite pass-after

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-28Z (nominal run-timestamp scheme, see the P5-T3 artifact).
Run by: atomic-executor, directly (`npx --yes bats`, bats 1.13.0).

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 0

## 11 ok / 0 not ok

```
1..11
ok 1 dirt_clear_all_disposable: the clearing sequence is reset then clean then worktree remove
ok 2 dirt_clear_all_disposable: the clear result record reports OK
ok 3 dirt_clear_all_disposable: no force flag and no ignored-file flag reaches git
ok 4 dirt_mixed_unique_blocks: a UNIQUE verdict refuses the clear
ok 5 dirt_mixed_unique_blocks: a refused clear runs no reset, no clean, and no second worktree remove
ok 6 dirt_classifier_read_error: a fail-closed UNIQUE refuses the clear
ok 7 dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal
ok 8 dirt_clear_reverify_order: the post-clear re-verification cherry probe follows the reset and precedes the removal retry
ok 9 reverify_delete_eligible refuses a non-eligible branch under the unmerged fixture
ok 10 dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index
ok 11 dirt_staged_tree_is_commit: the cached diff-index probe runs and every status read suppresses optional locks
```

Output Summary: eleven passing tests, named above. The gate pins the never-force invariant
(test 3), the `-x`/`-X`/`-ff` prohibition (test 3), the refusal on any `UNIQUE` verdict
including the fail-closed one (tests 4, 5, 6), the post-clear re-verification ordering (test 8),
and the report-mode non-mutation property (tests 10, 11).

## Known coverage gap recorded at this gate

Tests 1 through 8 drive `delete_candidate` directly with `CLEANUP_WT_CLEAR_DISPOSABLE=1` set in
the environment, so none of them observes the wrapper's flag pre-pass at
`scripts/bash/cleanup-worktrees.sh:145`, which is the line that sets that variable in production.
The gap was identified at the P7-T2 lint gate and is remediated by the two wrapper-driven tests
added in this suite after this run; see
`evidence/qa-gates/wrapper-clear-flag-mutation.<timestamp>.md`. That remediation raises this
suite's test count from eleven to thirteen, so a later run of the same command reports 13 ok.
