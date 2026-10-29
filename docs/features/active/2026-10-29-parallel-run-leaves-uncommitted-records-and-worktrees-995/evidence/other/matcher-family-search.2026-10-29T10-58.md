# Matcher-Family Search (Two Strategies)

Timestamp: 2026-10-29T10-58
Task: [P3-T5]
Command: grep -rn --include=*.ps1 --include=*.psm1 -F ".worktree_path" .claude/ (strategy 1); grep -rn --include=*.ps1 --include=*.psm1 -F "TrimEnd('/')" .claude/ filtered to lines containing "replace" (strategy 2a, normalizer idiom); grep -rn --include=*.ps1 --include=*.psm1 -F "Test-WorktreeRunPathEqual" .claude/ (strategy 2b); grep -rn --include=*.ps1 --include=*.psm1 -F "Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath" .claude/ (matcher call sites)
EXIT_CODE: 0
Output Summary: every matcher-family site calls Test-WorktreeRunRecordedPathMatchesTarget; no in-family hit normalizes and compares a checkpoint worktree_path outside WorktreeRunRecordPath.psm1. Plain grep was used because WorktreeRunRecordPath.psm1 is untracked.

## Strategy 1: property read `.worktree_path`

| File | Enclosing function | Classification |
| --- | --- | --- |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | Find-EpicWorktreeGateParallelItemRecord | in-family; calls Test-WorktreeRunRecordedPathMatchesTarget |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | Find-EpicWorktreeFeatureRecord | in-family; calls Test-WorktreeRunRecordedPathMatchesTarget |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | Test-ParallelCheckpointAllowsWorktreeRemoval | in-family; calls Test-WorktreeRunRecordedPathMatchesTarget |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | Find-ParallelWorktreeItemRecord | in-family; calls Test-WorktreeRunRecordedPathMatchesTarget |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | Test-CleanupManifestCheckpointCoversPath | in-family; calls Test-WorktreeRunRecordedPathMatchesTarget |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | Find-CleanupWorktreeManifestRemovalRecord | out-of-family: reads the manifest's own removals[] records, not a checkpoint |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | Invoke-ParallelDriftGateDecision | out-of-family: passes the value to a drift-finding lookup, compares it to no removal target |
| .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 | module help | documentation text, not a comparison |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | Resolve-WorktreeRunTargetByRecord help | documentation text, not a comparison |

Test-WorktreeRunCheckpointRecord reads the field by name through Get-WorktreeRunPropertyValue (no `.worktree_path` token); strategy 2 and the matcher-call search below place it in-family and show it calls the shared matcher.

## Strategy 2a: normalizer idiom (backslash-to-slash replace followed by TrimEnd('/'))

| File | Enclosing function or purpose | Classification |
| --- | --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 | Test-WorktreeRunPathEqual, Test-WorktreeRunRecordedPathMatchesTarget, Get-WorktreeRunMainCheckoutRoot | the shared module itself |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | ConvertTo-CleanupWorktreeManifestNormalizedPath | out-of-family: used only by Find-CleanupWorktreeManifestRemovalRecord for manifest removals[] |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | feature_folder normalization | out-of-family: feature folder, not worktree_path |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1, enforce-parallel-cohort-barrier.ps1, enforce-powershell-batch-budget.ps1, enforce-python-batch-budget.ps1, enforce-prd-feature-before-planner.ps1, feature-folder-resolution.ps1, validate-orchestrator-output-resolution.ps1 | root, folder, or checkpoint-path composition | out-of-family: none compares a recorded worktree_path to a removal target |

The removal gates no longer contain a target-side normalizer: the former inline `$normalizedTarget` lines in Find-ParallelWorktreeItemRecord, Find-EpicWorktreeFeatureRecord, Test-ParallelCheckpointAllowsWorktreeRemoval, and Find-EpicWorktreeGateParallelItemRecord were removed with the record-side comparison.

## Strategy 2b: calls of Test-WorktreeRunPathEqual

Only .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 defines, exports, and calls it (from Test-WorktreeRunRecordedPathMatchesTarget). WorktreeRunResolution.psm1 no longer defines or calls it.

## Shared matcher call sites

| Function | File |
| --- | --- |
| Test-WorktreeRunCheckpointRecord | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 |
| Find-ParallelWorktreeItemRecord | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 |
| Find-EpicWorktreeFeatureRecord | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 |
| Test-ParallelCheckpointAllowsWorktreeRemoval | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 |
| Find-EpicWorktreeGateParallelItemRecord | .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 |
| Test-CleanupManifestCheckpointCoversPath | .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 |

Result: PASS. All six family functions call the shared matcher, and no in-family hit normalizes and compares a checkpoint worktree_path outside WorktreeRunRecordPath.psm1.
