# Pass — R3: the remaining fail-closed branches are exercised

Timestamp: 2026-09-08T06-58

Task: [P6-T7] of `remediation-plan.2026-09-08T05-00.md`
Finding: R3 (policy audit P12)

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
```

EXIT_CODE: 0

TAP plan line: `1..55`
Lines beginning `ok`: 55
Lines beginning `not ok`: 0

## The three descriptions quoted in [P6-T4], [P6-T5], and [P6-T6]

```
ok 15 every verdict emitted across the checked-in dirt scenarios is one of the six defined tokens
ok 37 dirt_clear_reset_failed: a non-zero reset reports FAILED, runs no clean, and retries no removal
ok 43 dirt_tracked_read_errors: a rung-3 diff read failure and a rung-4 probe failure both map to UNIQUE
ok 44 dirt_history_read_error: a find-object read failure maps the untracked entry to UNIQUE
```

## Branches this phase closes

Three new checked-in scenarios drive the fail-closed sites that no test previously executed:

- `dirt_tracked_read_errors` — two entries in one fixture. The `*.csproj` entry's rung-3
  content read exits 128, so `dirt_is_build_artifact` returns 2 and the entry must not be
  declared a build artifact on a diff nobody could read. The tracked markdown entry's rung-4
  probe exits 128, which carries no verdict about whether the contents match `main`. Both
  resolve `UNIQUE` and the worktree aggregates `HAS_UNIQUE`.
- `dirt_history_read_error` — `log --find-object` exits 128, the last read in the ladder.
  The fixture also drives the depth fallback: `rev-parse --verify` on the bounded endpoint
  exits 1, so the scan uses the plain `main` ref. The entry resolves `UNIQUE`, and the
  positive control asserts a `--find-object` invocation is present so the absence of
  `CONTENT_IN_HISTORY` is the fail-closed branch rather than a ladder that stopped early.
- `dirt_clear_reset_failed` — `reset --hard` exits 1, the earlier of the clearing sequence's
  two failure sites. `ACTION|dirt-clear|/repo-wt/dirt|FAILED` is emitted, no `clean` is
  issued, and the removal is not retried.

## The membership test

The verdict-token membership test now names all 25 `dirt_*` scenario directories, its
`seen` guard is `30` records rather than `17`, and it carries a companion assertion that the
number of scenarios the loop iterated equals the number of `dirt_*` directories present on
disk. Without that companion, a future scenario could be added to the tree and omitted from
the list, and its verdicts would never be checked for membership.

Output Summary: All 55 tests across the four dirt suites pass with exit code 0 and 0 `not ok`
lines. Every branch this phase targets is now executed by a checked-in scenario.
[P6-T8] demonstrates the fail-closed pins can fail.
