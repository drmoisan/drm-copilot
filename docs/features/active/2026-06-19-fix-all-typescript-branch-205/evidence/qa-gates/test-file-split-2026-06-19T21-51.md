# QA Gate — test_fix_all.py 500-line split (issue 205)

Timestamp: 2026-06-19T21-51

## Scope

Test-only split of `tests/scripts/dev_tools/test_fix_all.py` (733 lines, over the 500-line
hard limit) into two cohesive files under 500 lines each. No production code changed.

Touched files:
- `tests/scripts/dev_tools/test_fix_all.py` (modified — core orchestration tests)
- `tests/scripts/dev_tools/test_fix_all_branches.py` (created — per-branch toolchain,
  status/board presentation, shell-skip, final summary, and subprocess-runner tests)

## Line Counts

- `tests/scripts/dev_tools/test_fix_all.py`: 434 lines (was 733)
- `tests/scripts/dev_tools/test_fix_all_branches.py`: 393 lines
- Both under the 500-line limit.

## Test Count Parity

- Before split: 34 tests collected in `test_fix_all.py`.
- After split: 34 tests collected across both files (16 + 18).
- No tests added, removed, merged, or weakened. Shared helpers (`make_result`,
  `FakeRunner`, `FakeRunnerFactory`, `build_logger`, `read_log`,
  `base_success_responses`) duplicated into each file per the repository's existing
  split-file pattern (no shared conftest is used in this directory).

## Toolchain Results

Command: `poetry run black --check .`
EXIT_CODE: 0
Output Summary: 255 files would be left unchanged. No reformatting required.

Command: `poetry run ruff check .`
EXIT_CODE: 0
Output Summary: All checks passed. (Ruff auto-fixed one unused `pytest` import and import
ordering in the new file during the loop; loop restarted and re-passed clean.)

Command: `poetry run pyright`
EXIT_CODE: 0
Output Summary: 0 errors, 0 warnings, 0 informations (full repo).

Command: `poetry run pytest tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary: 34 passed.

## Coverage Delta (zero regression)

| Module | Baseline (line / partial branches) | Post-split | Delta |
|---|---|---|---|
| scripts/dev_tools/fix_all.py | 85% (18 miss, 16 partial) | 85% (18 miss, 16 partial) | 0 |
| scripts/dev_tools/fix_all_runtime.py | 83% (34 miss, 14 partial) | 83% (34 miss, 14 partial) | 0 |

Identical missing-line and partial-branch sets before and after the split. No coverage
regression on changed lines (test code only; production coverage unchanged).
