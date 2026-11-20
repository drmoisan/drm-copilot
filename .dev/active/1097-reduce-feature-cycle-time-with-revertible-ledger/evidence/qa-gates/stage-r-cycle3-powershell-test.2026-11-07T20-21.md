# Stage R Cycle 3 PowerShell Test Gate

Timestamp: 2026-11-07T20-21
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by the reader script SCRATCH/c3/issue-1097-c3-readpester.ps1
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 440.05 s); run 2026-11-07T20-14 to 20-21 UTC; merged JUnit and coverage written 2026-11-07T20-21.
  JUnit totals: 16045 tests, 16035 passed, 0 failed, 0 errors, 10 disabled. No failing test, including the suites PR #1112 and PR #1113 added.
  ProcessReductionChain.Tests.ps1: 46 tests, 0 failures (39 before plus the seven new later-landing tests). ProcessReductionChain.Ledger.Tests.ps1: 5 tests, 0 failures (4 before plus PRC-LEDGER-SUBCHAIN-HOLDS).
  ProcessReductionLedger.Tests.ps1: 72 tests, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 15 tests, 0 failures. ProcessReductionLedger.Replay.Tests.ps1: 4 tests, 0 failures.
  Passed by name: PRC-LANDING-SPLITS-PRIOR-TEXT, PRC-LANDING-EMPTY-THROWS, PRC-CHAIN-LATER-LANDING-OVERLAPS-OWN-PATCH, PRC-CHAIN-LATER-LANDINGS-NEWEST-FIRST, PRC-CHAIN-LATER-LANDING-ON-BLOCK-ENTRY, PRC-CHAIN-LATER-LANDING-OVER-HIGHER-ENTRY-FAILS, PRC-CHAIN-STOP-BEFORE, PRC-LEDGER-SUBCHAIN-HOLDS, PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-END-STATE-RECORDED, PRC-README-REVERT-ORDER-STATED, PRC-LEDGER-NO-EXCEPTIONS, PRL-REAL-LEDGER-AGREES, PRL-PARTIAL-REVERT-LINKED, PRL-README-EXAMPLE-IS-VALID.
  Repo-wide PowerShell line coverage: 94.16% (24808 of 26348 lines).
  scripts/dev-tools/ProcessReductionChain.psm1: 100% (230 of 230 lines; no missed line), so every new line is covered.
  scripts/dev-tools/ProcessReductionLedger.psm1: 100% (195 of 195 lines).
  Comparison with P0-T1 (stage-r-cycle3-baseline-reference): failures 0 against 0; repo-wide 94.16% against 94.01% (no drop); ProcessReductionChain.psm1 100% against its 99.5% baseline; ProcessReductionLedger.psm1 100% against 100%. The test count rises from 15675 to 16045 with the merged main suites and the eight new chain tests.
