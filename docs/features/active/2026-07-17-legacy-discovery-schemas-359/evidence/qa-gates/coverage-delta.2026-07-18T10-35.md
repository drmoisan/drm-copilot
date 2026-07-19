# QA Gate — Coverage Delta and No-Regression Verification (#359, P5-T6)

Timestamp: 2026-07-18T10-35

## Sources

- Baseline (P0-T5): `evidence/baseline/baseline-pytest-coverage.2026-07-18T10-12.md`
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- Post-change (P5-T4): `evidence/qa-gates/qa-pytest-coverage.2026-07-18T10-35.md`
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

## Numeric Comparison

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Tests passed | 1537 | 1624 | +87 |
| Overall percent_covered | 85.20% | 85.20% | 0.00 |
| Line coverage | 87.76% | 87.76% | 0.00 |
| Branch coverage | 78.39% | 78.39% | 0.00 |
| Statements (num / miss) | 10909 / 1335 | 10909 / 1335 | 0 / 0 |
| Branches (total / covered) | 4114 / 3225 | 4114 / 3225 | 0 / 0 |

## New / Changed-Code Coverage

This feature adds no new production Python. The only production module the new tests exercise is
`scripts/dev_tools/validate_json.py` (unchanged in this feature). Its file-level coverage is 74% at both
baseline and post-change; the new tests drive the already-covered relative-`$schema` and `jsonschema`
validation paths, so no production line changed and no changed-line coverage regression is possible.

Because there are zero changed production lines, the "no regression on changed lines" contract is
satisfied vacuously, and the added test code is excluded from coverage measurement per
`[tool.coverage.run] omit` (`tests/*`).

## Threshold Verification

- Line coverage 87.76% >= 85% required: PASS.
- Branch coverage 78.39% >= 75% required: PASS.
- No regression on changed lines: PASS (production coverage totals byte-identical to baseline).

## Outcome

PASS. All required coverage values are available and numeric; both thresholds are met and no regression
occurred.
