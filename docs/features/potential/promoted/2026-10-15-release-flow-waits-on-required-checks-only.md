# release-flow-waits-on-required-checks-only (Issue #931)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/release-flow-waits-on-required-checks-only/ (Issue #931)
- Work Mode: minor-audit

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #931
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/931
- Last Updated: 2026-10-15
## Summary

scripts/dev-tools/Invoke-FullReleaseFlow.ps1 still waits only on required checks. #899 (PR #923) changed the CI-green gate to require all checks, but the release flow was out of its scope.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Inspect scripts/dev-tools/Invoke-FullReleaseFlow.ps1 line 220: ``$ghArgs = @('pr', 'checks', $PrNumber, '--required', '--json', 'bucket')`` (documented at line 167).

## Expected Behavior

The release flow treats a PR as green only when every check on its head has passed, matching the #899 rule.

## Actual Behavior

A release PR with a failing non-required check (for example the NPM Audit Gate or Publish to Marketplace) is treated as green.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: Invoke-FullReleaseFlow.ps1:167 and :220 use --required.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Recorded as an end-of-run follow-up by the bug-burndown-2026-10-11 planner (#899).

## Proposed Fix / Validation Ideas

- [ ] Drop --required and require at least one check and no non-success bucket.
- [ ] Update the doc comment and the Pester tests.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch