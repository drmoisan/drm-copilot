# Pinned `WORKTREE|` Assertions Unmodified (preserves AC5 and AC6)

Timestamp: 2026-09-07T16-30
Task: [P6-T11]

## Command 1 — removed `WORKTREE` assertion lines across the four pinned suites

Command: `git diff a36b6dca7809e456f00c7d5b01eec5da49f7fca0 -- tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_hard_failures.bats tests/shell/test_cleanup_worktrees_enumeration.bats | awk '/^-/ && !/^---/ && /WORKTREE/ {n++} END {print n+0}'`
EXIT_CODE: 0

Output:

```
0
```

## Command 2 — enumeration suite byte-unmodified

Command: `git diff a36b6dca7809e456f00c7d5b01eec5da49f7fca0 -- tests/shell/test_cleanup_worktrees_enumeration.bats`
EXIT_CODE: 0

Output: 0 lines (empty).

## Why the diff is anchored at the merge base

The diff is anchored at the fixed merge-base commit `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`
rather than at the moving remote base ref `origin/epic/cleanup-merged-worktrees-hardening-integration`.
That ref has advanced past the merge base, so anchoring at it would attribute sibling child 634's
changes to this branch. All four files exist at the merge base, so the anchor is valid for each and
the question the diff answers is what this whole branch did to them.

## Why removed lines only are counted

The `awk` filter counts lines beginning with a single `-` and excludes the `---` file header, so it
counts removed content lines only. Added lines are deliberately not counted: [P5-T2] adds a
`WORKTREE` assertion line to `tests/shell/test_cleanup_worktrees_cli.bats` carrying the five-field
detached record literal. Counting added lines as well would make this condition unsatisfiable once
[P5-T2] ran, so it would gate nothing.

## Interpretation

The `awk` stage printed `0`, so no removed line in any of the four pinned suites carries a
`WORKTREE` assertion. No pinned assertion literal was deleted or reworded in
`test_cleanup_worktrees_classification.bats`, `test_cleanup_worktrees_cli.bats`,
`test_cleanup_worktrees_hard_failures.bats`, or `test_cleanup_worktrees_enumeration.bats`.

Command 2 produced empty output, so `tests/shell/test_cleanup_worktrees_enumeration.bats` is
byte-unmodified against the merge base. That file was not touched by any task in this cycle, which
is Do-Not-Do list item 6.

Together these two observations preserve AC5 and AC6, whose record-shape assertions live in the
pinned suites.

Output Summary: the `awk` stage printed `0`, meaning no removed line in the four pinned suites
carries a `WORKTREE` assertion. The second command produced empty output, meaning
`tests/shell/test_cleanup_worktrees_enumeration.bats` is byte-unmodified against the merge base
`a36b6dca7809e456f00c7d5b01eec5da49f7fca0`. AC5 and AC6 are preserved.
