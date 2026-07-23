# Remediation Baseline — Pre-Change Line Counts (Cycle 2 / CR-1), Issue #396

Timestamp: 2026-07-22T20-42

Command:

```
wc -l scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_enumeration.bats
```

EXIT_CODE: 0

Output Summary: pre-change line counts (all <= 500):

| File | Lines |
|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 499 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 300 |
| `scripts/bash/cleanup-worktrees.sh` | 86 |
| `tests/shell/test_cleanup_worktrees_classification.bats` | 89 |
| `tests/shell/test_cleanup_worktrees_enumeration.bats` | 101 |

`cleanup_worktrees_lib.sh` is at 499 lines, one line below the 500-line cap. This confirms the Design Decision #4 rationale: the CR-1 fix adds lines, so the pure-move split in Phase 1 is required before the behavior change.
