# Stage I PowerShell Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-08T16-40
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest -Root <worktree root> (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, line coverage from artifacts/pester/powershell-coverage.xml (LINE counters) by a summary script stored under SCRATCH
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 940.4 s; the run overlapped one pytest run on the same host).
  JUnit totals: 19872 testcases, 19862 passed, 0 failed, 0 errors, 10 skipped. No failing test.
  OrchestratorStateEpicWaveBarrier.Tests.ps1: 20 cases, 0 failing.
  OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1: 7 cases, 0 failing (P row over 2 corpus files plus D1 to D5).
  enforce-epic-wave-barrier Claude suites (Tests, FolderResolution, WorktreeResolution): 59 cases, 0 failing.
  Codex enforce-epic-wave-barrier.Coverage.Tests.ps1: 21 cases, 0 failing.
  PRC- suites (ProcessReductionChain.Tests.ps1, ProcessReductionChain.Ledger.Tests.ps1): 55 cases, 0 failing.
  PRL- suites (ProcessReductionLedger.Tests.ps1, .Index.Tests.ps1, .Replay.Tests.ps1): 91 cases, 0 failing.
  Repo-wide PowerShell line coverage: 95.6% (35614 of 37254 lines).
  .claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1: 100% (109 of 109).
  .claude/hooks/enforce-epic-wave-barrier.ps1: 97.92% (94 of 96).
  .codex/hooks/enforce-epic-wave-barrier.ps1: 95.74% (135 of 141).
  No figure comes from MCP output.
