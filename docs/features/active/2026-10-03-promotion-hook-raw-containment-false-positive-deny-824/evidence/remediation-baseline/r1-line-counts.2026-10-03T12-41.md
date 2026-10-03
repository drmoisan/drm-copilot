# r1 P0-T5 — baseline line counts of every existing edited file

Timestamp: 2026-10-03T12-41
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t5.ps1 -Worktree WORKTREE (A0 preamble, then the P0-T5 loop and VERDICT line verbatim)
EXIT_CODE: 0
Output Summary: 15 counts recorded (P0 counts); budgets hold (PAR-GATE 474 <= 476, EPIC-GATE 457 <= 476, FR-HOOK 459 <= 465, PYA 463 <= 470).

P0 counts:

- .claude/hooks/hook-command-raw-invocation.ps1 109
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 457
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 474
- .codex/hooks/enforce-epic-worktree-removal-gate.ps1 177
- .claude/hooks/validate-feature-review-coverage.ps1 459
- .codex/codex-web-setup.sh 384
- tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 260
- tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 246
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 135
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 115
- tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 130
- tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 77
- tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1 77
- tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py 463
- tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 497
