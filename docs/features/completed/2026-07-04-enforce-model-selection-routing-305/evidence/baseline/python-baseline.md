# Python Baseline (Issue #305)

Timestamp: 2026-07-04T13-50

## Format

Command: `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`
EXIT_CODE: 0
Output Summary: All done. 222 files would be left unchanged.

## Lint

Command: `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`
EXIT_CODE: 0
Output Summary: All checks passed.

## Type-check

Command: `poetry run pyright scripts/dev_tools`
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations.

## Tests + coverage

Command: `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary: 1275 passed. Combined coverage TOTAL (line+branch) = 84% over `scripts/dev_tools`
(9179 statements, 1242 missed; 3304 branches, 447 partial). Derived line coverage
= (9179-1242)/9179 = 86.5%; derived branch coverage = (3304-447)/3304 = 86.5%.
The dominant coverage gap is the pre-existing `shell_qc.py` at 0% (222 statements uncovered),
which pre-dates this change. Modules directly relevant to #305:
`validate_orchestrator_state.py` 96%, `_orchestrator_state_model_routing.py` (in the same package),
`resolve_delegation_model.py` 100%, `validate_orchestration_artifacts.py` 90%.
