# Coverage Comparison (P4-T6)

Timestamp: 2026-10-01T23:55:00-04:00
Command: none (derived from the P0-T6 and P4-T5 artifacts, both NOT RUN locally under deviation D3)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: all coverage values are PENDING-CI. The outcome is REMEDIATION-REQUIRED, not PASS.

| Metric | Baseline (P0-T6) | Post-change (P4-T5) |
|---|---|---|
| Bash coverage total (lines) | PENDING-CI | PENDING-CI |
| parallel-lane-assertion.sh per-file line-rate | PENDING-CI | PENDING-CI |
| hits of the `read -ra tokens` line (88) | not applicable | PENDING-CI |

Thresholds to evaluate from CI values (AC-14): post-change per-file percentage at least the baseline per-file percentage, at least 85.0, and 1 or more hits on line 88.

Sources to read: CI job `shell-coverage` (Shell Coverage (Bats + kcov)), log line `Bash coverage (lines):`, and `artifacts/pester/kcov/cov.xml` in the uploaded `shell-coverage` artifact. No number is invented here.
