# Final pytest gate ([P2-T3], remediation cycle 1)

Timestamp: 2026-11-14T01-17
Command: sh SCRATCH/issue-1161-pytest.sh final (in the item worktree: `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-final.json --cov -q -rfE`; per-file figures read from the JSON report)
EXIT_CODE: 0
Output Summary: 16722 passed, 6 skipped, 0 failed in 193.42 s (one `pytest -n auto` run); no FAILED or ERROR line. Repo-wide (configured sources): line 97.13% (34574/35595), branch 94.42% (12785/13540). `scripts/dev_tools/validate_epic_planner_state.py`: line 100.00% (240/240), branch 99.21% (125/126); the one missing arc (176 to 180) is the pre-existing `feature_folder` uniqueness guard in the dependency-and-wave helper, unchanged in position and outside `_validate_planner_worktrees`, which has no missing branch.

## Comparison with the Phase 0 baseline

Baseline: `evidence/remediation-baseline/pytest-gate.2026-11-14T00-58.md` (same run as `pytest-gate.2026-11-14T00-57.md`).

| Measure | Baseline | Final | Result |
|---|---|---|---|
| Failing tests | 0 | 0 | no new failing test |
| Passed | 16714 | 16722 | +8 new corpus rows |
| Validator line | 100.00% (239/239) | 100.00% (240/240) | PASS (100%) |
| Validator branch | 99.21% (125/126) | 99.21% (125/126) | PASS (no drop) |
| Repo-wide line | 97.13% | 97.13% | no drop |
| Repo-wide branch | 94.42% | 94.42% | no drop |
