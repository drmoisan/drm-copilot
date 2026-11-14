# Stage J Cycle 1 PowerShell Test Gate (P3-T2)

Timestamp: 2026-11-09T00-00
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest -Root <worktree root> (one run; launcher stored under SCRATCH); counts read from artifacts/pester/pester-junit.xml, line coverage from artifacts/pester/powershell-coverage.xml (LINE counters) by a summary script stored under SCRATCH
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 551.4 s; merged JUnit and coverage written). The run overlapped the one pytest run on the same host, as the stage J baseline runs did.
  JUnit totals: 21052 testcases, 21042 passed, 0 failed, 0 errors, 10 skipped. Baseline (stage-j-powershell-test.2026-11-08T22-10.md): 20818 testcases, 20808 passed, 0 failed, 10 skipped. No test that passed at baseline fails.
  Repo-wide PowerShell line coverage: 95.73% (36903 of 38548); baseline 95.7% (36608 of 38252); stage J final gate 95.73% (36848 of 38493). No drop.
  .claude/lib/review-verdict/ReviewVerdictEligibility.psm1: 100% (201 of 201 lines); stage J final gate reference 100% (194 of 194). Threshold 85% met, no drop.
  .claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1: 97.87% (46 of 47 lines); stage J final gate reference 97.87% (46 of 47). Threshold 85% met, no drop.
  review-verdict suites: 175 cases, 0 failing (169 at the stage J final gate plus the six new cases: four in ReviewVerdictEligibility.Review.Tests.ps1 and two in Invoke-ReviewVerdictStatus.Tests.ps1).
  ProcessReductionChain.Ledger.Tests.ps1 and ProcessReductionChain.Tests.ps1 (PRC-): 58 cases, 0 failing, so the chain is valid with 0 errors over 10 entries. ProcessReductionLedger (PRL-): 91 cases, 0 failing.
  Other suites, 0 failing in each: ClaudeLibModuleConvention 6, enforce-epic-merge-gate.ReviewGuard (RG-*) 380, enforce-epic-merge-gate-review (RGC-*) 236, concurrent-review-skill-contract 58, less-evidence-contract 77, planning-contract-wording 114, light-remediation-skill-contract 74, parallel-gate-wording 56, CiRequiredGateWorkflow 5, early-start-skill-contract 56, enforce-epic-wave-barrier.EarlyStart 59.
  No figure comes from MCP output. First run of the gate on this cycle; no re-run was needed.
