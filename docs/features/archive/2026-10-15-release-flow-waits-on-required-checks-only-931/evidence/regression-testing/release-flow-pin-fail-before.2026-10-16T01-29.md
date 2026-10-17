# Release-Flow Pin Fail-Before (Issue #931) [expect-fail]

Timestamp: 2026-10-16T01-29
Command: poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py::test_release_flow_waits_on_every_check_without_required_wording -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure observed before the script edit. Summary line `1 failed in 0.29s`. Failure message: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1 carries the --required flag`.

Output (tail):

```
>       assert (
            not carries_required_flag
        ), f"{RELEASE_FLOW_SCRIPT.as_posix()} carries the --required flag"
E       AssertionError: scripts/dev-tools/Invoke-FullReleaseFlow.ps1 carries the --required flag
E       assert not True

tests\scripts\dev_tools\test_ci_gate_all_checks_contracts.py:265: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py::test_release_flow_waits_on_every_check_without_required_wording
1 failed in 0.29s
```

The failure is caused by the defect under repair (the `--required` flag at script line 220), not by a test error.
