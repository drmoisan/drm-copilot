# npm-token-guard-misses-append-assignment (Issue #933)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/npm-token-guard-misses-append-assignment/ (Issue #933)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #933
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/933
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

The workflow NPM token guard does not detect the append form NPM_TOKEN+=${{ secrets.X }}. Recorded as #903 Operator Follow-up 1 (from #845 research).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Add ``NPM_TOKEN+=${{ secrets.X }}`` to a workflow and run tests/scripts/dev_tools/test_workflow_npm_token_guard.py; none of the four finders reports it.

## Expected Behavior

The guard reports append assignments of NPM_TOKEN.

## Actual Behavior

The append form is not reported; #903 pinned this with the residual-bash-append-not-reported test row (AC-14).

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups item 1; evidence/regression-testing/fail-before-exception.p8-845.*.md.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Proposed pattern from the research: \bNPM_TOKEN\s*\+?=(?!=). This reverses a #845 spec non-goal, so it needs an operator decision.

## Proposed Fix / Validation Ideas

- [ ] Decide whether the append form is in scope; if so, change the finders and flip the pinned row to expect a finding.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch