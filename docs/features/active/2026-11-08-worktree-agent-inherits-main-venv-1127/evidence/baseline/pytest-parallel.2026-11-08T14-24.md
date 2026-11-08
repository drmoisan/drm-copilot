# Phase 0 baseline: pytest parallel gate (P0-T4)

Timestamp: 2026-11-08T14-24
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1127-pytest-baseline.json --cov -q -rfE (from the item worktree root, through sh SCRATCH/issue-1127-pytest.sh baseline; run started 2026-11-08T14-17 UTC)
EXIT_CODE: 0
Output Summary:
- 16537 passed, 0 failed, 6 skipped in 387.01 s
- Failing node IDs: none
- Repo-wide line coverage (JSON totals): 97.11% (34287 of 35308 statements)
- Repo-wide branch coverage (JSON totals): 94.37% (12645 of 13400 branches)
- Combined percent_covered (JSON totals): 96.35%; terminal TOTAL row 96%
