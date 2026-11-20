# Report mode is still non-mutating after the new probe (P5-T5)

Timestamp: 2026-09-08T10-00
WorkingDirectory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 0

## TAP figures

TapPlanLine: `1..14`
OkCount: 14
NotOkCount: 0

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

`ok 10` is the test that asserts report mode issues no mutating command and redirects no index, and
it passes with the new probe in place.

## The subcommand P1-T6 added is a read

The subcommand added by P1-T6 is **`rev-parse`**, issued as
`cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet "main:$rel"` at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:312`. `rev-parse --verify --quiet <rev>` resolves a
revision to an object name and prints it. **It reads and does not write.** It touches neither the
index nor the object database, so report mode remains non-mutating.

`ls-files --error-unmatch` was rejected for this probe because an `AD` path is present in the index
and that probe exits 0 for exactly the entry the guard must catch; `rev-parse --verify --quiet
main:<path>` answers whether `main` has content at the path, which is the question the inference
rests on, and it is a read.

## Stub digest

Command: `md5sum tests/fixtures/cleanup_worktrees/stub-bin/git`
EXIT_CODE: 0

StubDigest: a701f6cec32dc230b60d362f6266612b
BaselineStubDigest: a701f6cec32dc230b60d362f6266612b (recorded by P0-T8 in
`evidence/remediation-baseline/file-size-limit.2026-09-08T07-30.md:42`)

The recomputed digest **equals** the cycle-start value, which is the observation showing this cycle
added no arm to the stub. The `rev-parse --verify --quiet <ref>` arm the new probe uses was already
present, keyed as `rev-parse.verify.<sanitized ref>`, so no stub change was required.

The comparison is made against the cycle-start digest rather than against the epic base, because
cycle 1 legitimately changed the stub and a base-anchored diff would report those changes as this
cycle's.

## Output Summary

14 ok, 0 not ok, exit code 0. The added subcommand is `rev-parse`, a read. The stub digest is
unchanged at `a701f6cec32dc230b60d362f6266612b`. Acceptance met.
