---
issue: 133
parent: none
owner: drmoisan
last_updated: 2026-04-11T11-13
status: Planned
status_color: blue
version: 1.0
work_mode: full-feature
plan_type: remediation
plan_path: docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/remediation-plan.2026-04-11T11-13.md
---

# Remediation Plan: 2026-04-07-bundle-poshqc-suite-into-extension-133 (2026-04-11T11-13)

- **Issue:** #133
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-11T11-13
- **Status:** Planned
- **Version:** 1.0
- **Work Mode Resolution:** `full-feature` from `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/issue.md`

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Remediation Objective

**Status Badge:** `[Planned | blue]`

Close every outstanding remediation requirement recorded in `remediation-inputs.2026-04-11T11-13.md`, `policy-audit.2026-04-11T11-13.md`, `code-review.2026-04-11T11-13.md`, `feature-audit.2026-04-11T11-13.md`, `spec.md`, and `user-story.md` by recreating canonical evidence, raising changed-surface TypeScript/Python/PowerShell coverage to repository thresholds, restoring PowerShell file-size compliance without breaking bundled parity, and synchronizing documentation plus acceptance artifacts.

## Requirements Traceability

| Requirement ID | Source | Requirement | Planned Coverage |
|---|---|---|---|
| REQ-1 | `remediation-inputs.2026-04-11T11-13.md` item 1 | Recreate canonical baseline and QA evidence under `evidence/baseline/` and `evidence/qa-gates/`, then resynchronize `plan.2026-04-07T08-52.md` checklist state with artifacts on disk. | Phase 0, Phase 1, Phase 6 |
| REQ-2 | `remediation-inputs.2026-04-11T11-13.md` item 2 | Raise changed-surface TypeScript coverage for `extensions/drm-copilot/src/mcp-tool-inputs.ts` and related MCP semantic-tool paths to repository thresholds. | Phase 2, Phase 6 |
| REQ-3 | `remediation-inputs.2026-04-11T11-13.md` item 3 | Raise `scripts/dev_tools/validate_orchestration_artifacts.py` focused coverage to at least 90% with Black, Ruff, and Pyright still passing. | Phase 3, Phase 6 |
| REQ-4 | `remediation-inputs.2026-04-11T11-13.md` items 4 and 6 | Raise PowerShell coverage for the scan-folder-aware PoshQC module, split the oversized module below 500 lines, and preserve parity between repo-root and bundled copies. | Phase 4, Phase 6 |
| REQ-5 | `remediation-inputs.2026-04-11T11-13.md` item 5 | Update `extensions/drm-copilot/README.md` so the exposed MCP tool list and input summary match the implemented tool surface exactly. | Phase 5, Phase 6 |
| REQ-6 | `spec.md`, `user-story.md`, `feature-audit.2026-04-11T11-13.md` | Complete the remaining acceptance criteria by aligning tests, documentation, evidence, and review artifacts with the remediated branch state. | Phase 5, Phase 6 |

## Constraint Register

| Constraint ID | Source | Constraint |
|---|---|---|
| CON-1 | `issue.md` work mode marker | Treat `spec.md` and `user-story.md` as authoritative acceptance-criteria sources because work mode resolves to `full-feature`. |
| CON-2 | `remediation-inputs.2026-04-11T11-13.md` Do Not Do | Do not weaken coverage gates, validator rules, or policy requirements to make the review pass. |
| CON-3 | `remediation-inputs.2026-04-11T11-13.md` Do Not Do | Do not mark original plan tasks complete unless the corresponding evidence artifact exists on disk. |
| CON-4 | `remediation-inputs.2026-04-11T11-13.md` Do Not Do | Do not break the parity contract between `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`. |
| CON-5 | repo policies | Do not introduce temporary-file test strategies or broad lint/type suppressions. |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Inputs

**Phase Completion Criteria:** Policy-read evidence exists; missing-evidence discovery is auditable; baseline formatter/linter/type-check/test artifacts exist under canonical `evidence/baseline/` for every in-scope language; baseline coverage artifacts record numeric headline values for TypeScript, Python, and PowerShell.

- [x] [P0-T1] Record policy-read evidence in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/remediation-policy-read.2026-04-11T11-13.md` for this exact file order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp: 2026-04-11T11-13`, `Command: policy-read verification`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P0-T2] Record remediation scope evidence in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/remediation-scope.2026-04-11T11-13.md` by reading `remediation-inputs.2026-04-11T11-13.md`, `spec.md`, `user-story.md`, `research.md`, `policy-audit.2026-04-11T11-13.md`, `code-review.2026-04-11T11-13.md`, and `feature-audit.2026-04-11T11-13.md`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp: 2026-04-11T11-13`, `Command: remediation scope lock`, `EXIT_CODE: 0`, and `Output Summary:` naming `REQ-1` through `REQ-6`.

