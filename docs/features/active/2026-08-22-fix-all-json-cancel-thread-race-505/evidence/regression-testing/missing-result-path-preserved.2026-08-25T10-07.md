# Regression — Missing-Result Aggregation Path Preserved by the `_runner` Hardening

- **Task:** [P5-T5]
- **Issue:** #505

Timestamp: 2026-08-25T10-07

Command: `poetry run pytest tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_runtime_reports_missing_result_when_branch_absent`

EXIT_CODE: 0

## Result

```
tests\scripts\dev_tools\test_fix_all_failure_paths.py .                  [100%]
============================== 1 passed in 0.07s ==============================
```

`1 passed`. The run was executed **after** the [P5-T3] change to `_runner` in
`scripts/dev_tools/fix_all_runtime.py`.

## The test still asserts an exit code of 0

The assertion is unchanged and is still present in the test body at
`tests/scripts/dev_tools/test_fix_all_failure_paths.py`:

```python
    # Assert: the json result is missing, so the summary records the
    # missing-result message and the per-branch log loop skips the None entry.
    # The exit code reflects only recorded results (the four others succeed),
    # so it remains 0; the assertion targets the aggregation messages.
    assert exit_code == 0
    output = read_log(logger)
    assert "Branch json did not produce a result." in output
    assert "--- json branch log ---" not in output
```

The test file was not modified by Phase 5: `git diff --stat -- tests/scripts/dev_tools/test_fix_all_failure_paths.py`
produced no output at the time of this run. Its only Phase 2 change was the relocation of the
`_SkipBranchThread` class definition to `tests/scripts/dev_tools/fix_all_thread_stubs.py`, recorded
in `skip-branch-relocation.2026-08-25T09-37.md`, which left this test's body byte-identical.

## Why the hardening does not disturb this path

`SkipBranchThread.start` returns without ever invoking the target for the skipped branch, so
`_runner` is **never entered** for the json lane. No exception is raised inside `_runner`, so the new
`except Exception` handler added by [P5-T3] does not run, `results["json"]` stays unset, and the
aggregation loop still takes its missing-result path at `scripts/dev_tools/fix_all_runtime.py` lines
156-158 and 171. The exit-code expression continues to compute over recorded results only, and the
four recorded lanes all succeed, so the exit code remains 0.

This distinction is the point of the criterion: the hardening records a result for a branch that
**raises**, and deliberately does not invent one for a branch that never **ran**. Those are two
different aggregation paths, and both are now covered by tests.

Output Summary: `1 passed in 0.07s`, EXIT_CODE 0, run after the `_runner` hardening. The test is
unmodified (`git diff --stat` on its file produced no output) and still carries its `assert
exit_code == 0` assertion along with the two aggregation-message assertions. The hardening does not
affect this path because `SkipBranchThread` suppresses the target so `_runner` is never entered for
the skipped lane, leaving `results["json"]` unset and the missing-result branch intact.
