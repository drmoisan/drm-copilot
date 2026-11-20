# Stage R Cycle 2 PowerShell Test Gate

Timestamp: 2026-11-07T19-34
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, repo-wide line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary, and per-file line coverage from the LINE counter of each scripts/dev-tools sourcefile element of the same report; compared with the greatest stage-r-cycle2-baseline-reference.*.md
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 405.67 s); run 2026-11-07T19-25 to 19-32 UTC; merged reports written 2026-11-07T19-32.
  JUnit totals: 15718 tests, 15708 passed, 0 failed, 0 errors, 10 disabled. No failing test.
  ProcessReductionChain.Tests.ps1: 39 tests, 0 failures. ProcessReductionChain.Ledger.Tests.ps1: 4 tests, 0 failures. ProcessReductionLedger.Tests.ps1: 72 tests, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 15 tests, 0 failures. ProcessReductionLedger.Replay.Tests.ps1: 4 tests, 0 failures.
  Passed by name: PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-END-STATE-RECORDED, PRC-README-REVERT-ORDER-STATED, PRC-LEDGER-NO-EXCEPTIONS, PRL-REAL-LEDGER-AGREES, PRL-PARTIAL-REVERT-LINKED, PRL-README-EXAMPLE-IS-VALID.
  Repo-wide PowerShell line coverage: 94.06% (24248 of 25780 lines).
  scripts/dev-tools/ProcessReductionChain.psm1: 100% (198 of 198 lines; the one uncovered line of the earlier run was the removed created-path error).
  scripts/dev-tools/ProcessReductionLedger.psm1: 100% (195 of 195 lines).
  Comparison with the Phase 0 baseline reference: no new failing test (0 failed, same 15718 total as the stage R gate); repo-wide line coverage 94.01% (Phase 0 baseline) and 94.05% (stage R gate) to 94.06%, no drop; ProcessReductionChain.psm1 99.5% to 100%, no drop; ProcessReductionLedger.psm1 100% to 100%.
  No figure comes from MCP output.
