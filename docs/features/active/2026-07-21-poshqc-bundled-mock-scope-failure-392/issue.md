# poshqc-bundled-mock-scope-failure (Issue #392)

- Date captured: 2026-07-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/poshqc-bundled-mock-scope-failure/ (Issue #392)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #392
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/392
- Last Updated: 2026-07-21
- Work Mode: full-bug

## Summary

Running the PoshQC Pester suite directly against `tests/scripts/powershell/PoshQC` passes cleanly, but running the same suite through the bundled entry point (`Invoke-PoshQCSuite` / `mcp__drm-copilot__run_poshqc_suite`, which imports the module before calling `Invoke-PoshQCTest`) produces 31 failures, all with `RuntimeException: Mock data are not setup for this scope, what happened?`.

## Environment

- OS/version: Windows 11
- PowerShell version: 7.x (repo-mandated 7+)
- Command/flags used: `mcp__drm-copilot__run_poshqc_suite` (bundled) vs. direct `Invoke-Pester` against the PoshQC test folder
- Data source or fixture: `tests/scripts/powershell/PoshQC/*.Tests.ps1`

## Steps to Reproduce

1. Run the PoshQC Pester suite directly (e.g. `Invoke-Pester -Path tests/scripts/powershell/PoshQC`, or via direct module import) — all tests pass.
2. Run the bundled suite command (`Invoke-PoshQCSuite` as invoked by `scripts/dev-tools/run-poshqc-suite.ps1` / `mcp__drm-copilot__run_poshqc_suite`), which imports the PoshQC module (`Import-Module ...PoshQC.psd1 -Force`) before calling `Invoke-PoshQCTest`.
3. Observe 31 failing tests, concentrated in `PoshQC.Comprehensive.Tests.ps1` and `PoshQC.ScanFolders.Tests.ps1` (both use `InModuleScope PoshQC { ... }`), each failing with the same `RuntimeException: Mock data are not setup for this scope, what happened?`.

## Expected Behavior

The bundled suite command should produce the same pass/fail results as running Pester directly against the PoshQC test folder.

## Actual Behavior

31 of 1329 tests fail with `RuntimeException: Mock data are not setup for this scope, what happened?` only when invoked through the bundled command. Full failure list captured in the orchestration transcript; representative failures:
- `Get-PoshQCFileList.When given a valid root path.Should resolve the root path and return PowerShell files`
- `Invoke-PoshQCFormat.When formatting files.Should format files that need formatting`
- `Invoke-PoshQCTest.When coverage is enabled.Should resolve coverage paths`
- `bundled wrapper ScanFoldersJson transport.run-poshqc-format decodes ScanFoldersJson into string array input`

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `RuntimeException: Mock data are not setup for this scope, what happened?` repeated across 31 `It` blocks; final summary `Tests Passed: 1298, Failed: 31, Skipped: 9, Inconclusive: 0`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- The repository maintains two PoshQC module trees that must stay in text parity: `scripts/powershell/PoshQC/` (repo-root) and `extensions/drm-copilot/resources/powershell/PoshQC/` (bundled, enforced by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- The bundled entry points (`scripts/dev-tools/run-poshqc-suite.ps1`, `extensions/drm-copilot/resources/templates/run-poshqc-*.ps1`) `Import-Module` the bundled copy (`...PoshQC.psd1`) into the current session, then call `Invoke-PoshQCSuite -> Invoke-PoshQCTest -> Invoke-Pester`, which discovers and runs `tests/scripts/powershell/PoshQC/*.Tests.ps1` in that same session.
- Those test files independently `Import-Module` the repo-root copy (`scripts/powershell/PoshQC/PoshQC.psm1`) by relative path in their own `BeforeAll` blocks. Because both copies load under the same module name `PoshQC`, the session can end up with two distinct `PoshQC` module instances simultaneously loaded when entered via the bundled path (but only one when run directly).
- `PoshQC.Comprehensive.Tests.ps1` and `PoshQC.ScanFolders.Tests.ps1` already contain defensive logic in `BeforeAll` that removes any loaded `PoshQC` module whose `.Path` does not match the resolved repo-root path before re-importing — apparently a prior attempt to guard against this exact class of collision — yet tests in those same files are among the 31 failures, so the existing guard is not sufficient to prevent the `InModuleScope`/`Mock` resolution ambiguity when a same-named module is already loaded from a different file path before the guard runs. Other test files in the suite (e.g. `PoshQC.Tests.ps1`) have no such guard at all.
- `scripts/powershell/PoshQC/PoshQC.psm1` also carries a documented PowerShell 7.6+ behavior note about dot-sourced `.psm1` sub-modules being treated as isolated modules, worked around via `[Parser]::ParseFile(...).GetScriptBlock()`; this may interact with the dual-module-instance scenario and should be investigated as part of root-causing the exact mechanism (needs empirical reproduction, not just static reading).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: a regression test that runs the bundled entry point path (module import order matching production) and asserts zero Mock-scope failures, so this class of regression is caught going forward.
- [ ] Integration scenario to retest: `mcp__drm-copilot__run_poshqc_suite` end-to-end against the full repo test tree.
- [ ] Manual verification notes: confirm `Get-Module -Name PoshQC` shows exactly one loaded instance (repo-root path) at the point each `InModuleScope PoshQC` block executes, under both the direct and bundled invocation paths.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
