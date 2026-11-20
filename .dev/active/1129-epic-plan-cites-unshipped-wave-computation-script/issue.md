# epic-plan-cites-unshipped-wave-computation-script (Issue #1129)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-plan-cites-unshipped-wave-computation-script/ (Issue #1129)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1129
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1129
- Last Updated: 2026-11-08
- Work Mode: full-bug

## Summary

The `epic-plan` skill cites `scripts/dev_tools/epic_wave_computation.py` as the reference implementation for wave layering, but the push-down does not ship that script to destination repositories. In iar-migration the planner computed the waves by hand.

## Environment

- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `/epic-plan` in a pushed-down destination repository
- Data source or fixture: iar-migration E1/E2 planning, 2026-11-07/08

## Steps to Reproduce

1. Push down the Claude customizations to a destination repository.
2. Run `/epic-plan` there.
3. Observe that the skill points to `scripts/dev_tools/epic_wave_computation.py`, which does not exist in the destination.

## Expected Behavior

The wave-layering reference the skill names exists in every repository the skill is pushed to, or the skill names a script that is shipped.

## Actual Behavior

The cited script is missing in destination repositories, so the planner computes waves by hand, without the reference implementation's cycle and unresolved-reference checks.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `epic-plan` SKILL.md `## Decomposition and Wave Design`, step 4.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The script lives under `scripts/dev_tools/` in this repository, which the push-down does not bundle. Repository policy prefers PowerShell or bash for pushed-down skill tooling over new Python. Options: ship a PowerShell port under the skill or `.claude/lib/` and cite it, with parity against the Python reference; or ship the existing script in the bundle. Check the same issue for other scripts the epic skills cite.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: wave layering, cycle detection, and unresolved references in the shipped implementation; parity with the Python reference if both remain.
- [ ] Integration scenario to retest: a push-down to a scratch destination contains every script the epic skills cite.
- [ ] Manual verification notes: update `epic-plan` and `epic-orchestrate` text and mirrors; add a test that fails when a skill cites a script the push-down does not ship; state that destination repositories need a push-down refresh.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
