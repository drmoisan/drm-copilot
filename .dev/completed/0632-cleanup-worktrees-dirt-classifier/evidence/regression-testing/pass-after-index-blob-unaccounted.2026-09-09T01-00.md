# Pass-after — N3: the index blob is now accounted for before a disposable verdict

Timestamp: 2026-09-09T01-00

Task: [P2-T3]

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
EXIT_CODE: 0

Run from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, after
[P2-T1] and [P2-T2] applied the D1 fix to `scripts/bash/cleanup_worktrees_dirt_lib.sh`.

TapPlanLine: `1..17`

Lines beginning `ok `: 17
Lines beginning `not ok `: 0

## Why the registry suite is deliberately absent from this command

`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` is **not** included here. Its
Invariant 2 requires at least one registry row per marker id, and the three markers [P2-T1]
added have no rows until [P2-T4] appends them. Including that suite in this command would
make this task's acceptance unsatisfiable by construction. The registry suite is run green at
the end of the phase in [P2-T6].

## The six tests, verbatim from the captured stream

```
ok 12 dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE
ok 13 dirt_index_and_worktree_delta: an MM entry whose working-tree blob is in history is UNIQUE
ok 14 dirt_index_and_worktree_delta: a UU entry whose working-tree content is on main is UNIQUE
ok 15 dirt_index_and_worktree_delta: the M-space control entry in the same fixture is still CONTENT_ON_MAIN
ok 16 every disposable verdict is backed by a git read of every location holding that entry's content
ok 17 every classifier-relevant status-code class is covered by a checked-in dirt scenario
```

Lines 12, 13, 14 and 16 were `not ok` in the fail-before record
(`evidence/regression-testing/fail-before-index-blob-unaccounted.2026-09-09T00-30.md`) and
are `ok` here. Lines 15 and 17 were `ok` in both runs, which is the required direction: the
M-space control establishes that the fix did not simply disable rungs 4 and 5, and the
status-code coverage floor establishes that the corpus still carries every class the
accounting gate is about.

The eleven pre-existing tests in the failclosed suite (`ok 1` through `ok 11`) pass unchanged.

## The post-fix record stream, obtained through the same seam

`classify_worktree_dirt /repo-wt/dirt` under `CLEANUP_WT_STUB_SCENARIO` pointed at
`tests/fixtures/cleanup_worktrees/scenarios/dirt_index_and_worktree_delta`, with the stub
argv log discarded. Verbatim:

```
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/b.cs
DIRTFILE|/repo-wt/dirt|UNIQUE||UU|src/c.cs
DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||M |docs/tracked.md
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

The classification exited 0.

The stream contains the literal `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|` and does **not** contain
the literal `ALL_DISPOSABLE`.

## Direct comparison with the pre-fix stream

| Entry | Before the fix | After the fix |
|---|---|---|
| `MM src/a.cs` | `CONTENT_ON_MAIN` | `UNIQUE` |
| `MM src/b.cs` | `CONTENT_IN_HISTORY|ffff3333` | `UNIQUE` |
| `UU src/c.cs` | `CONTENT_ON_MAIN` | `UNIQUE` |
| `M  docs/tracked.md` | `CONTENT_ON_MAIN` | `CONTENT_ON_MAIN` |
| aggregate | `ALL_DISPOSABLE|ffff3333` | `HAS_UNIQUE|` |

Three verdicts changed and one did not. The aggregate moved from `ALL_DISPOSABLE`, which is
the condition `clear_disposable_dirt` requires before running `reset --hard` and `clean -fd`,
to `HAS_UNIQUE`, which refuses the clear. The record count is 5 in both runs: the fix changes
verdicts, not the number of records.

`src/a.cs` reaches rung 5 with blob `aaaa1111` and no `log.find-object.aaaa1111` fixture, so
`found` is empty and rung 6 resolves it. `src/c.cs` reaches rung 5 with blob `cccc1111` and
no fixture, likewise. `src/b.cs` reaches rung 5, finds `ffff3333`, and is stopped by the new
`guard:rung5-index-blob-unaccounted` gate. That is the derivation the plan's D2 states, and
the observed stream matches it.

Output Summary: 17 planned, 17 `ok`, 0 `not ok`, exit code 0. The four fail-before failures
are closed and both positive controls still pass. The post-fix record stream carries
`DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|` and no `ALL_DISPOSABLE`.
