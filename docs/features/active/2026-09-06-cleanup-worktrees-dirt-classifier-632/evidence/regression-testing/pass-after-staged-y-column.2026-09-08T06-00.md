# Pass-after — R1: rung 1 honours the porcelain Y column

Timestamp: 2026-09-08T06-08

Task: [P2-T5] of `remediation-plan.2026-09-08T05-00.md`
Finding: R1

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`

EXIT_CODE: 0

TAP plan line: `1..2`
Lines beginning `ok`: 2
Lines beginning `not ok`: 0

## Output, verbatim

```
1..2
ok 1 dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE
ok 2 dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT
```

Both test descriptions quoted in [P2-T2] carry an `ok` line.

## What changed

`scripts/bash/cleanup_worktrees_dirt_lib.sh` now declares `y="${xy:1:1}"` alongside `x` in
`classify_dirt_entry`, and rung 1's condition additionally requires `$y` to be a single
space. A comment block above the condition records why: the X column answers a question
about the index, `diff-index --cached --quiet` says nothing about a non-space Y column, and
an entry with a non-space Y column therefore falls through to the rungs that compare
working-tree content.

With the gate in place, `MM src/a.cs` declines rung 1, declines rung 3 through the `*)` arm
because the path is not a project file, advances past rung 4's tracked probe on
`diff-quiet..src_a.cs.rc` of `1`, and resolves `UNIQUE` through the `hash-object`-empty
fail-closed branch. The worktree aggregate becomes `HAS_UNIQUE`, which refuses the clear.

`M  src/b.cs`, whose Y column is a space, still resolves `STAGED_TREE_IS_COMMIT|eeee7777`
from the same probe result.

Output Summary: The suite passes with exit code 0, 2 `ok` lines and 0 `not ok` lines. The
same suite exited 1 against the unfixed library, recorded at
`evidence/regression-testing/fail-before-staged-y-column.2026-09-08T06-00.md`, so the pin
is demonstrably able to fail.
