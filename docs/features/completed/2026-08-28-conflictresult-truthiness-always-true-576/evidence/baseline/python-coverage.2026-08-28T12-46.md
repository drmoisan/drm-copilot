# Scoped Python Coverage Baseline — [P0-T6]

Timestamp: 2026-08-28T12-46

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_conflicts.py --cov=scripts.dev_tools._blast_radius_conflicts --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Verbatim Coverage Table

```
Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\_blast_radius_conflicts.py      58      0     22      0   100%
------------------------------------------------------------------------------------------
TOTAL                                             58      0     22      0   100%
```

Verbatim result line:

```
44 passed in 0.17s
```

## Recorded Module-Row Values

| Column | Value |
| --- | --- |
| Stmts | 58 |
| Miss | 0 |
| Branch | 22 |
| BrPart | 0 |
| Cover | 100 percent |
| Missing | empty |

Output Summary: `EXIT_CODE: 0` and `44 passed`. The dotted coverage argument
`scripts.dev_tools._blast_radius_conflicts` resolved and collected data: the term-missing table names
the module with 58 statements, 0 missed, 22 branches, 0 partial branches, and a Cover value of 100
percent. The string `No data was collected` does not appear anywhere in the output. The table prints
one combined `Cover` column; no separate branch percentage is printed by this or any other coverage
run in this plan, so none is read. The LCOV reporter supplied by the project `addopts` also wrote
`artifacts/python/lcov.info`, which is why `--cov-report=term-missing` is passed explicitly on every
coverage command in this plan.
