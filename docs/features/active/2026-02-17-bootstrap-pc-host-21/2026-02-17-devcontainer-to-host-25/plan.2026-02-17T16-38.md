---
title: "2026-02-17-devcontainer-to-host - Plan"
issue: "#25"
parent: "none"
owner: "drmoisan"
last_updated: "2026-02-17T23-59"
status: "Planned"
status_color: "blue"
version: "1.0"
---

# 2026-02-17-devcontainer-to-host - Plan

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

- **Issue:** #25
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-17T23-59
- **Status:** Planned
- **Version:** 1.0

## Scope Anchors

- Feature folder: `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/`
- Spec source: `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/spec.md`
- User story source: `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/user-story.md`
- Planned implementation script: `scripts/dev-tools/bootstrap-host.ps1`
- Planned PowerShell tests: `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`
- Planned docs update target: `README.md`

## Required References

- General policy: `.github/copilot-instructions.md`
- General policy: `.github/instructions/general-code-change.instructions.md`
- General policy: `.github/instructions/general-unit-test.instructions.md`
- PowerShell policy: `.github/instructions/powershell-code-change.instructions.md`
- PowerShell unit-test policy: `.github/instructions/powershell-unit-test.instructions.md`

## Requirement Catalog

| ID | Type | Deterministic requirement |
|---|---|---|
| REQ-001 | Functional | Provide `verify` command in `scripts/dev-tools/bootstrap-host.ps1` that exits non-zero when any required dependency is missing. |
| REQ-002 | Functional | Provide `install` command in `scripts/dev-tools/bootstrap-host.ps1` that installs only dependencies classified as missing and auto-installable. |
| REQ-003 | Functional | Support flags: `--format text|json`, `--dry-run`, `--precheck`, `--postcheck`, `--only <dependency>`. |
| REQ-004 | Functional | Build dependency catalog from `.devcontainer/local/Dockerfile` and `.devcontainer/local/devcontainer.json` plus repo-required tooling checks. |
| REQ-005 | Functional | Produce per-dependency statuses from set `{present, missing, installed, failed, skipped}` for both text and JSON outputs. |
| REQ-006 | Functional | Validate dependency filter for `--only` as case-insensitive exact match and return deterministic error for unknown dependency names. |
| REQ-007 | Functional | Maintain idempotency: repeated `install` runs do not reinstall dependencies already classified as present. |
| REQ-008 | Functional | Handle unsupported OS/package manager with explicit non-zero exit and remediation guidance output. |
| REQ-009 | Functional | Continue best-effort install when one dependency fails and report aggregate failure with actionable details. |
| REQ-010 | Functional | Implement JSON output schema with stable keys: `name`, `required_version`, `detected_version`, `status`, `install_action`, `message`. |
| REQ-011 | Functional | Enforce baseline version checks: PowerShell `>=7.5`, Poetry `>=2.2.1` while allowing newer compatible versions. |
| REQ-012 | Quality | Add Pester unit tests covering dependency detection, version parsing, OS routing, install decision logic, idempotency, and CLI validation. |
| REQ-013 | Quality | Add integration-style Pester tests for pre-install verify failure, install flow transition, partial install failure summary, and unsupported platform behavior. |
| REQ-014 | Documentation | Update `README.md` with deterministic command examples for `verify --format json` and `install --dry-run`. |
| SEC-001 | Security | Never persist credentials; perform installs with explicit user-level behavior and no plaintext secret storage. |
| SEC-002 | Security | Emit remediation instructions for dependencies that cannot be auto-installed or require elevation. |
| CON-001 | Constraint | Keep implementation Windows-first while returning explicit unsupported messages on non-supported platforms. |
| CON-002 | Constraint | Use only repo-approved PowerShell/tooling dependencies; no new runtime package manager frameworks. |

## Scenario Inventory (TDD decomposition baseline)

