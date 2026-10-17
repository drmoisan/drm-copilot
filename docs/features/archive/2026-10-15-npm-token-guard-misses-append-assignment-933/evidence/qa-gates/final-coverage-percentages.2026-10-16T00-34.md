# final-coverage-percentages

Timestamp: 2026-10-16T00-34
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 100 --min-branch 100 2>&1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

```text
line coverage 93.79748270779 is below the required floor 100.0.
branch coverage 88.12814070351759 is below the required floor 100.0.
```

PostChangeLinePercent: 93.79748270779
PostChangeBranchPercent: 88.12814070351759