- [x] [P0-T3] Record auditable missing-evidence search output in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/missing-canonical-evidence-search.2026-04-11T11-13.md` using `Get-ChildItem docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence -Recurse`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Get-ChildItem docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence -Recurse`, `EXIT_CODE:`, `Output Summary:`, `SearchScope: docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence`, `SearchPatterns: evidence/baseline/**; evidence/qa-gates/**`, and `SearchResult:`.

- [x] [P0-T4] Capture the baseline TypeScript formatter result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-typescript-prettier.2026-04-11T11-13.md` by running `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T5] Capture the baseline TypeScript lint result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-typescript-eslint.2026-04-11T11-13.md` by running `Push-Location extensions/drm-copilot; npm run lint; Pop-Location`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npm run lint; Pop-Location`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T6] Capture the baseline TypeScript type-check result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-typescript-typecheck.2026-04-11T11-13.md` by running `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T7] Capture the baseline TypeScript coverage result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-typescript-jest-coverage.2026-04-11T11-13.md` by running `Push-Location extensions/drm-copilot; npm run test -- --coverage; Pop-Location`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npm run test -- --coverage; Pop-Location`, `EXIT_CODE:`, and `Output Summary:` with numeric overall coverage plus numeric `src/mcp-tool-inputs.ts` coverage values.

- [x] [P0-T8] Capture the baseline Python formatter result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-python-black.2026-04-11T11-13.md` by running `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T9] Capture the baseline Python lint result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-python-ruff.2026-04-11T11-13.md` by running `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T10] Capture the baseline Python type-check result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-python-pyright.2026-04-11T11-13.md` by running `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T11] Capture the baseline Python coverage result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-python-pytest-coverage.2026-04-11T11-13.md` by running `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` with a numeric coverage value for `scripts/dev_tools/validate_orchestration_artifacts.py`.

- [x] [P0-T12] Capture the baseline PowerShell formatter comparison result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-powershell-format-compare.2026-04-11T11-13.md` by running the approved PowerShell formatter contract `mcp__drmCopilotExtension__run_poshqc_format` against the in-scope repo-root, bundled, and Pester files under `scripts/powershell/PoshQC`, `extensions/drm-copilot/resources/powershell/PoshQC`, and `tests/scripts/powershell/PoshQC`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, and non-empty `Output Summary:` while preserving the canonical evidence location.

- [x] [P0-T13] Capture the baseline PowerShell analyzer result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-powershell-analyze.2026-04-11T11-13.md` by running the approved PowerShell analyzer contract `mcp__drmCopilotExtension__run_poshqc_analyze` with scan folders `scripts/powershell/PoshQC`, `extensions/drm-copilot/resources/powershell/PoshQC`, `extensions/drm-copilot/resources/templates`, and `tests/scripts/powershell/PoshQC`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, and non-empty `Output Summary:` while preserving the canonical evidence location.

- [x] [P0-T14] Capture the baseline focused PowerShell coverage result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-powershell-pester-coverage.2026-04-11T11-13.md` by running the approved PowerShell test contract `mcp_drmcopilotext_run_poshqc_test` in coverage mode against `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` with coverage focused on `scripts/powershell/PoshQC/PoshQC.psm1`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and `Output Summary:` with a numeric coverage value for `scripts/powershell/PoshQC/PoshQC.psm1` while preserving the canonical evidence location.

- [x] [P0-T15] Capture the baseline PowerShell line-count result in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/baseline-poshqc-line-counts.2026-04-11T11-13.md` by running `(Get-Content scripts/powershell/PoshQC/PoshQC.psm1 | Measure-Object -Line).Lines` and `(Get-Content extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | Measure-Object -Line).Lines`.
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: line-count verification for repo-root and bundled PoshQC.psm1`, `EXIT_CODE:`, and `Output Summary:` naming the numeric line counts for both module copies.

### Phase 1 — Canonical Evidence Repair and Original Plan Reconciliation

**Phase Completion Criteria:** Canonical baseline artifacts and canonical QA-gate placeholders are recreated under the feature folder; the original implementation plan no longer claims completed evidence work without corresponding files on disk.

