# Decision-Matrix Row 3 Reproduction Against the Unmodified Hook

Timestamp: 2026-09-17T10-48

Command: `pwsh -NoProfile -File p0t11.ps1`, run from the worktree root through the scratchpad wrapper `sh runps.sh p0t11.ps1`. The script dot-sources the unmodified `.claude/hooks/enforce-prd-feature-before-planner.ps1`, redefines the checkpoint seam `Get-PrdFeatureCheckpointFolder` to return `docs/features/active/2026-01-01-unrelated-000` (a folder that is not among the prompt's candidates, per research-record hypothesis H1), and calls `Find-PrdFeatureFolderFromPrompt` and then `Invoke-PrdFeatureBeforePlannerDecision` with a `subagent_type` of `atomic-planner`.

Prompt used (one absolute-form citation into a sibling worktree, one bare repo-relative citation, two distinct feature folders):

`Execute the plan at C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-sibling/docs/features/active/2026-09-14-target-only-in-sibling-999/spec.md and cross-reference docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`

EXIT_CODE: 0

Output Summary:

- `Find-PrdFeatureFolderFromPrompt` returned `docs/features/active/2026-09-14-target-only-in-sibling-999` — the absolute prefix `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-sibling/` was discarded by the unanchored pattern at hook line 252 and consumed by the `[regex]::Matches` call at line 253, exactly as preamble ruling 1 states.
- Decision: `deny`.
- Reason: `PRD_FEATURE_BLOCKED: resolved feature folder 'docs/features/active/2026-09-14-target-only-in-sibling-999', but its work mode could not be determined from 'docs/features/active/2026-09-14-target-only-in-sibling-999/issue.md' (the '- Work Mode:' marker is absent, unreadable, or unrecognized). Confirm that is the intended feature folder, then add or correct the '- Work Mode:' marker in that file so the prerequisite set can be derived.`
- The bare four-segment path was probed against the session root, where the sibling worktree's folder does not exist, so `issue.md` could not be read and the gate took the indeterminate-work-mode branch at lines 398-410.

Observed outcome: **REPRODUCED**

The reproduction succeeded, so no `WhyFailingRunImpossible:` field is required. This task is an investigation and not a fail-before row; no `ExpectedExitCode:` field applies, and no later acceptance condition in this plan depends on this outcome. The fixed gate's binding requirement remains the positive one: it must allow an absolute path to the target feature folder when the required document is present under the containing worktree.
