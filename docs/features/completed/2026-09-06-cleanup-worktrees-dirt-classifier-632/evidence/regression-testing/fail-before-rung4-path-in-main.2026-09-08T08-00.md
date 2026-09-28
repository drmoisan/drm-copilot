# Fail-before — rung 4's tracked half resolves from a pathspec that matched nothing (N1)

Timestamp: 2026-09-08T08-00
Task: [P1-T5]  `[expect-fail]`
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
EXIT_CODE: 1
ExpectedExitCode: 1

This run was taken **before any library change**. `scripts/bash/cleanup_worktrees_dirt_lib.sh`
is unmodified at this point: the branch carries only the new fixture directory
`tests/fixtures/cleanup_worktrees/scenarios/dirt_tracked_staged_only_blob/` and the two
tests added by [P1-T3] and [P1-T4]. A failing run is the expected and required outcome of
this task; it is not a defect to be fixed here. [P1-T6] applies the fix and [P1-T8] records
the passing run.

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
not ok 8 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE
# (in test file tests/shell/test_cleanup_worktrees_dirt_failclosed.bats, line 171)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||AD|staged_only.md'* ]]' failed
ok 9 dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN
```

## The two lines this task's acceptance names

The negative direction fails, as required:

```
not ok 8 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE
```

The positive direction passes, as required:

```
ok 9 dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN
```

The second line is what makes the first line meaningful. It proves the fixture actually
drives the ladder rather than failing to load: the same scenario directory, read through
the same `dirt` helper, produces a correct `CONTENT_ON_MAIN` verdict for its second entry.
A fixture that did not load at all would fail both tests, and the `not ok` on the first
would then carry no information about rung 4.

## What the failure demonstrates

The failing assertion is the first one in the test — the absence of the required record:

```
`[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||AD|staged_only.md'* ]]' failed
```

At this commit the `AD staged_only.md` entry does not reach `UNIQUE`. Its
`diff-quiet..staged_only.md.rc` fixture supplies exit 0, and the unguarded rung 4 reads
that exit as "the content is on main" even though the pathspec matched nothing, so the
entry resolves `CONTENT_ON_MAIN`, the worktree aggregates `ALL_DISPOSABLE`, and the
clearing path is authorized over content that exists only as a staged blob. That is
finding N1 reproduced through the checked-in stub seam.

Output Summary: 9 tests, 8 ok, 1 not ok, exit 1 — the expected fail-before result. Test 8
(the AD entry, negative direction) fails; test 9 (the tracked entry, positive direction)
passes, confirming the fixture drives the ladder. Seven pre-existing tests in the suite are
unaffected.
