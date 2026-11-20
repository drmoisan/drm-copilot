# Stage H PowerShell Test Gate

Timestamp: 2026-11-08T15-22
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, repo-wide line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary; the committed ledger chain was also checked directly with Read-ProcessReductionChainInput and Invoke-ProcessReductionChain before the gates
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 974.0 s). Baseline (stage-h-powershell-test, Phase 0): 19666 testcases, 19656 passed, 0 failed, 10 skipped.
  JUnit totals: 19682 testcases, 19672 passed, 0 failed, 0 errors, 10 skipped. The 16 added testcases are the PCW-DESIGN-CHECK rows (6 + 8 + 2), all passing. No new failing test.
  Repo-wide PowerShell line coverage: 95.56% (35308 of 36947 lines), equal to the baseline; no production PowerShell file changed, so no per-file entry applies.
  ProcessReductionChain.Ledger test cases: 25, 0 failing. Direct chain run: IsValid True, 0 errors across 9 entries.
  No figure comes from MCP output.
