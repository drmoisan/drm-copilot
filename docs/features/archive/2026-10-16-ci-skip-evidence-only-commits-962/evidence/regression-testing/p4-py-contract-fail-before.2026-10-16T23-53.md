# Python contract test fails before A1 (P4-T8, PD-13)

Timestamp: 2026-10-16T23-53
Command: poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure caused by G1: the threshold step now carries `if: ${{ inputs.run-heavy }}`, and the unmodified test asserts `"if" not in step`. The short summary has exactly one FAILED line (test_threshold_step_runs_on_every_matrix_leg) and no other; the summary line reports `1 failed, 5 passed` (B = 6 from P0-T17, so B-1 = 5). CI job: quality-checks7 / Code Quality & Tests (ubuntu-latest).

## Output (host path redacted)

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 6 items

tests\scripts\dev_tools\test_quality_checks_workflow_contracts.py ....F. [100%]

================================== FAILURES ===================================
________________ test_threshold_step_runs_on_every_matrix_leg _________________

    def test_threshold_step_runs_on_every_matrix_leg() -> None:
        """The enforcement step must not be conditioned onto one matrix leg.

        Scenario: the step running the threshold checker is inspected for a
        condition key, per decision D3 of the spec. Expected outcome: the step
        mapping carries no ``if`` key.
        """
        step = step_running(THRESHOLD_CHECKER_MODULE)

>       assert "if" not in step
E       AssertionError: assert 'if' not in {'continue-on-error': False, 'if': '${{ inputs.run-heavy }}', 'name': 'Enforce Python coverage thresholds', 'run': 'po....check_python_coverage_thresholds \\\n  --report artifacts/python/coverage.json \\\n  --min-line 85 --min-branch 75\n'}

tests\scripts\dev_tools\test_quality_checks_workflow_contracts.py:143: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_threshold_step_runs_on_every_matrix_leg
========================= 1 failed, 5 passed in 0.17s =========================
```
