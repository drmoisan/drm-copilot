# QC Python Coverage (Remediation Cycle 1)

Timestamp: 2026-11-06T18-08
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json -n auto
EXIT_CODE: 0
Output Summary:
- 16099 passed, 0 failed, 6 skipped (160.93s). No test failure.
- artifacts/python/lcov.info was written (935795 bytes, non-empty).
- Repo-wide totals from artifacts/python/coverage.json: line coverage 48.36% (16522 of 33367 statements covered), branch coverage 45.29% (5669 of 12516 branches covered).
- Threshold result: line >= 85% NOT MET, branch >= 75% NOT MET at repo-wide scope. The coverage source set in pyproject.toml is src, scripts/dev_tools, packages/discovery-runtime/src.
- The only Python file changed by this branch relative to the merge base is a test file (tests/scripts/dev_tools/test_discovery_documentation_contracts.py); no production Python file changed, so the repo-wide shortfall is not attributable to the diff. Not verified against the merge base in this run.
