# Phase 0 baseline pytest gate ([P0-T3])

Timestamp: 2026-11-10T03-33
Command: sh SCRATCH/issue-1161-pytest.sh baseline (in the item worktree: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-baseline.json --cov -q -rfE`; figures read from the JSON report by SCRATCH/issue-1161-covjson.py)
EXIT_CODE: 0
Output Summary: 16598 passed, 6 skipped, 0 failed in 422.41 s (one `pytest -n auto` run). Repo-wide (configured sources): line 97.11% (34334/35355), branch 94.38% (12669/13424); terminal TOTAL column 96% combined. `scripts/dev_tools/validate_epic_planner_state.py`: line 100.00% (191/191), branch 99.00% (99/100; missing branch 175->179).