- `Resolve-DependencyCatalog` scenario A: dependency rows are built from devcontainer files and include required version constraints.
- `Resolve-DependencyCatalog` scenario B: unsupported source file parse error returns deterministic failure message.
- `Test-DependencyPresence` scenario C: command missing returns `missing` with remediation hint.
- `Test-DependencyPresence` scenario D: version below minimum returns `missing` with version-specific message.
- `Test-DependencyPresence` scenario E: version compatible returns `present`.
- `Resolve-InstallStrategy` scenario F: supported OS and dependency return known install action.
- `Resolve-InstallStrategy` scenario G: unsupported OS returns explicit unsupported classification.
- `Invoke-BootstrapVerify` scenario H: missing dependency causes non-zero exit and status summary.
- `Invoke-BootstrapVerify` scenario I: `--only` unknown dependency returns deterministic validation error.
- `Invoke-BootstrapInstall` scenario J: `--dry-run` returns planned actions without invoking installers.
- `Invoke-BootstrapInstall` scenario K: repeated install run skips already-present dependencies.
- `Invoke-BootstrapInstall` scenario L: partial install failure continues best-effort and exits non-zero with aggregate summary.
- `Format-BootstrapReport` scenario M: JSON output contains stable schema keys for every dependency row.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs

- [x] [P0-T1] Read policy files in mandatory order and append a timestamped completion entry to `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/evidence/other/policy-read-order.2026-02-17T23-59.md`.
  - Acceptance: The artifact contains five ordered lines referencing `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`.
- [x] [P0-T2] Create canonical evidence directories under `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/evidence/` for `baseline/`, `regression-testing/`, `qa-gates/`, `other/`, and `issue-updates/`.
  - Acceptance: Directory listing for the feature evidence path contains `baseline/`, `regression-testing/`, `qa-gates/`, `other/`, and `issue-updates/` exactly once.
- [x] [P0-T3] Capture baseline formatter result by running `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` and record output to `evidence/baseline/powershell-format-baseline.2026-02-17T23-59.md`.
  - Acceptance: Artifact file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` lines.
- [x] [P0-T4] Capture baseline analyzer result by running `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` and record output to `evidence/baseline/powershell-analyze-baseline.2026-02-17T23-59.md`.
  - Acceptance: Artifact file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` lines.
- [x] [P0-T5] Capture baseline Pester result by running `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` and record output to `evidence/baseline/powershell-test-baseline.2026-02-17T23-59.md`.
  - Acceptance: Artifact file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` lines.

### Phase 1 — TDD Red: Add Deterministic Failing Tests First

- [ ] [P1-T1] Add Pester test for `Resolve-DependencyCatalog` scenario A in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting catalog includes `git`, `python`, `poetry`, `pwsh`, `node`, and `npm` with minimum-version metadata.
  - Acceptance: Test name contains `Resolve-DependencyCatalog` and `scenario A`, and assertion checks all six dependency names.
- [ ] [P1-T2] Add Pester test for `Resolve-DependencyCatalog` scenario B in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting deterministic error when devcontainer input parse fails.
  - Acceptance: Test name contains `Resolve-DependencyCatalog` and `scenario B`, and expected message contains `devcontainer parse failed`.
- [ ] [P1-T3] Add Pester test for `Test-DependencyPresence` scenario C in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting command-missing classification returns `missing` and remediation hint text.
  - Acceptance: Test name contains `Test-DependencyPresence` and `scenario C`, and assertion checks status plus non-empty remediation string.
- [ ] [P1-T4] Add Pester test for `Test-DependencyPresence` scenario D in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting below-minimum version classification returns `missing` with version guidance.
  - Acceptance: Test name contains `Test-DependencyPresence` and `scenario D`, and assertion checks message contains both detected and required versions.
- [ ] [P1-T5] Add Pester test for `Test-DependencyPresence` scenario E in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting compatible version classification returns `present`.
  - Acceptance: Test name contains `Test-DependencyPresence` and `scenario E`, and assertion checks status equals `present`.
- [ ] [P1-T6] Add Pester test for `Resolve-InstallStrategy` scenario F in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting supported Windows dependency maps to deterministic install action metadata.
  - Acceptance: Test name contains `Resolve-InstallStrategy` and `scenario F`, and assertion checks installer command token is non-empty.
- [ ] [P1-T7] Add Pester test for `Resolve-InstallStrategy` scenario G in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting unsupported OS returns unsupported classification.
  - Acceptance: Test name contains `Resolve-InstallStrategy` and `scenario G`, and assertion checks status equals `unsupported`.
- [ ] [P1-T8] Add Pester test for `Invoke-BootstrapVerify` scenario H in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting missing dependency leads to non-zero exit code.
  - Acceptance: Test name contains `Invoke-BootstrapVerify` and `scenario H`, and assertion checks exit code is non-zero.
- [ ] [P1-T9] Add Pester test for `Invoke-BootstrapVerify` scenario I in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting unknown `--only` dependency returns deterministic validation message.
  - Acceptance: Test name contains `Invoke-BootstrapVerify` and `scenario I`, and expected message contains `Unknown dependency filter`.
- [ ] [P1-T10] Add Pester test for `Invoke-BootstrapInstall` scenario J in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting `--dry-run` performs no install calls.
  - Acceptance: Test name contains `Invoke-BootstrapInstall` and `scenario J`, and assertion checks installer mock invocation count equals `0`.
- [ ] [P1-T11] Add Pester test for `Invoke-BootstrapInstall` scenario K in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting repeated install skips already-present dependencies.
  - Acceptance: Test name contains `Invoke-BootstrapInstall` and `scenario K`, and assertion checks second run emits `skipped`.
- [ ] [P1-T12] Add Pester test for `Invoke-BootstrapInstall` scenario L in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting partial failure continues best-effort and returns aggregate non-zero exit.
  - Acceptance: Test name contains `Invoke-BootstrapInstall` and `scenario L`, and assertion checks one dependency `failed` while at least one later dependency is still processed.
- [ ] [P1-T13] Add Pester test for `Format-BootstrapReport` scenario M in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` asserting JSON output rows always contain keys `name`, `required_version`, `detected_version`, `status`, `install_action`, and `message`.
  - Acceptance: Test name contains `Format-BootstrapReport` and `scenario M`, and assertion checks all six keys on each row.
