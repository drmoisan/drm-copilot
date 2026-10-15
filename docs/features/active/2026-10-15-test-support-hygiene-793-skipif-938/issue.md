# test-support-hygiene-793-skipif (Issue #938)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/test-support-hygiene-793-skipif/ (Issue #938)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #938
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/938
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

Two small Python test-hygiene items recorded as #903 Operator Follow-ups 9 and 12.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. #793 L22: `build_valid_epic_state` and `build_read_text_stub` live in a test module rather than a `*_test_support.py` module.
2. `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py:11-15` keeps a skipif reason ("gitignored and unavailable in CI") that .gitignore no longer supports.

## Expected Behavior

Shared builders live in a test-support module; skip reasons are accurate or the skip is removed.

## Actual Behavior

Both items remain.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups 9 and 12.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

The new #903 P7 mirror test already covers the atomic-plan-contract .agents pair unconditionally.

## Proposed Fix / Validation Ideas

- [ ] Move the two builders into a test-support module.
- [ ] Remove or correct the stale skipif.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch