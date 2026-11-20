# ts-integer-check-accepts-float-formatted-json (Potential Bug)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: follow-up 7 of issue #484 (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md`, `## Rollout & Follow-up`)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

`JSON.parse` yields the same number for `2.0` and `2`, so the TypeScript integer checks (#484 invariants R7a and R11, `orchestrator-state-remediation-accounting.ts`) accept a float-formatted integer that the Python validator rejects because `json.load` produces a `float`. In addition, PowerShell rejects integers larger than Int64, which Python accepts (non-blocking review note on #484).

## Environment

- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: orchestrator-state validation in Python, TypeScript, and PowerShell
- Data source or fixture: a checkpoint with `"remediation_loop": {"completed_attempts": 2.0}`

## Steps to Reproduce

1. Create a checkpoint whose `remediation_loop.completed_attempts` is written as `2.0`.
2. Validate it with the Python validator and with the TypeScript validator.

## Expected Behavior

Both runtimes return the same result.

## Actual Behavior

Python reports the R7a integer error; TypeScript accepts the value. The #484 parity corpus excludes floats for this reason.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: none captured.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The parsed JSON value in TypeScript carries no lexical form. A fix needs either a raw-text-aware parse for these fields or a documented decision that Python should accept integral floats. Record this together with the cross-runtime rendering follow-up.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: float-formatted and out-of-Int64 integers in the shared parity corpus once the intended behavior is chosen
- [ ] Integration scenario to retest: the three parity readers
- [ ] Manual verification notes: none

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
