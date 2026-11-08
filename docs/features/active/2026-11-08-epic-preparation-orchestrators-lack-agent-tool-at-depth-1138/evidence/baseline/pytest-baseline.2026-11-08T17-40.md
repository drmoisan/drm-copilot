# pytest Phase 0 Baseline (P0-T4)

Timestamp: 2026-11-08T17-35
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov --cov-report=json:SCRATCH/issue-1138-cov-baseline.json (run from the worktree root through SCRATCH/issue-1138-gates.sh)
EXIT_CODE: 0
Output Summary:
- 16560 passed, 6 skipped, 0 failed in 272.23 s
- Repo-wide line coverage: 97.11% (34296 of 35317 statements)
- Repo-wide branch coverage: 94.37% (12649 of 13404 branches); combined coverage.py total 96.35% (terminal TOTAL row 96%)
- test_frozen_epic_surface_matches_pinned_baseline_digest: passed (no failure in the run)
- test_orchestrate_skill_first_thirteen_headings_match_required_layout: passed (no failure in the run)
