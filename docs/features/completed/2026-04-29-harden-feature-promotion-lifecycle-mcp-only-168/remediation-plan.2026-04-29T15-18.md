---
title: "2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168-remediation"
issue: 168
owner: "atomic_planner"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-29T15-18"
source_of_truth:
  - "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md"
  - "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md"
  - "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-inputs.2026-04-29T15-18.md"
review_inputs:
  - "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md"
  - "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md"
  - "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md"
plan_path: "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-plan.2026-04-29T15-18.md"
work_mode_source: "docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
---

# Atomic Remediation Plan — Feature #168

## Overview

This remediation plan addresses the rerun findings recorded at `2026-04-29T15-18`: `scripts/dev_tools/validate_orchestration_review_artifacts.py` still exceeds the repository 500-line production-file limit, and the Python split-validator coverage evidence remains below the repository 90% target for new production modules. The remediation must preserve the MCP-only feature behavior, keep `scripts.dev_tools.validate_orchestration_artifacts` as the stable CLI entrypoint, and retain the additive `delegation_receipts.promotion.*` validation path.

## Deterministic Inputs

- Repository root: `c:\Users\DanMoisan\repos\drm-copilot`
- Target plan path: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-plan.2026-04-29T15-18.md`
- Authoritative remediation scope: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-inputs.2026-04-29T15-18.md`
- Authoritative review context:
  - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md`
  - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md`
  - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md`
- Work-mode source: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/issue.md`
- Acceptance-criteria sources for `full-feature` mode:
  - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
  - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`
- Canonical feature evidence root: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/`
- New Python production helper module planned by this remediation: `scripts/dev_tools/validate_policy_audit_artifact.py`
- New Python test modules planned by this remediation:
  - `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py`
  - `tests/scripts/dev_tools/test_validate_orchestrator_state.py`

## In-Scope Remediation Findings

| Ref | Summary |
|---|---|
| R-1 | Reduce `scripts/dev_tools/validate_orchestration_review_artifacts.py` below 500 lines without changing the public CLI entrypoint or artifact-type names. |
| R-2 | Raise the coverage evidence for the split Python validator modules to the repository 90% target for new production modules. |
| R-3 | Re-verify the live `orchestrator-state` CLI path and refresh the review artifacts so the rerun package reports the corrected file-size and coverage status. |

## Deterministic Constraints

- Do not modify `.github/instructions/*.md` files.
- Do not weaken or remove the `delegation_receipts.promotion.*` validation contract.
- Do not change the public artifact-type names accepted by `scripts.dev_tools.validate_orchestration_artifacts`.
- Do not introduce suppressions or policy exceptions to avoid the file-size or coverage findings.
- Every evidence artifact named in this plan must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Every baseline and final-QA coverage artifact must record numeric coverage values for each Python production module named in the command scope.
- Use these exact baseline Python commands from the repository root:
  - `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
  - `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
  - `poetry run pyright`
  - `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`
- Use these exact final-QA Python commands from the repository root after the new helper and test modules are added:
  - `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_policy_audit_artifact.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
  - `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_policy_audit_artifact.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
  - `poetry run pyright`
  - `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_policy_audit_artifact --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`
- Use this exact baseline line-count command from the repository root:
  - `pwsh -NoProfile -Command "foreach ($path in @('scripts/dev_tools/validate_orchestration_artifacts.py','scripts/dev_tools/validate_orchestration_review_artifacts.py','scripts/dev_tools/validate_orchestrator_state.py')) { $count = (Get-Content -Path $path).Count; Write-Output (\"$path`t$count\") }"`
- Use this exact post-refactor line-count command from the repository root:
  - `pwsh -NoProfile -Command "foreach ($path in @('scripts/dev_tools/validate_orchestration_artifacts.py','scripts/dev_tools/validate_orchestration_review_artifacts.py','scripts/dev_tools/validate_policy_audit_artifact.py','scripts/dev_tools/validate_orchestrator_state.py')) { $count = (Get-Content -Path $path).Count; Write-Output (\"$path`t$count\") }"`
- Use these exact review-refresh validation commands from the repository root:
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json`
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md`
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md`
  - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md`
  - `mcp_drmcopilotext_collect_pr_context base=development`
- If any final-QA step fails or changes files, restart the Python QA loop from `P3-T1`.

### Phase 0 — Context & Baseline Evidence

- [x] [P0-T1] Create the feature evidence directories `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/regression-testing/`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/other/`, and `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/issue-updates/`.
  - Acceptance: All five directories exist at the exact paths named in this task.

