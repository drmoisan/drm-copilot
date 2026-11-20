# Stage R PowerShell Test Gate

Timestamp: 2026-11-07T18-28
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, repo-wide line coverage from artifacts/pester/powershell-coverage.xml through Get-PoshQCCoverageLineSummary, and per-file line coverage from the LINE counter of each scripts/dev-tools sourcefile element of the same report; compared with the greatest stage-r-powershell-test-baseline.*.md
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 303.82 s); run 2026-11-07T18-28 to 18-33 UTC; merged reports written 2026-11-07T18-33.
  JUnit totals: 15718 tests, 15708 passed, 0 failed, 0 errors, 10 disabled. No failing test.
  ProcessReductionChain.Tests.ps1: 39 tests, 0 failures. ProcessReductionChain.Ledger.Tests.ps1: 4 tests, 0 failures (PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-END-STATE-RECORDED, PRC-README-REVERT-ORDER-STATED, and PRC-LEDGER-NO-EXCEPTIONS passed).
  ProcessReductionLedger.Tests.ps1: 72 tests, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 15 tests, 0 failures (PRL-REAL-LEDGER-AGREES, PRL-PARTIAL-REVERT-LINKED, and PRL-README-EXAMPLE-IS-VALID passed). ProcessReductionLedger.Replay.Tests.ps1: 4 tests, 0 failures.
  Repo-wide PowerShell line coverage: 94.05% (24251 of 25784 lines).
  scripts/dev-tools/ProcessReductionChain.psm1: 99.5% (201 of 202 lines; the uncovered line is the end-state error for a created path that is still present, which the chain cannot reach because a create hunk sets the path absent and no older step touches it). New file, no pre-change run; at or above 85%.
  scripts/dev-tools/ProcessReductionLedger.psm1: 100% (195 of 195 lines).
  Comparison with the Phase 0 baseline (stage-r-powershell-test-baseline, 15675 tests, 0 failed, 94.01%): no new failing test (0 failed before and after; the 43 added tests are the two new suites); repo-wide line coverage 94.01% to 94.05%, no drop; ProcessReductionLedger.psm1 100% to 100%, no drop.
  No figure comes from MCP output.
