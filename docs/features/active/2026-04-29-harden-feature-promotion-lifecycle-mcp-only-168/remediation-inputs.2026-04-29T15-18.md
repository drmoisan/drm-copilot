# Remediation Inputs — 2026-04-29T15-18

## Source review artifacts

- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md`
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md`

## Enumerated fix list

1. **Bring the review-artifact validator back under the repository file-size limit**
   - **Files:** `scripts/dev_tools/validate_orchestration_review_artifacts.py` and any new helper modules required under `scripts/dev_tools/`
   - **Expected behavior:** The review-artifact validation logic remains functionally identical, the public CLI entrypoint and artifact-type names remain unchanged, and every touched production file is below 500 lines.
   - **Verification commands:**
     - `pwsh -NoProfile -Command "foreach ($path in @('scripts/dev_tools/validate_orchestration_artifacts.py','scripts/dev_tools/validate_orchestration_review_artifacts.py','scripts/dev_tools/validate_orchestrator_state.py')) { $count = (Get-Content -Path $path).Count; Write-Output (\"$path`t$count\") }"`
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/policy-audit.2026-04-29T12-38.md`
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/code-review.2026-04-29T12-38.md`
    - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/audit-2026-04-29T12-38/feature-audit.2026-04-29T12-38.md`

2. **Raise the new Python modules to the repository coverage target**
   - **Files:** `scripts/dev_tools/validate_orchestration_review_artifacts.py`, `scripts/dev_tools/validate_orchestrator_state.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`, and any direct helper-test modules created to cover the remaining branches
   - **Expected behavior:** The rerun QA evidence shows at least 90% coverage for each new Python production module without weakening the existing validator behavior.
   - **Verification commands:**
     - `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`
     - `poetry run pyright`

3. **Refresh the review package after remediation**
   - **Files:** new timestamped rerun artifacts in this feature folder
   - **Expected behavior:** A follow-up review reports the 500-line finding as resolved only if the direct line-count evidence confirms it, and the overall merge gate reflects the refreshed coverage evidence.
   - **Verification commands:**
     - `mcp_drmcopilotext_collect_pr_context base=development`
     - `mcp_drmcopilotext_validate_orchestration_artifacts artifact_type=policy-audit artifact_path=<new policy-audit path>`
     - `mcp_drmcopilotext_validate_orchestration_artifacts artifact_type=code-review artifact_path=<new code-review path>`
     - `mcp_drmcopilotext_validate_orchestration_artifacts artifact_type=feature-audit artifact_path=<new feature-audit path>`

## Do not do

- Do not weaken or remove the `delegation_receipts.promotion.*` validation behavior.
- Do not change the CLI entrypoint or artifact-type names accepted by `scripts.dev_tools.validate_orchestration_artifacts`.
- Do not claim the 500-line finding is resolved until direct line-count evidence confirms every touched production file is below 500 lines.
- Do not use policy exceptions or suppressions to avoid the file-size or coverage findings.
- Do not expand the remediation into unrelated feature work outside the split validator modules, their direct tests, and the review refresh.
