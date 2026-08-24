# Phase 0 Baseline — Pytest with Coverage (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-18
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Test result: 1704 passed, 1 skipped in 8.69s.
- Skipped test at baseline: `tests/scripts/dev_tools/discovery/test_init_flow.py:216 test_schema_conformance_pending_issue_9002` (reason recorded: "blocked pending legacy-discovery-schemas issue 9002: no schema files exist in the repository yet"). This is the PARTIAL AC-9 item to be re-enabled in this remediation cycle.
- Coverage (numeric, from coverage.py totals):
  - Line coverage: 88.16% (9951 covered of 11287 statements).
  - Branch coverage: 78.9% (3350 covered of 4246 branches).
  - Combined percent_covered (pytest-cov TOTAL headline): 85.63% (displayed as 86%).
- Coverage LCOV written to artifacts/python/lcov.info.
