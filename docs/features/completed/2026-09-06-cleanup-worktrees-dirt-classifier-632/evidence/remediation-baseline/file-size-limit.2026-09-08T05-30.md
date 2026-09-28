# Baseline — 500-line file size limit

Timestamp: 2026-09-08T05-08

Task: [P0-T8] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh \
  scripts/bash/cleanup-worktrees.sh tests/fixtures/cleanup_worktrees/stub-bin/git \
  tests/shell/test_cleanup_worktrees_*.bats
```

EXIT_CODE: 0

| Lines | File |
|---:|---|
| 425 | `scripts/bash/cleanup_worktrees_dirt_lib.sh` |
| 496 | `scripts/bash/cleanup_worktrees_lib.sh` |
| 437 | `scripts/bash/cleanup_worktrees_actions_lib.sh` |
| 476 | `scripts/bash/cleanup_worktrees_report_records_lib.sh` |
| 187 | `scripts/bash/cleanup-worktrees.sh` |
| 362 | `tests/fixtures/cleanup_worktrees/stub-bin/git` |
| 259 | `tests/shell/test_cleanup_worktrees_classification.bats` |
| 150 | `tests/shell/test_cleanup_worktrees_cli.bats` |
| 79 | `tests/shell/test_cleanup_worktrees_consolidation.bats` |
| 153 | `tests/shell/test_cleanup_worktrees_deletion.bats` |
| 329 | `tests/shell/test_cleanup_worktrees_detached.bats` |
| 300 | `tests/shell/test_cleanup_worktrees_dirt_classify.bats` |
| 283 | `tests/shell/test_cleanup_worktrees_dirt_clear.bats` |
| 126 | `tests/shell/test_cleanup_worktrees_dirt_regression.bats` |
| 113 | `tests/shell/test_cleanup_worktrees_enumeration.bats` |
| 182 | `tests/shell/test_cleanup_worktrees_hard_failures.bats` |
| 132 | `tests/shell/test_cleanup_worktrees_report_records.bats` |
| 34 | `tests/shell/test_cleanup_worktrees_scan_helper.bats` |
| 28 | `tests/shell/test_cleanup_worktrees_scan_seam.bats` |

Total across the measured set: 4551 lines.

Output Summary: The maximum is `496` for `scripts/bash/cleanup_worktrees_lib.sh`, 4 lines
below the 500-line cap. That file is excluded from modification by Binding Constraint 1 of
the remediation plan. The file this plan does modify,
`scripts/bash/cleanup_worktrees_dirt_lib.sh`, is at 425 lines and has 75 lines of headroom.
The three bats suites this plan appends to are at 300, 283, and 126 lines.
