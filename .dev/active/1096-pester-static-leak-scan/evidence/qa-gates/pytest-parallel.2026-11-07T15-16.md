# QA Gate: pytest -n auto

Timestamp: 2026-11-07T15-16
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/final/issue-1096-coverage-final.json --junitxml=SCRATCH/final/issue-1096-junit-final.xml
EXIT_CODE: 0
Output Summary: 16152 passed, 6 skipped in 293.33s. JUnit holds 16158 testcases with 0 failures and 0 errors. Total coverage from the JSON report: line 32364/33372 (96.98%), branch 11785/12518 (94.14%). The JSON report is kept apart from the P0-T3 report under SCRATCH/baseline/.

## Failures

GATE-FAILURE: NONE

## Named Tests (JUnit, no failure or error element)

- `tests.scripts.dev_tools.test_poshqc_bundled_parity` `test_poshqc_bundled_module_files_match_repo_root_sources`: passed
- `tests.scripts.dev_tools.test_execution_environment_brief_contracts` `test_brief_copies_are_byte_identical`: passed
- `tests.scripts.dev_tools.atomic_executor.test_qc_runner.TestQCRunnerRunScoped` `test_run_scoped_runs_all_tools_on_changed_files`: passed

## Coverage (JSON report `files` summaries)

- `scripts/dev_tools/fix_all_branches.py`: line 87/87 (100%), branch 26/26 (100%)
- `scripts/dev_tools/fix_all_branches_extra.py`: line 85/85 (100%), branch 24/24 (100%)
- `scripts/dev_tools/atomic_executor/cli_preflight.py`: line 153/153 (100%), branch 77/78 (98.72%)
- `scripts/dev_tools/atomic_executor/qc_runner.py`: line 96/103 (93.2%), branch 14/18 (77.78%)
- `scripts/dev_tools/atomic_executor/prompt_builder.py`: line 124/124 (100%), branch 44/44 (100%)
- `scripts/dev_tools/atomic_executor/qc_toolchain.py`: line 15/15 (100%), branch 0/0
