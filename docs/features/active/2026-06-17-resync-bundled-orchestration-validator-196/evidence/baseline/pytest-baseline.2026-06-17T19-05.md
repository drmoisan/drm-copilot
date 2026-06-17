# Pytest + Coverage Baseline (Issue #196)

Timestamp: 2026-06-17T19-05
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary:
- Tests: 1146 passed, 0 failed.
- TOTAL coverage (combined line+branch metric reported by pytest-cov): 82%.
- TOTAL statements: 8206; missed: 1238; branches: 2916; partial branches: 422.
- This 82% repository total is the pre-existing baseline. The low total is driven by host-bound/uninstrumented modules in scope (for example `scripts/dev_tools/shell_qc.py` at 0% and `tk_dialog_helpers.py` at 45%), which predate this change.
- The five validator modules in scope report at baseline: validate_orchestration_artifacts.py 88%, validate_orchestration_review_artifacts.py 97%, validate_orchestrator_state.py 95%, validate_policy_audit_artifact.py 88%.
- Obligation for this feature: no regression on changed lines; new bundled files and tests must be covered.
