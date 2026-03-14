# potential-to-issue-auto-resolve-prompts (Issue #98)

- Date captured: 2026-03-14
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-to-issue-auto-resolve-prompts/ (Issue #98)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #98
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/98
- Last Updated: 2026-03-14
- Work Mode: minor-audit

## Summary

In a destination workspace, running `drm-copilot: Potential To Issue` opens a file picker instead of auto-resolving the currently active potential markdown file. The flow also fails to present the follow-up promotion-type and work-mode prompts that are needed to complete the promotion.

## Environment

- OS/version: Windows (user report)
- Python version: Bundled extension command path; runtime discovered by extension at execution time
- Command/flags used: `drm-copilot: Potential To Issue` from the command palette in a destination workspace
- Data source or fixture: Active potential markdown file under `docs/features/potential/` in the destination workspace

## Steps to Reproduce

1. Open a destination workspace that has the pushed-down `drm-copilot` customizations and a potential markdown file under `docs/features/potential/`.
2. Make that potential markdown file the active editor file.
3. Run `drm-copilot: Potential To Issue` from the command palette.

## Expected Behavior

The command should auto-resolve the active potential markdown file path, then prompt for the promotion type and the work mode (`minor-audit` vs full path variants), and finally execute the bundled promotion script with those explicit arguments.

## Actual Behavior

The command opens a file picker instead of reusing the active potential file. After that, the expected promotion-type and work-mode prompts are not surfaced in the user workflow, so the bundled promotion flow cannot be completed as intended.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: User report only; no additional logs captured yet.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The live handler in `extensions/drm-copilot/src/extension.ts` currently calls `showOpenDialog()` unconditionally for `drmCopilotExtension.potentialToIssue`, so it has no active-editor auto-resolve path. The focused Jest coverage in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` also only verifies the file-picker flow today.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas — add Jest coverage for active-editor auto-resolve, fallback behavior, and retention of the promotion/work-mode quick picks.
- [x] Integration scenario to retest — run the extension command in a destination workspace with an active `docs/features/potential/*.md` file and verify the bundled script argv.
- [x] Manual verification notes — confirm the command still falls back cleanly when there is no valid active potential file.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch