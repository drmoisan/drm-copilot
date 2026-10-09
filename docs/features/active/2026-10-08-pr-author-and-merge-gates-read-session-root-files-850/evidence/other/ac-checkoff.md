# Acceptance-criteria check-off log (issue #850)

Timestamp: 2026-10-08T23-57
Command: sh SCRATCH/run-ps.sh SCRATCH/checkbox-count.ps1 -Path FEATURE/spec.md -FromLine 204 -Line <lines> (one run per check-off task)
EXIT_CODE: 0
Output Summary:
  Source: FEATURE/spec.md (full-bug; sole AC source). Entries are appended per check-off task.

## P1-T13 (2026-10-08T23-57)

- AC-30 (spec line 248): checked. Evidence: P1-T9 `evidence/regression-testing/cr4-pass-after.2026-10-08T23-55.md` (B14 passes; FailedCount=0), fail-before P1-T2 `evidence/regression-testing/cr4-fail-before.2026-10-08T23-52.md`.
- AC-31 (spec line 249): checked. Evidence: P1-T9 `evidence/regression-testing/cr4-pass-after.2026-10-08T23-55.md` (B11, B12, X1 pass); export count 7 unchanged (P1-T3 LOAD-CHECK ExportCount=7).
- A14 output: `CHECKBOX checked=2 unchecked=45`, `LINE n=248 state=checked`, `LINE n=249 state=checked`.
