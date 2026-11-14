# File Size - P2-T6 acceptance after the origin/main merge (issue #1161)

Timestamp: 2026-11-13T18-50
Command: wc -l <file>; awk 'END{print NR}' <file>
EXIT_CODE: 0
Output Summary: both Claude gates reduced from 504 logical lines (503 by wc -l; the final line has no terminator) to 500 logical lines (499 by wc -l), meeting the P2-T6 acceptance of at or below 500. The resolution file is unchanged at 260.

## Cause

The merge of origin/main (issue #1163, branch-name matching through -BranchWorktreeResolver) added lines to both Claude removal gates after P2-T6 had recorded them under the cap.

## Change (behavior-neutral)

- Reflowed the Issue #1161 `.DESCRIPTION` paragraph and the `.NOTES` paragraph of each gate to wider lines. The wording contract `tests/scripts/claude-runtime/planner-worktree-removal-contract.Tests.ps1` collapses whitespace, and every required token is still present.
- Removed one of two consecutive blank lines after the hook-dependency-guard load in each gate.
- `Get-EpicWorktreeGateDenyDiagnostics` and `Test-CleanupManifestCheckpointCoversPath` are not touched; no executable line changed.
- Each gate was copied byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (cmp reports identical).

## Counts

| File | Before (logical / wc -l) | After (logical / wc -l) |
| --- | --- | --- |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 504 / 503 | 500 / 499 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 504 / 503 | 500 / 499 |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 260 / 260 | 260 / 260 |

## Session-root check against #1163

Both gates pass `(Get-Location).Path` as `-SessionRoot` to `Get-PlannerWorktreeRemovalTargetDecision`, the same derivation the gates use for `$mainRoot` through `Get-WorktreeRunMainCheckoutRoot` and for the #1163 `-BranchWorktreeResolver` default.
