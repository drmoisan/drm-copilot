# epic-worktree-removal-gate-denies-merged-parallel-item-worktree (Issue #851)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-worktree-removal-gate-denies-merged-parallel-item-worktree/ (Issue #851)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #851
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/851
- Last Updated: 2026-10-08
## Summary

During parallel run bug-burndown-2026-09-29, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denied `git worktree remove` for the merged item #623's worktree (`.claude/worktrees/agent-abb9705e1b9ac1818`) although the parallel checkpoint recorded that `worktree_path` with `merge_status: merged`. The worktree is still on disk as of 2026-10-08. Re-evaluating the same command against the same checkpoint on main fb413fce now returns allow, so the cause of the original deny is not determined, and the deny message does not carry enough information to determine it after the fact.

## Environment

- OS/version: Windows 11 Pro; Claude Code 2.1.284
- Python version: n/a (PowerShell PreToolUse hook)
- Command/flags used: `git -C <main-checkout> worktree remove <main-checkout>/.claude/worktrees/agent-abb9705e1b9ac1818`, issued by the parallel-orchestrator from session root `drm-copilot-wt/2026-09-29T13-45` (HEAD a24a1ce3, which contains the #690 resolution commits ad2f8f41 and 8f566bfb)
- Data source or fixture: parallel checkpoint `drm-copilot-wt/2026-09-29T14-30-parallel-bug-burndown/artifacts/orchestration/parallel-orchestrator-state.json`, item 623 (`route_id: parallel`, `worktree_path` equal to the command operand, `merge_status: merged`, `merged_at: 2026-09-30T13:42:13Z`, PR #804)

## Steps to Reproduce

1. Merge a parallel item and set its `items[]` record to `merge_status: merged` in the parallel checkpoint held by the run's worktree (not the session root).
2. From the coordinator session root, issue `git -C <main> worktree remove <item worktree_path>`.
3. Observe the decisions of `enforce-parallel-worktree-removal-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1`.

## Expected Behavior

Both removal gates allow the removal: the epic gate's parallel branch (`Test-ParallelCheckpointAllowsWorktreeRemoval`) matches the item by `worktree_path` and `merge_status` is in `{merged, worktree_removed}`. If the gate denies, the reason names the run kind that resolved, the checkpoint path it read, and the `merge_status` it found.

## Actual Behavior

Observed at 2026-09-30T13:42:33Z (transcript of parallel-orchestrator agent a8b4aeca84152304a):

`EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '<main-checkout>/.claude/worktrees/agent-abb9705e1b9ac1818' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == "parallel" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal.`

The deny carries no `TARGET_WORKTREE_NOT_DERIVABLE` prefix, so at least one run kind resolved (`enforce-epic-worktree-removal-gate.ps1:398-403`), yet the parallel branch did not allow. An attempt 10 seconds earlier, chained after the checkpoint update, was denied by the parallel gate (`PARALLEL_WORKTREE_REMOVAL_BLOCKED`), which is expected because the hook ran before the update. The run notes recorded the item as `agent-abb9705e1b9ac1818 (623, epic removal gate denies)` under `deferred_worktree_cleanup`.

Re-check on 2026-10-08 (not a reproduction): dot-sourcing the gate from main fb413fce with cwd at the same session root, `Read-EpicWorktreeGateRunCheckpoint` returns `epic: NoTarget` and `parallel: OtherWorktree` (root `drm-copilot-wt/2026-09-29T14-30-parallel-bug-burndown`, checkpoint read), and the decision for the same command is `allow`. `git diff a24a1ce3 fb413fce` is empty for both removal-gate files, `.claude/lib/worktree-resolution/`, the command scanner files and `.claude/settings.json`, so the code did not change between the deny and the re-check. The difference therefore lies in runtime state at 13:42:33Z (checkpoint content or the set of live worktrees), which the deny text does not record.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior. Relevant code: parallel allow predicate `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:224-286`; decision flow `:360-403`; resolution seam `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1:112` (`Resolve-WorktreeRunTargetByRecord -RecordField worktree_path -SessionRoot (Get-Location).Path`) and `:117-145`, which resolves the target and then reads the checkpoint a second time through `Get-EpicWorktreeGateParallelCheckpointContent`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

A merged item's worktree is left on disk and has to be removed by an operator. No item is blocked, because `merged` is terminal. The diagnosability gap means a recurrence cannot be classified from the transcript either.

## Suspected Cause / Notes

Not determined. Candidates, none confirmed: (a) the checkpoint is read twice (once during resolution, once in `Read-EpicWorktreeGateRunCheckpoint`), so a read that coincides with a checkpoint rewrite can resolve the target and then parse a null checkpoint, which falls through to the generic deny; (b) the item record seen by the hook at that instant did not yet carry `merge_status: merged`; (c) another live worktree's checkpoint recorded the same `worktree_path` and the resolver selected it. Prior issues on this gate are closed and addressed different defects: #573 (parallel allow-branch added, c4261e51), #657 and #688 (the parallel gate blocking epic cleanup). Code reading and the 2026-10-08 re-check do not indicate a regression of those fixes. Related open issue #742 covers removal-gate false positives on non-removal commands, not this case.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: include in the generic deny the resolution status per kind, the checkpoint path read, whether it parsed, and the matched record's `merge_status`; read the resolved checkpoint once and pass the parsed object through. Pester rows for a parallel target that resolves but whose checkpoint read returns null, and for a matched record with a non-terminal `merge_status`, asserting the new diagnostic fields.
- [ ] Integration scenario to retest: in the next parallel run, remove a merged item worktree from the coordinator session root immediately after the checkpoint update, as the orchestrator does.
- [ ] Manual verification notes: remove `agent-abb9705e1b9ac1818` now that the gate allows it, and record the decision.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
