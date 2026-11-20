# hooks-read-main-checkout-not-item-worktree (Issue #1105)

- Date captured: 2026-11-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hooks-read-main-checkout-not-item-worktree/ (Issue #1105)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1105
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1105
- Last Updated: 2026-11-07
- Work Mode: full-bug

## Summary

Several stop hooks and the review coverage hook resolve an item's artifacts against the main checkout instead of the item's worktree. As a result they reject correct returns, skip their deeper checks, or read stale data.

## Environment

- OS/version: Windows 11 Pro, PowerShell 7
- Python version: 3.13 (Poetry environment)
- Command/flags used: orchestrator runs that delegate to subagents working in item worktrees under `.claude/worktrees/`
- Data source or fixture: issues #1031, #1034, #1096, and #1097, observed on 2026-11-07

## Steps to Reproduce

1. Start an orchestrated item in its own worktree, with a feature folder that exists only on the item branch.
2. Let a researcher, `prd-feature`, planner, executor, preflight, or feature-review subagent return a repo-relative artifact path.
3. Observe the stop hook resolve that path from the main checkout.
4. For a review, let the review coverage hook run while the main checkout holds an old `artifacts/pester/powershell-coverage.xml`.

## Expected Behavior

Each hook resolves artifact paths and coverage files against the item worktree that produced them, then runs its full checks against the item's own content.

## Actual Behavior

- The researcher, `prd-feature`, planner, and executor artifact hooks accept only repo-relative paths, then test them from the main checkout, where the item's feature folder does not exist. Their deeper checks did not run, including the planner hook's Pre-Mortem check (#1096).
- An executor's stop hook rejected a preflight return because it looked for the preflight fix record in the main checkout. The record was committed on the item branch at `697ddeab8` (#1034).
- A feature-review stop hook rejected a PASS review because the artifacts existed only in the worktree (#1031).
- The review coverage hook read `artifacts/pester/powershell-coverage.xml` in the main checkout. That file dated from 2026-11-05 and came from another branch, at 12.33%, so the hook rejected every #1097 review. The item's real coverage was 93.96% to 94.01%. The coordinator deleted the stale file on 2026-11-07 as a stopgap.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: the reports are in the orchestrator returns for #1096 and #1097 and the review returns for #1031 and #1034.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Correct work is rejected, which costs review and preflight rounds. Checks that should run are silently skipped. A stale coverage file can block every review, or could pass a review on another branch's figures.

## Suspected Cause / Notes

The hooks run with the main checkout's scripts and resolve paths against their own working directory or the repository root, not the worktree identified by the payload or the delegation. The repository already has `Resolve-HookTargetWorktree`, which the batch-budget hooks use. The issue-adoption feature-folder probe already reads the run worktree with `git -C <worktree root>`.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: path resolution for each affected hook, with a path that exists only in the item worktree, only in the main checkout, and in both.
- [ ] Integration scenario to retest: a full item run in a worktree in which every stop hook runs its deeper checks and none rejects a correct return.
- [ ] Manual verification notes: the coverage hook reads the item worktree's coverage output, or fails closed with a clear message when it is absent or older than the item's head, and never reads another branch's file.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
