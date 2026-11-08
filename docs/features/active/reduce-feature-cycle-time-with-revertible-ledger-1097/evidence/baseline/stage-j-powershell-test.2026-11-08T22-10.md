# Stage J PowerShell Test-Suite Baseline (Phase 0 baseline)

Timestamp: 2026-11-08T22-10
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest -Root <worktree root> (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, line coverage from artifacts/pester/powershell-coverage.xml (LINE counters) by a summary script stored under SCRATCH
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 618.9 s; the run overlapped the one pytest baseline run on the same host).
  Branch head at the run: the stage J plan preflight commit on main 0bfa4f2a0 (origin/main had not advanced, so no main sync was needed).
  JUnit totals: 20818 testcases, 20808 passed, 0 failed, 0 errors, 10 skipped. No failing test.
  ClaudeLibModuleConvention.Tests.ps1: 6 cases, 0 failing.
  enforce-epic-merge-gate.ReviewGuard.Tests.ps1 (RG-*): 378 cases, 0 failing. enforce-epic-merge-gate-review.Tests.ps1 (RGC-*): 234 cases, 0 failing.
  PRC- suites (ProcessReductionChain.Tests.ps1, ProcessReductionChain.Ledger.Tests.ps1): 58 cases, 0 failing. PRL- suites: 91 cases, 0 failing.
  Contract suites: concurrent-review-skill-contract 58, less-evidence-contract 77, planning-contract-wording 114, light-remediation-skill-contract 74, parallel-gate-wording 56, early-start-skill-contract 56; 0 failing in each.
  CiRequiredGateWorkflow.Tests.ps1: 5 cases, 0 failing.
  review-verdict suites: 0 cases (not yet created).
  Repo-wide PowerShell line coverage: 95.7% (36608 of 38252 lines).
  .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 and Invoke-ReviewVerdictStatus.ps1: not yet created, so no pre-change run; they are judged against the 85% line threshold in P3-T2.
  No figure comes from MCP output.