- [ ] [P1-T14] [expect-fail] Run targeted test command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/bootstrap-host.Tests.ps1 -Output Detailed"` before implementing `scripts/dev-tools/bootstrap-host.ps1` and save fail-before evidence at `evidence/regression-testing/bootstrap-host-red-suite.2026-02-17T23-59.md`.
  - Acceptance: Command exits non-zero and evidence artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and a `Failure:` excerpt attributable to missing implementation.

### Phase 2 — Implement Verify/Install Commands and Core Functions

- [ ] [P2-T1] Create `scripts/dev-tools/bootstrap-host.ps1` with advanced-function entrypoint `Invoke-BootstrapHost` exposing parameters `-Command`, `-Format`, `-DryRun`, `-Precheck`, `-Postcheck`, and `-Only`.
  - Acceptance: Script file exists and contains `function Invoke-BootstrapHost` plus parameter definitions matching the exact names.
- [ ] [P2-T2] Implement function `Resolve-DependencyCatalog` in `scripts/dev-tools/bootstrap-host.ps1` to parse `.devcontainer/local/Dockerfile` and `.devcontainer/local/devcontainer.json` into normalized dependency rows.
  - Acceptance: Function returns row objects with fields `name`, `required_version`, and `source` for each required dependency.
- [ ] [P2-T3] Implement function `Test-DependencyPresence` in `scripts/dev-tools/bootstrap-host.ps1` to classify dependencies as `present` or `missing` using command detection and version parsing.
  - Acceptance: Function output object contains keys `name`, `detected_version`, `status`, and `message`; `status` is exactly one of `present|missing` for verify classification.
- [ ] [P2-T4] Implement function `Resolve-InstallStrategy` in `scripts/dev-tools/bootstrap-host.ps1` to map dependency rows to OS/package-manager install actions and unsupported classifications.
  - Acceptance: Function output contains fields `install_action`, `is_auto_installable`, and `message`.
