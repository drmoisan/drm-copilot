# Phase 0 baseline: pytest

Timestamp: 2026-11-08T13-13
Command: env -u VIRTUAL_ENV python -m pytest -n auto -q -p no:cacheprovider --cov=scripts --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1130-cov-baseline.json (run from the item worktree root with the main-checkout .venv interpreter; no poetry install in the item worktree)
EXIT_CODE: 0
Output Summary:
- 16537 passed, 6 skipped, 0 failed in 303.35s (one parallel run, pytest-xdist -n auto).
- Repo-wide scripts coverage (combined line+branch column): 94% (17653 statements, 915 missed; 6418 branches, 431 partial).
- In-scope Python file: tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py is test support (not in the coverage denominator); no production Python file is in scope.
