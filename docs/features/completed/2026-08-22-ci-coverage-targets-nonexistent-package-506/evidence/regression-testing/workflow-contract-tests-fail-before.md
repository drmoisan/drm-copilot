# Workflow contract tests — fail-before

Fail-before evidence for AC-1 through AC-3 and AC-11 through AC-13. The six
contract tests of `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`
were executed against the UNMODIFIED `.github/workflows/_quality-checks.yml`.
A failing run is the expected outcome of this task ([P1-T7], `[expect-fail]`).

Timestamp: 2026-08-25T22-09

Command: `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:

- Collected: 6 tests
- Failed: 6
- Passed: 0
- Session line: `6 failed in 0.10s`
- Exit code captured directly from the command (no pipe consumer).

Failing node IDs, one per contract:

1. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_workflow_names_no_foreign_coverage_target`
   — `AssertionError: assert 'lexile_corpus_tuner' not in ...`; the committed
   workflow still names `--cov=src/lexile_corpus_tuner`.
2. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_pytest_step_uses_bare_cov_with_branch`
   — `AssertionError: assert '--cov-branch' in ('poetry', 'run', 'pytest', '--cov=src/lexile_corpus_tuner', '--cov-report=xml', '--cov-report=term-missing')`.
3. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_pytest_step_emits_json_coverage_report`
   — `AssertionError: assert '--cov-report=json:artifacts/python/coverage.json' in (...)`.
4. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_invokes_the_checker_with_both_floors`
   — `AssertionError: expected one step running check_python_coverage_thresholds, found 0`.
5. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_runs_on_every_matrix_leg`
   — `AssertionError: expected one step running check_python_coverage_thresholds, found 0`.
6. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_codecov_step_uses_the_declared_files_input`
   — `AssertionError: assert 'files' in {'fail_ci_if_error': False, 'file': './coverage.xml', 'flags': 'unittests', 'name': 'codecov-umbrella'}`.

Per-task fail-before runs recorded during authoring, each collecting exactly one
test and reporting one failed with exit code 1: [P1-T1] node 1, [P1-T2] node 2,
[P1-T3] node 3, [P1-T4] node 4, [P1-T5] node 5, [P1-T6] node 6.