- [ ] [P2-T5] Implement function `Invoke-DependencyInstall` in `scripts/dev-tools/bootstrap-host.ps1` to execute or skip install actions based on `-DryRun` and current status.
  - Acceptance: Function sets status transitions only from `missing` to `installed|failed|skipped` and never mutates `present` rows.
- [ ] [P2-T6] Implement function `Invoke-BootstrapVerify` in `scripts/dev-tools/bootstrap-host.ps1` to run catalog resolution, dependency checks, status output, and deterministic exit-code logic.
  - Acceptance: Function exits `0` when no required dependency is `missing`; function exits non-zero otherwise.
- [ ] [P2-T7] Implement function `Invoke-BootstrapInstall` in `scripts/dev-tools/bootstrap-host.ps1` to apply optional precheck/postcheck flow and best-effort install semantics.
  - Acceptance: Function runs postcheck when `-Postcheck` is true and returns non-zero when unresolved required dependencies remain.
- [ ] [P2-T8] Implement function `Format-BootstrapReport` in `scripts/dev-tools/bootstrap-host.ps1` to emit text table and JSON output using stable schema keys required by REQ-010.
  - Acceptance: JSON serialization output includes keys `name`, `required_version`, `detected_version`, `status`, `install_action`, and `message` in each object.
- [ ] [P2-T9] Implement function `Resolve-OnlyDependencyFilter` in `scripts/dev-tools/bootstrap-host.ps1` for case-insensitive exact matching and deterministic unknown-filter validation.
  - Acceptance: Unknown value raises deterministic error message containing `Unknown dependency filter` and non-zero exit code.

### Phase 3 — TDD Green: Make Tests Pass and Add Contract-Level Scenarios

- [ ] [P3-T1] Run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/bootstrap-host.Tests.ps1 -Output Detailed"` and capture pass-after evidence in `evidence/regression-testing/bootstrap-host-green-suite.2026-02-17T23-59.md`.
  - Acceptance: Command exits `0` and evidence artifact contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.
- [ ] [P3-T2] Add Pester test in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` validating REQ-011 by asserting PowerShell minimum version comparison accepts `7.5.0` and rejects `7.4.x`.
  - Acceptance: Test explicitly asserts accepted/rejected boundaries for PowerShell version logic.
- [ ] [P3-T3] Add Pester test in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` validating REQ-011 by asserting Poetry minimum version comparison accepts `2.2.1` and rejects `2.2.0`.
  - Acceptance: Test explicitly asserts accepted/rejected boundaries for Poetry version logic.
- [ ] [P3-T4] Add Pester test in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` validating REQ-009 by asserting install flow continues after first dependency failure.
  - Acceptance: Test verifies at least one dependency after the failure is evaluated and reported.
- [ ] [P3-T5] Add Pester test in `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` validating SEC-002 by asserting remediation guidance is non-empty for each `failed` or `missing` row.
  - Acceptance: Test checks `message` field for non-empty actionable text whenever status is `failed` or `missing`.
- [ ] [P3-T6] Re-run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/bootstrap-host.Tests.ps1 -Output Detailed"` after contract tests and save result in `evidence/regression-testing/bootstrap-host-contract-suite.2026-02-17T23-59.md`.
  - Acceptance: Command exits `0` and evidence artifact contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`.

### Phase 4 — Documentation and Traceability Synchronization

- [ ] [P4-T1] Update `README.md` with command examples `pwsh ./scripts/dev-tools/bootstrap-host.ps1 verify --format json` and `pwsh ./scripts/dev-tools/bootstrap-host.ps1 install --dry-run`.
  - Acceptance: `README.md` contains both commands exactly once under a heading named `## Host bootstrap`.
- [ ] [P4-T2] Update `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/spec.md` with implemented function names and output schema keys.
  - Acceptance: `spec.md` contains function names `Resolve-DependencyCatalog`, `Test-DependencyPresence`, `Invoke-BootstrapVerify`, and `Invoke-BootstrapInstall`.
- [ ] [P4-T3] Update `docs/features/active/2026-02-17-bootstrap-pc-host-21/2026-02-17-devcontainer-to-host-25/user-story.md` with implementation evidence links under acceptance criteria section.
  - Acceptance: `user-story.md` includes references to at least one regression evidence artifact and one QA evidence artifact path.

