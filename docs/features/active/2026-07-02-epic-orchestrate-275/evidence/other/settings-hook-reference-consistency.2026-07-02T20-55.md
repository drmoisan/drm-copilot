# Settings Hook Reference Consistency (P2-T18)

- Timestamp: 2026-07-02T20-55

## Method

Parsed `.claude/settings.json` as JSON and regex-scanned every string value recursively for
the pattern `\.claude/hooks/[A-Za-z0-9_.-]+\.ps1`, then verified each unique match resolves
to an existing file on disk relative to the repository root.

## Result

20 unique hook filenames referenced; all 20 exist on disk. Zero referenced-but-missing files.

- `.claude/hooks/check-powershell-test-purity.ps1` — EXISTS
- `.claude/hooks/check-python-test-purity.ps1` — EXISTS
- `.claude/hooks/enforce-checkpoint-monotonic.ps1` — EXISTS
- `.claude/hooks/enforce-completion-consistency.ps1` — EXISTS
- `.claude/hooks/enforce-epic-merge-gate.ps1` — EXISTS (new, P2-T5)
- `.claude/hooks/enforce-epic-wave-barrier.ps1` — EXISTS (new, P2-T12)
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` — EXISTS (new, P2-T10)
- `.claude/hooks/enforce-evidence-locations.ps1` — EXISTS
- `.claude/hooks/enforce-feature-folder-order.ps1` — EXISTS
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — EXISTS
- `.claude/hooks/enforce-powershell-batch-budget.ps1` — EXISTS
- `.claude/hooks/enforce-pr-author-skill.ps1` — EXISTS (modified, P2-T3)
- `.claude/hooks/enforce-prd-feature-before-planner.ps1` — EXISTS
- `.claude/hooks/enforce-promotion-mcp-only.ps1` — EXISTS
- `.claude/hooks/enforce-python-batch-budget.ps1` — EXISTS
- `.claude/hooks/validate-bash.ps1` — EXISTS
- `.claude/hooks/validate-feature-review-coverage.ps1` — EXISTS
- `.claude/hooks/validate-orchestrator-output.ps1` — EXISTS (modified, P2-T1)
- `.claude/hooks/validate-planner-output.ps1` — EXISTS
- `.claude/hooks/validate-pr-author-output.ps1` — EXISTS
