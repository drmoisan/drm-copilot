# create-active-folder-bug (Issue #43)

- Date captured: 2026-02-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/create-active-folder-bug/ (Issue #43)
- Issue: #43
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/43
- Last Updated: 2026-02-22
- Work Mode: full

## Summary

Delivered fix summary:
- Added `Dev: 3 Auto Create Folder` so active-folder creation can derive feature name from the active promoted markdown file (`${file}`) instead of relying only on manual input.
- Explicit full-mode runs now persist exactly one `- Work Mode: full` marker in moved `issue.md` content above the first `##` heading.
- Invalid auto-resolve inputs now emit deterministic guidance: `Select a promoted issue markdown file under docs/features/potential/promoted or supply --feature-name directly.`

## Environment

- OS/version:
- Python version:
- Command/flags used:
- Data source or fixture:

## Steps to Reproduce

1. ...
2. ...
3. ...

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened (include key error text).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet:

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Optional early hunches, related changes, or files to inspect.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas
- [ ] Integration scenario to retest
- [ ] Manual verification notes

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch