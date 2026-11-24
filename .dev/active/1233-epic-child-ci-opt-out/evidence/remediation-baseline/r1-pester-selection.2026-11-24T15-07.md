# R1 remediation baseline: Pester selection Set P (P0-T2)

Timestamp: 2026-11-24T15-07
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <Set P, 79 files listed in SCRATCH/issue-1233-r1-setp.txt> (through SCRATCH/issue-1233-r1-pester.sh and SCRATCH/issue-1233-retry.sh; JUnit and coverage copied to SCRATCH/issue-1233-r1-p0-pester.junit.xml and SCRATCH/issue-1233-r1-p0-pester.coverage.xml)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T14-58 to 2026-11-24T15-07; attempts 1 to 4 exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, lock held by another worktree), recorded as queue timeouts, not failures; attempt 5 exited 0.
- Invoke-PoshQCParallelTest: workers=8; wall-clock=465.23s; exit code=0.
- Merged JUnit (artifacts/pester/pester-junit.xml): tests=3549, failures=0, errors=0, skipped=0, passed=3549. No pre-existing failure.
- Line coverage of the in-scope files (artifacts/pester/powershell-coverage.xml, selection-scoped under O1; each file present in the population):
  - .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1: 145/147, 98.64%
  - .claude/hooks/enforce-epic-merge-gate-child-ci.ps1: 158/158, 100%
  - .codex/hooks/enforce-epic-merge-gate-child-ci.ps1: 156/158, 98.73%
- Other files read from the same report for reference: .codex/hooks/enforce-epic-merge-gate.ps1 182/183 (99.45%), .codex/hooks/enforce-completion-helpers.ps1 90/90 (100%).
- Selection-scoped repo line figure (not gate evidence under O1): 8306/49425, 16.81%. Repo-wide reference remains final-qc-pester.2026-11-24T13-00.md.
