# Python Coverage Re-Measurement (Issue 1019, Cycle 1 re-plan)

Timestamp: 2026-11-06T18-16
Command: sh SCRATCH/issue-1019-cov.sh (PYTHONPATH=packages/discovery-runtime/src; poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json -q; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75)
EXIT_CODE: 0
Output Summary:
- Supersedes qc-python-coverage.2026-11-06T18-08.md: that measurement resolved the discovery package to a sibling worktree, so the files under packages/discovery-runtime/src in this worktree measured 0%.
- Imported discovery package: packages/discovery-runtime/src/drm_copilot_discovery/__init__.py (inside this worktree).
- PYTEST_EXIT=0, THRESHOLD_EXIT=0.
- Tests: 16099 passed, 0 failed, 6 skipped.
- Repo-wide line coverage (percent_statements_covered, JSON totals): 96.71% (32270 covered of 33367 statements incl. branch-combined figure 95.88%).
- Repo-wide branch coverage (percent_branches_covered, JSON totals): 93.66% (11722 of 12516 branches).
- Thresholds: line >= 85 PASS, branch >= 75 PASS.
- artifacts/python/lcov.info exists.
