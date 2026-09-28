# Fail-Before — `_runner` Branch-Exception Regression Test

- **Task:** [P5-T2] `[expect-fail]`
- **Issue:** #505

Timestamp: 2026-08-25T10-03

Command: `poetry run pytest tests/scripts/dev_tools/test_fix_all_json_cancel.py::test_runner_records_failing_result_when_branch_raises`

EXIT_CODE: 1

ExpectedExitCode: 1

## Preconditions verified before the run

`scripts/dev_tools/fix_all_runtime.py` was **unmodified** when this command executed. Verified
immediately beforehand with `git status --porcelain scripts/dev_tools/fix_all_runtime.py`, which
produced no output, and `git diff --stat -- scripts/dev_tools/fix_all_runtime.py`, which produced no
output. `_runner` was still the four-line body at lines 141-145 with no exception handling. The
[P5-T3] production change had not been made.

## Observed failure

```
tests\scripts\dev_tools\test_fix_all_json_cancel.py F                    [100%]
>       assert exit_code == 1
E       assert 0 == 1
tests\scripts\dev_tools\test_fix_all_json_cancel.py:369: AssertionError
FAILED tests/scripts/dev_tools/test_fix_all_json_cancel.py::test_runner_records_failing_result_when_branch_raises
======================== 1 failed, 1 warning in 0.15s =========================
```

**The exit code returned by `run_fix_all` was `0`.** That is the defect this task documents: the json
lane's branch function raised, its thread terminated, `results["json"]` was never assigned, and the
exit-code expression at `scripts/dev_tools/fix_all_runtime.py` line 183 computed
`all(res.success for res in results.values())` over the four lanes that did record a result — all of
which passed. A crashed lane therefore produced a successful process exit code: a silent false pass.

The run also emitted the corroborating warning, which is the only signal the pre-change code gives:

```
PytestUnhandledThreadExceptionWarning: Exception in thread Thread-1 (_runner)
  File "...\scripts\dev_tools\fix_all_runtime.py", line 142, in _runner
    result = func()
RuntimeError: json branch raised: 505-runner-hardening-probe
```

The traceback terminates at `fix_all_runtime.py` line 142, `result = func()`, which is the exact
unguarded call [P5-T3] wraps.

## Why this is a real fail-before and not a fabricated one

The failure is deterministic, not load-dependent: the branch stand-in raises unconditionally on
every invocation, so the outcome does not depend on thread scheduling, machine load, or elapsed
time. Unlike the candidate B race documented in `fail-before-exception.2026-08-25T09-30.md`, no
exception dossier is required for this criterion because a clean failing run is available and is
recorded here.

The test reached its first assertion, so case 2 of the test (the `complete_all=False` cancel-event
clause) was not evaluated in this run; pytest stops the test at the first failing assertion. Case 2
is exercised in the post-change run recorded by [P5-T3].

Output Summary: `1 failed, 1 warning in 0.15s`, EXIT_CODE 1, matching the declared
`ExpectedExitCode: 1`. Run against the **unmodified** `scripts/dev_tools/fix_all_runtime.py`
(verified clean by `git status --porcelain` and `git diff --stat` beforehand). The assertion failed
as `assert 0 == 1`: **`run_fix_all` returned exit code 0** even though the json lane's branch
function raised `RuntimeError`, because the unguarded `result = func()` at line 142 let the thread
die with `results["json"]` unset and line 183 computed the exit code over the four surviving lanes.
The run also emitted `PytestUnhandledThreadExceptionWarning` for `Thread-1 (_runner)` with the
traceback terminating at line 142. This is the silent false pass that [P5-T3] fixes.
