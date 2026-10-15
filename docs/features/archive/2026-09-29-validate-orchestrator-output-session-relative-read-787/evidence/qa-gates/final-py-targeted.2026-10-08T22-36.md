# Final Targeted and Parity Python Runs (P6-T15), pass 1

Timestamp: 2026-10-08T22-36

Command: poetry run pytest -v <PY-TARGET: the six PY-TARGET-BASE files plus tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py>
EXIT_CODE: 0
Output Summary: `149 passed in 0.69s`; 0 failed.

Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 0
Output Summary: `17 passed in 0.57s`; no failed node.
KL-510: PASSED (`test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED`)

Result: PASS.
