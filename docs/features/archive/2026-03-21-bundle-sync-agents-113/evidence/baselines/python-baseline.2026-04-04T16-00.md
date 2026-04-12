# Python Baseline — 2026-04-04T16-00

Timestamp: 2026-04-04T16-00
Branch: feature/bundle-sync-agents-113

## Format (Black check-only)

Command: `poetry run black --check .`
EXIT_CODE: 0
Output Summary: 171 files would be left unchanged.

## Lint (Ruff)

Command: `poetry run ruff check`
EXIT_CODE: 0
Output Summary: All checks passed!

## Type-check (Pyright)

Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations

## Unit Tests with Coverage (Pytest)

Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing -q`
EXIT_CODE: 0
Output Summary:
- 905 passed
- TOTAL coverage: 83% (5480/6633 lines covered)
