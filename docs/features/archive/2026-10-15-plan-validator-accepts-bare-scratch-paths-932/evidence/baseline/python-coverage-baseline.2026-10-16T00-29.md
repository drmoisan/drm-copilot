# Python Coverage Baseline — Issue #932

Timestamp: 2026-10-16T00-29
Task: [P0-T7]
Command: poetry run pytest tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py.json
EXIT_CODE: 0

Output Summary:
- pytest: 107 passed, 0 failed.
- term-missing row: `scripts\dev_tools\plan_gate_discrimination.py  Stmts 131  Miss 3  Branch 52  BrPart 3  Cover 97%  Missing 209, 248, 277`
- Line coverage (covered_lines / num_statements, from SCRATCH/cov/baseline-py.json summary): 128 / 131 = 97.71%
- Branch coverage (covered_branches / num_branches): 49 / 52 = 94.23%
- Combined coverage.py percent_covered: 96.72%

missing_lines: [209, 248, 277]
missing_branches: [[208, 209], [247, 248], [276, 277]]
