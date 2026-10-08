# Full Local shell-qc.sh test with the Simulation Active (P7-T12, AC-15)

Timestamp: 2026-10-01T17-45
Command: sh <session-scratchpad>/shell-qc-test-local.sh <BATS_DIRECT>
EXIT_CODE: 0
Output Summary: `SHELL_QC_TEST_EXIT=0`; TAP plan `1..501`; 501 `ok`, 0 `not ok`. The three R5 tests are `ok 486`, `ok 487`, `ok 488`. No `kcov@` trace line reached the output.

RUN_START=2026-10-01T17-24-59
RUN_END=2026-10-01T17-45-00
Wall time: 20.02 minutes (P0-T24 baseline 21.47 minutes; difference -1.45 minutes; recorded, not gated).

TAP plan line: `1..501` (baseline `1..498` plus the three R5 tests).
not ok names: none. The `not ok` set is empty, a subset of the empty P0-T24 baseline failure set.

SIMULATION-EXPOSED: none. Every bats test under `tests/shell` passes with `BASH_ENV` set to `scripts/bash/kcov_trace_env.sh` and `BASH_XTRACEFD` on `/dev/null`.

The run used `<BATS_DIRECT>` = `<npm-cache>/_npx/cd2c4d46c11457b7/node_modules/bats/bin/bats` through the `SHELL_QC_BATS_BIN` seam, so bats was a direct bash child of `run_test`.
