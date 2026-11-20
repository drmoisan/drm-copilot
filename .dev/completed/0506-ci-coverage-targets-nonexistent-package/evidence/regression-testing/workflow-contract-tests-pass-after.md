# Workflow contract tests — pass-after

Pass-after evidence for AC-1 through AC-3 and AC-11 through AC-13. The same six
contract tests recorded as failing in
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-fail-before.md`
were rerun unchanged against the MODIFIED `.github/workflows/_quality-checks.yml`
after the three Phase 2 edits. Together the two artifacts form the fail-before
and pass-after pair.

Timestamp: 2026-08-25T22-12

Command: `poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`

EXIT_CODE: 0

Output Summary:

- Collected: 6 tests
- Passed: 6
- Failed: 0
- Session line: `6 passed in 0.07s`
- Exit code captured directly from the command (no pipe consumer).

This is the definitive run, taken against the test file exactly as it now sits
on disk. An identical earlier run at 2026-08-25T22-10 also reported 6 collected,
6 passed, 0 failed, exit code 0. Between the two runs the test file was
reformatted with Black and two module constants were renamed away from a
`_TOKEN` suffix to clear Ruff `S105`; no assertion was changed. The
supporting gate results for the file are: `poetry run black --check` exit 0,
`1 file would be left unchanged`; `poetry run ruff check` exit 0,
`All checks passed!`; `poetry run pyright` exit 0, `0 errors, 0 warnings`.
The full-repository toolchain loop remains Phase 4's task.

Passing node IDs:

1. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_workflow_names_no_foreign_coverage_target`
2. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_pytest_step_uses_bare_cov_with_branch`
3. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_pytest_step_emits_json_coverage_report`
4. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_invokes_the_checker_with_both_floors`
5. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_runs_on_every_matrix_leg`
6. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_codecov_step_uses_the_declared_files_input`

Per-task acceptance runs recorded during Phase 2, each with exit code 0:
[P2-T1] nodes 2 and 3, two passed and zero failed; [P2-T2] nodes 4 and 5, two
passed and zero failed; [P2-T3] node 6, one passed and zero failed.

The test file was not modified during Phase 2. Only
`.github/workflows/_quality-checks.yml` changed between the two runs.
