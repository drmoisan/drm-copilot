# Stage E2 PowerShell Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-07T14-22
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 429.61 s); run 2026-11-07T14-15 to 14-22 UTC.
  JUnit totals: 15656 tests, 15646 passed, 0 failed, 0 errors, 10 disabled.
  parallel-gate-wording.Tests.ps1: 56 tests, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 14 tests, 0 failures.
  Repo-wide PowerShell line coverage: 94.01% (24050 of 25582 lines).
  No figure comes from MCP output.
