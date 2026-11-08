# Stage I Cycle 3 PowerShell Test Gate (Final QC)

Timestamp: 2026-11-08T20-08
Command: sh SCRATCH/issue-1097-c3-pester.sh (PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest -Root <worktree root> through SCRATCH/issue-1097-c1i-pester.ps1, exiting with its ExitCode; one run on head d4747296f); counts from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml (both written 2026-11-08T20-18), read by SCRATCH/issue-1097-c3-pestercov.ps1
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest ExitCode 0 (workers 8, wall-clock 620 s; the run overlapped the one pytest run on the same host).
  JUnit totals: 20418 testcases, 20408 passed, 0 failed, 0 errors, 10 skipped. No failing test. Against the stage I Phase 0 baseline (19872 testcases, 0 failed): no new failure.
  Named ledger cases, each 1 case and passed: PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-END-STATE-RECORDED, PRC-LEDGER-SUBCHAIN-HOLDS, PRC-README-REVERT-ORDER-STATED, PRC-LEDGER-NO-EXCEPTIONS, PRL-REAL-LEDGER-AGREES.
  EarlyStart suites (Claude and Codex): 2 suites, 59 tests, 0 failed.
  early-start-skill-contract.Tests.ps1: 56 tests, 0 failed, including ESS-CLAUDE-FALLBACK-KEEPS-BARRIER for the skill and its bundle copy (both passed).
  #1142 suites: epic-invocation-nesting-depth.Tests.ps1 11 tests, NestingDepthContract.Tests.ps1 9 tests, 0 failed.
  Repo-wide PowerShell line coverage: 95.67% (36351 of 37995) against the stage I Phase 0 baseline 95.6% (35614 of 37254): no drop.
  Changed files against the baseline: OrchestratorStateEpicWaveBarrier.psm1 100% (136 of 136; baseline 100%); .claude/hooks/enforce-epic-wave-barrier.ps1 98.02% (99 of 101; baseline 97.92%); .codex/hooks/enforce-epic-wave-barrier.ps1 95.89% (140 of 146; baseline 95.74%). None below its baseline.
  Early-start siblings (new files, cycle 3 requires 100% lines): .claude/hooks/epic-wave-barrier-early-start.ps1 100% (30 of 30); .codex/hooks/epic-wave-barrier-early-start.ps1 100% (30 of 30).
  No figure comes from MCP output.