- [x] [P1-T1] Record recreated original-plan branch and feature-inventory evidence in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/original-plan-branch-inventory.2026-04-11T11-13.md` using `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, and `Get-ChildItem docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133 -Recurse`.
  - Acceptance: The artifact exists and contains one command block for each command with exact `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields.

- [x] [P1-T2] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md` Phase 0 checklist states so `[P0-T1]`, `[P0-T3]`, and `[P0-T4]` match the baseline artifacts recreated in Phase 0.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md').read_text(encoding='utf-8'); assert '- [x] [P0-T1]' in t; assert '- [x] [P0-T3]' in t; assert '- [x] [P0-T4]' in t"` exits with `EXIT_CODE: 0` only when the referenced baseline artifacts exist.

- [x] [P1-T3] Leave `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md` Phase 2 checklist tasks `[P2-T1]` through `[P2-T5]` unchecked until Phase 6 writes canonical `evidence/qa-gates/` artifacts.
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md').read_text(encoding='utf-8'); assert '- [ ] [P2-T1]' in t; assert '- [ ] [P2-T5]' in t"` exits with `EXIT_CODE: 0` before Phase 6 begins.

- [x] [P1-T4] Record a reconciliation summary in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/other/original-plan-reconciliation.2026-04-11T11-13.md` naming each original-plan evidence task, its canonical artifact path, and its checklist state after reconciliation.
  - Acceptance: The summary artifact exists and contains exact fields `Timestamp:`, `Command: original plan reconciliation`, `EXIT_CODE: 0`, and `Output Summary:` naming `[P0-T1]`, `[P0-T3]`, `[P0-T4]`, `[P2-T1]`, `[P2-T2]`, `[P2-T3]`, `[P2-T4]`, and `[P2-T5]`.

### Phase 2 — TypeScript Coverage Closure for MCP Input Parsing and Semantic Tool Paths

**Phase Completion Criteria:** Dedicated Jest coverage exists for `resolveRunPoshQCSuiteToolInput`, `resolveValidateOrchestrationArtifactsToolInput`, and the related MCP dispatch surface; the focused TypeScript coverage evidence shows `src/mcp-tool-inputs.ts` at or above 90% lines and functions.

- [x] [P2-T1] Create `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` and add shared Arrange helpers for resolver invocation with `workspace_root`, `scan_folders`, `artifact_type`, `artifact_path`, and `require_complete` inputs. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand; Pop-Location` exits with `EXIT_CODE: 0` after the helper scaffold is committed.

- [x] [P2-T2] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveRunPoshQCSuiteToolInput` returns `workspaceRoot` plus `scanFolders` when `scan_folders` is a valid string array. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveRunPoshQCSuiteToolInput.*valid string array"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T3] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveRunPoshQCSuiteToolInput` falls back to the provided workspace root when `workspace_root` is omitted. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveRunPoshQCSuiteToolInput.*falls back to the provided workspace root"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T4] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveRunPoshQCSuiteToolInput` rejects non-array `scan_folders`. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveRunPoshQCSuiteToolInput.*rejects non-array scan_folders"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T5] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveRunPoshQCSuiteToolInput` rejects non-string `scan_folders` elements. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveRunPoshQCSuiteToolInput.*rejects non-string scan_folders elements"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T6] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveValidateOrchestrationArtifactsToolInput` returns `artifactType`, `artifactPath`, and `requireComplete: true` for a valid `plan` payload. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveValidateOrchestrationArtifactsToolInput.*valid plan payload"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T7] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveValidateOrchestrationArtifactsToolInput` rejects a missing `artifact_path`. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveValidateOrchestrationArtifactsToolInput.*rejects a missing artifact_path"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T8] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveValidateOrchestrationArtifactsToolInput` rejects a non-string `artifact_path`. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveValidateOrchestrationArtifactsToolInput.*rejects a non-string artifact_path"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T9] Add a Jest scenario in `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` verifying `resolveValidateOrchestrationArtifactsToolInput` rejects an invalid `artifact_type` enum. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-tool-inputs.test.ts --runInBand --testNamePattern "resolveValidateOrchestrationArtifactsToolInput.*rejects an invalid artifact_type enum"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T10] Add a Jest scenario in `extensions/drm-copilot/test/mcp-server.test.ts` verifying the MCP server dispatches `run_poshqc_suite` through `resolveRunPoshQCSuiteToolInput` and forwards repeated `scan_folders` values to the repo-automation service. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-server.test.ts --runInBand --testNamePattern "run_poshqc_suite.*scan_folders"; Pop-Location` exits with `EXIT_CODE: 0`.

