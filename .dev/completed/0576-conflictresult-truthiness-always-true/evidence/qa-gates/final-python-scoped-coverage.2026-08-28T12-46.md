# Final Scoped Python Coverage — [P6-T5]

Timestamp: 2026-08-28T12-46

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py tests/scripts/dev_tools/test_blast_radius_invariants.py --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

This run was taken after the final formatter pass at [P6-T1] and the final linter pass at [P6-T2],
neither of which rewrote any file.

## Verbatim Coverage Table

```
Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\_blast_radius_conflicts.py      60      0     22      0   100%
------------------------------------------------------------------------------------------
TOTAL                                             60      0     22      0   100%
Coverage LCOV written to file artifacts/python/lcov.info
============================= 112 passed in 0.24s =============================
```

## Three-Line Comparison

1. **[P0-T6] baseline Cover value:** 100 percent (Stmts 58, Miss 0, Branch 22, BrPart 0).
2. **Post-change Cover value:** 100 percent (Stmts 60, Miss 0, Branch 22, BrPart 0). Not below the
   baseline value.
3. **Changed-line coverage of the added method:** 100 percent. The added `__bool__` contributes
   exactly two statements — the `def __bool__(self) -> bool:` header at line 136 and the
   `return self.conflict` body at line 149 — which is the whole of the 58-to-60 statement increase.
   The `Miss` column reads 0 and the `Missing` column is empty, so neither line is listed as
   uncovered. Both branch directions are exercised by
   `test_bool_is_false_for_a_disjoint_pair`, `test_bool_is_true_for_an_overlapping_pair`,
   `test_bool_matches_the_conflict_field_on_constructed_results`, and the ten cases of
   `test_boolean_projection_agrees_with_the_conflict_field`.

## Acceptance Checks

| Check | Result |
| --- | --- |
| `EXIT_CODE: 0` | Yes |
| Post-change Cover value is 100 percent | Yes |
| Post-change Cover value not below the baseline value | Yes; 100 equals 100 |
| `Miss` column reads 0 | Yes |
| `BrPart` column reads 0 | Yes |
| The added method's lines are absent from the `Missing` column | Yes; the `Missing` column is empty for the module row |
| Output does not contain `No data was collected` | Yes; a `grep -c` for that string over the captured output returns 0 |

Output Summary: `EXIT_CODE: 0` and `112 passed`. The term-missing table names
`scripts\dev_tools\_blast_radius_conflicts.py` with Stmts 60, Miss 0, Branch 22, BrPart 0, and a
Cover value of 100 percent. The three-line comparison records a [P0-T6] baseline Cover value of 100
percent, a post-change Cover value of 100 percent that is not below it, and changed-line coverage of
100 percent for the added method, whose two statements at lines 136 and 149 account for the entire
58-to-60 statement increase and appear in neither the Miss count nor the Missing column. The output
does not contain `No data was collected`, confirmed by a count of 0 occurrences.
