# P3-T3 [expect-fail] — classifier suite run before the library exists

Timestamp: 2026-09-08T02-05
Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_classify.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

Commit under test: `9b8e226637633ab587ee507a4fba2fb6bd1f5c82`
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Tree state at capture: `scripts/bash/cleanup_worktrees_dirt_lib.sh` does not exist.

## Route taken

The bash toolchain is denied to the delegated `atomic-executor`, so per EA-4 the
orchestrator executed this gate from its own context and returned the measurement. The
plan's `wsl -d Ubuntu -- bash -lc` command form is superseded by EA-1; the executed form is
`npx --yes bats <suite>` with bats 1.13.0, which is the version the CI runner installs.

Output Summary: 0 tests reported `ok` and all 19 reported `not ok`. The cause is the absence
of `scripts/bash/cleanup_worktrees_dirt_lib.sh`: every test in the suite sources that file
through the `DIRTLIB` variable defined in `setup`, so the `source` fails and
`classify_worktree_dirt` is undefined for every test, including test 19, which drives
`run_report`. No test in the suite can pass in this state, which is the required
expect-fail outcome for the whole suite.

## Prior run at `aa0d619d` and the defect it exposed

An earlier execution of this same gate, at commit
`aa0d619d9e3b4c7e3ecca027fb4978541f265407`, measured 1 `ok` and 18 `not ok`. The single
pass was:

```
ok 12 dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths
```

That test asserted only the absence of lower-rung git reads, which holds trivially in a
tree where no classification runs at all, so it could not fail in the direction AC-09
depends on. A positive control asserting that the `STAGED_TREE_IS_COMMIT` record IS emitted
for both staged paths was added in commit `9b8e226637633ab587ee507a4fba2fb6bd1f5c82`. The
control is asserted over the merged `$output` because the records are written to stdout
while the stub argv log is written to stderr; the four absence assertions continue to read
the stderr-filtered `$log`.

The re-run at `9b8e2266` recorded above is the confirming measurement: test 12 now fails
alongside the other eighteen, so the gate is discriminating in both directions.

Both runs and the intervening remediation are also recorded in
`expect-fail-gates.2026-09-08T02-05.md` in this directory.
