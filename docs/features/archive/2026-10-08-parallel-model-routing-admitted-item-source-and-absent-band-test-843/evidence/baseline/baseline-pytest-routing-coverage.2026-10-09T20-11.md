# Baseline routing pytest with coverage (P0-T14)

Timestamp: 2026-10-09T20-11
Command: poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py --cov=scripts.dev_tools._parallel_planner_state_routing --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/routing-coverage-843.json
EXIT_CODE: 0
Output Summary:
- Result line: ============================= 29 passed in 0.27s ==============================
- BaselineRoutingTestCount: 29
- Coverage-table columns: Name Stmts Miss Branch BrPart Cover Missing
- Coverage row: scripts\dev_tools\_parallel_planner_state_routing.py      50      0     16      0   100%
