# P5-T10 — byte-identity regression suite after the call sites are wired

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-28Z (nominal run-timestamp scheme, see the P5-T3 artifact).
Run by: atomic-executor, directly (`npx --yes bats`, bats 1.13.0).

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_regression.bats`
EXIT_CODE: 0

## 11 ok / 0 not ok

```
1..11
ok 1 report mode output for merged_with_worktree is byte-identical to the checked-in expected output
ok 2 report mode output for merged_no_worktree is byte-identical to the checked-in expected output
ok 3 report mode output for unmerged is byte-identical to the checked-in expected output
ok 4 report mode output for content_neutral is byte-identical to the checked-in expected output
ok 5 report mode output for residual_on_main is byte-identical to the checked-in expected output
ok 6 report mode output for residual_unique_doc is byte-identical to the checked-in expected output
ok 7 report mode output for current_exclusion is byte-identical to the checked-in expected output
ok 8 report mode output for main_divergence is byte-identical to the checked-in expected output
ok 9 apply mode without --clear-disposable over dirty_worktree is byte-identical
ok 10 apply mode without --clear-disposable over dirty_worktree_status_error is byte-identical
ok 11 report mode over a worktree with zero status entries emits no DIRTFILE or DIRTSUM record
```

Output Summary: the same eleven tests passed in the pre-change run recorded by P3-T1 at
`evidence/regression-testing/regression-byte-identity-prechange.2026-09-08T01-30.md`
(`EXIT_CODE: 0`, `11 passed, 0 failed`). The suite is a pin rather than an expect-fail gate: it
must be green both before and after the call-site wiring, and it is. The eight report scenarios
and the two apply scenarios therefore produce byte-identical output with the classifier call
site present and the flag not supplied.
