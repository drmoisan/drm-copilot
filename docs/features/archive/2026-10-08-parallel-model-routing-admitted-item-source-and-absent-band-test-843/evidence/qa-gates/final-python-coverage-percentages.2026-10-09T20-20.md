# Final Python coverage percentages, loop pass 3 (P2-T8)

Timestamp: 2026-10-09T20-20
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/routing-coverage-843.json --min-line 101 --min-branch 101 2>&1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
line coverage 100.0 is below the required floor 101.0.
branch coverage 100.0 is below the required floor 101.0.
PostChangePythonLinePercent: 100.0
PostChangePythonBranchPercent: 100.0
Comparison: BaselinePythonLinePercent 100.0 (P0-T15) and BaselinePythonBranchPercent 100.0 (P0-T15); post-change values are at least 85 / 75 and at least the baselines.
