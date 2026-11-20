# Final QA — report mode is still non-mutating

Timestamp: 2026-09-09T02-30
Task: [P5-T5]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats`

EXIT_CODE: 0

TAP plan line: `1..14`
`ok` count: 14
`not ok` count: 0

## Output Summary

```
1..14
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
ok 12 dirt_clear_all_disposable through the wrapper: --apply --clear-disposable arms the clearing sequence
ok 13 dirt_clear_all_disposable through the wrapper: apply mode without the flag clears nothing
ok 14 dirt_clear_reset_failed: a non-zero reset reports FAILED, runs no clean, and retries no removal
```

Test 10 is the direct non-mutation assertion: report mode issues no mutating git command
and redirects no index.

## No git read of any new shape

This cycle added **no** git read of any new shape. The `bothloc` flag D1 introduces is
derived entirely from the porcelain status text the classifier already holds in hand — the
X and Y characters of the entry's two-character status field — and issues no git invocation
of its own. The two gates it feeds only suppress an emission; they add no probe. Because no
new invocation shape exists, no new arm was needed in the git stub.

## Stub digest

StubDigest: `a701f6cec32dc230b60d362f6266612b`

Command: `md5sum tests/fixtures/cleanup_worktrees/stub-bin/git`

P0-T8 recorded `StubDigest: a701f6cec32dc230b60d362f6266612b` at cycle start
(`evidence/remediation-baseline/file-size-limit.2026-09-09T00-00.md:42`). The recomputed
value is identical, which is the observation that this cycle added no arm to the stub and
therefore introduced no git subcommand that writes the index or the object database.

Result: pass. Exit 0, 14 `ok`, 0 `not ok`, stub digest unchanged.
