# Final QC: pytest Suite (P7-T5)

Timestamp: 2026-11-14T09-16
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov=scripts.dev_tools.fix_all_runtime --cov=scripts.dev_tools.fix_all_branches --cov=scripts.dev_tools.fix_all_branches_extra --cov=scripts.dev_tools.atomic_executor.qc_runner --cov=scripts.dev_tools.atomic_executor.qc_runner_expectations --cov=scripts.dev_tools.atomic_executor.cli_preflight --cov=scripts.dev_tools.atomic_executor.cli_task_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1158-pytest-final.json (run through SCRATCH/issue-1158-gate-pytest.sh); collection proof: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --collect-only -q
EXIT_CODE: 0
Output Summary: launcher exit 0, with no queue timeout and no refusal line. 24 xdist workers, 16839 items; `16833 passed, 6 skipped in 211.37s`; 0 failed, 0 errors. The project `addopts` carries `--strict-markers --strict-config`, and the session printed no marker error and no warning. Line and branch coverage for the seven modules is at or above the 85% and 75% thresholds.

## Lane Exclusion (spec D27 live proof)

- A collect-only run through the same launcher collected 16839 tests, the same count as the gate session, and listed 0 node ids from `tests/scripts/dev_tools/test_pr_context_integration.py` or `tests/scripts/dev_tools/atomic_executor/test_unicode_integration.py`, the two integration-named files of P0-T5.
- The term-missing table lists all seven `--cov` modules. That proves the extras reached pytest through the launcher and `poetry run`.

## Coverage (term-missing table and JSON report)

| Module | Line | Branch |
|---|---|---|
| `scripts/dev_tools/fix_all_runtime.py` | 98.80% | 95.45% |
| `scripts/dev_tools/fix_all_branches.py` | 100.00% | 100.00% |
| `scripts/dev_tools/fix_all_branches_extra.py` | 100.00% | 100.00% |
| `scripts/dev_tools/atomic_executor/qc_runner.py` | 93.58% | 81.82% |
| `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` | 100.00% | 97.14% |
| `scripts/dev_tools/atomic_executor/cli_preflight.py` | 100.00% | 98.78% |
| `scripts/dev_tools/atomic_executor/cli_task_runtime.py` | 98.84% | 94.23% |
| Total (seven modules) | 98.83% | 96.41% |

The term-missing table reports a combined `Cover` column of 98% for the total. The separate line and branch figures above come from the JSON report.