- [x] [P2-T11] Add a Jest scenario in `extensions/drm-copilot/test/mcp-server.test.ts` verifying the MCP server dispatches `validate_orchestration_artifacts` through `resolveValidateOrchestrationArtifactsToolInput` and forwards `artifact_type`, `artifact_path`, and `require_complete` to the repo-automation service. (Covers REQ-2.)
  - Acceptance: `Push-Location extensions/drm-copilot; npx jest --runTestsByPath test/mcp-server.test.ts --runInBand --testNamePattern "validate_orchestration_artifacts.*require_complete"; Pop-Location` exits with `EXIT_CODE: 0`.

### Phase 3 — Python Coverage Closure for the Orchestration Artifact Validator

**Phase Completion Criteria:** Focused Pytest coverage for `scripts/dev_tools/validate_orchestration_artifacts.py` reaches at least 90%; new tests cover malformed receipt payloads, unsupported dispatch, and CLI failure paths without introducing temporary-file test strategies.

- [x] [P3-T1] Add a Pytest scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` verifying `validate_orchestrator_state_text` rejects a JSON root that is not an object. (Covers REQ-3.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -k "json root that is not an object"` exits with `EXIT_CODE: 0`.

- [x] [P3-T2] Add a Pytest scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` verifying `validate_orchestrator_state_text` rejects `delegation_receipts` when the field is not a list. (Covers REQ-3.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -k "delegation_receipts when the field is not a list"` exits with `EXIT_CODE: 0`.

- [x] [P3-T3] Add a Pytest scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` verifying `validate_orchestrator_state_text` rejects a receipt object missing `result_signal`. (Covers REQ-3.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -k "receipt object missing result_signal"` exits with `EXIT_CODE: 0`.

- [x] [P3-T4] Add a Pytest scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` verifying `validate_orchestrator_state_text` rejects a receipt whose `artifact_paths` value is not a list. (Covers REQ-3.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -k "artifact_paths value is not a list"` exits with `EXIT_CODE: 0`.

- [x] [P3-T5] Add a Pytest scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` verifying `_validate_from_args` returns `Unsupported artifact type` when it receives an unrecognized `artifact_type` namespace value with `_read_text` monkeypatched to a stable in-memory payload. (Covers REQ-3.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -k "Unsupported artifact type"` exits with `EXIT_CODE: 0`.

