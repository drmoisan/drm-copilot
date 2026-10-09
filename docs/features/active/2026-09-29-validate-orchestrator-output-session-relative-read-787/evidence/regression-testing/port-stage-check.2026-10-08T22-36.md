# PORT Stage Check (P2-T1)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/stage-check.ps1 -Path .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1
EXIT_CODE: 0
Output Summary: STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0

Correction loop (task text: "otherwise correct PORT and repeat"):
1. First run: `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=4`, four `PSUseOutputTypeCorrectly` (Information) records: the analyzer infers `System.Object[]` for the unary-comma returns of `Get-EpicWaveBarrierFeatureEntry` and `Get-OrchestratorStateEpicWaveBarrierError`. Correction: each `OutputType` attribute also declares `[object[]]`, the convention WorktreeRunResolution.psm1 uses for `Get-WorktreeRunLiveRoot`.
2. Second run: the PASS line above.

Implementation notes recorded for review:
- Property names, merged statuses, `not_started`, and prefixes are compared with `[System.StringComparison]::Ordinal` (stricter than `-ceq`, which is culture-aware), so the comparison matches Python string equality.
- Array returns are consumed by assignment or `foreach`, never by `@(...)` around a unary-comma return. A scratch probe (`@(f)` around `return , [string[]] @('a','b')` yields Count 1) showed that wrapping nests the array.

Result: PASS.
