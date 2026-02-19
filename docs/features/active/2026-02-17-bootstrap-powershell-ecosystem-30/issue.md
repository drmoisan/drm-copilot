# bootstrap-powershell-ecosystem (Issue #30)

- Date captured: 2026-02-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-powershell-ecosystem/ (Issue #30)

- Issue: #30
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/30
- Last Updated: 2026-02-19

## Problem / Why

New workspaces do not consistently include a repeatable PowerShell quality toolchain for formatting, linting, testing, and coverage. That inconsistency causes local/CI drift, uneven script quality, and friction when contributors try to run the same checks. We need a deterministic bootstrap that establishes a PoshQC-compatible PowerShell ecosystem with explicit prerequisites and expected artifacts.

## Proposed Behavior

Provide a bootstrap flow that initializes PowerShell quality tooling from requirements (not ad-hoc manual setup).

Required output behavior:
- Ensure PowerShell runtime compatibility for the workspace (targeting 7.5+ for full parity with current tooling expectations).
- Scaffold the PoshQC module bundle layout required for operation (`PoshQC.psm1`, `PoshQC.psd1`, and `settings/` files).
- Install or validate required quality modules in CurrentUser scope via bootstrap helper flow:
	- PSScriptAnalyzer (pinned major/minor compatibility with current baseline),
	- Pester (pinned major/minor compatibility with current baseline).
- Configure analyzer and test settings files so formatting, linting, and test/coverage behavior are deterministic for the target repo paths.
- Provide bootstrap commands for the standard quality sequence:
	- format (`Invoke-PoshQCFormat -Root .`),
	- analyze (`Invoke-PoshQCAnalyze -Root .`),
	- test (`Invoke-PoshQCTest -Root .`).
- Ensure coverage artifacts include:
	- JUnit XML output,
	- CoverageGutters-compatible XML,
	- optional relative-path `*.koverage.xml` output (with toggle/override support).
- Validate presence of required files, module imports, and command availability; emit actionable diagnostics when missing.

## Acceptance Criteria (early draft)

- [ ] Bootstrap creates or validates the required PoshQC module structure and settings files in the target workspace.
- [ ] Bootstrap verifies PowerShell runtime compatibility and reports a clear block when the minimum supported runtime is missing.
- [ ] Bootstrap installs or validates required modules (PSScriptAnalyzer and Pester) using the documented helper workflow.
- [ ] Running format/analyze/test commands after bootstrap succeeds in a correctly provisioned workspace.
- [ ] Test execution emits JUnit XML and coverage outputs in expected artifact locations, including optional `.koverage.xml` output.
- [ ] Bootstrap validation reports clear failures for missing module files, missing settings, missing modules, or command import failures.

## Constraints & Risks

- Do not overwrite user-authored analyzer/test settings without an explicit merge or overwrite policy.
- Keep bootstrap behavior compatible with repository PowerShell policy expectations and CI artifact consumers.
- Ensure module installation scope avoids requiring administrator elevation for normal developer setup.
- Risk: module version drift can break deterministic lint/test behavior if bootstrap and CI pinning diverge.
- Risk: path assumptions in settings files can break when workspaces use non-standard folder layouts.

## Test Conditions to Consider

- [ ] Unit coverage areas: module-file existence checks, version validation, and command availability detection.
- [ ] Unit coverage areas: error messages for missing runtime, missing modules, and malformed settings files.
- [ ] Integration scenarios: bootstrap a fresh workspace, then run format/analyze/test sequence end-to-end.
- [ ] Integration scenarios: verify coverage/JUnit artifacts are written to expected paths and are readable by coverage consumers.
- [ ] CLI/API examples: dry-run/bootstrap-plan output showing what will be installed, created, or validated.
- [ ] CLI/API examples: bootstrap apply mode output summarizing completed steps and any blocked prerequisites.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bootstrap-powershell-ecosystem/` folder from the template