- [x] [P3-T6] Add a Pytest scenario in `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` verifying `main()` returns exit code `1` for an invalid `plan` artifact while reading the artifact text through a monkeypatched `_read_text` helper instead of a temporary file. (Covers REQ-3 and CON-5.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -k "main returns exit code 1 for an invalid plan artifact"` exits with `EXIT_CODE: 0`.

### Phase 4 — PowerShell Module Split, Parity Preservation, and Coverage Closure

**Phase Completion Criteria:** No production or bundled PowerShell module file exceeds 500 lines; repo-root and bundled helper modules remain mirror-equal; focused Pester coverage for the changed PoshQC behavior reaches repository expectations.

- [x] [P4-T1] Record a split design note in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/other/poshqc-split-design.2026-04-11T11-13.md` assigning `ConvertTo-PoshQCPath`, `Get-PoshQCFileList`, and `Resolve-PoshQCScanFolder` to `PoshQC.FileDiscovery.psm1`; `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCAnalyzeAutofix` to `PoshQC.Analyzer.psm1`; and `Convert-PoshQCCoverageToRelative`, `Invoke-PoshQCTest`, and `Invoke-PoshQCSuite` to `PoshQC.Testing.psm1`. (Covers REQ-4.)
  - Acceptance: The design note exists and contains exact fields `Timestamp:`, `Command: PoshQC split design`, `EXIT_CODE: 0`, and `Output Summary:` naming the three helper-module filenames exactly.

- [x] [P4-T2] Create `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1` and move `ConvertTo-PoshQCPath`, `Get-PoshQCFileList`, and `Resolve-PoshQCScanFolder` out of `scripts/powershell/PoshQC/PoshQC.psm1`. (Covers REQ-4.)
  - Acceptance: `(Get-Content scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1 | Measure-Object -Line).Lines` exits with `EXIT_CODE: 0` and returns a value `<= 500`.

- [x] [P4-T3] Create `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` and move `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCAnalyzeAutofix` out of `scripts/powershell/PoshQC/PoshQC.psm1`. (Covers REQ-4.)
  - Acceptance: `(Get-Content scripts/powershell/PoshQC/PoshQC.Analyzer.psm1 | Measure-Object -Line).Lines` exits with `EXIT_CODE: 0` and returns a value `<= 500`.

- [x] [P4-T4] Create `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and move `Convert-PoshQCCoverageToRelative`, `Invoke-PoshQCTest`, and `Invoke-PoshQCSuite` out of `scripts/powershell/PoshQC/PoshQC.psm1`. (Covers REQ-4.)
  - Acceptance: `(Get-Content scripts/powershell/PoshQC/PoshQC.Testing.psm1 | Measure-Object -Line).Lines` exits with `EXIT_CODE: 0` and returns a value `<= 500`.

- [x] [P4-T5] Update `scripts/powershell/PoshQC/PoshQC.psm1` to dot-source `PoshQC.FileDiscovery.psm1`, `PoshQC.Analyzer.psm1`, and `PoshQC.Testing.psm1`, preserve `$script:PssaSettings`, `$script:PesterSettings`, and `$script:DefaultExcludedDirs`, and keep the existing exported function list unchanged. (Covers REQ-4.)
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('scripts/powershell/PoshQC/PoshQC.psm1').read_text(encoding='utf-8'); assert 'PoshQC.FileDiscovery.psm1' in t; assert 'PoshQC.Analyzer.psm1' in t; assert 'PoshQC.Testing.psm1' in t"` exits with `EXIT_CODE: 0`.

- [x] [P4-T6] Create `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.FileDiscovery.psm1` so it mirrors `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1` exactly. (Covers REQ-4 and CON-4.)
  - Acceptance: `poetry run python -c "from pathlib import Path; assert Path('scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1').read_text(encoding='utf-8') == Path('extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.FileDiscovery.psm1').read_text(encoding='utf-8')"` exits with `EXIT_CODE: 0`.

- [x] [P4-T7] Create `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Analyzer.psm1` so it mirrors `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` exactly. (Covers REQ-4 and CON-4.)
  - Acceptance: `poetry run python -c "from pathlib import Path; assert Path('scripts/powershell/PoshQC/PoshQC.Analyzer.psm1').read_text(encoding='utf-8') == Path('extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Analyzer.psm1').read_text(encoding='utf-8')"` exits with `EXIT_CODE: 0`.

- [x] [P4-T8] Create `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` so it mirrors `scripts/powershell/PoshQC/PoshQC.Testing.psm1` exactly. (Covers REQ-4 and CON-4.)
  - Acceptance: `poetry run python -c "from pathlib import Path; assert Path('scripts/powershell/PoshQC/PoshQC.Testing.psm1').read_text(encoding='utf-8') == Path('extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1').read_text(encoding='utf-8')"` exits with `EXIT_CODE: 0`.

- [x] [P4-T9] Update `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` to dot-source `PoshQC.FileDiscovery.psm1`, `PoshQC.Analyzer.psm1`, and `PoshQC.Testing.psm1` while preserving mirror parity with `scripts/powershell/PoshQC/PoshQC.psm1`. (Covers REQ-4 and CON-4.)
  - Acceptance: `poetry run python -c "from pathlib import Path; assert Path('scripts/powershell/PoshQC/PoshQC.psm1').read_text(encoding='utf-8') == Path('extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1').read_text(encoding='utf-8')"` exits with `EXIT_CODE: 0`.

- [x] [P4-T10] Add a parity regression test in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` that asserts exact text equality for `PoshQC.psm1`, `PoshQC.FileDiscovery.psm1`, `PoshQC.Analyzer.psm1`, and `PoshQC.Testing.psm1` between repo-root and bundled paths. (Covers REQ-4.)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` exits with `EXIT_CODE: 0`.

- [x] [P4-T11] Add a Pester scenario in `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` verifying `Resolve-PoshQCScanFolder` rejects blank scan-folder values. (Covers REQ-4.)
  - Acceptance: `mcp_drmcopilotext_run_poshqc_test` exits with `EXIT_CODE: 0` when run against `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, and the test file contains an `It` block with text `rejects blank scan-folder values`.

- [x] [P4-T12] Add a Pester scenario in `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` verifying `Get-PoshQCFileList` returns an empty array when selected scan roots contain no PowerShell files. (Covers REQ-4.)
  - Acceptance: `mcp_drmcopilotext_run_poshqc_test` exits with `EXIT_CODE: 0` when run against `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, and the test file contains an `It` block with text `returns an empty array when selected scan roots contain no PowerShell files`.

- [x] [P4-T13] Add a Pester scenario in `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` verifying `Invoke-PoshQCAnalyze` honors `ScanFolders` when requesting the file list. (Covers REQ-4.)
  - Acceptance: `mcp_drmcopilotext_run_poshqc_test` exits with `EXIT_CODE: 0` when run against `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, and the test file contains an `It` block with text `honors ScanFolders when requesting the file list`.

- [x] [P4-T14] Add a Pester scenario in `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` verifying `Invoke-PoshQCAnalyzeAutofix` preserves selected scan folders when it reruns analysis after autofix. (Covers REQ-4.)
  - Acceptance: `mcp_drmcopilotext_run_poshqc_test` exits with `EXIT_CODE: 0` when run against `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, and the test file contains an `It` block with text `preserves selected scan folders when it reruns analysis after autofix`.

- [x] [P4-T15] Add a Pester scenario in `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` verifying `Invoke-PoshQCTest` preserves a custom `KoverageOutputPath` when `ScanFolders` override `Run.Path` and `CodeCoverage.Path`. (Covers REQ-4.)
  - Acceptance: `mcp_drmcopilotext_run_poshqc_test` exits with `EXIT_CODE: 0` when run against `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`, and the test file contains an `It` block with text `preserves a custom KoverageOutputPath when ScanFolders override Run.Path and CodeCoverage.Path`.

### Phase 5 — Documentation and Acceptance-Source Closure

**Phase Completion Criteria:** The extension README lists the full MCP tool surface and exact input contracts; acceptance-source documents are ready to be checked only after QA artifacts and refreshed audits confirm the remediated state.

- [x] [P5-T1] Update the `### Exposed MCP Tools` section in `extensions/drm-copilot/README.md` so it lists `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, `run_poshqc_suite`, and `validate_orchestration_artifacts` in addition to the previously documented tools. (Covers REQ-5.)
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/drm-copilot/README.md').read_text(encoding='utf-8');
for name in ['run_poshqc_format','run_poshqc_analyze','run_poshqc_test','run_poshqc_analyze_autofix','run_poshqc_suite','validate_orchestration_artifacts']:
    assert name in t"` exits with `EXIT_CODE: 0`.

- [x] [P5-T2] Update the `### MCP Input Summary` section in `extensions/drm-copilot/README.md` so it documents the exact `workspace_root`, `scan_folders`, `artifact_type`, `artifact_path`, and `require_complete` contracts implemented in `extensions/drm-copilot/src/mcp-tools.ts` and `extensions/drm-copilot/src/repo-automation-service.ts`. (Covers REQ-5.)
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('extensions/drm-copilot/README.md').read_text(encoding='utf-8'); assert 'run_poshqc_suite: optional `workspace_root`, optional `scan_folders`' in t; assert 'validate_orchestration_artifacts: optional `workspace_root`, required `artifact_type`, required `artifact_path`, optional `require_complete`' in t"` exits with `EXIT_CODE: 0`.

- [x] [P5-T3] Prepare acceptance-source updates by leaving the remaining unchecked criteria in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/spec.md` and `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/user-story.md` untouched until Phase 6 evidence proves `REQ-2` through `REQ-6`. (Covers REQ-6.)
  - Acceptance: `poetry run python -c "from pathlib import Path; spec=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/spec.md').read_text(encoding='utf-8'); story=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/user-story.md').read_text(encoding='utf-8'); assert '- [ ] The extension and PowerShell test suites cover the new wrapper, command wiring, MCP dispatch, and folder-selection behavior.' in spec; assert '- [ ] Documentation and feature artifacts reflect the new bundled workflow and its usage.' in spec; assert '- [ ] Tests and documentation are updated for the new bundled workflow and folder-selection behavior.' in story"` exits with `EXIT_CODE: 0` before Phase 6 closeout.

### Phase 6 — Final QA, Acceptance Closeout, and Review Artifact Refresh

**Phase Completion Criteria:** One clean formatter → lint → type-check → test loop is recorded for every in-scope language under canonical `evidence/qa-gates/`; coverage evidence records numeric threshold satisfaction; acceptance-source files and review artifacts reflect the remediated branch state; the original feature plan checklist is synchronized with the new evidence bundle.

- [x] [P6-T1] Run the final TypeScript formatter gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-typescript-prettier.2026-04-11T11-13.md` with `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`. If this step reports changes, rerun Phase 6 from [P6-T1].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P6-T2] Run the final TypeScript lint gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-typescript-eslint.2026-04-11T11-13.md` with `Push-Location extensions/drm-copilot; npm run lint; Pop-Location`. If this step fails, rerun Phase 6 from [P6-T1].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npm run lint; Pop-Location`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P6-T3] Run the final TypeScript type-check gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-typescript-typecheck.2026-04-11T11-13.md` with `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location`. If this step fails, rerun Phase 6 from [P6-T1].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P6-T4] Run the final TypeScript coverage gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-typescript-jest-coverage.2026-04-11T11-13.md` with `Push-Location extensions/drm-copilot; npm run test -- --coverage; Pop-Location`. If this step fails, rerun Phase 6 from [P6-T1].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: Push-Location extensions/drm-copilot; npm run test -- --coverage; Pop-Location`, `EXIT_CODE: 0`, and `Output Summary:` stating numeric overall coverage plus numeric `src/mcp-tool-inputs.ts` line and function coverage values `>= 90`.

- [x] [P6-T5] Run the final Python formatter gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-python-black.2026-04-11T11-13.md` with `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`. If this step fails, rerun the Python QA loop from [P6-T5].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P6-T6] Run the final Python lint gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-python-ruff.2026-04-11T11-13.md` with `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`. If this step fails, rerun the Python QA loop from [P6-T5].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P6-T7] Run the final Python type-check gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-python-pyright.2026-04-11T11-13.md` with `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`. If this step fails, rerun the Python QA loop from [P6-T5].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `EXIT_CODE: 0`, and non-empty `Output Summary:`.

