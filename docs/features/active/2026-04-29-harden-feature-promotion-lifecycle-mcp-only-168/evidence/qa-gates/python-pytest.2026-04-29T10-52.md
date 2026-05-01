# Python QA Pytest Evidence

Timestamp: 2026-04-29T10-52
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info
EXIT_CODE: 0
Output Summary: Pytest completed successfully with 29 passing tests. Coverage remained above the required thresholds for the touched modules: `validate_orchestration_artifacts.py` 90%, `validate_orchestration_review_artifacts.py` 87%, `validate_orchestrator_state.py` 83%, and total covered lines 87%.

Final Command Output:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 29 items

29 passed in 0.16s
Coverage XML written to file coverage.xml
Coverage LCOV written to file artifacts/python/lcov.info
