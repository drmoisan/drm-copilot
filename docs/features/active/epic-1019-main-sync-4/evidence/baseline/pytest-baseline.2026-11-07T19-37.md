# Pytest Phase 0 baseline (integration tip before the main merge)

Timestamp: 2026-11-07T19-19
Command: poetry run pytest -n auto --cov --cov-branch --cov-report=json:SCRATCH/baseline/coverage.json --cov-report=term --junitxml=SCRATCH/baseline/pytest-junit.xml -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Tree: epic/documentation-estate-tooling-integration tip 2f5968dca (branch chore/epic-1019-main-sync-4 before the merge).
- Environment: worktree-local Poetry environment (`poetry env info -p` resolved inside the worktree before `poetry install`).
- Result: 16446 passed, 6 skipped, 0 failed in 210.91s.
- Coverage (combined line and branch, TOTAL row): 96% (35273 statements, 1110 missed; 13386 branches, 572 partial).
