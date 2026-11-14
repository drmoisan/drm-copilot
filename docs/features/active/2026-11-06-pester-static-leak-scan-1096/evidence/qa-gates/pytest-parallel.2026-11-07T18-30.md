# QA Gate: pytest -n auto (Remediation Cycle 2, Phase 2 restart)

Timestamp: 2026-11-07T18-30
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/c2r/issue-1096-coverage-c2r.json --junitxml=SCRATCH/c2r/issue-1096-junit-c2r.xml
EXIT_CODE: 0
Output Summary: Phase 2 restart after the orchestrator's conflict-free merge of origin/main (PR #1113, issue #1105); one background run after the restart P2-T2. 16213 passed, 6 skipped in 191.42s. JUnit holds 16219 testcases with 0 failures and 0 errors. Total coverage from the JSON report: line 32456/33464 (96.99%), branch 11827/12560 (94.16%).

## Failures

GATE-FAILURE: NONE

## Named Tests (JUnit, testcase element with no failure or error child)

- `tests.scripts.dev_tools.test_execution_environment_brief_contracts` `test_brief_copies_are_byte_identical`: passed
- `tests.scripts.dev_tools.test_execution_environment_brief_contracts` `test_brief_test_isolation_states_parallel_gates`: passed
- `tests.scripts.dev_tools.test_execution_environment_brief_contracts` `test_brief_passages_state_parallel_gate_facts`: passed
- `tests.scripts.dev_tools.test_execution_environment_brief_contracts` `test_brief_ci_section_names_jobs_and_required_contexts`: passed
- `tests.scripts.dev_tools.atomic_executor.test_qc_runner.TestQCRunnerRunFull` `test_run_full_runs_all_tools_on_entire_codebase`: passed
- `tests.scripts.dev_tools.test_poshqc_bundled_parity` `test_poshqc_bundled_module_files_match_repo_root_sources`: passed
- `tests.scripts.dev_tools.atomic_executor.test_cli_part3.TestPreflightQCBranches` `test_collect_step_missing_executable_fails`: passed
- `tests.scripts.dev_tools.atomic_executor.test_cli_part2_part2.TestPreflightParallelCommand` `test_preflight_pytest_step_runs_xdist_workers`: passed
- `tests.scripts.dev_tools.atomic_executor.test_unicode_integration.TestQCRunnerFilterHelpers` `test_filter_python_files_keeps_py_only`: passed

## Coverage (JSON report `files` summaries)

- `scripts/dev_tools/fix_all_branches.py`: line 87/87 (100%), branch 26/26 (100%)
- `scripts/dev_tools/fix_all_branches_extra.py`: line 85/85 (100%), branch 24/24 (100%)
- `scripts/dev_tools/atomic_executor/cli_preflight.py`: line 153/153 (100%), branch 77/78 (98.72%)
- `scripts/dev_tools/atomic_executor/qc_runner.py`: line 96/103 (93.2%), branch 14/18 (77.78%)
- `scripts/dev_tools/atomic_executor/prompt_builder.py`: line 124/124 (100%), branch 44/44 (100%)
- `scripts/dev_tools/atomic_executor/qc_toolchain.py`: line 15/15 (100%), branch 0/0

git status --porcelain through -C was empty after the run.
