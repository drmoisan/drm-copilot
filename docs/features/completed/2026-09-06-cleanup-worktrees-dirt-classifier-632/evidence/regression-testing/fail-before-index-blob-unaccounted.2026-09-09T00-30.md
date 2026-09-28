# Fail-before — N3: rungs 4 and 5 resolve a disposable verdict without reading the index blob

Timestamp: 2026-09-09T00-30

Task: [P1-T6] `[expect-fail]`

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Run from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, before any
change to `scripts/bash/cleanup_worktrees_dirt_lib.sh`. The library at the time of this run
is the 481-line file [P0-T8] measured; the D1 fix has not been applied.

TapPlanLine: `1..17`

Lines beginning `ok `: 13
Lines beginning `not ok `: 4

## The six tests [P1-T4] and [P1-T5] added, verbatim from the captured stream

```
not ok 12 dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE
# (in test file tests/shell/test_cleanup_worktrees_dirt_failclosed.bats, line 242)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs'* ]]' failed
not ok 13 dirt_index_and_worktree_delta: an MM entry whose working-tree blob is in history is UNIQUE
# (in test file tests/shell/test_cleanup_worktrees_dirt_failclosed.bats, line 258)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/b.cs'* ]]' failed
not ok 14 dirt_index_and_worktree_delta: a UU entry whose working-tree content is on main is UNIQUE
# (in test file tests/shell/test_cleanup_worktrees_dirt_failclosed.bats, line 270)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||UU|src/c.cs'* ]]' failed
ok 15 dirt_index_and_worktree_delta: the M-space control entry in the same fixture is still CONTENT_ON_MAIN
not ok 16 every disposable verdict is backed by a git read of every location holding that entry's content
# (in test file tests/shell/test_cleanup_worktrees_dirt_content_locations.bats, line 170)
#   `[ -z "$offenders" ]' failed
# in-domain records examined: 19
# UNACCOUNTED CONTENT LOCATIONS (scenario:path:verdict:location):
# dirt_index_and_worktree_delta:src/a.cs:CONTENT_ON_MAIN:index dirt_index_and_worktree_delta:src/b.cs:CONTENT_IN_HISTORY:index dirt_index_and_worktree_delta:src/c.cs:CONTENT_ON_MAIN:index
ok 17 every classifier-relevant status-code class is covered by a checked-in dirt scenario
```

## Why each of the two passing lines above matters

`ok 15` is the M-space control entry in the same fixture. It passes, which establishes that
the fixture loads and drives the ladder: the three failures above it are the classifier
returning the wrong verdict, not a scenario that failed to resolve.

`ok 17` is the status-code coverage floor. It passes, which establishes that the accounting
failure at line 16 is a real missing comparison and not an artefact of a status-code class
being absent from the corpus.

## The eleven pre-existing tests in the failclosed suite

All eleven pass unchanged in this run (`ok 1` through `ok 11`), so this branch's additions
introduce no regression in that suite.

## The pre-fix record stream, obtained through the same seam

`classify_worktree_dirt /repo-wt/dirt` under `CLEANUP_WT_STUB_SCENARIO` pointed at
`tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta`, with the stub
argv log discarded. Verbatim:

```
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff3333|MM|src/b.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||UU|src/c.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md
DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333
```

The classification exited 0.

This stream is the data loss on the record rather than described. The aggregate is
`DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333`, which is the condition
`clear_disposable_dirt` requires before it runs `reset --hard` followed by `clean -fd`. Three
of the four entries carry content-bearing letters in both porcelain columns, so each holds an
index blob and a working-tree blob that differ. `reset --hard` drops the index entry, and for
`src/a.cs`, `src/b.cs` and `src/c.cs` those index-side blobs exist in no commit, so they
become unreachable.

The stream reproduces the plan's D2 derivation for the pre-fix state byte for byte.

## What the accounting gate reported

19 in-domain records were examined across the 29 checked-in `dirt_*` scenarios. Three tuples
were unaccounted, all of them the **index** location and all three in the new scenario:

| Scenario | Path | Verdict | Unaccounted location |
|---|---|---|---|
| `dirt_index_and_worktree_delta` | `src/a.cs` | `CONTENT_ON_MAIN` | index |
| `dirt_index_and_worktree_delta` | `src/b.cs` | `CONTENT_IN_HISTORY` | index |
| `dirt_index_and_worktree_delta` | `src/c.cs` | `CONTENT_ON_MAIN` | index |

No other scenario produced an unaccounted tuple, which is the expected result: the accounting
property is satisfied by the rest of the corpus today, and the three offenders are exactly the
records N3 describes.

Output Summary: expected failure recorded. Four `not ok` lines — the three new fail-closed
tests and the accounting gate — against 13 `ok` lines including both positive controls. The
pre-fix record stream contains the literal `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333`.
