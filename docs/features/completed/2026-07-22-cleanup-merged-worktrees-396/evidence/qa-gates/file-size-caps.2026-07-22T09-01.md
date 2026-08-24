# File-Size Caps (Issue #396)

Timestamp: 2026-07-22T09-01

Command: `wc -l` over the three production scripts, the git stub, and every
`tests/shell/test_cleanup_worktrees_*.bats` file.

EXIT_CODE: 0

Output Summary:

| File | Lines | <= 500 |
|---|---|---|
| `scripts/bash/cleanup-worktrees.sh` | 86 | PASS |
| `scripts/bash/cleanup_worktrees_lib.sh` | 499 | PASS |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 300 | PASS |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 193 | PASS |
| `tests/shell/test_cleanup_worktrees_classification.bats` | 89 | PASS |
| `tests/shell/test_cleanup_worktrees_cli.bats` | 63 | PASS |
| `tests/shell/test_cleanup_worktrees_consolidation.bats` | 77 | PASS |
| `tests/shell/test_cleanup_worktrees_deletion.bats` | 82 | PASS |
| `tests/shell/test_cleanup_worktrees_enumeration.bats` | 101 | PASS |

Every listed file is at or under the 500-line cap. The largest is
`cleanup_worktrees_lib.sh` at 499 lines; the two-library split (Planner Decision 1)
keeps enumeration/classification/report in one file and consolidation/deletion/apply in
the other, so neither exceeds the cap.
