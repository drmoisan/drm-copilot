# Python Coverage Gate (R2, loop pass 3)

Timestamp: 2026-11-03T20-40
Task: [P6-T12]
Command: poetry run pytest -n auto -q -p no:cacheprovider --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1047-p6t12-cov.json (project addopts in effect: -ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config; source list from [tool.coverage.run]); the last pytest run of the plan
EXIT_CODE: 0
Output Summary: artifacts/python/lcov.info exists after the run. 16063 passed, 0 failed, 0 errors, 6 skipped in 562.51 s. JSON totals: line 96.67% (32257/33367, threshold 85%, PASS); branch 93.64% (11720/12516, threshold 75%, PASS). LCOV sums: LF 33367, LH 32257 (96.67%), BRF 12516, BRH 11720 (93.64%). Terminal TOTAL row: 33367 statements, 1110 missed, 12516 branches, 548 partial, 96%.

| Metric | JSON totals | LCOV sums | Threshold | Result |
| --- | --- | --- | --- | --- |
| Line | 96.67% (32257/33367) | LH 32257 / LF 33367 | 85% | PASS |
| Branch | 93.64% (11720/12516) | BRH 11720 / BRF 12516 | 75% | PASS |

No production Python file changed in this item; the one changed .py file (tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py) is under tests/ and is omitted from measurement by [tool.coverage.run] omit.
