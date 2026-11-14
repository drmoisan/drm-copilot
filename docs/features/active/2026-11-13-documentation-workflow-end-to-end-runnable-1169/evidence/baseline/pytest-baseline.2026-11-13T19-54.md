# pytest Phase 0 Baseline (P0-T3)

Timestamp: 2026-11-13T19-48
Command: sh SCRATCH/issue-1169-pytest.sh p0 (from the worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing -q -p no:cacheprovider; then the line and branch totals are read from artifacts/python/coverage.json)
EXIT_CODE: 0
Output Summary:
- Gate: one pytest -n auto run with coverage (pytest-xdist, coverage source from pyproject [tool.coverage.run]).
- Result: 16598 passed, 0 failed, 6 skipped in 322.50 s.
- Repo-wide line coverage (JSON report totals): 97.11% (34334/35355).
- Repo-wide branch coverage (JSON report totals): 94.37% (12668/13424).
- Terminal report TOTAL row: 35355 statements, 1021 missed, 13424 branches, 556 partial, 96% combined.
- No Python production file is in scope for this plan.
