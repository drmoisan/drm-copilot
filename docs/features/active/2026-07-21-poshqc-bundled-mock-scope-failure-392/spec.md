# poshqc-bundled-mock-scope-failure (Spec)

- **Issue:** #392
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-21T17-26
- **Status:** Draft
- **Version:** 0.1

## Context
Running the PoshQC Pester suite directly against `tests/scripts/powershell/PoshQC` passes cleanly, but running the same suite through the bundled entry point (`Invoke-PoshQCSuite` / `mcp__drm-copilot__run_poshqc_suite`, which imports the module before calling `Invoke-PoshQCTest`) produces 31 failures, all with `RuntimeException: Mock data are not setup for this scope, what happened?`.

Environment:
- OS/version: Windows 11
- PowerShell version: 7.x (repo-mandated 7+)
- Command/flags used: `mcp__drm-copilot__run_poshqc_suite` (bundled) vs. direct `Invoke-Pester` against the PoshQC test folder
- Data source or fixture: `tests/scripts/powershell/PoshQC/*.Tests.ps1`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run the PoshQC Pester suite directly (e.g. `Invoke-Pester -Path tests/scripts/powershell/PoshQC`, or via direct module import) — all tests pass.
2. Run the bundled suite command (`Invoke-PoshQCSuite` as invoked by `scripts/dev-tools/run-poshqc-suite.ps1` / `mcp__drm-copilot__run_poshqc_suite`), which imports the PoshQC module (`Import-Module ...PoshQC.psd1 -Force`) before calling `Invoke-PoshQCTest`.
3. Observe 31 failing tests, concentrated in `PoshQC.Comprehensive.Tests.ps1` and `PoshQC.ScanFolders.Tests.ps1` (both use `InModuleScope PoshQC { ... }`), each failing with the same `RuntimeException: Mock data are not setup for this scope, what happened?`.

Expected:
The bundled suite command should produce the same pass/fail results as running Pester directly against the PoshQC test folder.

