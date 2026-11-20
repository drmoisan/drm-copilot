# 2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168 — Remediation Plan

## Overview

This remediation plan addresses the post-implementation review finding that `scripts/dev_tools/validate_orchestration_artifacts.py` remains above the repository's 500-line production-file limit after the additive receipt-namespace work for issue `#168`. The remediation must preserve the current CLI contract and the reviewed behavior for policy-audit, code-review, feature-audit, and orchestrator-state validation while splitting the production logic into smaller cohesive modules and refreshing only the direct test and review artifacts that depend on that split.

## Authoritative inputs

- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-plan.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/remediation-inputs.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/issue.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`

## In-scope files

- `scripts/dev_tools/validate_orchestration_artifacts.py`
- `scripts/dev_tools/validate_orchestration_review_artifacts.py`
- `scripts/dev_tools/validate_orchestrator_state.py`
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/user-story.md`

## Out-of-scope guardrails

- Do not weaken the `delegation_receipts.promotion.*` validation contract.
- Do not change the CLI entrypoint or artifact-type names accepted by `scripts.dev_tools.validate_orchestration_artifacts`.
- Do not expand the remediation into feature-scope changes outside the oversized validator and its direct tests.
- Do not introduce suppression comments or policy exceptions to avoid the file-size limit.
- Keep remediation limited to splitting the oversized validator plus the direct test and review-document refresh work needed to prove the split.

### Phase 0 — Policy and baseline capture

- [x] [P0-T1] Read the required repository policy files and the authoritative remediation inputs in order, then write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/phase0-instructions-read.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: The feature folder inputs and repository instruction files exist at the paths listed above.
	- Acceptance: The artifact exists under `evidence/baseline/` and includes `Timestamp:`, `Policy Order:`, and an explicit ordered list covering `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/self-explanatory-code-commenting.instructions.md`, `issue.md`, `spec.md`, `user-story.md`, `remediation-inputs.2026-04-29T13-55.md`, `audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md`, `audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md`, and `audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md`.
- [x] [P0-T2] Capture the current remediation file-state baseline for the validator, direct Python tests, and review artifacts in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/remediation-file-state.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P0-T1] is complete.
	- Acceptance: The artifact exists under `evidence/baseline/`, includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the summary names the current `scripts/dev_tools/validate_orchestration_artifacts.py` line count plus the tracked remediation files.
- [x] [P0-T3] Run the baseline Black command for the Python remediation scope and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-black.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P0-T2] is complete.
	- Acceptance: The artifact exists under `evidence/baseline/`, includes `Timestamp:`, `Command: poetry run black scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --check`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T4] Run the baseline Ruff command for the Python remediation scope and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-ruff.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P0-T3] is complete.
	- Acceptance: The artifact exists under `evidence/baseline/`, includes `Timestamp:`, `Command: poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T5] Capture baseline Pyright and focused Pytest evidence for the Python remediation scope in `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-pyright.yyyy-MM-ddTHH-mm.md` and `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-pytest.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P0-T4] is complete.
	- Acceptance: Both baseline artifacts exist under `evidence/baseline/`; the Pyright artifact includes `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`; the Pytest artifact includes `Timestamp:`, `Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage values.

### Phase 1 — Extract cohesive validator modules

- [x] [P1-T1] Create `scripts/dev_tools/validate_orchestration_review_artifacts.py` and move the plan, policy-audit, code-review, and feature-audit validators plus their shared parsing helpers into that module.
	- Preconditions: [P0-T5] is complete.
	- Acceptance: `scripts/dev_tools/validate_orchestration_review_artifacts.py` exists, owns the review-artifact validation helpers previously defined in `validate_orchestration_artifacts.py`, and remains below 500 lines.
- [x] [P1-T2] Create `scripts/dev_tools/validate_orchestrator_state.py` and move the checkpoint receipt-namespace and orchestrator-state validation helpers into that module without weakening `delegation_receipts.promotion.*` validation.
	- Preconditions: [P1-T1] is complete.
	- Acceptance: `scripts/dev_tools/validate_orchestrator_state.py` exists, preserves the additive namespaced receipt behavior and legacy list compatibility, and remains below 500 lines.
- [x] [P1-T3] Update `scripts/dev_tools/validate_orchestration_artifacts.py` to remain the stable CLI entrypoint, keep the existing artifact-type names unchanged, import the extracted helpers, and reduce the entrypoint file below 500 lines.
	- Preconditions: [P1-T2] is complete.
	- Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts --help` still exposes the existing artifact-type names, and `scripts/dev_tools/validate_orchestration_artifacts.py` is below 500 lines.
