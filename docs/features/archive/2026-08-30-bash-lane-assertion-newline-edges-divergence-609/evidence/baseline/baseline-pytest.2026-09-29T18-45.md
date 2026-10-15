# Baseline Pytest (P0-T7)

Timestamp: 2026-10-01T23:13:30-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/scripts/dev_tools/test_parallel_lane_assertion.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 0
Output Summary: collected 82 items; 82 passed in 0.39s; zero failed. No pre-existing failure, including the push-down contract test file (all 14 of its tests passed).

N_b = 82 (baseline pass count). Post-fix expected count is N_b + 1 = 83 (the new fixture node `edges_newline_separated`).
