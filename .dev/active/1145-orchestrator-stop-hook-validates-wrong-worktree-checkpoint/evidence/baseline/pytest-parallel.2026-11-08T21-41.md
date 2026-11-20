# pytest Phase 0 Baseline (issue #1145, [P0-T3])

Timestamp: 2026-11-08T21-38
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/pytest-p0.json --junitxml=SCRATCH/pytest-p0.json.junit.xml
EXIT_CODE: 0
Output Summary:
- Run: one `pytest -n auto` gate on the unmodified branch head; finished 2026-11-08T21-41 (210.27 s).
- Counts: 16560 passed, 0 failed, 0 errors, 6 skipped.
- Totals from the JSON report: line 97.11% (34296 of 35317 statements); branch 94.37% (12649 of 13404 branches); combined percent_covered 96.35%.
- Terminal TOTAL row: 35317 statements, 1021 missed, 13404 branches, 555 partial, 96%.
