# pytest Phase 0 Baseline — Remediation Cycle 1, P0-T5 (Issue 1162)

Timestamp: 2026-11-14T08-15
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1162-cov-p0.json --junitxml=SCRATCH/issue-1162-junit-p0.xml -q -p no:cacheprovider (from the item worktree root, through sh SCRATCH/issue-1162-pytest-gate.sh p0)
EXIT_CODE: 0
Output Summary:
- Counts: 16815 passed, 0 failed, 6 skipped (186.92 s). Started 2026-11-14T08-15-10Z, ended 2026-11-14T08-18-23Z.
- Repository total (scripts.dev_tools), from the JSON report totals: line 94.93% (17145/18060 statements covered), branch 90.48% (5995/6626). The combined line-and-branch figure that coverage.py reports as `percent_covered` is 93.74%.
- `artifacts/python/lcov.info` was rewritten by this run (addopts reporter).
- No Python production file changes in this cycle; the figures are the reference for the final pytest gate.
