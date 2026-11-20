# release-poll-budgets-unpinned-and-isolation-evidence-proxy-level (Issue #575)

- Date captured: 2026-08-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/release-poll-budgets-unpinned-and-isolation-evidence-proxy-level/ (Issue #575)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #575
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/575
- Last Updated: 2026-08-28
- Work Mode: full-bug

## Summary

Two follow-ups deferred from issue #526 (fixed by PR #564). First, no test pins the three per-check polling budgets at the call site, so a caller passing wrong explicit interval/attempts arguments would reproduce the original defect (a budget expiring early, tripping the pre-push check after the tag is pushed, and burning a version number on a false negative) while the suite stays green. Second, acceptance criterion AC21's network-isolation evidence is proxy-level: during #526's verification a raw socket still reached the registry from inside the "isolated" session, so the recorded isolation evidence proves less than the criterion states.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository toolchain (release scripts)
- Command/flags used: release verification flow shipped by PR #564
- Data source or fixture: #526 execution and reaudit artifacts under the feature folder; reaudit follow-up recorded as `m8`

## Steps to Reproduce

1. For the budget gap: change the call site to pass an explicit wrong budget (for example the 3-minute pair where the spec requires 20 minutes) for check (b); run the full test suite; observe it passes.
2. For AC21: rerun the isolation probe the #526 reaudit wrote (a raw socket to the registry from inside the isolated session); observe it connects despite the recorded isolation evidence.

## Expected Behavior

1. A call-site test pins each of the three checks to its specified interval/attempts pair, failing when any budget deviates from the spec.
2. AC21's evidence demonstrates actual network isolation (the probe cannot reach the registry), or the criterion's wording is corrected to state the weaker property that is actually verified.

## Actual Behavior

1. The three budgets are correct in the shipped code but are pinned by no test; the reaudit wrote a working probe for the budget check but did not land it as a test (follow-up `m8`).
2. AC21 is checked off but was graded PARTIAL during #526's review: the isolation evidence is a proxy (exit-code level), and a raw socket connection from inside the session succeeded.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: recorded in #526's reaudit artifacts (follow-up m8; AC21 graded PARTIAL) and disclosed in PR #564's review notes.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Neither gap is a live defect today; both are regression exposure. The budget gap recreates a version-number-burning failure mode if the call site regresses; the AC21 gap records stronger evidence than exists.

## Suspected Cause / Notes

Deferred deliberately at #526's merge (2026-08-26) so the fix could land while CI was healthy; recorded in the parallel-run receipts as agreed follow-ups. The probe code for item 1 already exists in the reaudit artifacts and needs landing as a test.

## Proposed Fix / Validation Ideas

- [ ] Land the reaudit's budget probe as a call-site test pinning all three interval/attempts pairs.
- [ ] Replace AC21's proxy evidence with a real isolation assertion (probe must fail to connect), or amend the criterion text.
- [ ] Zero-regression toolchain pass on the release-script test suite.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
