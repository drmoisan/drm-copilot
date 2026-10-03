# r1 P7-T6 — test integrity

Timestamp: 2026-10-03T13-22
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p7-t6.ps1 -Worktree WORKTREE (A0; the BASE_SHA-anchored numstat and the porcelain status of tests/scripts/claude-hooks, tests/scripts/codex-hooks, and tests/scripts/dev_tools; the named-set, bad-delete, and set-difference computation; the P7-T6 VERDICT line)
EXIT_CODE: 0
Output Summary:
- numstat (added, deleted, path):
  - 124 0 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
  - 124 0 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
  - 32 0 tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
  - 82 0 tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1
  - 112 0 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
  - 32 0 tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
  - 82 0 tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1
  - 31 1 tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
- status: the eight files above as ` M`; untracked `?? tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`, `?? tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, `?? tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`
- NAMED=11 BAD-DELETES=0 SET-DIFFERENCES=0 (no existing PowerShell test line changed; exactly one PYA line changed)