- [x] [P0-T2] Read the required policy and context files in this exact order and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/phase0-instructions-read.2026-04-29T15-18.md`: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `.github/instructions/tonality.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/issue.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-inputs.2026-04-29T15-18.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md`, `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md`, and `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`.
    - The artifact contains `Policy Order:`.
    - The artifact lists each file path in the exact order named in this task.

- [x] [P0-T3] Write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/p0-t3.work-mode-and-ac-source.2026-04-29T15-18.md` recording that `issue.md` contains `- Work Mode: full-feature`, that `spec.md` and `user-story.md` are the authoritative acceptance-criteria sources, and that final acceptance reporting must summarize both files without inventing new checkbox items.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Resolved Work Mode: full-feature`.
    - The artifact contains `Acceptance Criteria Sources:` followed by the exact `spec.md` and `user-story.md` paths from this feature folder.
    - The artifact contains `Checkbox Rule: update only pre-existing unchecked acceptance checkboxes after verification; do not add or rewrite criteria text`.

- [x] [P0-T4] Capture the baseline line-count evidence in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/p0-t4.python-line-count.2026-04-29T15-18.md` by running `pwsh -NoProfile -Command "foreach ($path in @('scripts/dev_tools/validate_orchestration_artifacts.py','scripts/dev_tools/validate_orchestration_review_artifacts.py','scripts/dev_tools/validate_orchestrator_state.py')) { $count = (Get-Content -Path $path).Count; Write-Output (\"$path`t$count\") }"`.
  - Acceptance:
    - The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
    - `Output Summary:` records numeric line counts for the three exact paths named in the command.
    - `Output Summary:` identifies `scripts/dev_tools/validate_orchestration_review_artifacts.py` as the only baseline file above 500 lines if the current finding still reproduces.

- [x] [P0-T5] Capture the baseline Python formatting-check result in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/p0-t5.python-format-check.2026-04-29T15-18.md` by running `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.
  - Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T6] Capture the baseline Python lint result in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/p0-t6.python-lint.2026-04-29T15-18.md` by running `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.
  - Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T7] Capture the baseline Python type-check result in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/p0-t7.python-typecheck.2026-04-29T15-18.md` by running `poetry run pyright`.
  - Acceptance: The artifact contains exact fields `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and non-empty `Output Summary:`.

- [x] [P0-T8] Capture the baseline focused Python coverage result in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/p0-t8.python-coverage.2026-04-29T15-18.md` by running `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`.
  - Acceptance:
    - The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
    - `Output Summary:` contains numeric coverage values for `scripts.dev_tools.validate_orchestration_artifacts`, `scripts.dev_tools.validate_orchestration_review_artifacts`, and `scripts.dev_tools.validate_orchestrator_state`.
    - `Output Summary:` records that `validate_orchestration_review_artifacts.py` and `validate_orchestrator_state.py` are below 90% if the baseline finding still reproduces.

### Phase 1 — File-Size Remediation

- [x] [P1-T1] Write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/other/p1-t1.review-validator-split-note.2026-04-29T15-18.md` documenting the extraction plan for `scripts/dev_tools/validate_orchestration_review_artifacts.py`, including the exact destination module `scripts/dev_tools/validate_policy_audit_artifact.py` and the functions being moved.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Destination Module: scripts/dev_tools/validate_policy_audit_artifact.py`.
    - The artifact lists `validate_policy_audit_substantive_requirements` and `validate_policy_audit_text` plus the policy-audit parsing helpers as moved symbols.

