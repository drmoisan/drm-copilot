# Pass-after — rung 4's tracked half is narrowed by a path-presence read (N1)

Timestamp: 2026-09-08T08-00
Task: [P1-T8]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
EXIT_CODE: 0

TAP plan line: 1..9
OkCount: 9
NotOkCount: 0

## Verbatim TAP output

```
1..9
ok 1 dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE
ok 2 dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT
ok 3 dirt_staged_tree_no_match: a staged index matching no ancestor tree is UNIQUE not STAGED_TREE_IS_COMMIT
ok 4 dirt_staged_probe_revlist_error: a rev-list hard failure maps the staged entry to UNIQUE
ok 5 dirt_staged_probe_diffindex_error: a diff-index exit above one maps the staged entry to UNIQUE
ok 6 dirt_tracked_read_errors: a rung-3 diff read failure and a rung-4 probe failure both map to UNIQUE
ok 7 dirt_history_read_error: a find-object read failure maps the untracked entry to UNIQUE
ok 8 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE
ok 9 dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN
```

## The line this task's acceptance names

```
ok 8 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE
```

Test 8 was `not ok` in the fail-before run recorded at
`evidence/regression-testing/fail-before-rung4-path-in-main.2026-09-08T08-00.md` and is
`ok` here. The only change between the two runs is [P1-T6]'s narrowing of rung 4's tracked
half and [P1-T7]'s header paragraph; no fixture and no assertion was altered.

Test 9 is `ok` in both runs. That is the required outcome for the positive direction: the
narrowing rejects the empty-pathspec case without disabling the rung, so a tracked entry
whose content genuinely equals main's still resolves `CONTENT_ON_MAIN`.

The seven pre-existing tests in the suite are `ok` in both runs, so the narrowing disturbed
none of the staged-tree or fail-closed pins that cycle 1 delivered.

Output Summary: 9 tests, 9 ok, 0 not ok, exit 0. The fail-before/pass-after pair is closed:
test 8 moved from `not ok` to `ok`, test 9 held at `ok`, and the seven pre-existing tests
were unaffected.
