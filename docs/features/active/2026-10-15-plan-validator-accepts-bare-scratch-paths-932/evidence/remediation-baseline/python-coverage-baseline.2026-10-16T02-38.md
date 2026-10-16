# Python Coverage Baseline (Remediation Cycle 1)

Timestamp: 2026-10-16T02-38
Task: [P0-T14]
Command: poetry run pytest tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_commands --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py.json
EXIT_CODE: 0
Output Summary:

- Final pytest summary: `145 passed in 1.72s` (145 passed, 0 failed).
- term-missing rows:

```text
Name                                      Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\plan_gate_commands.py      99      1     36      2    98%   325->327, 332
scripts\dev_tools\plan_gate_scratch.py       53      0     18      0   100%
TOTAL                                       152      1     54      2    99%
```

- From `SCRATCH/cov/baseline-py.json` `summary` objects:
  - `plan_gate_scratch.py`: line 53/53 = 100.00%; branch 18/18 = 100.00%.
  - `plan_gate_commands.py`: line 98/99 = 98.99%; branch 34/36 = 94.44%; `missing_lines` [332].
