# Final QC — Shell Coverage (P5-T4) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: bash scripts/bash/shell-qc.sh test --coverage
EXIT_CODE: NOT-EXECUTED (kcov unavailable locally; delegated)

Note: kcov is not installed on this Windows host (would be exit 127 locally). Per the plan's
authorized fallback (P5-T4), the numeric `Bash coverage (lines): NN.N%` value is obtained from
the green `_shell-coverage.yml` run captured at P5-T9 (AC9). That run also uploads `cov.xml`
under `artifacts/pester/kcov/**`.

Bash coverage (lines): DEFERRED to P5-T9 CI run (authorized fallback). cov.xml location:
`artifacts/pester/kcov` (CI upload artifact "shell-coverage").
Output Summary: Local kcov absent; numeric bash line-coverage and cov.xml deferred to the CI
coverage run (AC2/AC9). Recorded in ci-green-run and coverage-delta once the CI run completes.
