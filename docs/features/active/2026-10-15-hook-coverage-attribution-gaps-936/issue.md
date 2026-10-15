# hook-coverage-attribution-gaps (Issue #936)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-coverage-attribution-gaps/ (Issue #936)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #936
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/936
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

Two hook lines that are executed by tests are not attributed in CI PowerShell coverage. Recorded by #903 (Operator Follow-up 7 and policy-audit PA-2).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. CI run 38410234897: `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41` (catch body) shows ci 0.
2. CI run 38423196404: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207` show ci 0 although test ES-D1 asserts the exact deny reason that only line 207 produces.

## Expected Behavior

Executed lines are attributed, or the cause of the non-attribution is documented with a test that covers the line.

## Actual Behavior

The lines report 0 hits.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 policy-audit.2026-10-13T16-01.md PA-2; issue.md Operator Follow-up 7.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Item 7 was routed to the owner of hook-import-failure-exemptions.FailClosed.Tests.ps1 (epic #852 C4 / #786).

## Proposed Fix / Validation Ideas

- [ ] Add a test that covers modes.ps1:41.
- [ ] Investigate why ES-D1 does not attribute epic-scope 206-207 (stub construction or a separate runspace) and fix or document it.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch