# parallel-run-leaves-uncommitted-records-and-worktrees (Issue #995)

- Date captured: 2026-10-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-run-leaves-uncommitted-records-and-worktrees/ (Issue #995)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #995
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/995
- Last Updated: 2026-10-29
## Summary

A completed parallel run does not finish its own housekeeping. It leaves the run's planning records uncommitted and unmerged, and it leaves its item worktrees and the planner's scratch worktrees in place. A human must commit, merge and remove them by hand.

## Environment

- OS/version: Windows 11
- Python version: not applicable
- Command/flags used: `/parallel-plan` then `/parallel-run pr-author-and-file-size`
- Data source or fixture: run `pr-author-and-file-size`, items #989 (PR #991) and #990 (PR #993)

## Steps to Reproduce

1. Run `/parallel-plan` for two items that conflict, so they run in two cohorts.
2. Run `/parallel-run` to completion. Both item PRs merge.
3. Inspect the planning session's worktree and `git worktree list`.

## Expected Behavior

When the run completes, it commits and merges the records it generated (`parallel-status.md`, the run manifest and kickoff, any promoted records) and removes the item worktrees and the planner's scratch worktrees. No manual step remains.

## Actual Behavior

- `parallel-status.md` and the promoted potential records stayed untracked in the planning worktree. The manifest and kickoff were committed on a branch that was never merged.
- Both item worktrees stayed in place, locked by the agent process.
- The removal hook returned `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`. The checkpoint records `worktree_path` as a relative path, `.claude/worktrees/agent-...`, while the hook is matched on the absolute path in the command, so the item whose `merge_status` is `merged` is not recognised.
- The planner's three scratch worktrees (`wt989`, `wt990`, `wtplan`) were left behind because `git worktree remove` is hook-blocked.
- The pre-implementation gate blocks the `git add` and `git commit` needed to land the records, because no issue checkpoint is active.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: no live worktree's run checkpoint records worktree_path '<absolute path>'`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Every parallel run needs manual cleanup, and stale worktrees accumulate.

## Suspected Cause / Notes

The orchestrator has no closing step that commits generated records or removes worktrees, and the removal hook's path match does not normalise relative and absolute spellings. The harness lock on the item worktrees is held by the agent process that ran the item. Not yet confirmed against the hook source. See `.claude/skills/parallel-orchestrate/SKILL.md`, the worktree removal hook, and `.claude/skills/cleanup-merged-worktrees/SKILL.md`.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: path normalisation in the removal hook; a closing step that commits generated records through a route the pre-implementation gate accepts.
- [ ] Integration scenario to retest: a two-cohort run ends with records merged and no item or scratch worktree left.
- [ ] Manual verification notes: confirm unmerged or unfinished items are never removed.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
