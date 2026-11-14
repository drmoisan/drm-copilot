# Remediation baseline: pytest gate ([P0-T3], cycle 1, Phase 0 baseline; corrected description)

Timestamp: 2026-11-14T00-58
Command: sh SCRATCH/issue-1161-pytest.sh baseline (in the item worktree: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-baseline.json --cov -q -rfE`; per-file figures read from the JSON report)
EXIT_CODE: 0
Output Summary: 16714 passed, 6 skipped, 0 failed in 234.20 s (one `pytest -n auto` run); no FAILED or ERROR line. Repo-wide (configured sources): line 97.13% (34573/35594), branch 94.42% (12784/13540). `scripts/dev_tools/validate_epic_planner_state.py`: line 100.00% (239/239), branch 99.21% (125/126); missing-branch list: one arc (176 to 180 in the report), the false arm of the `feature_folder` uniqueness guard in the dependency-and-wave helper above `_validate_planner_worktrees`. `_validate_planner_worktrees` has no missing branch.

## Supersedes

This artifact records the same single gate run as `pytest-gate.2026-11-14T00-57.md`. That file misnames the guard behind the missing arc (it says `branch_name`); the figures in both files are identical. The earlier file is left unedited under the append-only rule.
