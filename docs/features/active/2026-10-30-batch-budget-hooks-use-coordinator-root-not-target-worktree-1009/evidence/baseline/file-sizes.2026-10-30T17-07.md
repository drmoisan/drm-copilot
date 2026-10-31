# Baseline Physical Line Counts (issue #1009)

Timestamp: 2026-10-30T17-07
Command: wc -l over every `.ps1` file in the plan's File Inventory Edit list plus `.claude/lib/worktree-resolution/WorktreeResolution.psm1`
EXIT_CODE: 0
Output Summary: all files below 801; Codex hooks at or below 500; Claude hooks near the 500 guidance tier.

| Path | Lines |
|---|---|
| `.claude/hooks/enforce-python-batch-budget.ps1` | 496 |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 493 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | 496 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | 493 |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 351 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 348 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1` | 351 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1` | 348 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | 108 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 501 |
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | 500 |
