# Remediation Inputs — 2026-04-29T13-55

## Source review artifacts

- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/feature-audit.2026-04-29T13-55.md`

## Enumerated fix list

1. **Split the oversized Python validator into smaller cohesive production files**
	 - **Files:** `scripts/dev_tools/validate_orchestration_artifacts.py` and any new helper module(s) needed under `scripts/dev_tools/`
	 - **Expected behavior:** The validator must preserve the existing CLI behavior, artifact-type names, additive `delegation_receipts.promotion.*` support, and legacy list compatibility while bringing every touched production file below the 500-line repository limit.
	 - **Verification commands:**
		 - `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py [new helper files] tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --check`
		 - `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py [new helper files] tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
		 - `poetry run pyright`
		 - `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`

2. **Refresh the review package after the split**
	 - **Files:** `audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md`, `audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md`, and any refreshed follow-up review artifacts
	 - **Expected behavior:** The updated review should remove the 500-line file-size failure if the refactor succeeds and keep the acceptance evidence aligned with the remediated validator layout.
	 - **Verification commands:**
		 - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/policy-audit.2026-04-29T13-55.md`
		 - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T13-55/code-review.2026-04-29T13-55.md`

## Do not do

- Do not weaken or remove the `delegation_receipts.promotion.*` validation behavior.
- Do not change the validator CLI contract or artifact-type names.
- Do not introduce suppression comments or policy exceptions instead of splitting the file.
- Do not expand the remediation into unrelated feature work outside the oversized validator and its direct tests.
