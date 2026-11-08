# pytest Parallel Baseline (Phase 0, issue #1118)

Timestamp: 2026-11-07T22-09
Command: sh SCRATCH/issue-1118-pytest.sh baseline (from the item worktree: PYTHONPATH=<item worktree>/packages/discovery-runtime/src env -u VIRTUAL_ENV poetry run pytest -n auto -rfE --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1118-pytest-baseline.json --cov)
EXIT_CODE: 0
Output Summary:
- Result line: 16213 passed, 6 skipped in 225.10s; 0 failed, 0 errors (no `-rfE` FAILED or ERROR lines).
- Repo-wide totals from the JSON report (totals): lines 32456 of 33464 covered (96.99%); branches 11827 of 12560 covered (94.16%); combined percent_covered 96.22%.
- Terminal TOTAL row: 33464 statements, 1008 missed, 12560 branches, 533 partial, 96%.
- No Python file is in scope for issue #1118 (PowerShell-only change); this run is the baseline for the push-down contract tests and the no-new-failure comparison.
