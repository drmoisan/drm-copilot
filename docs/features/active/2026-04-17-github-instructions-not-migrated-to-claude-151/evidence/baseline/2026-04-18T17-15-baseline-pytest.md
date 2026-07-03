# Baseline — Pytest with Coverage

Timestamp: 2026-04-18T17-15
Command: poetry run pytest --cov --cov-report=term
EXIT_CODE: 1 (baseline has 1 pre-existing failure, unrelated to this task)

Output Summary:
- Total tests: 972 collected
- Passed: 971
- Failed: 1 (pre-existing, unrelated)
  - tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py::test_minor_audit_customization_mirrors_match_root_contracts
  - Concerns policy-doc mirror parity between root skill text and customization mirror.
  - Unrelated to the fixture rename or hard-lock resolver feature.
- Total coverage: 83%
- Key in-scope files:
  - scripts/dev_tools/resolve_hard_lock_prompt.py: 108 stmts, 3 miss, 97%
  - extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py: (uncovered in scripts aggregate; covered via bundled test suite separately)
  - tests/conftest.py: not reported (test code excluded from coverage)

Zero-regression gate for this task:
- Pytest failures must remain at 1 (the pre-existing unrelated failure).
- No new failures introduced by Phase 1 rename or Phase 2 feature.
- Per-file coverage must stay at >= baseline for all touched files.
