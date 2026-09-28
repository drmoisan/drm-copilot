# Pass — R4: the staged-tree rung pinned in five material directions

Timestamp: 2026-09-08T06-46

Task: [P5-T5] of `remediation-plan.2026-09-08T05-00.md`
Finding: R4 (code review F3; policy audit P18)

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`

EXIT_CODE: 0

TAP plan line: `1..5`
Lines beginning `ok`: 5
Lines beginning `not ok`: 0

## Output, verbatim

```
1..5
ok 1 dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE
ok 2 dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT
ok 3 dirt_staged_tree_no_match: a staged index matching no ancestor tree is UNIQUE not STAGED_TREE_IS_COMMIT
ok 4 dirt_staged_probe_revlist_error: a rev-list hard failure maps the staged entry to UNIQUE
ok 5 dirt_staged_probe_diffindex_error: a diff-index exit above one maps the staged entry to UNIQUE
```

All five descriptions are present with an `ok` line: the three quoted in [P5-T4] and the two
quoted in [P2-T2].

## The five material directions

| Direction | Fixture | Verdict |
|---|---|---|
| Probe match | `dirt_staged_tree_worktree_delta` (`M ` entry), and the pre-existing `dirt_staged_tree_is_commit` | `STAGED_TREE_IS_COMMIT` |
| Probe no-match | `dirt_staged_tree_no_match` | `UNIQUE` |
| Probe hard read failure at the `rev-list` site | `dirt_staged_probe_revlist_error` | `UNIQUE` |
| Probe hard read failure at the `diff-index` site | `dirt_staged_probe_diffindex_error` | `UNIQUE` |
| Staged entry with a non-space Y column | `dirt_staged_tree_worktree_delta` (`MM` entry) | `UNIQUE` |

One of the five was pinned before this remediation cycle. Phase 2 added two and this phase
adds the remaining three.

The two hard-failure sites are counted separately because they are different lines reached
through different reads. `diff-index` exits 1 to mean "this tree is not the index", which is
its defined negative answer and advances the ladder; an exit above 1 carries no verdict at
all and must not be collapsed into the no-match case. A test covering only one site would
leave the other unexecuted.

## Positive controls

The two hard-failure tests each assert over the filtered stub argv log that the probe was
actually issued — `rev-list --max-count=201 HEAD` for the first and
`diff-index --cached --quiet eeee7777` for the second. Without those, each test's four
absence assertions would hold in any build where no classification ran at all, including one
with the probe deleted outright.

The `revlist_error` fixture deliberately supplies no lower-rung response: rung 1's `ERROR`
branch prints `UNIQUE` and returns before rung 2 is reached, so a lower-rung file there
would be a fixture entry no code path reads.

Output Summary: The suite passes with exit code 0, 5 `ok` lines and 0 `not ok` lines. The
staged-tree rung is now pinned in all five material directions. [P5-T6] demonstrates that the
three new pins can fail.