- [x] [P6-T8] Run the final Python coverage gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-python-pytest-coverage.2026-04-11T11-13.md` with `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing`. If this step fails, rerun the Python QA loop from [P6-T5].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` stating a numeric coverage value for `scripts/dev_tools/validate_orchestration_artifacts.py` `>= 90`.

- [x] [P6-T9] Run the final PowerShell formatter comparison gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-powershell-format-compare.2026-04-11T11-13.md` with the approved PowerShell formatter contract `mcp__drmCopilotExtension__run_poshqc_format` against the in-scope repo-root, bundled, and Pester files under `scripts/powershell/PoshQC`, `extensions/drm-copilot/resources/powershell/PoshQC`, and `tests/scripts/powershell/PoshQC`. If this step changes files or fails, rerun the PowerShell QA loop from [P6-T9].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, and non-empty `Output Summary:` while preserving the canonical evidence location.

- [x] [P6-T10] Run the final PowerShell analyzer gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-powershell-analyze.2026-04-11T11-13.md` with the approved PowerShell analyzer contract `mcp__drmCopilotExtension__run_poshqc_analyze` using scan folders `scripts/powershell/PoshQC`, `extensions/drm-copilot/resources/powershell/PoshQC`, `extensions/drm-copilot/resources/templates`, and `tests/scripts/powershell/PoshQC`. If this step changes files or fails, rerun the PowerShell QA loop from [P6-T9].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE: 0`, and non-empty `Output Summary:` while preserving the canonical evidence location.

- [x] [P6-T11] Run the final focused PowerShell coverage gate and capture `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-powershell-pester-coverage.2026-04-11T11-13.md` with the approved PowerShell test contract `mcp_drmcopilotext_run_poshqc_test` in coverage mode against `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1` and `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`, with coverage focused on `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1`, `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1`, and `scripts/powershell/PoshQC/PoshQC.Testing.psm1`. If this step changes files or fails, rerun the PowerShell QA loop from [P6-T9].
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE: 0`, and `Output Summary:` stating numeric coverage values that satisfy the repository threshold while preserving the canonical evidence location.

