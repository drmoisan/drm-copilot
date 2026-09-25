# Reason-Code Literal Search: AC-23 (issue #673)

Timestamp: 2026-09-19T19-09

Command: `git diff --name-only b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD`; `git status --porcelain`; then `Select-String -SimpleMatch` for each of the two reason-code literals over every remaining file, after dropping paths under either feature folder.

EXIT_CODE: 0

## Scope

RS-10 restates AC-23 from "search the whole repository" to "evaluated over files added or modified outside the feature folder". The evaluated set is the anchored diff against `F5_BASE_SHA`, less paths under `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/` and `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/`.

`git status --porcelain` at the time of this task lists three paths, all under the first feature folder: the commit log and the plan, both modified by this phase's own bookkeeping, and this task's sibling artifact. It lists **no path outside the two feature folders**.

FILES_SCANNED: 59

## Result

| Literal | Occurrences across the 59 files |
| --- | --- |
| `TARGET_WORKTREE_AMBIGUOUS` | **0** |
| `TARGET_WORKTREE_NOT_DERIVABLE` | **0** |

Both counts are 0, which is the acceptance condition. Every consumer obtains each code from `Get-WorktreeResolutionAmbiguityReasonCode` or `Get-WorktreeResolutionNoTargetReasonCode`, so a change to either literal moves every consumer with it and no second spelling can drift into existence.

Two files that carried a literal before this change set are among the 59 and are now clean: the doc comment in `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, which named both codes in its mapping description, and `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, which pinned both in mock results and assertions. The three skill files, the two prd gate files, and every file Phase 9 touched are likewise clean.

The library modules that legitimately define the literals, `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and its bundled mirror, are absent from the evaluated set because this change set does not modify them — which `[P10-T5]` asserts independently.

## The 59 files evaluated

- `.claude/hooks/enforce-model-routing-receipt.ps1`
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- `.claude/hooks/enforce-pr-author-skill.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`
- `.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `tests/fixtures/worktree-resolution/README.md`
- `tests/fixtures/worktree-resolution/model-routing/item-own-no-receipt/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/model-routing/item-own-receipt/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/model-routing/item-stale-receipt/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/model-routing/session-root/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/pr-author/item-own-epic-mode/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/pr_body_1.md`
- `tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/pr_body_1.receipt.json`
- `tests/fixtures/worktree-resolution/pr-author/item-own-ready/artifacts/pr_context.summary.txt`
- `tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/pr_body_1.md`
- `tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/pr_body_1.receipt.json`
- `tests/fixtures/worktree-resolution/pr-author/session-root/artifacts/pr_context.summary.txt`
- `tests/fixtures/worktree-resolution/shared/item-no-checkpoint/artifacts/pr_context.summary.txt`
- `tests/fixtures/worktree-resolution/shared/item-own-empty/artifacts/orchestration/orchestrator-state.json`
- `tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json`
- `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1`
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1`
- `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1`
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`
- `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`

Output Summary: `git status --porcelain` lists no path outside the two feature folders. Both reason-code literals occur zero times across the 59 files added or modified outside those folders. The two files that previously carried a literal are in the evaluated set and are clean.
