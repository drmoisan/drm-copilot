# Baseline Coverage Threshold Gate (P0-T17)

Timestamp: 2026-09-27T09-14
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75 2>&1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: no output (line and branch coverage of the P0-T12 report meet the 85% line and 75% branch floors)
