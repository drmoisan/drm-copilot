# Bash Per-File Coverage for the Abandon Script (P11-T4)

Timestamp: 2026-09-29T19-13
Command: gh run download 36645685724 -n shell-coverage -D SCRATCH/shell-cov-final ; poetry run python SCRATCH/cobertura-files.py SCRATCH/shell-cov-final/cov.xml abandon-parallel-item.sh compute-cohorts.sh
EXIT_CODE: 0
Output Summary:
COBERTURA-TOTAL line-rate=0.934
COBERTURA file=.claude/lib/bash/abandon-parallel-item.sh line-rate=0.946
COBERTURA file=.claude/lib/bash/compute-cohorts.sh line-rate=0.925

- No `MISSING` line.
- Every `COBERTURA file=` line whose path ends with `abandon-parallel-item.sh` shows a line-rate of
  at least 0.85 (0.946).
- Run 36645685724 is the P11-T2 run at FINAL_SHA `4c87951d9f4ee93d0c587b8db797719031f933db`.
