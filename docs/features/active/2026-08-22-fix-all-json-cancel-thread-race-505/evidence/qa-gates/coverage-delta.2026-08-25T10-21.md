# Coverage Delta Comparison (Phase 7, [P7-T3])

Timestamp: 2026-08-25T10-21

Command: the two full-suite coverage commands being compared —

- Baseline ([P0-T10]): `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`
- Final ([P6-T4]): `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

The two commands are byte-identical; only the tree state differs. Supporting per-module figures come from [P4-T5] and [P5-T4], and from the `files` entries of the [P6-T4] coverage JSON read with:

`poetry run python -c "import json;d=json.load(open('artifacts/python/coverage.json'));..."`

EXIT_CODE: 0

## Measurement rule applied throughout

Every repository-wide figure below is read only from `artifacts/python/coverage.json`: line coverage from `totals.percent_statements_covered` and branch coverage from `totals.percent_branches_covered`. No figure is derived from the terminal `TOTAL` row's `Cover` column, which is `totals.percent_covered`, the combined statements-plus-branches ratio and a different statistic.

## Group 1 — Baseline repository coverage (from [P0-T10])

| Metric | JSON key | Value (percent) |
| --- | --- | --- |
| Line | `totals.percent_statements_covered` | **92.6086956521739** |
| Branch | `totals.percent_branches_covered` | **85.19664967225054** |

Source artifact: `../baseline/pytest-coverage.2026-08-25T09-17.md`.

## Group 2 — Post-change repository coverage (from [P6-T4])

| Metric | JSON key | Value (percent) | Threshold | Verdict |
| --- | --- | --- | --- | --- |
| Line | `totals.percent_statements_covered` | **92.6302414231258** | at least 85 | Satisfied |
| Branch | `totals.percent_branches_covered` | **85.21485797523671** | at least 75 | Satisfied |

Source artifact: `final-pytest-coverage.2026-08-25T10-14.md`.

### Delta

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Line | 92.6086956521739 | 92.6302414231258 | **+0.0215457709518887** |
| Branch | 85.19664967225054 | 85.21485797523671 | **+0.01820830298616727** |

Both deltas are positive, so there is no coverage regression at the repository level. The magnitudes are small because the change adds a small number of statements to a 14953-statement denominator while covering all of them.

## Group 3 — New-or-changed-code coverage

### 3a. The lines added inside `_runner` by [P5-T3] (`scripts/dev_tools/fix_all_runtime.py`)

The added executable lines, in post-change numbering, are **142** (`try:`), **143** (`result = func()`), **144** (`except Exception as exc:`), and **152** (the `api.BranchResult(` call spanning 152-157, attributed by coverage to its first line). Lines 145-151 are comments and carry no statement.

| Source | Line coverage of the module | Branch coverage of the module | Missing lines | Added lines missing |
| --- | --- | --- | --- | --- |
| [P5-T4] targeted run | 85.36585365853658 | 90.9090909090909 | `50-69, 77` | **0** |
| [P6-T4] full-suite run | **98.78048780487805** | **95.45454545454545** | `[77]` | **0** |

Under the full suite the module misses exactly one line, **77**, the injected-runner-factory short-circuit. Line 77 is a pre-existing line, is not one of the four added lines, and is not touched by this change. The intersection of the added-line set `{142, 143, 144, 152}` with the missing-line list is empty under both measurements, and [P5-T4] additionally confirmed all four present in `executed_lines` rather than merely absent from `missing_lines`.

**Every line added by [P5-T3] is covered. Zero added lines are uncovered.**

### 3b. `scripts.dev_tools.fix_all_branches` lines 100 to 118 (from [P4-T5])

That range is the json lane's cancel logic: the first check at line 102, the grace wait at 111-112, the second check at 113, and the two `Canceled` returns at 103-107 and 114-118.

| Source | Line coverage of the module | Branch coverage of the module | Missing lines | Lines 100-118 missing |
| --- | --- | --- | --- | --- |
| [P4-T5] targeted run (this test file alone) | 31.70731707317073 | 33.333333333333336 | `94-96, 137-139, 170-246, 273-366` | **0** |
| [P6-T4] full-suite run | **100.0** | **100.0** | `[]` (empty) | **0** |

The [P4-T5] percentages are the module's coverage under `tests/scripts/dev_tools/test_fix_all_json_cancel.py` alone, which never enters the shell and PowerShell branch functions in the same module; they are not offered as repository-wide figures. What that task asserted is the missing-line condition, and it held: the largest missing line below the range is 96 and the smallest above it is 137.

Under the full suite the module reaches **100.0 percent line and 100.0 percent branch coverage with an empty missing-lines list**, so no line anywhere in the module — and therefore no line in 100 to 118 — is uncovered.

**No line in the range 100 to 118 is reported as uncovered.**

Note that `scripts/dev_tools/fix_all_branches.py` is a read-only file for this fix; it is not in the write set (confirmed at [P7-T2]). The coverage recorded here is new coverage of pre-existing production lines contributed by the added tests, not coverage of changed lines.

## Output Summary

All reported values are numeric; no placeholder and no `UNVERIFIED` literal appears.

- Baseline repository coverage: line **92.6086956521739**, branch **85.19664967225054**.
- Post-change repository coverage: line **92.6302414231258** (at least 85 — satisfied), branch **85.21485797523671** (at least 75 — satisfied).
- Delta: line **+0.0215457709518887**, branch **+0.01820830298616727**. Both positive; no regression.
- New-or-changed-code coverage: all four lines added inside `_runner` (142, 143, 144, 152) are covered, with the module at 98.78048780487805 percent line and 95.45454545454545 percent branch under the full suite and only pre-existing line 77 missing. `scripts.dev_tools.fix_all_branches` lines 100 to 118 are fully covered, with the module at 100.0 percent line and 100.0 percent branch and an empty missing-lines list under the full suite.
- **No changed line is reported as uncovered.**
