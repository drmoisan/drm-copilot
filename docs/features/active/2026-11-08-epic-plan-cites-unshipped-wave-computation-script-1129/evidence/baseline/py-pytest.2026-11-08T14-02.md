# py-pytest

Timestamp: 2026-11-08T14-02
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1129-cov-baseline.json --cov
EXIT_CODE: 0
Output Summary:
16537 passed, 6 skipped, 0 failed in 352.51s (pytest -n auto).
Coverage read from the JSON report:
repo-wide: lines 97.11% (34287/35308) branches 94.37% (12645/13400)
scripts/dev_tools/epic_wave_computation.py: lines 100.00% (26/26) branches 100.00% (8/8)
scripts/dev_tools/push_down_codex_and_agents_customizations.py: lines 98.17% (107/109) branches 88.89% (16/18)
scripts/dev_tools/validate_epic_planner_state.py: lines 100.00% (191/191) branches 99.00% (99/100)