- [x] [P6-T12] Capture final PowerShell line-count evidence in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/final-poshqc-line-counts.2026-04-11T11-13.md` by running line-count commands for `PoshQC.psm1`, `PoshQC.FileDiscovery.psm1`, `PoshQC.Analyzer.psm1`, and `PoshQC.Testing.psm1` in both repo-root and bundled locations. (Covers REQ-4.)
  - Acceptance: The artifact exists and contains exact fields `Timestamp:`, `Command: final line-count verification for repo-root and bundled PoshQC helper modules`, `EXIT_CODE: 0`, and `Output Summary:` proving every listed production file is `<= 500` lines.

- [x] [P6-T13] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/spec.md` so the remaining unchecked acceptance criteria are checked only after [P6-T4], [P6-T8], [P6-T11], and [P6-T12] succeed. (Covers REQ-6.)
  - Acceptance: `poetry run python -c "from pathlib import Path; spec=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/spec.md').read_text(encoding='utf-8'); assert '- [x] The extension and PowerShell test suites cover the new wrapper, command wiring, MCP dispatch, and folder-selection behavior.' in spec; assert '- [x] Documentation and feature artifacts reflect the new bundled workflow and its usage.' in spec"` exits with `EXIT_CODE: 0`.

- [x] [P6-T14] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/user-story.md` so the remaining unchecked acceptance criterion is checked only after [P6-T4], [P6-T8], [P6-T11], and [P6-T12] succeed. (Covers REQ-6.)
  - Acceptance: `poetry run python -c "from pathlib import Path; story=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/user-story.md').read_text(encoding='utf-8'); assert '- [x] Tests and documentation are updated for the new bundled workflow and folder-selection behavior.' in story"` exits with `EXIT_CODE: 0`.

- [x] [P6-T15] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/policy-audit.2026-04-11T11-13.md` in place so it references the recreated evidence bundle and no longer reports the resolved blockers. (Covers REQ-6.)
  - Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/policy-audit.2026-04-11T11-13.md` exits with `EXIT_CODE: 0`.

- [x] [P6-T16] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/code-review.2026-04-11T11-13.md` in place so it references the recreated evidence bundle and no longer reports the resolved blockers. (Covers REQ-6.)
  - Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/code-review.2026-04-11T11-13.md` exits with `EXIT_CODE: 0`.

- [x] [P6-T17] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/feature-audit.2026-04-11T11-13.md` in place so it references the recreated evidence bundle and no longer reports the resolved blockers. (Covers REQ-6.)
  - Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/feature-audit.2026-04-11T11-13.md` exits with `EXIT_CODE: 0`.

- [x] [P6-T18] Update `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md` so Phase 2 tasks `[P2-T1]` through `[P2-T5]` are checked only after their corresponding `evidence/qa-gates/` artifacts exist. (Covers REQ-1 and REQ-6.)
  - Acceptance: `poetry run python -c "from pathlib import Path; t=Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md').read_text(encoding='utf-8');
