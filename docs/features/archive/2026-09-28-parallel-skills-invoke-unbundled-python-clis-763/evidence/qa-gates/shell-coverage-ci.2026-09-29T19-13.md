# Bash Suite Results and Coverage Headline From CI (P11-T3)

Timestamp: 2026-09-29T19-13
Command: sh SCRATCH/ci-shell-log.sh 36645685724
EXIT_CODE: 0
Output Summary:
- Run 36645685724 at FINAL_SHA `4c87951d9f4ee93d0c587b8db797719031f933db` (job `Shell Coverage (Bats + kcov)`, success).
- Exactly one headline line: `Bash coverage (lines): 93.4%` (>= 85.0).
- `NOT-OK-COUNT=0`
- `OK-COUNT=498`
- Information only: the P0-T21 baseline headline was 93.3; the difference is +0.1 percentage point.
  The changed-line gate for bash is the per-file line rate of P11-T4.
- OK-COUNT arithmetic: P0-T21 `OK-COUNT=478` + 20 = 498, where 20 = 14 tests in
  `tests/shell/parallel_abandon.bats` + 3 in `tests/shell/parallel_abandon_parity.bats` + 3 added to
  `tests/shell/parallel_payload_only.bats` (B30 renames one existing test and adds none). Observed
  498; the arithmetic holds.
- Printed suite lines include:
  - the three `tests/shell/parallel_abandon_parity.bats` tests:
    `ok 15 the abandon parity corpus meets the declared floor`,
    `ok 16 the harness interpreter is available to read the corpus`,
    `ok 17 the bash lane reproduces every abandon corpus fixture`
  - the three B29 tests:
    `ok 168 the payload directory carries the abandon entry point`,
    `ok 169 the abandon shim PATH exposes no Python interpreter`,
    `ok 170 the payload abandons an item without Python on PATH`
  - `ok 23 the five CLI entry points are present in both trees`
  - `ok 1 the abandon script exists in the repository library` (the other 13
    `tests/shell/parallel_abandon.bats` tests carry no keyword the extraction filter prints; with
    `NOT-OK-COUNT=0` every test in the run passed)

This is the authoritative bash parity result (AC5) and payload-only result (AC6).
