# Final Pester gate ([P4-T3], re-run after the P4-T6 host-path fix)

Timestamp: 2026-11-13T20-34
Command: sh SCRATCH/issue-1161-pester-gate.sh (PowerShell 7 in the item worktree; imports the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`, runs one `Invoke-PoshQCParallelTest -Root <worktree>`, exits with the returned `ExitCode`; counts from `artifacts/pester/pester-junit.xml`, line coverage from `artifacts/pester/powershell-coverage.xml`)
EXIT_CODE: 0
Output Summary: ExitCode 0, 8 workers, wall clock 791.71 s, every shard exit 0, merged reports written (JUnit write time 2026-11-13T20:34:32Z). Merged JUnit: 22679 tests, 0 failures, 0 errors, 10 disabled. Repo-wide line coverage 95.86% (38941/40624), baseline 95.80%. Every per-file figure equals `pester-gate.2026-11-13T20-02.md`.

Reason for the re-run: P4-T6 changed one row of `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1` (recorded in `pwsh-static.2026-11-13T20-15.md`), so the loop restarted from step 1. That suite reports 220 tests, 0 failures, and the discovery guard 548 tests, 0 failures.

| File | Baseline | Final | Threshold 85% | No drop |
| --- | --- | --- | --- | --- |
| .claude/hooks/hook-planner-worktree-removal.ps1 | new file | 100.00% (130/130) | PASS | n/a |
| .codex/hooks/hook-planner-worktree-removal.ps1 | new file | 100.00% (130/130) | PASS | n/a |
| .claude/hooks/enforce-worktree-removal-gate-planner.ps1 | new file | 93.88% (46/49) | PASS | n/a |
| .codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1 | new file | 93.33% (42/45) | PASS | n/a |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 94.92% (112/118) | 95.24% (120/126) | PASS | PASS |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 95.58% (108/113) | 95.93% (118/123) | PASS | PASS |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.73% (78/79) | 100.00% (87/87) | PASS | PASS |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 96.23% (51/53) | 96.55% (56/58) | PASS | PASS |
| Repo-wide | 95.80% (37558/39203) | 95.86% (38941/40624) | PASS | PASS |

Baseline: `evidence/baseline/pester-gate.2026-11-10T04-07.md`.
