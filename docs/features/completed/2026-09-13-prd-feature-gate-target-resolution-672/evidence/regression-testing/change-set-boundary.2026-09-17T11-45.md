# Change-Set Boundary — Must-Not-Regress File-Set Constraints

Timestamp: 2026-09-17T11-45

Command (all three run from the worktree root, none chained after a `cd`; the wrapper script performs the single `cd` to the worktree root before any of them):

1. `git merge-base --is-ancestor d039e89b2b2569151e9170e1bbefb9f974419f87 HEAD` — **exit 0**
2. `git status --porcelain --untracked-files=all` — **exit 0**
3. `git diff --name-only d039e89b2b2569151e9170e1bbefb9f974419f87` — **exit 0**

`$baselineHead` is bound to `d039e89b2b2569151e9170e1bbefb9f974419f87`, the 40-character commit identifier recorded in `evidence/baseline/baseline-worktree-state.2026-09-17T10-28.md`.

EXIT_CODE: 0

## Anchor precondition

`git merge-base --is-ancestor` exits 0, so the baseline commit is still an ancestor of `HEAD` and the anchored diff describes this plan's change set only. The branch was not re-anchored after `[P0-T2]` ran. The halt branch does not fire.

## The enumerated union

Both commands are required: porcelain status reports nothing once a phase has been committed, and a name-listing diff cannot report an untracked file. A `git add --dry-run` companion is not used, because the pre-implementation gate classifies `git add` as a staging command at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` line 140.

From `git status --porcelain --untracked-files=all` (uncommitted at the time of this task):

- `M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- `M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/batch-boundary-e.2026-09-17T11-42.md`
- `?? docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/batch-e-delivery-tests.2026-09-17T11-43.md`

From `git diff --name-only $baselineHead`, the non-evidence paths (the remaining entries are this feature's own `evidence/**` artifacts and its `plan.2026-09-13T20-47.md`):

- `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`

## Acceptance

The union is **non-empty** and names all three required paths — `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, and `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` — which is what distinguishes a genuine enumeration from an empty one.

Within that union:

- no path matches `enforce-orchestration-preimplementation-gate`
- no path matches `enforce-epic-merge-gate`
- no path is `.claude/lib/hook-payload/HookPayload.psm1`
- no path lies under `.codex/`

`.codex/hooks/` contains no mirror of this hook and no differently named analogue, so this feature carries zero Codex parity work and a reviewer should not look for one.
