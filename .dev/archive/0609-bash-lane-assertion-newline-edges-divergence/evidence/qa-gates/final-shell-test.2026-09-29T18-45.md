# Final Shell Test (P4-T4)

Timestamp: 2026-10-01T23:53:00-04:00
Command: sh scripts/bash/shell-qc.sh test   (NOT RUN locally; withheld by operator rule Option A, deviation D4)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: BATS is absent for local use. With bats missing, `scripts/bash/shell_qc_lib.sh` prints `bats not installed; skipping shell tests.` and exits 0; that exit-0 run would be a vacuous pass and is recorded here as non-evidence. Authority: CI job `shell-coverage` (Shell Coverage (Bats + kcov)), which runs the full `tests/shell` and `tests/bash` suites.

Deviation D1 (from the origin/main merge): `scripts/bash/shell_qc_lib.sh` `run_test` now runs bats under a kcov-equivalent trace environment (`BASH_ENV=kcov_trace_env.sh`). It does not change the tool-absent text above.

Operator-run blocker (requires bats). Exact command: sh scripts/bash/shell-qc.sh test
