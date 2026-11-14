# parallel-planner-leaves-scratch-worktrees (Issue #1002)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-planner-leaves-scratch-worktrees/ (Issue #1002)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1002
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1002
- Last Updated: 2026-10-30
- Work Mode: full-bug

## Summary

The parallel planner creates scratch worktrees (`wt989`, `wt990`, `wtplan`) during planning and never removes them. The worktree-removal hooks then refuse to delete them, so they persist after the run closes.

## Environment

- OS/version: Windows 11, PowerShell 7
- Python version: not applicable
- Command/flags used: `/parallel-plan` then `/parallel-run` for #989 and #990
- Data source or fixture: run `pr-author-and-file-size`

## Steps to Reproduce

1. Run `/parallel-plan` over two items.
2. Complete the run through `/parallel-run` and the Run Closing step.
3. List worktrees and observe the planner scratch worktrees still registered.

## Expected Behavior

Planning leaves no worktree behind, or removes each one it creates before finishing.

## Actual Behavior

Three scratch worktrees remain. `PARALLEL_WORKTREE_REMOVAL_BLOCKED` refuses their removal. Only the repo-wide `cleanup-merged-worktrees` apply mode could remove them, and that is risky because it operates on every worktree.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PARALLEL_WORKTREE_REMOVAL_BLOCKED`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The planner's preparation delegations create worktrees that no manifest or checkpoint records, so the removal gates cannot match them to a finished run. Related: #995 fixed removal of item worktrees but not planner scratch worktrees.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: planner closes or avoids scratch worktrees; removal gate behavior for unrecorded planner worktrees.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Fix at the source: stop the planner from creating scratch worktrees, or have it remove them at the end of planning.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
