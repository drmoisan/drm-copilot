# Final Broad Dev-Tools Regression (Remediation Cycle 1, QA loop pass 1)

Timestamp: 2026-10-16T03-01
Task: [P5-T6]
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:

- `7067 passed, 6 skipped in 34.80s`; 0 failed, 0 errors.
- Baseline [P0-T15]: `7055 passed, 6 skipped`, reference failing set empty. The increase of 12 passes equals the new cycle-1 test nodes (4 splitter cases and 2 extractor cases in `test_plan_gate_commands.py`; 2 absorb cases and 2 separator cases in `test_plan_gate_scratch.py`; 2 rule-file tests in `test_plan_gate_scratch_docs.py`).
- Newly failing nodes: none. Newly passing nodes beyond the new tests: none.
