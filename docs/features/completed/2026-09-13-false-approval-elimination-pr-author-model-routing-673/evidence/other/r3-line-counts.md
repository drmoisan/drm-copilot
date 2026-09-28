# Line Counts: AC-30 (issue #673)

Timestamp: 2026-09-19T19-13

Command: `git diff --name-only b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD` filtered to `.ps1`, `.psm1`, `.psd1`, and `.py`; then `@(Get-Content -LiteralPath <path>).Count` for each; then `git status --porcelain`.

EXIT_CODE: 0

## Porcelain

`git status --porcelain` lists only paths under `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/`: this phase's evidence artifacts and the plan's checklist state. It lists **no path outside the two feature folders**, which is the scoped form binding rule 5 requires.

## Counts

Thirty-four code files are in the anchored diff. **Every count is at most 500.**

| File | Lines |
| --- | --- |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 275 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 360 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 126 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 314 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 332 |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 477 |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | 392 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1` | 275 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 360 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 126 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | 314 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 332 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | 477 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | 392 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 308 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 308 |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` | 113 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` | 145 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | 390 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` | 112 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 392 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 122 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 57 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 453 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | 362 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 499 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 446 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | 491 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1` | 86 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1` | 496 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | 92 |
| `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` | 155 |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | 165 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 346 |

OVER_500: 0

## Files the acceptance condition requires to be listed

| Required file | Listed | Lines |
| --- | --- | --- |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | yes | 491 |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | yes | 392 |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | yes | 477 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | yes | 332 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | yes | 446 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | yes | 453 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | yes | 499 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | yes | 362 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1` | yes | 275 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | yes | 360 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | yes | 126 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` | yes | 314 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | yes | 332 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | yes | 477 |

All six bundled hook mirrors are listed, and each matches its source exactly, which is what byte-identical mirroring implies for a line count.

## The two files that were at or near the cap

`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` was **509 lines at baseline**, a pre-existing breach RS-14 records. `[P6-T2]` moved its value-contract block into a sibling file and `[P6-T3]` added seven lines to the pin replacement, leaving 491 with nine lines of headroom. The sibling is 86 lines.

`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` was 499 lines at baseline and is 499 lines now, having lost five rows and gained one. It sits exactly at the plan's stated pre-Phase-9 figure with one line of headroom, which is why RS-14 placed the new identity rows in a new file rather than in this one.

`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` is 392 lines, within the 400-line bound `[P2-T2]` set for itself, which is stricter than the repository's 500-line cap.

Output Summary: Thirty-four code files are in the anchored diff and every one is at most 500 lines; the maximum is 499. `git status --porcelain` lists no path outside the two feature folders. Every file the acceptance condition names is listed, including all six bundled hook mirrors. The pre-existing 509-line cap breach in the orchestrator-state suite is resolved at 491 lines.
