# Baseline Shell Coverage (P0-T6)

Timestamp: 2026-10-01T23:16:00-04:00
Command: sh scripts/bash/shell-qc.sh test --coverage, then grep -F 'parallel-lane-assertion.sh' artifacts/pester/kcov/cov.xml   (NOT RUN locally; withheld by operator rule Option A, deviation D3)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: BATS and KCOV are recorded absent-by-guard. No numeric value was observed locally.

Baseline values:
- Bash coverage total (lines): PENDING-CI
- parallel-lane-assertion.sh per-file line-rate: PENDING-CI

Statement: no numeric value was observed locally. Per the plan's tool-absent rule, a `test --coverage` run with bats or kcov missing exits 127 and prints `not installed`; that message was not observed here because the command was not run. Authority: CI job `shell-coverage` (log line `Bash coverage (lines):` and `artifacts/pester/kcov/cov.xml` in the uploaded `shell-coverage` artifact).

Plan checkbox for P0-T6 is left unchecked.
