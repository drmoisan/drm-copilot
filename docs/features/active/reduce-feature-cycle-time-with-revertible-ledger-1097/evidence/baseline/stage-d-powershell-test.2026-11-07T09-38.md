# Stage D PowerShell Test Baseline

Timestamp: 2026-11-07T09-31
Command: Invoke-PoshQCParallelTest -Root <worktree root>, run once from a `sh` launcher under SCRATCH that imports `scripts/powershell/PoshQC/PoshQC.psd1`
EXIT_CODE: 0
Output Summary: returned `ExitCode` 0 with 8 workers, wall-clock 298.0 seconds; every shard exited 0. `artifacts/pester/pester-junit.xml` reports 15392 tests, 0 failures, 0 errors, and 10 disabled. `Get-PoshQCCoverageLineSummary` over `artifacts/pester/powershell-coverage.xml` reports 23994 covered and 1534 missed of 25528 lines, 93.99% repo-wide. `LINE` counters of the `sourcefile` elements: `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` 121 covered, 0 missed (100%); `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1` 100 covered, 0 missed (100%); `.claude/hooks/enforce-epic-merge-gate-review.ps1` 160 covered, 2 missed (98.77%); `.codex/hooks/enforce-epic-merge-gate-review.ps1` 149 covered, 13 missed (91.98%). Every figure was read from those files and not from MCP output.