- [x] [P1-T2] Create `scripts/dev_tools/validate_policy_audit_artifact.py` and move the policy-audit parsing helpers `_has_numeric_coverage`, `_is_na_value`, `_has_placeholder_marker`, `_extract_policy_audit_coverage_rows`, `_find_policy_audit_checklist_line`, `_extract_policy_audit_comparison_lines`, and `_comparison_line_has_labelled_percentage` into that module.
  - Acceptance:
    - `scripts/dev_tools/validate_policy_audit_artifact.py` exists.
    - The exact seven helper function names named in this task exist in `scripts/dev_tools/validate_policy_audit_artifact.py`.
    - `scripts/dev_tools/validate_orchestration_review_artifacts.py` no longer defines any of those seven helper functions.

- [x] [P1-T3] Move `validate_policy_audit_substantive_requirements` and `validate_policy_audit_text` into `scripts/dev_tools/validate_policy_audit_artifact.py` without changing their public return contract.
  - Acceptance:
    - `scripts/dev_tools/validate_policy_audit_artifact.py` defines `validate_policy_audit_substantive_requirements` and `validate_policy_audit_text`.
    - `scripts/dev_tools/validate_orchestration_review_artifacts.py` no longer defines either function name.
    - Both moved functions still return `list[str]`.

- [x] [P1-T4] Update `scripts/dev_tools/validate_orchestration_review_artifacts.py` so it imports and re-exports `validate_policy_audit_text` from `scripts/dev_tools/validate_policy_audit_artifact.py` while retaining the code-review and feature-audit validators locally.
  - Acceptance:
    - `scripts/dev_tools/validate_orchestration_review_artifacts.py` contains an import for `validate_policy_audit_text` from `scripts.dev_tools.validate_policy_audit_artifact` or the equivalent absolute project import path.
    - `scripts/dev_tools/validate_orchestration_review_artifacts.py` still defines `validate_code_review_text` and `validate_feature_audit_text`.
    - `scripts/dev_tools/validate_orchestration_review_artifacts.py` remains below 500 lines after the edit.

- [x] [P1-T5] Update `scripts/dev_tools/validate_orchestration_artifacts.py` so the stable CLI entrypoint continues to dispatch the existing `policy-audit`, `code-review`, `feature-audit`, and `orchestrator-state` artifact types through the split modules without renaming any artifact-type strings.
  - Acceptance:
    - `scripts/dev_tools/validate_orchestration_artifacts.py` still contains the exact artifact-type strings `policy-audit`, `code-review`, `feature-audit`, and `orchestrator-state`.
    - The entrypoint imports `validate_policy_audit_text` from the split-module path and `validate_orchestrator_state_text` from `scripts.dev_tools.validate_orchestrator_state`.

- [x] [P1-T6] Capture the post-refactor line-count evidence in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/other/p1-t6.post-refactor-line-count.2026-04-29T15-18.md` by running `pwsh -NoProfile -Command "foreach ($path in @('scripts/dev_tools/validate_orchestration_artifacts.py','scripts/dev_tools/validate_orchestration_review_artifacts.py','scripts/dev_tools/validate_policy_audit_artifact.py','scripts/dev_tools/validate_orchestrator_state.py')) { $count = (Get-Content -Path $path).Count; Write-Output (\"$path`t$count\") }"`.
  - Acceptance:
    - The artifact contains exact fields `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
    - `Output Summary:` records numeric line counts for the four exact paths named in the command.
    - No recorded line count exceeds `499`.

### Phase 2 — Python Coverage Remediation

- [x] [P2-T1] Add `test_extract_policy_audit_coverage_rows_ignores_nonseven_cell_rows` to `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` so the coverage-row parser rejects malformed table rows without treating them as coverage evidence.
  - Acceptance: `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` contains a test function named exactly `test_extract_policy_audit_coverage_rows_ignores_nonseven_cell_rows`.

- [x] [P2-T2] Add `test_extract_policy_audit_coverage_rows_ignores_separator_language_rows` to `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` so the parser skips dashed separator rows instead of reporting them as a language entry.
  - Acceptance: `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` contains a test function named exactly `test_extract_policy_audit_coverage_rows_ignores_separator_language_rows`.

