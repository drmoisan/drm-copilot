---
title: "Remediation Plan: 2026-03-11-expose-placeholder-commands-92 (2026-03-14T15-48)"
issue: "#92"
parent: "none"
owner: "drmoisan"
last_updated: "2026-03-14T15-48"
status: "Planned"
status_color: "blue"
version: "2.0"
work_mode: "full-feature"
mode_source: "docs/features/active/2026-03-11-expose-placeholder-commands-92/issue.md"
requirements_source: "docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-inputs.2026-03-14T15-48.md"
acceptance_source: "docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md"
research_source: "docs/features/active/2026-03-11-expose-placeholder-commands-92/research.md"
plan_path: "docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-plan.2026-03-14T15-48.md"
preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
preflight_expected_signals:
	- "PREFLIGHT: ALL CLEAR"
	- "PREFLIGHT: REVISIONS REQUIRED"
---

# Remediation Plan: 2026-03-11-expose-placeholder-commands-92 (2026-03-14T15-48)

- **Issue:** #92
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-14T15-48
- **Status:** Planned
- **Version:** 2.0
- **Work Mode:** full-feature
- **Requirements source:** `docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-inputs.2026-03-14T15-48.md`
- **Acceptance source:** `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`

## Overview

**Status Badge:** [Planned | blue]

This remediation plan closes the remaining PR-readiness gaps for feature `#92` by converting `new_potential_bug_entry.py` into the same thin-wrapper architecture used by the other bundled Python entrypoints, lifting the named Python modules to the repo’s `>= 90%` changed-module coverage bar, replacing the broad catch in the active-feature-folder I/O path, restoring cross-language coverage evidence, and removing review-scope ambiguity through deterministic documentation updates. When remediation-input requirements conflict with earlier scoping material, this plan treats `remediation-inputs.2026-03-14T15-48.md` as authoritative.

## Required References

