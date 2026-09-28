# P5-T1 — dirt library added to the source chain of all nine suites

Timestamp: 2026-09-08T02-30
Task: [P5-T1]
Command: npx --yes bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
EXIT_CODE: 0

## Output Summary

11 `ok`, 0 `not ok`, exit 0. Sourcing `scripts/bash/cleanup_worktrees_dirt_lib.sh` into the nine
suites changed no `run_report` or `run_apply` output: the eight report-mode byte-identity tests, the
two apply-mode byte-identity tests, and the zero-status-entry test all still pass against the
libraries as they stand before the [P5-T3] call site lands.

## Static half of the acceptance clause

`grep -c "cleanup_worktrees_dirt_lib.sh"` reports a non-zero count for every one of the nine files:

```
tests/shell/test_cleanup_worktrees_classification.bats
tests/shell/test_cleanup_worktrees_cli.bats
tests/shell/test_cleanup_worktrees_consolidation.bats
tests/shell/test_cleanup_worktrees_deletion.bats
tests/shell/test_cleanup_worktrees_enumeration.bats
tests/shell/test_cleanup_worktrees_hard_failures.bats
tests/shell/test_cleanup_worktrees_dirt_classify.bats
tests/shell/test_cleanup_worktrees_dirt_clear.bats
tests/shell/test_cleanup_worktrees_dirt_regression.bats
```

Each defines `DLIB` in `setup` and adds it to the driver helper's source list. No `@test` body and no
assertion was edited in any suite.

## Additional suites rewired beyond the nine the task names, and the gate that isolates them

Two further suites were rewired in the same micro-action:
`tests/shell/test_cleanup_worktrees_detached.bats` and
`tests/shell/test_cleanup_worktrees_report_records.bats`. Both drive `run_report`. Without the
rewiring each would have invoked an undefined `classify_worktree_dirt` the moment [P5-T3] added the
report-mode call site, and the resulting failure would have been attributable to the sourcing gap
rather than to the call site.

Isolation gate, run before [P5-T3] landed:

Command: npx --yes bats tests/shell/test_cleanup_worktrees_detached.bats tests/shell/test_cleanup_worktrees_report_records.bats
EXIT_CODE: 0
Result: 36 `ok`, 0 `not ok`.

Recording this run separately is what makes a later failure in either suite attributable to the
[P5-T3] call-site change rather than to this sourcing edit. Both suites were green under the sourcing
edit alone.

## Command form note

The plan writes bats gates in the
`wsl -d Ubuntu -- bash -lc 'cd /mnt/c/... && bats ...'` form. The orchestrator executes them as
`npx --yes bats <suite>` from the Windows worktree; bats 1.13.0 via npx matches the CI runner
version. The suite under test and the tree under test are unchanged.
