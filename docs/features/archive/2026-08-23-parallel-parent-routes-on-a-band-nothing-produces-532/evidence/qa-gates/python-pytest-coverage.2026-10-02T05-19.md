# Python Targeted Test and Coverage Gate (P7-T4)

Timestamp: 2026-10-02T05-19
Command: poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py tests/scripts/dev_tools/test_validate_parallel_planner_state.py tests/scripts/dev_tools/test_validate_parallel_planner_state_bounds.py tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py --cov=scripts.dev_tools._parallel_planner_state_routing --cov=scripts.dev_tools.validate_parallel_planner_state --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-532-final.json
EXIT_CODE: 0
Output Summary:
136 passed, 0 failed
Read from each file's `summary` block in artifacts/python/coverage-532-final.json:
scripts/dev_tools/_parallel_planner_state_routing.py - line coverage = covered_lines / num_statements = 50 / 50 = 100.00%; branch coverage = covered_branches / num_branches = 16 / 16 = 100.00% (threshold 85% line / 75% branch: met)
scripts/dev_tools/validate_parallel_planner_state.py - line coverage = 115 / 115 = 100.00%; branch coverage = 46 / 46 = 100.00%
missing_lines for both files: [] (empty).
Terminal table rows: routing Stmts 50, Miss 0, Branch 16, BrPart 0, Cover 100%; validator Stmts 115, Miss 0, Branch 46, BrPart 0, Cover 100%.
Integration coverage for the CLI dispatch path: tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py is included in this run.
