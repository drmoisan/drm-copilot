# Baseline: coverage percentage readout (P0-T14)

Timestamp: 2026-10-01T20-49
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 100 --min-branch 100 2>&1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `line coverage 93.52893424562217 is below the required floor 100.0.`
- `branch coverage 86.76187419768935 is below the required floor 100.0.`
- BaselineLinePercent: 93.52893424562217
- BaselineBranchPercent: 86.76187419768935
