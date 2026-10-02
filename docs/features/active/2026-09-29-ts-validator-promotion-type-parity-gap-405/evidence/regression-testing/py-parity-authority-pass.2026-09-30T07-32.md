# P1-T14 Python parity reader against the unchanged Python authority

Timestamp: 2026-09-30T07-32
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py
EXIT_CODE: 0
Output Summary:
- Pytest summary line: `15 passed in 0.09s` (three guard tests plus twelve parametrized cases); zero failed.
- P1-T13 line count: `wc -l tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py` printed 220 (below 500).
- All twelve fixtures under `tests/fixtures/orchestrator_state_promotion_type/` matched the Python authority on first run; no fixture correction was needed.
