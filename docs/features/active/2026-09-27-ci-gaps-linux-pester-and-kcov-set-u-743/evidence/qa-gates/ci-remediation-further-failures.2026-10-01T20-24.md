# Further-Failure Set (P4-T10)

Timestamp: 2026-10-01T20-24
RUN_ID: 36918378249

Derivation (union of a to d):
- (a) `OTHER-FAIL:` lines of the P4-T7 output (`ci-remediation-inventory.2026-10-01T20-22.md`): none (`other-fail=0`).
- (b) `FAIL:` lines of P4-T6 (`ci-remediation-linux-junit.2026-10-01T20-22.md`) and P4-T9 (`ci-remediation-windows-results.2026-10-01T20-23.md`): none.
- (c) failing `[-]` log lines from P4-T8: not applicable (the Windows job concluded `success`).
- (d) the three asserted jobs (`poshqc / PowerShell hook suites (Linux)`, `poshqc / PowerShell QC`, `shell-coverage / Shell Coverage (Bats + kcov)`) all end `success`; none of their `STEP:` lines ends `failure`, `cancelled`, or `timed_out` (the one `skipped` step, `Build kcov from source`, is not a failure); both P4-T6 and P4-T9 downloads exited 0. No `UNATTRIBUTED:` item.

FURTHER-FAILURES: NONE

The per-job log filters are not run because the union is empty.
