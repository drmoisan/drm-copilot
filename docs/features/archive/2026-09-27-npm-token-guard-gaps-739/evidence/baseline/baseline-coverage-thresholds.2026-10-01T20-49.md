# Baseline: coverage policy gate (P0-T13)

Timestamp: 2026-10-01T20-49
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75 2>&1
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: no output
