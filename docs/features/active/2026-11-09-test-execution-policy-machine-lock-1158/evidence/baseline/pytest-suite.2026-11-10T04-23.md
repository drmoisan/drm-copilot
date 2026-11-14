# pytest Phase 0 Baseline (P0-T5)

Timestamp: 2026-11-10T04-23
Command: sh SCRATCH/issue-1158-pytest-baseline.sh (unset VIRTUAL_ENV; poetry run pytest -n auto --cov=scripts.dev_tools.fix_all_runtime --cov=scripts.dev_tools.fix_all_branches --cov=scripts.dev_tools.fix_all_branches_extra --cov=scripts.dev_tools.atomic_executor.qc_runner --cov=scripts.dev_tools.atomic_executor.qc_runner_expectations --cov=scripts.dev_tools.atomic_executor.cli_preflight --cov=scripts.dev_tools.atomic_executor.cli_task_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1158-pytest-baseline.json --junitxml=artifacts/python/pytest-junit.xml)
EXIT_CODE: 0
Output Summary: Phase 0 baseline, one pytest -n auto run: 16598 passed, 6 skipped, 0 failed in 285.72 s. Total over the seven modules: line 72.91% (557/764), branch 65.44% (178/272), read from the JSON report.

## Per-module coverage (JSON report)

| Module | Line | Branch |
|---|---|---|
| scripts/dev_tools/fix_all_runtime.py | 98.78% (81/82) | 95.45% (21/22) |
| scripts/dev_tools/fix_all_branches.py | 100.00% (87/87) | 100.00% (26/26) |
| scripts/dev_tools/fix_all_branches_extra.py | 100.00% (85/85) | 100.00% (24/24) |
| scripts/dev_tools/atomic_executor/qc_runner.py | 93.20% (96/103) | 77.78% (14/18) |
| scripts/dev_tools/atomic_executor/qc_runner_expectations.py | 43.53% (37/85) | 29.63% (16/54) |
| scripts/dev_tools/atomic_executor/cli_preflight.py | 100.00% (153/153) | 98.72% (77/78) |
| scripts/dev_tools/atomic_executor/cli_task_runtime.py | 10.65% (18/169) | 0.00% (0/50) |

Pre-existing: `qc_runner_expectations.py` and `cli_task_runtime.py` are below the 85% line and 75% branch thresholds before any change; P7-T5 holds each module to the thresholds, so the Phase 5 test files must raise them.

## Integration-named test files (testcase count from artifacts/python/pytest-junit.xml)

| File | Tests |
|---|---|
| tests/scripts/dev_tools/test_pr_context_integration.py | 5 |
| tests/scripts/dev_tools/atomic_executor/test_unicode_integration.py | 6 |
