# QA Gate — Pytest Coverage (#359, P5-T4)

Timestamp: 2026-07-18T10-35
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:
- Tests: 1624 passed, 0 failed (baseline was 1537 passed; +87 new discovery tests).
- Overall coverage (percent_covered): 85.20%.
- Line coverage: 87.76% (covered_lines 9574 / num_statements 10909; missing_lines 1335).
- Branch coverage: 78.39% (covered_branches 3225 / num_branches 4114).
- `scripts/dev_tools/validate_json.py` file-level coverage: 74% (unchanged from baseline; the new tests
  exercise the already-covered relative-`$schema` and `jsonschema` validation paths, so no production
  lines regressed and none newly regressed).

Production coverage totals are byte-identical to baseline (10909 / 1335 / 4114 / 549), confirming no
regression. Both thresholds are met: line 87.76% >= 85%, branch 78.39% >= 75%. Numeric values were
extracted from `poetry run coverage json` totals for precision.
