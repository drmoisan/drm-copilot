# P7-T7 — 500-line cap over every shell file this work created or changed

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-42Z (nominal run-timestamp scheme).
Run by: atomic-executor, directly. Measured at execution time, not taken from the research
projection.

Command: `wc -l` over the fourteen files the plan enumerates.
EXIT_CODE: 0

```
   425 scripts/bash/cleanup_worktrees_dirt_lib.sh
   496 scripts/bash/cleanup_worktrees_lib.sh
   437 scripts/bash/cleanup_worktrees_actions_lib.sh
   187 scripts/bash/cleanup-worktrees.sh
   362 tests/fixtures/cleanup_worktrees/stub-bin/git
   300 tests/shell/test_cleanup_worktrees_dirt_classify.bats
   283 tests/shell/test_cleanup_worktrees_dirt_clear.bats
   126 tests/shell/test_cleanup_worktrees_dirt_regression.bats
   150 tests/shell/test_cleanup_worktrees_cli.bats
   259 tests/shell/test_cleanup_worktrees_classification.bats
    79 tests/shell/test_cleanup_worktrees_consolidation.bats
   153 tests/shell/test_cleanup_worktrees_deletion.bats
   113 tests/shell/test_cleanup_worktrees_enumeration.bats
   182 tests/shell/test_cleanup_worktrees_hard_failures.bats
  3552 total
```

Output Summary: every count is at or under 500. The largest is
`scripts/bash/cleanup_worktrees_lib.sh` at 496, four lines below the cap; it is unchanged by the
Phase 7 remediation, which touched only `scripts/bash/cleanup-worktrees.sh` (179 to 187, +8 for
the suppression and its justification) and
`tests/shell/test_cleanup_worktrees_dirt_clear.bats` (224 to 283, +59 for the wrapper-driven
pair, its helper, and the two-driver header paragraph).

P0-T8's extraction contingency did not execute, so
`scripts/bash/cleanup_worktrees_report_lib.sh` does not exist and is not in the measured list.
