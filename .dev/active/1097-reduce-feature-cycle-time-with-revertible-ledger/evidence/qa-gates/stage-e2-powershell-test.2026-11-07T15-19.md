# Stage E2 PowerShell Test Gate (compared with the Phase 0 baseline)

Timestamp: 2026-11-07T15-19
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary; baseline: stage-e2-powershell-test-baseline.2026-11-07T14-22.md
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 509.72 s); run 2026-11-07T15-10 to 15-18 UTC.
  JUnit totals: 15657 tests, 15647 passed, 0 failed, 0 errors, 10 disabled. Baseline: 15656 tests, 15646 passed, 0 failed, 10 disabled. Difference: +1 test (PRL-PARTIAL-REVERT-LINKED), +1 passed, failed unchanged at 0; no test passing at baseline fails.
  parallel-gate-wording.Tests.ps1: 56 tests, 0 failures (baseline 56; the row count is unchanged, the required and forbidden tokens changed). ProcessReductionLedger.Index.Tests.ps1: 15 tests, 0 failures (baseline 14; +1).
  Repo-wide PowerShell line coverage: 94.01% (24050 of 25582). Baseline 94.01% (24050 of 25582). Difference: 0.00 points; not below the baseline. No production PowerShell file changed in this stage.
  No figure comes from MCP output.
