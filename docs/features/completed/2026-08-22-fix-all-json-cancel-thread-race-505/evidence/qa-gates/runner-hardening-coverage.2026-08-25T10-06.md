# QA Gate — Targeted `fix_all_runtime` Coverage After the `_runner` Hardening

- **Task:** [P5-T4]
- **Issue:** #505

Timestamp: 2026-08-25T10-06

Command: `poetry run pytest --cov=scripts.dev_tools.fix_all_runtime --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json tests/scripts/dev_tools/test_fix_all_json_cancel.py tests/scripts/dev_tools/test_fix_all_failure_paths.py tests/scripts/dev_tools/test_fix_all.py`

EXIT_CODE: 0

## Test Result

`32 passed in 0.45s` — 4 from `test_fix_all_json_cancel.py`, 12 from
`test_fix_all_failure_paths.py`, and 16 from `test_fix_all.py`. Zero failures, zero skips.

## Coverage of `scripts.dev_tools.fix_all_runtime`

Read from `artifacts/python/coverage.json`, entry `files["scripts\dev_tools\fix_all_runtime.py"]`,
object `summary`:

| Metric | JSON key | Value (percent) |
| --- | --- | --- |
| Line coverage | `percent_statements_covered` | **85.36585365853658** |
| Branch coverage | `percent_branches_covered` | **90.9090909090909** |

The terminal `Cover` column reads `87%`. That is the combined statements-plus-branches ratio and is
**not** recorded as either figure above; both figures come from the two named JSON keys.

## Added-Line Assertion — every line added by [P5-T3] is covered

[P5-T3] replaced the single statement `result = func()` with a `try` / `except Exception` block. Its
added **executable** lines, in post-change numbering, are:

| Line | Statement |
| --- | --- |
| 142 | `try:` |
| 143 | `result = func()` (relocated into the `try` block) |
| 144 | `except Exception as exc:` |
| 152 | `result = api.BranchResult(` — the multi-line call spanning 152-157, which coverage attributes to its first line |

Lines 145-151 are comment lines and carry no statement, so coverage does not measure them.

Missing lines reported for the module, read from the `missing_lines` list of the same JSON entry
(identical to the terminal `Missing` column, `50-69, 77`):

```
50, 51, 52, 62, 63, 64, 65, 66, 67, 68, 69, 77
```

Verdict: **zero added lines are missing.** The intersection of the added-line set
`{142, 143, 144, 152}` with the missing-line list is empty. The complementary check confirms
presence rather than mere absence: all four of `142, 143, 144, 152` appear in the same JSON entry's
`executed_lines` list. The twelve remaining missing lines are the interactive status-board rendering
path at lines 50-52 and 62-69 and the injected-runner-factory short-circuit at line 77, none of
which is touched by this change.

Output Summary: `32 passed`, EXIT_CODE 0. Targeted coverage of `scripts.dev_tools.fix_all_runtime`
is **line 85.36585365853658 percent** (`percent_statements_covered`) and **branch 90.9090909090909
percent** (`percent_branches_covered`), both read from `artifacts/python/coverage.json`. The
missing-line list is `50-69, 77`, so **zero of the four lines added by [P5-T3] (142, 143, 144, 152)
are missing**; all four are confirmed present in `executed_lines`. The new
`test_runner_records_failing_result_when_branch_raises` covers both the `try` success path and the
`except` recording path.
