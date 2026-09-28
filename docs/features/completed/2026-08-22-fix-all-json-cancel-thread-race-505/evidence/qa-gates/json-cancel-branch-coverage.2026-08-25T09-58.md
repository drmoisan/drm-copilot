# QA Gate — Targeted `fix_all_branches` Coverage from the New Cancel Tests

- **Task:** [P4-T5]
- **Issue:** #505

Timestamp: 2026-08-25T09-58

Command: `poetry run pytest --cov=scripts.dev_tools.fix_all_branches --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json tests/scripts/dev_tools/test_fix_all_json_cancel.py`

EXIT_CODE: 0

## Test Result

`3 passed in 0.11s`. The three tests collected are the candidate A tests added by [P4-T2] through
[P4-T4]: `test_run_json_branch_canceled_at_first_check`,
`test_run_json_branch_canceled_during_grace_wait`, and
`test_run_json_branch_complete_all_runs_validate`.

## Coverage of `scripts.dev_tools.fix_all_branches`

Read from `artifacts/python/coverage.json`, entry `files["scripts\dev_tools\fix_all_branches.py"]`,
object `summary`:

| Metric | JSON key | Value (percent) |
| --- | --- | --- |
| Line coverage | `percent_statements_covered` | **31.70731707317073** |
| Branch coverage | `percent_branches_covered` | **33.333333333333336** |

These two percentages are the module's coverage **under this single test file alone**. This command
deliberately runs only `tests/scripts/dev_tools/test_fix_all_json_cancel.py`, so the shell and
PowerShell branch functions in the same module are never entered and their lines are counted as
missing. The figure is therefore not, and is not offered as, the module's repository-wide coverage;
that is measured by [P6-T4]. What this task is asserting is the missing-line condition below.

The terminal `Cover` column reads `32%`. It is the combined statements-plus-branches ratio and is
**not** recorded as either figure above; both figures come from the two named JSON keys.

## Missing-Line Assertion — lines 100 to 118 of `scripts/dev_tools/fix_all_branches.py`

Requirement: no line in the range 100 to 118 is listed as missing. That range is the json lane's
three cancel checks — the first check at line 102, the grace wait at lines 111-112, and the second
check at line 113 — and the two `Canceled` returns at lines 103-107 and 114-118.

Missing lines reported for the module, read from the `missing_lines` list of the same JSON entry
(identical to the terminal report's `Missing` column, `94-96, 137-139, 170-246, 273-366`):

```
94, 95, 96, 137, 138, 139, 170, 171, 172, 174, 175, 189, 190, 191, 195, 196, 210, 211, 212,
216, 217, 218, 228, 229, 230, 231, 233, 234, 235, 236, 237, 239, 244, 245, 246, 273, 274, 275,
277, 278, 297, 298, 299, 306, 307, 326, 327, 328, 335, 336, 355, 356, 357, 364, 365, 366
```

Verdict: **no line between 100 and 118 inclusive appears in that list.** The largest missing line
below the range is 96 and the smallest above it is 137. Every statement of the json lane's cancel
logic is executed by the three new tests.

Output Summary: `3 passed`, EXIT_CODE 0. Targeted coverage of `scripts.dev_tools.fix_all_branches`
under this test file alone is **line 31.70731707317073 percent**
(`percent_statements_covered`) and **branch 33.333333333333336 percent**
(`percent_branches_covered`), both read from `artifacts/python/coverage.json`. The missing-line list
is `94-96, 137-139, 170-246, 273-366`, so **no line in the range 100 to 118 is missing**: the three
new single-threaded tests cover all three cancel checks, the grace wait, and both `Canceled` return
paths of the json lane.
