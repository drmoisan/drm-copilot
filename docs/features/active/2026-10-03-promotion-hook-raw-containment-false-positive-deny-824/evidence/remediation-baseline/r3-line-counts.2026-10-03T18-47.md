# r3 P0-T5 baseline line counts (issue #824)

Timestamp: 2026-10-03T18-47
Command: pwsh -NoProfile -File "SCRATCH/steps/r3-p0-t5.ps1" -Worktree "WORKTREE" (Get-Content line count of the 11 listed files; VERDICT with limits CLAUDE-RAW 400, gate suites 420, unit suites 430)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-47
.claude/hooks/hook-command-raw-invocation.ps1 300
.claude/hooks/enforce-epic-worktree-removal-gate.ps1 464
.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 481
.codex/hooks/enforce-epic-worktree-removal-gate.ps1 184
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 332
tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 312
tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 303
tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 191
tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1 191
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 497
.claude/hooks/hook-command-invocation.ps1 494

P0 counts recorded: CLAUDE-RAW 300, EPIC-GATE 464, PAR-GATE 481, CODEX-GATE 184, S6 332, S7 312, S8 303, U1 191, U2 191, LEGACY 497, CLAUDE-INV 494. All equal the planning-time values; every limit holds.
