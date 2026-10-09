# QC Pass 2: pytest Parity and Manifest Completeness ([P10-T10])

Timestamp: 2026-10-08T23-22
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
EXIT_CODE: 0
Output Summary:
collected 27 items
============================= 27 passed in 0.34s ==============================
Summary line printed; total 27 (> 0). Failing node IDs: none (subset of `B_PY`, which is empty).

Note: an immediately preceding equivalent run used `poetry -C <WORKSPACE_ROOT> run pytest` with the same four files given as absolute paths (27 passed, exit 0); the command above is the verbatim [P0-T19] command and is the recorded result.
