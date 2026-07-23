# Cycle-3 File-Size Cap Compliance (P5-T6), Issue #396

Timestamp: 2026-07-22T22-21

Command:

```
wc -l scripts/bash/cleanup_worktrees_lib.sh \
      scripts/bash/cleanup_worktrees_enumerate_lib.sh \
      scripts/bash/cleanup_worktrees_actions_lib.sh \
      scripts/bash/cleanup-worktrees.sh \
      tests/shell/test_cleanup_worktrees_hard_failures.bats \
      tests/fixtures/cleanup_worktrees/stub-bin/git
```

EXIT_CODE: 0

Output Summary (line counts; 500-line cap):

| File | Lines | <= 500 |
|---|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 476 | yes |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | yes |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 382 | yes |
| `scripts/bash/cleanup-worktrees.sh` | 92 | yes |
| `tests/shell/test_cleanup_worktrees_hard_failures.bats` | 172 | yes |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 208 | yes |

Every listed file is <= 500 lines. No split branch (P4-T2) was required. Pre-fix vs
post-fix growth of the three modified libraries: classification 411 -> 476 (+65),
enumerate 209 -> 236 (+27), actions 301 -> 382 (+81).
