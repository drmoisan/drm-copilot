# epic-merge-gate-authorization-record (Issue #670)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-merge-gate-authorization-record/ (Issue #670)
- Epic: worktree-scoped-state-resolution (F3, wave 0, complexity C3)
- Epic ref: 3.6

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #670
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/670
- Last Updated: 2026-09-14
## Summary

`.claude/hooks/enforce-epic-merge-gate.ps1` denies `gh pr merge --merge` for a standalone pull
request, because a standalone PR matches none of the gate's three allow paths. A fix that unblocks
a parallel or epic run therefore cannot be landed by the orchestration that discovered it.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (hook is PowerShell 7+, platform-neutral)
- Python version: not applicable; the hook is PowerShell and must remain PowerShell or bash
- Command/flags used: `gh pr merge <N> --merge`
- Data source or fixture: `artifacts/orchestration/*orchestrator-state.json` checkpoints

## Steps to Reproduce

1. Run a parallel orchestration (for example TaskMaster run `bugs-2026-09-11`) and let an agent
   discover a defect whose fix must land as a standalone pull request rather than as a tracked
   parallel item.
2. Open that standalone fix PR, drive it to CLEAN mergeable state with all required checks passing.
3. Invoke `gh pr merge <N> --merge` from the orchestrating session.

## Expected Behavior

A standalone merge that the orchestration has explicitly and auditably authorized is permitted, so
the run can land its own unblocking fix.

## Actual Behavior

The gate denies with `EPIC_MERGE_GATE_BLOCKED`. The standalone PR matches none of the three
documented allow paths (epic child, epic integration, parallel item matched by `pr_number` against
an `items[]` entry whose `merge_status == "ci_green"`), and the hook documents this exclusion as
deliberate. Observed consequence: run `bugs-2026-09-11` stalled with a green, CLEAN,
all-checks-passing PR that no agent could merge.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: deny reason code `EPIC_MERGE_GATE_BLOCKED` emitted by the PreToolUse hook.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Total standstill of a 13-item parallel run: the fix that would have unblocked it was unlandable by
the orchestration that produced it.

## Suspected Cause / Notes

- Allow paths documented at lines 8-19 of `.claude/hooks/enforce-epic-merge-gate.ps1`.
- Existing internals: `Test-ChildCheckpointAllowsEpicMerge` (line 177),
  `Test-EpicCheckpointAllowsMerge` (line 206), `Test-ParallelCheckpointAllowsMerge` (line 264);
  `$script:ParallelCheckpointPath` at line 50.
- The file is 486 lines against the repository's 500-line cap, so a fourth allow path cannot be
  added in place; a helpers extraction is required.
- Bundled payload mirror at
  `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
  is byte-identical today and must receive the same change, or the push-down publishes stale
  content.
- `.codex/hooks/enforce-epic-merge-gate.ps1` is a separate, smaller implementation of the same
  decision surface and carries a parity obligation.

## Proposed Fix / Validation Ideas

User ruling (settled, not to be re-litigated): **relax with an authorization record**. Permit a
standalone merge only when an explicit, auditable authorization record naming that specific PR is
present in orchestrator state. Do not widen the `pr_number` matcher. A blanket
"standalone merges allowed" flag is not an authorization record and must be rejected.

Rejected workarounds, recorded as closed anti-patterns:

1. Injecting a synthetic `items[]` record to satisfy the `pr_number` matcher.
2. Switching to `--squash` to evade the matcher.

- [x] Unit coverage areas: table-driven Pester over the full allow/deny matrix, with every
      currently-passing case retained as a regression guard.
- [x] Integration scenario to retest: standalone PR with a valid authorization record naming that
      PR; the same record naming a different PR; no record at all.
- [x] Manual verification notes: prove the `pr_number` matcher is byte-unchanged.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
