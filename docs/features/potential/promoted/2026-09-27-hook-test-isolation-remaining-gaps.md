# hook-test-isolation-remaining-gaps (Issue #737)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-test-isolation-remaining-gaps/ (Issue #737)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #737
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/737
- Last Updated: 2026-09-27
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