Actual:
31 of 1329 tests fail with `RuntimeException: Mock data are not setup for this scope, what happened?` only when invoked through the bundled command. Full failure list captured in the orchestration transcript; representative failures:
- `Get-PoshQCFileList.When given a valid root path.Should resolve the root path and return PowerShell files`
- `Invoke-PoshQCFormat.When formatting files.Should format files that need formatting`
- `Invoke-PoshQCTest.When coverage is enabled.Should resolve coverage paths`
- `bundled wrapper ScanFoldersJson transport.run-poshqc-format decodes ScanFoldersJson into string array input`

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `RuntimeException: Mock data are not setup for this scope, what happened?` repeated across 31 `It` blocks; final summary `Tests Passed: 1298, Failed: 31, Skipped: 9, Inconclusive: 0`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- The repository maintains two PoshQC module trees that must stay in text parity: `scripts/powershell/PoshQC/` (repo-root) and `extensions/drm-copilot/resources/powershell/PoshQC/` (bundled, enforced by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- The bundled entry points (`scripts/dev-tools/run-poshqc-suite.ps1`, `extensions/drm-copilot/resources/templates/run-poshqc-*.ps1`) `Import-Module` the bundled copy (`...PoshQC.psd1`) into the current session, then call `Invoke-PoshQCSuite -> Invoke-PoshQCTest -> Invoke-Pester`, which discovers and runs `tests/scripts/powershell/PoshQC/*.Tests.ps1` in that same session.
- Those test files independently `Import-Module` the repo-root copy (`scripts/powershell/PoshQC/PoshQC.psm1`) by relative path in their own `BeforeAll` blocks. Because both copies load under the same module name `PoshQC`, the session can end up with two distinct `PoshQC` module instances simultaneously loaded when entered via the bundled path (but only one when run directly).
- `PoshQC.Comprehensive.Tests.ps1` and `PoshQC.ScanFolders.Tests.ps1` already contain defensive logic in `BeforeAll` that removes any loaded `PoshQC` module whose `.Path` does not match the resolved repo-root path before re-importing — apparently a prior attempt to guard against this exact class of collision — yet tests in those same files are among the 31 failures, so the existing guard is not sufficient to prevent the `InModuleScope`/`Mock` resolution ambiguity when a same-named module is already loaded from a different file path before the guard runs. Other test files in the suite (e.g. `PoshQC.Tests.ps1`) have no such guard at all.
- `scripts/powershell/PoshQC/PoshQC.psm1` also carries a documented PowerShell 7.6+ behavior note about dot-sourced `.psm1` sub-modules being treated as isolated modules, worked around via `[Parser]::ParseFile(...).GetScriptBlock()`; this may interact with the dual-module-instance scenario and should be investigated as part of root-causing the exact mechanism (needs empirical reproduction, not just static reading).

### Confirmed root cause (empirical, experiments E1–E4)

- **E1a (global-hosted run with the colliding bundled module pre-imported):** Passed=95, Failed=0, Skipped=7 (exit 0). Pre-import collision alone does NOT reproduce the defect under global hosting. Evidence: `evidence/baseline/e1a-global-hosted-preimport.2026-07-21T18-01.md`.
- **E1b (module-hosted bundled path, narrowed to the PoshQC folder):** tests=102, failures=31, skipped=7 (exit 31); all failures `Mock data are not setup for this scope`. Module-session-state hosting is the necessary and sufficient condition. Evidence: `evidence/baseline/e1b-module-hosted-narrowed.2026-07-21T18-01.md`.
- **E1 contingency verdict:** `CONTINGENCY: NOT-REQUIRED` (E1a passed); the top-level PoshQC import clear was not added. Evidence: `evidence/baseline/e1-decision.2026-07-21T18-01.md`.
- **E2 (throw site):** `Mock` at `Pester.psm1:14896` (mock-setup path), reached via `Get-MockDataForCurrentScope` at line 15230 — not the `Invoke-Mock` invocation path (15868). Evidence: `evidence/baseline/e2-throw-site.2026-07-21T18-01.md`.
- **E3 (module topology at failure time):** exactly one `PoshQC` instance (repo-root path) is loaded at container run time in both bundled and direct modes; the BeforeAll guard de-duplicates. The defect is NOT an `InModuleScope` multi-instance ambiguity. Evidence: `evidence/baseline/e3-module-topology.2026-07-21T18-01.md`.
- **E4 (baseline/repro pair):** direct run green; the bundled-manifest import path (MCP `run_poshqc_test`/`run_poshqc_suite`, E1b) reproduces 31 failures. Note: `scripts/dev-tools/run-poshqc-suite.ps1` imports the repo-root module (same path as the test-file guards), so no collision occurs and it did not reproduce the defect at baseline; the production reproduction is the bundled-manifest import. Evidence: `evidence/regression-testing/fail-before.e4-bundled.2026-07-21T18-01.md`.

Conclusion: the single architectural difference between the passing and failing invocations is that the bundled entry path hosts `Invoke-Pester` (and thus every discovered test container) in the imported PoshQC module's session state. The fix hosts the run in the global session state at the `Invoke-PoshQCTest` seam, matching the passing direct run.


## Proposed Fix

### Design summary (what changes where):
Host the Pester run in the global session state at the `Invoke-PoshQCTest` seam layer (`PoshQC.Testing.psm1`), so bundled-entry runs execute discovered test containers in the global session state exactly as the passing direct run does. Two default seams change:
- `$EnsureModule` default: `Import-Module $Name -Global -ErrorAction Stop` (was without `-Global`), so Pester's `Describe`/`It`/`Mock` resolve in globally-hosted containers.
- `$InvokePester` default: a global-scope trampoline. It builds an unbound scriptblock via `[scriptblock]::Create('param($c) Invoke-Pester -Configuration $c')`, installs it as `function:global:Invoke-PoshQCPesterRun`, invokes it inside `try`, and removes it in `finally` via `Remove-Item -Path 'Function:\Invoke-PoshQCPesterRun'` (the `Function:\` provider path; a `function:global:`-qualified path is honored by `New-Item` but silently no-ops on `Remove-Item`, which would leak the trampoline). The Pester result object is returned unmodified so `PassThru` survives.

### Boundaries and invariants to preserve:
- Injected-seam callers are unaffected: no seam parameter name, position, or signature changes; all existing unit tests that inject `$EnsureModule`/`$InvokePester` bypass the changed defaults.
- `Invoke-PoshQCTest` still throws on missing Pester, missing settings, and unresolved explicit scan folders.
- `Invoke-PoshQCSuite` still runs format -> analyze -> test; the global trampoline exists only for the duration of the Pester call (try/finally removal), so no global state leaks between suite invocations in a persistent host (verified: P4-T2 trailing `Test-Path` = False).
- Coverage and JUnit artifact outputs under `artifacts/pester/` are unchanged in shape.

### Dependencies or blocked work:
None. Fully local PowerShell/Pester work; no external service or human interaction.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and its byte-identical bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` (seam defaults).
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror (add `PoshQC.Testing.psm1` to `CodeCoverage.Path` for changed-line coverage evidence).
- `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` (new seam-default unit tests).
- `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (inject `-InvokePester` stub into the 3 Koverage-copy `It` blocks so their module-scope `Mock Invoke-Pester` intercepts as before, bypassing the trampoline in those unit tests only).

#### Functions/classes/CLI commands impacted:
- `Invoke-PoshQCTest` default seams `$EnsureModule` and `$InvokePester`. `Invoke-PoshQCSuite`, `mcp__drm-copilot__run_poshqc_suite`/`run_poshqc_test` benefit transitively.

#### Data flow and validation changes:
None. The Pester configuration build, scan-folder resolution, coverage handling, and result summary are unchanged.

#### Error handling and logging updates:
None. Throw-on-missing behavior for Pester/settings/scan folders is preserved.

#### Rollback/feature-flag considerations (if applicable):
Revert the two seam defaults (and their mirrors) to roll back; no data migration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
`Invoke-PoshQCTest` signature is unchanged. `$InvokePester` still returns the `Invoke-Pester` PassThru result object unmodified.

#### Required configuration keys and defaults:
No new configuration keys. `pester.runsettings.psd1` gains one `CodeCoverage.Path` entry (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`); `CoveragePercentTarget = 0` is unchanged.

#### Backward-compatibility expectations:
Fully backward compatible: seam parameter names/positions/signatures unchanged; injected-seam callers unaffected. Consumer repos that import only the bundled module continue to work (the contingency top-level import clear was not required; E1a passed).

#### Performance constraints (latency/throughput/memory):
Negligible. The fix adds one global function create/remove per Pester invocation; no measurable latency change (full bundled suite completed in ~45s, consistent with baseline).

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Constraints (budget, performance, compatibility):
- External dependencies (services, libraries, releases):

## Data / API / Config Impact
- User-facing or API changes:
- Data or migration considerations:
- Logging/telemetry updates (if any):
- Compatibility notes (CLI flags, config schemas, versioning):

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: a regression test that runs the bundled entry point path (module import order matching production) and asserts zero Mock-scope failures, so this class of regression is caught going forward.
- [ ] Integration scenario to retest: `mcp__drm-copilot__run_poshqc_suite` end-to-end against the full repo test tree.
- [ ] Manual verification notes: confirm `Get-Module -Name PoshQC` shows exactly one loaded instance (repo-root path) at the point each `InModuleScope PoshQC` block executes, under both the direct and bundled invocation paths.

- Regression tests to add or update:
- Unit tests (pytest) for the fixed behavior and boundaries:
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):


