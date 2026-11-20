# Python Coverage Baseline (remediation cycle 1)

Timestamp: 2026-11-03T19-32
Task: [P0-T5]
Command: poetry run pytest -n auto -q -p no:cacheprovider --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1047-p0t5-cov.json (project addopts in effect: -ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config; source list from [tool.coverage.run]), at branch head 5000b6455 before any edit
EXIT_CODE: 0
Output Summary: 16063 passed, 0 failed, 6 skipped in 492.42 s. Terminal TOTAL row: 33367 statements, 1110 missed, 12516 branches, 548 partial, 96%. JSON totals: line 96.67% (covered_lines 32257 / num_statements 33367); branch 93.64% (covered_branches 11720 / num_branches 12516).

Terminal TOTAL row:

```
TOTAL                                                                                     33367   1110  12516    548    96%
```
