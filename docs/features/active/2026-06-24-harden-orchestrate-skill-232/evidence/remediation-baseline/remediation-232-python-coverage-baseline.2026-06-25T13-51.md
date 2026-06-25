Timestamp: 2026-06-25T13-51
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_policy_audit_artifact.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_bundle_parity.py --cov=scripts.dev_tools.validate_orchestrator_state --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_policy_audit_artifact --cov-report=term-missing
EXIT_CODE: 0
Output Summary: Pytest passed with 51 tests. Total scoped Python coverage was 86%.

Python Coverage Values:
- scripts\dev_tools\validate_orchestration_artifacts.py: 85 statements, 8 missed, 91% coverage.
- scripts\dev_tools\validate_orchestrator_state.py: 175 statements, 34 missed, 81% coverage.
- scripts\dev_tools\validate_policy_audit_artifact.py: 125 statements, 12 missed, 90% coverage.
- Total: 385 statements, 54 missed, 86% coverage.
