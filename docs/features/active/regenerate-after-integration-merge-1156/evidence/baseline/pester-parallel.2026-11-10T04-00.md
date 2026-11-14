# Pester Parallel Baseline (P0-T2, Phase 0 baseline)

Timestamp: 2026-11-10T04-00
Command: sh SCRATCH/issue-1156-exec-pester.sh baseline (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run: workers=8, wall-clock 2355.01 s, exit code 0; merged JUnit and coverage written at the end of this run (file times match the run end).
- Pass and fail counts (artifacts/pester/pester-junit.xml): 21311 tests, 0 failures, 0 errors, 10 skipped; 21301 passed.
- Pre-existing failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.80% (37558 covered, 1645 missed).
- Per-file line coverage of the four existing files this plan edits:
  - .claude/hooks/enforce-epic-merge-gate.ps1: 98.63% (144 covered, 2 missed)
  - .codex/hooks/enforce-epic-merge-gate.ps1: 99.43% (175 covered, 1 missed)
  - .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: 97.66% (125 covered, 3 missed)
  - .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: 97.96% (144 covered, 3 missed)
