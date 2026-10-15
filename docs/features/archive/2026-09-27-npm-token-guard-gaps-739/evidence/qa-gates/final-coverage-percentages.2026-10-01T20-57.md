# Final QC: coverage percentage readout (P2-T7)

Timestamp: 2026-10-01T20-57
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 100 --min-branch 100 2>&1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `line coverage 93.52893424562217 is below the required floor 100.0.`
- `branch coverage 86.76187419768935 is below the required floor 100.0.`
- PostChangeLinePercent: 93.52893424562217
- PostChangeBranchPercent: 86.76187419768935
