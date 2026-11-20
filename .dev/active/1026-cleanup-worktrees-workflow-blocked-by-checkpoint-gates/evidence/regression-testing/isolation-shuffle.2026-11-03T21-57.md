# Isolation — TOUCHED_SUITES Serial and Seeded Shuffled File Order (P2-T3)

Timestamp: 2026-11-03T21-57
Command: sh SCRATCH/issue-1026-p2t3.sh (PowerShell 7 Invoke-Pester over the five TOUCHED_SUITES in one process per run: one serial run in plan order, then three runs with the file order shuffled by System.Random seeded with 1026, 4242, and 90210; JUnit per run under SCRATCH)
EXIT_CODE: 0
Output Summary: serial run 699 tests, 0 failures; seed 1026: 699 tests, 0 failures; seed 4242: 699 tests, 0 failures; seed 90210: 699 tests, 0 failures. No order dependence observed.

| Run | Seed | File order | Tests | Failures | Errors |
|---|---|---|---|---|---|
| serial | none | cleanup-merged-worktrees.SkillText, hook-cleanup-context.Parity, claude-architecture-doc, hook-dependency-guard-completeness, test-name-uniqueness | 699 | 0 | 0 |
| shuffle 1 | 1026 | test-name-uniqueness, hook-dependency-guard-completeness, cleanup-merged-worktrees.SkillText, hook-cleanup-context.Parity, claude-architecture-doc | 699 | 0 | 0 |
| shuffle 2 | 4242 | test-name-uniqueness, hook-cleanup-context.Parity, cleanup-merged-worktrees.SkillText, claude-architecture-doc, hook-dependency-guard-completeness | 699 | 0 | 0 |
| shuffle 3 | 90210 | hook-cleanup-context.Parity, hook-dependency-guard-completeness, claude-architecture-doc, cleanup-merged-worktrees.SkillText, test-name-uniqueness | 699 | 0 | 0 |

File-name prefixes: `tests/scripts/claude-hooks/` for cleanup-merged-worktrees.SkillText and hook-cleanup-context.Parity; `tests/scripts/claude-runtime/` for the other three; every file ends in `.Tests.ps1`.
