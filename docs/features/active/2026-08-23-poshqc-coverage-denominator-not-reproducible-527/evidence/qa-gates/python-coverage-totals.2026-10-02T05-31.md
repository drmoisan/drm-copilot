# Python Coverage Totals from coverage json (Run B data; issue #527)

Timestamp: 2026-10-02T05-31
Command: poetry -C <ROOT> run coverage json --pretty-print -o artifacts/python/coverage.json; then Grep tool for `"totals"` with -A 14 against <ROOT>/artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary: totals block read from the Run B data file. covered_lines 16129 of num_statements 17244 gives 93.53% line coverage. covered_branches 5406 of num_branches 6230 gives 86.77% branch coverage. The derived line percentage rounds to 94, equal to the Cover value in the Run A TOTAL row. num_branches is greater than zero.

## totals fields (verbatim)

- covered_lines: 16129
- num_statements: 17244
- num_branches: 6230
- covered_branches: 5406

## Derived values

- Line percentage: 16129 / 17244 * 100 = 93.53% (rounds to 94; Run A TOTAL Cover is 94%: MATCH)
- Branch percentage: 5406 / 6230 * 100 = 86.77%

Cross-reference (coverage json fields as printed): percent_statements_covered 93.53398283460913; percent_branches_covered 86.77367576243981.
