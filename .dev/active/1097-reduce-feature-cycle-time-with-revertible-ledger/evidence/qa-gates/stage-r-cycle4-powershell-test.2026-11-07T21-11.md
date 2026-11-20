# Stage R Cycle 4 PowerShell Test Gate

Timestamp: 2026-11-07T21-11
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by the reader script SCRATCH/c3/issue-1097-c3-readpester.ps1
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 660.01 s); merged JUnit and coverage written 2026-11-07T21-11. No re-run was needed.
  JUnit totals: 16049 tests, 16039 passed, 0 failed, 0 errors, 10 disabled. No failing test.
  ProcessReductionChain.Tests.ps1: 50 tests, 0 failures (46 before, plus the four PRC-CHAIN-REPORTS-STALE-CREATED-FILE cases: edited, absent, unchanged without a trailing newline, unchanged with BOM and CRLF). PRC-CHAIN-CREATED-FILE-ENDS-ABSENT passes with an unedited created file.
  ProcessReductionChain.Ledger.Tests.ps1: 5 tests, 0 failures, so PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS stay green with no ledger edit. ProcessReductionLedger.Tests.ps1: 72 tests, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 15 tests, 0 failures. ProcessReductionLedger.Replay.Tests.ps1: 4 tests, 0 failures.
  Repo-wide PowerShell line coverage: 94.16% (24816 of 26356 lines).
  scripts/dev-tools/ProcessReductionChain.psm1: 100% (238 of 238 lines; no missed line), so the new lines are covered. scripts/dev-tools/ProcessReductionLedger.psm1: 100% (195 of 195 lines).
  Comparison with the stage R Phase 0 baseline (stage-r-powershell-test-baseline): failures 0 against 0; repo-wide 94.16% against 94.01% (no drop); ProcessReductionLedger.psm1 100% against 100%. ProcessReductionChain.psm1 had no figure in that baseline; against the cycle 3 reference (99.5%) it is 100% (no drop). No figure comes from MCP output.
