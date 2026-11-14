# Stage F PowerShell Test Baseline (Phase 0)

Timestamp: 2026-11-07T22-54
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/sf/issue-1097-sf-readpester.ps1
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 567.39 s, run 22-54 to 23-03 UTC); merged JUnit and coverage written by this run.
  JUnit totals: 16122 tests, 0 failures, 0 errors, 10 disabled. No failing test.
  planning-contract-wording.Tests.ps1: 88 tests, 0 failures. ProcessReductionLedger.Tests.ps1: 72, 0 failures; ProcessReductionLedger.Index.Tests.ps1: 15, 0 failures; ProcessReductionLedger.Replay.Tests.ps1: 4, 0 failures. ProcessReductionChain.Ledger.Tests.ps1: 5 tests, 0 failures; PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS passed.
  Repo-wide PowerShell line coverage: 94.18% (24954 of 26496 lines).
  No figure comes from MCP output.
