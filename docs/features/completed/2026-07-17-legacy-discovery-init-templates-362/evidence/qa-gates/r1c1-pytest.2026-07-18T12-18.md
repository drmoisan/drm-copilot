# Phase 7 Final QA — Pytest with Coverage (#362, Remediation Cycle 1)

Timestamp: 2026-07-18T12-18
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Test result: 1708 passed, 0 skipped in 8.94s (baseline was 1704 passed, 1 skipped).
- Zero unexpectedly-skipped tests: the previously-skipped `test_schema_conformance_pending_issue_9002` is now implemented and renamed `test_generated_artifacts_conform_to_real_schemas` and passes.
- Discovery test-file confirmations (all passed, zero skips in `tests/scripts/dev_tools/discovery/`):
  - `test_generated_artifacts_conform_to_real_schemas` (validates all seven rendered artifacts against `schemas/discovery/v1/`): PASSED
  - `test_domain_profile_template_parses_with_real_loader` (parses the domain-profile template under the merged #360 loader): PASSED
  - `tests/scripts/dev_tools/discovery/test_package_exports.py` (2 tests guarding the package re-export surface): PASSED
- Coverage (numeric, from coverage.py totals):
  - Line coverage: 88.17% (9954 covered of 11290 statements).
  - Branch coverage: 78.9% (3350 covered of 4246 branches).
  - Combined percent_covered (pytest-cov TOTAL headline): 85.63% (displayed as 86%).
  - Changed production file `scripts/dev_tools/discovery/__init__.py`: 100% line coverage, 0 missing lines.
- Coverage LCOV written to artifacts/python/lcov.info.
