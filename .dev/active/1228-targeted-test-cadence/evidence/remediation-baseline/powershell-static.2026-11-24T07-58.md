# PowerShell Static Baseline - Remediation Cycle 1 ([P0-T1])

Timestamp: 2026-11-24T07-58
Plan: remediation-plan.2026-11-24T07-15.md
Command: `sh SCRATCH/issue-1228-pstatic.sh r0`, which runs pwsh 7 at the item worktree root: `Invoke-PoshQCFormat -Root <worktree root>` with `git status --porcelain` captured before and after; `Invoke-PoshQCAnalyze -Root <worktree root>` (settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`); `Invoke-PoshQCLeakScan -Root <worktree root>`; `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`; `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check`
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T07-52 to 07-58 (UTC), before any edit of this cycle.
- Format: `Invoke-PoshQCFormat` EXIT_CODE 0; 1879 files visited; finding count 0 (0 reformatted, no `Formatted:` line); `git status --porcelain` identical before and after the format step (True).
- Analyze: `Invoke-PoshQCAnalyze` EXIT_CODE 0 (the function throws on any finding; no exception); finding count 0.
- Leak scan: `Invoke-PoshQCLeakScan` EXIT_CODE 0; "Leak scan: 907 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures."; failing finding count 0.
- Harness generation `-Check`: EXIT_CODE 0, "harness-generation: no drift"; finding count 0.
- Harness generation `-Surface instructions -Check`: EXIT_CODE 0, "harness-generation: no drift"; finding count 0.

## Phase 0 baseline citation

The cycle runs no test suite in Phase 0; it cites the orchestration's `Phase 0 baseline` artifacts (lexicographically greatest of each name under `<FEATURE>/evidence/baseline/`), all present:

- `evidence/baseline/pester.2026-11-23T13-26.md`: one `Invoke-PoshQCParallelTest` run with coverage; 29157 tests, 29139 passed, 0 failed, 18 skipped; repo-wide line coverage 47285 covered, 1542 missed = 96.84%.
- `evidence/baseline/pytest.2026-11-23T13-32.md`: one `pytest -n auto` run with coverage; 17104 passed, 6 skipped, 0 failed; lines 98.01% (35372/36090), branches 95.47% (13100/13722), combined 97.31%.
- `evidence/baseline/jest.2026-11-23T13-33.md`: jest-extension with coverage, 6707 passed of 6707, 0 failed; Statements 97.59%, Branches 94.96%, Functions 93.35%, Lines 97.59%; root jest 6724 passed of 6724, 0 failed.