for task_id in ['P2-T1','P2-T2','P2-T3','P2-T4','P2-T5']:
    assert f'- [x] [{task_id}]' in t"` exits with `EXIT_CODE: 0` only after the matching QA artifacts exist on disk.

### Phase 7 — Preflight Validation Loop

**Phase Completion Criteria:** Validation-only preflight for this exact remediation plan path ends with the exact final signal `PREFLIGHT: ALL CLEAR`.

- [x] [P7-T1] Run validation-only preflight through the `atomic_planner -> atomic_executor` route using this exact first line: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`, and record the loop transcript in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/other/preflight-loop.2026-04-11T11-13.md`.
  - Acceptance: The transcript exists and contains exact lines `Directive: DIRECTIVE: PREFLIGHT VALIDATION ONLY` and one signal line equal to either `PREFLIGHT: REVISIONS REQUIRED` or `PREFLIGHT: ALL CLEAR`.

- [x] [P7-T2] Apply only plan-text deltas requested by preflight when the signal is `PREFLIGHT: REVISIONS REQUIRED`, then rerun [P7-T1] without changing the remediation plan path. 
  - Acceptance: Whenever the transcript contains `PREFLIGHT: REVISIONS REQUIRED`, the same transcript also contains `Plan Delta:` followed by the applied edit description for this exact file path.

- [x] [P7-T3] Stop the preflight loop only when the final non-empty signal line in `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/other/preflight-loop.2026-04-11T11-13.md` is exactly `PREFLIGHT: ALL CLEAR`.
  - Acceptance: `poetry run python -c "from pathlib import Path; lines=[line.strip() for line in Path('docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/other/preflight-loop.2026-04-11T11-13.md').read_text(encoding='utf-8').splitlines() if line.strip()]; assert lines[-1] == 'PREFLIGHT: ALL CLEAR'"` exits with `EXIT_CODE: 0`.

## Test Plan

- Unit: `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`, `extensions/drm-copilot/test/mcp-server.test.ts`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1`, and the bundled-parity regression test module added in Phase 4.
- Integration: `Push-Location extensions/drm-copilot; npm run test -- --coverage; Pop-Location`, `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing`, and the focused `Invoke-Pester` coverage run for the PoshQC remediation suite.
- Manual/CLI: `Get-ChildItem docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence -Recurse`, `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit <feature-audit-path>`, the repo-root and bundled PowerShell line-count commands, and the validation-only preflight loop recorded in `evidence/other/preflight-loop.2026-04-11T11-13.md`.

## Open Questions / Notes

- This remediation plan assumes the existing TypeScript and Python production logic is functionally correct and primarily needs missing coverage plus evidence capture; if any new test reveals a functional defect, fix only the smallest touched production surface required to make the new scenario pass.
- The PowerShell helper-module filenames in Phase 4 are intentional and deterministic; do not substitute different names unless the remediation plan is revised through the preflight loop.
- The original feature plan `plan.2026-04-07T08-52.md` remains the authoritative execution checklist for the already-implemented feature; this remediation plan only reconciles its evidence-backed completion state.

## Preflight Handoff Contract

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required preflight result signals:
- `PREFLIGHT: ALL CLEAR`
- `PREFLIGHT: REVISIONS REQUIRED`

The remediation plan path for every preflight iteration is:
- `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/remediation-plan.2026-04-11T11-13.md`
