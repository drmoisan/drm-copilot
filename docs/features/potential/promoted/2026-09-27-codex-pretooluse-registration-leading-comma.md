# codex-pretooluse-registration-leading-comma (Issue #746)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-pretooluse-registration-leading-comma/ (Issue #746)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #746
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/746
- Last Updated: 2026-09-27
## Summary

`Get-CodexPreToolUseRegistration` returns `$registrations.ToArray()` without the PowerShell leading-comma idiom. A single-element result is therefore unrolled to a scalar, which is the root cause behind #711's AC-5 fragility (its decision D5).

## Environment

- OS/version: any
- Python version: n/a (PowerShell)
- Command/flags used: Codex PreToolUse registration enumeration
- Data source or fixture: #711 `spec.md` D5 and its review files on main

## Steps to Reproduce

1. Call `Get-CodexPreToolUseRegistration` in a configuration that yields exactly one registration.
2. The caller receives the object itself rather than a one-element array, so `.Count` and indexing behave differently.

## Expected Behavior

The function always returns an array: `return ,$registrations.ToArray()`.

## Actual Behavior

A single registration unrolls to a scalar. #711 worked around it in its test assertions rather than fixing the source.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #711 spec D5. Minor: #711's Phase 0 policy-read evidence file has no `Command:` or `EXIT_CODE:` fields.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

A standard PowerShell array-unrolling pitfall.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add the leading comma; add Pester cases for 0, 1 and N registrations that assert an array type; grep the other `.ToArray()` returns in the hook libraries for the same pitfall.
- [ ] Integration scenario to retest: the Codex hook registration suites still pass.
- [ ] Manual verification notes: none.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
