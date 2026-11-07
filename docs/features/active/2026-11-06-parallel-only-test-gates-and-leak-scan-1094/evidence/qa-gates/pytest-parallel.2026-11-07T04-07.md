# Pytest Parallel Gate (Remediation Cycle)

Timestamp: 2026-11-07T04-07
Command: PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/r-pytest-coverage.json --junitxml=SCRATCH/r-pytest-junit.xml
EXIT_CODE: 0
Output Summary: 16103 passed, 6 skipped, 0 failures, 0 errors in 168.32 s (JUnit: 16109 tests). JSON totals: line 96.71% (32270 of 33367 statements), branch 93.66% (11722 of 12516 branches). artifacts/python/lcov.info, written after the run start: line 96.71% (32270 of 33367), branch 93.66% (11722 of 12516). Per root of [tool.coverage.run] source: src 0 files measured (0 of 0 statements); scripts/dev_tools 226 files, line 94.27% (16522 of 17526), branch 89.11% (5669 of 6362); packages/discovery-runtime/src 140 files, line 99.41% (15748 of 15841), branch 98.36% (6053 of 6154). Nothing was excluded: no source or omit change and no pragma.
