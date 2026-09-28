# epic-worktree-removal-gate-blocks-parallel-runs (Issue #573)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-worktree-removal-gate-blocks-parallel-runs/ (Issue #573)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #573
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/573
- Last Updated: 2026-08-28
## Summary

The epic worktree-removal `PreToolUse` gate structurally denies every worktree removal issued by a parallel run, because it requires a matching epic checkpoint `features[]` record and a parallel run has no epic checkpoint. Merged parallel items therefore can never reach `merge_status: worktree_removed`, and every parallel run leaks its worktrees.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hook)
- Command/flags used: `git worktree remove <path>` issued by the parallel-orchestrator after a per-item merge
- Data source or fixture: parallel run `critical-bug-fixes` (11 items, completed 2026-08-26)

## Steps to Reproduce

1. Complete a parallel-run item to `merge_status: merged` (its PR merged into main).
2. From the parallel-orchestrator, attempt `git worktree remove` on that item's worktree.
3. The hook denies with: `EPIC_WORKTREE_REMOVAL_BLOCKED: ... requires a matching epic checkpoint features[] record with merge_status in {merged, worktree_removed}.`

## Expected Behavior

A parallel-run item whose own checkpoint records `merge_status: merged` (re-derivable from `gh pr view`) can have its worktree removed, reaching the `worktree_removed` terminal state defined in `.claude/rules/parallel-orchestration.md`. The gate should carry a parallel allow-branch keyed on the parallel-orchestrator checkpoint, analogous to the parallel allow-branch already present in `.claude/hooks/enforce-epic-merge-gate.ps1`.

## Actual Behavior

The gate consults only `artifacts/orchestration/epic-orchestrator-state.json` `features[]`. A parallel run has no such record, and the gate fails closed on its absence. `PreToolUse` denials are conjunctive, so no allow-hook can override it. The removal was attempted during the `critical-bug-fixes` closing pass and denied verbatim; 23 run worktrees remain on disk requiring manual cleanup. F7 (parallel enforcement hooks, issue #440) shipped no parallel counterpart for this gate. The completion predicate keys on `merged`, so the run completes; the leak is per-item housekeeping debt, not a run failure.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `EPIC_WORKTREE_REMOVAL_BLOCKED: ... requires a matching epic checkpoint features[] record with merge_status in {merged, worktree_removed}.` (demonstrated 2026-08-26 during the critical-bug-fixes closing pass)

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Every parallel run leaks one worktree per item (23 leaked in the first full run). Disk and `git worktree list` clutter accumulates; no data loss.

## Suspected Cause / Notes

The worktree-removal gate predates the parallel surface and was written epic-singular. The precedent fix shape exists: `.claude/hooks/enforce-epic-merge-gate.ps1` carries a parallel allow-branch that authorizes a per-item `gh pr merge` when `route_id == "parallel"` and the target item's state matches. Mirror that shape: authorize removal when the parallel checkpoint's matching item has `merge_status` in `{merged, worktree_removed}`, fail closed otherwise. Related: issue #440 (F7 parallel enforcement hooks).

## Proposed Fix / Validation Ideas

- [ ] Pester cases: parallel item merged — allow; parallel item not merged — deny; no parallel checkpoint — deny (unchanged epic behavior); epic path unchanged.
- [ ] Propagate to `.codex` and extension-resource copies per surface parity.
- [ ] Manual verification: rerun the denied removal from the completed run.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
