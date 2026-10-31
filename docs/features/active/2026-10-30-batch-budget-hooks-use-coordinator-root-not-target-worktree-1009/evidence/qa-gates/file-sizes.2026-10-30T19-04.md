# Final Physical Line Counts (issue #1009)

Timestamp: 2026-10-30T19-04
Command: wc -l over every created or edited .ps1 and .psm1 file in the plan's File Inventory
EXIT_CODE: 0
Output Summary: the two Codex hooks, their bundles, the twin, and its bundle are at or below 500; every file is below 801. The Claude hooks (535 and 532) are above the 500-line guidance tier, which is non-blocking; they are below the 700 advisory tier and the 801 hard block, and their logic sits in the new module.

| File | Baseline | Final | Limit checked | Result |
|---|---|---|---|---|
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (and bundle) | new | 391 | < 801 | PASS |
| `.codex/hooks/hook-target-worktree.ps1` (and bundle) | new | 369 | <= 500 | PASS |
| `.claude/hooks/enforce-python-batch-budget.ps1` (and bundle) | 496 | 535 | < 801 | PASS (guidance tier) |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` (and bundle) | 493 | 532 | < 801 | PASS (guidance tier) |
| `.codex/hooks/enforce-python-batch-budget.ps1` (and bundle) | 351 | 390 | <= 500 | PASS |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` (and bundle) | 348 | 387 | <= 500 | PASS |
| `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` | new | 232 | < 801 | PASS |
| `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Rows.Helpers.ps1` | new | 235 | < 801 | PASS |
| `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` | new | 158 | < 801 | PASS |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1` | new | 276 | < 500 (plan) | PASS |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1` | new | 287 | < 500 (plan) | PASS |
| `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1` | new | 220 | < 500 (plan) | PASS |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | 108 | 112 | < 801 | PASS |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 501 | 501 | < 801 | PASS (one-line edit; size unchanged) |

`tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` passed 5/5 in the [P9-T10] full run, and `legacy-codex-hook-contracts.Tests.ps1` (`keeps every file within 500 lines` for the Codex hooks and shared modules, including the twin) passed in [P9-T5].
