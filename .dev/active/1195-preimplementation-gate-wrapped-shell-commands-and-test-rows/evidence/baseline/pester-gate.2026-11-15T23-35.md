# Phase 0 Baseline: Pester Gate (P0-T3)

Timestamp: 2026-11-15T23-35
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launched from SCRATCH/issue-1195-gate.sh with the worktree as cwd; runs one Invoke-PoshQCParallelTest, coverage enabled, integration and golden lanes excluded); counts and coverage read by SCRATCH/issue-1195-report.ps1
EXIT_CODE: 0
Output Summary:
- Run: started 2026-11-15T23-23, ended 2026-11-15T23-33; 8 shard processes, all exit 0; wall-clock 631.41 s; merged JUnit and coverage written (fully green run).
- artifacts/pester/pester-junit.xml: tests 27341, passed 27323, failures 0, errors 0, skipped 18.
- artifacts/pester/powershell-coverage.xml repo-wide line coverage: 44785 covered, 1846 missed, 96.04%.
- Per-file line coverage:
  - .claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1: 61/61, 100.00%
  - .codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1: 61/61, 100.00%
  - .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 169 covered, 6 missed, 96.57%
  - .codex/hooks/enforce-orchestration-preimplementation-gate.ps1: 180/180, 100.00%
  - The two bundle copies of the classify sibling are not in the measured population.
- Pre-existing Pester failures (regression reference): none.
