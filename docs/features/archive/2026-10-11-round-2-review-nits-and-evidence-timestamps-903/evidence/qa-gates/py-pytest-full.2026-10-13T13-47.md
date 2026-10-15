# Python Full-Suite Coverage (P12-T4)

Timestamp: 2026-10-13T13-47
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/scratch-903/py-coverage-final-903.json" -q
EXIT_CODE: 0
HEAD: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
Loop-Iteration: 2

Run from `<worktree>`; stdout and stderr captured to `artifacts/scratch-903/py-pytest-full-iter2-903.txt` (not committed). Run started 2026-10-13T13-45 UTC.

## Pytest summary line

```
7094 passed, 6 skipped in 88.55s (0:01:28)
```

- Passed: 7094 (baseline 7065)
- Failed: 0
- Skipped: 6 (the same six pre-existing skips recorded in the P0-T19 baseline)

## TOTAL row

```
Name     Stmts   Miss Branch BrPart  Cover
TOTAL    17638   1094   6368    505    92%
```

## Changed production module row

```
scripts\dev_tools\_blast_radius_token_shapes.py    27    0    10    0   100%
```

## P0-T19 failures still failing

None. P0-T19 recorded 0 failed tests, and this run has 0 failed tests.

Output Summary: PASS. 7094 passed, 0 failed, 6 skipped (pre-existing). TOTAL 17638 statements, 1094 missed, 6368 branches, 505 partial, 92% combined cover. Coverage JSON written to `artifacts/scratch-903/py-coverage-final-903.json` for P12-T5.
