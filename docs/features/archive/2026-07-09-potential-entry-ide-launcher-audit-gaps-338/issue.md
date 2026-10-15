# potential-entry-ide-launcher-audit-gaps (Issue #338)

- Date captured: 2026-07-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-entry-ide-launcher-audit-gaps/ (Issue #338)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #338
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/338
- Last Updated: 2026-07-09
- Work Mode: minor-audit

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

The feature merged without the two Major findings being closed out, and no closure evidence or documented exception exists for either. The Minor docstring literal remains in both `_resolve_code_cli()` docstrings, in `new_potential_bug_entry.py` and `new_active_feature_folder_io.py`.

Correction (#846): no bundled mirror copies of the two Python modules exist (code-review.2026-10-08T07-05.md CR-3).

## Acceptance Criteria

- [x] The stray docstring literal is removed from `_resolve_code_cli()` with no behavior change: a search for the token `as_posix() for file_path in files` in `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py` returns no matches, and `poetry run ruff check` on those two files passes. The TypeScript launcher sources and both `new-potential-entry.ps1` copies are unchanged.
- [x] New Python tests pass and drive the previously untested launcher branches (backslash-to-forward-slash argv conversion, symmetric CLI fallback with a successful second probe, and each Insiders signal variable in `_INSIDERS_SIGNAL_NAMES`) for both modules: `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py` exits 0, and no test file exceeds 500 lines.
- [x] New TypeScript tests pass and drive the previously untested launcher branches (backslash conversion, symmetric CLI fallback, each Insiders signal variable, and the default lookup helpers) in `extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts`, `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts`, and `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` (the default lookup helper tests are in `io-launcher.test.ts`): `npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts test/lib/new-active-feature-folder/io-launcher.test.ts` run from `extensions/drm-copilot` exits 0. (AC text corrected under #846; the original text named only io.test.ts; verifying run: `evidence/regression-testing/ac3-jest-new-tests.2026-10-08T02-45.md`.)
- [x] Finding (B) is closed by isolated launcher coverage evidence stored under `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/qa-gates/` (each file recording Timestamp, Command, and EXIT_CODE) showing `scripts/dev_tools/new_potential_bug_entry.py`, `scripts/dev_tools/new_active_feature_folder_io.py`, `extensions/drm-copilot/src/lib/new-potential-bug-entry.ts`, and `extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts` each at line coverage >= 85% and branch coverage >= 75%. The 90% new-code figure is reported for information only.
- [x] Finding (C) (AC-1/AC-2 live-Windows verification) is resolved by `scope_change`: a timestamped closure record `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/evidence/other/ac1-ac2-scope-change-closure.<timestamp>.md` exists, names by file and test name the Python and TypeScript argv/CLI-selection contract tests asserting `--reuse-window`, file arguments, and Insiders-first CLI selection, and states the residual unobserved desktop-UI risk.

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

- [ ] Unit coverage areas: isolate changed/new-code coverage for the four launcher files (`new_potential_bug_entry.py`, `new_active_feature_folder_io.py`, `new-potential-bug-entry.ts`, `io-launcher.ts`) to close the 90% new-code coverage policy gap, or document an approved exception if isolation is not feasible.
- [ ] Integration scenario to retest: manually verify the same-window-reuse behavior on Windows with VS Code / VS Code Insiders and record the observed behavior as a timestamped evidence artifact, closing AC-1 and AC-2.
- [ ] Manual verification notes: remove the stray literal command fragment from both `_resolve_code_cli()` docstrings.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
