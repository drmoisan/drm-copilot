# Pytest Phase 0 Baseline ([P0-T4])

Timestamp: 2026-11-12T03-29
Command: sh SCRATCH/issue-1167-pytest.sh p0t4 (env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/issue-1167-p0t4-cov.json -q -p no:cacheprovider, from the item worktree root)
EXIT_CODE: 0
Output Summary:
- One pytest -n auto run: 16598 passed, 6 skipped, 0 failed, 0 errors in 184.21s (fully green).
- Repo-wide line coverage (JSON totals): 34334 / 35355 statements = 97.11%.
- Repo-wide branch coverage (JSON totals): 12668 / 13424 branches = 94.37%.
- Combined percent_covered (information): 96.36%.
- Per-file production coverage: not in scope (the plan changes no Python production file).
