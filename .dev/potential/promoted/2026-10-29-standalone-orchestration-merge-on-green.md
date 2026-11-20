# standalone-orchestration-merge-on-green (Issue #997)

- Date captured: 2026-10-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/standalone-orchestration-merge-on-green/ (Issue #997)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #997
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/997
- Last Updated: 2026-10-29
## Summary

A standalone orchestration (neither an epic child nor a parallel item) cannot merge its own pull request after CI is green. The merge gate allows a standalone merge only through a hand-written, session-bound `standalone_merge_authorizations` record (#670). The orchestration therefore stops at a green PR and a person must merge it or write the record.

## Environment

- OS/version: Windows 11
- Python version: not applicable
- Command/flags used: `gh pr merge --merge <PR>` under `.claude/hooks/enforce-epic-merge-gate.ps1`
- Data source or fixture: standalone `/orchestrate` runs

## Steps to Reproduce

1. Run `/orchestrate` for a single item to a green PR (`step9_status` passed, `ci_gate.conclusion` success).
2. Attempt `gh pr merge --merge <PR>`.

## Expected Behavior

When the checkpoint records `step9_status` passed, `ci_gate.conclusion` success, a `ci_gate.head_sha` equal to the live PR head, and a binding to the explicit PR number, the orchestration merges its own PR and confirms the merge.

## Actual Behavior

The gate returns `EPIC_MERGE_GATE_BLOCKED`. Branch 1 requires `epic_mode` to be true, and a standalone run satisfies none of branches 1 to 3.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `EPIC_MERGE_GATE_BLOCKED` from `enforce-epic-merge-gate.ps1`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

By design: a standalone run never merges itself. This item reverses that policy for the green-CI case, at the user's direction on 2026-10-29. See research section 7 to 9 in `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/research/research.2026-10-29T10-07.md` for the enforcement and prose locations, the proposed sibling hook file `enforce-epic-merge-gate-green-ci.ps1`, and the pinning tests.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: a new pure green-CI check, with fail-closed cases for stale head, pending or failed CI, `step9_status` not passed, unbound or different PR number, missing checkpoint, bare command, `gh` failure or timeout, and a differing `--match-head-commit`.
- [ ] Integration scenario to retest: a standalone orchestration merges its own green PR; a parallel child still does not.
- [ ] Manual verification notes: keep the #670 authorization branch for non-green cases; update the orchestrate skill S9 step 6 and the PR Creation Gate; mirror changes.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
