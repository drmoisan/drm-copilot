# Python Pytest Baseline

Timestamp: 2026-04-25T14:37:00Z
Command: poetry run pytest --cov --cov-report=term-missing
EXIT_CODE: 1
Output Summary:
- TOTAL coverage: 83% (7010 statements, 1198 missed)
- 1 failed, 993 passed, 14 skipped
- Pre-existing failure: tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_mirrored_orchestrator_agents_match_root_direct_command_contracts
- This failure is pre-existing and not related to this feature's changes.

Notable module coverages:
- scripts\dev_tools\validate_orchestration_artifacts.py: 87%
- scripts\dev_tools\shell_qc.py: 0%
- Coverage LCOV written to artifacts/python/lcov.info
