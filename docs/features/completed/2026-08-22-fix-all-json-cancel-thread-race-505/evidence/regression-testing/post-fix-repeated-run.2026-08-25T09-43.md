# Post-Fix Repeated-Run Protocol (50 iterations under concurrent load)

- **Task:** [P3-T3]
- **Issue:** #505
- **Tree state:** candidate B applied. Both racy tests install an ordered synchronous thread stand-in
  built by `make_ordered_thread_class` for the order python-then-json ([P3-T1], [P3-T2]).

Timestamp: 2026-08-25T09-43

Command:

Load shell (started first, ran for the whole protocol):

```
pwsh -NoProfile -Command "1..12 | ForEach-Object { poetry run pytest -q }"
```

Protocol shell (the 50-iteration measurement):

```
pwsh -NoProfile -Command "1..50 | ForEach-Object { 'ITER ' + $_; poetry run pytest tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate -q }"
```

EXIT_CODE: 0

## Result

- Iterations: 50
- FailureCount: 0 — `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result`
- FailureCount: 0 — `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate`

## Tally

Counted by hand from the per-iteration output, using the same method and the same cross-checks as
the pre-fix protocol at [P1-T1]:

| Check | Expected if zero failures | Observed |
| --- | --- | --- |
| Count of `ITER ` markers (iterations actually executed) | 50 | 50 |
| Count of iterations whose summary line reads `2 passed` | 50 | 50 |
| Count of lines naming `test_json_cancel_before_validate_returns_canceled_result` as failed | 0 | 0 |
| Count of lines naming `test_fail_fast_cancels_json_before_validate` as failed | 0 | 0 |
| Count of lines containing `FAILED` or `error` anywhere in the capture | 0 | 0 |

All 50 iterations reported `2 passed`, for 100 node executions with zero failures.

Wall-clock: **1 minute 21.9 seconds** (`real 1m21.869s`), 09:41:10 to 09:42:32 local time. Load
presence was verified rather than assumed: the load shell was at its tenth of twelve full-suite
runs when the protocol returned, each run reporting `1 failed, 4116 passed, 5 skipped` in 6.8 to 9.1
seconds. The single failure in the load runs is the pre-existing push-down payload parity test
recorded in the Phase 0 baseline, not a `fix_all` failure.

## Why This Zero Means Something the Pre-Fix Zero Did Not

The pre-fix protocol at [P1-T1] also produced 0 and 0. Reporting the same number twice would be
worthless as evidence if the two zeroes had the same standing, so the distinction is stated
explicitly and is backed by a coverage measurement rather than by argument.

**Pre-fix, the zero was probabilistic.** The two tests reached their assertion through the *second*
cancel check in `run_json_branch`, at `scripts/dev_tools/fix_all_branches.py` line 113, which fires
only after the bounded `cancel_event.wait(api.CANCEL_CHECK_DELAY_S)` grace wait at line 112. Whether
the cancel event was set by then depended on the scheduler. The Phase 0 targeted-coverage baseline
measured this directly: `missing_lines` `[103, 104, 105]` and `missing_branches` `[[102, 103]]`, that
is, the True edge of the **first** cancel check was never taken by any test in the suite.

**Post-fix, the zero is structural.** A coverage run over the repaired
`test_json_cancel_before_validate_returns_canceled_result` alone was taken to confirm the path
actually changed:

Verification command:
`poetry run pytest --cov=scripts.dev_tools.fix_all_branches --cov-branch --cov-report=json:artifacts/python/p3check.json tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result -q`

| `scripts/dev_tools/fix_all_branches.py` lines | Covered by the repaired test alone |
| --- | --- |
| 103-105 (first cancel check body) | **yes** |
| 113-118 (grace-wait second cancel check body) | **no** |

The result is the exact inverse of the baseline. The ordered stand-in runs the python branch to
completion before the json branch starts, so the cancel event is already set when json evaluates
line 102 and the lane returns at the first check without ever reaching line 112. The 10 millisecond
wall-clock span is no longer on the path the test exercises, so the test's outcome no longer depends
on host speed or machine load. That is what makes this `FailureCount: 0` a property of ordering
rather than of timing, and it is why the same numeral carries a different claim than it did at
[P1-T1].

Output Summary: Iterations: 50. FailureCount: 0 for
`tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result`
and FailureCount: 0 for
`tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate`, satisfying
the task's acceptance criterion of `FailureCount: 0` for both node IDs. All 50 iterations reported
`2 passed`, cross-checked five ways, with concurrent load verified present for the protocol's full
81.9-second duration. A supporting coverage measurement confirms the repaired test now covers
`fix_all_branches.py` lines 103-105 (the first cancel check) and no longer covers lines 113-118 (the
grace-wait check) — the inverse of the Phase 0 baseline, establishing that the zero failure count is
structural rather than probabilistic.
