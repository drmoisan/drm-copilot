# pytest gate (P5-T7)

Timestamp: 2026-11-14T06-55
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1162-cov-final.json --junitxml=SCRATCH/issue-1162-junit-final.xml -q -p no:cacheprovider (from the item worktree root, through sh SCRATCH/issue-1162-pytest-gate.sh)
EXIT_CODE: 0
Output Summary:
- Counts: 16815 passed, 0 failed, 6 skipped (173.26 s). Phase 0 baseline: 16598 passed, 0 failed, 6 skipped.
- Repository total (scripts.dev_tools), from the JSON report: line 94.93% (17145/18060), branch 90.46% (5994/6626). Phase 0 baseline: line 94.83%, branch 90.20%.
- scripts/dev_tools/_epic_orchestrator_state_resolution.py: line 100.00% (177/177), branch 100.00% (102/102). Baseline 100.00% / 100.00%.
- scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py: line 100.00% (98/98), branch 100.00% (50/50). Baseline 100.00% / 100.00%.
- scripts/dev_tools/validate_epic_orchestrator_state.py: line 98.46% (128/130), branch 96.77% (60/62). Baseline 98.44% / 96.77%.
- scripts/dev_tools/validate_epic_planner_state.py: line 100.00% (241/241), branch 99.21% (125/126). Baseline 100.00% / 99.00%.
- Zero failures; each of the four files is at or above 85% line and 75% branch coverage. The run ended at 2026-11-14T06-58.
