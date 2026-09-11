# parallel-worktree-removal-gate-blocks-epic-cleanup (Issue #657)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-worktree-removal-gate-blocks-epic-cleanup/ (Issue #657)
- Consolidated: closed 2026-09-09 as consolidated into #663 (enforcement gates lack an epic-level checkpoint seam); this record is retained as the lifecycle trail and no active folder is created for it.

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #657
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/657
- Last Updated: 2026-09-08
## Summary

`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` has no epic-checkpoint seam, so during an epic run it denies every `git worktree remove`. Its sibling epic gate is cross-mode aware, but the reciprocal fallback was never added. Both hooks share one PreToolUse matcher and a deny from either wins, so an epic-orchestrator cannot remove a child worktree even after the epic checkpoint records the child as merged.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Claude Code runtime.
- Python version: not applicable (PowerShell hook).
- Command/flags used: `git worktree remove <child-worktree-path>` from `epic-orchestrator` after the child's `merge_status` was `merged`.
- Data source or fixture: epic `cleanup-merged-worktrees-hardening` (#655), `artifacts/orchestration/epic-orchestrator-state.json`.

## Steps to Reproduce

1. Run an epic to the point where a child feature's `merge_status` is `merged` in `artifacts/orchestration/epic-orchestrator-state.json`.
2. From the epic orchestrator, run `git worktree remove <that child's worktree path>`.
3. Observe `EPIC_WORKTREE_REMOVAL_BLOCKED` before the checkpoint records `merged`, then, after it does, observe the epic gate pass and the identical command denied by `PARALLEL_WORKTREE_REMOVAL_BLOCKED`.

## Expected Behavior

When an epic checkpoint authorizes the removal, the parallel gate defers to it (the reciprocal of the epic gate's existing cross-mode fallback), and the removal proceeds.

## Actual Behavior

The parallel gate reads only the parallel checkpoint, finds no entry for the path, and denies. Nine child worktrees from epic #655 remain registered after the epic merged, and the epic orchestrator recorded them as deliberately not force-removed.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
PARALLEL_WORKTREE_REMOVAL_BLOCKED (same path had just passed the epic gate)
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Every epic run leaves its child worktrees behind; cleanup then depends on a later `/cleanup-merged-worktrees` run or manual removal.

## Suspected Cause / Notes

- `enforce-parallel-worktree-removal-gate.ps1` lacks the epic-checkpoint fallback that `enforce-epic-worktree-removal-gate.ps1` has for the parallel checkpoint.
- The #635 sanctioned removal manifest does not cover this case because its authorized `branch_state` set excludes merged states by design.
- Related closed issue #573 fixed the reverse direction (epic gate blocking parallel runs).

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester cases for the parallel gate reading an epic checkpoint whose feature is `merged` or `worktree_removed` at the requested path (allow), and an epic checkpoint that does not cover the path (deny).
- [x] Integration scenario to retest: remove a merged child worktree from an epic orchestrator context with no parallel checkpoint present.
- [x] Manual verification notes: both gates must keep denying a path that neither checkpoint covers.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