- [x] [P2-T3] Add `test_validate_policy_audit_substantive_requirements_rejects_missing_coverage_table_rows` to `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` so the validator reports a missing coverage metrics table when only the headings and checklist are present.
  - Acceptance: `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` contains a test function named exactly `test_validate_policy_audit_substantive_requirements_rejects_missing_coverage_table_rows`.

- [x] [P2-T4] Add `test_validate_policy_audit_substantive_requirements_rejects_comparison_line_missing_change_text` to `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` so the validator reports the missing `Change:` label in a per-language comparison line.
  - Acceptance: `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` contains a test function named exactly `test_validate_policy_audit_substantive_requirements_rejects_comparison_line_missing_change_text`.

- [x] [P2-T5] Add `test_validate_policy_audit_substantive_requirements_rejects_comparison_line_missing_evidence_reference` to `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` so the validator reports a comparison line that omits `Evidence:`.
  - Acceptance: `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` contains a test function named exactly `test_validate_policy_audit_substantive_requirements_rejects_comparison_line_missing_evidence_reference`.

- [x] [P2-T6] Add `test_validate_policy_audit_substantive_requirements_allows_na_new_code_without_percentage` to `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` so `N/A` new-code coverage rows do not require a numeric `New/changed-code coverage:` comparison value.
  - Acceptance: `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py` contains a test function named exactly `test_validate_policy_audit_substantive_requirements_allows_na_new_code_without_percentage`.

- [x] [P2-T7] Add `test_validate_list_delegation_receipts_rejects_non_object_entry` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so the legacy list validator rejects scalar receipt items.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_list_delegation_receipts_rejects_non_object_entry`.

- [x] [P2-T8] Add `test_validate_namespaced_delegation_receipts_rejects_unsupported_top_level_key` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so the namespaced validator rejects object keys outside `promotion`.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_namespaced_delegation_receipts_rejects_unsupported_top_level_key`.

- [x] [P2-T9] Add `test_validate_namespaced_delegation_receipts_rejects_non_object_promotion_namespace` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so the validator rejects `delegation_receipts.promotion` values that are not objects.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_namespaced_delegation_receipts_rejects_non_object_promotion_namespace`.

- [x] [P2-T10] Add `test_validate_orchestrator_state_text_rejects_invalid_step_status` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so invalid lifecycle status strings produce a checkpoint error.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_orchestrator_state_text_rejects_invalid_step_status`.

- [x] [P2-T11] Add `test_validate_orchestrator_state_text_rejects_invalid_blocked_reason` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so unsupported `blocked_reason` values fail validation.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_orchestrator_state_text_rejects_invalid_blocked_reason`.

- [x] [P2-T12] Add `test_validate_orchestrator_state_text_require_complete_rejects_non_none_blocked_reason` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so completion-mode validation rejects a checkpoint whose `blocked_reason` is not `none`.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_orchestrator_state_text_require_complete_rejects_non_none_blocked_reason`.

- [x] [P2-T13] Add `test_validate_orchestrator_state_text_rejects_malformed_json` to `tests/scripts/dev_tools/test_validate_orchestrator_state.py` so malformed checkpoint JSON produces the explicit JSON-parse error message.
  - Acceptance: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` contains a test function named exactly `test_validate_orchestrator_state_text_rejects_malformed_json`.

### Phase 3 — Final Python QA, Review Refresh, and Acceptance Tracking

- [x] [P3-T1] Run `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_policy_audit_artifact.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t1.python-black.2026-04-29T15-18.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`, the exact Black command, `EXIT_CODE:`, and `Output Summary:`.
    - If Black changes any file or exits non-zero, restart the Python QA loop at `P3-T1` after applying the formatter result.

- [x] [P3-T2] Run `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_policy_audit_artifact.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t2.python-ruff.2026-04-29T15-18.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`, the exact Ruff command, `EXIT_CODE:`, and `Output Summary:`.
    - If Ruff exits non-zero, fix the findings and restart the Python QA loop at `P3-T1`.

- [x] [P3-T3] Run `poetry run pyright` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t3.python-pyright.2026-04-29T15-18.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
    - If Pyright exits non-zero, fix the typing issue and restart the Python QA loop at `P3-T1`.

- [x] [P3-T4] Run `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_policy_audit_artifact --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t4.python-pytest.2026-04-29T15-18.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`, the exact Pytest command, `EXIT_CODE:`, and `Output Summary:`.
    - `Output Summary:` records numeric coverage values for `scripts.dev_tools.validate_orchestration_artifacts`, `scripts.dev_tools.validate_orchestration_review_artifacts`, `scripts.dev_tools.validate_policy_audit_artifact`, and `scripts.dev_tools.validate_orchestrator_state`.
    - If Pytest exits non-zero, fix the failing behavior and restart the Python QA loop at `P3-T1`.

- [x] [P3-T5] Write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t5.python-coverage-comparison.2026-04-29T15-18.md` comparing the numeric baseline coverage from `p0-t8.python-coverage.2026-04-29T15-18.md` against the final results from `p3-t4.python-pytest.2026-04-29T15-18.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Baseline Coverage:` and `Post-Change Coverage:` for `validate_orchestration_review_artifacts.py`, `validate_policy_audit_artifact.py`, and `validate_orchestrator_state.py`.
    - The artifact contains `Threshold Verdict: pass` only if each named Python production module is `>= 90%`.

