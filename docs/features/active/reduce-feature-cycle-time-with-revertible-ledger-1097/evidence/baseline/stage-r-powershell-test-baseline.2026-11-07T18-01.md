# Stage R PowerShell Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-07T17-53
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, repo-wide line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary, and per-file line coverage from the LINE counter of the scripts/dev-tools sourcefile element of the same report
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 459.4 s); run 2026-11-07T17-53 to 18-01 UTC; merged reports written 2026-11-07T18-01.
  JUnit totals: 15675 tests, 15665 passed, 0 failed, 0 errors, 10 disabled. No failing test.
  ProcessReductionLedger.Tests.ps1: 72 tests, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 15 tests, 0 failures. ProcessReductionLedger.Replay.Tests.ps1: 4 tests, 0 failures.
  Repo-wide PowerShell line coverage: 94.01% (24050 of 25582 lines).
  scripts/dev-tools/ProcessReductionLedger.psm1 line coverage: 100% (195 of 195 lines).
  No figure comes from MCP output.