### Phase 5 — Final QA Loop (PowerShell Toolchain)

- [ ] [P5-T1] Run formatter command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."` for final QA pass and save artifact `evidence/qa-gates/final-format.2026-02-17T23-59.md`.
  - Acceptance: Command exits `0` and artifact contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`; if this step fails or changes files, restart Phase 5 from `P5-T1` and do not mark complete until `format→analyze→test` all succeed in one clean pass.
- [ ] [P5-T2] Run analyzer command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."` for the same pass and save artifact `evidence/qa-gates/final-analyze.2026-02-17T23-59.md`.
  - Acceptance: Command exits `0` and artifact contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`; if this step fails or changes files, restart Phase 5 from `P5-T1` and do not mark complete until `format→analyze→test` all succeed in one clean pass.
- [ ] [P5-T3] Run Pester command `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` for the same pass and save artifact `evidence/qa-gates/final-test.2026-02-17T23-59.md`.
  - Acceptance: Command exits `0` and artifact contains `Timestamp:`, `Command:`, and `EXIT_CODE: 0`; if this step fails or changes files, restart Phase 5 from `P5-T1` and do not mark complete until `format→analyze→test` all succeed in one clean pass.
- [ ] [P5-T4] Compare final QA artifacts with baseline artifacts and save deterministic delta summary to `evidence/qa-gates/final-delta-summary.2026-02-17T23-59.md`.
  - Acceptance: Summary states whether any new analyzer findings or test failures exist relative to Phase 0 artifacts.

## Requirements Traceability

| Requirement ID | Planned task IDs |
|---|---|
| REQ-001 | P2-T1, P2-T6, P3-T6 |
| REQ-002 | P2-T1, P2-T5, P2-T7, P3-T6 |
| REQ-003 | P2-T1, P2-T7, P2-T9, P4-T1 |
| REQ-004 | P2-T2, P3-T6 |
| REQ-005 | P2-T3, P2-T5, P2-T8, P3-T6 |
| REQ-006 | P2-T9, P1-T9, P3-T6 |
| REQ-007 | P2-T5, P2-T7, P1-T11, P3-T6 |
| REQ-008 | P2-T4, P1-T7, P3-T6 |
| REQ-009 | P2-T7, P1-T12, P3-T4, P3-T6 |
| REQ-010 | P2-T8, P1-T13, P3-T6 |
| REQ-011 | P2-T3, P3-T2, P3-T3 |
| REQ-012 | P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P1-T6, P1-T7, P1-T8, P1-T9, P1-T10, P1-T11, P1-T12, P1-T13 |
| REQ-013 | P1-T14, P3-T1, P3-T4, P3-T6 |
| REQ-014 | P4-T1 |
| SEC-001 | P2-T5, P2-T7 |
| SEC-002 | P2-T4, P2-T8, P3-T5 |
| CON-001 | P2-T4, P1-T7 |
| CON-002 | P0-T1, P2-T1 |

## Test Plan

- Unit (Pester): `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` scenarios A-M plus version-boundary and remediation contract scenarios.
- Integration-style (Pester with mocks): verify non-zero pre-install, dry-run no-op, partial failure continuation, unsupported OS behavior, post-install state transitions.
- CLI/API deterministic commands:
  - `pwsh ./scripts/dev-tools/bootstrap-host.ps1 verify --format json`
  - `pwsh ./scripts/dev-tools/bootstrap-host.ps1 install --dry-run --format text`

## Open Questions / Notes

- None. All required behavior is specified via REQ/SEC/CON IDs and mapped to atomic task IDs.

## Preflight Validation Log

- Iteration 1: PREFLIGHT: REVISIONS REQUIRED
  - Delta applied: added `issue-updates/` to canonical evidence directory task, strengthened `P2-T3` acceptance to exact status domain, strengthened `P4-T1` acceptance to exact heading requirement, and added explicit Phase 5 restart-loop rule to `P5-T1..P5-T3`.
- Iteration 2: PREFLIGHT: ALL CLEAR
