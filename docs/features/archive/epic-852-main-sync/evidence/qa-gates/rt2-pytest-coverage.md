# RT-2 Pytest Coverage Run (scripts.dev_tools)

Timestamp: 2026-10-11T01-35
Task: [P2-T1]
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0

## Verbatim lines

Coverage table header:

```
Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing
```

TOTAL row:

```
TOTAL                                                                 17633   1094   6364    505    92%
```

Report-written lines:

```
Coverage JSON written to file artifacts/python/coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
```

Final pytest summary line:

```
================= 6944 passed, 6 skipped in 72.52s (0:01:12) ==================
```

Output Summary: 6944 passed, 0 failed, 6 skipped. Combined Cover column 92% (17633 statements, 1094 missed, 6364 branches, 505 partial). JSON and LCOV reports written. Separate line and branch percentages are recorded in rt2-py-figures.md from the JSON totals.
