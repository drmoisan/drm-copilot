# run-actionlint-test-path-env-leak (Issue #1066)

- Date captured: 2026-11-03
- Author: drmoisan
- Status: Promoted -> docs/features/active/run-actionlint-test-path-env-leak/ (Issue #1066)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1066
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1066
- Last Updated: 2026-11-03
## Summary

The Pester test "Add-DirectoryToPath handles paths with trailing separator" in tests/scripts/dev-tools/run-actionlint.Tests.ps1 sets `$env:PATH` and never restores it. In a single-process Pester run, later suites inherit the altered PATH and fail. This is a test-order dependence, which repository policy treats as a violation.

## Environment

- OS/version: Linux Codespace (PowerShell 7.6, Pester 5.9.x); CI runs the suite on windows-latest, where each shard is a separate process and the leak is not visible.
- Python version: not applicable.
- Command/flags used: Invoke-Pester over tests/scripts/dev-tools in a single process.
- Data source or fixture: none; the test assigns `$env:PATH = '/existing'` directly (about line 495).

## Steps to Reproduce

1. Run Invoke-Pester single-process over tests/scripts/dev-tools including run-actionlint.Tests.ps1.
2. Observe that eight later suites fail.
3. Run the same suites without run-actionlint.Tests.ps1, or with the leaking test excluded; the failures disappear.

## Expected Behavior

Every test restores process-global state (environment variables) it changes, so suites pass in any order and in a single process.

## Actual Behavior

After the test at about line 495 runs, `$env:PATH` remains '/existing' (plus the added directory), and eight later suites fail because commands cannot be resolved.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: reported by the issue 1026 run; see its isolation-parallel evidence note (89 host failures plus this leak affecting 8 later suites).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The Add-DirectoryToPath Describe (about lines 225-303) saves and restores PATH in BeforeEach and AfterEach. The later block that contains the trailing-separator test has no such restore. The test file dates from 2026-02-21 (e467a0e8b) and was last changed in df7cb4f31 (2026-03-11). Other tests in the same file may also change process-global state without restoring it. A sibling item (Pester fixtures platform independence) fixes the 89 Linux host failures in 17 other suites and must not be mixed into this item.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: restore PATH (and any other changed process state) in every block of run-actionlint.Tests.ps1; add a regression guard that fails if a suite leaves PATH or other process environment changed.
- [x] Integration scenario to retest: single-process Invoke-Pester over tests/scripts/dev-tools in forward and reversed order; the eight victim suites must pass.
- [ ] Manual verification notes

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
