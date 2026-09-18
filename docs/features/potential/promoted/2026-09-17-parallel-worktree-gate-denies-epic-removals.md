# parallel-worktree-gate-denies-epic-removals (Issue #688)

- Date captured: 2026-09-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-worktree-gate-denies-epic-removals/ (Issue #688)

- Issue: #688
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/688
- Last Updated: 2026-09-17
## Summary

`enforce-parallel-worktree-removal-gate.ps1` denies `git worktree remove` for a merged EPIC child
worktree, so epic worktrees can never be removed through the Bash tool. The epic gate authorizes
the same call. The result is that every completed epic strands its child worktrees and the operator
is told to remove them by hand.

## Reproduction

1. Run an epic to completion so its children merge and the epic checkpoint records
   `features[].merge_status: merged`.
2. Issue `git worktree remove <child worktree path>`.

Observed on 2026-09-17 for epic #678 children #669, #670, #671, #672 and #675.

## Expected vs Actual

- `enforce-epic-worktree-removal-gate.ps1` ALLOWS: the epic checkpoint has a matching `features[]`
  record with `merge_status: merged`.
- `enforce-parallel-worktree-removal-gate.ps1` DENIES with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. It
  resolves only `artifacts/orchestration/parallel-orchestrator-state.json` and looks for an
  `items[]` record. An epic run never writes that checkpoint, so the lookup finds nothing and the
  gate fails closed. It has no epic-aware branch.

Both gates run on the same Bash call, so the deny wins.

## Why the cleanup manifest does not rescue it

The sanctioned-removal manifest branch is unreachable for this case. `Test-CleanupWorktreeManifestAuthorizesRemoval`
condition 9 checks `branch_state` against
`$script:AuthorizedBranchStates = @('NOT_MERGED', 'HAS_UNIQUE_RESIDUALS')`
(`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1:50`). A merged epic child classifies
`MERGED_CLEAN`, which is not in that set, so no manifest record can authorize it. The manifest is
scoped to durable-residual triage, not to merged worktrees.

The script's own apply mode (`scripts/bash/cleanup-worktrees.sh --apply`) does remove `MERGED_CLEAN`
worktrees, but it takes no path or scope operand, so the only available route is a repository-wide
sweep. With 72 live worktrees and concurrent sessions running, that is not an acceptable instrument
for removing five known paths.

## Proposed Fix

Give the parallel gate an epic-aware branch, mirroring the epic gate's existing dual read: when no
parallel checkpoint covers the target, consult the epic checkpoint's `features[]` records and allow
when `merge_status` is `merged` or `worktree_removed`. Keep the fail-closed default for a target
neither checkpoint covers.

Consider separately whether `cleanup-worktrees.sh` should accept an explicit path operand so a
scoped removal does not require a repository-wide apply.

## Acceptance Criteria (early draft)

- [ ] A merged epic child worktree can be removed through the Bash tool with both gates active.
- [ ] A target covered by neither checkpoint still denies, fail-closed.
- [ ] Parallel-run behavior is unchanged: an unmerged parallel item still denies.
- [ ] Pester coverage for the epic-authorized, parallel-authorized, and neither-authorized cases.

## Constraints & Risks

- Both gates must stay fail-closed; this must not widen removal to unmerged work.
- Related to epic #678's defect class: a gate reading state that does not describe the call's target.

## Next Step

- [x] Promote to GitHub issue
