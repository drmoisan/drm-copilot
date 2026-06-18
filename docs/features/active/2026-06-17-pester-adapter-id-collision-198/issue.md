# pester-adapter-id-collision (Issue #198)

- Date captured: 2026-06-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-06-17-pester-adapter-id-collision-198/ (Issue #198)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #198
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/198
- Last Updated: 2026-06-17
- Work Mode: full-bug

## Summary

The VS Code Test Explorer drops or misreports Pester tests whose sibling names differ only by letter case, because the `pspester.pester-test` adapter folds discovered test IDs to uppercase and treats the collisions as duplicates.

## Environment

- OS/version: Windows, VS Code with `pspester.pester-test` 2023.7.8
- Python version: n/a (PowerShell/Pester)
- Command/flags used: Test Explorer "Run Tests" (adapter runs `PesterInterface.ps1`)
- Data source or fixture: `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`

## Steps to Reproduce

1. Define sibling tests whose names differ only by letter case (confirmation tokens `"YES"` and `"Yes"`).
2. Run the file's tests in the VS Code Test Explorer.
3. One case-variant item is dropped or reported failed/ghost.

## Expected Behavior

Every discovered test has a distinct adapter ID and is reported with its true result.

## Actual Behavior

The adapter emits `Duplicate test item ... detected. ... The duplicate will be ignored.` because both case variants fold to the uppercased ID `...CONFIRMTOKEN=YES`.

## Logs / Screenshots

- [x] Captured minimal logs
- Snippet: adapter discovery emits two `type:"Test"` records with the identical uppercased `id` ending `...IS REJECTED WITH CODE 2>>CONFIRMTOKEN=YES`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The adapter constructs test IDs from uppercased Describe/Context/It names. Case-only differences between siblings (or `-ForEach` expansions) collide. `Invoke-Pester` does not fold case, so the engine reports green and hides the defect.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: disambiguate the colliding case-sensitivity cases; add a regression guard for case-insensitive sibling-name uniqueness.
- [x] Integration scenario to retest: adapter discovery across all `tests/**/*.Tests.ps1` yields zero colliding IDs.
- [x] Manual verification notes: reload VS Code; confirm all `Invoke-FullRelease` items report.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
