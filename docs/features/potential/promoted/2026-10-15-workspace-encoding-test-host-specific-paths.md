# workspace-encoding-test-host-specific-paths (Issue #934)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/workspace-encoding-test-host-specific-paths/ (Issue #934)
- Work Mode: minor-audit

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #934
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/934
- Last Updated: 2026-10-15
## Summary

extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts contains about 30 lines with a host-specific user path segment. Recorded as #903 Operator Follow-up 2 (related to #846 CR-6).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. grep the file for the host user segment.

## Expected Behavior

Tests use neutral fixture paths.

## Actual Behavior

About 30 lines encode a real host path, which leaks host data and ties the test to one machine layout.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups item 2.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Repository rule: never encode absolute host paths in artifacts.

## Proposed Fix / Validation Ideas

- [ ] Replace the host-specific segments with a neutral placeholder and keep the encoding assertions unchanged.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch