# Baseline Python coverage percentages (P0-T15)

Timestamp: 2026-10-09T20-11
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/routing-coverage-843.json --min-line 101 --min-branch 101 2>&1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
line coverage 100.0 is below the required floor 101.0.
branch coverage 100.0 is below the required floor 101.0.
BaselinePythonLinePercent: 100.0
BaselinePythonBranchPercent: 100.0