- Copilot instructions: [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
- General coding standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General unit test policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python code change policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python unit test policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- TypeScript code change policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript unit test policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- PowerShell code change policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell unit test policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Authoritative remediation inputs: [`remediation-inputs.2026-03-14T15-48.md`](./remediation-inputs.2026-03-14T15-48.md)
- Authoritative acceptance checklist: [`user-story.md`](./user-story.md)
- Authoritative work-mode source: [`issue.md`](./issue.md)
- Existing feature plan to sync twice: [`plan.2026-03-11T21-40.md`](./plan.2026-03-11T21-40.md)
- Implementation research handoff: [`research.md`](./research.md)
- Review-scope baseline artifact: [`artifacts/pr_context.summary.txt`](../../../../artifacts/pr_context.summary.txt)

**Policy order is mandatory:** `.github/copilot-instructions.md` → `general-code-change.instructions.md` → `general-unit-test.instructions.md` → language-specific policies for Python, TypeScript, and PowerShell in scope.

## Requirements Traceability

| ID | Source | Deterministic requirement | Covered By |
|---|---|---|---|
| REQ-001 | `remediation-inputs.2026-03-14T15-48.md` item 5 | Sync `plan.2026-03-11T21-40.md` immediately after remediation-plan creation so reviewers can see that remediation is in progress without marking incomplete work done. | `P0-T3` |
| REQ-002 | `remediation-inputs.2026-03-14T15-48.md` item 1; `user-story.md` acceptance criterion 3 | Convert `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` into a thin wrapper that only sets up bundled imports and delegates to `dev_tools.new_potential_bug_entry`, while adding `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py` as the bundled logic module. | `P1-T1`, `P1-T2`, `P1-T3`, `P1-T4`, `P2-T1`, `P2-T2`, `P3-T1`, `P4-T12`, `P4-T13` |
| REQ-003 | `remediation-inputs.2026-03-14T15-48.md` item 2 | Raise coverage for `scripts/dev_tools/new_active_feature_folder_models.py`, `scripts/dev_tools/potential_to_issue_content.py`, and `scripts/dev_tools/prompt_mode_contract.py` to at least `90%` without regressing current behavior. | `P1-T5`, `P1-T6`, `P1-T7`, `P1-T8`, `P1-T9`, `P1-T10`, `P1-T11`, `P1-T12`, `P1-T13`, `P1-T14`, `P1-T15`, `P1-T16`, `P1-T17`, `P1-T18`, `P1-T19`, `P1-T20`, `P1-T21`, `P1-T22`, `P1-T23`, `P1-T24`, `P1-T25`, `P1-T26`, `P1-T27`, `P4-T12` |
| REQ-004 | `remediation-inputs.2026-03-14T15-48.md` item 3 | Replace the broad `except Exception` in both `new_active_feature_folder_io.py` copies with explicit handling that preserves the `YYYY-MM-DD` fallback behavior. | `P1-T4`, `P2-T3`, `P2-T4`, `P4-T12` |
| REQ-005 | `remediation-inputs.2026-03-14T15-48.md` item 4 | Restore comparable TypeScript, Python, and PowerShell coverage evidence with numeric baseline and post-change values plus a deterministic changed-surface explanation when changed-code coverage is not directly measurable. | `P0-T4`, `P0-T5`, `P0-T6`, `P0-T7`, `P0-T8`, `P0-T9`, `P0-T10`, `P0-T11`, `P0-T12`, `P0-T13`, `P0-T14`, `P3-T2`, `P3-T3`, `P3-T4`, `P3-T5`, `P4-T1`, `P4-T2`, `P4-T3`, `P4-T4`, `P4-T5`, `P4-T6`, `P4-T7`, `P4-T8`, `P4-T9`, `P4-T10`, `P4-T11`, `P4-T12` |
| REQ-006 | `remediation-inputs.2026-03-14T15-48.md` item 5 | Resolve PR-review ambiguity through deterministic umbrella-scope documentation tied to fresh PR-context evidence instead of silently mixing unrelated fixes into the #92 review. | `P3-T6`, `P3-T7`, `P3-T8` |
| REQ-007 | `remediation-inputs.2026-03-14T15-48.md` item 5 | Sync `plan.2026-03-11T21-40.md` again at remediation end using only evidence-backed completion state. | `P4-T14` |
| REQ-008 | `remediation-inputs.2026-03-14T15-48.md` acceptance section; `user-story.md` acceptance criterion 3 | Mark the thin-wrapper acceptance criterion complete only after the wrapper tests, Python coverage evidence, and final QA artifacts all show passing results. | `P4-T13`, `P4-T15` |
| REQ-009 | `remediation-inputs.2026-03-14T15-48.md` do-not-do section | Run TypeScript, Python, and PowerShell verification loops without skipping planned command tasks. | `P4-T1`, `P4-T2`, `P4-T3`, `P4-T4`, `P4-T5`, `P4-T6`, `P4-T7`, `P4-T8`, `P4-T9`, `P4-T10`, `P4-T11` |

## Constraints

| ID | Deterministic constraint |
|---|---|
| CON-001 | Use `docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-inputs.2026-03-14T15-48.md` as the highest-priority scope document whenever it conflicts with review summaries, older remediation artifacts, or the original plan. |
| CON-002 | Resolve work mode from `docs/features/active/2026-03-11-expose-placeholder-commands-92/issue.md`; the current authoritative marker is `- Work Mode: full-feature`. |
| CON-003 | Do not weaken coverage thresholds, relax lint rules, or replace failing evidence with unsupported substitutes. |
| CON-004 | `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` must remain an adapter-only entrypoint after remediation; business logic must live in `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`. |
| CON-005 | Reuse `docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-plan.2026-03-14T15-48.md` for every planning revision in this cycle; do not create sibling remediation-plan files. |
| CON-006 | Keep remediation file scope limited to the named Python modules, test files, evidence artifacts, review artifacts, `user-story.md`, and `plan.2026-03-11T21-40.md`. |
| SEC-001 | New or updated tests must remain deterministic: no temporary files, no network calls, no live GitHub mutations, and no hidden dependency on editor state outside the existing mocked process boundaries. |

## QC Toolchain

| Language | Baseline commands | Final QA commands |
|---|---|---|
| TypeScript | `npm --prefix extensions/drm-copilot run format`<br>`npm --prefix extensions/drm-copilot run lint`<br>`npm --prefix extensions/drm-copilot run typecheck`<br>`npm --prefix extensions/drm-copilot run test:unit -- --coverage` | `npm --prefix extensions/drm-copilot run format`<br>`npm --prefix extensions/drm-copilot run lint`<br>`npm --prefix extensions/drm-copilot run typecheck`<br>`npm --prefix extensions/drm-copilot run test:unit -- --coverage` |
| Python | `poetry run black --check .`<br>`poetry run ruff check`<br>`poetry run pyright`<br>`poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | `poetry run black .`<br>`poetry run ruff check`<br>`poetry run pyright`<br>`poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` |
| PowerShell | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`<br>`pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`<br>`pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`<br>`pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`<br>`pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs

- [x] [P0-T1] Record remediation policy order in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/other/remediation-policy-order.2026-03-14T15-48.md`
	- Tags: `CON-001`, `CON-002`, `CON-005`, `CON-006`
	- Preconditions: `issue.md` still contains `- Work Mode: full-feature`.
	- Acceptance: the artifact exists and contains `Timestamp: 2026-03-14T15-48`, `Policy Order:`, the exact ordered policy file list from the Required References section, `Mode Source: docs/features/active/2026-03-11-expose-placeholder-commands-92/issue.md`, and `Result: READY`.

- [x] [P0-T2] Record the remediation scope gate in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/other/remediation-scope-gate.2026-03-14T15-48.md`
	- Tags: `CON-001`, `CON-006`
	- Preconditions: [P0-T1]
	- Acceptance: the artifact exists and contains `Timestamp: 2026-03-14T15-48`, `Requirements Source: docs/features/active/2026-03-11-expose-placeholder-commands-92/remediation-inputs.2026-03-14T15-48.md`, `Acceptance Source: docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`, `Research Source: docs/features/active/2026-03-11-expose-placeholder-commands-92/research.md`, `Allowed Files:`, `Blocked Files: .github/instructions/**, .github/skills/**`, and `Result: PASS`.

- [x] [P0-T3] Sync `docs/features/active/2026-03-11-expose-placeholder-commands-92/plan.2026-03-11T21-40.md` immediately after remediation-plan creation
	- Tags: `REQ-001`
	- Preconditions: [P0-T2]
	- Acceptance: `plan.2026-03-11T21-40.md` contains the exact string `Remediation follow-up: \`remediation-plan.2026-03-14T15-48.md\`` in a new status note, and no incomplete remediation work is marked `[x]` in that file.

- [x] [P0-T4] Capture TypeScript formatting baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-ts-format-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T5] Capture TypeScript lint baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-ts-lint-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T4]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T6] Capture TypeScript type-check baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-ts-typecheck-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T5]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T7] Capture TypeScript coverage baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-ts-test-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T6]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric TypeScript coverage headline values.

- [x] [P0-T8] Capture Python formatting baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-python-format-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T9] Capture Python lint baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-python-lint-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T8]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T10] Capture Python type-check baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-python-typecheck-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T9]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T11] Capture Python coverage baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-python-test-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T10]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage values for `new_active_feature_folder_models.py`, `potential_to_issue_content.py`, and `prompt_mode_contract.py`.

- [x] [P0-T12] Capture PowerShell formatting baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-powershell-format-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T13] Capture PowerShell analysis baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-powershell-analyze-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T12]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P0-T14] Capture PowerShell test baseline in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/baseline/remediation-powershell-test-baseline.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T13]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:` with numeric PowerShell coverage headline values from the generated coverage artifacts.

### Phase 1 — Regression Tests & Coverage Scenarios

- [x] [P1-T1] [expect-fail] Add the red thin-wrapper delegation scenario to `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
	- Tags: `REQ-002`, `SEC-001`
	- Preconditions: [P0-T11]
	- Acceptance: `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py` contains a test named `test_main_invokes_bundled_entrypoint_and_returns_zero`, the command `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py -k main_invokes_bundled_entrypoint_and_returns_zero` exits non-zero before the wrapper refactor, and `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/regression-testing/new-potential-bug-entry-wrapper-red.2026-03-14T15-48.md` exists with `Timestamp:`, `Command:`, and `EXIT_CODE:`.

- [x] [P1-T2] Add the bundled-module import scenario to `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
	- Tags: `REQ-002`
	- Preconditions: [P1-T1]
	- Acceptance: the file contains a test named `test_imports_bundled_module` that loads `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` from disk and asserts the module exposes `main`.

- [x] [P1-T3] Add the bundled `sys.path` prepend scenario to `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
	- Tags: `REQ-002`
	- Preconditions: [P1-T1]
	- Acceptance: the file contains a test named `test_ensure_path_adds_scripts_dir_to_sys_path` that asserts `_ensure_bundled_scripts_import_path()` inserts `resources/scripts` at index `0`.

- [x] [P1-T4] [expect-fail] Capture the broad-catch Ruff regression in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/regression-testing/new-active-feature-folder-io-broad-except-red.2026-03-14T15-48.md`
	- Tags: `REQ-004`
	- Preconditions: [P0-T10]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/new_active_feature_folder_io.py extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`, `EXIT_CODE:`, and either a non-zero exit code or a `Failure:` line that cites the broad `except Exception` finding.

- [x] [P1-T5] Add the duplicate-`sys.path` guard scenario to `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
	- Tags: `REQ-002`
	- Preconditions: [P1-T1]
	- Acceptance: the file contains a test named `test_ensure_path_skips_duplicate_entry` that asserts `_ensure_bundled_scripts_import_path()` does not append a second `resources/scripts` entry.

- [x] [P1-T6] Add the `RealFileSystem.copy_tree` relative-copy scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`, `SEC-001`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_real_filesystem_copy_tree_preserves_relative_paths` that exercises `RealFileSystem.copy_tree` in `scripts/dev_tools/new_active_feature_folder_models.py`.

- [x] [P1-T7] Add the `RealFileSystem.list_files` missing-path scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`, `SEC-001`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_real_filesystem_list_files_returns_empty_for_missing_path` that exercises `RealFileSystem.list_files` in `scripts/dev_tools/new_active_feature_folder_models.py`.

- [x] [P1-T8] Add the `RealFileSystem.move` replace-existing-file scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`, `SEC-001`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_real_filesystem_move_replaces_existing_destination_file` that exercises `RealFileSystem.move` in `scripts/dev_tools/new_active_feature_folder_models.py`.

- [x] [P1-T9] Add the `resolve_workspace` source-layout scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_resolve_workspace_returns_repo_root_from_source_layout` that exercises `resolve_workspace` in `scripts/dev_tools/new_active_feature_folder_models.py`.

- [x] [P1-T10] Add the timezone-aware `get_est_timestamp` scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_get_est_timestamp_formats_timezone_aware_datetime` that exercises `get_est_timestamp` in `scripts/dev_tools/new_active_feature_folder_models.py`.

- [x] [P1-T11] Add the naive-datetime rejection scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_get_est_timestamp_rejects_naive_datetime` that exercises the `ValueError` branch in `get_est_timestamp`.

- [x] [P1-T12] Add the `extract_date_from_timestamp` scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_extract_date_from_timestamp_returns_prefix_before_T` that exercises `extract_date_from_timestamp` in `scripts/dev_tools/new_active_feature_folder_models.py`.

- [x] [P1-T13] Add the valid feature-name scenario to `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_validate_feature_name_accepts_kebab_and_underscore_case` that exercises the non-error path in `validate_feature_name`.

- [x] [P1-T14] Add the `build_bug_body` heading-order scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`, `SEC-001`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_build_bug_body_preserves_canonical_heading_order` that exercises `build_bug_body` in `scripts/dev_tools/potential_to_issue_content.py`.

- [x] [P1-T15] Add the bootstrapped minor-audit eligibility scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_evaluate_minor_audit_eligibility_accepts_bootstrapped_keyword` that exercises `evaluate_minor_audit_eligibility` in `scripts/dev_tools/potential_to_issue_content.py`.

- [x] [P1-T16] Add the production-file overflow minor-audit scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_evaluate_minor_audit_eligibility_rejects_more_than_three_production_files` that exercises the overflow branch in `evaluate_minor_audit_eligibility`.

- [x] [P1-T17] Add the invalid-JSON `extract_last_updated` scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_extract_last_updated_returns_none_for_invalid_json` that exercises `extract_last_updated` in `scripts/dev_tools/potential_to_issue_content.py`.

- [x] [P1-T18] Add the non-string `updatedAt` scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_extract_last_updated_returns_none_for_non_string_updated_at` that exercises `extract_last_updated` in `scripts/dev_tools/potential_to_issue_content.py`.

- [x] [P1-T19] Add the invalid-ISO timestamp scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_extract_last_updated_returns_none_for_invalid_iso_timestamp` that exercises the `ValueError` branch in `extract_last_updated`.

- [x] [P1-T20] Add the metadata insertion scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_update_metadata_lines_inserts_missing_issue_url_last_updated_and_status` that exercises `update_metadata_lines` in `scripts/dev_tools/potential_to_issue_content.py`.

- [x] [P1-T21] Add the punctuation-normalization scenario to `tests/scripts/dev_tools/test_potential_to_issue_content.py`
	- Tags: `REQ-003`, `SEC-001`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_normalize_smart_punctuation_replaces_all_mapped_characters` that exercises `normalize_smart_punctuation` in `scripts/dev_tools/potential_to_issue_content.py`.

- [x] [P1-T22] Add the unchanged minor-audit normalization scenario to `tests/scripts/dev_tools/test_prompt_mode_contract.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: `tests/scripts/dev_tools/test_prompt_mode_contract.py` contains a test named `test_normalize_requested_work_mode_returns_minor_audit_unchanged` that exercises `normalize_requested_work_mode` in `scripts/dev_tools/prompt_mode_contract.py`.

- [x] [P1-T23] Add the feature-mode normalization scenario to `tests/scripts/dev_tools/test_prompt_mode_contract.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_normalize_requested_work_mode_accepts_full_feature_for_feature_work` that exercises `normalize_requested_work_mode` with `requested_mode="full-feature"` and `promotion_type="feature"`.

- [x] [P1-T24] Add the legacy full-to-bug normalization scenario to `tests/scripts/dev_tools/test_prompt_mode_contract.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_normalize_requested_work_mode_maps_legacy_full_to_full_bug_for_bug_work` that exercises `normalize_requested_work_mode` with `requested_mode="full"` and `promotion_type="bug"`.

- [x] [P1-T25] Add the invalid `full-bug` feature-work scenario to `tests/scripts/dev_tools/test_prompt_mode_contract.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_normalize_requested_work_mode_rejects_full_bug_for_feature_work` that exercises the incompatible-usage branch in `normalize_requested_work_mode`.

- [x] [P1-T26] Add the invalid `full-feature` bug-work scenario to `tests/scripts/dev_tools/test_prompt_mode_contract.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains a test named `test_normalize_requested_work_mode_rejects_full_feature_for_bug_work` that exercises the incompatible-usage branch in `normalize_requested_work_mode`.

- [x] [P1-T27] Add the fallback-reason detail scenarios to `tests/scripts/dev_tools/test_prompt_mode_contract.py`
	- Tags: `REQ-003`
	- Preconditions: [P0-T11]
	- Acceptance: the file contains tests named `test_build_fallback_reason_returns_none_for_valid_marker`, `test_build_fallback_reason_describes_legacy_full_normalization`, and `test_build_fallback_reason_describes_malformed_marker` that exercise the uncovered branches in `build_fallback_reason`.

### Phase 2 — Code Remediation

- [x] [P2-T1] Add the bundled logic module `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`
	- Tags: `REQ-002`, `CON-004`
	- Preconditions: [P1-T1], [P1-T2], [P1-T3], [P1-T5]
	- Acceptance: `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py` exists, defines `create_bug_entry`, `parse_args`, and `main`, and preserves the bundled `--template-root` workflow used by `drmCopilotExtension.newPotentialBugEntry`.

- [x] [P2-T2] Replace `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` with a thin wrapper
	- Tags: `REQ-002`, `CON-004`
	- Preconditions: [P2-T1]
	- Acceptance: `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` contains `_ensure_bundled_scripts_import_path()`, imports `importlib`, calls `importlib.import_module("dev_tools.new_potential_bug_entry")` inside `main()`, and does not define `create_bug_entry`, `render_content`, `validate_short_name`, `FileSystem`, or `RealFileSystem`.

- [x] [P2-T3] Replace the broad catch in `scripts/dev_tools/new_active_feature_folder_io.py`
	- Tags: `REQ-004`
	- Preconditions: [P1-T4]
	- Acceptance: `scripts/dev_tools/new_active_feature_folder_io.py` no longer contains `except Exception:` in `default_issue_fetcher`, and the `updated_date == "YYYY-MM-DD"` fallback still occurs only for the intended invalid `updatedAt` states.

- [x] [P2-T4] Mirror the explicit `updatedAt` handling in `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
	- Tags: `REQ-004`
	- Preconditions: [P2-T3]
	- Acceptance: `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py` no longer contains `except Exception:` in `default_issue_fetcher`, and the `updated_date == "YYYY-MM-DD"` fallback behavior matches the repo-root source file.

### Phase 3 — Evidence Restoration & Review Scope

- [x] [P3-T1] Record thin-wrapper parity in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/new-potential-bug-entry-wrapper-parity.2026-03-14T15-48.md`
	- Tags: `REQ-002`
	- Preconditions: [P2-T1], [P2-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Compared Files:`, `Template Delegates To: dev_tools.new_potential_bug_entry`, `Bundled Module Exists: yes`, `Template Logic Symbols Present: none`, and `Result: PASS`.

- [x] [P3-T2] Capture TypeScript post-change coverage evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-ts-test-post-change.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P2-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric TypeScript coverage headline values.

- [x] [P3-T3] Capture Python post-change coverage evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-python-test-post-change.2026-03-14T15-48.md`
	- Tags: `REQ-003`, `REQ-005`
	- Preconditions: [P2-T4]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage values for `new_active_feature_folder_models.py`, `potential_to_issue_content.py`, `prompt_mode_contract.py`, and `new_active_feature_folder_io.py`.

- [x] [P3-T4] Capture PowerShell post-change coverage evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-powershell-test-post-change.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P2-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:` with numeric PowerShell coverage headline values.

- [x] [P3-T5] Write the cross-language coverage matrix in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-coverage-matrix.2026-03-14T15-48.md`
	- Tags: `REQ-005`
	- Preconditions: [P0-T7], [P0-T11], [P0-T14], [P3-T2], [P3-T3], [P3-T4]
	- Acceptance: the artifact exists and contains `Timestamp:`, `TypeScript Baseline Coverage:`, `TypeScript Post-Change Coverage:`, `TypeScript Changed-Surface Substitute: no TypeScript production-file changes in remediation`, `Python Baseline Coverage:`, `Python Post-Change Coverage:`, `Python Module Coverage: new_active_feature_folder_models.py`, `Python Module Coverage: potential_to_issue_content.py`, `Python Module Coverage: prompt_mode_contract.py`, `PowerShell Baseline Coverage:`, `PowerShell Post-Change Coverage:`, `PowerShell Changed-Surface Substitute: no PowerShell production-file changes in remediation`, and `Result: PASS`.

- [x] [P3-T6] Refresh `artifacts/pr_context.summary.txt` for the current branch scope
	- Tags: `REQ-006`
	- Preconditions: [P0-T2]
	- Acceptance: `artifacts/pr_context.summary.txt` contains the exact lines `Base ref (requested): origin/development`, `Head ref (resolved): feature/expose-placeholder-commands-92`, and `Range: 026c449ed838cd77dd0841207fb165a647f1ad43..88100e2a0f8718bfe0ef53e3efbd5c9787591806`.

- [x] [P3-T7] Write the umbrella-scope map in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/other/review-scope-map.2026-03-14T15-48.md`
	- Tags: `REQ-006`
	- Preconditions: [P3-T6]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Scope Decision: umbrella review scope`, `Primary Feature: #92`, `Out-of-Feature Commits:`, and exact list entries for `#94`, `#96`, and `#99` with a mapped evidence path for each item.

- [x] [P3-T8] Update `docs/features/active/2026-03-11-expose-placeholder-commands-92/code-review.2026-03-14T15-48.md` with the resolved scope decision
	- Tags: `REQ-006`
	- Preconditions: [P3-T7]
	- Acceptance: `code-review.2026-03-14T15-48.md` contains the exact line `Review scope decision: umbrella review scope documented in evidence/other/review-scope-map.2026-03-14T15-48.md`.

### Phase 4 — Final QA & Synchronization

Executor rule: restart this phase from [P4-T1] whenever a formatting step changes files or any later QA command fails.

- [x] [P4-T1] Capture final TypeScript formatting evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-ts-format-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P3-T8]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T2] Capture final TypeScript lint evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-ts-lint-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P4-T1]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T3] Capture final TypeScript type-check evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-ts-typecheck-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P4-T2]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T4] Capture final TypeScript coverage evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-ts-test-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P4-T3]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE: 0`, and `Output Summary:` with numeric TypeScript coverage headline values.

- [x] [P4-T5] Capture final Python formatting evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-python-format-final.2026-03-14T15-48.md`
	- Tags: `REQ-003`, `REQ-005`, `REQ-009`
	- Preconditions: [P3-T5]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run black .`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T6] Capture final Python lint evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-python-lint-final.2026-03-14T15-48.md`
	- Tags: `REQ-003`, `REQ-005`, `REQ-009`
	- Preconditions: [P4-T5]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run ruff check`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T7] Capture final Python type-check evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-python-typecheck-final.2026-03-14T15-48.md`
	- Tags: `REQ-003`, `REQ-005`, `REQ-009`
	- Preconditions: [P4-T6]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T8] Capture final Python coverage evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-python-test-final.2026-03-14T15-48.md`
	- Tags: `REQ-003`, `REQ-005`, `REQ-009`
	- Preconditions: [P4-T7]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`, `EXIT_CODE: 0`, and `Output Summary:` with numeric coverage values for `new_active_feature_folder_models.py`, `potential_to_issue_content.py`, `prompt_mode_contract.py`, and `new_active_feature_folder_io.py`.

- [x] [P4-T9] Capture final PowerShell formatting evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-powershell-format-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P3-T5]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T10] Capture final PowerShell analysis evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-powershell-analyze-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P4-T9]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P4-T11] Capture final PowerShell test evidence in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-powershell-test-final.2026-03-14T15-48.md`
	- Tags: `REQ-005`, `REQ-009`
	- Preconditions: [P4-T10]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`, `EXIT_CODE: 0`, and `Output Summary:` with numeric PowerShell coverage headline values.

- [x] [P4-T12] Verify remediation thresholds in `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/qa-gates/remediation-threshold-verification.2026-03-14T15-48.md`
	- Tags: `REQ-002`, `REQ-003`, `REQ-004`, `REQ-005`
	- Preconditions: [P3-T1], [P4-T4], [P4-T8], [P4-T11]
	- Acceptance: the artifact exists and contains `Timestamp:`, `Wrapper Criterion: PASS`, `Python Module Coverage: new_active_feature_folder_models.py >= 90%`, `Python Module Coverage: potential_to_issue_content.py >= 90%`, `Python Module Coverage: prompt_mode_contract.py >= 90%`, `Broad Catch Present: no`, `TypeScript Coverage Evidence: complete`, `Python Coverage Evidence: complete`, `PowerShell Coverage Evidence: complete`, and `Result: PASS`.

- [x] [P4-T13] Sync `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md` after verification
	- Tags: `REQ-002`, `REQ-008`
	- Preconditions: [P4-T12]
	- Acceptance: `user-story.md` changes the exact acceptance-criteria line `- [ ] Wrapper templates follow the same thin-adapter pattern as \`collect_pr_context.py\` and \`push_down_copilot_customizations.py\`` to `[x]` only when `evidence/qa-gates/new-potential-bug-entry-wrapper-parity.2026-03-14T15-48.md` and `evidence/qa-gates/remediation-threshold-verification.2026-03-14T15-48.md` both contain `Result: PASS`.

- [x] [P4-T14] Sync `docs/features/active/2026-03-11-expose-placeholder-commands-92/plan.2026-03-11T21-40.md` after remediation verification
	- Tags: `REQ-007`
	- Preconditions: [P4-T12], [P4-T13]
	- Acceptance: `plan.2026-03-11T21-40.md` contains the exact string `Remediation verification complete: remediation-plan.2026-03-14T15-48.md`, and only remediation items backed by the fresh evidence artifacts from this plan are marked complete.

- [x] [P4-T15] Update `docs/features/active/2026-03-11-expose-placeholder-commands-92/feature-audit.2026-03-14T15-48.md` with the restored wrapper result
	- Tags: `REQ-008`
	- Preconditions: [P4-T12], [P4-T13]
	- Acceptance: `feature-audit.2026-03-14T15-48.md` contains the exact line `- PASS: criterion 3 (Wrapper templates follow the same thin-adapter pattern as collect_pr_context.py and push_down_copilot_customizations.py)`.

## Test Plan

- Wrapper regression red phase: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py -k main_invokes_bundled_entrypoint_and_returns_zero`
- Wrapper green verification: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
- Targeted Python coverage additions: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py tests/scripts/dev_tools/test_potential_to_issue_content.py tests/scripts/dev_tools/test_prompt_mode_contract.py tests/scripts/dev_tools/test_new_potential_bug_entry.py`
- Targeted lint regression evidence: `poetry run ruff check scripts/dev_tools/new_active_feature_folder_io.py extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
- TypeScript full QA: `npm --prefix extensions/drm-copilot run format`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- Python full QA: `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- PowerShell full QA: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`, `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`, `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

## Open Questions / Notes

- This remediation plan intentionally chooses the deterministic documentation path for review-scope ambiguity; it does not require branch restacking to complete the #92 remediation.
- No `.env` file is required for this remediation scope.
- TypeScript changed-surface coverage is documented through overall coverage plus targeted extension test evidence because this remediation does not require TypeScript production-file edits.
- PowerShell changed-surface coverage is documented through no-regression overall coverage because this remediation does not require PowerShell production-file edits.
- Downstream preflight validation must use `DIRECTIVE: PREFLIGHT VALIDATION ONLY` and may only report `PREFLIGHT: ALL CLEAR` or `PREFLIGHT: REVISIONS REQUIRED`.
