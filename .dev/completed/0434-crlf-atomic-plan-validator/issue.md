# crlf-atomic-plan-validator (Issue #434)

- Date captured: 2026-08-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-08-04-crlf-atomic-plan-validator-434/ (Issue #434)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #434
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/434
- Last Updated: 2026-08-04
- Work Mode: full-bug

## Summary

The TypeScript MCP atomic-plan validator splits input only on LF. Canonical plans
with CRLF or lone-CR line endings retain a trailing carriage return and valid
phase and task lines fail their end-anchored structural regular expressions.

## Environment

- OS/version: Windows 11
- Python version: Not applicable
- Command/flags used: `validate_orchestration_artifacts` with `artifact_type = plan`
- Data source or fixture: Canonical completed atomic-plan text encoded with LF, CRLF, or CR line endings

## Steps to Reproduce

1. Encode a canonical atomic plan containing phase headings and completed task lines using CRLF or CR line endings.
2. Validate the plan through the MCP `validate_orchestration_artifacts` tool.
3. ...

## Expected Behavior

The validator accepts structurally identical canonical plans regardless of LF,
CRLF, or CR line endings.

## Actual Behavior

The LF version validates, but CRLF and CR versions fail canonical phase/task
validation because the validator uses `text.split("\n")` and leaves `\r` on
each line. TaskMaster issue #400's CRLF-only plan demonstrates the failure.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `Line N: phase heading must match \`### Phase N — <Title>\`.` and `Line N: task line must match \`- [ ] [P#-T#] <Title>\`.`

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` line 73
uses LF-only splitting. The Python reference validator uses line-ending-neutral
splitting and accepts the same content.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: add failing CRLF completed-task coverage, then prove LF, CRLF, and CR validation parity.
- [x] Integration scenario to retest: run the generated MCP bundle against canonical plan content with each line ending.
- [x] Manual verification notes: no manual validation is required; the release workflow must publish and inspect the immutable npm bundle.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
