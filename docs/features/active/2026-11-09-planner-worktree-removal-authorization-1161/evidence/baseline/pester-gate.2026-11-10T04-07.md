# Phase 0 baseline Pester gate ([P0-T2])

Timestamp: 2026-11-10T04-07
Command: sh SCRATCH/issue-1161-pester.sh base (PowerShell 7; imports the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`, runs one `Invoke-PoshQCParallelTest -Root <worktree>`, exits with the returned `ExitCode`; counts from `artifacts/pester/pester-junit.xml`, line coverage from `artifacts/pester/powershell-coverage.xml`)
EXIT_CODE: 0
Output Summary: ExitCode 0, 8 workers, wall clock 2577.13 s (the pytest and Jest baselines ran concurrently), every shard exit 0. Merged JUnit: 21311 tests, 0 failures, 0 errors, 10 disabled. Repo-wide line coverage 95.80% (37558/39203). Per-file line coverage: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` 94.92% (112/118); `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` 95.58% (108/113); `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` 98.73% (78/79); `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` 96.23% (51/53).
