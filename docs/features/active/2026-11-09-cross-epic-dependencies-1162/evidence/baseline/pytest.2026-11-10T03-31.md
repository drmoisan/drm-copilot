# pytest Phase 0 baseline (P0-T6)

Timestamp: 2026-11-10T03-31
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1162-cov-baseline.json --junitxml=SCRATCH/issue-1162-junit-baseline.xml -q -p no:cacheprovider (from the item worktree root, through sh SCRATCH/issue-1162-pytest.sh)
EXIT_CODE: 0
Output Summary:
- Counts: 16598 passed, 0 failed, 6 skipped (298.21 s). No pre-existing failure in this run.
- Repository total (scripts.dev_tools): line 94.83% (16785/17700), branch 90.20% (5811/6442), from the JSON report.
- scripts/dev_tools/_epic_orchestrator_state_resolution.py: line 100.00% (85/85), branch 100.00% (48/48).
- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py: line 100.00% (73/73), branch 100.00% (36/36).
- scripts/dev_tools/validate_epic_orchestrator_state.py: line 98.44% (126/128), branch 96.77% (60/62).
- scripts/dev_tools/validate_epic_planner_state.py: line 100.00% (191/191), branch 99.00% (99/100).
- Note: the JSON report path was translated by the MSYS shell to a drive-rooted copy of SCRATCH; the figures were read from that file. The launcher was corrected to a mixed-form SCRATCH path for later runs.
