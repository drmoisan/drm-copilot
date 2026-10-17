# Python Targeted Baseline (P0-T30)

Timestamp: 2026-10-08T22-36

Command: poetry run pytest -v tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py
EXIT_CODE: 0
Output Summary: `119 passed in 0.44s` (PY-TARGET-BASE; 0 failed)

Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 0
Output Summary: `17 passed in 0.34s` (CMD-PY-PARITY; 0 failed)
KL-510: PASSED (`test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED`)

Result: PASS.
