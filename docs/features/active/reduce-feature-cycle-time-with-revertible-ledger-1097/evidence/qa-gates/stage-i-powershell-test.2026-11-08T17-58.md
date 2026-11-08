# Stage I PowerShell Test Gate (P3-T2)

Timestamp: 2026-11-08T17-58
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest -Root <worktree root> (one run, after the P2-T3 commit and the P3-T1 restart pass; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, line coverage from artifacts/pester/powershell-coverage.xml (LINE counters) by a summary script stored under SCRATCH
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 697.4 s; the run overlapped the one pytest run on the same host, as the Phase 0 baseline did). Merged JUnit and coverage written by this run.
  JUnit totals: 19991 testcases, 19981 passed, 0 failed, 0 errors, 10 skipped (baseline 19872, 19862 passed, 0 failed, 10 skipped). No failing test.
  OrchestratorStateEpicWaveBarrier.Tests.ps1: 20 cases, 0 failing (baseline 20).
  OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1: 8 cases, 0 failing (baseline 7; one It added for the new corpus file early-start-edge-cases.json, which runs all of its cases).
  enforce-epic-wave-barrier Claude suites (Tests 31, FolderResolution 18, WorktreeResolution 10): 59 cases, 0 failing (baseline 59).
  Codex enforce-epic-wave-barrier.Coverage.Tests.ps1: 21 cases, 0 failing (baseline 21).
  PRC- suites: 58 cases, 0 failing (baseline 55; plus the 3 P2-T3 rows: PRC-CHAIN-DERIVED-CREATED-COPY-ENDS-ABSENT x2 and PRC-CHAIN-DERIVED-MODIFIED-BUNDLE-SKIPPED). PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-END-STATE-RECORDED pass.
  PRL- suites: 91 cases, 0 failing (baseline 91).
  New suites: Claude enforce-epic-wave-barrier.EarlyStart.Tests.ps1 28 cases, Codex enforce-epic-wave-barrier.EarlyStart.Tests.ps1 27 cases, early-start-skill-contract.Tests.ps1 54 cases, all passing; codex-epic-runtime-contracts.Tests.ps1 12 cases, all passing.
  Repo-wide PowerShell line coverage: 95.6% (35712 of 37354); baseline 95.6% (35614 of 37254). No drop (95.604% against 95.598%).
  .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1: 100% (136 of 136); baseline 100% (109 of 109).
  .claude/hooks/enforce-epic-wave-barrier.ps1: 98.02% (99 of 101); baseline 97.92% (94 of 96).
  .codex/hooks/enforce-epic-wave-barrier.ps1: 95.89% (140 of 146); baseline 95.74% (135 of 141).
  .claude/hooks/epic-wave-barrier-early-start.ps1: 96.67% (29 of 30); new file, threshold 85%.
  .codex/hooks/epic-wave-barrier-early-start.ps1: 96.67% (29 of 30); new file, threshold 85%.
  scripts/dev-tools/ProcessReductionChain.psm1: 100% (241 of 241); pre-change figure recorded in P2-T3: 100% (238 of 238). No drop.
  No figure comes from MCP output.
