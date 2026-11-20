# preimpl-gate-demands-checkpoint-for-merged-feature-followup (Issue #1141)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimpl-gate-demands-checkpoint-for-merged-feature-followup/ (Issue #1141)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1141
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1141
- Last Updated: 2026-11-08
- Work Mode: full-bug

## Summary

When an agent performs a follow-up on a feature whose PR has already merged (for example into an epic integration branch), the preimplementation gate demands a readiness checkpoint for that feature. No documented, gate-recognized path exists for this case, so agents hand-author a readiness checkpoint to get past the gate.

## Environment

- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a (PowerShell hooks)
- Command/flags used: `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08
- Data source or fixture: epic checkpoint recording the feature as merged; no live per-item orchestrator checkpoint for it

## Steps to Reproduce

1. Run an epic until feature F has merged into `epic/<slug>-integration` (merge_status `merged` in the epic checkpoint).
2. A follow-up on F is needed (for example a small correction, an AC check-off, or a status/evidence update for F's folder).
3. The agent attempts the Write/Edit or `git add`/`git commit` for that follow-up.

## Expected Behavior

A documented, gate-recognized path exists for follow-ups on an already-merged feature. Agents never hand-author a readiness checkpoint. The allowed path is narrow and auditable (for example: a follow-up checkpoint created by a defined tool or skill step that references the merged feature and the epic checkpoint record; or a gate rule that recognizes the merged state from the epic checkpoint for a bounded path set).

## Actual Behavior

The preimplementation gate denies the operation because no readiness checkpoint exists for F. Agents then hand-author a checkpoint with `lifecycle_ready` and receipts to pass the gate.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: preimplementation gate deny for a follow-up write on a merged epic feature.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The gate recognizes only a live per-item readiness checkpoint (and, since #1136 / PR #1140, a narrow post-fan-in allowance on the integration branch). It has no state for "feature already merged; follow-up in progress". #1140 added `hook-epic-fan-in.ps1` with `Get-EpicFanInAllowance -Scope ...` as a seam intended for this finding and finding 9 (stop hook validating the wrong worktree's checkpoint). Owner constraint: do not weaken the gate's intent; make the legitimate path pass; agents must never hand-author a checkpoint.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: follow-up path allowed only for a feature recorded merged in the epic checkpoint (or a defined follow-up record); denied for unmerged features, for paths outside the bounded set, and for hand-authored checkpoints lacking the defined provenance.
- [ ] Integration scenario to retest: follow-up write and commit on a merged epic feature.
- [ ] Manual verification notes: document the path in the orchestrate and epic-orchestrate skills; destinations need a push-down refresh.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
