# Baseline CI shell coverage (P0-T8)

Timestamp: 2026-10-09T07-00
Command: gh run view 37895732802 --log | grep -F "Bash coverage (lines):" ; gh run download 37895732802 -n shell-coverage -D artifacts/pester/ci-794-baseline ; grep -F "parallel-cohorts.sh" artifacts/pester/ci-794-baseline/cov.xml
EXIT_CODE: 0
Output Summary: baseline total Bash coverage (lines) 94.2%; parallel-cohorts.sh class line-rate 0.993 = BASE_FILE_PCT 99.3%.

Summary line (the three preceding matches are the usage-help text of the script, not results):
Shell Coverage (Bats + kcov)	Run shell-qc test with coverage	2026-10-09T06:59:03.4994128Z Bash coverage (lines): 94.2%

cov.xml class line:
<class name="parallel_cohorts_sh__46" filename=".claude/lib/bash/parallel-cohorts.sh" branch-rate="1.0" complexity="1.0" line-rate="0.993">

Baseline total: 94.2%
BASE_FILE_PCT: 99.3
