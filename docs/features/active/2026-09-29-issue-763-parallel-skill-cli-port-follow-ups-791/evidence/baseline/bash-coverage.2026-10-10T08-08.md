# Baseline — Bash Coverage

Timestamp: 2026-10-10T08-08
Task: [P0-T12]
Command: sh scripts/bash/shell-qc.sh test --coverage (not run locally)
EXIT_CODE: N/A
CI-DEFERRED: yes

Output Summary:
- kcov has no local route in this environment, so bash coverage is not measured locally.
- `.claude/lib/bash/parallel-mutation.sh` and `.claude/lib/bash/remove-parallel-item.sh` do not exist at baseline (0 measured lines each).
- The post-change per-file values are produced by `.github/workflows/_shell-coverage.yml` (called from `.github/workflows/ci.yml`) in the later execution run.
