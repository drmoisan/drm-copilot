# Final CI shell coverage (P4-T10)

Timestamp: 2026-10-09T07-21
Command: gh run view 37897674234 --log | grep -F "Bash coverage (lines):" ; gh run download 37897674234 -n shell-coverage -D artifacts/pester/ci-794-final ; grep -F "parallel-cohorts.sh" artifacts/pester/ci-794-final/cov.xml ; awk '/parallel-cohorts\.sh"/{f=1} f&&/number="67"/{print} /<\/class>/{f=0}' artifacts/pester/ci-794-final/cov.xml ; same awk with number="138"
EXIT_CODE: 0
Output Summary: post-change total Bash coverage (lines) 94.2%; POST_FILE_PCT 99.3 (line-rate 0.993); line 67 hits=1; line 138 hits=1.

Summary line (the three preceding matches are the usage-help text, not results):
Shell Coverage (Bats + kcov)	Run shell-qc test with coverage	2026-10-09T07:20:00.8403631Z Bash coverage (lines): 94.2%

class line:
<class name="parallel_cohorts_sh__46" filename=".claude/lib/bash/parallel-cohorts.sh" branch-rate="1.0" complexity="1.0" line-rate="0.993">

awk number="67":  <line number="67" hits="1"/>
awk number="138": <line number="138" hits="1"/>

Post-change total: 94.2%
POST_FILE_PCT: 99.3
