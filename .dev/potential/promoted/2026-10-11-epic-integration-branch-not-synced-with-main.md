# epic-integration-branch-not-synced-with-main (Issue #902)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-integration-branch-not-synced-with-main/ (Issue #902)
- Origin: epic #852 enforcement-hook-precision (wave 3 `epic-852-main-sync`, PR #882; integration PR #883); process defect

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #902
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/902
- Last Updated: 2026-10-11
## Summary

The epic-orchestrate skill branches the integration branch from `origin/main` once and never merges `origin/main` back in while child waves run. During epic #852 the integration branch fell 278 commits behind main between 2026-10-09 and 2026-10-11, and an extra wave (`epic-852-main-sync`, PR #882) was required to merge main before the integration PR. One earlier sync was performed on operator instruction on 2026-10-09.

## Environment

- OS/version: Windows 11 Pro, Claude Code epic orchestration
- Python version: n/a
- Command/flags used: `/epic-run` for epic #852
- Data source or fixture: `.claude/skills/epic-orchestrate/SKILL.md` on main at 2ef8d361; `artifacts/orchestration/epic-orchestrator-state.json` in worktree `2026-10-08T08-00-epic-enforcement-hook-precision`

## Steps to Reproduce

1. Start an epic whose waves run for more than a day while other work merges to main.
2. Follow `.claude/skills/epic-orchestrate/SKILL.md:90-111` ("Epic Integration Branch Lifecycle").
3. Before the final integration PR, run `git rev-list --count <integration>..origin/main`.

## Expected Behavior

The lifecycle includes a step that merges `origin/main` into the integration branch at defined points (for example before each wave), so child branches are created from a current base and the final integration PR does not require a large catch-up merge.

## Actual Behavior

- `.claude/skills/epic-orchestrate/SKILL.md:90-111`: step 1 branches from `origin/main` once; step 2 fetches only `origin epic/<slug>-integration` before each wave; step 5 opens the final integration PR. No step merges `origin/main`; the only `origin/main` mentions are lines 93 and 100.
- `git rev-list --count 9add694e4..daa6436cd` = 278 (19 first-parent merges).
- epic-orchestrator-state.json:1237 (2026-10-11T02:58Z): "Second main sync: origin/main is 278 commits ahead ... Coordinator Edit denied by PREIMPLEMENTATION_GATE_BLOCKED ... Merge aborted". The sync then had to run as its own child item (PR #882).
- The one earlier sync (`main_sync_merge`, lines 1263-1268: commit `86e457a0`, main tip `c61d5d39`, 2026-10-09T11:38Z) was made on operator decision (line 1255), not by the skill.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: PR #882 body: "Merges `origin/main` at `daa6436cd` (278 commits)". Also `docs/features/active/epic-852-main-sync/issue.md:11` and `plan.2026-10-10T22-52.md:30`.
- Snippet: epic-orchestrator-state.json:1260, operator decision: "Sync main into integration regularly from now on."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. A stale integration base increases conflict risk, means child CI runs test against old main, and required an extra planned wave plus operator decisions. The coordinator's direct merge attempt was also blocked by the preimplementation gate.

## Suspected Cause / Notes

- The lifecycle was written for short epics; it has no main-sync step and no drift threshold.
- The coordinator cannot perform the merge itself under `PREIMPLEMENTATION_GATE_BLOCKED`, so a sync needs either a child item or an explicit, gate-compatible route.

## Proposed Fix / Validation Ideas

- [ ] Add a main-sync step to the epic integration branch lifecycle (before each wave, or when `rev-list --count` exceeds a threshold), with a gate-compatible execution route.
- [ ] Record each sync in the epic checkpoint (`main_sync_merge` entries) and project it into `epic-status.md`.
- [ ] Mirror the change into `.agents/skills/epic-orchestrate` and the bundled copies.
- [ ] Integration scenario to retest: an epic spanning merges to main keeps its integration branch within the threshold.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch