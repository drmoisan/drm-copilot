# Spec: parallel worktree removal gate denies merged epic child worktrees (Issue #688)

- Issue: #688
- Work Mode: full-bug
- Last Updated: 2026-09-18

## Problem

`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denies `git worktree remove` for every
merged **epic** child worktree. Both worktree-removal gates run on the same Bash call, so a deny
from either one wins:

- `enforce-epic-worktree-removal-gate.ps1` **allows**: the epic checkpoint carries a matching
  `features[]` record with `merge_status: merged`.
- `enforce-parallel-worktree-removal-gate.ps1` **denies** with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`.
  It resolves only `artifacts/orchestration/parallel-orchestrator-state.json` and scans its
  `items[]` array. An epic run never writes that checkpoint, so the lookup finds nothing and the
  gate fails closed. The gate has no epic-aware branch.

Observed 2026-09-17 on epic #678 children #669, #670, #671, #672 and #675, each merged to `main`
via PR #686 and each with a clean worktree.

## Why existing escape hatches do not cover it

- **Cleanup manifest.** `Test-CleanupWorktreeManifestAuthorizesRemoval` condition 9 tests
  `branch_state` against `$script:AuthorizedBranchStates = @('NOT_MERGED', 'HAS_UNIQUE_RESIDUALS')`
  (`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1:50`). A merged epic child classifies
  `MERGED_CLEAN`, which is outside that set, so no manifest record can authorize it. The manifest is
  scoped to durable-residual triage by design.
- **Script apply mode.** `scripts/bash/cleanup-worktrees.sh --apply` does remove `MERGED_CLEAN`
  worktrees, but it accepts no path or scope operand, so the only available instrument is a
  repository-wide sweep. With 72 live worktrees and concurrent sessions running, that is not an
  acceptable way to remove five known paths.

The operator is therefore told to remove epic worktrees by hand, which is the defect.

## Required Behavior

1. When no parallel checkpoint record covers the removal target, the parallel gate MUST consult the
   epic checkpoint (`artifacts/orchestration/epic-orchestrator-state.json`) `features[]` records and
   ALLOW when the matching record's `merge_status` is `merged` or `worktree_removed`.
2. The gate MUST remain fail-closed for a target that neither checkpoint covers.
3. Parallel-run behavior MUST be unchanged: an unmerged parallel item still denies, and a parallel
   item whose `merge_status` is `merged` or `worktree_removed` still allows on the existing path.
4. The epic-checkpoint read MUST go through an injectable seam, matching the existing read-seam
   convention in both gates, so tests drive it without writing temporary files.
5. The existing cleanup-manifest branch and its checkpoint-coverage exclusion MUST keep their
   current semantics and evaluation order.

## Non-Goals

- Widening removal to unmerged work in either topology.
- Changing the cleanup manifest's authorized branch states.
- Adding a path operand to `cleanup-worktrees.sh` (worth doing, but tracked separately).
- Any change to `enforce-epic-worktree-removal-gate.ps1`, which already behaves correctly.

## Acceptance Criteria

- [ ] AC-1: A merged epic child worktree is removable through the Bash tool with both gates active.
- [ ] AC-2: A target covered by neither checkpoint denies with the unchanged
      `PARALLEL_WORKTREE_REMOVAL_BLOCKED` reason code.
- [ ] AC-3: An epic `features[]` record whose `merge_status` is not `merged`/`worktree_removed`
      denies.
- [ ] AC-4: Existing parallel-run cases are unchanged (merged allows; unmerged denies).
- [ ] AC-5: An unreadable or malformed epic checkpoint denies rather than allowing.
- [ ] AC-6: Pester coverage for the epic-authorized, parallel-authorized, neither-authorized, and
      malformed-checkpoint cases, including the currently-passing parallel cases as regression
      guards.
- [ ] AC-7: Line coverage >= 85% and the PowerShell toolchain (format, analyze, test) passes.

## Test Conditions

- Epic checkpoint records the target as `merged` and no parallel checkpoint exists: allow.
- Epic checkpoint records the target as `merged` and a parallel checkpoint exists but does not
  cover the target: allow.
- Parallel checkpoint covers the target with `merge_status: merged`: allow (unchanged path).
- Parallel checkpoint covers the target with an unsafe `merge_status`: deny (unchanged).
- Neither checkpoint covers the target: deny.
- Epic checkpoint present but unparseable: deny.
