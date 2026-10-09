# Baseline: pytest Parity and Manifest-Completeness Tests

Timestamp: 2026-10-08T17-32

## Step 1

Command: poetry install --no-interaction
EXIT_CODE: 0
Output Summary: No dependencies to install or update; installed the current project drm-copilot (0.1.1).

## Step 2

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
EXIT_CODE: 0
Output Summary:
collected 27 items
============================= 27 passed in 0.71s ==============================
B_PY (failing node IDs): (empty set)
