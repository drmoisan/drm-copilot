# Final Shell Coverage (P4-T5)

Timestamp: 2026-10-01T23:54:00-04:00
Command: sh scripts/bash/shell-qc.sh test --coverage ; grep -F 'parallel-lane-assertion.sh' artifacts/pester/kcov/cov.xml ; awk '/parallel-lane-assertion\.sh"/{f=1} f&&/number="88"/{print} /<\/class>/{f=0}' artifacts/pester/kcov/cov.xml   (NOT RUN locally; withheld by operator rule Option A, deviation D3)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: BATS and KCOV are recorded absent for local use. No numeric value was observed locally.
- Bash coverage total (lines): PENDING-CI
- parallel-lane-assertion.sh per-file line-rate: PENDING-CI
- hits of the changed statement at line 88 (the `read -ra tokens` line recorded in the P2-T1 artifact): PENDING-CI

Authority: CI job `shell-coverage` (log line `Bash coverage (lines):` and `artifacts/pester/kcov/cov.xml` in the uploaded `shell-coverage` artifact).
