# Baseline: pytest parallel run (issue 1105)

Timestamp: 2026-11-07T14-43
Task: [P0-T4]
Command: sh SCRATCH/issue-1105-pytest.sh baseline (`poetry run pytest -n auto -q -rfE -p no:cacheprovider` from the item worktree root; output to SCRATCH/issue-1105-baseline-pytest.log)
EXIT_CODE: 0
Output Summary:
- Final summary: 16179 passed, 6 skipped in 71.97s.
- Totals: passed 16179, failed 0, skipped 6, errors 0.
- Failing tests: none.
- Environment: the item worktree has no `.venv`; `poetry run` used the inherited Poetry environment (probe confirmed `xdist` and `pytest_cov` import). No `poetry install` was run.
- Run before any code change.
