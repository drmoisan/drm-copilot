# Final QC — 500-line file size limit

Timestamp: 2026-09-08T07-25

Task: [P8-T4] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh \
  scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_report_records_lib.sh \
  scripts/bash/cleanup-worktrees.sh tests/fixtures/cleanup_worktrees/stub-bin/git \
  tests/shell/test_cleanup_worktrees_*.bats
```

The `tests/shell/test_cleanup_worktrees_*.bats` glob now matches
`tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` as well, which is the file
[P8-T4] adds to the [P0-T8] set.

EXIT_CODE: 0

| Lines | File | Baseline | Delta |
|---:|---|---:|---:|
| 463 | `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 425 | +38 |
| 496 | `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 0 |
| 437 | `scripts/bash/cleanup_worktrees_actions_lib.sh` | 437 | 0 |
| 476 | `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 476 | 0 |
| 187 | `scripts/bash/cleanup-worktrees.sh` | 187 | 0 |
| 362 | `tests/fixtures/cleanup_worktrees/stub-bin/git` | 362 | 0 |
| 259 | `tests/shell/test_cleanup_worktrees_classification.bats` | 259 | 0 |
| 150 | `tests/shell/test_cleanup_worktrees_cli.bats` | 150 | 0 |
| 79 | `tests/shell/test_cleanup_worktrees_consolidation.bats` | 79 | 0 |
| 153 | `tests/shell/test_cleanup_worktrees_deletion.bats` | 153 | 0 |
| 329 | `tests/shell/test_cleanup_worktrees_detached.bats` | 329 | 0 |
| 377 | `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | 300 | +77 |
| 302 | `tests/shell/test_cleanup_worktrees_dirt_clear.bats` | 283 | +19 |
| 158 | `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` | new | +158 |
| 143 | `tests/shell/test_cleanup_worktrees_dirt_regression.bats` | 126 | +17 |
| 113 | `tests/shell/test_cleanup_worktrees_enumeration.bats` | 113 | 0 |
| 182 | `tests/shell/test_cleanup_worktrees_hard_failures.bats` | 182 | 0 |
| 132 | `tests/shell/test_cleanup_worktrees_report_records.bats` | 132 | 0 |
| 34 | `tests/shell/test_cleanup_worktrees_scan_helper.bats` | 34 | 0 |
| 28 | `tests/shell/test_cleanup_worktrees_scan_seam.bats` | 28 | 0 |

Total across the measured set: 4860 lines.

Output Summary: The maximum is `496` for `scripts/bash/cleanup_worktrees_lib.sh`, unchanged
from the [P0-T8] baseline because Binding Constraint 1 excluded that file from modification
and this plan did not modify it. Every recorded count is at or below 500. The one production
file this plan changed, `scripts/bash/cleanup_worktrees_dirt_lib.sh`, grew from 425 to 463
lines and retains 37 lines of headroom. The largest test file is
`tests/shell/test_cleanup_worktrees_dirt_classify.bats` at 377 lines.
