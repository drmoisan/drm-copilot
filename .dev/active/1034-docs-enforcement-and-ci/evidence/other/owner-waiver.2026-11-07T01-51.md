# Owner Directive Waiver - Issue 1034 Remediation Cycle 1

Timestamp: 2026-11-07T01-51
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T01-25.md

WAIVED BY OWNER DIRECTIVE (received through the coordinator): P0-T3, P0-T4, P2-T4, P2-T5, P3-T1 to P3-T7, P4-T3, P4-T4, P4-T5, P4-T7, P4-T8, P4-T10, P4-T11, P4-T12, P4-T13, P4-T14.

Execution state at receipt: P0-T1, P0-T2 and P0-T3 were complete. The P0-T4 run was in progress and was stopped, so no P0-T4 baseline exists. The directive's exception for a task needed to prove F1 or F2 fixed is applied to P2-T4, because the F2 verification in `remediation-inputs.2026-11-07T01-25.md` requires a real-process run with the file locked, and the reported failure occurred only in a real process.

## Directive, Verbatim

Owner directive for #1034 remediation cycle 1: cut this cycle to the two blocking findings, F1 and F2, effective now.

Do only these tasks, in this order:
- P1-T1 and P1-T2 (the regression rows, including the N6 row), then P1-T3.
- P2-T1 and P2-T2 (the hook corrections and byte-for-byte bundle copies), then P2-T3.
- P4-T1 (format), P4-T2 (analyzer), P4-T6 (pytest, with `-n auto`), and P4-T9 (one `Invoke-PoshQCParallelTest` run).

Skip everything else as waived by owner directive: P0-T3, P0-T4, P2-T4, P2-T5, all of Phase 3 (notes N1 to N5), P4-T3 to P4-T5, P4-T7, P4-T8, and P4-T10 to P4-T14. P4-T8 and P4-T10 are also barred by the parallel-only directive. Record one waiver line in the evidence that lists these tasks; do not write an evidence file for each skipped task.

If P4-T9 fails, fix the cause and re-run it once. Commit and push, then finish and report. If a skipped task turns out to be needed to prove F1 or F2 fixed, do that task and say why in your report.
