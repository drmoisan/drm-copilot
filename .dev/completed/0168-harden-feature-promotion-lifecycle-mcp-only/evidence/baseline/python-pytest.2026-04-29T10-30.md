# Python Baseline Pytest Evidence

Timestamp: 2026-04-29T10-30
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info
EXIT_CODE: 0
Output Summary: Pytest passed 28 tests in 0.12s with 87% line coverage for `scripts.dev_tools.validate_orchestration_artifacts`.

Coverage Headline:
- `scripts.dev_tools.validate_orchestration_artifacts` — 87% line coverage
- Total — 87% line coverage

Command Output:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 28 items

28 passed in 0.12s
Coverage XML written to file coverage.xml
Coverage LCOV written to file artifacts/python/lcov.info