- [x] [P1-T4] Update `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` only where needed so the module split preserves the current assertion set for the CLI entrypoint and the receipt-namespace validation behavior.
	- Preconditions: [P1-T3] is complete.
	- Acceptance: The targeted test file references the split layout without reducing any existing validator assertions for plan, review-artifact, or receipt-namespace behavior.
- [x] [P1-T5] Update `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` only where needed so the remediation continues to cover the validator-dependent review and guardrail contracts after the split.
	- Preconditions: [P1-T4] is complete.
	- Acceptance: The targeted guardrail-contract test file still verifies the reviewed feature behavior and references the split validator layout only when a moved import or helper path makes that necessary.

### Phase 2 — Python QA loop

- [x] [P2-T1] Run `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-black.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P1-T5] is complete.
	- Acceptance: The final-QA artifact exists under `evidence/qa-gates/` and includes `Timestamp:`, the exact Black command, `EXIT_CODE:`, and `Output Summary:`; if Black changes any file or exits non-zero, apply the formatter result and restart the QA loop at [P2-T1] before advancing.
- [x] [P2-T2] Run `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-ruff.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P2-T1] completed with a clean formatter pass.
	- Acceptance: The final-QA artifact exists under `evidence/qa-gates/` and includes `Timestamp:`, the exact Ruff command, `EXIT_CODE:`, and `Output Summary:`; if Ruff exits non-zero, fix the findings and restart the QA loop at [P2-T1] after the corrective edits.
- [x] [P2-T3] Run `poetry run pyright` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pyright.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P2-T2] completed with a clean Ruff pass.
	- Acceptance: The final-QA artifact exists under `evidence/qa-gates/` and includes `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`; if Pyright exits non-zero, fix the typing issue and restart the QA loop at [P2-T1].
- [x] [P2-T4] Run `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` and write `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pytest.yyyy-MM-ddTHH-mm.md`.
	- Preconditions: [P2-T3] completed with a clean Pyright pass.
	- Acceptance: The final-QA artifact exists under `evidence/qa-gates/`, includes `Timestamp:`, the exact Pytest command, `EXIT_CODE:`, and `Output Summary:` with numeric coverage values for the touched Python modules; if Pytest exits non-zero, fix the failing behavior and restart the QA loop at [P2-T1].

### Phase 3 — Refresh review artifacts

- [x] [P3-T1] Refresh `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md` so it removes the 500-line file-size failure when the split succeeds and cites the refreshed Python baseline and final-QA evidence.
	- Preconditions: [P2-T4] completed with a clean Pytest pass.
	- Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md` exits with code 0, and the refreshed audit records the split validator files instead of the prior 615-line failure.
- [x] [P3-T2] Refresh `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md` so its findings table and verdict reflect the split validator layout and the unchanged CLI and artifact-type contract.
	- Preconditions: [P3-T1] is complete.
	- Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md` exits with code 0, and the refreshed review no longer reports the 500-line production-file violation.
- [x] [P3-T3] Refresh `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md` and record the updated validator-dependent feature-review verification results.
	- Preconditions: [P3-T2] is complete.
	- Acceptance: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md` exits with code 0, and the refreshed feature audit references the remediated validator split and the updated Python QA evidence.
- [x] [P3-T4] Check off satisfied acceptance criteria in both `spec.md` and `user-story.md` for the `full-feature` work mode.
	- Preconditions: [P3-T3] is complete.
	- Acceptance: `user-story.md` checkbox-backed acceptance criteria reflect the delivered remediation status, and `spec.md` is reconciled according to its source format without inventing new checklist items; if `spec.md` still contains prose-only corroboration, the refreshed `audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md` explicitly records that no checkbox edits were available there while preserving the satisfied full-feature acceptance evidence.
