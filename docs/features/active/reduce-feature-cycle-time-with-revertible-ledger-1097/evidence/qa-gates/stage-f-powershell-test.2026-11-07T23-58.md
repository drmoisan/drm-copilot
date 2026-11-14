# Stage F PowerShell Test Gate After the G5 Fix (P3-T2 rerun, compared with the Phase 0 baseline)

Timestamp: 2026-11-07T23-58
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run after the fix, because the ledger chain tests read the regenerated 0008 patch; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/sf/issue-1097-sf-readpester.ps1; baseline: stage-f-powershell-test-baseline.2026-11-07T23-04.md. Also in this record: git apply -R --check of patches/0008-g13-guideline-cutoff.patch, and SCRATCH/sf/issue-1097-sf-ledger.ps1 (Test-ProcessReductionLedger, Invoke-ProcessReductionChain, and its -StopBefore replay of each stored-patch entry).
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 379.95 s); merged JUnit and coverage written by this run. No re-run.
  JUnit totals: 16132 tests, 0 failures, 0 errors, 10 disabled (baseline 16122, 0 failures, 10 disabled). No failing test.
  planning-contract-wording.Tests.ps1: 98 tests, 0 failures (baseline 88). ProcessReductionLedger.Tests.ps1: 72, 0 failures. ProcessReductionLedger.Index.Tests.ps1: 15, 0 failures. ProcessReductionLedger.Replay.Tests.ps1: 4, 0 failures. ProcessReductionChain.Ledger.Tests.ps1: 5, 0 failures.
  PRC-LEDGER-CHAIN-HOLDS: Passed. PRC-LEDGER-SUBCHAIN-HOLDS: Passed.
  Repo-wide PowerShell line coverage: 94.18% (24954 of 26496 lines); baseline 94.18% (24954 of 26496); no drop.
  git apply -R --check of the regenerated 0008 patch: exit 0.
  Ledger and chain check with 0008: ledger IsValid=True, 8 entries, 0 errors; chain full IsValid=True, 0 errors; StopBefore 0001, 0006, and 0008 each IsValid=True, 0 errors; current-fence-hits=0; failures=0.
  No production PowerShell file changed, so no per-file figure applies. No figure comes from MCP output. Python is unchanged by the fix, so the earlier pytest gate stands.
