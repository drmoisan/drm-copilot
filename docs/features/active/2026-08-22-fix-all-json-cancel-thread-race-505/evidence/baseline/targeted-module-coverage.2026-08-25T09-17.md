# Baseline — Targeted Module Coverage (`fix_all_runtime`, `fix_all_branches`)

- **Task:** [P0-T11]
- **Issue:** #505

Timestamp: 2026-08-25T09-17

Command: `poetry run pytest --cov=scripts.dev_tools.fix_all_runtime --cov=scripts.dev_tools.fix_all_branches --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_failure_paths.py tests/scripts/dev_tools/test_fix_all_branches.py`

EXIT_CODE: 0

Test result: `49 passed in 0.44s`.

## The Four Required Numeric Percentages

Read from `artifacts/python/coverage.json`, from each module's entry under `files`, key `summary`.
The JSON `files` keys are OS-native, so on this Windows host they appear with backslash separators.

| Module | JSON `files` key | `percent_statements_covered` (line) | `percent_branches_covered` (branch) |
| --- | --- | --- | --- |
| `scripts.dev_tools.fix_all_runtime` | `scripts\dev_tools\fix_all_runtime.py` | **98.73417721518987** | **95.45454545454545** |
| `scripts.dev_tools.fix_all_branches` | `scripts\dev_tools\fix_all_branches.py` | **96.34146341463415** | **95.83333333333333** |

Terminal `term-missing` report for the same run (its `Cover` column is the combined
statements-plus-branches ratio and is not the source of either figure above):

```
Name                                    Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\fix_all_branches.py      82      3     24      1    96%   103-105
scripts\dev_tools\fix_all_runtime.py       79      1     22      1    98%   77
TOTAL                                     161      4     46      2    97%
```

## Missing Lines and Branches (from the JSON report)

| Module | `missing_lines` | `missing_branches` |
| --- | --- | --- |
| `scripts\dev_tools\fix_all_branches.py` | `[103, 104, 105]` | `[[102, 103]]` |
| `scripts\dev_tools\fix_all_runtime.py` | `[77]` | `[[75, 77]]` |

## Why the `fix_all_branches.py` Missing Range Is the Defect Itself

Lines 103 through 105 are the body of the **first** cancel check in `run_json_branch`:

```python
102:    if cancel_event.is_set() and not complete_all:
103:        output = branch_stream.getvalue()
104:        emit_status_transition("json", "FAIL")
105:        return api.BranchResult(
106:            name="json", success=False, output=output, failed_step="Canceled"
107:        )
```

The uncovered branch `[102, 103]` is the True edge out of line 102. In this baseline run, the first
cancel check never fired: every existing cancel test reached the cancel state only after the
wall-clock grace wait at line 112, and returned through the **second** cancel check at line 113.

That is the race the plan repairs, measured rather than argued. The two tests named in the plan's
Scope of the Fix section pass in this run, but they pass through the timing-dependent path, not
through the first check the plan says a correctly ordered run must hit. The plan's candidate B
repair (ordered synchronous thread stand-in) is what makes the Python lane's failure precede the
JSON lane so that line 102's True edge is taken deterministically, and the plan's candidate A tests
([P4-T2] through [P4-T4], outside this execution's scope) are what cover all three cancel branches
directly. Both figures in this artifact are therefore the pre-change reference point that
[P4-T5] and [P7-T3] compare against.

Output Summary: Targeted baseline captured with exit code 0 and 49 tests passed. Four numeric
percentages recorded: `scripts.dev_tools.fix_all_runtime` line **98.73417721518987** percent and
branch **95.45454545454545** percent; `scripts.dev_tools.fix_all_branches` line **96.34146341463415**
percent and branch **95.83333333333333** percent. Missing lines are `fix_all_branches.py` 103-105
with missing branch edge `[102, 103]`, and `fix_all_runtime.py` line 77 with missing branch edge
`[75, 77]`. The `fix_all_branches.py` 103-105 gap is the first cancel check in `run_json_branch`,
whose True edge no existing test reaches — direct measured confirmation of the timing dependency
this fix removes.
