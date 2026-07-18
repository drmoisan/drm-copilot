# Baseline — Pytest Coverage (#359)

Timestamp: 2026-07-18T10-12
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:
- Tests: 1537 passed.
- Overall coverage (percent_covered): 85.20%.
- Line coverage: 87.76% (covered_lines 9574 / num_statements 10909; missing_lines 1335).
- Branch coverage: 78.39% (covered_branches 3225 / num_branches 4114).
- `scripts/dev_tools/validate_json.py` file-level coverage: 74% (this file's uncovered branches are the target of the new tests added by this feature; it must not decrease).

Numeric values were extracted from `poetry run coverage json` totals for precision.
