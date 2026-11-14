# Phase 0 baseline pytest gate ([P0-T6])

Timestamp: 2026-11-11T04-11
Command: sh SCRATCH/issue-1159-pytest.sh (in the worktree: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term:skip-covered --cov-report=json:artifacts/python/coverage-p0.json`; coverage source from `[tool.coverage.run]` in `pyproject.toml`)
EXIT_CODE: 0
Output Summary: 16598 passed, 6 skipped, 0 failed in 391.67s (pytest-xdist, -n auto). Repo-wide line coverage 97.11% (34334 of 35355 statements; 1021 missed); branch coverage 94.37% (12668 of 13424 branches; 756 missed, 556 partial); combined term TOTAL 96%. Line and branch figures read from the JSON report totals.

Run start (UTC): 2026-11-11T04-03. The three Python test files that [P4-T4] edits are inside this run; they are test files and are outside the coverage source.
