# subagentstop-hook-uncaught-error-exits-1 (Issue #928)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/ (Issue #928)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #928
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/928
- Last Updated: 2026-10-15
- Work Mode: full-bug

## Summary

SubagentStop validators now block with exit 2 for deliberate block decisions (epic #904), but an uncaught terminating error in any of them still ends the pwsh -File process with exit 1. SubagentStop does not block on exit 1, so a crashing validator lets the subagent result through unchecked (NB-6).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Make any SubagentStop validator (for example `.claude/hooks/validate-task-researcher-output.ps1`) throw an unhandled terminating error, for example by corrupting an imported module.
2. Observe exit code 1; the SubagentStop event is not blocked.

## Expected Behavior

Any unhandled error in a SubagentStop validator blocks (exit 2) with a reason, consistent with fail-closed hook policy.

## Actual Behavior

The process exits 1 and the event proceeds.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: E3 code-review NB-6 (docs/features/active/subagentstop-envelope-artifact-gates-905/code-review.2026-10-12T04-58.md): "An uncaught terminating error in any hook still ends the pwsh -File process with exit 1, which does not block a SubagentStop event."

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- Applies to all 9 SubagentStop validators migrated by epic #904 (E1 helper `.claude/hooks/subagentstop-envelope.ps1`, E2-E4).
- #786 already converted two handlers to the uniform deny for the same exit-code reason.

## Proposed Fix / Validation Ideas

- [ ] Add a top-level trap/try in each validator (or in the shared helper's entry contract) that converts any unhandled error to `Exit-SubagentStopBlock` with a reason.
- [ ] Add one test per validator that forces an unhandled error and asserts exit 2.
- [ ] Mirror to the bundled copies.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch