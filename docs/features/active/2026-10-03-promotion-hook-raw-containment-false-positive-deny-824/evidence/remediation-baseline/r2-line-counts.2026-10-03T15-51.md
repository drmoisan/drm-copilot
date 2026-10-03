# r2 P0-T5 baseline line counts

Timestamp: 2026-10-03T15-51
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p0-t5.ps1" -Worktree "WORKTREE" (Get-Content line count of the 17 existing files this plan edits or pins; VERDICT on the CLAUDE-INV 496, SETUP 470, and CLAUDE-RAW 310 budgets)
EXIT_CODE: 0
Output Summary: 17 counts recorded as the P0 counts; all budgets fit (CLAUDE-INV 491 <= 496, SETUP 394 <= 470, CLAUDE-RAW 298 <= 310). Every value equals the planning-time value.

| File | P0 count |
|---|---|
| .claude/hooks/hook-command-raw-invocation.ps1 (CLAUDE-RAW) | 298 |
| .claude/hooks/hook-command-invocation.ps1 (CLAUDE-INV) | 491 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 (EPIC-GATE) | 464 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 (PAR-GATE) | 481 |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 (CODEX-GATE) | 184 |
| .codex/codex-web-setup.sh (SETUP) | 394 |
| tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 (S1) | 292 |
| tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 (S2) | 278 |
| tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 (S3) | 347 |
| tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 (S3X) | 284 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 (S6) | 259 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 (S7) | 239 |
| tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 (S8) | 242 |
| tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 (U1) | 159 |
| tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1 (U2) | 159 |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 (LEGACY) | 497 |
| .github/workflows/_shell-coverage.yml (WORKFLOW) | 62 |
