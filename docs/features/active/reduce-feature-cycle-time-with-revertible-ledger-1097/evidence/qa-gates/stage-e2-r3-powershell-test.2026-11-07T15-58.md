# Stage E2 R3 PowerShell Test Gate (compared with the Phase 0 baseline)

Timestamp: 2026-11-07T15-58
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary; baseline: stage-e2-powershell-test-baseline.2026-11-07T14-22.md
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 353.49 s); run 2026-11-07T15-48 to 15-54 UTC, on the commit that carries the R3 light fix (reduction: 0006).
  JUnit totals: 15657 tests, 15647 passed, 0 failed, 0 errors, 10 disabled. Baseline: 15656 tests, 15646 passed, 0 failed, 10 disabled. Difference: +1 test (PRL-PARTIAL-REVERT-LINKED, added in stage E2), +1 passed, failed unchanged at 0; no test passing at baseline fails.
  parallel-gate-wording.Tests.ps1: 56 tests, 0 failures (baseline 56; the row count is unchanged, EXEC-CLAUDE, EXEC-CLAUDE-BUNDLE, and EXEC-CODEX now also require Phase 0 baseline).
  Repo-wide PowerShell line coverage: 94.01% (24050 of 25582 lines). Baseline 94.01% (24050 of 25582). Difference: 0.00 points; not below the baseline. No production PowerShell file changed in this cycle.
  No figure comes from MCP output.
