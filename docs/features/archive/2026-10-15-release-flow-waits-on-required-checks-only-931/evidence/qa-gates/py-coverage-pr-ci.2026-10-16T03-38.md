# Python Coverage on the PR CI Run (Issue #931, finding R2)

Timestamp: 2026-10-16T03-38
Command: gh run view 38845165586 --job 116793934193 --log (job `quality-checks7 / Code Quality & Tests (3.13)`, read with the Grep and Read tools)
EXIT_CODE: 0
Output Summary: Job 116793934193 concluded success. pytest ended with `7100 passed, 6 skipped`. The step `Enforce Python coverage thresholds` ran `check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75` and the job concluded success. pytest `TOTAL` row: 17638 statements, 1108 missed, 6368 branches, 504 partial, 92 percent combined; line coverage (17638 - 1108) / 17638 = 93.72 percent, equal to the 93.72 percent merge-base value in `remediation-inputs.2026-10-16T03-14.md`.

Python files changed by this item: `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` only, a test module outside coverage measurement.

The 3.10, 3.11, and 3.12 jobs of the same workflow also concluded success on the same head.
