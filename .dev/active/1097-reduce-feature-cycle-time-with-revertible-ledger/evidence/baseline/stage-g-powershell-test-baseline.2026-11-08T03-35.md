# Stage G PowerShell Test Baseline (P0-T2, Phase 0 baseline)

Timestamp: 2026-11-08T03-28
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by a reader script under SCRATCH
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 348.79 s, run 03-28 to 03-34 UTC); merged JUnit and coverage written by this run.
  JUnit totals: 16132 tests, 16122 passed, 0 failures, 0 errors, 10 disabled. No failing test.
  Suite counts by test-name prefix (tests, failed): RG- 375, 0; RGC- 232, 0; OCR- 25, 0; PRL- 87, 0; PRC- 55, 0; PGW- 56, 0; CRS- 58, 0; LEC- 0 (suite not yet created).
  PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-END-STATE-RECORDED, and PRC-LEDGER-SUBCHAIN-HOLDS passed.
  Repo-wide PowerShell line coverage: 94.18% (24954 of 26496 lines).
  No figure comes from MCP output.
