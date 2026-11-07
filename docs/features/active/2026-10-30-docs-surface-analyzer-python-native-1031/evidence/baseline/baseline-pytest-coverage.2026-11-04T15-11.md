# Baseline: Pytest with coverage ([P0-T6])

Timestamp: 2026-11-04T15-11
Command: poetry run python -m pytest --strict-markers --strict-config -n auto -q --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-baseline-coverage.json --cov (bare --cov last, so [tool.coverage.run] source applies)
EXIT_CODE: 0
Output Summary: 16061 passed, 0 failed, 6 skipped in 763.79s. JSON totals: line coverage 96.67% (32257 of 33367 statements), branch coverage 93.64% (11720 of 12516 branches), combined percent_covered 95.85%. PYLIB (.claude/lib/docs/python) does not exist at baseline (new-code baseline: not present).
