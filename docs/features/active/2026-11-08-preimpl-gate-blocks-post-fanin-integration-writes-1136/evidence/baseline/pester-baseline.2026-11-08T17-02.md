# Pester Baseline (Phase 0)

Timestamp: 2026-11-08T17-02
Command: sh SCRATCH/issue-1136-pester.sh baseline (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest returned ExitCode 0 (8 shards, all shard exit codes 0, wall clock 570.81 s).
- Counts from artifacts/pester/pester-junit.xml: tests=19856, failures=0, errors=0, disabled (skipped)=10; passed=19846.
- Failing tests: none.
- Repo-wide line coverage from artifacts/pester/powershell-coverage.xml: 95.6% (covered 35614, missed 1640).
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 97.48% (covered 116, missed 3).
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 97.83% (covered 135, missed 3).
- JUnit and coverage files copied to SCRATCH/baseline-pester/ for the [P5-T3] comparison.
