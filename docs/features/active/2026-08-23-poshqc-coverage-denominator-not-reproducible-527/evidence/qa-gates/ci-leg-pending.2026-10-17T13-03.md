# CI Leg Pending (round 2, P2-T5)

Timestamp: 2026-10-17T13-03
Command: values copied from `evidence/qa-gates/determinism-comparison.2026-10-17T13-03.md` (run A); no further command was run
EXIT_CODE: 0
Output Summary: AC-01 local legs pass; the CI leg is `PENDING-CI`. Local values from run A: file count 215, ROOT_LINE_TOTAL 19095, KEY_SHA256 08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5.

Status: PENDING-CI

Local values (run A, copied from the determinism-comparison artifact):

- File count: 215
- ROOT_LINE_TOTAL: 19095
- KEY_SHA256: 08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5

S9 instruction (orchestrator): compare these values with the newest full CI run of the PR head. Use the `poshqc / PowerShell QC` aggregator log line `Merged PowerShell line coverage`, taken from a run whose `CI full run` job succeeded. A docs-only push is skipped by the change-scope rule, so the newest run whose `CI full run` job succeeded is the valid base. The AC-01 checkbox in `spec.md` stays unchecked until that comparison matches; the orchestrator checks it off at S9.
