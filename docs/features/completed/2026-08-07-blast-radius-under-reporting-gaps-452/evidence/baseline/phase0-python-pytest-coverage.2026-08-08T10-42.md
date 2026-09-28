# Phase 0 — Python Test and Coverage Baseline (Pytest)

Timestamp: 2026-08-08T10-42
Task: [P0-T6]

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Supplementary command used only to resolve the separate line and branch percentages that the
`term-missing` report combines into a single `Cover` column:
`poetry run coverage json -o artifacts/python/coverage-baseline.json`

## Test counts

```
2835 passed in 13.75s
```

- Passed: 2835
- Failed: 0
- Skipped: 0
- Errors: 0

## Numeric baseline coverage totals

| Metric | Value |
| --- | --- |
| TOTAL line (statement) coverage | 91.71% (12247 / 13354 statements) |
| TOTAL branch coverage | 83.58% (4122 / 4932 branches) |
| Combined `Cover` column reported by term-missing | 90% |

The `term-missing` `TOTAL` row prints `90%`, which is coverage.py's combined line-plus-branch
figure. The separate 91.71% line and 83.58% branch values above are the authoritative numbers for
the >= 85% line and >= 75% branch policy floors, and both floors are met at baseline.

## Per-file baseline coverage for the four in-scope Python modules

| File | Cover | Statements covered | Branches covered |
| --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 100% | 119 / 119 | 58 / 58 |
| `scripts/dev_tools/_blast_radius_validation.py` | 100% | 119 / 119 | 46 / 46 |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 98% | 74 / 75 | 31 / 32 |
| `scripts/dev_tools/compute_blast_radius.py` | 100% | 58 / 58 | 8 / 8 |

`_blast_radius_conflicts.py` line 195 is the single uncovered statement at baseline.

Output Summary: 2835 passed, 0 failed, 0 skipped. Baseline TOTAL line coverage 91.71%, baseline
TOTAL branch coverage 83.58%. Per-file baseline: `_blast_radius_extraction.py` 100%,
`_blast_radius_validation.py` 100%, `_blast_radius_conflicts.py` 98%, `compute_blast_radius.py`
100%. Both policy floors (line >= 85%, branch >= 75%) hold at baseline, so any post-change value
below a floor, or any per-file regression against these percentages, is attributable to this
change set.
