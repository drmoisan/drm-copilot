Timestamp: 2026-03-11T22-18
Command: poetry run pytest --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Pytest completed successfully from the repo root.
- Tests: 828 passed.
- Numeric coverage headline captured via supplemental coverage-producing verification because the plan command inherited repo config that only emitted LCOV output by default.
- Coverage total: 82% (6,615 statements, 1,206 missed).

Key Output:
============================= test session starts ==============================
platform linux -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
collected 828 items
...
================================ tests coverage ================================
TOTAL                                                               6615   1206
	82%
Coverage LCOV written to file artifacts/python/lcov.info
============================= 828 passed in 4.53s ==============================

Supplemental Coverage Command:
poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing
