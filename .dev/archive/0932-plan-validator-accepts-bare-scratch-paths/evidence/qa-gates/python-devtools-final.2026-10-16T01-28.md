# Final Python Dev-Tools Regression — Issue #932

Timestamp: 2026-10-16T01-28
Task: [P6-T6]
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider
EXIT_CODE: 0

Output Summary: `7055 passed, 6 skipped in 44.44s`; 0 failed, 0 errors.
- Baseline (python-devtools-baseline.2026-10-16T00-30.md): 7006 passed, 6 skipped, no failing or erroring node.
- Failing or erroring nodes now: none. Newly failing: none. Newly passing: none (the baseline had no failures).
- Passed-count delta: +49, matching the cases this item adds (33 in `test_plan_gate_scratch.py`, 5 in `test_plan_gate_scratch_docs.py`, 11 new parametrizations in `test_scratch_location_contracts.py`).
- No remediation was needed; no out-of-scope-remediation artifact was written.
