# potential-to-issue-missing-label (Issue #123)

- Date captured: 2026-04-05
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-to-issue-missing-label/ (Issue #123)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #123
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/123
- Last Updated: 2026-04-05
- Work Mode: minor-audit

## Summary

`drmCopilotExtension.potentialToIssue` fails during feature promotion when the target repository does not already contain a `feature` GitHub label. The bundled promotion flow exits after `gh issue create` reports `could not add label: 'feature' not found` instead of recovering or producing a successful issue creation path.

## Environment

- OS/version: Windows
- Python version: runtime probe resolved `python`
- Command/flags used: `drmCopilotExtension.potentialToIssue --potential-path <potential.md> --promotion-type feature --work-mode full-feature`
- Data source or fixture: real potential entry under `docs/features/potential/`

## Steps to Reproduce

1. Invoke `drmCopilotExtension.potentialToIssue` in interactive mode or pass direct arguments that resolve to `--promotion-type feature`.
2. Allow the bundled wrapper to execute `resources/templates/potential_to_issue.py` against a repository whose GitHub labels do not already include `feature`.
3. Observe the `gh issue create` failure emitted by the command output channel.

## Expected Behavior

The promotion flow should create the GitHub issue successfully for the selected promotion type even when the repository is missing the corresponding label beforehand.

## Actual Behavior

The command fails with the following output and does not create the issue:

- `Creating issue: Feature: refactor-and-test (label: feature)`
- `could not add label: 'feature' not found`
- `[drmCopilotExtension.potentialToIssue] command failure`

## Acceptance Criteria

- [x] Promoting a potential entry as `feature` succeeds when the repository does not already contain a `feature` label.
- [x] The promotion workflow continues to pass through the selected promotion label when the label already exists.
- [x] Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet:
	- `[drmCopilotExtension.potentialToIssue] interactive mode`
	- `[drmCopilotExtension.potentialToIssue] runtime probe success: python`
	- `[drmCopilotExtension.potentialToIssue] resolved script path: .../resources/templates/potential_to_issue.py`
	- `could not add label: 'feature' not found`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

`RealGhClient.issue_create` always passes `--label <promotion_type>` directly to `gh issue create`, but the promotion workflow does not ensure that the repository contains the selected label before attempting the issue creation.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
- [x] Integration scenario to retest
- [ ] Manual verification notes

- Add a focused regression test around `scripts/dev_tools/potential_to_issue.py` for a missing-label failure followed by recovery.
- Update the gh client flow so promotion can ensure the target label exists before issue creation.
- Retest the original feature-promotion path from the extension command surface.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch