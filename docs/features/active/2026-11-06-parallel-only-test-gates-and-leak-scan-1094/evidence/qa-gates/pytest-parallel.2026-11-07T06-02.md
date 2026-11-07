# Pytest Parallel Gate (Remediation Cycle 3)

Timestamp: 2026-11-07T06-02
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/c3-pytest-coverage.json --junitxml=SCRATCH/c3-pytest-junit.xml
EXIT_CODE: 0
Output Summary: 16103 passed, 6 skipped, 0 failures, 0 errors in 177.80 s (JUnit: 16109 tests). JSON totals: line 96.71% (32270 of 33367 statements), branch 93.66% (11722 of 12516 branches). artifacts/python/lcov.info, written after the run start: line 96.71% (32270 of 33367), branch 93.66% (11722 of 12516). The run covers the bundle parity tests that read the hook files. Nothing was excluded: no source or omit change and no pragma.
