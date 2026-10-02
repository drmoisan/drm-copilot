# Acceptance Criteria Gaps

Timestamp: 2026-10-01T23:59:45-04:00

Unchecked criteria and the reason each remains open. All gaps share one cause: the bats, kcov, and shell-entry invocations are withheld locally (operator rule Option A; deviations D3, D4, D5), so the evidence authority is the CI job `shell-coverage` (Shell Coverage (Bats + kcov)) on the pushed head, not yet read.

- AC-1 (P4-T10): the P3-T1 bash-lane reproduction was not run (D5), and no bats pass-after result exists locally. The Python header is pinned (`repro-python.2026-09-29T18-45.md`).
- AC-3 (P4-T12): case (1) added (P1-T1) but no pass-after result (P3-T2, D4).
- AC-4 (P4-T13): case (2) added but no pass-after result (D4).
- AC-5 (P4-T14): cases (3) and (4) added but no pass-after result (D4).
- AC-6 (P4-T15): needs the exactly-four `not ok` run before the fix (P1-T7) and none after (P3-T2); only a fail-before exception dossier exists, which the plan says does not satisfy this criterion (D4).
- AC-8 (P4-T17): the parity bats run (P3-T3) was not run (D4).
- AC-11 (P4-T20): `cmp` exit 0 and the push-down contract pass are recorded, but the membership bats run (P3-T4) is absent (D4).
- AC-12 (P4-T21): needs P3-T2 and P3-T3 with BATS present (D4).
- AC-13 (P4-T22): needs the new cases' exit-0 assertions to pass (P3-T2) and P3-T3 (D4).
- AC-14 (P4-T23): coverage values are PENDING-CI (D3); `coverage-comparison.2026-09-29T18-45.md` records REMEDIATION-REQUIRED.
- AC-17 (P4-T26): P4-T1 and P4-T2 not run after the fix (D3).
