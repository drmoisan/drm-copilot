# Isolation — Reversed-Order Python Run

Timestamp: 2026-10-31T17-00
Command: poetry run pytest -p no:cacheprovider -p no:randomly --no-cov -q <modules in reversed order, one process>
EXIT_CODE: 0
Output Summary: 276 passed, 0 failed, in one process with the module order reversed.

Forward order (the plan's list): `test_blast_radius_aggregate.py`, `test_blast_radius_aggregate_properties.py`, `test_blast_radius_combination.py`, `test_blast_radius_combination_threshold.py`, `test_blast_radius_contract_weight.py`, `test_push_down_claude_blast_radius_default_tolerance.py`, `test_parallel_issue_combination_contracts.py`, `test_blast_radius_scheduling.py`, `test_blast_radius_scheduling_properties.py`, `test_blast_radius_historical_runs.py`, `test_parallel_drift_scheduling.py`, `test_blast_radius_config_tolerance_keys.py`, `test_validate_parallel_state_tolerated_edge_fields.py` (all under `tests/scripts/dev_tools/`).

Executed order: the exact reverse of the list above, starting with `test_validate_parallel_state_tolerated_edge_fields.py` and ending with `test_blast_radius_aggregate.py`.
