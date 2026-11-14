# Phase 0 Baseline: pytest (parallel)

Timestamp: 2026-11-14T11-50
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing -q -p no:cacheprovider (worktree root, through SCRATCH/issue-1182-pytest.sh), one run
EXIT_CODE: 0
Output Summary:
- "16823 passed, 6 skipped in 205.67s (0:03:25)". Failed 0; failing tests: none.
- The two untracked [P1-T1] Pester suites were moved to SCRATCH for the run and restored afterwards.
- Python coverage: N/A - no Python production change. For reference, the run's repo-wide totals were line 97.14% (34694/35715) and branch 94.45% (12853/13608).
