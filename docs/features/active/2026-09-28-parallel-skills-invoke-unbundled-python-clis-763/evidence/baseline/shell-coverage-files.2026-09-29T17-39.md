# Bash Per-File Coverage Baseline (P0-T22)

Timestamp: 2026-09-29T17-39
Command: gh run download 36636142693 -n shell-coverage -D SCRATCH/shell-cov-baseline ; poetry run python SCRATCH/cobertura-files.py SCRATCH/shell-cov-baseline/cov.xml compute-cohorts.sh
EXIT_CODE: 0
Output Summary:
COBERTURA-TOTAL line-rate=0.933
COBERTURA file=.claude/lib/bash/compute-cohorts.sh line-rate=0.925

The control entry for `compute-cohorts.sh` confirms that per-file entries exist for the
`.claude/lib/bash` tree in the CI Cobertura report (run 36636142693).
