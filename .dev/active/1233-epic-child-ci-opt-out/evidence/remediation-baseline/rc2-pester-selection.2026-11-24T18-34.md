# RC2 remediation baseline: Pester selection Set P (P0-T3)

Timestamp: 2026-11-24T18-34
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <Set P, 21 files listed in SCRATCH/issue-1233-rc2-setp.txt> (through SCRATCH/issue-1233-r1-pester.sh and SCRATCH/issue-1233-retry.sh; merged JUnit copied to SCRATCH/issue-1233-rc2-p0-pester.junit.xml)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T18-23 to 2026-11-24T18-33; attempts 1 to 5 exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, lock held by another worktree), recorded as queue timeouts, not failures; attempt 6 started 2026-11-24T18-29 and exited 0.
- Invoke-PoshQCParallelTest: workers=8; wall-clock=191.18s; exit code=0.
- Merged JUnit (artifacts/pester/pester-junit.xml, removed before the run and rewritten by it): testcases=913, failures=0, errors=0, skipped=0, passed=913. No pre-existing failure.
- Set P files: OrchestratorStateChildCi.Tests.ps1; claude-runtime child-ci-opt-out-skill-contract, concurrent-review-skill-contract, light-remediation-skill-contract, owner-directives-skill-contract, regeneration-path-skill-contract, parallel-gate-wording, test-cadence-wording; claude-hooks release-merge.Parity, release-pull-request.Parity, hook-release-allowance-context.Parity, enforce-epic-merge-gate.Release; codex-hooks enforce-epic-merge-gate-release; dev-tools StageTimingDocumentation; HarnessGeneration.RepoGate; FileSizePolicy.RepoGate; and Set L (ProcessReductionChain.Ledger, ProcessReductionChain, ProcessReductionLedger, ProcessReductionLedger.Index, ProcessReductionLedger.Replay).
- Selection-scoped run under O1; not repo-wide gate evidence.
