# Scoped Python Coverage After the Fix — [P3-T5]

Timestamp: 2026-08-28T12-46

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_blast_radius_invariants.py --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing`, and in the same task `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py`

EXIT_CODE: 0

Both commands exited 0. The exit codes were captured directly from the invoking shell, not through a
pipe.

## Combined Two-File Run

```
................................................                         [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\_blast_radius_conflicts.py      60      0     22      0   100%
------------------------------------------------------------------------------------------
TOTAL                                             60      0     22      0   100%
Coverage LCOV written to file artifacts/python/lcov.info
============================= 112 passed in 0.46s =============================
```

### Test-Count Arithmetic

| Term | Count |
| --- | --- |
| The two files reported before this change | 98 |
| Conflicts-module tests added by this plan (`test_bool_is_false_for_a_disjoint_pair`, `test_bool_is_true_for_an_overlapping_pair`, `test_bool_matches_the_conflict_field_on_constructed_results`, `test_conflict_reason_defines_no_boolean_projection`) | 4 |
| Parametrized invariant cases added by this plan (`test_boolean_projection_agrees_with_the_conflict_field`, one per `RADIUS_PAIRS` entry) | 10 |
| **Total** | **112** |

The observed combined figure is `112 passed`, which equals 98 + 4 + 10.

## Single-File Run

```
...............................                                          [100%]

============================= 48 passed in 0.09s ==============================
```

`48 passed`, which is four more than the `44 passed` recorded at [P0-T6] for the same file, matching
the four conflicts-module tests this plan adds.

## Coverage Table Values

| Column | Baseline ([P0-T6]) | This run | Movement |
| --- | --- | --- | --- |
| Stmts | 58 | 60 | +2 (the `def __bool__` line and its `return self.conflict`) |
| Miss | 0 | 0 | unchanged |
| Branch | 22 | 22 | unchanged; the added method is branchless |
| BrPart | 0 | 0 | unchanged |
| Cover | 100 percent | 100 percent | unchanged |
| Missing | empty | empty | unchanged |

## Threshold Assessment

- The Cover value is 100 percent, at or above the uniform 85 percent line threshold.
- The run is branch-enabled (`--cov-branch` is supplied, and the `Branch` and `BrPart` columns are
  present), and the table prints one combined `Cover` column that includes branch measurement. A
  combined value of 100 percent is therefore at or above the 75 percent branch threshold. No separate
  branch percentage is read, because none is printed.
- `Miss` and `BrPart` both read 0.
- The string `No data was collected` does not appear in the output. The dotted coverage argument
  `scripts.dev_tools._blast_radius_conflicts` resolved and collected data, evidenced by the non-zero
  statement count of 60 on the named module row.

Output Summary: `EXIT_CODE: 0` for both commands. The combined two-file run reports `112 passed`,
equal to the 98 the two files reported before this change plus the 4 conflicts-module tests and the
10 parametrized invariant cases this plan adds. The single-file run reports `48 passed`, four more
than the 44 recorded at [P0-T6]. The term-missing table names
`scripts\dev_tools\_blast_radius_conflicts.py` with a Stmts value of 60, which is at least 58, and a
Cover value of 100 percent, satisfying both the 85 percent line threshold and the 75 percent branch
threshold through the single combined column of the branch-enabled run. The Miss and BrPart columns
both read 0, and the Missing column is empty. The output does not contain `No data was collected`.
This task discharges AC13 and AC14.
