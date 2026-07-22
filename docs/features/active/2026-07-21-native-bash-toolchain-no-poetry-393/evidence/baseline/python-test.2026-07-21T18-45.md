# Baseline — Python Tests and Coverage (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Result: 2069 passed in ~16s. No failures, no errors.
- Combined headline coverage (TOTAL row): 87%.
- Statements: 12474 total, 1336 missed -> line coverage = 11138/12474 = 89.3%.
- Branches: 4530 total, 564 partial -> branch coverage = 3966/4530 = 87.5%.
- Both exceed policy thresholds (>= 85% line, >= 75% branch).
- Per-file target line: `scripts/dev_tools/shell_qc.py` = 222 statements, 222 missed,
  84 branches, 0% coverage (missing 3-491). This is the dominant untested Python file;
  its removal in Phase 3 removes 222 uncovered statements and 84 branches from the
  denominator (expected upward effect on aggregate coverage, quantified at P3-T6/P5-T8).
