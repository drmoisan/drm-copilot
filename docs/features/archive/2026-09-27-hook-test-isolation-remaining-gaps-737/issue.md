# hook-test-isolation-remaining-gaps (Issue #737)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-test-isolation-remaining-gaps/ (Issue #737)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #737
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/737
- Last Updated: 2026-09-27
- Work Mode: full-bug

## Summary

#709 (PR #728) mocked the epic-checkpoint read in seven gate suites and added a structural guard. Several suites and guard gaps remain, and #707 found a related gap in the no-Python guard.

## Environment

- OS/version: developer machines (CI has no local state)
- Python version: n/a (Pester)
- Command/flags used: the Pester suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- Data source or fixture: #709 `evidence/other/follow-ups.md`; the #707 follow-ups

## Steps to Reproduce

1. D8: four other epic gate suites may read `artifacts/orchestration/epic-orchestrator-state.json` without the mock.
2. D5: the Codex suites are not covered by #709's mocks or guard.
3. D9: the structural guard checks a hard-coded list of seven suites, so a new suite that reads epic state is not caught.
4. Review found:
   - CR-1: no test proves the mock actually intercepts the read.
   - CR-2: two ways the guard can pass wrongly.
   - CR-3: untested guard branches.
   - CR-7: a stale comment.
5. #707: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` does not scan `.codex/hooks`.

## Expected Behavior

Every gate suite on both surfaces is hermetic against local orchestration state. The guards discover their targets instead of using fixed lists, and cover both surfaces.

## Actual Behavior

The gaps listed above.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #709 and #707 follow-ups on main.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Same class as #510: gitignored local state leaking into tests.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: extend the mocks to the four remaining suites and to the Codex suites; make the guard discover suites by pattern; add an interception-proof test; close the CR-2 and CR-3 gaps; extend the no-Python guard's scan roots to `.codex/hooks`.
- [ ] Integration scenario to retest: run the suites with a deliberately present local epic checkpoint and expect identical results.
- [ ] Manual verification notes: none.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## Consolidation Scope (#737 comment, 2026-09-29)

- Add a parity test covering the main `enforce-orchestration-preimplementation-gate.ps1` across the Claude and Codex surfaces (remaining gap from #555, closed as delivered by PR #572).
- Add a parity test pinning `GENERATED_AGENT_FAMILIES` between the Python authority and `CodexDeployment.psm1` (drift class from #646, closed as delivered by PR #699).

## Bundled Issues

This child (C5b of epic #852, `enforcement-hook-precision`) delivers the following issues in one pull request. No new GitHub issue is created.

- #737 (primary): the scope above, including D8 (hermetic epic gate suites), D5 (Codex suites), D9 (suite discovery instead of a fixed list), CR-1, CR-2, CR-3, CR-7, the no-Python guard scanning `.codex/hooks` (#707), and the two consolidation parity tests.
- #746 (secondary): `Get-CodexPreToolUseRegistration` returns `$registrations.ToArray()` without the leading-comma idiom, so a single registration unrolls to a scalar. Acceptance conditions:
  - The function returns `,$registrations.ToArray()`, so the caller always receives an array (zero, one, or many registrations).
  - The #711 test workarounds that compensate for the scalar unroll are removed, and the affected assertions still fail on an empty or missing registration set.
  - Any bundled mirror of a changed file under `extensions/drm-copilot/resources/` is updated, and the bundle-parity tests stay green.
- #335 is excluded: it is closed as obsolete and is not in scope for this child.

## Upstream Dependencies

This child executes after #736 (C5a), #732 (C1b), and #850 (C3) merge into `epic/enforcement-hook-precision-integration`. Suite targets are discovered mechanically on the integration branch at execution time rather than taken from a list fixed during preparation.
