# Baseline — Pytest with Coverage (Issue #399)

Timestamp: 2026-07-22T15-15
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary:
- Tests: 2069 passed, 0 failed.
- Coverage headline (TOTAL): 88% (statements 12252, missed 1114; branches 4446, partial 564).
- Derived line coverage: (12252 - 1114) / 12252 = 90.9%.
- Derived branch coverage: (4446 - 564) / 4446 = 87.3%.
- Targeted module `scripts/dev_tools/_orchestrator_state_routing.py`: 210 statements, 17 missed, 108 branches, 18 partial, 89%. Missing/partial include lines 85, 90, 95, 184, 233, 282, 325, 339, 367, 380->378, 394, 399->392, 419, 453, 457-460, 477, 482, 485.
- All thresholds (>= 85% line, >= 75% branch) satisfied at baseline.