- [x] [P3-T6] Run `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t6.orchestrator-state-validation.2026-04-29T15-18.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json`, `EXIT_CODE: 0`, and `Output Summary:`.
    - `Output Summary:` states that the live checkpoint still accepts the additive `delegation_receipts.promotion.*` namespace.

- [x] [P3-T7] Run `mcp_drmcopilotext_collect_pr_context` with `base=development` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t7.pr-context-refresh.2026-04-29T15-18.md` summarizing the refreshed PR-context artifacts used for the rerun review package.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: mcp_drmcopilotext_collect_pr_context base=development`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` names `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` as the refreshed review inputs.

- [x] [P3-T8] Refresh `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md` so it reports the resolved file-size evidence, the refreshed Python coverage numbers, and the current merge-gate status.
  - Acceptance:
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md` cites `p1-t6.post-refactor-line-count.2026-04-29T15-18.md`, `p3-t4.python-pytest.2026-04-29T15-18.md`, and `p3-t5.python-coverage-comparison.2026-04-29T15-18.md`.
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md` exits with code `0`.

- [x] [P3-T9] Refresh `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md` so its findings table reflects the corrected file-size and coverage status for the split Python validators.
  - Acceptance:
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md` cites `p1-t6.post-refactor-line-count.2026-04-29T15-18.md` and `p3-t4.python-pytest.2026-04-29T15-18.md`.
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md` exits with code `0`.

- [x] [P3-T10] Refresh `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md` so it references the remediated validator evidence and the current acceptance status against `spec.md` and `user-story.md`.
  - Acceptance:
    - `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md` cites `p3-t4.python-pytest.2026-04-29T15-18.md`, `p3-t5.python-coverage-comparison.2026-04-29T15-18.md`, and `p3-t6.orchestrator-state-validation.2026-04-29T15-18.md`.
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md` exits with code `0`.

- [x] [P3-T11] Write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t11.acceptance-criteria-status.2026-04-29T15-18.md` summarizing acceptance-criteria status from `spec.md` and `user-story.md`, and update only any pre-existing unchecked acceptance checkboxes that this remediation verifies as newly satisfied.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains the heading `### Acceptance Criteria Status`.
    - The artifact contains `Source: docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md; docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`.
    - The artifact contains numeric `Total AC items:`, `Checked off (delivered):`, and `Remaining (unchecked):` fields.
    - If no checkbox change is required, the artifact states `Checkbox Updates: none required; authoritative sources were already reconciled`.

## Executor Preflight Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required success signal: `PREFLIGHT: ALL CLEAR`
- Required validator gate: `mcp_drmcopilotext_validate_orchestration_artifacts artifact_type=plan artifact_path=docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-plan.2026-04-29T15-18.md`
- Revalidation rule: If the executor returns `PREFLIGHT: REVISIONS REQUIRED`, revise this exact file in place and repeat preflight on the same `plan_path`.
