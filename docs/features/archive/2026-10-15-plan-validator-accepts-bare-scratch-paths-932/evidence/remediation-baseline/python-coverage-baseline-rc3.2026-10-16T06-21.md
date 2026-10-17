# Python Coverage Baseline (Remediation Cycle 3)

Timestamp: 2026-10-16T06-21
Task: [P0-T13]
Command: poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_plan_gate_discrimination_context.py tests/scripts/dev_tools/test_plan_gate_discrimination_cov.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_scratch --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov/baseline-py-rc3.json
EXIT_CODE: 0
Output Summary:

- Final pytest summary: `170 passed in 1.88s` (170 passed, 0 failed).
- term-missing rows:

```text
Name                                            Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\plan_gate_commands.py           107      1     40      2    98%   363->365, 370
scripts\dev_tools\plan_gate_discrimination.py     133      2     52      2    98%   212, 251
scripts\dev_tools\plan_gate_scratch.py             55      0     16      0   100%
TOTAL                                             295      3    108      4    98%
```

- From each file's `summary` object in `SCRATCH/cov/baseline-py-rc3.json`:

| File | Line (covered_lines / num_statements) | Branch (covered_branches / num_branches) |
| --- | --- | --- |
| `plan_gate_commands.py` | 106/107 = 99.07% | 38/40 = 95.00% |
| `plan_gate_scratch.py` | 55/55 = 100.00% | 16/16 = 100.00% |
| `plan_gate_discrimination.py` | 131/133 = 98.50% | 50/52 = 96.15% |
