# Remediation Inputs: Issue #615

## Findings

1. Resolve the failing full pytest/coverage gate recorded in evidence/qa-gates/python-tests-coverage.md (exit code 1).
2. Refresh the full Python QA evidence after the fix.
3. Verify exact-head CI for the resulting commit.

## Required verification

- poetry run black .
- poetry run ruff check .
- poetry run pyright
- poetry run pytest --cov=. --cov-report=term-missing
- poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py

## Do not do

- Do not modify runtime skill or mirror files.
- Do not modify production code or unrelated expectations.
- Do not weaken or skip the frozen-surface assertion.
