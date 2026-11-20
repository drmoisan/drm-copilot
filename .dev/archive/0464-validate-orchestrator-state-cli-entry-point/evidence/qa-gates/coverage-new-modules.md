# Coverage, New Modules (Issue #464)

Timestamp: 2026-09-30T09-27
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py tests/scripts/dev_tools/test_validate_orchestrator_state.py --cov=scripts.dev_tools.validate_orchestrator_state_cli --cov=scripts.dev_tools._orchestrator_state_remediation_loop --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-464.json -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- `47 passed in 0.33s`; 0 failed.
- Table rows (Stmts, Miss, Branch, BrPart, Cover, Missing):
  - `scripts\dev_tools\_orchestrator_state_remediation_loop.py`: 36, 1, 16, 2, 94%, missing `57->70, 85`
  - `scripts\dev_tools\validate_orchestrator_state_cli.py`: 33, 1, 4, 0, 97%, missing `118`
  - TOTAL: 69, 2, 20, 2, 96%
- The table prints one combined `Cover` column; separate line and branch ratios follow from the JSON report (P8-T8).
- Note: line 118 of the CLI module is the body of `read_checkpoint_text`, the single I/O seam, which the tests replace with in-memory stubs (no temporary files are permitted). It is exercised end to end by the subprocess reproductions in P8-T2 to P8-T4, which coverage does not measure.

## P8-T8 Separate line and branch ratios

Timestamp: 2026-09-30T09-28
Command: poetry run python -c "import json; d = json.load(open('artifacts/python/coverage-464.json')); print({p: v['summary'] for p, v in d['files'].items()})"
EXIT_CODE: 0
Printed keys per file include `covered_lines`, `num_statements`, `covered_branches`, `num_branches` (the names the plan expects), so the ratios are derived directly from them.

| Module | covered_lines / num_statements | Line ratio | covered_branches / num_branches | Branch ratio |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/validate_orchestrator_state_cli.py` | 32 / 33 | 0.9697 | 4 / 4 | 1.0000 |
| `scripts/dev_tools/_orchestrator_state_remediation_loop.py` | 35 / 36 | 0.9722 | 14 / 16 | 0.8750 |

Thresholds: line >= 0.85 and branch >= 0.75. Both modules meet both thresholds (lowest line ratio 0.9697, lowest branch ratio 0.8750).
