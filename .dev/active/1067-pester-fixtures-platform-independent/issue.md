# pester-fixtures-platform-independent (Issue #1067)

- Date captured: 2026-11-03
- Author: drmoisan
- Status: Promoted -> docs/features/active/pester-fixtures-platform-independent/ (Issue #1067)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1067
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1067
- Last Updated: 2026-11-03
- Work Mode: full-bug

## Summary

Seventeen Pester suites under tests/scripts/dev-tools and tests/scripts/powershell/PoshQC use Windows-specific fixtures and fail on Linux (89 failures of 308 tests). The fixtures should be platform independent so the suites pass on both Windows and Linux.

## Environment

- OS/version: Linux Codespace (PowerShell 7.6, Pester 5.9.x). CI runs these suites on windows-latest only.
- Python version: not applicable.
- Command/flags used: Invoke-Pester over tests/scripts/dev-tools and tests/scripts/powershell/PoshQC, single process, coverage disabled.
- Data source or fixture: hardcoded C:\ paths, backslash path expectations, writes to /repo, Windows prompt strings.

## Steps to Reproduce

1. On a Linux host, run Invoke-Pester over tests/scripts/dev-tools and tests/scripts/powershell/PoshQC.
2. Observe 308 tests, 219 passed, 89 failed across 17 suites.
3. Compare with the same run at the merge base of the issue 1026 branch; the distribution is identical.

## Expected Behavior

The suites pass on Linux and Windows without host-specific fixtures, and make no real writes outside mocks.

## Actual Behavior

Representative errors: `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.`; `Expected: 'C:\fixture\ws'`; `UnauthorizedAccessException: Access to the path '/repo' is denied.`; `A parameter cannot be found that matches parameter name 'Raw'.`

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: the issue 1026 evidence note isolation-parallel.2026-11-03T18-55.md lists per-suite counts and messages.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Fixtures were written for a Windows host. Commit df7cb4f31 (2026-03-11) normalized other suites with a portable pattern: Join-Path, [IO.Path]::DirectorySeparatorChar, mocks in place of real file system access, no temp files. A sibling item fixes the $env:PATH leak in run-actionlint.Tests.ps1 and must merge first; edits to that file belong to this item only after main is updated.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: apply the portable fixture pattern to each of the 17 suites; add any helper under the existing test-support location rather than new copies.
- [x] Integration scenario to retest: single-process Invoke-Pester over the 17 suites on Linux shows 0 failures; Windows CI shards pass; evaluate making the suites eligible for the ubuntu-latest PowerShell leg.
- [ ] Manual verification notes

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
