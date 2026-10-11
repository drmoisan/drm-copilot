# pr-author-hook-blocks-docs-only-prs-without-checkpoint (Issue #901)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-author-hook-blocks-docs-only-prs-without-checkpoint/ (Issue #901)
- Origin: parallel run bug-burndown-2026-10-08 record reconciliation, 2026-10-09 (branch `docs/parallel-run-records-2026-10-09`); process defect

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #901
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/901
- Last Updated: 2026-10-11
## Summary

The pr-author PreToolUse hook requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` before `gh pr create` with `--body-file` is allowed. A documentation-only branch created outside an orchestration (for example a run-record reconciliation) has no checkpoint, so agents cannot open its PR. On 2026-10-09 the branch `docs/parallel-run-records-2026-10-09` was pushed but no PR was opened, and its records have not reached main.

## Environment

- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `gh pr create --body-file artifacts/pr_body_<N>.md` from the pr-author agent
- Data source or fixture: main at 2ef8d361; `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`; worktree `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-10-09-parallel-run-records`

## Steps to Reproduce

1. Create a branch that changes only documentation under `docs/`, outside any orchestration, so that no `artifacts/orchestration/orchestrator-state.json` exists in the worktree.
2. Delegate to the pr-author agent to open the PR.
3. Observe the hook decision.

## Expected Behavior

A documentation-only PR can be opened by an agent through pr-author, either through an explicit exemption for changes confined to documentation paths or through a lightweight checkpoint the hook accepts.

## Actual Behavior

- `.claude/hooks/enforce-pr-author-skill.ps1:24-25`: "Preflight - --body-file/context present: orchestrator-state checkpoint must pass --require-pr-creation-ready ... else blocked."
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1:408-419` calls `Invoke-OrchestratorStatePreflight -CheckpointPath $checkpointPath` and returns `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: ... checkpoint missing at $checkpointPath`. Lines 386-388 also deny when the target worktree cannot be resolved. There is no exemption for documentation-only changes.
- `gh pr list --state all --search "head:docs/parallel-run-records-2026-10-09"` returns `[]`. The branch is pushed at `0b81e1845` ("docs(parallel): reconcile completed run records", 2026-10-09T19:24:47-04:00) and is not an ancestor of origin/main. Its worktree has no `artifacts/` directory.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: hook output form: `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: ... checkpoint missing at <path>`. The exact denial text from 2026-10-09 was not preserved in a committed artifact.
- Contrast: docs PR #866 (`docs/preserve-pending-promoted-records-2026-10-09`) was opened by the operator account at 2026-10-09T23:05Z, outside pr-author.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. Run records and follow-up documentation remain on unmerged branches until an operator opens the PR by hand. This also affects branches such as this follow-up filing branch.

## Suspected Cause / Notes

- The preflight assumes every PR originates from an orchestration with a checkpoint.
- Related memory of earlier sessions: cleanup consolidation PRs needed operator hands for the same reason.

## Proposed Fix / Validation Ideas

- [ ] Add a documented exemption when every changed path is under an allowlisted documentation tree (for example `docs/features/potential/**`, `docs/features/parallel/**`, `docs/features/epics/**`), verified from `git diff --name-only <base>...HEAD`.
- [ ] Alternatively, define a minimal "documentation PR" checkpoint shape that `--require-pr-creation-ready` accepts.
- [ ] Unit coverage areas: Pester cases for a docs-only diff (allow), a mixed diff without checkpoint (deny), and a docs-only diff touching `.claude/` (deny).
- [ ] Mirror the change into the Codex copy and the bundled payload.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch