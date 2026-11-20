# Phase 2 sibling check — the six dirt suites, and the entry D1 identified as at risk

Timestamp: 2026-09-09T01-00

Task: [P2-T6]

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`
EXIT_CODE: 0

Run from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, after
[P2-T1] through [P2-T5]. The registry suite is included here, unlike in [P2-T3], because
[P2-T4] has since appended the three rows its Invariant 2 requires.

TapPlanLine: `1..70`

Lines beginning `ok `: 70
Lines beginning `not ok `: 0

Phase 2 left the tree consistent across all six dirt suites.

## The sibling finding: `dirt_staged_tree_worktree_delta`'s `MM src/a.cs` entry is unchanged

D1 identifies this entry as the one at risk from the placement of the new gates. It is the
only checked-in entry outside the new scenario whose X and Y columns are both content-bearing,
so it is the only pre-existing entry for which `bothloc` is set to 1. The registry's
`hash-object-hard-fail` **literal** row is keyed to this scenario
(`tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`), and that row would go inert on
both channels if this entry stopped reaching the `hash-object` read. That is the concrete
reason D1 nests the gates at the two positive emissions rather than short-circuiting after
rung 3.

**The scenario's `diff-quiet..src_a.cs.rc` value is `1`.** Read directly from
`tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_worktree_delta/diff-quiet..src_a.cs.rc`.
That value is what makes the entry a rung-4 miss, so it advances past rung 4's positive
branch and reaches the `hash-object` read before either new gate can suppress an emission.

**The entry's verdict is `UNIQUE` both before and after this phase.**

Before, replayed against the pre-change classifier library extracted from commit `4cbc62b7`
through the same `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO` seam:

```
stub-git: --no-optional-locks -C /repo-wt/dirt status --porcelain
stub-git: --no-optional-locks -C /repo-wt/dirt rev-list --max-count=201 HEAD
stub-git: --no-optional-locks -C /repo-wt/dirt diff-index --cached --quiet eeee7777 --
stub-git: --no-optional-locks -C /repo-wt/dirt diff --quiet main -- src/a.cs
stub-git: --no-optional-locks -C /repo-wt/dirt hash-object -- src/a.cs
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

After, against the working-tree classifier library as this phase leaves it:

```
stub-git: --no-optional-locks -C /repo-wt/dirt status --porcelain
stub-git: --no-optional-locks -C /repo-wt/dirt rev-list --max-count=201 HEAD
stub-git: --no-optional-locks -C /repo-wt/dirt diff-index --cached --quiet eeee7777 --
stub-git: --no-optional-locks -C /repo-wt/dirt diff --quiet main -- src/a.cs
stub-git: --no-optional-locks -C /repo-wt/dirt hash-object -- src/a.cs
DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs
DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs
DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|
```

**The scenario's stub argv log is unchanged.** The two logs above are identical line for
line: five invocations in the same order, ending with `hash-object -- src/a.cs`. The record
stream is likewise identical. The entry still reaches the `hash-object` read, so the
`hash-object-hard-fail` literal row keyed to this scenario keeps separating, which the
registry suite's `ok 2` in this run confirms independently.

## Summary of the four required observations

| Observation | Value |
|---|---|
| `diff-quiet..src_a.cs.rc` | `1` |
| Verdict before this phase | `UNIQUE` |
| Verdict after this phase | `UNIQUE` |
| Stub argv log differs | **No** — byte-identical before and after |

Output Summary: 70 planned, 70 `ok`, 0 `not ok`, exit code 0 across the six dirt suites. The
sibling entry D1 named as at risk is unchanged by this phase on both channels, and its
`diff-quiet..src_a.cs.rc` fixture value of `1` is the mechanism that keeps it reaching the
`hash-object` read.
