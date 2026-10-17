# host-bootstrap-does-not-install-poetry (Issue #930)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/host-bootstrap-does-not-install-poetry/ (Issue #930)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #930
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/930
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

Host bootstrap does not install poetry on a machine that lacks it. Recorded as out-of-scope item OD-3 by #887 (PR #919).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Run the host bootstrap on a machine without poetry.
2. `scripts/host-tools.manifest.json` has no poetry winget entry, and `Install-PoetryWithPip` is reachable only from the winget failure path.

## Expected Behavior

Bootstrap installs poetry when it is missing.

## Actual Behavior

Poetry is not installed; later bootstrap steps that run poetry fail.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #887 issue.md line 70: "no poetry winget entry is listed because no package ID was verified, and Install-PoetryWithPip is reachable only from the winget failure path, so bootstrap does not install poetry on a host that lacks it."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

See docs/features/active/*host-tools-manifest-and-bootstrap-behavior-887/issue.md (OD-3).

## Proposed Fix / Validation Ideas

- [ ] Verify a poetry winget package ID and add it to the manifest, or call `Install-PoetryWithPip` directly when poetry is absent.
- [ ] Add a test for the missing-poetry path.

## Acceptance Criteria

Adopted approach: `Invoke-BootstrapHost` in `scripts/dev-tools/HostBootstrap.psm1` calls `Install-PoetryWithPip -ApplyMode:$Apply` after the session PATH refresh and before the Graphite CLI step. `scripts/host-tools.manifest.json` is unchanged. Bootstrap-level criteria are verified through the mocked `Install-PoetryWithPip` seam in `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`.

- [x] AC-1: In apply mode, `Install-PoetryWithPip` is invoked exactly once by `Invoke-BootstrapHost` with `ApplyMode` set, verified by a Pester test in `HostBootstrap.Invoke.Tests.ps1` using `Should -Invoke -CommandName Install-PoetryWithPip -ModuleName HostBootstrap -Times 1 -Exactly -ParameterFilter { $ApplyMode }`.
- [x] AC-2: In dry-run mode (no `-Apply`), `Install-PoetryWithPip` is invoked exactly once by `Invoke-BootstrapHost` without `ApplyMode`, verified by a Pester test using `-ParameterFilter { -not $ApplyMode }`. The existing `Describe 'Install-PoetryWithPip'` dry-run test in `HostBootstrap.Tests.ps1` already covers the `- Would install poetry using python -m pip install --user poetry` message and the absence of side effects, and requires no restatement or change.
- [x] AC-3: The `Install-PoetryWithPip` call occurs after the Process-scope Path refresh (`Set-HostEnvironmentVariable ... -Target Process`) and before `Invoke-HostBootstrapPoetry`, verified by a Pester ordering test that records the sequence of these mocked calls in a script-scoped list and asserts the relative order. Source inspection also confirms the call is placed before the Graphite CLI step.
- [x] AC-4: When `Install-PoetryWithPip` throws in apply mode, `Invoke-BootstrapHost -Apply` throws a terminating error and `Invoke-HostBootstrapPoetry` is not invoked, verified by a Pester test that mocks `Install-PoetryWithPip` to throw.
- [x] AC-5: `-SkipProjectPoetryInstall` does not suppress the poetry tool install: with the switch set in apply mode, `Install-PoetryWithPip` is still invoked once and `Invoke-HostBootstrapPoetry` is not invoked, verified by a Pester test.
- [x] AC-6: `scripts/host-tools.manifest.json` is unchanged (`git diff` against `main` for that path is empty), and the winget-failure pip fallback in `Install-WithWinget` is retained, verified by the existing `AC06-POETRY-PIP-FALLBACK` and `AC06-NONPOETRY-RETHROW` tests in `HostBootstrap.Tests.ps1` continuing to pass. The already-installed `[OK] poetry already installed` behaviour is covered by the existing `Describe 'Install-PoetryWithPip'` tests, which are unchanged.
- [x] AC-7: The existing `Describe 'Invoke-BootstrapHost'` BeforeEach in `HostBootstrap.Invoke.Tests.ps1` mocks `Install-PoetryWithPip` (`Mock -CommandName Install-PoetryWithPip -ModuleName HostBootstrap`), and all pre-existing Invoke tests, including `AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS` and `AC07-DRYRUN-COMMITTED-MANIFEST`, pass without other modification.
- [x] AC-8: Expect-fail evidence: the new tests for AC-1 through AC-5 fail when run against the unmodified `HostBootstrap.psm1` and pass after the fix. Both PoshQC MCP test results are recorded under the feature `evidence/` folder (baseline before the change, QA gate after).
- [x] AC-9: `scripts/dev-tools/HostBootstrap.psm1` and every touched or added test file are at or under 500 lines, verified by a line count. If `HostBootstrap.Invoke.Tests.ps1` would exceed 500 lines, the new tests are placed in `tests/scripts/dev-tools/HostBootstrap.Poetry.Tests.ps1`.
- [x] AC-10: Local verification using the PoshQC MCP tools (format, analyze, test) on the changed module and test files reports zero formatting changes, zero analyzer findings, and zero test failures.
- [x] AC-11: The `poshqc / PowerShell QC` CI job (windows-latest) passes on the PR head with line coverage at or above the repository threshold (CI-dependent).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch