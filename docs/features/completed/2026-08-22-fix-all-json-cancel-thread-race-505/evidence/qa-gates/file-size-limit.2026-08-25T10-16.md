# Constraint Verification — File-Size Limit (Phase 7, [P7-T1])

Timestamp: 2026-08-25T10-16

Command (PowerShell, run from the worktree root):

```
@('scripts/dev_tools/fix_all_runtime.py','tests/scripts/dev_tools/test_fix_all_failure_paths.py','tests/scripts/dev_tools/test_fix_all.py','tests/scripts/dev_tools/fix_all_thread_stubs.py','tests/scripts/dev_tools/test_fix_all_json_cancel.py') | ForEach-Object { $c = @(Get-Content $_); '{0}: total={1} nonblank={2}' -f $_, $c.Count, ($c | Measure-Object -Line).Lines }
```

EXIT_CODE: 0

## Measurement convention

`Get-Content` piped to `Measure-Object -Line` reports NON-BLANK lines, because an empty string contributes zero lines to that cmdlet's tally. The 500-line limit in `.claude/rules/general-code-change.md` is measured against the TOTAL physical line count, so both figures are recorded and the total is the authoritative one. This is the same convention established at [P0-T6] in `../baseline/repo-state.2026-08-25T09-17.md`.

## Line counts of the five files written by this change

| File | Baseline total | Final total (authoritative) | Non-blank | At or below 500 |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/fix_all_runtime.py` | 183 | **198** | 172 | Yes |
| `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | 492 | **472** | 390 | Yes |
| `tests/scripts/dev_tools/test_fix_all.py` | 434 | **447** | 387 | Yes |
| `tests/scripts/dev_tools/fix_all_thread_stubs.py` | 0 (new) | **176** | 133 | Yes |
| `tests/scripts/dev_tools/test_fix_all_json_cancel.py` | 0 (new) | **396** | 319 | Yes |

Output Summary: Five numeric line counts were measured, one per file written by this change: 198, 472, 447, 176, and 396. Every count is at or below the 500-line limit, so the file-size constraint is satisfied for the whole write set. The largest file, `tests/scripts/dev_tools/test_fix_all_failure_paths.py` at 472 lines, has 28 lines of headroom — an improvement on its 8 lines of baseline headroom, because relocating `_SkipBranchThread` to the shared stub module removed more lines than the repair added.

## Variance against the plan's File-Size Budget projections

The plan's File-Size Budget table carried projections, not acceptance thresholds; the stated acceptance is solely that every count is at or below 500. The observed variances are recorded for accuracy:

- `scripts/dev_tools/fix_all_runtime.py`: projected about 191, actual 198 (+7). The `_runner` exception handler needed slightly more than the eight projected lines to record the failing `BranchResult` and reapply the cancel rule.
- `tests/scripts/dev_tools/test_fix_all_failure_paths.py`: projected about 462, actual 472 (+10).
- `tests/scripts/dev_tools/test_fix_all.py`: projected about 441, actual 447 (+6).
- `tests/scripts/dev_tools/fix_all_thread_stubs.py`: budget 160, actual 176 (+16).
- `tests/scripts/dev_tools/test_fix_all_json_cancel.py`: budget 300, actual 396 (+96). The largest variance, attributable to the second `complete_all=False` case added to `test_runner_records_failing_result_when_branch_raises` at [P5-T1] to close the second clause of the `_runner` acceptance criterion by test rather than by code inspection.

No variance approaches the 500-line limit; the closest file retains 28 lines of headroom.

## Pre-existing out-of-scope observation

`scripts/dev_tools/fix_all.py` remains at 628 lines and is still over the 500-line limit. It is read-only for this fix, is not in the write set measured above, and was not split. This is recorded as an out-of-scope observation in the plan and the spec and is to be filed separately.
