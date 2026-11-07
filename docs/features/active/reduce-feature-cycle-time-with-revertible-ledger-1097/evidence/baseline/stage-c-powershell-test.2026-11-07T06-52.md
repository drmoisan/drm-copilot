# Stage C PowerShell Test Baseline

Timestamp: 2026-11-07T06-43
Command: Invoke-PoshQCParallelTest -Root <worktree root>, run once from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 workers, wall-clock 311.96 seconds. `artifacts/pester/pester-junit.xml` reports 14591 tests, 0 failures, 0 errors, and 10 disabled. `Get-PoshQCCoverageLineSummary` over `artifacts/pester/powershell-coverage.xml` reports 23618 covered and 1519 missed of 25137 lines, 93.96% repo-wide. `LINE` counters of the `sourcefile` elements: `.claude/hooks/enforce-epic-merge-gate.ps1` 134 covered, 2 missed (98.53%); `.codex/hooks/enforce-epic-merge-gate.ps1` 154 covered, 1 missed (99.35%); `OrchestratorState.psm1` 109 covered, 1 missed (99.09%); `OrchestratorStateCompletion.psm1` 97 covered, 0 missed (100%); `OrchestratorStateCompletionChecks.psm1` 99 covered, 2 missed (98.02%). Every figure was read from those files and not from MCP output.
