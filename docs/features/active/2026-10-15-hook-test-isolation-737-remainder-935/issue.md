# hook-test-isolation-737-remainder (Issue #935)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-test-isolation-737-remainder/ (Issue #935)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #935
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/935
- Last Updated: 2026-10-15
- Work Mode: full-bug

## Summary

Remaining hook-test isolation work from #737, recorded as #903 Operator Follow-ups 4, 5, 6, 10 and 11.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

See docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md, Operator Follow-ups.

## Expected Behavior

The items below are delivered or closed with a decision.

## Actual Behavior

- F-3 (item 4): the isolation guard does not detect `Join-Path <root-variable> '<name>.ps1'` hook loads or ProcessStartInfo suites with variable-built paths.
- N-2 (item 5): optional rename of `-Surface` to `-Scope` across 25+ consuming suites.
- F-6 (item 6): whether test-session memo caches should be a named exception in the PowerShell rule (policy file).
- F-1/F-2 (item 10): withheld in #903 because the Discovery guard flagged seven suites in CI run 38404520141; the four files were restored (commit 4e8d9f92d; evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md).
- I-3 (item 11): four test files are at 500 lines and must be split before their next edit.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups 4, 5, 6, 10, 11.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

F-6 needs operator approval because it edits .claude/rules/powershell.md and .github/instructions/.

## Proposed Fix / Validation Ideas

- [ ] Apply F-1/F-2 now that the concurrent epic and #901 have merged, fixing the seven flagged suites.
- [ ] Extend detection for F-3.
- [ ] Split the 500-line files (I-3).
- [ ] Decide N-2 and F-6.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch