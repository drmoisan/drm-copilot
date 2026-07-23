# Phase 3 Fix — Shell QC Format + Check (Cycle 2 / CR-1), Issue #396

Timestamp: 2026-07-22T20-58

Command:

```
bash scripts/bash/shell-qc.sh format
bash scripts/bash/shell-qc.sh check
```

EXIT_CODE: 0

Output Summary: After the CR-1 call-site fixes (guarded parent-shell capture at `parse_worktree_list`, `compute_protected`, `classify_branch` x2, `run_report`, `classify_cherry_equivalent`, and `select_cherry_pick_candidates`; `CHERRY_ERROR` internal verdict and `ANCESTRY_ERROR` hard-error mapping; header rewrites), the format stage exited 0 with no output and the check stage (shfmt diff mode plus shellcheck per file) exited 0 with no findings in a single pass. No restart was required. `bash -n` passes on both `.sh` libraries. Post-fix line counts: `cleanup_worktrees_lib.sh` 411, `cleanup_worktrees_enumerate_lib.sh` 209 (both <= 500).
