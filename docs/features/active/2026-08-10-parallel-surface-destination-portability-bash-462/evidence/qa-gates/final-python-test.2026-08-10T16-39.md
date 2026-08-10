# Final QA — Python Tests with Coverage

Timestamp: 2026-08-10T16-39

Task: [P7-T4]
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

## Output Summary

- Result: **3774 passed, 5 skipped**, 0 failed, in 15.33s.
- Coverage totals row: `TOTAL 14396 1108 5286 556 90%`
  - Statements: 14396
  - Statements missed: 1108
  - Branches: 5286
  - Partial branches: 556
- **Line coverage: 92.30%** ((14396 - 1108) / 14396) — threshold >= 85%, **PASS**
- **Branch coverage: 89.48%** ((5286 - 556) / 5286) — threshold >= 75%, **PASS**
- coverage.py combined total reported by the terminal report: 90%

## Delta Against Baseline

| Metric | Baseline ([P0-T3]) | Final ([P7-T4]) | Delta |
| --- | --- | --- | --- |
| Tests passed | 3665 | 3774 | +109 |
| Tests skipped | 0 | 5 | +5 |
| Line coverage | 92.30% | 92.30% | 0.00 |
| Branch coverage | 89.46% | 89.48% | +0.02 |
| Statements | 14396 | 14396 | 0 |
| Partial branches | 557 | 556 | -1 |

The +109 tests are the two parity suites added by [P2-T3] and [P2-T4]: 31 cohort cases and 83
manifest cases, less the 5 accessor cases that skip for the five fixtures whose frontmatter never
parses. Statement count is unchanged because this feature added no Python production code — the
Python side of #462 is test-only, which is why line coverage is flat.

The five skips are accessor cases for `manifest_m1_missing_opening_fence`,
`manifest_m1_unterminated_fence`, `manifest_m1_non_mapping_frontmatter`,
`manifest_m1_empty_frontmatter`, and `manifest_m1_yaml_parse_failure`. Those fixtures declare no
accessor expectation because there is no parsed mapping to hand the accessors; their validator
cases run and pass.

No coverage regression on changed lines: no Python production line changed.
