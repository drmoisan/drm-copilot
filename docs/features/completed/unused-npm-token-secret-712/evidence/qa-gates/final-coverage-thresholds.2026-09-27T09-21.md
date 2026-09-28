# Final QC - Coverage Threshold Gate (P5-T6)

Timestamp: 2026-09-27T09-21
Command: poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75 2>&1
EXIT_CODE: 0
Output Summary: no output (the P5-T5 report meets the 85% line and 75% branch floors)
BaselineThresholdArtifact: docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-coverage-thresholds.2026-09-27T09-14.md
