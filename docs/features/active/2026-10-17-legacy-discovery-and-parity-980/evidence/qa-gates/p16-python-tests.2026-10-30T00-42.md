# P16-T1 Python tests gate on the remediated tree

Timestamp: 2026-10-30T00-42
Task: [P16-T1] Run the Python formatting, lint, type and full coverage loop on the remediated tree.
Command: poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p16-coverage.json --junitxml=SCRATCH/issue-980-p16-junit.xml -p no:cacheprovider --cov; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-980-p16-coverage.json --min-line 85 --min-branch 75
EXIT_CODE: 0 (pytest), 0 (threshold gate)
Output Summary: `15728 passed, 6 skipped in 661.48s (0:11:01)` over the complete `tests` population, 0 failed, 0 errors; run from 2026-10-30T00-31 to 2026-10-30T00-42 UTC. JSON report totals: lines 32061/33160 (96.69%), branches 11659/12454 (93.62%), above the 85% line and 75% branch floors. Terminal TOTAL row `TOTAL                                                                                     33160   1099  12454    551    96%`. The CI threshold gate exits 0 (it prints nothing on success). The 6 skips are the pre-existing `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` manifest cases. The JSON report is retained as `p16-python-coverage.2026-10-30T00-42.json` beside this record (P14-T6 recorded 15668 passed, 96.70% lines, 93.62% branches in 929.37 s).
Result: PASS
