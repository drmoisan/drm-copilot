# epic-wave-barrier-violations-lack-start-guard (Issue #659)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-wave-barrier-violations-lack-start-guard/ (Issue #659)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #659
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/659
- Last Updated: 2026-09-08
## Summary

`_validate_wave_barrier_ordering` in `scripts/dev_tools/validate_epic_orchestrator_state.py` applies no start guard: it emits `EPIC_WAVE_BARRIER_VIOLATION` for every dependency edge whose upstream `merge_status` is not `merged` or `worktree_removed`, regardless of whether the dependent feature has started. A freshly bootstrapped epic checkpoint therefore always reports one violation per edge.

## Environment

- OS/version: Windows 11 Pro 10.0.26200.
- Python version: 3.13 (Poetry environment).
- Command/flags used: `validate_orchestration_artifacts.py epic-orchestrator-state artifacts/orchestration/epic-orchestrator-state.json`.
- Data source or fixture: epic #655 checkpoint at kickoff (four `depends_on` edges).

## Steps to Reproduce

1. Bootstrap an epic checkpoint from a manifest with at least one `depends_on` edge; every feature is `not_started`.
2. Run the epic-orchestrator-state validator without `require_complete`.
3. Observe one `EPIC_WAVE_BARRIER_VIOLATION` per edge although no dependent has started.

## Expected Behavior

A wave-barrier violation is reported only when a dependent feature has started (`merge_status` beyond `not_started`) while an upstream dependency is not yet merged.

## Actual Behavior

Four violations at kickoff for epic #655, falling to zero only as dependencies merged. The SubagentStop gate does not run this check, so it is noise rather than a block, but it hides a real ordering violation among expected ones.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
EPIC_WAVE_BARRIER_VIOLATION x4 at kickoff (features 631, 632, 635, 637 all not_started)
```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Validator noise; a real violation would be indistinguishable from the expected ones until the end of the run.

## Suspected Cause / Notes

- The ordering check tests the upstream state only; it needs `dependent.merge_status != "not_started"` as a precondition.
- A TypeScript parity port may exist under `extensions/drm-copilot/src/lib/validate/`; apply the same guard there with byte-identical error strings.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: pytest cases for `not_started` dependent with unmerged upstream (no violation), started dependent with unmerged upstream (violation), started dependent with merged upstream (no violation).
- [x] Integration scenario to retest: validate a kickoff checkpoint and expect zero violations.
- [x] Manual verification notes: keep the error string unchanged for the true-violation case.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
