# Stage F PowerShell Test Gate (P3-T2, compared with the Phase 0 baseline)

Timestamp: 2026-11-07T23-33
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/sf/issue-1097-sf-readpester.ps1; baseline: stage-f-powershell-test-baseline.2026-11-07T23-04.md
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 325.45 s, run 23-33 to 23-38 UTC); merged JUnit and coverage written by this run. No re-run.
  JUnit totals: 16132 tests, 0 failures, 0 errors, 10 disabled (baseline 16122, 0 failures, 10 disabled). No failing test; no test passing at the baseline fails.
  planning-contract-wording.Tests.ps1: 98 tests, 0 failures (baseline 88; the 10 added rows are PCW-SIZE-GUIDELINE-<Copy> over six copies and PCW-SIZE-AGENT-<Id> over four agents).
  ProcessReductionLedger.Tests.ps1: 72, 0 failures (baseline 72). ProcessReductionLedger.Index.Tests.ps1: 15, 0 failures (baseline 15). ProcessReductionLedger.Replay.Tests.ps1: 4, 0 failures (baseline 4). ProcessReductionChain.Ledger.Tests.ps1: 5, 0 failures (baseline 5), now over entries 0001 to 0008.
  PRC-LEDGER-CHAIN-HOLDS: Passed. PRC-LEDGER-SUBCHAIN-HOLDS: Passed.
  Repo-wide PowerShell line coverage: 94.18% (24954 of 26496 lines); baseline 94.18% (24954 of 26496); no drop.
  No production PowerShell file changed, so no per-file figure applies. No figure comes from MCP output.