## Acceptance Criteria
- [x] Repro steps now produce the expected behavior in all documented environments. (Evidence: `evidence/regression-testing/pass-after.direct.2026-07-21T18-01.md`, `pass-after.bundled-narrowed.2026-07-21T18-01.md`, `pass-after.bundled-full.2026-07-21T18-01.md` — 0 failed in direct, bundled-narrowed, and full bundled runs.)
- [x] Regression test(s) added and passing (list file path and test name). (Evidence: `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` — `Invoke-PoshQCTest default $InvokePester seam ... defines/removes function:global:Invoke-PoshQCPesterRun ... returns the result unmodified`; `... default $EnsureModule seam ... imports the requested module with -Global`; `... throws the supplied error when the module is unavailable`. Verified in `evidence/regression-testing/pass-after.direct.2026-07-21T18-01.md`.)
- [x] Edge cases and invalid inputs are handled with correct errors or fallbacks. (Evidence: the `$EnsureModule` throw-when-unavailable test in `PoshQC.TestingSeamDefaults.Tests.ps1`; missing-Pester/missing-settings throw behavior preserved — `evidence/regression-testing/p3-t4-seam-injection.2026-07-21T18-01.md` and P3-T2.)
- [x] No unintended behavior changes outside the defined scope. (Evidence: `evidence/other/change-set-audit.2026-07-21T18-01.md`; injected-seam callers unaffected; P3-T4 shows the 3 Koverage tests keep every assertion.)
- [x] Required logs/telemetry updated and validated (if applicable). (N/A — no logging/telemetry surface changed; the `$Logger` seam and summary output are unchanged.)
- [x] Performance constraints met or explicitly waived with rationale. (Waived: the fix adds one global function create/remove per Pester invocation; full bundled suite completed in ~45s, consistent with baseline — `evidence/regression-testing/pass-after.bundled-full.2026-07-21T18-01.md`.)
- [x] Full toolchain pass completed (format → lint → type-check → test). (Evidence: `evidence/qa-gates/final-format.2026-07-21T18-01.md` (exit 0, no changes), `final-analyze.2026-07-21T18-01.md` (0 findings; type-check N/A for PowerShell), `final-test-coverage.2026-07-21T18-01.md` (worktree run 0 failed, coverage recorded). The MCP `run_poshqc_test` shows the pre-fix failures because it loads a stale bundled snapshot of the module from the main-repo install; this resolves once the extension is repackaged from merged main.)
- [x] Docs/config references updated to match the new behavior. (Evidence: this `spec.md` Proposed Fix / Root Cause Analysis; `pester.runsettings.psd1` coverage-path comment citing issue #392.)

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs
