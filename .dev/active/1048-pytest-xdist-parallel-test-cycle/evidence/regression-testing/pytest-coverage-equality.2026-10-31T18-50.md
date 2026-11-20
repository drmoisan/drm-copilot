# Coverage equality, serial versus -n auto (#1048, P2-T9)

Timestamp: 2026-10-31T18-50
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1048-xdist.json --cov; poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report SCRATCH/issue-1048-xdist.json --min-line 85 --min-branch 75
EXIT_CODE: 0
Output Summary:
- Test run: 15875 passed, 6 skipped, 0 failed in 139.20 s under 24 xdist workers (exit 0); the serial coverage baseline took 725.25 s.
- Threshold checker exit code: 0.

| Metric | Serial baseline (P0-T2, SCRATCH/issue-1048-serial-baseline.json) | -n auto (SCRATCH/issue-1048-xdist.json) | Difference |
| --- | --- | --- | --- |
| `totals.percent_statements_covered` | 96.6940 (32144 / 33243) | 96.6940 (32144 / 33243) | 0.0000 percentage points |
| `totals.percent_branches_covered` | 93.6298 (11685 / 12480) | 93.6378 (11686 / 12480) | +0.0080 percentage points |

- Both differences are within 0.1 percentage point. The single additional covered branch is run-to-run variance, not an effect of the test edits: the final `-n auto` coverage run (P10-T4, same code) measured 11685/12480 branches, equal to the serial baseline. Which branch varies was not identified.
- Terminal TOTAL row under `-n auto`: 33243 statements, 1099 missed, 12480 branches, 550 partial, 96%.
