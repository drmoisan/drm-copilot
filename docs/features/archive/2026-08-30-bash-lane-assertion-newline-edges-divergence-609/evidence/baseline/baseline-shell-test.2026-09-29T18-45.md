# Baseline Shell Test (P0-T5)

Timestamp: 2026-10-01T23:15:00-04:00
Command: sh scripts/bash/shell-qc.sh test   (NOT RUN locally; withheld by operator rule Option A, deviation D4)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: BATS is absent (see tool-availability artifact: `BATS: absent`). Per `scripts/bash/shell_qc_lib.sh` a `test` run with bats missing prints `bats not installed; skipping shell tests.` and exits 0; that exit-0 run is a vacuous pass and is not baseline evidence. This line is quoted from the plan's reading of the source, not observed in this session.

## Deviations recorded here
- D4: bats-based baseline not captured locally. The authority is the CI job `shell-coverage` (Shell Coverage (Bats + kcov), `.github/workflows/_shell-coverage.yml`) on the pushed head. The baseline for this task is PENDING-CI.
- D1 (from the origin/main merge): `scripts/bash/shell_qc_lib.sh` `run_test` now runs bats under a kcov-equivalent trace environment (`BASH_ENV=kcov_trace_env.sh`). This does not change the plan's tool-absent text above.

Plan checkbox for P0-T5 is left unchecked: its acceptance (BATS present: exit 0 and no `not ok`; BATS absent: the recorded skip line and CI authority) was not exercised by a local run.
