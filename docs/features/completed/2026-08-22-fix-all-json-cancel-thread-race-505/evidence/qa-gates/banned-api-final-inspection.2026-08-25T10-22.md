# Banned Determinism API — Final Inspection of the Complete Test Write Set (Phase 7, [P7-T4])

Timestamp: 2026-08-25T10-22

Command (PowerShell, run from the worktree root), plus a read of each of the four files:

```
Select-String -SimpleMatch -Pattern 'time.sleep' -Path tests/scripts/dev_tools/test_fix_all_failure_paths.py,tests/scripts/dev_tools/test_fix_all.py,tests/scripts/dev_tools/fix_all_thread_stubs.py,tests/scripts/dev_tools/test_fix_all_json_cancel.py
```

Supporting token sweep across the same four files for `\.wait\(`, `import time`, `time\.`, `perf_counter`, `monotonic`, `datetime`, `elapsed`, `timeout`, and `sleep`.

EXIT_CODE: 0

## Why this artifact and not the [P3-T5] one

`banned-api-inspection.2026-08-25T09-43.md` ([P3-T5]) is deliberately scoped to the Phase 2 and Phase 3 modifications of **tracked** files, inspected through `git diff -- tests/scripts/dev_tools`. At that point `tests/scripts/dev_tools/fix_all_thread_stubs.py` and `tests/scripts/dev_tools/test_fix_all_json_cancel.py` were untracked, so a diff-based inspection could not see them. This artifact inspects the complete final test write set — all four files, tracked or not — and is the sole authoritative support for the banned-determinism-API acceptance criterion.

## Banned forms inspected

Per the Determinism Infrastructure section of `.claude/rules/general-unit-test.md`, as expressed in Python terms by the spec:

- **Form A** — `time.sleep`.
- **Form B** — a bounded `Event.wait` used as a synchronization delay.
- **Form C** — any assertion whose outcome depends on elapsed time.

## Twelve verdicts (four files, three forms each)

| # | File | Form | Verdict |
| --- | --- | --- | --- |
| 1 | `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | A — `time.sleep` | **ABSENT** |
| 2 | `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | B — bounded `Event.wait` as a delay | **ABSENT** |
| 3 | `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | C — elapsed-time assertion | **ABSENT** |
| 4 | `tests/scripts/dev_tools/test_fix_all.py` | A — `time.sleep` | **ABSENT** |
| 5 | `tests/scripts/dev_tools/test_fix_all.py` | B — bounded `Event.wait` as a delay | **ABSENT** |
| 6 | `tests/scripts/dev_tools/test_fix_all.py` | C — elapsed-time assertion | **ABSENT** |
| 7 | `tests/scripts/dev_tools/fix_all_thread_stubs.py` | A — `time.sleep` | **ABSENT** |
| 8 | `tests/scripts/dev_tools/fix_all_thread_stubs.py` | B — bounded `Event.wait` as a delay | **ABSENT** |
| 9 | `tests/scripts/dev_tools/fix_all_thread_stubs.py` | C — elapsed-time assertion | **ABSENT** |
| 10 | `tests/scripts/dev_tools/test_fix_all_json_cancel.py` | A — `time.sleep` | **ABSENT** |
| 11 | `tests/scripts/dev_tools/test_fix_all_json_cancel.py` | B — bounded `Event.wait` as a delay | **ABSENT** |
| 12 | `tests/scripts/dev_tools/test_fix_all_json_cancel.py` | C — elapsed-time assertion | **ABSENT** |

Twelve verdicts, all ABSENT.

## Evidence for each verdict

### Form A — `time.sleep`

`Select-String -SimpleMatch` over the four files returned exactly **one** line:

```
tests\scripts\dev_tools\test_fix_all_json_cancel.py:20:    No test in this module creates a thread, calls ``time.sleep``, waits on a
```

That line is inside the module docstring (lines 1-30), under the `Key invariants/constraints:` heading, and is a **negated prose claim that the module does not call the API**. It is not a call, not an import, and not executable. The full sentence reads: "No test in this module creates a thread, calls ``time.sleep``, waits on a real clock, or asserts anything about elapsed time, per the Determinism Infrastructure section of ``.claude/rules/general-unit-test.md``."

The occurrence is recorded here rather than suppressed, because a literal match did occur and an inspection artifact that reported a bare "no matches" would misstate the raw command output. The verdict for Form A is ABSENT in all four files: no file contains a call to `time.sleep`, and none of the four imports the `time` module (the token sweep found no `import time` in any of them).

### Form B — bounded `Event.wait` used as a synchronization delay

The token sweep for `\.wait\(` found no occurrence in `test_fix_all_failure_paths.py`, `test_fix_all.py`, or `fix_all_thread_stubs.py`. Verdicts 2, 5, and 8 are ABSENT with no occurrence to assess.

`test_fix_all_json_cancel.py` defines a `wait` method at line 143, on the class `GraceWaitCancelEvent` (lines 121-147). It is **not** a bounded `threading.Event.wait` and performs no waiting:

```python
def wait(self, timeout: float | None = None) -> bool:
    """Record the timeout, become set, and return without waiting."""
    self.wait_timeouts.append(timeout)
    self._flag = True
    return True
```

The method records the timeout argument, flips the flag to set, and returns `True` immediately. The `timeout` parameter exists solely to match the `threading.Event.wait` signature and to be captured for assertion; it is never used to delay. This is a stand-in that replaces the real wait, which is precisely the mechanism that removes the wall-clock dependency rather than introducing one. Verdict 11 is ABSENT.

The three tests that use a real `threading.Event` (in `test_run_json_branch_canceled_at_first_check` and `test_run_json_branch_complete_all_runs_validate`) pre-set the event and never call `wait` on it.

### Form C — assertion whose outcome depends on elapsed time

The token sweep for `perf_counter`, `monotonic`, `datetime`, `elapsed`, and `time.` found no clock read in any of the four files. The only `elapsed` occurrences are two prose lines in `test_fix_all_json_cancel.py` (line 21 in the module docstring and line 128 in a class docstring), both stating the absence of an elapsed-time dependency. Verdicts 3, 6, 9, and 12 are ABSENT.

One assertion warrants explicit treatment, at `test_fix_all_json_cancel.py` line 301:

```python
assert cancel_event.wait_timeouts == [fix_all.CANCEL_CHECK_DELAY_S]
```

This asserts the **argument value passed** to the stand-in's `wait` method — that the production code requested the configured grace duration — by comparing a recorded argument against the production constant `fix_all.CANCEL_CHECK_DELAY_S`. It measures no duration and reads no clock. Its outcome is a pure function of the arguments the production code supplies, so it produces the same result on every run regardless of machine load. It is not an elapsed-time assertion.

## Output Summary

All four files of the final test write set were inspected for all three banned determinism forms, producing **twelve verdicts, every one of them ABSENT**. The single literal `time.sleep` match is a negated prose claim inside a module docstring, not a call. The single `wait` definition is a stand-in that returns immediately without waiting and exists to eliminate the wall-clock dependency. The single assertion referencing the grace constant compares a recorded argument value, not an elapsed duration. No added or modified test contains `time.sleep`, a bounded `Event.wait` used as a synchronization delay, or an assertion whose outcome depends on elapsed time.
