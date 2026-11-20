# potential-entry-ide-launcher-audit-gaps (Issue #338)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-entry-ide-launcher-audit-gaps/ (Issue #338)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #338
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/338
- Last Updated: 2026-07-09
## Summary

Issue #116 (`potential-entry-opening-different-ide`) shipped via merged PRs #119 and #137, but the feature's own 2026-04-04 code review recorded a "No-Go / Needs revision" verdict with two Major findings and one Minor finding that were never subsequently closed out with evidence, even though the code was merged anyway.

## Environment

- OS/version: Windows (the unverified behavior is specifically the same-window-reuse launch behavior on Windows/VS Code Insiders)
- Python version: N/A
- Command/flags used: `new_potential_bug_entry` / `new_active_feature_folder` launcher commands that invoke `_resolve_code_cli()`
- Data source or fixture: `docs/features/completed/2026-04-04-potential-entry-opening-different-ide-116/code-review.2026-04-04T12-40.md`

## Steps to Reproduce

1. Read `docs/features/completed/2026-04-04-potential-entry-opening-different-ide-116/code-review.2026-04-04T12-40.md`.
2. Note the "No-Go / Needs revision" PR-readiness recommendation and the two Major findings (AC-1/AC-2 live-Windows verification unresolved; changed/new-code coverage not isolated) plus one Minor finding (stray literal in a docstring).
3. Confirm the feature nonetheless shipped via merged PR #119 (2026-04-05) and follow-up PR #137 (2026-04-12), neither of which recorded closure evidence for the two Major findings.
4. Confirm the Minor docstring finding is still present today in `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py` (`_resolve_code_cli()` docstrings still contain the stray literal command fragment).

## Expected Behavior

Either the live-Windows same-window-reuse behavior (AC-1/AC-2) and the changed/new-code coverage isolation should have closure evidence recorded before or shortly after merge, or an explicit, documented policy exception should exist. The stray docstring literal should be removed.

## Actual Behavior

The feature merged without the two Major findings being closed out, and no closure evidence or documented exception exists for either. The Minor docstring literal remains in both the root and bundled copies of `_resolve_code_cli()`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: N/A — confirmed via direct review of the code-review artifact and current source files.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Surfaced during the 2026-07-09 repository housekeeping audit (`docs/research/2026-07-09-active-features-delivery-status-audit.md`) while reconciling issue #116's GitHub state (issue remained OPEN despite both PRs being merged, and neither PR body used a closing keyword). This entry tracks the audit-trail closure gap separately from the issue-closure action itself.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: isolate changed/new-code coverage for the four launcher files (`new_potential_bug_entry.py`, `new_active_feature_folder_io.py`, and their bundled mirrors) to close the 90% new-code coverage policy gap, or document an approved exception if isolation is not feasible.
- [ ] Integration scenario to retest: manually verify the same-window-reuse behavior on Windows with VS Code / VS Code Insiders and record the observed behavior as a timestamped evidence artifact, closing AC-1 and AC-2.
- [ ] Manual verification notes: remove the stray literal command fragment from both `_resolve_code_cli()` docstrings (root and bundled copies).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
