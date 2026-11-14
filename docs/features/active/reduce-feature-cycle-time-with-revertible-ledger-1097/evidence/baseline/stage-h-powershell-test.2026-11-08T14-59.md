# Stage H PowerShell Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-08T14-59
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, repo-wide line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 951.0 s; run overlapped one pytest run on the same host).
  JUnit totals: 19666 testcases, 19656 passed, 0 failed, 0 errors, 10 skipped. No failing test.
  ProcessReductionChain test cases: 25, 0 failing. PCW-DESIGN-CHECK cases: 0 (rows are added in P1-T5).
  Repo-wide PowerShell line coverage: 95.56% (35308 of 36947 lines).
  No figure comes from MCP output.
