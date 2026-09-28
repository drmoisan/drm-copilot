# Fail-before — R1: rung 1 ignores the porcelain Y column

Timestamp: 2026-09-08T06-05

Task: [P2-T3] of `remediation-plan.2026-09-08T05-00.md` — tagged `[expect-fail]`
Finding: R1 (code review F1; policy audit P18)

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`

EXIT_CODE: 1
ExpectedExitCode: 1

Run against the **unfixed** `scripts/bash/cleanup_worktrees_dirt_lib.sh`, before [P2-T4]
gates rung 1 on the Y column.

## Output, verbatim

```
1..2
not ok 1 dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE
# (in test file tests/shell/test_cleanup_worktrees_dirt_failclosed.bats, line 68)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs'* ]]' failed
ok 2 dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT
```

## Both halves

The failing half is required and is present: the `MM src/a.cs` entry is labelled
`STAGED_TREE_IS_COMMIT|eeee7777` by the unfixed rung 1, so the assertion that it is `UNIQUE`
fails. The worktree aggregate is `ALL_DISPOSABLE`, which is the state in which
`--clear-disposable` runs `reset --hard` and destroys the unstaged delta.

The passing half is equally required and is present: `ok 2` shows the `M ` entry in the
*same* fixture still resolves `STAGED_TREE_IS_COMMIT`. That proves the fixture is not simply
broken — the probe was issued, `rev-list.HEAD.out` supplied its two candidates, the HEAD sha
`dddd9999` was dropped, and `diff-index.eeee7777.rc` of `0` produced the match. Without this
half, a fixture that produced no records at all would satisfy the failing half.

The two entries differ **only** in the porcelain Y column, so the same once-per-worktree
probe result serves both directions and no unrelated change can satisfy the pin.

Output Summary: The suite exits 1 with 1 `not ok` and 1 `ok`, exactly as the expect-fail
condition requires. The defect is reproduced at the level of the emitted record: the unfixed
classifier answers an index-only question and applies the answer to an entry whose working
tree also differs from the index.
