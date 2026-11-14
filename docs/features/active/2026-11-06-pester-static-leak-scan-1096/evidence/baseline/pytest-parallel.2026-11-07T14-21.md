# Baseline Gate: pytest -n auto

Timestamp: 2026-11-07T14-21
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/baseline/issue-1096-coverage-baseline.json --junitxml=SCRATCH/baseline/issue-1096-junit-baseline.xml
EXIT_CODE: 0
Output Summary: 16119 passed, 6 skipped in 300.65s. JUnit holds 16125 testcases with 0 failures and 0 errors. Total coverage from the JSON report: line 32270/33367 (96.71%), branch 11722/12516 (93.66%).

## Failures

BASELINE-FAILURE: NONE

## Coverage

BASELINE-COVERAGE: scripts/dev_tools/fix_all_branches.py | line 82/82 | 100% | branch 24/24 | 100%
BASELINE-COVERAGE: scripts/dev_tools/fix_all_branches_extra.py | line 85/85 | 100% | branch 24/24 | 100%
BASELINE-COVERAGE: scripts/dev_tools/atomic_executor/cli_preflight.py | line 99/153 | 64.71% | branch 36/78 | 46.15%
BASELINE-COVERAGE: scripts/dev_tools/atomic_executor/qc_runner.py | line 96/103 | 93.2% | branch 14/18 | 77.78%
BASELINE-COVERAGE: scripts/dev_tools/atomic_executor/prompt_builder.py | line 92/124 | 74.19% | branch 26/44 | 59.09%
BASELINE-COVERAGE: scripts/dev_tools/atomic_executor/qc_toolchain.py | line 15/15 | 100% | branch 0/0 | 100%
