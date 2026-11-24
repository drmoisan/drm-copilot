# Baseline: Pester gate (P0-T4)

Timestamp: 2026-11-24T05-33
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (run from the item worktree root through SCRATCH/issue-1233-gate-pester.sh, wrapped by SCRATCH/issue-1233-retry.sh, which re-runs on a launcher exit 75)
EXIT_CODE: 0
Output Summary:
- Run window: 2026-11-24T05-17 to 2026-11-24T05-30 (UTC). One earlier attempt at 05-17 ended with launcher exit 75 (TEST_EXECUTION_QUEUE_TIMEOUT: the machine lock was held by a sibling worktree's pester run); it is a queue timeout, not a failure, and the gate was re-run.
- Invoke-PoshQCParallelTest: workers=8; wall-clock=781.53 s; exit code=0 (the returned ExitCode).
- artifacts/pester/pester-junit.xml: tests=29292, passed=29274, failures=0, errors=0, skipped=18. No failing pre-existing test.
- artifacts/pester/powershell-coverage.xml, repo-wide line coverage: 47435 covered, 1541 missed, 96.85%.
- Per-file line coverage of the in-scope PowerShell files of research Section 7 present in the population:
  - .claude/hooks/enforce-epic-merge-gate-child-ci.ps1: 83/83, 100%
  - .codex/hooks/enforce-epic-merge-gate-child-ci.ps1: 81/83, 97.59%
  - .claude/hooks/enforce-epic-merge-gate.ps1: 145/147, 98.64%
  - .codex/hooks/enforce-epic-merge-gate.ps1: 180/181, 99.45%
  - .claude/hooks/enforce-completion-helpers.ps1: 62/67, 92.54%
  - .codex/hooks/enforce-completion-helpers.ps1: 67/67, 100%
  - .claude/hooks/enforce-completion-consistency.ps1: 153/160, 95.62%
  - .codex/hooks/enforce-completion-consistency.ps1: 163/163, 100%
  - .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1: 115/117, 98.29%
- Bundle copies under extensions/drm-copilot/resources/ are not in the coverage population (config/poshqc-coverage.json roots).
- The merged JUnit and coverage files were copied to SCRATCH/issue-1233-p0-pester.junit.xml and SCRATCH/issue-1233-p0-pester.coverage.xml for the P5-T7 comparison.
