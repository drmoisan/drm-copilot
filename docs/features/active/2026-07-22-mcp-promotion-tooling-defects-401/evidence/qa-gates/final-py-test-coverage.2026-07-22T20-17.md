# Final QA — Python Tests + Coverage (Issue #401)

Timestamp: 2026-07-22T20-17

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term (from repo root)
EXIT_CODE: 0

Output Summary:
- Tests: 1982 passed.
- TOTAL coverage: 88% combined (statements 12252, missed 1114, branches 4446, partial 564).
  - Overall line coverage = (12252 - 1114) / 12252 = 90.9% (>= 85%).
  - Overall branch coverage = (4446 - 564) / 4446 = 87.3% (>= 75%).
- Per-file scripts/dev_tools/potential_to_issue.py: 200 statements, 18 missed, 66 branches, 21 partial, 85% (combined). Line coverage = (200-18)/200 = 91%.
- scripts/dev_tools/potential_to_issue_content.py: 95 statements, 4 missed, 28 branches, 6 partial, 92% (unchanged; not modified by this change set).
- The changed module potential_to_issue.py reports the identical statement/branch/miss/partial counts as the P0-T10 baseline (200/18/66/21, 85%), confirming no coverage regression from the Defect B branch reorder; the (bug, minor-audit) reordered path is exercised by the new/updated pytest cases.
